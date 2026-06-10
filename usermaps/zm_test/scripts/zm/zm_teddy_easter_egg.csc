
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
    if (IsSplitScreen() && !IsSplitScreenHost(n_client_num))
    {
        PRINT_DEBUG_TEDDY("Not split-screen host. Not playing music.");
        return;
    }

    util::waitforclient(n_client_num);

    PRINT_DEBUG_TEDDY("Called music reward with: " + n_new_val);

    if (n_new_val)
    {
        // Start / resume from the beginning. Once the song has played to its end
        // on its own, music_should_start is false and we never start it again.
        if (!level.teddy_bear_music.music_should_start)
        {
            PRINT_DEBUG_TEDDY("Music already finished. Not playing again.");
            return;
        }

        level endon("teddy_music_paused"); // a pause during the start delay cancels this start
        waitrealtime(level.teddy_bear_music.music_delay);
        level.teddy_bear_music.playback_id = PlaySound(n_client_num, TEDDY_MUSIC_SOUND);
        PRINT_DEBUG_TEDDY("Music playing !");
        level thread _watch_music_finished();
    }
    else
    {
        // Pause: stop the song but stay armed, so the next hellround restarts it
        // from the beginning. This is NOT a natural finish.
        level notify("teddy_music_paused"); // ends the finish-watcher and any pending start
        if (isdefined(level.teddy_bear_music.playback_id) && SoundPlaying(level.teddy_bear_music.playback_id))
        {
            StopSound(level.teddy_bear_music.playback_id);
            level.teddy_bear_music.music_delay = TEDDY_MUSIC_SOUND_EXTENDED_DELAY;
            PRINT_DEBUG_TEDDY("Music paused !");
        }
    }
}

// Disarms replay once the song ends by itself. A pause fires "teddy_music_paused"
// and ends this thread before it can disarm, so a paused song still resumes.
function private _watch_music_finished()
{
    level endon("teddy_music_paused");

    waitrealtime(0.5); // let the sound register as playing before we poll for its end
    while (isdefined(level.teddy_bear_music.playback_id) && SoundPlaying(level.teddy_bear_music.playback_id))
    {
        waitrealtime(0.25);
    }

    level.teddy_bear_music.music_should_start = false;
    PRINT_DEBUG_TEDDY("Music finished. Never going to play it again !");
}
