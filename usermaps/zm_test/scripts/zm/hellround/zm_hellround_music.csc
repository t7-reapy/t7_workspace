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

    level.hellround_music = undefined;
}

function private hellround_music(n_client_num, _oldVal, n_new_val, _bNewEnt, _bInitialSnap, _fieldName, _bWasTimeJump)
{
    util::waitforclient(n_client_num);
    player = GetLocalPlayer(n_client_num);
    switch (n_new_val)
    {
        case HRMUS_DISABLED:
            player StopLoopSound(level.hellround_music, 1);
            break;
        case 1:
            level.hellround_music = player PlayLoopSound(HRMUS_ITERATION_1, 1);
            break;
        case 2:
            level.hellround_music = player PlayLoopSound(HRMUS_ITERATION_2, 1);
            break;
        case 3:
            level.hellround_music = player PlayLoopSound(HRMUS_ITERATION_3, 1);
            break;
        default:
            level.hellround_music = player PlayLoopSound(HRMUS_ITERATION_BAD, 1);
            break;
    }
}