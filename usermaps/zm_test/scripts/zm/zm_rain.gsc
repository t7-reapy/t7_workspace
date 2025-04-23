#using scripts\zm\_util;
#using scripts\zm\_zm_utility;
#using scripts\shared\util_shared;

#using scripts\shared\array_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\system_shared;
#using scripts\shared\clientfield_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

////////////////////////////////////
//              RAIN              //
////////////////////////////////////

#using scripts\zm\_zm_postfx_rain_drops;

#namespace zm_rain;

class Rain {
    var enabled;
    var source_ent;
}

class Thunder {
    var enabled;
    var lightstate_missing;
    var lightstate_strikes;
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
    level.thunder.lightstate_missing = LIGHTSTATE_THUNDER_MISSING;
    level.thunder.lightstate_strikes = LIGHTSTATE_THUNDER_STRIKES;
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

// TODO: review the way the thunder is triggered and "positionned" to give a better realistic feeling.
//       today the sound is played "onto" the player itself
// TODO 2: play a thunder strike is the sky ?
function private thunder_plays()
{
    while(1)
    {
        wait RandomIntRange(9,15);
        nb = RandomIntRange(0,100);

        if (!level.thunder.enabled) 
        {
            // Exits, skipping next thunder strikes if thunder was disabled elsewhere
            // We don't use endon() to avoid being blocked in a wrong light state ...
            return;
        }
            
        if(nb > 80)
        {
            self util::set_lighting_state(self.thunder.lightstate_strikes);
            PlaySoundAtPosition("thunder_short", (0,0,0));
            wait RandomFloatRange(0.1,0.6);
            self util::set_lighting_state(self.thunder.lightstate_missing);
        }
        if(nb > 60 && nb <= 80)
        {
            self util::set_lighting_state(self.thunder.lightstate_strikes);
            PlaySoundAtPosition("thunder_short", (0,0,0));
            wait RandomFloatRange(0.6,1.5);
            self util::set_lighting_state(self.thunder.lightstate_missing);
        }
        if(nb > 40 && nb <= 60)
        {
            self util::set_lighting_state(self.thunder.lightstate_strikes);
            PlaySoundAtPosition("thunder_short", (0,0,0));
            wait RandomFloatRange(0.1,0.6);
            self util::set_lighting_state(self.thunder.lightstate_missing);
        }
        if(nb > 20 && nb <= 40)
        {
            self util::set_lighting_state(self.thunder.lightstate_strikes);
            PlaySoundAtPosition("thunder_short", (0,0,0));
            wait RandomFloatRange(0.4,0.6);
            self util::set_lighting_state(self.thunder.lightstate_missing);
            wait RandomFloatRange(0.1,0.3);
            self util::set_lighting_state(self.thunder.lightstate_strikes);
            wait RandomFloatRange(0.6,0.9);
            self util::set_lighting_state(self.thunder.lightstate_missing);
            wait RandomFloatRange(2,4);
            self util::set_lighting_state(self.thunder.lightstate_strikes);
            wait RandomFloatRange(0.6,0.6);
            self util::set_lighting_state(self.thunder.lightstate_missing);
        }
        if(nb > 10 && nb <= 20)
        {
            self util::set_lighting_state(self.thunder.lightstate_strikes);
            PlaySoundAtPosition("thunder_short", (0,0,0));
            wait RandomFloatRange(0.4,0.6);
            self util::set_lighting_state(self.thunder.lightstate_missing);
            wait RandomFloatRange(0.1,0.3);
            self util::set_lighting_state(self.thunder.lightstate_strikes);
            wait RandomFloatRange(0.6,0.9);
            self util::set_lighting_state(self.thunder.lightstate_missing);
            wait RandomFloatRange(0.1,0.2);
            self util::set_lighting_state(self.thunder.lightstate_strikes);
            wait RandomFloatRange(0.6,0.6);
            self util::set_lighting_state(self.thunder.lightstate_missing);
        }
    }
}