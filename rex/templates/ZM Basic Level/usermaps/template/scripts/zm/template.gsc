#using scripts\shared\flag_shared;
#using scripts\zm\_zm_zonemgr;
#using scripts\zm\_zm_weapons;
#using scripts\zm\zm_usermap;

function main()
{

    level._zombie_custom_add_weapons =&custom_add_weapons;

	level.dog_rounds_allowed = 0;
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

    // Setup the levels Zombie Zone Volumes
    init_zones = [];
    level.zone_manager_init_func =&template_zone_init;
    init_zones[0] = "start_zone";
    init_zones[1] = "zone_01";
    level thread zm_zonemgr::manage_zones( init_zones );
}

function template_zone_init()
{
    level flag::init( "always_on" );
    level flag::set( "always_on" );
}

function custom_add_weapons()
{
	zm_weapons::load_weapon_spec_from_table("gamedata/weapons/zm/template.csv", 1);
}
