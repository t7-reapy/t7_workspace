#using scripts\zm\weather\rain\zm_weather_rain_ambience;
#using scripts\zm\weather\rain\zm_weather_rain_drops_fx;
#using scripts\zm\weather\rain\zm_weather_rain_drops_postfx;
#using scripts\zm\weather\rain\zm_weather_rain_environment;

#insert scripts\zm\weather\zm_weather_shared.gsh;
#insert scripts\zm\weather\zm_weather_rain.gsh;

#namespace zm_weather_rain;

class Rain {
    var intensity;

    var ambience;
    var drops_fx;
    var drops_postfx;
    var environment;
}

function init() 
{
    level.weather.rain = new Rain();
    level.weather.rain.intensity = RAIN_INTENSITY_OFF;

    if (ENABLE_RAIN_AMBIENCE)
    {
        zm_weather_rain_ambience::init();
    }

    if (ENABLE_RAIN_DROPS_FX)
    {
        zm_weather_rain_drops_fx::init();
    }

    if (ENABLE_RAIN_DROPS_POSTFX)
    {
        zm_weather_rain_drops_postfx::init();
    }

    // We don't check for ENABLE_RAIN_ENVIRONMENT here because we certainly want to 
    // hide present volume decals in the map if ENABLE_RAIN_ENVIRONMENT is turned off.
    // Thus, GSC needs to initiate some clientfields.
    zm_weather_rain_environment::init();
}

function play() 
{
    level endon("entityshutdown");
    level.weather.rain.intensity = RAIN_DEFAULT_INTENSITY;

    if (ENABLE_RAIN_AMBIENCE)
    {
        thread zm_weather_rain_ambience::play();
    }

    if (ENABLE_RAIN_DROPS_FX)
    {
        thread zm_weather_rain_drops_fx::play();
    }

    if (ENABLE_RAIN_DROPS_POSTFX)
    {
        thread zm_weather_rain_drops_postfx::play();
    }

    if (ENABLE_RAIN_ENVIRONMENT)
    {
        thread zm_weather_rain_environment::play();
    }
}

function pause()
{
    // Must turn off rain here in case of player spawn.
    level.weather.rain.intensity = RAIN_INTENSITY_OFF;

    if (ENABLE_RAIN_AMBIENCE)
    {
        thread zm_weather_rain_ambience::pause();
    }

    if (ENABLE_RAIN_DROPS_FX)
    {
        thread zm_weather_rain_drops_fx::pause();
    }

    if (ENABLE_RAIN_DROPS_POSTFX)
    {
        thread zm_weather_rain_drops_postfx::pause();
    }

    if (ENABLE_RAIN_ENVIRONMENT)
    {
        thread zm_weather_rain_environment::pause();
    }
}

function greater_intensity()
{
    if (level.weather.rain.intensity < RAIN_INTENSITY_HIG
        && level.weather.rain.intensity != RAIN_INTENSITY_OFF)
    {
        level.weather.rain.intensity++;
    }
}

function lesser_intensity()
{
    if (level.weather.rain.intensity > RAIN_INTENSITY_LOW
        && level.weather.rain.intensity != RAIN_INTENSITY_OFF)
    {
        level.weather.rain.intensity--;
    }
}
