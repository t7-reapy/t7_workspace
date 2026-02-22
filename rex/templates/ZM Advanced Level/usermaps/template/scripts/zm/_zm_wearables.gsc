#using scripts\codescripts\struct;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\flagsys_shared;
#using scripts\shared\system_shared;
#using scripts\shared\trigger_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_equipment;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_unitrigger;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\craftables\_zm_craftables;

#using_animtree("generic");

#namespace zm_wearables;

function autoexec __init__sytem__()
{
	system::register("zm_wearables", &__init__, undefined, undefined);
}

function __init__()
{
	/*
	clientfield::register("clientuimodel", "zmInventory.wearable_perk_icons", 15000, 2, "int");
	zm_spawner::register_zombie_death_event_callback(&function_9d85b9ce);
	zm_spawner::register_zombie_damage_callback(&function_cb27f92e);
	for(i = 0; i < 4; i++)
	{
		registerclientfield("world", ("player" + i) + "wearableItem", 15000, 4, "int");
	}
	*/
	level thread Weasels_Quest();
	level thread Direwolf_Quest();
	level thread Margwa_Quest();
	level thread Fury_Quest();
	level thread Siegfried_Quest();
	level thread Kings_Quest();
	level thread Keepers_Quest();
	level thread Apothigod_Quest();
	level thread Dragon_Quest();
	level thread Raz_Quest();
	level thread Sentinel_Quest();
}

function function_2436f867()
{
	self notify("hash_2436f867");
	self endon("hash_2436f867");
	self util::waittill_any("disconnect", "bled_out", "death");
	self.Helmet = undefined;
	//function_b712ee6f(0);
	//function_30fb8e63(0);
}

function function_b712ee6f(var_908867a0)
{
	level clientfield::set(("player" + self.entity_num) + "wearableItem", var_908867a0);
}

function function_30fb8e63(n_perks)
{
	self clientfield::set_player_uimodel("zmInventory.wearable_perk_icons", n_perks);
}

function Helmet_Handler(var_8fca9f8c, var_f48b681c, str_tag, var_f3776824)
{
	s_loc = struct::get(var_8fca9f8c, "targetname");
	level.var_6d65545f = spawn("script_model", s_loc.origin);
	level.var_6d65545f.angles = s_loc.angles;
	level.var_6d65545f setmodel(var_f48b681c);
	var_750a9baa = s_loc zm_unitrigger::create_unitrigger(&"ZM_GENESIS_WEARABLE_PICKUP", undefined, &Helmet_Trigger_String, &Helmet_Struct);
	var_750a9baa.str_helmet = var_f48b681c;
	var_750a9baa.str_tag = str_tag;
	var_750a9baa.wearable = var_8fca9f8c;
	v_offset = (0, 0, var_f3776824);
	var_750a9baa.origin = var_750a9baa.origin + v_offset;
	zm_unitrigger::unitrigger_force_per_player_triggers(var_750a9baa, 1);
}

function Helmet_Trigger_String(e_player)
{
	if(isdefined(e_player.Helmet) && e_player.Helmet.str_model === self.stub.str_helmet)
	{
		self sethintstring(&"ZM_GENESIS_WEARABLE_EQUIPPED");
		return false;
	}
	self sethintstring(&"ZM_GENESIS_WEARABLE_PICKUP");
	return true;
}

function Helmet_Struct()
{
	self endon("death");
	while(true)
	{
		self trigger::wait_till();
		e_player = self.who;
		if(!isdefined(e_player.Helmet))
		{
			e_player.Helmet = spawnstruct();
		}
		e_player Take_Off_Helmet();
		str_tag = self.stub.str_tag;
		wearable = self.stub.wearable;
		e_player Put_On_Helmet(self.stub.str_helmet, wearable, str_tag);
	}
}

