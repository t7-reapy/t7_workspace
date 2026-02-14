#using scripts\codescripts\struct;
#using scripts\shared\audio_shared;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;
#using scripts\shared\system_shared;
#using scripts\zm\_zm_utility;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#precache( "client_fx", "dlc5/zmb_weapon/fx_staff_charge_souls");
#precache( "client_fx", "dlc5/tomb/fx_tomb_challenge_fire");

#namespace zm_soul_box;

REGISTER_SYSTEM_EX("zm_soul_box", &__init__, &__main__, undefined)

function __init__()
{
	level._effect["zombie_soul"] = "dlc5/zmb_weapon/fx_staff_charge_souls";
	level._effect["foot_box_glow"] = "dlc5/tomb/fx_tomb_challenge_fire";
	level._effect["foot_print_box_glow"] = "dlc5/tomb/fx_tomb_challenge_fire";
	n_bits = getminbitcountfornum(4);
	clientfield::register("actor", "foot_print_box_fx", 21000, 1, "int", &foot_print_box_fx, 0, 0);
	clientfield::register("actor", "zombie_soul", 21000, n_bits, "int", &function_1ee903c, 0, 0);
	clientfield::register("scriptmover", "foot_print_box_glow", 21000, 1, "int", &foot_print_box_glow, 0, 0);
}

function __main__()
{
}

function function_1ee903c(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump)
{
	v_origin = self gettagorigin("J_SpineUpper");
	v_dest = undefined;
	if(!isdefined(level.var_d1435401))
	{
		level.var_d1435401 = [];
	}
	if(isdefined(level.var_d1435401[newval]))
	{
		v_dest = level.var_d1435401[newval];
	}
	if(!isdefined(v_dest) || !isdefined(v_origin))
	{
		return;
	}
	if(isdefined(self))
	{
		v_origin = self gettagorigin("J_SpineUpper");
	}
	e_fx = spawn(localclientnum, v_origin, "script_model");
	e_fx setmodel("tag_origin");
	e_fx playsound(localclientnum, "zmb_squest_charge_soul_leave");
	e_fx playloopsound("zmb_squest_charge_soul_lp");
	playfxontag(localclientnum, level._effect["zombie_soul"], e_fx, "tag_origin");
	e_fx moveto(v_dest + vectorscale((0, 0, 1), 5), 0.5);
	IPrintLnBold(e_fx + v_dest );
	e_fx waittill("movedone");
	e_fx playsound(localclientnum, "zmb_squest_charge_soul_impact");
	playfxontag(localclientnum, level._effect["zombie_soul"], e_fx, "tag_origin");
	util::server_wait(localclientnum, 0.3);
	e_fx delete();
}

function foot_print_box_fx(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump)
{
	a_structs = struct::get_array("foot_box_pos", "targetname");
	s_box = arraygetclosest(self.origin, a_structs);
	e_fx = spawn(localclientnum, self gettagorigin("J_SpineUpper"), "script_model");
	e_fx setmodel("tag_origin");
	e_fx playsound(localclientnum, "zmb_squest_charge_soul_leave");
	e_fx playloopsound("zmb_squest_charge_soul_lp");
	playfxontag(localclientnum, level._effect["zombie_soul"], e_fx, "tag_origin");
	e_fx moveto(s_box.origin, 1);
	e_fx waittill("movedone");
	playsound(localclientnum, "zmb_squest_charge_soul_impact", e_fx.origin);
	playfxontag(localclientnum, level._effect["zombie_soul"], e_fx, "tag_origin");
	wait(0.3);
	e_fx delete();
}

function foot_print_box_glow(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump)
{
	self util::waittill_dobj(localclientnum);
	if(newval == 1)
	{
		if(!isdefined(self.fx_glow))
		{
			self.fx_glow = playfxontag(localclientnum, level._effect["foot_box_glow"], self, "tag_origin");
			self thread function_91953add(localclientnum);
		}
		if(!isdefined(self.sndent))
		{
			self.sndent = spawn(0, self.origin, "script_origin");
			self.sndent playloopsound("zmb_footprintbox_glow_lp", 1);
			self.sndent thread function_3a4d4e97();
		}
	}
	else
	{
		if(isdefined(self.fx_glow))
		{
			stopfx(localclientnum, self.fx_glow);
			self.fx_glow = undefined;
			self thread function_526683dc(localclientnum);
		}
		if(isdefined(self.sndent))
		{
			self.sndent delete();
			self.sndent = undefined;
		}
	}
}

function function_91953add(localclientnum)
{
	self endon("entityshutdown");
	self mapshaderconstant(localclientnum, 0, "ScriptVector1");
	s_timer = new_timer(localclientnum);
	n_phase_in = 1;
	do
	{
		util::server_wait(localclientnum, 0.11);
		n_current_time = s_timer get_time_in_seconds();
		n_delta_val = lerpfloat(1, 0, n_current_time / n_phase_in);
		self setshaderconstant(localclientnum, 0, n_delta_val, 0, 0, 0);
	}
	while(n_current_time < n_phase_in);
}

function function_526683dc(localclientnum)
{
	self endon("entityshutdown");
	self mapshaderconstant(localclientnum, 0, "ScriptVector1");
	s_timer = new_timer(localclientnum);
	n_phase_in = 1;
	do
	{
		util::server_wait(localclientnum, 0.11);
		n_current_time = s_timer get_time_in_seconds();
		n_delta_val = lerpfloat(0, 1, n_current_time / n_phase_in);
		self setshaderconstant(localclientnum, 0, n_delta_val, 0, 0, 0);
	}
	while(n_current_time < n_phase_in);
}

function new_timer(localclientnum)
{
	s_timer = spawnstruct();
	s_timer.n_time_current = 0;
	s_timer thread timer_increment_loop(localclientnum);
	return s_timer;
}

function function_3a4d4e97()
{
	self endon("entityshutdown");
	level waittill("demo_jump");
	self delete();
}

function get_time_in_seconds()
{
	return self.n_time_current;
}

function timer_increment_loop(localclientnum)
{
	while(isdefined(self))
	{
		util::server_wait(localclientnum, 0.016);
		self.n_time_current = self.n_time_current + 0.016;
	}
}