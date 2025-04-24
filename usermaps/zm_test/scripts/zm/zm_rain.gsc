#using scripts\zm\_util;
#using scripts\zm\_zm_utility;
#using scripts\shared\util_shared;

#using scripts\shared\array_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\system_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\clientfield_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

////////////////////////////////////
//              RAIN              //
////////////////////////////////////
#define ORIGIN_DEFAULT (0, 0, 0)
#define IS_DISTANT_THUNDER(__val) (__val > THUNDER_CLOSE_STRIKE_CHANCE_PERCENT)

#using scripts\zm\_zm_postfx_rain_drops;

#namespace zm_rain;

class Rain {
    var enabled;
    var source_ent;
}

class CloseThunder {
    var lightstate_missing; // LIGHTSTATE_THUNDER_MISSING
    var lightstate_strikes; // LIGHTSTATE_THUNDER_CLOSE_STRIKES
    var sounds; // THUNDER_CLOSE_SOUNDS
}

class DistantThunder {
    var exploders; //THUNDER_DISTANT_EXPLODERS
    var sounds; //THUNDER_DISTANT_SOUNDS
}

class Thunder {
    var enabled;
    var close; // CloseThunder
    var distant; // DistantThunder
}

#insert scripts\zm\zm_rain.gsh;
#precache ("fx", FX_RAIN_LIGHT);
#precache ("fx", FX_RAIN_REGULAR);
#precache ("fx", FX_RAIN_HEAVY);

REGISTER_SYSTEM_EX("zm_rain", &init, &main, undefined)

function init() 
{
    // Rain
    level.rain = new Rain();
    level.rain.enabled = SHOULD_START_WITH_RAIN;
    level.rain.source_ent = GetEnt("rain_source", "targetname");
    level define_rain_amount();
    clientfield::register("world", DECAL_RAIN_TOGGLE, VERSION_SHIP, 1, "int");
    clientfield::register("world", FX_RAIN_TOGGLE, VERSION_SHIP, 1, "int");

    // Thunder
    level.thunder = new Thunder();
    level.thunder.enabled = SHOULD_START_WITH_THUNDER;
    
    level.thunder.distant = new DistantThunder();
    level.thunder.distant.exploders = THUNDER_DISTANT_EXPLODERS;
    level.thunder.distant.sounds = THUNDER_DISTANT_SOUNDS;

    level.thunder.close = new CloseThunder();
    level.thunder.close.lightstate_missing = LIGHTSTATE_THUNDER_MISSING;
    level.thunder.close.lightstate_strikes = LIGHTSTATE_THUNDER_STRIKES;
    level.thunder.close.sounds = THUNDER_CLOSE_SOUNDS;
}

function main() 
{
    level flag::wait_till("initial_blackscreen_passed");

    level clientfield::set(DECAL_RAIN_TOGGLE, SHOULD_START_WITH_RAIN);
    level clientfield::set(FX_RAIN_TOGGLE, SHOULD_START_WITH_RAIN);

    if (SHOULD_START_WITH_RAIN)
    {
        level thread rain_plays();
    }
    
    if (SHOULD_START_WITH_THUNDER)
    {
        level thread thunder_plays();
    }
}

function toggle_rain()
{
    level.rain.enabled = !level.rain.enabled;

    if (level.rain.enabled)
    {
        level thread rain_plays();
    } 
    else 
    {
        level rain_stops();
    }

    level clientfield::set(FX_RAIN_TOGGLE, level.rain.enabled);
    level clientfield::set(DECAL_RAIN_TOGGLE, level.rain.enabled);
}

function toggle_thunder()
{
    level.thunder.enabled = !level.thunder.enabled;

    if (level.thunder.enabled)
    {
        level thread thunder_plays();
    }
}

function private define_rain_amount()
{
    //self._effect[ "player_rain" ] = FX_RAIN_LIGHT;
    //self._effect[ "player_rain" ] = FX_RAIN_REGULAR;
    self._effect[ "player_rain" ] = FX_RAIN_HEAVY;
}

function private rain_plays()
{
    // TODO: rework sound localization in the map...
    self.rain.source_ent PlayLoopSound("rain_sounds");
}

function private rain_stops()
{
    // TODO: rework sound localization in the map...
    self.rain.source_ent StopSound("rain_sounds");
}

function private thunder_plays()
{
    // self = level
    while(1)
    {
        wait RandomIntRange(MIN_WAIT_BETWEEN_STRIKES, MAX_WAIT_BETWEEN_STRIKES);

        if (!self.thunder.enabled) 
        {
            // Exits, skipping next thunder strikes if thunder was disabled elsewhere
            // We don't use endon() to avoid being blocked in a wrong light state ...
            return;
        }
        
        percent_val = RandomIntRange(1, 100);
        if(IS_DISTANT_THUNDER(percent_val))
        {
            random_sound_index = RandomIntRange(0, self.thunder.distant.sounds.size);
            sound = self.thunder.distant.sounds[random_sound_index];
            random_exploder_index = RandomIntRange(0, self.thunder.distant.exploders.size);
            exploder = self.thunder.distant.exploders[random_exploder_index];

            // Strikes distant thunder
            exploder::exploder(exploder);
            delay = RandomFloatRange(1.0, THUNDER_DISTANT_DELAY); // Strike is distant, so the sound takes time to come to player's ears
            wait delay;
            PlaySoundAtPosition(sound, ORIGIN_DEFAULT);
            if (delay < THUNDER_DISTANT_DELAY)
            {
                wait (THUNDER_DISTANT_DELAY - delay);
            }
            exploder::exploder_stop(exploder);
        }
        else
        {
            random_sound_index = RandomIntRange(0, self.thunder.close.sounds.size);
            sound = self.thunder.close.sounds[random_sound_index];
            random_lightstate_index = RandomIntRange(0, self.thunder.close.lightstate_strikes.size);
            lightstate = self.thunder.close.lightstate_strikes[random_lightstate_index];

            // Strikes close thunder
            self util::set_lighting_state(lightstate);
            PlaySoundAtPosition(sound, ORIGIN_DEFAULT);
            wait RandomFloatRange(0.3, 0.9);
            self util::set_lighting_state(self.thunder.close.lightstate_missing);
            wait RandomFloatRange(0.05, 0.2);
            self util::set_lighting_state(lightstate);
            wait RandomFloatRange(0.2, 0.4);
            self util::set_lighting_state(self.thunder.close.lightstate_missing);
        }
    }
}