function Put_On_Helmet(str_model, wearable, str_tag)
{
	self alt_character();
	self.Helmet.str_model = str_model;
	self.Helmet.str_tag = str_tag;
	self attach(self.Helmet.str_model, str_tag);
	self playsound("zmb_craftable_pickup");
	self notify("changed_wearable", wearable);
	self thread function_2436f867();
	switch(wearable)
	{
		case "s_weasels_hat":
		{
			self playsound("zmb_wearable_weasel_wear");
			//self function_b712ee6f(1);
			//self function_30fb8e63(0);
			break;
		}
		/*
		case "s_helm_of_siegfried":
		{
			self playsound("zmb_wearable_siegfried_wear");
			self.n_player_health_boost = 45;
			self zm_perks::perk_set_max_health_if_jugg("health_reboot", 0, 0);
			self function_b712ee6f(2);
			self function_30fb8e63(2);
			break;
		}
		*/
		case "s_helm_of_the_king":
		{
			self playsound("zmb_wearable_mechz_wear");
			/*
			self.var_e1384d1e = 0.5;
			self.var_ad21546 = 0.5;
			self.n_margwa_head_damage_scale = 1.33;
			self.var_bbd3efb8 = 1.33;
			self.var_fd3f1056 = 1;
			*/
			self setperk("specialty_tombstone");
			//self function_b712ee6f(4);
			//self function_30fb8e63(1);
			break;
		}
		case "s_dire_wolf_head":
		{
			self playsound("zmb_wearable_wolf_wear");
			self setperk("specialty_tombstone");
			//self function_b712ee6f(7);
			//self function_30fb8e63(1);
			break;
		}
		case "s_dragon_wings":
		{
			self playsound("zmb_wearable_wing_wear");
			//self function_b712ee6f(7);
			//self function_30fb8e63(1);
			break;
		}
		case "s_raz_hat":
		{
			self playsound("zmb_wearable_raz_success");
			//self function_b712ee6f(7);
			//self function_30fb8e63(1);
			break;
		}
		case "s_margwa_head":
		{
			self playsound("zmb_wearable_margwa_wear");
			//self.var_e1384d1e = 0.5;
			//self.n_margwa_head_damage_scale = 1.33;
			self setperk("specialty_tombstone");
			//self function_b712ee6f(6);
			//self function_30fb8e63(1);
			break;
		}
		/*
		case "s_keeper_skull_head":
		{
			self playsound("zmb_wearable_keeper_wear");
			self.n_player_health_boost = 45;
			self zm_perks::perk_set_max_health_if_jugg("health_reboot", 0, 0);
			self.var_e7f63e2e = 30;
			self.var_ebafd972 = 0.5;
			self.var_74fe492b = 1;
			self function_b712ee6f(5);
			self function_30fb8e63(2);
			break;
		}
		*/
		//case "s_apothicon_mask":
		{
			self playsound("zmb_wearable_apothigod_wear");
			//self.var_e8e8daad = 1;
			//self.var_bcff1de = 1;
			//self.n_margwa_head_damage_scale = 1.5;
			//self.var_bbd3efb8 = 1.5;
			self setperk("specialty_tombstone");
			self.n_player_health_boost = 45;
			self zm_perks::perk_set_max_health_if_jugg("health_reboot", 0, 0);
			//self function_b712ee6f(3);
			//self function_30fb8e63(3);
			break;
		}
		/*
		case "s_fury_head":
		{
			self playsound("zmb_wearable_fury_wear");
			self.var_eef0616b = 0.66;
			self.var_15c79ed8 = 1;
			self.n_player_health_boost = 45;
			self zm_perks::perk_set_max_health_if_jugg("health_reboot", 0, 0);
			self function_b712ee6f(8);
			self function_30fb8e63(2);
			break;
		}
		*/
	}
}

function alt_character()
{
	alt_character = self getcharacterbodymodel();
	switch(alt_character)
	{
		case "c_zom_dlc3_nikolai_mpc_fb":
		{
			self setcharacterbodystyle(2);
			break;
		}
		case "c_zom_dlc3_takeo_mpc_fb":
		{
			self setcharacterbodystyle(2);
			break;
		}
	}
}

function Take_Off_Helmet()
{
	self notify("hash_baf651e0");
	self.var_e8e8daad = undefined;
	self.var_bcff1de = undefined;
	self.var_e1384d1e = undefined;
	self.var_ad21546 = undefined;
	self.n_margwa_head_damage_scale = undefined;
	self.var_bbd3efb8 = undefined;
	self.var_e7f63e2e = undefined;
	self.var_ebafd972 = undefined;
	self.b_no_trap_damage = undefined;
	self.var_74fe492b = undefined;
	self.var_adaec269 = undefined;
	self.var_fd3f1056 = undefined;
	self.var_eef0616b = undefined;
	self.var_15c79ed8 = undefined;
	self.n_player_health_boost = undefined;
	self zm_perks::perk_set_max_health_if_jugg("health_reboot", 0, 0);
	if(self hasperk("specialty_tombstone"))
	{
		self unsetperk("specialty_tombstone");
	}
	if(isdefined(self.Helmet.str_model))
	{
		self detach(self.Helmet.str_model, self.Helmet.str_tag);
	}
}

function Weasels_Quest()
{
	level waittill("all_players_spawned");
	Helmet_Handler("s_weasels_hat", "c_zom_dlc4_player_arlington_helmet", "j_head", 0);
}

function Siegfried_Quest()
{
	playsoundatposition("zmb_wearable_siegfried_horn_1", (0, 0, 0));
	Helmet_Handler("s_helm_of_siegfried", "c_zom_dlc4_player_siegfried_helmet", "j_head", 0);
}

