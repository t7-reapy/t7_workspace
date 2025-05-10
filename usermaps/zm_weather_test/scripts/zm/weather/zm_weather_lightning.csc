#using scripts\shared\exploder_shared; 
#using scripts\shared\callbacks_shared; 
#using scripts\shared\clientfield_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\weather\zm_weather_shared.gsh;
#insert scripts\zm\weather\zm_weather_lightning.gsh;

#namespace zm_weather_lightning;

class Lightning {
    var distance;
    var sounds;
    var exploders;
}

function init() 
{
    clientfield::register("world", LIGHTNING_EXPLODER_CF_NAME, VERSION_SHIP, 2, "int", &lightning_explodes, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);

    callback::on_localclient_connect(&on_connect);
}

function private on_connect(local_client_number) // self == player
{
    level.weather.lightning = new Lightning();
    level.weather.lightning.distance = LIGHTNING_SOUND_DISTANCE;
    level.weather.lightning.sounds = LIGHTNING_SOUNDS;
    level.weather.lightning.exploders = LIGHTNING_EXPLODERS;
}

function private lightning_explodes(local_client_number, old_intensity, new_intensity, b_new_ent, b_initial_snap, s_field_name, b_was_time_jump) // self == world
{
    if(isdefined(new_intensity) && new_intensity != WEATHER_INTENSITY_OFF)
    {
        player = GetLocalPlayer(local_client_number);
        player thread lightning_exploders_play(new_intensity);
    }
}

function private lightning_exploders_play(intensity) // self == player
{
    if (intensity == WEATHER_INTENSITY_OFF)
    {
        return;
    }

    lightning = level.weather.lightning;
    lightning_sound = lightning.sounds[intensity];
    lightning_exploder = lightning.exploders[RandomIntRange(0, lightning.exploders.size)];

    self thread play_and_stop_exploder(lightning_exploder);
    self thread play_lightning_sound(lightning_sound, lightning.distance[intensity]);
}

function private play_and_stop_exploder(exploder_alias) // self == player
{
    // We don't use local_client_number because we want the 
    // exploder to be applied to all local players at the same time.
    exploder::exploder(exploder_alias);
    wait LIGHTNING_EXPLODERS_TIME;
    exploder::stop_exploder(exploder_alias);
}

function private play_lightning_sound(sound_alias, delay) // self == player
{
    // Strike is distant, so the sound takes time to come to player's ears
    wait RandomFloatRange(delay - 1, delay + 1);
    self PlaySound(self GetLocalClientNumber(), sound_alias);
}