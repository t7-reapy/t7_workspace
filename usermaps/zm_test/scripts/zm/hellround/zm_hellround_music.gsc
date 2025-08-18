#using scripts\shared\clientfield_shared; 
#using scripts\zm\_zm_audio; 
#using scripts\shared\util_shared;
#using scripts\shared\system_shared;

#insert scripts\shared\version.gsh;
#insert scripts\shared\shared.gsh;

#using scripts\zm\hellround\zm_hellround_shared;
#insert scripts\zm\hellround\zm_hellround_shared.gsh;
#insert scripts\zm\hellround\zm_hellround_music.gsh;
#namespace zm_hellround_music;

REGISTER_SYSTEM("zm_hellround_music", &init, undefined)

function init()
{
    clientfield::register("world", HRMUS_CLIENT_FIELD, VERSION_SHIP, 3, "int");
    
    zm_audio::musicState_Create("round_start", PLAYTYPE_ROUND, "roundstart1", "roundstart2", "roundstart3", "roundstart4");
    zm_audio::musicState_Create("round_start_short", PLAYTYPE_ROUND, "roundstart1", "roundstart2", "roundstart3", "roundstart4");
    zm_audio::musicState_Create("round_start_first", PLAYTYPE_ROUND, "roundstart1");
    zm_audio::musicState_Create("round_end", PLAYTYPE_ROUND, "roundend1");
    zm_audio::musicState_Create("game_over", PLAYTYPE_GAMEEND, "gameover");
    zm_audio::musicState_Create("dog_start", PLAYTYPE_ROUND, "dogstart1");
    zm_audio::musicState_Create("dog_end", PLAYTYPE_ROUND, "dogend1");

    thread gameover_ending_sounds();
    thread gameover_stop_music();
}

function toggle_hellround_music(b_enable)
{
    iteration = HRMUS_DISABLED;
    if (IS_TRUE(b_enable))
    {
        iteration = zm_hellround_shared::get_current_iteration();
    }
    level clientfield::set(HRMUS_CLIENT_FIELD, iteration);
}

// In MOTD the game over music changes depending on what ending you get, we will replicate this here
function gameover_ending_sounds()
{
    level endon("end_game"); //Stop changing the gameover sound if the game ends

    while(true)
    {
        //To change the ending type, notify the corresponding string as written here
        endingType = level util::waittill_any_return(HRMUS_REGULAR_ENDING, HRMUS_GOOD_ENDING, HRMUS_BAD_ENDING);
        
        //Now we override the gameover music state with our preferred ending based on which notify we received
        switch (endingType)
        {
            case HRMUS_GOOD_ENDING:
                zm_audio::musicState_Create("game_over", PLAYTYPE_GAMEEND, "gameover_good");
                break;
            case HRMUS_BAD_ENDING:
                zm_audio::musicState_Create("game_over", PLAYTYPE_GAMEEND, "gameover_bad");
                break;
            default: // HRMUS_REGULAR_ENDING
                zm_audio::musicState_Create("game_over", PLAYTYPE_GAMEEND, "gameover");
                break;
        }
    }
}

function private gameover_stop_music()
{
    level waittill("end_game");
    level clientfield::set(HRMUS_CLIENT_FIELD, HRMUS_DISABLED);
}

function enable_bad_ending()
{
    level notify(HRMUS_BAD_ENDING);
}

function enable_good_ending()
{
    level notify(HRMUS_GOOD_ENDING);
}

function disable_round_sounds()
{
    level.musicSystem.states["round_start"].oldMusArray = level.musicSystem.states["round_start"].musArray;
    level.musicSystem.states["round_start"].musArray = [];

    level.musicSystem.states["round_start_short"].oldMusArray = level.musicSystem.states["round_start_short"].musArray;
    level.musicSystem.states["round_start_short"].musArray = [];

    level.musicSystem.states["round_start_first"].oldMusArray = level.musicSystem.states["round_start_first"].musArray;
    level.musicSystem.states["round_start_first"].musArray = [];

    level.musicSystem.states["round_end"].oldMusArray = level.musicSystem.states["round_end"].musArray;
    level.musicSystem.states["round_end"].musArray = [];
}

function restore_round_sounds()
{
    level.musicSystem.states["round_start"].musArray = level.musicSystem.states["round_start"].oldMusArray;
    level.musicSystem.states["round_start_short"].musArray = level.musicSystem.states["round_start_short"].oldMusArray;
    level.musicSystem.states["round_start_first"].musArray = level.musicSystem.states["round_start_first"].oldMusArray;
    level.musicSystem.states["round_end"].musArray = level.musicSystem.states["round_end"].oldMusArray;
}
