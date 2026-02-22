#using scripts\shared\ai\zombie_utility; 
#using scripts\shared\ai\zombie_death; 
#using scripts\shared\ai\systems\gib; 
#using scripts\shared\clientfield_shared; 
#using scripts\zm\_zm_spawner; 
#using scripts\shared\flag_shared; 
#using scripts\shared\_burnplayer; 
#using scripts\zm\_callbacks;
#using scripts\shared\callbacks_shared; 
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

#namespace zm_wallrunning;

REGISTER_SYSTEM_EX("zm_wallrunning", &__init__, &__main__, undefined)

function __init__(){}

function __main__()
{
	callback::on_spawned(&onspawned);
}

function onspawned()
{
	self thread setup_wallrun();

	wallrun_trigger = GetEntArray("wallrun_trig","targetname");
	foreach(trig in wallrun_trigger )
		self thread wallrun_handler(trig);
}

function setup_wallrun()
{
	SetDvar("wallrun_enabled", 1);
	self AllowWallRun(false);
}

function wallrun_handler(trig)
{
	self endon("end_function");

	while(isDefined(trig) && isDefined(self) && IsPlayer(self))
	{
		trig waittill("trigger", player);

		if (player == self && !isdefined(self.iswallrunning))
		{
			self thread enable_wallrun(trig);
		}
	}
}

function enable_wallrun(trig)
{
	self endon("end_function");

	self.iswallrunning = true;
	self AllowWallRun(true);

	while(isdefined(self) && IsPlayer(self) && isdefined(trig) && self IsTouching(trig))
		wait(0.05);

	self AllowWallRun(false);
	self.iswallrunning = undefined;
}