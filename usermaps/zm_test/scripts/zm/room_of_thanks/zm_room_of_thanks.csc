#using scripts\shared\array_shared; 
#using scripts\codescripts\struct; 
#using scripts\shared\clientfield_shared; 
#using scripts\shared\util_shared; 
#using scripts\shared\system_shared; 

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\room_of_thanks\zm_room_of_thanks_elevator;

#insert scripts\zm\room_of_thanks\zm_room_of_thanks.gsh;
#namespace zm_room_of_thanks;

REGISTER_SYSTEM("zm_room_of_thanks", &init, undefined)

function private init()
{
    clientfield::register("world", ROTSND_CLIENTFIELD, VERSION_SHIP, 1, "int", &stop_and_play_random_music, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);
    
    thread setup_sounds();
}

function private stop_and_play_random_music(n_client_num, _oldVal, n_new_val, _bNewEnt, _bInitialSnap, _fieldName, _bWasTimeJump)
{
    util::waitforclient(n_client_num);

    if (n_new_val)
    {
        if (level.machine_struct.sound_is_playing)
        {
            PlaySound(0, ROTSND_SWOOSH_SOUND, level.machine_struct.origin);
        }
        else
        {
            PlaySound(0, ROTSND_BOOT_SOUND, level.machine_struct.origin);
        }

        foreach(struct in level.sound_structs)
        {
            struct notify(ROTSND_SOUND_NOTIFY);
            WAIT_CLIENT_FRAME;
        }

        level.machine_struct.sound_is_playing = true;
    }
}

// Inspired from audio_shared.csc:startSoundLoops()
function private setup_sounds()
{
    level.sound_structs = struct::get_array(ROTSND_STRUCT_TARGETNAME);
    level.machine_struct = struct::get(ROTSND_MACHINE_STRUCT_TARGETNAME);
    level.machine_struct.sound_is_playing = false;
    
    if(!isdefined(level.sound_structs) || level.sound_structs.size <= 0)
    {
        return;
    }

    foreach(struct in level.sound_structs)
    {
        struct thread sound_struct_think();
        WAIT_CLIENT_FRAME;
    }
}

function sound_struct_think() // self == struct
{
    sounds = ROTSND_SOUNDS;
    index = 0;
    while(true)
    {
        self waittill(ROTSND_SOUND_NOTIFY);

        if (isdefined(self.playing_sound))
        {
            StopSound(self.playing_sound);
            waitrealtime(ROTSND_SOUND_TRIGGER_DELAY);
        }
        else
        {
            waitrealtime(3.5);
        }

        sound = sounds[index % sounds.size];
        self.playing_sound = PlaySound(0, sound, self.origin);
        index++;
    }
}