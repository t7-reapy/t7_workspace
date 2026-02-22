#using scripts\codescripts\struct;
#using scripts\shared\array_shared;
#using scripts\shared\audio_shared;
#using scripts\shared\visionset_mgr_shared; 
#using scripts\shared\ai_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\postfx_shared;
#using scripts\shared\util_shared;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace zm_ai_monkey;

#precache( "client_fx", "dlc5/zmhd/fx_zmb_monkey_eyes" );
#precache( "client_fx", "dlc5/cosmo/fx_zombie_ape_spawn_dust" );
#precache( "client_fx", "dlc5/cosmo/fx_zombie_ape_spawn_trail" );
#precache( "client_fx", "dlc5/cosmo/fx_zombie_lunar_lander_dust" );
#precache( "client_fx", "dlc5/cosmo/fx_zmb_monkey_death");

REGISTER_SYSTEM_EX( "zm_ai_monkey", &__init__, undefined, undefined )

function __init__()
{
	registerclientfields();
	ai::add_archetype_spawn_function("monkey", &monkeycollision);
	visionset_mgr::register_visionset_info("zm_cosmodrome_monkey_on", 21000, 31, undefined, "zombie_cosmodrome_monkey");
	visionset_mgr::register_visionset_info("zm_cosmodrome_monkey_off", 21000, 31, undefined, "zombie_cosmodrome_monkey");
	level._effect["monkey_eye_glow"] = "dlc5/zmhd/fx_zmb_monkey_eyes";
	level._effect["monkey_spawn"] = "dlc5/cosmo/fx_zombie_ape_spawn_dust";
	level._effect["monkey_trail"] = "dlc5/cosmo/fx_zombie_ape_spawn_trail";
	level._effect["monkey_death"] = "dlc5/cosmo/fx_zmb_monkey_death";
	level._effect["lander_fx"] = "dlc5/cosmo/fx_zombie_lunar_lander_dust";
}

function registerclientfields()
{
	clientfield::register("actor", "monkey_eye_glow", 21000, 1, "int", &monkey_eye_glow_fx, 0, 0);
	clientfield::register("world", "COSMO_VISIONSET_MONKEY", 21000, 1, "int", &monkey_round_vision_set, 0, 0);
	clientfield::register("scriptmover", "COSMO_MONKEY_LANDER_FX", 21000, 1, "int", &monkey_lander_fx, 0, 0);
}

function private monkeycollision(localclientnum)
{
	self suppressragdollselfcollision(1);
}

function monkey_eye_glow_fx(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump)
{
	if(newval)
	{
		waittillframeend;
		if(!isdefined(self))
		{
			return;
		}
		var_f9e79b00 = self mapshaderconstant(localclientnum, 0, "scriptVector2", 0, 1, 3, 0);
		self._eyearray[localclientnum] = playfxontag(localclientnum, level._effect["monkey_eye_glow"], self, "j_eyeball_le");
	}
	else
	{
		waittillframeend;
		if(!isdefined(self))
		{
			return;
		}
		var_f9e79b00 = self mapshaderconstant(localclientnum, 0, "scriptVector2", 0, 0, 3, 0);
		if(isdefined(self._eyearray))
		{
			if(isdefined(self._eyearray[localclientnum]))
			{
				deletefx(localclientnum, self._eyearray[localclientnum], 1);
				self._eyearray[localclientnum] = undefined;
			}
		}
	}
}


function monkey_lander_fx(local_client_num, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump)
{
	if(local_client_num != 0)
	{
		return;
	}
	while(!self hasdobj(local_client_num))
	{
		wait(0.1);
	}
	if(newval)
	{
		self thread monkey_lander_fx_on();
		//level thread function_ea758913();
	}
	else
	{
		self thread monkey_lander_fx_off();
	}
}

function monkey_lander_fx_on()
{
	self endon("switch_off_monkey_lander_fx");
	playsound(0, "zmb_ape_intro_whoosh", self.origin);
	wait(2.5);
	if(isdefined(self))
	{
		self.fx = [];
		players = getlocalplayers();
		ent_num = self getentitynumber();
		for(i = 0; i < players.size; i++)
		{
			player = players[i];
			if(!isdefined(player._monkey_lander_fx))
			{
				player._monkey_lander_fx = [];
			}
			if(isdefined(player._monkey_lander_fx[ent_num]))
			{
				deletefx(i, player._monkey_lander_fx[ent_num]);
				player._monkey_lander_fx[ent_num] = undefined;
			}
			player._monkey_lander_fx[ent_num] = playfxontag(i, level._effect["monkey_trail"], self, "tag_origin");
			setfxignorepause(i, player._monkey_lander_fx[ent_num], 1);
		}
	}
}

function monkey_lander_fx_off()
{
	players = getlocalplayers();
	ent_num = self getentitynumber();
	for(i = 0; i < players.size; i++)
	{
		player = players[i];
		playfx(i, level._effect["monkey_spawn"], self.origin);
		playrumbleonposition(i, "explosion_generic", self.origin);
		player earthquake(0.5, 0.5, player.origin, 1000);
	}
	playsound(0, "zmb_ape_intro_land", self.origin);
}

function monkey_round_vision_set(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump)
{
	if(newval)
	{
		level.var_f2fba834 = 1;
		if(isdefined(level._power_on) && !level._power_on)
		{
			level._power_on = 1;
			//level thread setup_lander_screens(localclientnum);
		}
		player = getlocalplayers()[localclientnum];
		player earthquake(0.2, 5, player.origin, 20000);
		playsound(0, "zmb_ape_intro_sonicboom_fnt", (0, 0, 0));
		level._effect["eye_glow"] = level._effect["monkey_eye_glow"];
		e_player = getlocalplayers()[localclientnum];
		//e_player set_fog("monkey");
	}
}