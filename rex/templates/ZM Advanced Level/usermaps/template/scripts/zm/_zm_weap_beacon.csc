#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\shared\system_shared;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

//#precache( "client_fx", "dlc5/tomb/fx_tomb_beacon_glow");
//#precache( "client_fx", "dlc5/tomb/fx_tomb_beacon_launch");
//#precache( "client_fx", "dlc5/tomb/fx_tomb_beacon_exp");
//#precache( "client_fx", "dlc5/tomb/fx_tomb_beacon_trail");

#namespace zm_weap_beacon;

REGISTER_SYSTEM( "zm_weap_beacon", &__init__, undefined )

function __init__()
{
	clientfield::register( "scriptmover", "play_beacon_fx", VERSION_SHIP, 1, "int", &beacon_beep, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "scriptmover", "play_artillery_barrage", VERSION_SHIP, 1, "int", &play_artillery_barrage, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	level.w_beacon = getweapon("zombie_beacon");
	level.var_67735adb = "wpn_t7_zmb_hd_g_strike_world";
	level._effect["beacon_glow"] = "dlc5/tomb/fx_tomb_beacon_glow";
	level._effect["beacon_launch_fx"] = "dlc5/tomb/fx_tomb_beacon_launch";
	level._effect["beacon_shell_explosion"] = "dlc5/tomb/fx_tomb_beacon_exp";
	level._effect["beacon_shell_trail"] = "dlc5/tomb/fx_tomb_beacon_trail";
}

function function_d391c94e(origin)
{
	playsound(0, "zmb_homingbeacon_missiile_alarm", origin);
	for(i = 0; i < 5; i++)
	{
		playsound(0, "zmb_homingbeacon_missile_fire", origin);
		wait(0.15);
	}
}

function beacon_beep(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump)
{
	self endon("hash_962e0148");
	while(isdefined(self))
	{
		playsound(0, "evt_beacon_beep", self.origin);
		playfxontag(localclientnum, level._effect["beacon_glow"], self, "origin_animate_jnt");
		wait(1.5);
	}
}

function play_artillery_barrage(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump)
{
	if(newval == 0)
	{
		return;
	}
	if(newval == 1)
	{
		if(!isdefined(self.a_v_land_offsets))
		{
			self.a_v_land_offsets = [];
		}
		if(!isdefined(self.a_v_land_offsets[localclientnum]))
		{
			self.a_v_land_offsets[localclientnum] = self build_weap_beacon_landing_offsets();
		}
		if(!isdefined(self.a_v_start_offsets))
		{
			self.a_v_start_offsets = [];
		}
		if(!isdefined(self.a_v_start_offsets[localclientnum]))
		{
			self.a_v_start_offsets[localclientnum] = self build_weap_beacon_start_offsets();
		}
	}
	if(!isdefined(self.var_f510f618))
	{
		self.var_f510f618 = [];
	}
	if(!isdefined(self.var_f510f618[localclientnum]))
	{
		self.var_f510f618[localclientnum] = 0;
	}
	n_index = self.var_f510f618[localclientnum];
	v_start = self.origin + self.a_v_start_offsets[localclientnum][n_index];
	shell = spawn(localclientnum, v_start, "script_model");
	shell.angles = vectorscale((-1, 0, 0), 90);
	shell setmodel("tag_origin");
	shell thread function_3700164e(self, n_index, v_start, localclientnum);
	self.var_f510f618[localclientnum]++;
}

function build_weap_beacon_landing_offsets()
{
	a_offsets = [];
	a_offsets[0] = (0, 0, 0);
	a_offsets[1] = vectorscale((-1, 1, 0), 72);
	a_offsets[2] = vectorscale((1, 1, 0), 72);
	a_offsets[3] = vectorscale((1, -1, 0), 72);
	a_offsets[4] = vectorscale((-1, -1, 0), 72);
	return a_offsets;
}

function build_weap_beacon_start_offsets()
{
	a_offsets = [];
	a_offsets[0] = vectorscale((0, 0, 1), 8500);
	a_offsets[1] = (-6500, 6500, 8500);
	a_offsets[2] = (6500, 6500, 8500);
	a_offsets[3] = (6500, -6500, 8500);
	a_offsets[4] = (-6500, -6500, 8500);
	return a_offsets;
}

function function_3700164e(model, index, v_start, localclientnum)
{
	var_89ea469b = model.origin + model.a_v_land_offsets[localclientnum][index];
	v_start_trace = v_start - vectorscale((0, 0, 1), 5000);
	trace = bullettrace(v_start_trace, var_89ea469b, 0, undefined);
	var_89ea469b = trace["position"];
	self moveto(var_89ea469b, 3);
	playfxontag(localclientnum, level._effect["beacon_shell_trail"], self, "tag_origin");
	self playsound(0, "zmb_homingbeacon_missile_boom");
	self thread function_42cb41ec(var_89ea469b);
	self waittill("movedone");
	if(index == 1)
	{
		model notify("hash_962e0148");
	}
	playfx(localclientnum, level._effect["beacon_shell_explosion"], self.origin);
	playsound(0, "wpn_rocket_explode", self.origin);
	self delete();
}

function function_42cb41ec(origin)
{
	wait(2);
	playsound(0, "zmb_homingbeacon_missile_incoming", origin);
}

