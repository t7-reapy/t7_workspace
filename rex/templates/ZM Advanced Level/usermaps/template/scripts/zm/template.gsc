#using scripts\codescripts\struct;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\_zm_utility.gsh;

#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_zonemgr;

#using scripts\zm\zm_usermap;

//*****************************************************************************
// MAIN
//*****************************************************************************

function main()
{
	
	level._zombie_custom_add_weapons =&custom_add_weapons;

	level.dog_rounds_allowed = 0;
	level.mixed_dog_rounds = true;
	level.special_monkey_rounds = false;
	level.temple_monkey = false;
	level.random_pandora_box_start = true;
	level.timed_gameplay = false;
	level.enable_hitmakers = false;
	level.enable_zm_vox = true;
	level.enable_portals = true;
	level.enable_firesale = true;
	level.enable_all_characters = false;
	level.keep_perks = false;
	level.enable_dvars = true;

	zm_usermap::main();

	// Change your starting weapon here
	startingWeapon = "pistol_standard";
	weapon = getWeapon(startingWeapon);
	level.start_weapon = (weapon);

	 // Starting Points
	level.player_starting_points = 50000;

	// Perk Limit
	level.perk_purchase_limit = 20;

	//Pack a Punch Camos
	level.pack_a_punch_camo_index = 121;
	level.pack_a_punch_camo_index_number_variants = 5;
	
	//Setup the levels Zombie Zone Volumes
	init_zones = [];
	level.zone_manager_init_func =&template_zone_init;
	init_zones[0] = "start_zone";
	init_zones[1] = "zone_01";
	init_zones[2] = "zone_02";
	init_zones[3] = "zone_03";
	init_zones[4] = "zone_04";
	init_zones[5] = "zone_05";
	init_zones[6] = "zone_06";
	init_zones[7] = "receiver_zone";
	level thread zm_zonemgr::manage_zones( init_zones );
}

function template_zone_init()
{
	level flag::init( "always_on" );
	level flag::set( "always_on" );

	zm_zonemgr::add_adjacent_zone("zone_02", "zone_03", "enter_zone_02" );
}

function custom_add_weapons()
{
	zm_weapons::load_weapon_spec_from_table("gamedata/weapons/zm/template.csv", 1);
}
