#using scripts\shared\array_shared; 
#using scripts\shared\util_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;

#insert scripts\shared\version.gsh;
#insert scripts\shared\shared.gsh;

#insert scripts\zm\hellround\zm_hellround_shared.gsh;
#insert scripts\zm\hellround\zm_hellround_music.gsh;
#namespace zm_hellround_music;

REGISTER_SYSTEM("zm_hellround_music", &init, undefined)

function init()
{
    clientfield::register("world", HRMUS_CLIENT_FIELD, VERSION_SHIP, 3, "int", &hellround_music, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);

    level.hellround_music = spawnstruct();
    level.hellround_music.soundtrack_id = undefined;
    level.hellround_music.sound_ent = spawn(0, (0, 0, 0), "script_origin");
    level.hellround_music.iteration_musics = array::randomize(array(HRMUS_ITERATION_1, HRMUS_ITERATION_2, HRMUS_ITERATION_3));
}

function private hellround_music(n_client_num, _oldVal, n_new_val, _bNewEnt, _bInitialSnap, _fieldName, _bWasTimeJump)
{
    util::waitforclient(n_client_num);

    if (IsSplitScreen() && !IsSplitScreenHost(n_client_num))
    {
        return;
    }

    switch (n_new_val)
    {
        case HRMUS_DISABLED:
            level.hellround_music.sound_ent StopLoopSound(level.hellround_music.soundtrack_id, 1);
            break;
        case 1:
        case 2:
        case 3:
            level.hellround_music.soundtrack_id = level.hellround_music.sound_ent PlayLoopSound(level.hellround_music.iteration_musics[n_new_val - 1], 1);
            break;
        default:
            level.hellround_music.soundtrack_id = level.hellround_music.sound_ent PlayLoopSound(HRMUS_ITERATION_BAD, 1);
            break;
    }
}