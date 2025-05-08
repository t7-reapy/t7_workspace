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
//#using scripts\zm\_zm_powerup_weapon_minigun;

//Traps
#using scripts\zm\_zm_trap_electric;

// Weather
#using scripts\zm\weather\zm_weather;

#using scripts\zm\zm_usermap;

function main()
{
	zm_usermap::main();
	map_init();
	zm_weather::play();

	// Triggers for testing
	ent_triggers_greater = GetEntArray("trigger_greater_intensity", "targetname");
	array::thread_all(ent_triggers_greater, &monitor_trigger_greater_intensity);
	
	ent_triggers_lesser = GetEntArray("trigger_lesser_intensity", "targetname");
	array::thread_all(ent_triggers_lesser, &monitor_trigger_lesser_intensity);
	
	ent_triggers_pause = GetEntArray("trigger_play_pause", "targetname");
	array::thread_all(ent_triggers_pause, &monitor_trigger_play_pause);
}

function monitor_trigger_greater_intensity()
{
	// self == trigger_use
	self SetHintString("Hold ^3[{+activate}]^7 to increase weather intensity");

	while(true)
	{
		self waittill("trigger");
		zm_weather::greater_intensity();
	}
}

function monitor_trigger_lesser_intensity()
{
	// self == trigger_use
	self SetHintString("Hold ^3[{+activate}]^7 to lower down weather intensity");

	while(true)
	{
		self waittill("trigger");
		zm_weather::lesser_intensity();
	}
}

function monitor_trigger_play_pause()
{
	// self == trigger_use
	self SetHintString("Hold ^3[{+activate}]^7 to play or pause weather");

	while(true)
	{
		self waittill("trigger");
		zm_weather::pause();
		self waittill("trigger");
		zm_weather::play();
	}
}

//*****************************************************************************
// INIT
//*****************************************************************************

function map_init() {
	level util::set_lighting_state(0);
	
	level._zombie_custom_add_weapons =& custom_add_weapons;
	
	//Setup the levels Zombie Zone Volumes
	level.zones = [];
	level.zone_manager_init_func =& usermap_test_zone_init;
	init_zones[0] = "start_zone";
	level thread zm_zonemgr::manage_zones( init_zones );

	level.pathdist_type = PATHDIST_ORIGINAL;
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

