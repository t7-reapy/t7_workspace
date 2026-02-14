#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_equipment;
#using scripts\zm\zm_moon_gravity;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;

#precache("model", "c_t7_zm_dlchd_moon_pressuresuit_dempsey_mpc");
#precache("model", "c_t7_zm_dlchd_moon_pressuresuit_nikolai_mpc");
#precache("model", "c_t7_zm_dlchd_moon_pressuresuit_richtofen_mpc");
#precache("model", "c_t7_zm_dlchd_moon_pressuresuit_takeo_mpc");
#precache("model", "c_t7_zm_dlchd_moon_pressuresuit_body_mpc");

#namespace zm_equip_gasmask;

function autoexec __init__sytem__()
{
	system::register("zm_equip_gasmask", &__init__, &__main__, undefined);
}

function __init__()
{
	clientfield::register("toplayer", "gasp_rumble", 21000, 1, "int");
	clientfield::register("toplayer", "snd_lowgravity", 21000, 1, "int");
	clientfield::register("actor", "low_gravity", 21000, 1, "int");
	clientfield::register("toplayer", "gas_mask_buy", 21000, 1, "counter");
	clientfield::register("toplayer", "gas_mask_on", 21000, 1, "counter");
	clientfield::register("toplayer", "gasmaskoverlay", 21000, 1, "int");
	clientfield::register("clientuimodel", "hudItems.showDpadDown_PES", 21000, 1, "int");
	for(i = 0; i < 4; i++)
	{
		clientfield::register("world", ("player" + i) + "wearableItem", 21000, 1, "int");
	}

	zm_equipment::register("equip_gasmask", &"ZOMBIE_EQUIP_GASMASK_PICKUP_HINT_STRING", &"ZOMBIE_EQUIP_GASMASK_HOWTO", undefined, "gasmask");
	zm_equipment::register_slot_watcher_override("equip_gasmask", &function_7cb416b);
	visionset_mgr::register_info("overlay", "zm_gasmask_postfx", 21000, 501, 32, 1);
	callback::on_spawned(&on_player_spawned);
	level.var_f486078e = getweapon("equip_gasmask");
	level.zombiemode_gasmask_reset_player_model = &gasmask_reset_player_model;
	level.zombiemode_gasmask_reset_player_viewmodel = &gasmask_reset_player_set_viewmodel;
	level.zombiemode_gasmask_change_player_headmodel = &gasmask_change_player_headmodel;
	level.zombiemode_gasmask_set_player_model = &gasmask_set_player_model;
	level.zombiemode_gasmask_set_player_viewmodel = &gasmask_set_player_viewmodel;
	level.gasmask_currently_on = 0;
}

function __main__()
{
	zm_equipment::register_for_level("equip_gasmask");
	zm_equipment::register_for_level("lower_equip_gasmask");
	zm_equipment::include("equip_gasmask");
}

function on_player_spawned()
{
	self thread gasmask_removed_watcher_thread();
	self thread remove_gasmask_on_game_over();
	self thread gasmask_activation_watcher_thread();
	self thread function_4933258e();
	self thread remove_gasmask_on_player_bleedout();
	self clientfield::set_to_player("gasmaskoverlay", 0);
	visionset_mgr::deactivate("overlay", "zm_gasmask_postfx", self);
	self zm_equipment::set_equipment_invisibility_to_player(level.var_f486078e, 0);
	level thread mask_vox();
}

function mask_vox()
{
	zm_audio::loadPlayerVoiceCategories("gamedata/audio/zm/zm_moon_vox.csv");
	level thread init_level_specific_audio();
}

