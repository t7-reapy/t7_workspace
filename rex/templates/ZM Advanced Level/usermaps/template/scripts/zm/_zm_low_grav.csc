#using scripts\shared\audio_shared; 
#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\postfx_shared;
#using scripts\shared\util_shared;

#precache( "client_fx", "dlc1/castle/fx_plyr_screen_115_liquid" );

#namespace zm_low_grav;

function main()
{
	register_clientfields();
	level.var_51541120 = [];
	level._effect["low_grav_player_jump"] = "dlc1/castle/fx_plyr_115_liquid_trail";
	level._effect["low_grav_screen_fx"] = "dlc1/castle/fx_plyr_screen_115_liquid";
	level thread function_554db684();
}

function register_clientfields()
{
	clientfield::register("toplayer", "player_postfx", 5000, 1, "int", &function_df81c23d, 0, 0);
	clientfield::register("toplayer", "player_screen_fx", 5000, 1, "int", &player_screen_fx, 0, 1);
	clientfield::register("scriptmover", "undercroft_emissives", 5000, 1, "int", &function_9a8a19ab, 0, 0);
	clientfield::register("world", "snd_low_gravity_state", 5000, 2, "int", &snd_low_gravity_state, 0, 0);
}


function function_554db684()
{
	setdvar("wallrun_enabled", 1);
	setdvar("doublejump_enabled", 1);
	setdvar("playerEnergy_enabled", 1);
	setdvar("bg_lowGravity", 300);
	setdvar("wallRun_maxTimeMs_zm", 10000);
	setdvar("playerEnergy_maxReserve_zm", 200);
	setdvar("wallRun_peakTest_zm", 0);
}

function player_screen_fx(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
	if(newval == 1)
	{
		if(isdefined(level.var_51541120[localclientnum]))
		{
			deletefx(localclientnum, level.var_51541120[localclientnum], 1);
		}
		level.var_51541120[localclientnum] = playfxoncamera(localclientnum, level._effect["low_grav_screen_fx"]);
	}
	else if(isdefined(level.var_51541120[localclientnum]))
	{
		deletefx(localclientnum, level.var_51541120[localclientnum], 1);
	}
}

function function_df81c23d(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
	if(newval == 1)
	{
		setpbgactivebank(localclientnum, 2);
		self thread postfx::playpostfxbundle("pstfx_115_castle_loop");
	}
	else
	{
		setpbgactivebank(localclientnum, 1);
		self thread postfx::exitpostfxbundle();
	}
}

function function_9a8a19ab(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
	self endon("entityshutdown");
	self notify("hash_67a9e087");
	self endon("hash_67a9e087");
	if(newval == 1)
	{
		n_start_time = gettime();
		n_end_time = n_start_time + (1 * 1000);
		b_is_updating = 1;
		while(b_is_updating)
		{
			n_time = gettime();
			if(n_time >= n_end_time)
			{
				n_shader_value = mapfloat(n_start_time, n_end_time, 0, 1, n_end_time);
				b_is_updating = 0;
			}
			else
			{
				n_shader_value = mapfloat(n_start_time, n_end_time, 0, 1, n_time);
			}
			self mapshaderconstant(localclientnum, 0, "scriptVector2", 0, n_shader_value, 0);
			wait(0.01);
		}
	}
	else
	{
		n_start_time = gettime();
		n_end_time = n_start_time + (2 * 1000);
		b_is_updating = 1;
		while(b_is_updating)
		{
			n_time = gettime();
			if(n_time >= n_end_time)
			{
				n_shader_value = mapfloat(n_start_time, n_end_time, 1, 0, n_end_time);
				b_is_updating = 0;
			}
			else
			{
				n_shader_value = mapfloat(n_start_time, n_end_time, 1, 0, n_time);
			}
			self mapshaderconstant(localclientnum, 0, "scriptVector2", 0, n_shader_value, 0);
			wait(0.01);
		}
	}
}

