#using scripts\codescripts\struct;
#using scripts\shared\ai_shared;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_load;
#using scripts\zm\_zm;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#precache( "client_fx", "zombie/fx_bmode_tent_light_zod_zmb" );
#precache( "client_fx", "zombie/fx_keeper_ambient_torso_zod_zmb" );
#precache( "client_fx", "zombie/fx_keeper_glow_mouth_zod_zmb" );
#precache( "client_fx", "zombie/fx_keeper_mist_trail_zod_zmb" );
#precache( "client_fx", "zombie/fx_keeper_death_zod_zmb" );

#namespace zm_ai_keeper;

REGISTER_SYSTEM_EX( "zm_ai_keeper", &__init__, &__main__, undefined )

function __init__()
{
	ai::add_archetype_spawn_function("keeper", &function_5ea6033e);
	ai::add_archetype_spawn_function("keeper", &function_6ded398b);
	if(ai::shouldregisterclientfieldforarchetype("keeper"))
	{
		clientfield::register("actor", "keeper_death", 15000, 2, "int", &function_6e8422e9, 0, 0);
		//clientfield::register("world", "keeper_spawn_portals", 1, 4, "int", &keeper_spawn_portals, 0, 0);
	}
	level._effect["chaos_1p_light"] = "zombie/fx_bmode_tent_light_zod_zmb";
	level._effect["keeper_glow"] = "zombie/fx_keeper_ambient_torso_zod_zmb";
	level._effect["keeper_mouth"] = "zombie/fx_keeper_glow_mouth_zod_zmb";
	level._effect["keeper_trail"] = "zombie/fx_keeper_mist_trail_zod_zmb";
	level._effect["keeper_death"] = "zombie/fx_keeper_death_zod_zmb";
}

function __main__()
{
	
}

function function_5ea6033e(localclientnum)
{
	self.var_341f7209 = playfxontag(localclientnum, level._effect["keeper_glow"], self, "j_spineupper");
	self.var_c5e3cf4b = playfxontag(localclientnum, level._effect["keeper_mouth"], self, "j_head");
	self.var_2d3cc156 = playfxontag(localclientnum, level._effect["keeper_trail"], self, "j_robe_front_03");
	if(!isdefined(self.sndlooper))
	{
		self.sndlooper = self playloopsound("zmb_keeper_looper");
	}
	self callback::on_shutdown(&function_4dc56cc7);
}

function function_4dc56cc7(localclientnum)
{
	if(isdefined(self.var_341f7209))
	{
		stopfx(localclientnum, self.var_341f7209);
		self.var_341f7209 = undefined;
	}
	if(isdefined(self.var_c5e3cf4b))
	{
		stopfx(localclientnum, self.var_c5e3cf4b);
		self.var_c5e3cf4b = undefined;
	}
	if(isdefined(self.var_2d3cc156))
	{
		stopfx(localclientnum, self.var_2d3cc156);
		self.var_2d3cc156 = undefined;
	}
	v_origin = self gettagorigin("j_spineupper");
	v_angles = self gettagangles("j_spineupper");
	if(isdefined(v_origin) && isdefined(v_angles))
	{
		playfx(localclientnum, level._effect["keeper_death"], v_origin, v_angles);
	}
	self stopallloopsounds();
	self playsound(0, "zmb_keeper_death_explo");
}

function function_6ded398b(localclientnum)
{
	self thread function_ea48e71e(localclientnum);
}

function function_ea48e71e(localclientnum)
{
	self endon("entityshutdown");
	self util::waittill_dobj(localclientnum);
	if(!isdefined(self))
	{
		return;
	}
	s_timer = new_timer(localclientnum);
	n_phase_in = 1;
	do
	{
		util::server_wait(localclientnum, 0.11);
		n_current_time = s_timer get_time_in_seconds();
		n_delta_val = lerpfloat(0, 1, n_current_time / n_phase_in);
		self mapshaderconstant(localclientnum, 0, "scriptVector2", n_delta_val);
		self mapshaderconstant(localclientnum, 0, "scriptVector0", n_delta_val);
	}
	while(n_current_time < n_phase_in);
	s_timer notify("timer_done");
}

function new_timer(localclientnum)
{
	s_timer = spawnstruct();
	s_timer.n_time_current = 0;
	s_timer thread timer_increment_loop(localclientnum, self);
	return s_timer;
}

function timer_increment_loop(localclientnum, entity)
{
	entity endon("entityshutdown");
	self endon("timer_done");
	while(isdefined(self))
	{
		util::server_wait(localclientnum, 0.016);
		self.n_time_current = self.n_time_current + 0.016;
	}
}

function get_time()
{
	return self.n_time_current * 1000;
}

function get_time_in_seconds()
{
	return self.n_time_current;
}

function reset_timer()
{
	self.n_time_current = 0;
}

function function_6e8422e9(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
	self endon("entityshutdown");
	self util::waittill_dobj(localclientnum);
	if(!isdefined(self))
	{
		return;
	}
	if(newval == 1)
	{
		s_timer = new_timer(localclientnum);
		n_phase_in = 0.3;
		self.removingfireshader = 1;
		do
		{
			util::server_wait(localclientnum, 0.11);
			n_current_time = s_timer get_time_in_seconds();
			n_delta_val = lerpfloat(1, 0.1, n_current_time / n_phase_in);
			self mapshaderconstant(localclientnum, 0, "scriptVector2", n_delta_val);
		}
		while(n_current_time < n_phase_in);
		s_timer notify("timer_done");
		self.removingfireshader = 0;
	}
	else if(newval == 2)
	{
		if(!isdefined(self))
		{
			return;
		}
		n_phase_in = 0.3;
		s_timer = new_timer(localclientnum);
		do
		{
			util::server_wait(localclientnum, 0.11);
			n_current_time = s_timer get_time_in_seconds();
			n_delta_val = lerpfloat(1, 0, n_current_time / n_phase_in);
			self mapshaderconstant(localclientnum, 0, "scriptVector0", n_delta_val);
		}
		while(n_current_time < n_phase_in);
		s_timer notify("timer_done");
		self mapshaderconstant(localclientnum, 0, "scriptVector0", 0);
	}
}