function init_level_specific_audio()
{
	level.vox zm_audio::zmbvoxadd("general", "start", "start", 100, 0);
	level.vox zm_audio::zmbvoxadd("general", "door_deny", "nomoney", 100, 0);
	level.vox zm_audio::zmbvoxadd("general", "perk_deny", "nomoney", 100, 0);
	level.vox zm_audio::zmbvoxadd("general", "no_money_weapon", "nomoney", 100, 0);
	level.vox zm_audio::zmbvoxadd("general", "astro_spawn", "spawn_astro", 100, 0);
	level.vox zm_audio::zmbvoxadd("general", "biodome", "location_biodome", 100, 0);
	level.vox zm_audio::zmbvoxadd("general", "jumppad", "jumppad", 100, 0);
	level.vox zm_audio::zmbvoxadd("general", "teleporter", "teleporter", 100, 0);
	level.vox zm_audio::zmbvoxadd("general", "hack_plr", "hack_plr", 100, 0);
	level.vox zm_audio::zmbvoxadd("general", "hack_vox", "hack_vox", 100, 0);
	level.vox zm_audio::zmbvoxadd("general", "airless", "location_airless", 100, 0);
	level.vox zm_audio::zmbvoxadd("general", "moonjump", "moonjump", 100, 0);
	level.vox zm_audio::zmbvoxadd("eggs", "meteors", "egg_pedastool", 100, 0);
	level.vox zm_audio::zmbvoxadd("eggs", "music_activate", "secret", 100, 0);
	level.vox zm_audio::zmbvoxadd("weapon_pickup", "microwave", "wpck_microwave", 100, 0);
	level.vox zm_audio::zmbvoxadd("weapon_pickup", "quantum", "wpck_quantum", 100, 0);
	level.vox zm_audio::zmbvoxadd("weapon_pickup", "gasmask", "wpck_gasmask", 100, 0);
	level.vox zm_audio::zmbvoxadd("weapon_pickup", "hacker", "wpck_hacker", 100, 0);
	level.vox zm_audio::zmbvoxadd("weapon_pickup", "grenade", "wpck_launcher", 100, 0);
	level.vox zm_audio::zmbvoxadd("kill", "micro_dual", "kill_micro_dual", 100, 0, 120);
	level.vox zm_audio::zmbvoxadd("kill", "micro_single", "kill_micro_single", 100, 0);
	level.vox zm_audio::zmbvoxadd("kill", "quant_good", "kill_quant_good", 10, 0);
	level.vox zm_audio::zmbvoxadd("kill", "quant_bad", "kill_quant_bad", 10, 0);
	level.vox zm_audio::zmbvoxadd("kill", "astro", "kill_astro", 100, 0);
	level.vox zm_audio::zmbvoxadd("digger", "incoming", "digger_incoming", 100, 0);
	level.vox zm_audio::zmbvoxadd("digger", "breach", "digger_breach", 100, 0);
	level.vox zm_audio::zmbvoxadd("digger", "hacked", "digger_hacked", 100, 0);
	level.vox zm_audio::zmbvoxadd("perk", "specialty_additionalprimaryweapon", "perk_arsenal", 100, 0);
	level.vox zm_audio::zmbvoxadd("player", "powerup", "bonus_points_solo", "powerup_pts_solo", 100, 0);
	level.vox zm_audio::zmbvoxadd("player", "powerup", "bonus_points_team", "powerup_pts_team", 100, 0);
	level.vox zm_audio::zmbvoxadd("player", "powerup", "lose_points", "powerup_antipts_zmb", 100, 0);
}