function function_a3279a5(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
	self endon("entityshutdown");
	self notify("hash_67a9e087");
	self endon("hash_67a9e087");
	n_start_time = gettime();
	n_end_time = n_start_time + (1 * 1000);
	b_is_updating = 1;
	while(b_is_updating)
	{
		n_time = gettime();
		if(n_time >= n_end_time)
		{
			n_shader_value = mapfloat(n_start_time, n_end_time, 1, 0, n_end_time);
			b_is_updating = 0;
		}
		else
		{
			n_shader_value = mapfloat(n_start_time, n_end_time, 1, 0, n_time);
		}
		self mapshaderconstant(localclientnum, 0, "scriptVector2", 0, n_shader_value, 0);
		wait(0.01);
	}
}

function function_23861dfe(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
	self endon("entityshutdown");
	self notify("hash_67a9e087");
	self endon("hash_67a9e087");
	if(newval == 1)
	{
		n_start_time = gettime();
		n_end_time = n_start_time + (1 * 1000);
		b_is_updating = 1;
		while(b_is_updating)
		{
			n_time = gettime();
			if(n_time >= n_end_time)
			{
				n_shader_value = mapfloat(n_start_time, n_end_time, 0.3, 1, n_end_time);
				b_is_updating = 0;
			}
			else
			{
				n_shader_value = mapfloat(n_start_time, n_end_time, 0.3, 1, n_time);
			}
			self mapshaderconstant(localclientnum, 0, "scriptVector2", 0, n_shader_value, 0);
			wait(0.01);
		}
	}
	else
	{
		n_start_time = gettime();
		n_end_time = n_start_time + (2 * 1000);
		b_is_updating = 1;
		while(b_is_updating)
		{
			n_time = gettime();
			if(n_time >= n_end_time)
			{
				n_shader_value = mapfloat(n_start_time, n_end_time, 1, 0.3, n_end_time);
				b_is_updating = 0;
			}
			else
			{
				n_shader_value = mapfloat(n_start_time, n_end_time, 1, 0.3, n_time);
			}
			self mapshaderconstant(localclientnum, 0, "scriptVector2", 0, n_shader_value, 0);
			wait(0.01);
		}
	}
}

function function_a81107fc(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
	if(!isdefined(newval))
	{
		return;
	}
	if(newval)
	{
		fxobj = util::spawn_model(localclientnum, "tag_origin", self.origin, self.angles);
		fxobj thread function_10dcbf51(localclientnum, fxobj);
	}
}

function private function_10dcbf51(localclientnum, fxobj)
{
	fxobj playsound(localclientnum, "evt_ai_explode");
	wait(1);
	fxobj delete();
}

function snd_low_gravity_state(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
	if(newval == 1)
	{
		audio::playloopat("zmb_low_grav_room_loop", (0, 750, 1100));
		audio::playloopat("zmb_low_grav_machine_loop", (0, 750, 1100));
		playsound(0, "zmb_low_grav_machine_start", (0, 750, 1100));
	}
	if(newval == 2)
	{
		audio::stoploopat("zmb_low_grav_machine_loop", (0, 750, 1100));
		playsound(0, "zmb_low_grav_machine_stop", (0, 750, 1100));
	}
	else
	{
		audio::stoploopat("zmb_low_grav_room_loop", (0, 750, 1100));
	}
}

function zombie_low_gravity(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump)
{
	self endon("death");
	self endon("entityshutdown");
	if(newval)
	{
		self.in_low_g = 1;
	}
	else
	{
		self.in_low_g = 0;
	}
}

function function_20286238(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump)
{
	self endon("death");
	self endon("entityshutdown");
	if(newval)
	{
		if(!isdefined(self.var_9f5aac3e))
		{
			self.var_9f5aac3e = self playloopsound("zmb_moon_bg_airless");
		}
	}
	else if(isdefined(self.var_9f5aac3e))
	{
		self stoploopsound(self.var_9f5aac3e);
		self.var_9f5aac3e = undefined;
	}
}



