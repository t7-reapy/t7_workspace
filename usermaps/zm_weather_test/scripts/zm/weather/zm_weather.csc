#using scripts\shared\util_shared; 
#using scripts\shared\flag_shared; 
#using scripts\shared\system_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\zm\weather\zm_weather_shared.gsh;

// Weather features
#using scripts\zm\weather\zm_weather_lightning;
#using scripts\zm\weather\zm_weather_rain;
#using scripts\zm\weather\zm_weather_thunder;
#using scripts\zm\weather\zm_weather_wind;

#insert scripts\zm\weather\zm_weather.gsh;
#namespace zm_weather;

REGISTER_SYSTEM_EX("zm_weather", &init, &main, undefined)


class Weather{
    var lightning;
    var rain;
    var thunder;
    var wind;
}

function init()
{
    level.weather = new Weather();

    if (ENABLE_LIGHTNING)
    {
        self zm_weather_lightning::init();
    }

    if (ENABLE_RAIN)
    {
        self zm_weather_rain::init();
    }

    if (ENABLE_THUNDER)
    {
        self zm_weather_thunder::init();
    }

    if (ENABLE_WIND)
    {
        self zm_weather_wind::init();
    }
}

function main()
{
    util::waitforallclients();

    if (ENABLE_LIGHTNING)
    {
        self thread zm_weather_lightning::run();
    }

    if (ENABLE_RAIN)
    {
        self thread zm_weather_rain::run();
    }

    if (ENABLE_THUNDER)
    {
        self thread zm_weather_thunder::run();
    }

    if (ENABLE_WIND)
    {
        self thread zm_weather_wind::run();
    }
}
