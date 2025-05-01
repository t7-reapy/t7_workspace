#using scripts\shared\flag_shared; 
#using scripts\shared\util_shared; 

#insert scripts\shared\shared.gsh;

#insert scripts\zm\weather\zm_weather_shared.gsh;
#insert scripts\zm\weather\zm_weather_thunder.gsh;
#namespace zm_weather_thunder;

class Thunder {
    var min_wait;
    var max_wait;

    var lightstate_missing;
    var lightstate_strikes;
    
    var sounds;
    var effects;
}

function init() {
    WEATHER_ASSERT_INIT;
    level.weather.thunder = default_thunder_state();
}

function run()
{
    WEATHER_THUNDER_ASSERT_INIT;
    level endon(KILL_THUNDER_NOTIFICATION);
    WEATHER_PRINT_DEBUG("thunder plays");

    while(level flag::get(ACTIVE_THUNDER_FLAG))
    {
        level.weather.thunder thunder_strikes();
        WAIT_SERVER_FRAME;
    }

    // striking stoppped, let's restore defaults.
    level.weather.thunder = default_thunder_state();
    WEATHER_PRINT_DEBUG("thunder stops");
}

function private default_thunder_state() 
{
    thunder = new Thunder();
    thunder.min_wait = DEFAULT_MIN_WAIT_THUNDER;
    thunder.max_wait = DEFAULT_MAX_WAIT_THUNDER;
    thunder.waiting = false;
    thunder.lightstate_missing = THUNDER_DEFAULT_LIGHTSTATE;
    thunder.lightstate_strikes = THUNDER_STRIKES_LIGHTSTATE;
    thunder.sounds = THUNDER_SOUNDS;
    thunder.effects = undefined; // TODO: https://github.com/McReaper/bo3maps/issues/16

    return thunder;
}

function higher_frequency()
{
    WEATHER_THUNDER_ASSERT_INIT;
    WEATHER_PRINT_DEBUG("thunder frequency +");
    level.weather.thunder.min_wait /= HIGH_FREQUENCY_FACTOR_THUNDER;
    level.weather.thunder.max_wait /= HIGH_FREQUENCY_FACTOR_THUNDER;

    // TODO: find a way to reset loop to not be blocked in previous lightning strikes waiting
}

function lower_frequency()
{
    WEATHER_THUNDER_ASSERT_INIT;
    WEATHER_PRINT_DEBUG("thunder frequency -");
    level.weather.thunder.min_wait *= HIGH_FREQUENCY_FACTOR_THUNDER;
    level.weather.thunder.max_wait *= HIGH_FREQUENCY_FACTOR_THUNDER;

    // TODO: find a way to reset loop to not be blocked in previous lightning strikes waiting
}

function private thunder_strikes() 
{
    // self = Thunder (level.weather.thunder)

    WEATHER_PRINT_DEBUG("preparing thunder strike...");
    thunder.waiting = true;
    wait RandomFloatRange(self.min_wait, self.max_wait);
    thunder.waiting = false;

    if (!level flag::get(ACTIVE_THUNDER_FLAG))
    {
        WEATHER_PRINT_DEBUG("thunder strike canceled");
        return;
    }

    // TODO: play FXs with level.weather.thunder.effects

    thunder_sound = self.sounds[RandomIntRange(0, self.sounds.size)];
    thunder_effect = undefined; //self.effects[RandomIntRange(0, self.effects.size)];
    thunder_lightstate = self.lightstate_strikes[RandomIntRange(0, self.lightstate_strikes.size)];

    WEATHER_PRINT_DEBUG("thunder strike !");
    PlaySoundAtPosition(thunder_sound, (0, 0, 0));
    level util::set_lighting_state(thunder_lightstate);
    wait RandomFloatRange(0.3, 0.9);
    level util::set_lighting_state(self.lightstate_missing);
    wait RandomFloatRange(0.05, 0.2);
    level util::set_lighting_state(thunder_lightstate);
    wait RandomFloatRange(0.2, 0.4);
    level util::set_lighting_state(self.lightstate_missing);
}