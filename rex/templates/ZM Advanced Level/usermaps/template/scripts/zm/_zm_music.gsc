#using scripts\shared\flag_shared; 
#using scripts\shared\callbacks_shared; 
#using scripts\zm\_zm_unitrigger; 
#using scripts\shared\audio_shared; 
#using scripts\codescripts\struct; 
#using scripts\shared\system_shared;
#using scripts\shared\array_shared;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_audio;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\zm\_zm_utility.gsh;

#define PLAYTYPE_REJECT 1
#define PLAYTYPE_QUEUE 2
#define PLAYTYPE_ROUND 3
#define PLAYTYPE_SPECIAL 4
#define PLAYTYPE_GAMEEND 5

#define ACTIVATE_SOUND 		        "zmb_meteor_activate" 
#define LOOP_SOUND				    "zmb_meteor_loop" 					

#namespace zm_music_easter_egg;

REGISTER_SYSTEM_EX("zm_music_easter_egg", &__init__, &__main__, undefined)

function __init__(){}

function __main__()
{
    level thread Setup_MusicStates();
    level thread Setup_EasterEgg();
}

function Setup_MusicStates()
{		
	zm_audio::musicState_Create("round_start", PLAYTYPE_ROUND, "roundstart1", "roundstart2", "roundstart3", "roundstart4" );
	zm_audio::musicState_Create("round_start_short", PLAYTYPE_ROUND, "roundstart_short1", "roundstart_short2", "roundstart_short3", "roundstart_short4" );
	zm_audio::musicState_Create("round_start_first", PLAYTYPE_ROUND, "roundstart_first" );
	zm_audio::musicState_Create("round_end", PLAYTYPE_ROUND, "roundend1" );
	zm_audio::musicState_Create("game_over", PLAYTYPE_GAMEEND, "gameover" );
	zm_audio::musicState_Create("dog_start", PLAYTYPE_ROUND, "dogstart1" );
	zm_audio::musicState_Create("dog_end", PLAYTYPE_ROUND, "dogend1" );
	zm_audio::musicState_Create("timer", PLAYTYPE_ROUND, "timer" );
	zm_audio::musicState_Create("power_on", PLAYTYPE_QUEUE, "poweron" );
	zm_audio::musicstate_create("lullaby_for_a_dead_man", PLAYTYPE_SPECIAL, "lullaby_for_a_dead_man");
    zm_audio::musicState_Create("template", PLAYTYPE_SPECIAL, "template");
}


function Setup_EasterEgg()
{
    while(1)
    {

        level.secret = 0;
        secret_trigs = struct::get_array("music_egg", "targetname");
        array::thread_all(secret_trigs, &sndHint);
        while(true)
        {
            level waittill("egg_activated");
            if(level.secret == secret_trigs.size)
            {
                break;
            }
        }
        level thread zm_audio::sndMusicSystem_PlayState("template");
        while(level.musicSystem.currentPlaytype >= 4) // special or higher
        {
            level waittill("between_round_over"); // next round
        }
    }
}

function sndHint()
{
	e_origin = spawn("script_origin", self.origin);
	e_origin zm_unitrigger::create_unitrigger();
	e_origin playloopsound("zmb_meteor_loop", 1);

	while(!(isdefined(e_origin.b_activated) && e_origin.b_activated))
	{
		e_origin waittill("trigger_activated");
		if(isdefined(level.musicsystem.currentplaytype) && level.musicsystem.currentplaytype >= 4 || (isdefined(level.musicsystemoverride) && level.musicsystemoverride))
		{
			return false;
		}
		e_origin activate_music();
	}
	zm_unitrigger::unregister_unitrigger(e_origin.s_unitrigger);
	e_origin delete();
}

function activate_music()
{
	if(!(isdefined(self.b_activated) && self.b_activated))
	{
		self.b_activated = 1;
		level.secret++;
		level notify("egg_activated");
		self stoploopsound(0.2);
	}
	self playsound("zmb_meteor_activate");
}
