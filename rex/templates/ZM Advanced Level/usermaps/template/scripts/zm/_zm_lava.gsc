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

#namespace zm_lava;

REGISTER_SYSTEM_EX("zm_lava", &__init__, &__main__, undefined)

function __init__(){}

function __main__()
{
	callback::on_spawned(&onspawned);

	trig_fire = GetEntArray("lava_trig","targetname");
	if(trig_fire.size > 0)
	{
		zm_spawner::add_custom_zombie_spawn_logic( &lava_trig_for_zombies ); 
		zm_spawner::register_zombie_death_event_callback( &watch_for_death);
	}
}

function onspawned()
{
	trig_fire = GetEntArray("lava_trig","targetname");
	foreach(trig in trig_fire )
		self thread watch_player_step_on_lava_trig(trig);
}

function lava_trig_for_zombies()
{
	trig_fire = GetEntArray("lava_trig","targetname");
	foreach(trig in trig_fire )
		self thread zombie_watch_for_trig(trig);
}

function zombie_watch_for_trig(trig)
{
	self endon("death");
	level endon("end_game");

	if(isdefined(trig.script_flag) && trig.script_flag != "")
	{
		flag = trig.script_flag;
		level flag::init(flag);
	}

	while(isdefined(self))
	{
		trig waittill("trigger",zombie);
		if(zombie == self && (!isdefined(flag) || isdefined(flag) && level flag::get(flag)))
		{
			self.zombie_on_fire = 1;
			self.flame_fx_timeout = 15;
			self playloopsound("zmb_fire_loop");
			self thread zombie_death::flame_death_fx();
			wait 15;
			self stoploopsound(0.25);
			self.zombie_on_fire = 0;
		}
		wait(.05);
	}
}

function watch_for_death()
{
	level endon("end_game");

    if(!isdefined(self.zombie_on_fire))
    	return;

	if(self.zombie_on_fire == 1)
	{
		PlayFX("explosions/fx_vexp_raps_death", self.origin);
		PlaySoundAtPosition("explode_flesh", self.origin);

		self thread zombie_utility::zombie_gut_explosion();
		self PlaySound("wpn_grenade_explode_close");
		self RadiusDamage(self.origin, 128, 30, 15, undefined, "MOD_EXPLOSIVE");
		self ghost();
		self clientfield::set("zombie_ragdoll_explode", 1);

		foreach(player in GetPlayers() )
		if ( distance2dSquared( player.origin, self.origin ) < 7000 && !player hasPerk( "specialty_phdflopper" ) )
		{
			player DoDamage(40, self.origin);
			player shellShock("explosion", 0.6);

			Earthquake(0.2,0.6,self.origin,200);
		}	
	}
}

function watch_player_step_on_lava_trig(trig)
{
	self endon("end_function");

	self.is_burning = false;

	while(isdefined(trig) && isdefined(self))
	{
		trig waittill("trigger",player);
		if(self == player && !self.is_burning && self IsOnGround() && self IsWallRunning() == 0)
		{
			self.is_burning = true;
			self do_player_fire_damage();
		}
		wait 0.05;
	}
}

function do_player_fire_damage(damage)
{   
	self endon("end_function");
	
    burn_time = 2;
	self.is_burning = true;
    if (self hasPerk("specialty_phdflopper"))
    {
		self burnplayer::setPlayerBurning( burn_time, .5, 0, self, undefined );
        wait burn_time;
        self.is_burning = false;
    }
    else
    {
		self burnplayer::setPlayerBurning(burn_time, .5, 6, self, undefined );
        self AllowSprint(false);
        wait burn_time;
        self AllowSprint(true);
        self.is_burning = false;
    }
}

