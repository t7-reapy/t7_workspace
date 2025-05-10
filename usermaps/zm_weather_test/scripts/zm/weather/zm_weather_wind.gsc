#using scripts\shared\array_shared; 
#using scripts\shared\exploder_shared; 

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\weather\zm_weather_shared.gsh;
#insert scripts\zm\weather\zm_weather_wind.gsh;

#namespace zm_weather_wind;

class Wind {
    var paused;
    var intensity;

    var exploders;

    var min_wait;
    var max_wait;
}

function private default_wind_state()
{
    wind = new Wind();
    
    wind.paused = true;
    wind.intensity = WEATHER_INTENSITY_OFF;
    wind.exploders = WIND_EXPLODERS;
    wind.min_wait = WIND_MIN_WAIT[wind.intensity];
    wind.max_wait = WIND_MAX_WAIT[wind.intensity];

    return wind;
}

function init() {
    level.weather.wind = default_wind_state();
}

function play()
{
    level endon("entityshutdown");
    level endon("level_stop_wind");

    if (!level.weather.wind.paused)
    {
        WEATHER_PRINT_DEBUG("wind already running");
        return;
    }
    level.weather.wind.paused = false;
    level.weather.wind.intensity = WEATHER_INTENSITY_DEFAULT;

    while(true)
    {
        level.weather.wind wind_blow();
        WAIT_SERVER_FRAME;
    }
}

function pause()
{
    if (level.weather.wind.paused)
    {
        WEATHER_PRINT_DEBUG("already paused wind");
        return;
    }

    level notify("level_stop_wind");
    level notify("wind_end_current_blow");
    level.weather.wind = default_wind_state();
}

function private wind_blow() 
{
    // self = Wind (level.weather.wind)
    level endon("wind_end_current_blow");

    wait RandomFloatRange(self.min_wait, self.max_wait);
    WEATHER_PRINT_DEBUG("wind blow");

    foreach(exploder in self.exploders) 
    {
        // Note: wind SFX is included in the FX of the radiant exploder.
        exploder::exploder(exploder);
        wait WIND_DELAY_FOR_TOSSING_OBJECTS;
        self thread toss_objects_around();
        wait WIND_EXPLODER_WAIT_TIME;
        exploder::exploder_stop(exploder);
    }
}

function private toss_objects_around()
{
    // self = Wind (level.weather.wind)

    // TODO: use API to toss around some objects for wind blows
    // Like: PhysicsLaunch, PhysicsJetThrust, PhysicsExplosionCylinder, ...
}

function greater_intensity()
{
    if (level.weather.wind.intensity >= WEATHER_INTENSITY_HIG)
    {
        return;
    }
    level.weather.wind.intensity++;
    level.weather.wind.min_wait = WIND_MIN_WAIT[level.weather.wind.intensity];
    level.weather.wind.max_wait = WIND_MAX_WAIT[level.weather.wind.intensity];
    level notify("wind_end_current_blow");
}

function lesser_intensity()
{
    if (level.weather.wind.intensity <= WEATHER_INTENSITY_LOW)
    {
        return;
    }
    level.weather.wind.intensity--;
    level.weather.wind.min_wait = WIND_MIN_WAIT[level.weather.wind.intensity];
    level.weather.wind.max_wait = WIND_MAX_WAIT[level.weather.wind.intensity];
    level notify("wind_end_current_blow");
}