function gasmask_removed_watcher_thread()
{
	self notify("only_one_gasmask_removed_thread");
	self endon("only_one_gasmask_removed_thread");
	self endon("disconnect");
	for(;;)
	{
		self waittill("hash_5a02c845");
		if(isdefined(level.zombiemode_gasmask_reset_player_model))
		{
			ent_num = self.characterindex;
			if(isdefined(self.zm_random_char))
			{
				ent_num = self.zm_random_char;
			}
			self [[level.zombiemode_gasmask_reset_player_model]](ent_num);
		}
		if(isdefined(level.zombiemode_gasmask_reset_player_viewmodel))
		{
			ent_num = self.characterindex;
			if(isdefined(self.zm_random_char))
			{
				ent_num = self.zm_random_char;
			}
			self [[level.zombiemode_gasmask_reset_player_viewmodel]](ent_num);
		}
		self clientfield::set_player_uimodel("hudItems.showDpadDown_PES", 0);
		self clientfield::set_to_player("gasmaskoverlay", 0);
		visionset_mgr::deactivate("overlay", "zm_gasmask_postfx", self);
		level clientfield::set(("player" + self getentitynumber()) + "wearableItem", 0);
	}
}

function gasmask_activation_watcher_thread()
{
	self endon("zombified");
	self endon("disconnect");
	self notify("hash_b0734faa");
	self endon("hash_b0734faa");
	var_f499fcb0 = getweapon("lower_equip_gasmask");
	if(isdefined(level.zombiemode_gasmask_reset_player_model))
	{
		ent_num = self.characterindex;
		self [[level.zombiemode_gasmask_reset_player_model]](ent_num);
	}
	while(true)
	{
		str_notify = self util::waittill_any_return("equip_gasmask_activate", "equip_gasmask_deactivate", "disconnect");
		if(!self zm_equipment::has_player_equipment(level.var_f486078e))
		{
			continue;
		}
		if(self zm_equipment::is_active(level.var_f486078e))
		{
			self zm_utility::increment_is_drinking();
			self setactionslot(2, "");
			if(isdefined(level.zombiemode_gasmask_change_player_headmodel))
			{
				ent_num = self.characterindex;
				if(isdefined(self.zm_random_char))
				{
					ent_num = self.zm_random_char;
				}
				self [[level.zombiemode_gasmask_change_player_headmodel]](ent_num, 1);
			}
			self clientfield::increment_to_player("gas_mask_on");
			self waittill("weapon_change_complete");
			level clientfield::set(("player" + self getentitynumber()) + "wearableItem", 1);
			self clientfield::set_to_player("gasmaskoverlay", 1);
			visionset_mgr::activate("overlay", "zm_gasmask_postfx", self);
		}
		else
		{
			self zm_utility::increment_is_drinking();
			self setactionslot(2, "");
			if(isdefined(level.zombiemode_gasmask_change_player_headmodel))
			{
				ent_num = self.characterindex;
				if(isdefined(self.zm_random_char))
				{
					ent_num = self.zm_random_char;
				}
				self [[level.zombiemode_gasmask_change_player_headmodel]](ent_num, 0);
			}
			self takeweapon(level.var_f486078e);
			self giveweapon(var_f499fcb0);
			self switchtoweapon(var_f499fcb0);
			wait(0.05);
			self clientfield::set_to_player("gasmaskoverlay", 0);
			visionset_mgr::deactivate("overlay", "zm_gasmask_postfx", self);
			level clientfield::set(("player" + self getentitynumber()) + "wearableItem", 0);
			self waittill("weapon_change_complete");
			self takeweapon(var_f499fcb0);
			self giveweapon(level.var_f486078e);
		}
		if(!self laststand::player_is_in_laststand())
		{
			if(self zm_utility::is_multiple_drinking())
			{
				self zm_utility::decrement_is_drinking();
				self setactionslot(2, "weapon", level.var_f486078e);
				self notify("equipment_select_response_done");
				continue;
			}
			else
			{
				self zm_weapons::switch_back_primary_weapon(self.prev_weapon_before_equipment_change);
			}
		}
		self setactionslot(2, "weapon", level.var_f486078e);
		if(!self laststand::player_is_in_laststand() && (!(isdefined(self.intermission) && self.intermission)))
		{
			self zm_utility::decrement_is_drinking();
		}
		self notify("equipment_select_response_done");
	}
}

