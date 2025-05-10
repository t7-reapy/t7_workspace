#using scripts\shared\callbacks_shared; 
#using scripts\shared\exploder_shared; 
#using scripts\shared\clientfield_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\weather\zm_weather_shared.gsh;
#insert scripts\zm\weather\zm_weather_rain.gsh;
#insert scripts\zm\weather\rain\zm_weather_rain_environment.gsh;

#namespace zm_weather_rain_environment;

class RainEnvironment {
    var volume_decals;
    var exploders;

    var sounds;
    var sounds_origins;
}

function init() 
{
    clientfield::register("world", DECAL_RAIN_TOGGLE, VERSION_SHIP, 1, "int", &decal_rain_toggle, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT);
    clientfield::register("world", RAIN_EXPLODERS_CF_NAME, VERSION_SHIP, 2, "int", &update_rain_pipes, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT);

    callback::on_localclient_connect(&on_connect);
}

function private on_connect(local_client_num)
{
    level.weather.rain.environment = new RainEnvironment();
    level.weather.rain.environment.volume_decals = FindVolumeDecalIndexArray(DECAL_RAIN_TARGETNAME);
    level.weather.rain.environment.exploders = RAIN_EXPLODERS_PIPE_DRAIN;
    level.weather.rain.environment.sounds = PIPE_DRAIN_SCRIPT_ORIGIN_SOUNDS;

    level.weather.rain.environment.sounds_origins = [];
    stript_origin_targets = PIPE_DRAIN_SCRIPT_ORIGIN_TARGETNAMES;
    for(i = 0; i < stript_origin_targets.size; i++)
    {
        level.weather.rain.environment.sounds_origins[i] = GetEntArray(local_client_num, stript_origin_targets[i], "targetname");
    }
}

function private decal_rain_toggle(_localClientNum, _oldVal, shouldRain, _bNewEnt, _bInitialSnap, _fieldName, _bWasTimeJump) // self == player
{
    volume_decals = level.weather.rain.environment.volume_decals;

    foreach (volume_decal in volume_decals)
    {
        if (isdefined(shouldRain) && shouldRain)
        {
            UnhideVolumeDecal(volume_decal);
        }
        else
        {
            HideVolumeDecal(volume_decal);
        }
    }
}

function private update_rain_pipes(local_client_num, old_intensity, new_intensity, _bNewEnt, _bInitialSnap, _fieldName, _bWasTimeJump) // self == player
{
    exploders = level.weather.rain.environment.exploders;
    if (new_intensity == WEATHER_INTENSITY_OFF)
    {
        self stop_rain_pipes_exploders(local_client_num, exploders);
        self stop_rain_pipes_sounds();
    }
    else
    {
        self play_rain_pipes_exploders(local_client_num, exploders, new_intensity);
        self play_rain_pipes_sounds(new_intensity);
    }
}

function private stop_rain_pipes_exploders(local_client_num, exploders) // self == player
{
    foreach (exploder in exploders)
    {
        exploder::stop_exploder(exploder, local_client_num);
    }
}

function private play_rain_pipes_exploders(local_client_num, exploders, intensity) // self == player
{
    exploder::exploder(exploders[intensity], local_client_num);
    exploder::stop_exploder(exploders[(intensity % WEATHER_INTENSITY_HIG) + 1], local_client_num);
    exploder::stop_exploder(exploders[((intensity + 1) % WEATHER_INTENSITY_HIG) + 1], local_client_num);
}

function private stop_rain_pipes_sounds() // self == player
{
    self thread stop_rain_pipes_sounds_for_given_intensity(WEATHER_INTENSITY_LOW);
    self thread stop_rain_pipes_sounds_for_given_intensity(WEATHER_INTENSITY_MED);
    self thread stop_rain_pipes_sounds_for_given_intensity(WEATHER_INTENSITY_HIG);
}

function private play_rain_pipes_sounds(intensity) // self == player
{
    self thread play_rain_pipes_sounds_for_given_intensity(intensity);
    self thread stop_rain_pipes_sounds_for_given_intensity((intensity % WEATHER_INTENSITY_HIG) + 1);
    self thread stop_rain_pipes_sounds_for_given_intensity(((intensity + 1) % WEATHER_INTENSITY_HIG) + 1);
}

function private stop_rain_pipes_sounds_for_given_intensity(intensity) // self == player
{
    self notify("stop_rain_pipes_sounds_for_given_intensity_" + intensity);
    self endon("stop_rain_pipes_sounds_for_given_intensity_" + intensity);
    self endon("play_rain_pipes_sounds_for_given_intensity_" + intensity);

    script_origins_to_stop = level.weather.rain.environment.sounds_origins[intensity];
    sound_alias = level.weather.rain.environment.sounds[intensity];

    foreach (script_origin in script_origins_to_stop)
    {
        SoundStopLoopEmitter(sound_alias, script_origin.origin);
    }
}

function private play_rain_pipes_sounds_for_given_intensity(intensity) // self == player
{
    self notify("play_rain_pipes_sounds_for_given_intensity_" + intensity);
    self endon("play_rain_pipes_sounds_for_given_intensity_" + intensity);
    self endon("stop_rain_pipes_sounds_for_given_intensity_" + intensity);

    script_origins_to_play = level.weather.rain.environment.sounds_origins[intensity];
    sound_alias = level.weather.rain.environment.sounds[intensity];

    foreach (script_origin in script_origins_to_play)
    {
        // Let's wait with random shifting in order to avoid 
        // having a weird effect with duplicated sounds at the same place...
        thread play_pipe_draining_sound_with_random_delay(sound_alias, script_origin.origin);
    }
}

function private play_pipe_draining_sound_with_random_delay(sound_alias, origin)
{
    wait RandomFloat(2.4);
    SoundLoopEmitter(sound_alias, origin);
}