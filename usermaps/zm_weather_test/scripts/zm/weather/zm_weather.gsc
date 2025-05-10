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

#define ACTIVE_LIGHTNING_FLAG "active_lightning_flag"
#define ACTIVE_RAIN_FLAG "active_rain_flag"
#define ACTIVE_THUNDER_FLAG "active_thunder_flag"
#define ACTIVE_WIND_FLAG "active_wind_flag"

#namespace zm_weather;

REGISTER_SYSTEM_EX("zm_weather", &init, &main, undefined)

// TODO: use these flags for endgame ? maybe for restart
// #define KILL_WEATHER_METEO_MANAGER "kill_weather_meteo_manager"
// #define KILL_LIGHTNING_NOTIFICATION "kill_lightning_notification"
// #define KILL_RAIN_NOTIFICATION "kill_rain_notification"
// #define KILL_THUNDER_NOTIFICATION "kill_thunder_notification"
// #define KILL_WIND_NOTIFICATION "kill_wind_notification"
// function autoexec private end_game_watcher()
// {
//     level waittill("end_game");
//     clear_weather_flags();
//     level notify(KILL_LIGHTNING_NOTIFICATION);
//     level notify(KILL_RAIN_NOTIFICATION);
//     level notify(KILL_THUNDER_NOTIFICATION);
//     level notify(KILL_WIND_NOTIFICATION);
// }
class Weather{
    var lightning;
    var rain;
    var thunder;
    var wind;
}

function init() 
{
    level.weather = new Weather();
    
    level flag::init(ACTIVE_LIGHTNING_FLAG);
    level flag::init(ACTIVE_RAIN_FLAG);
    level flag::init(ACTIVE_THUNDER_FLAG);
    level flag::init(ACTIVE_WIND_FLAG);

    if (ENABLE_LIGHTNING)
    {
        zm_weather_lightning::init();
    }

    if (ENABLE_RAIN)
    {
        zm_weather_rain::init();
    }

    if (ENABLE_THUNDER)
    {
        zm_weather_thunder::init();
    }

    if (ENABLE_WIND)
    {
        zm_weather_wind::init();
    }
}

function main()
{
    thread do_lightning();
    thread do_rain();
    thread do_thunder();
    thread do_wind();

    thread meteo_manager();
}

function pause()
{
    clear_weather_flags();
}

function play()
{
    set_weather_flags();
}

function private set_weather_flags()
{
    level flag::set(ACTIVE_LIGHTNING_FLAG);
    level flag::set(ACTIVE_RAIN_FLAG);
    level flag::set(ACTIVE_THUNDER_FLAG);
    level flag::set(ACTIVE_WIND_FLAG);
}

function private clear_weather_flags()
{
    level flag::clear(ACTIVE_LIGHTNING_FLAG);
    level flag::clear(ACTIVE_RAIN_FLAG);
    level flag::clear(ACTIVE_THUNDER_FLAG);
    level flag::clear(ACTIVE_WIND_FLAG);
}

function private do_lightning()
{
    if (!ENABLE_LIGHTNING)
        return;

    while(true)
    {
        level flag::wait_till(ACTIVE_LIGHTNING_FLAG);
        thread zm_weather_lightning::play();

        level flag::wait_till_clear(ACTIVE_LIGHTNING_FLAG);
        thread zm_weather_lightning::pause();
    }
}

function private do_rain()
{
    if (!ENABLE_RAIN)
        return;
        
    while(true)
    {
        level flag::wait_till(ACTIVE_RAIN_FLAG);
        thread zm_weather_rain::play();

        level flag::wait_till_clear(ACTIVE_RAIN_FLAG);
        thread zm_weather_rain::pause();
    }
}

function private do_thunder()
{
    if (!ENABLE_THUNDER)
        return;

    while(true)
    {
        level flag::wait_till(ACTIVE_THUNDER_FLAG);
        thread zm_weather_thunder::play();
     
        level flag::wait_till_clear(ACTIVE_THUNDER_FLAG);
        thread zm_weather_thunder::pause();
    }
}

function private do_wind()
{
    if (!ENABLE_WIND)
        return;

    while(true)
    {
        level flag::wait_till(ACTIVE_WIND_FLAG);
        thread zm_weather_wind::play();

        level flag::wait_till_clear(ACTIVE_WIND_FLAG);
        thread zm_weather_wind::pause();
    }
}

function private meteo_manager()
{
    //level endon(KILL_WEATHER_METEO_MANAGER);

    while(true)
    {
        // TODO: remove
        //WEATHER_PRINT_DEBUG("meteo manager heart beat");
        wait 1;

        //TODO: increase frequency/intensity of weather, lower them, etc.
        WAIT_SERVER_FRAME;
    }
}

function greater_intensity() 
{
    WEATHER_PRINT_DEBUG("Weather intensity +");

    if (ENABLE_LIGHTNING)
        zm_weather_lightning::greater_intensity();

    if (ENABLE_RAIN)
        zm_weather_rain::greater_intensity();

    if (ENABLE_THUNDER)
        zm_weather_thunder::greater_intensity();

    if (ENABLE_WIND)
        zm_weather_wind::greater_intensity();
}

function lesser_intensity() 
{
    WEATHER_PRINT_DEBUG("Weather intensity -");

    if (ENABLE_LIGHTNING)
        zm_weather_lightning::lesser_intensity();

    if (ENABLE_RAIN)
        zm_weather_rain::lesser_intensity();

    if (ENABLE_THUNDER)
        zm_weather_thunder::lesser_intensity();

    if (ENABLE_WIND)
        zm_weather_wind::lesser_intensity();
}