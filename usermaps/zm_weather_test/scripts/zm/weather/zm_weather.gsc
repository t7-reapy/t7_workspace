#using scripts\shared\flag_shared; 
#insert scripts\shared\shared.gsh;
#insert scripts\zm\weather\zm_weather_shared.gsh;

// Weather features
#using scripts\zm\weather\zm_weather_lightning;
#using scripts\zm\weather\zm_weather_rain;
#using scripts\zm\weather\zm_weather_thunder;
#using scripts\zm\weather\zm_weather_wind;

#insert scripts\zm\weather\zm_weather.gsh;
#namespace zm_weather;

function autoexec private end_game_watcher()
{
    level waittill("end_game");

    clear_weather_flags();
    level notify(KILL_LIGHTNING_NOTIFICATION);
    level notify(KILL_RAIN_NOTIFICATION);
    level notify(KILL_THUNDER_NOTIFICATION);
    level notify(KILL_WIND_NOTIFICATION);
}

class Weather{
    var currently_running;

    var lightning;
    var rain;
    var thunder;
    var wind;
}

function init() 
{
    level.weather = new Weather();
    level.weather.currently_running = false;
    
    level flag::init(ACTIVE_LIGHTNING_FLAG);
    level flag::init(ACTIVE_RAIN_FLAG);
    level flag::init(ACTIVE_THUNDER_FLAG);
    level flag::init(ACTIVE_WIND_FLAG);

    if (ENABLE_LIGHTNING)
    {
        zm_weather_lightning::init();
        WEATHER_LIGHTNING_ASSERT_INIT;
    }

    if (ENABLE_RAIN)
    {
        zm_weather_rain::init();
        WEATHER_RAIN_ASSERT_INIT;
    }

    if (ENABLE_THUNDER)
    {
        zm_weather_thunder::init();
        WEATHER_THUNDER_ASSERT_INIT;
    }

    if (ENABLE_WIND)
    {
        zm_weather_wind::init();
        WEATHER_WIND_ASSERT_INIT;
    }
}

function private set_weather_flags()
{
    WEATHER_PRINT_DEBUG("Weather flags set");
    level flag::set(ACTIVE_LIGHTNING_FLAG);
    level flag::set(ACTIVE_RAIN_FLAG);
    level flag::set(ACTIVE_THUNDER_FLAG);
    level flag::set(ACTIVE_WIND_FLAG);
}

function private clear_weather_flags()
{
    WEATHER_PRINT_DEBUG("Weather flags cleared");
    level flag::clear(ACTIVE_LIGHTNING_FLAG);
    level flag::clear(ACTIVE_RAIN_FLAG);
    level flag::clear(ACTIVE_THUNDER_FLAG);
    level flag::clear(ACTIVE_WIND_FLAG);
}

function play_weather()
{
    WEATHER_ASSERT_INIT;
    Assert(!level.weather.currently_running, "weather already running");

    set_weather_flags();
    thread do_lightning();
    thread do_rain();
    thread do_thunder();
    thread do_wind();
    thread meteo_manager();

    level.weather.currently_running = true;
    WEATHER_PRINT_DEBUG("WEATHER PLAYS");
}

function pause_weather()
{
    WEATHER_ASSERT_INIT;
    Assert(level.weather.currently_running, "weather not running");

    clear_weather_flags();
    level notify(KILL_WEATHER_METEO_MANAGER);

    level.weather.currently_running = false;
    WEATHER_PRINT_DEBUG("WEATHER PAUSED");
}

function private do_lightning()
{
    if (!ENABLE_LIGHTNING)
        return;

    thread zm_weather_lightning::run();
}

function private do_rain()
{
    if (!ENABLE_RAIN)
        return;

    thread zm_weather_rain::run();
}

function private do_thunder()
{
    if (!ENABLE_THUNDER)
        return;

    thread zm_weather_thunder::run();
}

function private do_wind()
{
    if (!ENABLE_WIND)
        return;

    thread zm_weather_wind::run();
}

function private meteo_manager()
{
    level endon(KILL_WEATHER_METEO_MANAGER);

    while(true)
    {
        // TODO: remove
        WEATHER_PRINT_DEBUG("meteo manager heart beat");
        wait 1;

        //TODO: increase frequency/intensity of weather, lower them, etc.
        WAIT_SERVER_FRAME;
    }
}