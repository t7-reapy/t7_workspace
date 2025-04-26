#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\compass;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\_zm_utility.gsh;

#using scripts\zm\_load;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_zonemgr;

#using scripts\shared\ai\zombie_utility;

//Perks
#using scripts\zm\_zm_pack_a_punch;
#using scripts\zm\_zm_pack_a_punch_util;
#using scripts\zm\_zm_perk_quick_revive;
#using scripts\zm\_zm_perk_doubletap2;
#using scripts\zm\_zm_perk_juggernaut;
#using scripts\zm\_zm_perk_sleight_of_hand;
#using scripts\zm\_zm_perk_deadshot;
#using scripts\zm\_zm_perk_staminup;
#using scripts\zm\_zm_perk_phdflopper;
#using scripts\zm\_zm_perk_additionalprimaryweapon;
#using scripts\zm\_zm_perk_tombstone;
#using scripts\zm\_zm_perk_whoswho;
#using scripts\zm\_zm_perk_vulture_aid;
#using scripts\zm\_zm_perk_electric_cherry;
#using scripts\zm\_zm_perk_widows_wine;
#using scripts\zm\_zm_perk_elemental_pop;
#using scripts\zm\_zm_perk_random;

//Powerups
#using scripts\zm\_zm_powerup_double_points;
#using scripts\zm\_zm_powerup_carpenter;
#using scripts\zm\_zm_powerup_fire_sale;
#using scripts\zm\_zm_powerup_free_perk;
#using scripts\zm\_zm_powerup_full_ammo;
#using scripts\zm\_zm_powerup_insta_kill;
#using scripts\zm\_zm_powerup_nuke;
//#using scripts\zm\_zm_powerup_weapon_minigun;

//Traps
#using scripts\zm\_zm_trap_electric;

#using scripts\zm\zm_usermap;

//*****************************************************************************
// MAIN
//*****************************************************************************

function main()
{	
	level.dog_rounds_allowed = 0;
	
	zm_usermap::main();
	
	//DEBUG
	level.player_starting_points = 500000;
	level.perk_purchase_limit = 14;
	
	level.pack_a_punch_camo_index = 133;
	level.pack_a_punch_camo_index_number_variants = 1;
	
	level._zombie_custom_add_weapons =&custom_add_weapons;
	
	//Setup the levels Zombie Zone Volumes
	level.zones = [];
	level.zone_manager_init_func =&usermap_test_zone_init;
	init_zones[0] = "start_zone";
	level thread zm_zonemgr::manage_zones( init_zones );

	level.pathdist_type = PATHDIST_ORIGINAL;
	
	// thread loop_waypoint();
	
	
}

function usermap_test_zone_init()
{
	level flag::init( "always_on" );
	level flag::set( "always_on" );
}	

function custom_add_weapons()
{
	zm_weapons::load_weapon_spec_from_table("gamedata/weapons/zm/zm_levelcommon_weapons.csv", 1);
}

























function loop_waypoint()
{
	while ( 1 )
	{
		Objective_Add(0, "active", (0, 0, 0), istring("waypoint_vulture"));
		
		// Objective_SetProgress(0,0.5);
		Objective_SetVisibleToAll(0);
		Objective_Add(1, "active", (100, 0, 0), istring("waypoint_vulture"));
		Objective_SetVisibleToAll(1);
		Objective_Add(2, "active", (-100, 0, 0), istring("waypoint_vulture"));
		Objective_SetVisibleToAll(2);
		wait 1;
		break;
	}
}