function function_4933258e()
{
	self notify("hash_17dade16");
	self endon("hash_17dade16");
	self endon("disconnect");
	while(true)
	{
		self waittill("player_given", equipment);
		if(equipment == level.var_f486078e)
		{
			self clientfield::set_player_uimodel("hudItems.showDpadDown_PES", 1);
		}
		if(isdefined(level.zombiemode_gasmask_set_player_model))
		{
			ent_num = self.characterindex;
			if(isdefined(self.zm_random_char))
			{
				ent_num = self.zm_random_char;
			}
			self [[level.zombiemode_gasmask_set_player_model]](ent_num);
			self clientfield::increment_to_player("gas_mask_buy");
		}
	}
}

function remove_gasmask_on_player_bleedout()
{
	self endon("disconnect");
	while(true)
	{
		self waittill("bled_out");
		self clientfield::set_player_uimodel("hudItems.showDpadDown_PES", 0);
		self clientfield::set_to_player("gasmaskoverlay", 0);
		visionset_mgr::deactivate("overlay", "zm_gasmask_postfx", self);
		level clientfield::set(("player" + self getentitynumber()) + "wearableItem", 0);
		self takeweapon(level.var_f486078e);
	}
}

function remove_gasmask_on_game_over()
{
	self endon("hash_5a02c845");
	level waittill("pre_end_game");
	if(isdefined(self))
	{
		self clientfield::set_to_player("gasmaskoverlay", 0);
		visionset_mgr::deactivate("overlay", "zm_gasmask_postfx", self);
	}
}

function gasmask_active()
{
	return self zm_equipment::is_active(level.var_f486078e);
}

function function_7cb416b(var_226f0a45, var_4bbe5bcf, var_d79c9dc0, str_notify)
{
	if(var_4bbe5bcf == var_226f0a45)
	{
		if(self.current_equipment_active[var_226f0a45] == 1)
		{
			self notify(str_notify.deactivate);
			self.current_equipment_active[var_226f0a45] = 0;
		}
		else if(self.current_equipment_active[var_226f0a45] == 0)
		{
			self notify(str_notify.activate);
			self.current_equipment_active[var_226f0a45] = 1;
		}
		self waittill("equipment_select_response_done");
	}
}

function function_5c35365f(players)
{
	foreach(player in players)
	{
		if(isdefined(player.characterindex) && player.characterindex == 2)
		{
			return true;
		}
	}
	return false;
}

function gasmask_get_head_model(entity_num, gasmask_active)
{
	if(gasmask_active)
	{
		return "c_zom_moon_pressure_suit_helm";
	}
	switch(entity_num)
	{
		case 0:
		{
			return "c_usa_dempsey_dlc5_head";
		}
		case 1:
		{
			return "c_rus_nikolai_dlc5_head_psuit";
		}
		case 2:
		{
			return "c_jap_takeo_dlc5_head";
		}
		case 3:
		{
			return "c_ger_richtofen_dlc5_head";
		}
	}
}

function gasmask_change_player_headmodel(entity_num, gasmask_active)
{
	if(gasmask_active)
	{
		self setcharacterhelmetstyle(1);
		self setcharacterbodystyle(2);
		gasmask_currently_on = 1;
	}
	else
	{
		self setcharacterbodystyle(1);
		self setcharacterhelmetstyle(0);
		self.gasmask_currently_on = 0;
	}
}

function gasmask_set_player_model(entity_num)
{
	self setcharacterbodystyle(1);
}

function gasmask_set_player_viewmodel(entity_num)
{
	self clientfield::increment_to_player("gas_mask_buy");
}

function gasmask_reset_player_model(entity_num)
{
	self setcharacterbodystyle(0);
}

function gasmask_reset_player_set_viewmodel(entity_num)
{
	gasmask_change_player_headmodel(entity_num, 0);
	self setcharacterbodystyle(0);
	level clientfield::set(("player" + self getentitynumber()) + "wearableItem", 0);
}

