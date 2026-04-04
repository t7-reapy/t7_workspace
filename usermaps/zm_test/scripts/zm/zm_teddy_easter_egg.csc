
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

class ShootableTeddyEasterEgg
{
    var playback_id;
    var music_should_start;
    var music_delay;
}

function private _init()
{
    level.teddy_bear_music = new ShootableTeddyEasterEgg();
    level.teddy_bear_music.playback_id = undefined;
    level.teddy_bear_music.music_should_start = true;
    level.teddy_bear_music.music_delay = TEDDY_MUSIC_SOUND_INITIAL_DELAY;
    clientfield::register("world", TEDDY_CLIENTFIELD_MUSIC, VERSION_SHIP, 1, "int", &play_easter_egg_music, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);
}

function play_easter_egg_music(n_client_num, _oldVal, n_new_val, _bNewEnt, _bInitialSnap, _fieldName, _bWasTimeJump)
{
    util::waitforclient(n_client_num);
    PRINT_DEBUG_TEDDY("Called music reward with: " + n_new_val);

    if (n_new_val && level.teddy_bear_music.music_should_start)
    {
        waitrealtime(level.teddy_bear_music.music_delay);
        level.teddy_bear_music.playback_id = PlaySound(n_client_num, TEDDY_MUSIC_SOUND);
        PRINT_DEBUG_TEDDY("Music playing !");
    }
    else if (isdefined(level.teddy_bear_music.playback_id))
    {
        if (SoundPlaying(level.teddy_bear_music.playback_id))
        {
            StopSound(level.teddy_bear_music.playback_id);
            level.teddy_bear_music.music_should_start = true;
            level.teddy_bear_music.music_delay = TEDDY_MUSIC_SOUND_EXTENDED_DELAY;
            PRINT_DEBUG_TEDDY("Music Stopped !");
        }
        else
        {
            level.teddy_bear_music.music_should_start = false;
            PRINT_DEBUG_TEDDY("Music done. Never going to play it again !");
        }
    }
}
