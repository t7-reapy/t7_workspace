#using scripts\zm\_zm_audio; 
#using scripts\shared\util_shared;
#using scripts\shared\system_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\zm\hellround\zm_hellround_music.gsh;

#namespace zm_hellround_music;

REGISTER_SYSTEM_EX("zm_hellround_music", &__init__, undefined, undefined)

function __init__()
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

//In MOTD the game over muysic changes depending on what ending you get, we will replicate this here
function gameover_ending_sounds()
{
    self endon("end_game"); //Stop changing the gameover sound if the game ends

    while(true)
    {
        //To change the ending type, notify the corresponding string as written here
        endingType = self util::waittill_any_return("hellround_regular_ending","hellround_good_ending","hellround_bad_ending");
        
        //Now we override the gameover music state with our preferred ending based on which notify we received
        if(endingType == "hellround_regular_ending")
        {
            zm_audio::musicState_Create("game_over", PLAYTYPE_GAMEEND, "gameover");
        }
        if(endingType == "hellround_good_ending")
        {
            zm_audio::musicState_Create("game_over", PLAYTYPE_GAMEEND, "gameover_good");
        }
        if(endingType == "hellround_bad_ending")
        {
            zm_audio::musicState_Create("game_over", PLAYTYPE_GAMEEND, "gameover_bad");
        }
    }
}
