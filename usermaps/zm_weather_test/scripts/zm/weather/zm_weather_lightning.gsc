#using scripts\shared\clientfield_shared; 

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\weather\zm_weather_shared.gsh;
#insert scripts\zm\weather\zm_weather_lightning.gsh;

#namespace zm_weather_lightning;

class Lightning {
    var paused;

    var intensity;

    var min_wait;
    var max_wait;
}

function init() {
    clientfield::register("world", LIGHTNING_EXPLODER_CF_NAME, VERSION_SHIP, 2, "int");

    level.weather.lightning = default_lightning_state();
}

function play()
{
    level endon("entityshutdown");
    level endon("level_stop_lightning");

    if (!level.weather.lightning.paused)
    {
        WEATHER_PRINT_DEBUG("lightning already running");
        return;
    }
    level.weather.lightning.paused = false;

    if (level.weather.lightning.intensity == WEATHER_INTENSITY_OFF)
    {
        level.weather.lightning.intensity = WEATHER_INTENSITY_DEFAULT;
    }

    while(true)
    {
        level.weather.lightning lightning_strike();
        WAIT_SERVER_FRAME;
    }
}

function pause()
{
    if (level.weather.lightning.paused)
    {
        WEATHER_PRINT_DEBUG("already paused lightning");
        return;
    }

    level notify("level_stop_lightning");
    level notify("lightning_end_current_strike");
    level.weather.lightning = default_lightning_state();
    level clientfield::set(LIGHTNING_EXPLODER_CF_NAME, WEATHER_INTENSITY_OFF);
}

function private default_lightning_state() 
{
    lightning = new Lightning();
    lightning.paused = true;
    lightning.intensity = WEATHER_INTENSITY_OFF;
    lightning.min_wait = LIGHTNING_BASE_MIN_WAIT[lightning.intensity];
    lightning.max_wait = LIGHTNING_BASE_MAX_WAIT[lightning.intensity];
    
    return lightning;
}

function greater_intensity()
{
    if (level.weather.lightning.intensity >= WEATHER_INTENSITY_HIG
        || level.weather.lightning.intensity == WEATHER_INTENSITY_OFF)
    {
        return;
    }

    level.weather.lightning.intensity++;
    level.weather.lightning.min_wait = LIGHTNING_BASE_MIN_WAIT[level.weather.lightning.intensity];
    level.weather.lightning.max_wait = LIGHTNING_BASE_MAX_WAIT[level.weather.lightning.intensity];
    level notify("lightning_end_current_strike");
}

function lesser_intensity()
{
    if (level.weather.lightning.intensity <= WEATHER_INTENSITY_LOW
        || level.weather.lightning.intensity == WEATHER_INTENSITY_OFF)
    {
        return;
    }

    level.weather.lightning.intensity--;
    level.weather.lightning.min_wait = LIGHTNING_BASE_MIN_WAIT[level.weather.lightning.intensity];
    level.weather.lightning.max_wait = LIGHTNING_BASE_MAX_WAIT[level.weather.lightning.intensity];
    level notify("lightning_end_current_strike");
}

function private lightning_strike() // self == lightning (level.weather.lightning)
{
    level endon("lightning_end_current_strike");

    wait RandomFloatRange(self.min_wait, self.max_wait);
    level clientfield::set(LIGHTNING_EXPLODER_CF_NAME, self.intensity);
    WAIT_SERVER_FRAME;
    level clientfield::set(LIGHTNING_EXPLODER_CF_NAME, WEATHER_INTENSITY_OFF);
}