#using scripts\codescripts\struct;
#using scripts\shared\audio_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_load;
#using scripts\zm\_zm_weapons;

//Perks
#using scripts\zm\_zm_pack_a_punch;
#using scripts\zm\_zm_perk_additionalprimaryweapon;
#using scripts\zm\_zm_perk_doubletap2;
#using scripts\zm\_zm_perk_deadshot;
#using scripts\zm\_zm_perk_juggernaut;
#using scripts\zm\_zm_perk_quick_revive;
#using scripts\zm\_zm_perk_sleight_of_hand;
#using scripts\zm\_zm_perk_staminup;

//Powerups
#using scripts\zm\_zm_powerup_double_points;
#using scripts\zm\_zm_powerup_carpenter;
#using scripts\zm\_zm_powerup_fire_sale;
#using scripts\zm\_zm_powerup_free_perk;
#using scripts\zm\_zm_powerup_full_ammo;
#using scripts\zm\_zm_powerup_insta_kill;
#using scripts\zm\_zm_powerup_nuke;

//Traps
#using scripts\zm\_zm_trap_electric;

#using scripts\zm\zm_usermap;

function main()
{
	visions = array("blinded", "charred", "cheat_bw", "concussion_grenade", "core_frontend", "core_movement_swimming", "cp_raven_hallucination", "cp_zurich_hallucination", "creek_1", "creek_1_tunnel", "creek_1_tunnel_off", "death", "default", "drown", "flare", "flashbang", "flash_grenade", "heatwave", "infrared", "infrared_snow", "int_frontend_char_trans", "low_health", "mpintro", "mpoutro", "mp_ability_resurrection", "mp_ability_wakeup", "mp_apartments", "mp_array", "mp_chinatown", "mp_cracked", "mp_havoc", "mp_hellstorm", "mp_mountain", "mp_nuked", "mp_nuked2", "mp_sector", "mp_spire", "mp_vehicles_agr", "mp_vehicles_dart", "mp_vehicles_mothership", "mp_vehicles_sentinel", "mp_vehicles_turret", "neutral", "oed", "optic_camo_01", "overdrive_initialize", "remote_mortar_enhanced", "remote_mortar_infrared", "speed_burst_initialize", "spiki_whoswho", "spiki_whoswho_rage", "tac_mode_blue", "taser_mine_shock", "tvguided_mp", "tvguided_sp", "vehicle_hijack_blur", "vehicle_transition", "vision_puls_bw", "vtol", "zm_ash_nuke", "zm_bgb_candy_bluez", "zm_bgb_candy_bluez2", "zm_bgb_candy_greenz", "zm_bgb_candy_purplez", "zm_bgb_candy_yellowz", "zm_bgb_in_plain_sight", "zm_bgb_now_you_see_me", "zm_bloodwash_red", "zm_chaos_organge", "zm_elemental_round_visionset", "zm_factory", "zm_gray", "zm_idgun_vortex", "zm_isl_parasite_spider", "zm_isl_parasite_spider", "zm_isl_thrasher_stomach", "zm_sentinel_round_visionset", "zm_tomb_in_plain_sight", "zm_vulture_aid_stink", "zm_wasp_round_visionset", "zm_whos_who", "zm_whos_who_dark", "zod_ritual_dim", "zombie", "zombie_beast_2", "zombie_black_hole", "zombie_cosmodrome_blackhole", "zombie_cosmodrome_divetonuke", "zombie_cosmodrome_monkey", "zombie_cosmodrome_nopower", "zombie_cosmodrome_power_antic", "zombie_cosmodrome_power_flare", "zombie_death", "zombie_last_stand", "zombie_noire", "zombie_turned");

	foreach(vision in visions)
	{
		visionset_mgr::register_visionset_info(vision, VERSION_SHIP, 1, undefined, vision);
	}

	zm_usermap::main();

	include_weapons();
	
	util::waitforclient( 0 );
}

function include_weapons()
{
	zm_weapons::load_weapon_spec_from_table("gamedata/weapons/zm/zm_levelcommon_weapons.csv", 1);
}
