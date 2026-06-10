#using scripts\shared\laststand_shared; 
#using scripts\shared\flag_shared; 
#using scripts\zm\_zm_audio; 
#using scripts\shared\callbacks_shared; 
#using scripts\shared\system_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\hellround\zm_hellround_shared;

#insert scripts\zm\hellround\zm_hellround_shared.gsh;
#insert scripts\zm\hellround\zm_hellround_announcer.gsh;
#namespace zm_hellround_announcer;

REGISTER_SYSTEM_EX("zm_hellround_announcer", &init, &main, undefined)

class HellroundAnnouncer
{
    var actor_killed_counter;
}

function private init()
{
    level.hellround_announcer = new HellroundAnnouncer();
    level.hellround_announcer.actor_killed_counter = 0;

    _add_vox(HRANN_VOX_ENJOYMENT);
    _add_vox(HRANN_VOX_BAD_PATH);
    _add_vox(HRANN_VOX_SURVIVED_BAD_PATH);
    _add_vox(HRANN_VOX_FAILED_BAD_PATH);
    _add_vox(HRANN_VOX_FINISHED_GOOD_PATH);
    _add_vox(HRANN_VOX_COMPLETE_ITERATION);
    _add_vox(HRANN_VOX_START_CERBERUS);
    _add_vox(HRANN_VOX_ENABLE_POWER_GOOD);
    _add_vox(HRANN_VOX_PLAYER_DEAD);
    _add_vox(HRANN_VOX_START_POST_BAD);
    _add_vox(HRANN_VOX_END_POST_BAD);

    callback::on_spawned(&_watch_player_elimination);
}

function private main()
{
    level.hellround_announcer thread _check_for_enjoyment();
    level.hellround_announcer thread _check_for_endgame();
}

/* region VOX setup and play */


function private _add_vox(voiceline)
{
    zm_audio::sndAnnouncerVoxAdd(voiceline, voiceline);
}

function private _play_vox(voiceline)
{
    thread zm_audio::sndAnnouncerPlayVox(voiceline, undefined);
}

function private _enjoy_kills()
{
    _play_vox(HRANN_VOX_ENJOYMENT);
}

function private _enjoy_player_death()
{
    _play_vox(HRANN_VOX_PLAYER_DEAD);
}

function private _enjoy_game_loss()
{
    _play_vox(HRANN_VOX_FAILED_BAD_PATH);
}

function bad_path_started()
{
    wait 3;
    _play_vox(HRANN_VOX_BAD_PATH);
}

function bad_path_survived()
{
    _play_vox(HRANN_VOX_SURVIVED_BAD_PATH);
}

function finished_good_path()
{
    _play_vox(HRANN_VOX_FINISHED_GOOD_PATH);
}

function iteration_complete()
{
    _play_vox(HRANN_VOX_COMPLETE_ITERATION);
}

function cerberus_feeding_started()
{
    _play_vox(HRANN_VOX_START_CERBERUS);
}

function private _enable_power_good()
{
    wait 2;
    _play_vox(HRANN_VOX_ENABLE_POWER_GOOD);
}

function private _post_bad_start()
{
    _play_vox(HRANN_VOX_START_POST_BAD);
}

function private _post_bad_end()
{
    _play_vox(HRANN_VOX_END_POST_BAD);
}

/* endregion */

function toggle_hellround_announce(b_enabled)
{
    if (!IS_TRUE(level.hellround.progress_stopped))
    {
        return;
    }

    if (IS_TRUE(b_enabled))
    {
        _post_bad_start();
    }
    else
    {
        _post_bad_end();
    }
}

function wait_for_hellround_bad_flag_when_abolished()
{
    level flag::wait_till(HELLROUND_BAD_FLAG_TRIGGER);
    _enable_power_good();
}

function watch_ai_kill() // self == ai actor
{    
    level endon("end_game");

    if(!isdefined(self))
    {
        return;
    }

    self waittill("death");
    level.hellround_announcer.actor_killed_counter++;
    level.hellround_announcer notify("actor_killed");
}

function private _check_for_enjoyment() // self == level.hellround_announcer
{
    level endon("end_game");

    while(true)
    {
        self waittill("actor_killed");

        if (self.actor_killed_counter > HRANN_ENJOYMENT_THRESHOLD && RandomFloat(1) > HRANN_ENJOYMENT_FREQUENCY)
        {
            self.actor_killed_counter = 0;
            if (zm_hellround_shared::is_hellround_running())
            {
                self _enjoy_kills();
            }
        }
    }
}

function private _check_for_endgame() // self == level.hellround_announcer
{
    level waittill("end_game");

    if (zm_hellround_shared::is_bad_iteration_running())
    {
        self _enjoy_game_loss();
    }
}


function private _watch_player_elimination() // self == player
{
    self endon("disconnect");
	self endon("spawned_player");
    level endon("end_game");

    while(isdefined(self) && self.sessionstate != "spectator")
    {
        wait 0.5;
    }

    if (zm_hellround_shared::is_bad_iteration_running())
    {
        self _enjoy_player_death();
    }
}
