
#using scripts\shared\array_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\util_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\zm_teddy_easter_egg.gsh;

#namespace zm_teddy_easter_egg;

REGISTER_SYSTEM("zm_teddy_easter_egg", &_init, undefined)

function private _init()
{
    clientfield::register("world", TEDDY_CLIENTFIELD_MUSIC, VERSION_SHIP, 1, "int", &play_easter_egg_music, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);
}

function play_easter_egg_music(n_client_num, _oldVal, n_new_val, _bNewEnt, _bInitialSnap, _fieldName, _bWasTimeJump)
{
    util::waitforclient(n_client_num);
    PRINT_DEBUG_TEDDY("Called music reward with: " + n_new_val);

    if (n_new_val)
    {
        //TODO
    }
}
