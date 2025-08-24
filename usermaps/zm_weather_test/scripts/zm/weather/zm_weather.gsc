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

REGISTER_SYSTEM("zm_weather", &init, undefined)

class Weather{
    var intensity;

    var lightning;
    var rain;
    var thunder;
    var wind;
}

function private init() 
{
    level.weather = new Weather();
    level.weather.intensity = undefined;

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

function play()
{
    level.weather.intensity = RandomInt(WEATHER_INTENSITY_HIG) + 1;
    
    if (ENABLE_LIGHTNING)
        thread zm_weather_lightning::play();
    if (ENABLE_RAIN)
        thread zm_weather_rain::play();
    if (ENABLE_THUNDER)
        thread zm_weather_thunder::play();
    if (ENABLE_WIND)
        thread zm_weather_wind::play();

    thread meteo_manager();
}

function private meteo_manager()
{
    level notify("kill_meteo_manager");
    level endon("kill_meteo_manager");
    WEATHER_PRINT_DEBUG("Weather meteo manager playing");

    while(true)
    {
        wait RandomFloatRange(STATE_SWITCHING_EVALUATION_MIN_WAIT, STATE_SWITCHING_EVALUATION_MAX_WAIT);

        switch_state_p = RandomInt(100);
        if (switch_state_p < STATE_SWITCHING_PROBABILITY)
        {
            thread switch_state();
        }
    }
}

function private switch_state()
{
    switch (level.weather.intensity)
    {
        case WEATHER_INTENSITY_LOW:
            greater_intensity();
            // There is a chance of drastic transition
            if (RandomInt(100) < STATE_SWITCHING_DRASTIC_PROBABILITY)
                greater_intensity();
            break;
        case WEATHER_INTENSITY_HIG:
            lesser_intensity();
            // There is a chance of drastic transition
            if (RandomInt(100) < STATE_SWITCHING_DRASTIC_PROBABILITY)
                lesser_intensity();
            break;
        case WEATHER_INTENSITY_MED:
            if (RandomInt(2)) // fifty fifty
                greater_intensity();
            else
                lesser_intensity();
            break;
        default:
            WEATHER_PRINT_DEBUG("Weather intensity not managed at intensity: " + level.weather.intensity);
            break;
    }
}

function pause()
{
    if (ENABLE_LIGHTNING)
        thread zm_weather_lightning::pause();
    if (ENABLE_RAIN)
        thread zm_weather_rain::pause();
    if (ENABLE_THUNDER)
        thread zm_weather_thunder::pause();
    if (ENABLE_WIND)
        thread zm_weather_wind::pause();

    level notify("kill_meteo_manager");
}

function greater_intensity() 
{
    if (level.weather.intensity >= WEATHER_INTENSITY_HIG)
    {
        WEATHER_PRINT_DEBUG("Weather intensity already at max");
        return;
    }
    WEATHER_PRINT_DEBUG("Weather intensity +");
    level.weather.intensity++;

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
    if (level.weather.intensity <= WEATHER_INTENSITY_LOW)
    {
        WEATHER_PRINT_DEBUG("Weather intensity already at min");
        return;
    }
    WEATHER_PRINT_DEBUG("Weather intensity -");
    level.weather.intensity--;

    if (ENABLE_LIGHTNING)
        zm_weather_lightning::lesser_intensity();

    if (ENABLE_RAIN)
        zm_weather_rain::lesser_intensity();

    if (ENABLE_THUNDER)
        zm_weather_thunder::lesser_intensity();

    if (ENABLE_WIND)
        zm_weather_wind::lesser_intensity();
}

function update_default_lightstate()
{
    zm_weather_thunder::update_default_lightstate();
}
