#using scripts\shared\trigger_shared; 
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

#namespace zm_water;

REGISTER_SYSTEM_EX("zm_water", &__init__, &__main__, undefined)

function __init__(){}

function __main__()
{
	//zombieUnderwaterTriggers = GetEntArray( "zombie_underwater_trigger", "targetname" );
	//array::thread_all( zombieUnderwaterTriggers, &ZombieUnderWaterLogic );
}

function ZombieUnderWaterLogic()
{
	//level endon( "end_game" );
//
	//while(1)
	//{
	//	self waittill( "trigger", zombie );
	//	self thread trigger::function_thread( zombie, &ZombieUnderwaterEnter ,&ZombieUnderwaterExit );
	//}
}

function ZombieUnderwaterEnter( zombie )
{
	//if( isdefined( zombie ) )
	//	zombie.low_gravity = true;
}

function ZombieUnderwaterExit( zombie )
{
	//if( isdefined( zombie ) )
	//	zombie.low_gravity = false;
}
