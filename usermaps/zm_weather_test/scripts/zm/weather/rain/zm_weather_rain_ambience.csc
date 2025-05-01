#using scripts\shared\callbacks_shared; 
#using scripts\shared\clientfield_shared; 

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\weather\zm_weather_shared.gsh;
#insert scripts\zm\weather\zm_weather_rain.gsh;
#insert scripts\zm\weather\rain\zm_weather_rain_ambience.gsh;

#namespace zm_weather_rain_ambience;

#define RAIN_INTERIOR_STOP_NOTIFY "rain_interior_sound_stop"
#define RAIN_LIMINAL_STOP_NOTIFY "rain_liminal_sound_stop"
#define RAIN_EXTERIOR_STOP_NOTIFY "rain_exterior_sound_stop"

class RainAmbience {
    var interior_sounds;
    var liminal_sounds;
    var exterior_sounds;

    var mutex_sound;
    var interior_sound_playing;
    var liminal_sound_playing;
    var exterior_sound_playing;
}

function init()
{
    clientfield::register("toplayer", RAIN_INTERIOR_TYPE_SFX, VERSION_SHIP, 2, "int", &rain_interior_sound, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);
    clientfield::register("toplayer", RAIN_LIMINAL_TYPE_SFX, VERSION_SHIP, 2, "int", &rain_liminal_sound, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);
    clientfield::register("toplayer", RAIN_EXTERIOR_TYPE_SFX, VERSION_SHIP, 2, "int", &rain_exterior_sound, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);

    level.weather.rain.ambience = new RainAmbience();
    level.weather.rain.ambience.interior_sounds = RAIN_INTERIOR_SOUNDS;
    level.weather.rain.ambience.liminal_sounds = RAIN_LIMINAL_SOUNDS;
    level.weather.rain.ambience.exterior_sounds = RAIN_EXTERIOR_SOUNDS;

    level.weather.rain.ambience.mutex_sound = 1;
    level.weather.rain.ambience.interior_sound_playing = undefined;
    level.weather.rain.ambience.liminal_sound_playing = undefined;
    level.weather.rain.ambience.exterior_sound_playing = undefined;

    callback::on_localclient_connect(&on_connect);
}

function run()
{
}

function on_connect(local_client_number)
{
    level.weather.rain.ambience.mutex_sound = 1;
    level.weather.rain.ambience.interior_sound_playing = undefined;
    level.weather.rain.ambience.liminal_sound_playing = undefined;
    level.weather.rain.ambience.exterior_sound_playing = undefined;
}

function acquireMutex()
{
    while(isdefined(level.weather.rain.ambience.mutex_sound) && !level.weather.rain.ambience.mutex_sound)
    {
        // Clientfield callbacks are made by server, that's the maximum time 
        // we should wait for next callback. And thus, next check.
        WAIT_SERVER_FRAME;
    }
    level.weather.rain.ambience.mutex_sound = 0;
}

function releaseMutex()
{
    level.weather.rain.ambience.mutex_sound = 1;
}

/* region interior: begin */

function rain_interior_sound(local_client_number, old_intensity, new_intensity, b_new_ent, b_initial_snap, s_field_name, b_was_time_jump)
{
    if(isdefined(new_intensity) && new_intensity != RAIN_INTENSITY_DISABLE)
    {
        self thread rain_interior_sound_play(level.weather.rain.ambience.interior_sounds[new_intensity]);
    }
    else
    {
        self thread rain_interior_sound_stop(level.weather.rain.ambience.interior_sounds[old_intensity]);
    }
}

function rain_interior_sound_play(sound_alias)
{
    self endon("entityshutdown");

    if (isdefined(level.weather.rain.ambience.liminal_sound_playing))
    {
        self waittill(RAIN_LIMINAL_STOP_NOTIFY);
    }

    if (isdefined(level.weather.rain.ambience.exterior_sound_playing))
    {
        self waittill(RAIN_EXTERIOR_STOP_NOTIFY);
    }
    
    acquireMutex();
    level.weather.rain.ambience.interior_sound_playing = self PlayLoopSound(sound_alias, SOUND_TIME_FADE);
    releaseMutex();
}

