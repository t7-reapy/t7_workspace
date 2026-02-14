#using scripts\shared\clientfield_shared;
#using scripts\shared\callbacks_shared; 
#using scripts\shared\array_shared;
#using scripts\shared\filter_shared;
#using scripts\shared\system_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\zm\_zm_utility;
#using scripts\zm\zm_moon_gravity;
#using scripts\zm\_zm_equipment;

#namespace zm_equip_gasmask;

function autoexec __init__sytem__()
{
	system::register("zm_equip_gasmask", &__init__, &__main__, undefined);
}

function __init__()
{
	zm_equipment::include("equip_gasmask");
	clientfield::register("toplayer", "gasp_rumble", 21000, 1, "int", &player_gasp_rumble, 0, 0);
	clientfield::register("toplayer", "snd_lowgravity", 21000, 1, "int", &zm_moon_gravity::function_20286238, 0, 0);
	clientfield::register("actor", "low_gravity", 21000, 1, "int", &zm_moon_gravity::zombie_low_gravity, 0, 0);
	clientfield::register("toplayer", "gas_mask_buy", 21000, 1, "counter", &function_7c00de2d, 0, 0);
	clientfield::register("toplayer", "gas_mask_on", 21000, 1, "counter", &function_29c0676c, 0, 0);
	clientfield::register("toplayer", "gasmaskoverlay", 21000, 1, "int", &gasmask_overlay_handler, 0, 0);
	clientfield::register("clientuimodel", "hudItems.showDpadDown_PES", 21000, 1, "int", undefined, 0, 0);

	for(i = 0; i < 4; i++)
	{
		registerclientfield("world", ("player" + i) + "wearableItem", 21000, 1, "int", &zm_utility::setsharedinventoryuimodels, 0);
	}
	
	visionset_mgr::register_overlay_info_style_postfx_bundle("zm_gasmask_postfx", 21000, 32, "pstfx_moon_helmet", 3);
}

function __main__()
{
	level thread function_73cc64f1(0);
}

function function_7c00de2d(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump)
{
	playsound(localclientnum, "evt_gasmask_suit_on", self.origin);
}

function function_29c0676c(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump)
{
	playsound(localclientnum, "evt_gasmask_on_v2", self.origin);
}

function function_73cc64f1(localclientnum)
{
	level.var_98cd8f08 = [];
	level.var_98cd8f08[1] = "c_t7_zm_dlchd_moon_pressuresuit_dempsey_mpc";
	level.var_98cd8f08[2] = "c_t7_zm_dlchd_moon_pressuresuit_nikolai_mpc";
	level.var_98cd8f08[3] = "c_t7_zm_dlchd_moon_pressuresuit_richtofen_mpc";
	level.var_98cd8f08[4] = "c_t7_zm_dlchd_moon_pressuresuit_takeo_mpc";
	lock_model("c_t7_zm_dlchd_moon_pressuresuit_body_mpc");
	foreach(player in getplayers(localclientnum))
	{
		player thread function_c06d0a4e(localclientnum);
	}
	callback::on_spawned(&function_c06d0a4e);
}

function function_c06d0a4e(localclientnum)
{
	self endon("entityshutdown");
	self util::waittill_dobj(localclientnum);
	while(isdefined(self) && !isdefined(self.player_exert_id))
	{
		wait(1);
	}
	if(isdefined(self) && isdefined(self.player_exert_id))
	{
		lock_model(level.var_98cd8f08[self.player_exert_id]);
	}
}

function lock_model(model)
{
	if(isdefined(model))
	{
		if(!isdefined(level.model_locks))
		{
			level.model_locks = [];
		}
		if(!isdefined(level.model_locks[model]))
		{
			level.model_locks[model] = 0;
		}
		if(level.model_locks[model] < 1)
		{
			forcestreamxmodel(model);
		}
		level.model_locks[model]++;
	}
}

function gasmask_overlay_handler(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump)
{
	if(!self islocalplayer() || isspectating(localclientnum, 0) || (isdefined(level.localplayers[localclientnum]) && self getentitynumber() != level.localplayers[localclientnum] getentitynumber()))
	{
		return;
	}
	if(newval)
	{
		if(!isdefined(self.var_cf129735))
		{
			self.var_cf129735 = self playloopsound("evt_gasmask_loop", 0.5);
		}
	}
	else if(isdefined(self.var_cf129735))
	{
		self stoploopsound(self.var_cf129735, 0.5);
		self.var_cf129735 = undefined;
	}
}

function player_gasp_rumble(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump)
{
	if(!self islocalplayer())
	{
		return;
	}
	if(!isdefined(self getlocalclientnumber()))
	{
		return;
	}
	if(newval)
	{
		if(randomint(100) > 70)
		{
			self playrumbleonentity(localclientnum, "damage_light");
		}
		else
		{
			self playrumbleonentity(localclientnum, "damage_heavy");
		}
	}
}