function Kings_Quest()
{
	level flag::init("Kings_Quest_Step_01");
	level flag::init("Kings_Quest_Step_02");
	level flag::init("Kings_Quest_Step_03");
	level thread margwa_quest_step_01("Kings_Quest_Step_01");
	level thread margwa_quest_step_02("Kings_Quest_Step_02", "Kings_Quest_Step_03");
	level thread margwa_quest_step_03("Kings_Quest_Step_03", "Kings_Quest_Step_02");
	level flag::wait_till_all(array("Kings_Quest_Step_01", "Kings_Quest_Step_02", "Kings_Quest_Step_03"));
	playsoundatposition("zmb_wearable_mechz_complete", (0, 0, 0));
	Helmet_Handler("s_helm_of_the_king", "c_zom_dlc4_player_king_helmet", "j_head", 0);
}

function Kings_Quest_Step_01(str_flag)
{
	level flag::set(str_flag);
	//do something
	wait (1);
	level notify("kings_quest_step_01_complete");
}

function Kings_Quest_Step_02(str_flag, quest_step)
{
	level waittill("kings_quest_step_01_complete");
	//do something
	wait (1);
	level notify("kings_quest_step_02_complete");
	level flag::set(str_flag);
}

function Kings_Quest_Step_03(str_flag, quest_step)
{
	level waittill("kings_quest_step_02_complete");
	//do something
	wait (1);
	level flag::set(str_flag);
}

function Kings_Quest_Sound_Complete()
{
	playsoundatposition("zmb_wearable_mechz_step", (0, 0, 0));
}

function Direwolf_Quest()
{
	level flag::init("direwolf_quest_step_01");
	level flag::init("direwolf_quest_step_02");
	level thread direwolf_quest_step_01("direwolf_quest_step_01");
	level thread direwolf_quest_step_02("direwolf_quest_step_02");
	level flag::wait_till_all(array("direwolf_quest_step_01", "direwolf_quest_step_02"));

	//playsoundatposition("zmb_wearable_wolf_howl_finish", (0, 0, 0));
	Helmet_Handler("s_dire_wolf_head", "c_zom_dlc4_player_direwolf_helmet", "j_head", 0);
}

function direwolf_quest_step_01(str_flag)
{
	level flag::set(str_flag);
	//do something
	wait (1);
	level notify("direwolf_quest_step_01_complete");
}

function direwolf_quest_step_02(str_flag)
{
	level waittill("direwolf_quest_step_01_complete");
	//do something
	wait (1);
	level flag::set(str_flag);
}

function Dragon_Quest()
{
	level flag::init("Dragon_Quest_Step_01");
	level flag::init("Dragon_Quest_Step_02");
	level thread Dragon_Quest_Step_01("Dragon_Quest_Step_01");
	level thread Dragon_Quest_Step_02("Dragon_Quest_Step_02");
	level flag::wait_till_all(array("Dragon_Quest_Step_01", "Dragon_Quest_Step_02"));

	//playsoundatposition("zmb_wearable_wolf_howl_finish", (0, 0, 0));
	Helmet_Handler("s_dragon_wings", "c_zom_dlc3_player_wings", "j_spine4", 0);
}

function Dragon_Quest_Step_01(str_flag)
{
	level flag::set(str_flag);
	//do something
	wait (1);
	level notify("Dragon_Quest_Step_01_Complete");
}

function Dragon_Quest_Step_02(str_flag)
{
	level waittill("Dragon_Quest_Step_01_Complete");
	//do something
	wait (1);
	level flag::set(str_flag);
}


function Keepers_Quest()
{
	level flag::init("Keepers_Quest_01");
	level flag::init("Keepers_Quest_02");
	level thread Keepers_Quest_Step_01("Keepers_Quest_01");
	level thread Keepers_Quest_Step_02("Keepers_Quest_02");
	level.var_1c301ed2 = 1;
	level flag::wait_till_all(array("Keepers_Quest_01", "Keepers_Quest_02"));
	level.var_1c301ed2 = 0;

	playsoundatposition("zmb_wearable_keeper_complete", (0, 0, 0));
	Helmet_Handler("s_keeper_skull_head", "c_zom_dlc4_player_keeper_helmet", "j_head", 0);
}

function Keepers_Quest_Step_01(str_flag)
{
	level flag::set(str_flag);
}

function Keepers_Quest_Step_02(str_flag)
{
	playsoundatposition("zmb_wearable_keeper_step", (0, 0, 0));
	level flag::set(str_flag);
}

