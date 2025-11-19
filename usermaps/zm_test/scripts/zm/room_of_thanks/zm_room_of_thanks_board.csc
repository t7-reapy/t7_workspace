

#using scripts\shared\callbacks_shared; 
#using scripts\shared\array_shared; 
#using scripts\codescripts\struct; 
#using scripts\shared\clientfield_shared; 
#using scripts\shared\util_shared; 
#using scripts\shared\system_shared; 

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\room_of_thanks\zm_room_of_thanks_board.gsh;
#namespace zm_room_of_thanks_board;

REGISTER_SYSTEM("zm_room_of_thanks_board", &init, undefined)

function private init()
{
    clientfield::register("world", CLIENTFIELD_BOARDS_SOUND_AND_SUBTITLE, VERSION_SHIP, 1, "int", &play_video_audio, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);

    level.thanks_board_sound_struct = struct::get(VIDEO_SOUND_STRUCT);
    level.thanks_board_sound_struct.soundtrack_id = undefined;
}

function private play_video_audio(n_client_num, _oldVal, n_new_val, _bNewEnt, _bInitialSnap, _fieldName, _bWasTimeJump)
{
    util::waitforclient(n_client_num);

    if (IS_TRUE(n_new_val))
    {
        if(!isdefined(level.thanks_board_sound_struct))
        {
            return;
        }
        
        if (!IsSplitScreen() || IsSplitScreenHost(n_client_num))
        {
            level.thanks_board_sound_struct.soundtrack_id = PlaySound(0, VIDEO_SOUND_NAME, level.thanks_board_sound_struct.origin);
        }
    }
    else
    {
        sound_id = level.thanks_board_sound_struct.soundtrack_id;
        if (isdefined(sound_id) && SoundPlaying(sound_id))
        {
            StopSound(sound_id);
        }
    }
}
