#using scripts\zm\weather\rain\zm_weather_rain_ambience;
#using scripts\zm\weather\rain\zm_weather_rain_drops_fx;
#using scripts\zm\weather\rain\zm_weather_rain_drops_postfx;
#using scripts\zm\weather\rain\zm_weather_rain_environment;

#insert scripts\zm\weather\zm_weather_shared.gsh;
#insert scripts\zm\weather\zm_weather_rain.gsh;

#namespace zm_weather_rain;

class Rain {
    var ambience;
    var drops_fx;
    var drops_postfx;
    var environment;
}

function init()
{
    level.weather.rain = new Rain();

    if (ENABLE_RAIN_AMBIENCE)
    {
        self zm_weather_rain_ambience::init();
    }

    if (ENABLE_RAIN_DROPS_FX)
    {
        self zm_weather_rain_drops_fx::init();
    }

    if (ENABLE_RAIN_DROPS_POSTFX)
    {
        self zm_weather_rain_drops_postfx::init();
    }

    if (ENABLE_RAIN_ENVIRONMENT)
    {
        self zm_weather_rain_environment::init();
    }
}

function run()
{
    if (ENABLE_RAIN_AMBIENCE)
    {
        self thread zm_weather_rain_ambience::run();
    }

    if (ENABLE_RAIN_DROPS_FX)
    {
        self thread zm_weather_rain_drops_fx::run();
    }

    if (ENABLE_RAIN_DROPS_POSTFX)
    {
        self thread zm_weather_rain_drops_postfx::run();
    }

    if (ENABLE_RAIN_ENVIRONMENT)
    {
        self thread zm_weather_rain_environment::run();
    }
}