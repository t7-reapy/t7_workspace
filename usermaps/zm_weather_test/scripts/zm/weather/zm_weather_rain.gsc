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
    level.weather.rain.intensity = RAIN_DEFAULT_INTENSITY;

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

    if (ENABLE_RAIN_ENVIRONMENT)
    {
        zm_weather_rain_environment::init();
    }
}

function run() 
{
    level endon("entityshutdown");
    level.weather.rain.intensity = RAIN_DEFAULT_INTENSITY;

    if (ENABLE_RAIN_AMBIENCE)
    {
        thread zm_weather_rain_ambience::run();
    }

    if (ENABLE_RAIN_DROPS_FX)
    {
        thread zm_weather_rain_drops_fx::run();
    }

    if (ENABLE_RAIN_DROPS_POSTFX)
    {
        thread zm_weather_rain_drops_postfx::run();
    }

    if (ENABLE_RAIN_ENVIRONMENT)
    {
        thread zm_weather_rain_environment::run();
    }
}

function pause()
{
    // Must turn off rain here in case of player spawn.
    level.weather.rain.intensity = RAIN_INTENSITY_DISABLE;

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
    if (level.weather.rain.intensity < RAIN_INTENSITY_HIG)
    {
        level.weather.rain.intensity++;
    }
}

function lesser_intensity()
{
    if (level.weather.rain.intensity > RAIN_INTENSITY_LOW)
    {
        level.weather.rain.intensity--;
    }
}
