#using scripts\shared\exploder_shared; 
#using scripts\shared\util_shared; 
#using scripts\shared\clientfield_shared; 

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\weather\zm_weather_shared.gsh;
#insert scripts\zm\weather\zm_weather_thunder.gsh;

#namespace zm_weather_thunder;

class Thunder {
    var paused;
    var intensity;

    var exploders;

    var min_wait;
    var max_wait;

    var lightstate_missing;
    var lightstate_strikes;
}

function init() 
{
    level.weather.thunder = default_thunder_state();
}

function play()
{
    level endon("entityshutdown");
    level endon("level_stop_thunder");

    if (!level.weather.thunder.paused)
    {
        WEATHER_PRINT_DEBUG("thunder already running");
        return;
    }
    level.weather.thunder.paused = false;

    while(true)
    {
        level.weather.thunder thunder_strike();
        WAIT_SERVER_FRAME;
    }
}

function pause()
{
    if (level.weather.thunder.paused)
    {
        WEATHER_PRINT_DEBUG("already paused thunder");
        return;
    }

    level notify("level_stop_thunder");
    level notify("thunder_end_current_strike");
    level.weather.thunder = default_thunder_state();
}

function private default_thunder_state() 
{
    thunder = new Thunder();
    thunder.paused = true;
    thunder.intensity = WEATHER_INTENSITY_DEFAULT;
    thunder.min_wait = THUNDER_DEFAULT_MIN_WAIT[thunder.intensity];
    thunder.max_wait = THUNDER_DEFAULT_MAX_WAIT[thunder.intensity];
    thunder.lightstate_missing = THUNDER_DEFAULT_LIGHTSTATE;
    thunder.lightstate_strikes = THUNDER_STRIKES_LIGHTSTATE;
    thunder.exploders = THUNDER_EXPLODERS;

    return thunder;
}

function greater_intensity()
{
    if (level.weather.thunder.intensity >= WEATHER_INTENSITY_HIG)
    {
        return;
    }
    level.weather.thunder.intensity++;
    level.weather.thunder.min_wait = THUNDER_DEFAULT_MIN_WAIT[level.weather.thunder.intensity];
    level.weather.thunder.max_wait = THUNDER_DEFAULT_MAX_WAIT[level.weather.thunder.intensity];
    level notify("thunder_end_current_strike");
    level util::set_lighting_state(level.weather.thunder.lightstate_missing);
}

function lesser_intensity()
{
    if (level.weather.thunder.intensity <= WEATHER_INTENSITY_LOW)
    {
        return;
    }
    level.weather.thunder.intensity--;
    level.weather.thunder.min_wait = THUNDER_DEFAULT_MIN_WAIT[level.weather.thunder.intensity];
    level.weather.thunder.max_wait = THUNDER_DEFAULT_MAX_WAIT[level.weather.thunder.intensity];
    level notify("thunder_end_current_strike");
    level util::set_lighting_state(level.weather.thunder.lightstate_missing);
}

function private thunder_strike() // self = Thunder (level.weather.thunder)
{
    level endon("thunder_end_current_strike");

    wait RandomFloatRange(self.min_wait, self.max_wait);

    thunder_lightstate = self.lightstate_strikes[RandomIntRange(0, self.lightstate_strikes.size)];
    flashes = RandomIntRange(3, 5);

    exploder::exploder(self.exploders[RandomInt(self.exploders.size)]);
    for (i = 0; i < flashes; i++)
    {
        wait RandomFloatRange(0.15 / flashes, 0.25 / flashes);
        level util::set_lighting_state(thunder_lightstate);

        wait RandomFloatRange(0.30 / flashes, 0.50 / flashes);
        level util::set_lighting_state(self.lightstate_missing);
    }
}