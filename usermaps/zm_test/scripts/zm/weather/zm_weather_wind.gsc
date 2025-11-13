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

    var objects;
    var exploders;

    var min_wait;
    var max_wait;
}

function private default_wind_state()
{
    wind = new Wind();
    
    wind.paused = true;
    wind.intensity = WEATHER_INTENSITY_OFF;
    wind.objects = GetEntArray(WIND_SCRIPT_MODELS_TARGETNAME, "targetname");
    wind.exploders = WIND_EXPLODERS;
    wind.min_wait = WIND_MIN_WAIT[wind.intensity];
    wind.max_wait = WIND_MAX_WAIT[wind.intensity];

    return wind;
}

function init() {
    level.weather.wind = default_wind_state();

    thread watch_wind_blow_end();
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
    level.weather.wind.intensity = level.weather.intensity;
    level.weather.wind.min_wait = WIND_MIN_WAIT[level.weather.wind.intensity];
    level.weather.wind.max_wait = WIND_MAX_WAIT[level.weather.wind.intensity];

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

function pause_player_features()
{
    // No player specific features yet.
}

// This function is used to watch for the end of the wind blow, 
// It forces exploder to end, just to make sure it's not stuck,
// especially when notification is fired in middle of it.
function private watch_wind_blow_end() 
{
    while(true)
    {
        level waittill("wind_end_current_blow");
        wait 0.5; // We want to make sure exploders properly started before stopping them.

        // Force exploders to stop.
        foreach(exploder in level.weather.wind.exploders) 
        {
            exploder::exploder_stop(exploder);
        }
    }
}

function private wind_blow() // self == Wind (level.weather.wind)
{
    level endon("wind_end_current_blow");

    wait RandomFloatRange(self.min_wait, self.max_wait);

    foreach(exploder in self.exploders) 
    {
        // Note: wind SFX is included in the FX of the radiant exploder.
        exploder::exploder(exploder);
    }

    self thread toss_objects_around();
    wait WIND_EXPLODER_WAIT_TIME;

    foreach(exploder in self.exploders) 
    {
        exploder::exploder_stop(exploder);
    }
}

function private toss_objects_around() // self == Wind (level.weather.wind)
{
    // Generates a base random angle in degress
    wind_base_angle = RandomFloat(360);
    wind_min_force = WIND_VECTOR_MIN_FORCE;
    wind_force_vectorial = compute_wind_force(wind_base_angle, wind_min_force);

    WEATHER_PRINT_DEBUG("Wind force vectorial: " + wind_force_vectorial);
    foreach (object in self.objects)
    {
        wait WIND_DELAY_FOR_TOSSING_OBJECTS;
        object PhysicsLaunch(object.origin, wind_force_vectorial);
    }
}

function private compute_wind_force(wind_base_angle, wind_min_force)
{    
    // Wind direction and force shouldn't be homogeneous between object on the map
    // But it shouldn't be drastically different, even if objects are far from eachothers.
    wind_force = RandomFloatRange(wind_min_force / 2, wind_min_force * level.weather.wind.intensity);
    wind_force_x = wind_force * cos(wind_base_angle);
    wind_force_y = wind_force * sin(wind_base_angle);
    wind_force_z = 0.1; // Just a little bit to avoid objects being stuck on the ground.
    wind_force_vectorial = (wind_force_x, wind_force_y, wind_force_z);

    return wind_force_vectorial;
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
