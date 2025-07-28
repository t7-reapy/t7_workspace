#using scripts\zm\_zm_audio; 
#using scripts\shared\util_shared;
#using scripts\shared\system_shared;

#insert scripts\shared\shared.gsh;

#insert scripts\zm\hellround\zm_hellround_shared.gsh;
#insert scripts\zm\hellround\zm_hellround_music.gsh;
#namespace zm_hellround_music;

REGISTER_SYSTEM("zm_hellround_music", &init, undefined)

function init()
{
    zm_audio::musicState_Create("round_start", PLAYTYPE_ROUND, "roundstart1", "roundstart2", "roundstart3", "roundstart4");
    zm_audio::musicState_Create("round_start_short", PLAYTYPE_ROUND, "roundstart1", "roundstart2", "roundstart3", "roundstart4");
    zm_audio::musicState_Create("round_start_first", PLAYTYPE_ROUND, "roundstart1");
    zm_audio::musicState_Create("round_end", PLAYTYPE_ROUND, "roundend1");
    zm_audio::musicState_Create("game_over", PLAYTYPE_GAMEEND, "gameover");
    zm_audio::musicState_Create("dog_start", PLAYTYPE_ROUND, "dogstart1");
    zm_audio::musicState_Create("dog_end", PLAYTYPE_ROUND, "dogend1");

    level thread gameover_ending_sounds();
}

// In MOTD the game over muysic changes depending on what ending you get, we will replicate this here
function gameover_ending_sounds() // self == level
{
    self endon("end_game"); //Stop changing the gameover sound if the game ends

    while(true)
    {
        //To change the ending type, notify the corresponding string as written here
        endingType = self util::waittill_any_return(HRMUS_REGULAR_ENDING, HRMUS_GOOD_ENDING, HRMUS_BAD_ENDING);
        
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