function rain_interior_sound_stop(sound_alias)
{
    self endon("entityshutdown");

    if (!isdefined(level.weather.rain.ambience.interior_sound_playing))
    {
        return;
    }

    acquireMutex();
    self StopLoopSound(level.weather.rain.ambience.interior_sound_playing, SOUND_TIME_FADE);
    level.weather.rain.ambience.interior_sound_playing = undefined;
    self notify(RAIN_INTERIOR_STOP_NOTIFY);
    releaseMutex();
}

/* region interior: end */
/* region liminal: begin */

function rain_liminal_sound(local_client_number, old_intensity, new_intensity, b_new_ent, b_initial_snap, s_field_name, b_was_time_jump)
{
    if(isdefined(new_intensity) && new_intensity != RAIN_INTENSITY_DISABLE)
    {
        self thread rain_liminal_sound_play(level.weather.rain.ambience.liminal_sounds[new_intensity]);
    }
    else
    {
        self thread rain_liminal_sound_stop(level.weather.rain.ambience.interior_sounds[old_intensity]);
    }
}

function rain_liminal_sound_play( sound_alias)
{
    self endon("entityshutdown");

    if (isdefined(level.weather.rain.ambience.interior_sound_playing))
    {
        self waittill(RAIN_INTERIOR_STOP_NOTIFY);
    }

    if (isdefined(level.weather.rain.ambience.exterior_sound_playing))
    {
        self waittill(RAIN_EXTERIOR_STOP_NOTIFY);
    }
    
    acquireMutex();
    level.weather.rain.ambience.liminal_sound_playing = self PlayLoopSound(sound_alias, SOUND_TIME_FADE);
    releaseMutex();
}

function rain_liminal_sound_stop(sound_alias)
{
    self endon("entityshutdown");

    if (!isdefined(level.weather.rain.ambience.liminal_sound_playing))
    {
        return;
    }
    
    acquireMutex();
    self StopLoopSound(level.weather.rain.ambience.liminal_sound_playing, SOUND_TIME_FADE);
    level.weather.rain.ambience.liminal_sound_playing = undefined;
    self notify(RAIN_LIMINAL_STOP_NOTIFY);
    releaseMutex();
}

/* region liminal: end */
/* region exterior: begin */

function rain_exterior_sound(local_client_number, old_intensity, new_intensity, b_new_ent, b_initial_snap, s_field_name, b_was_time_jump)
{
    if(isdefined(new_intensity) && new_intensity != RAIN_INTENSITY_DISABLE)
    {
        self thread rain_exterior_sound_play(level.weather.rain.ambience.exterior_sounds[new_intensity]);
    }
    else
    {
        self thread rain_exterior_sound_stop(level.weather.rain.ambience.exterior_sounds[old_intensity]);
    }
}

function rain_exterior_sound_play(sound_alias)
{
    self endon("entityshutdown");

    if (isdefined(level.weather.rain.ambience.interior_sound_playing))
    {
        self waittill(RAIN_INTERIOR_STOP_NOTIFY);
    }

    if (isdefined(level.weather.rain.ambience.liminal_sound_playing))
    {
        self waittill(RAIN_LIMINAL_STOP_NOTIFY);
    }
    
    acquireMutex();
    level.weather.rain.ambience.exterior_sound_playing = self PlayLoopSound(sound_alias, SOUND_TIME_FADE);
    releaseMutex();
}

function rain_exterior_sound_stop(sound_alias)
{
    self endon("entityshutdown");

    if (!isdefined(level.weather.rain.ambience.exterior_sound_playing))
    {
        return;
    }
    
    acquireMutex();
    self StopLoopSound(level.weather.rain.ambience.exterior_sound_playing, SOUND_TIME_FADE);
    level.weather.rain.ambience.exterior_sound_playing = undefined;
    self notify(RAIN_EXTERIOR_STOP_NOTIFY);
    releaseMutex();
}

/* region exterior: end */