function Margwa_Quest()
{
	level flag::init("margwa_head_quest_step_01");
	level flag::init("margwa_head_quest_step_02");
	level flag::init("margwa_head_quest_step_03");
	level thread margwa_quest_step_01("margwa_head_quest_step_01");
	level thread margwa_quest_step_02("margwa_head_quest_step_02", "margwa_head_quest_step_03");
	level thread margwa_quest_step_03("margwa_head_quest_step_03", "margwa_head_quest_step_02");
	level.var_16f4dfa5 = 1;
	level flag::wait_till_all(array("margwa_head_quest_step_01", "margwa_head_quest_step_02", "margwa_head_quest_step_03"));
	level.var_16f4dfa5 = 0;

	playsoundatposition("zmb_wearable_margwa_complete", (0, 0, 0));
	Helmet_Handler("s_margwa_head", "c_zom_dlc4_player_margwa_helmet", "j_head", 0);
}

function margwa_quest_step_01(str_flag)
{
	level flag::set(str_flag);
	//do something
	wait (1);
	level notify("margwa_quest_step_01_complete");
}

function margwa_quest_step_02(str_flag, quest_step)
{
	level waittill("margwa_quest_step_01_complete");
	//do something
	wait (1);
	level notify("margwa_quest_step_02_complete");
	level flag::set(str_flag);
}

function margwa_quest_step_03(str_flag, quest_step)
{
	level waittill("margwa_quest_step_02_complete");
	//do something
	wait (1);
	level flag::set(str_flag);
}

function function_838522a5()
{
	playsoundatposition("zmb_wearable_margwa_step", (0, 0, 0));
}

function Apothigod_Quest()
{
	level flag::init("apothicon_mask_step_01");
	level flag::init("apothicon_mask_step_02");
	level flag::init("apothicon_mask_step_02");
	level thread Apothigod_Requirements_01("apothicon_mask_step_01");
	level thread Apothigod_Requirements_02("apothicon_mask_step_02");
	level thread Apothigod_Requirements_03("apothicon_mask_step_03");
	level.var_26af7b39 = 1;
	level flag::wait_till_all(array("apothicon_mask_step_01", "apothicon_mask_step_02", "apothicon_mask_step_03"));
	level.var_26af7b39 = 0;

	playsoundatposition("zmb_wearable_apothigod_complete", (0, 0, 0));
	Helmet_Handler("s_apothicon_mask", "c_zom_dlc4_player_apothican_helmet", "j_head", -30);
}


function Apothigod_Requirements_01(god_requirements)
{
	level flag::set(god_requirements);
	level thread god_step_complete_sound();
}

function Apothigod_Requirements_02(god_requirements)
{
	level flag::set(god_requirements);
	level thread god_step_complete_sound();
}

function Apothigod_Requirements_03(god_requirements)
{
	level flag::set(god_requirements);
	level thread god_step_complete_sound();
}

function god_step_complete_sound()
{
	playsoundatposition("zmb_wearable_apothigod_step", (0, 0, 0));
}

function Fury_Quest()
{
	level flag::init("fury_head_quest_step_01");
	level flag::init("fury_head_quest_step_02");
	level flag::init("fury_head_quest_step_03");
	level thread fury_quest_step_01("fury_head_quest_step_01");
	level thread fury_quest_step_02("fury_head_quest_step_02", "fury_head_quest_step_03");
	level thread fury_quest_step_03("fury_head_quest_step_03", "fury_head_quest_step_02");
	level.var_16f4dfa5 = 1;
	level flag::wait_till_all(array("fury_head_quest_step_01", "fury_head_quest_step_02", "fury_head_quest_step_03"));
	level.var_16f4dfa5 = 0;

	playsoundatposition("zmb_wearable_fury_complete", (0, 0, 0));
	Helmet_Handler("s_fury_head", "c_zom_dlc4_player_fury_helmet", "j_head", -30);
}

function fury_quest_step_01(str_flag)
{
	level flag::set(str_flag);
	//do something
	wait (1);
	level notify("fury_quest_step_01_complete");
}

function fury_quest_step_02(str_flag, quest_step)
{
	level waittill("fury_quest_step_01_complete");
	//do something
	wait (1);
	level notify("fury_quest_step_02_complete");
	level flag::set(str_flag);
}

function fury_quest_step_03(str_flag, quest_step)
{
	level waittill("fury_quest_step_02_complete");
	//do something
	wait (1);
	level flag::set(str_flag);
}

function Raz_Quest()
{
	playsoundatposition("wearables_raz_mask_complete", (0, 0, 0));
	Helmet_Handler("s_raz_hat", "c_zom_dlc3_player_raz_facemask", "j_head", 0);
}

function Sentinel_Quest()
{
	playsoundatposition("c_zom_dlc3_player_sentinel_drone_hat", (0, 0, 0));
	Helmet_Handler("s_sentinel_hat", "c_zom_dlc3_player_sentinel_drone_hat", "j_head", 0);
}