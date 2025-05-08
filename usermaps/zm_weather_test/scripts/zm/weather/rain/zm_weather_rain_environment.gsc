#using scripts\shared\clientfield_shared; 

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\weather\zm_weather_shared.gsh;
#insert scripts\zm\weather\zm_weather_rain.gsh;
#insert scripts\zm\weather\rain\zm_weather_rain_environment.gsh;

#namespace zm_weather_rain_environment;

class RainEnvironment {
    var paused;
}

function init() 
{
    clientfield::register("world", DECAL_RAIN_TOGGLE, VERSION_SHIP, 1, "int");
    clientfield::register("world", RAIN_EXPLODERS_CF_NAME, VERSION_SHIP, 2, "int");

    level.weather.rain.environment = new RainEnvironment();
    level.weather.rain.environment.paused = true;
}

function play() 
{
    level endon("level_stop_rain_environment");
    level endon("entityshutdown");

    if (!level.weather.rain.environment.paused)
    {
        WEATHER_PRINT_DEBUG("already running rain environment");
        return;
    }
    
    level.weather.rain.environment.paused = false;

    while(true)
    {
        update();
        WAIT_SERVER_FRAME;
    }
}

function pause()
{
    if (level.weather.rain.environment.paused)
    {
        WEATHER_PRINT_DEBUG("already paused rain environment");
        return;
    }

    level notify("level_stop_rain_environment");
    level clientfield::set(DECAL_RAIN_TOGGLE, false);
    level clientfield::set(RAIN_EXPLODERS_CF_NAME, RAIN_INTENSITY_OFF);

    level.weather.rain.environment.paused = true;
}

function update()
{
    intensity = level.weather.rain.intensity;

    decal_enabled = (intensity != RAIN_INTENSITY_OFF);
    level clientfield::set(DECAL_RAIN_TOGGLE, decal_enabled);
    level clientfield::set(RAIN_EXPLODERS_CF_NAME, intensity);
}
