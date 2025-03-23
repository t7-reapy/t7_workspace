/*
Rain Template by Ardivee & Zeroy
April 2017

Tutorial: http://wiki.modsrepository.com/index.php?title=Call_of_duty_bo3:_Rain
*/

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
#using scripts\zm\_zm_powerup_weapon_minigun;

//Traps
#using scripts\zm\_zm_trap_electric;

#using scripts\zm\zm_usermap;

#precache ("fx", "custom/env/fx_rain_player_z_light");
#precache ("fx", "custom/env/fx_rain_player_z_regular");
#precache ("fx", "custom/env/fx_rain_player_z_heavy");

//*****************************************************************************
// MAIN
//*****************************************************************************

function main()
{
    // Decal
    clientfield::register( "world", "decal_toggle", VERSION_SHIP, 1, "int" );

    // Rain
    clientfield::register( "world", "rain_fx_stop", VERSION_SHIP, 1, "int" );

	zm_usermap::main();

	//FX
	precache_fx();

    level util::set_lighting_state( 0 ); // For Perk Machine Lights
	
	level._zombie_custom_add_weapons =&custom_add_weapons;
	
	//Setup the levels Zombie Zone Volumes
	level.zones = [];
	level.zone_manager_init_func =&usermap_test_zone_init;
	init_zones[0] = "start_zone";
	level thread zm_zonemgr::manage_zones( init_zones );

	level.pathdist_type = PATHDIST_ORIGINAL;

	level thread watch_lightstate();
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

function precache_fx()
{
	//level._effect[ "player_rain" ] = "custom/env/fx_rain_player_z_light";
	level._effect[ "player_rain" ] = "custom/env/fx_rain_player_z_regular";
	//level._effect[ "player_rain" ] = "custom/env/fx_rain_player_z_heavy";
}

function watch_lightstate() // for debug
{

	level waittill("power_on"); // Wait until power is switched on

    level clientfield::set("rain_fx_stop", 1); //Stops the rain
    
    wait 0.5;

    level clientfield::set("decal_toggle", 1); //Hide the decals

    wait 0.5;

    level util::set_lighting_state( 1 ); // Set new Lightstate
}

