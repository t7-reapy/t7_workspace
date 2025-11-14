#using scripts\shared\callbacks_shared; 
#using scripts\shared\array_shared; 
#using scripts\codescripts\struct; 
#using scripts\shared\clientfield_shared; 
#using scripts\shared\util_shared; 
#using scripts\shared\system_shared; 

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\room_of_thanks\zm_room_of_thanks.gsh;
#namespace zm_room_of_thanks;

REGISTER_SYSTEM("zm_room_of_thanks", &init, undefined)

function private init()
{
    clientfield::register("world", ROTSND_CLIENTFIELD, VERSION_SHIP, 1, "int", &stop_and_play_random_music, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);
    callback::on_localclient_connect(&on_connect);
    thread setup_sounds();
}

function private stop_and_play_random_music(n_client_num, _oldVal, n_new_val, _bNewEnt, _bInitialSnap, _fieldName, _bWasTimeJump)
{
    util::waitforclient(n_client_num);

    if (n_new_val)
    {
        if (is_sound_playing())
        {
            PlaySound(0, ROTSND_SWOOSH_SOUND, level.machine_struct.origin);
        }
        else
        {
            PlaySound(0, ROTSND_BOOT_SOUND, level.machine_struct.origin);
        }

        level.machine_struct notify(ROTSND_SOUND_PLAY_NOTIFY);
    }
}

// Inspired from audio_shared.csc:startSoundLoops()
function private setup_sounds()
{
    level.sound_structs = struct::get_array(ROTSND_STRUCT_TARGETNAME);
    level.machine_struct = struct::get(ROTSND_MACHINE_STRUCT_TARGETNAME);
}

function private on_connect(n_client_num)
{
    if (!IsSplitScreen() || IsSplitScreenHost(n_client_num))
    {
        if(!isdefined(level.sound_structs) || level.sound_structs.size <= 0)
        {
            return;
        }

        level.rot_sound_zone_trigger = GetEnt(n_client_num, ROTSND_TRIGGER_ZONE_TARGETNAME, "targetname");

        foreach(struct in level.sound_structs)
        {
            struct.playing_sound = undefined;
        }

        thread sound_structs_think(n_client_num);
    }
}

function private sound_structs_think(n_client_num)
{
    level endon("disconnect");

    sounds = ROTSND_SOUNDS;
    trigger = level.rot_sound_zone_trigger;
    index = 0;
    while(true)
    {
        level.machine_struct waittill(ROTSND_SOUND_PLAY_NOTIFY);

        if (is_sound_playing())
        {
            stop_sounds();
            waitrealtime(ROTSND_SOUND_TRIGGER_DELAY);
        }
        else
        {
            waitrealtime(ROTSND_SOUND_TRIGGER_INIT_DELAY);
        }

        if (!trigger one_local_player_touches_trigger())
        {
            continue;
        }

        sound = sounds[index % sounds.size];
        play_sounds(sound);
        trigger thread watch_for_local_players_exit();
        index++;
    }
}

function private is_sound_playing()
{
    sound_playing = false;
    foreach (struct in level.sound_structs)
    {
        sound_playing = isdefined(struct.playing_sound) && SoundPlaying(struct.playing_sound);
    }
    return sound_playing;
}

function private play_sounds(sound_alias)
{
    foreach (struct in level.sound_structs)
    {
        struct.playing_sound = PlaySound(0, sound_alias, struct.origin);
        thread delayed_sound_safe_stop(struct.playing_sound);
    }
}

function private delayed_sound_safe_stop(soundtrack_id)
{
    // Sometime a sound keep playing, I don't know how...
    level.machine_struct util::waittill_any(ROTSND_SOUND_PLAY_NOTIFY, ROTSND_SOUND_STOP_NOTIFY);
    StopSound(soundtrack_id);
}

function private stop_sounds()
{
    level.machine_struct notify(ROTSND_SOUND_STOP_NOTIFY);
}

function private one_local_player_touches_trigger() // self == trigger
{
    foreach (player in GetLocalPlayers())
    {
        if (player IsTouching(self))
        {
            return true;
        }
    }
    return false;
}

function private watch_for_local_players_exit() // self == trigger
{
    level endon("disconnect");
    level.machine_struct endon(ROTSND_SOUND_PLAY_NOTIFY);
    trigger = self;

    while(true)
    {
        WAIT_CLIENT_FRAME;
        trigger waittill("trigger", who);

        if (!who IsLocalPlayer())
        {
            continue;
        }

        while (trigger one_local_player_touches_trigger())
        {
            wait 1;
        }

        if (is_sound_playing())
        {
            stop_sounds();
        }
    }
}
