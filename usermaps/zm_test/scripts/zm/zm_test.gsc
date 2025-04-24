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

// Weapon inspection
#using scripts\lilrobot\_inspectable_weapons;

#using scripts\zm\_load;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_zonemgr;
#using scripts\zm\_zm_equipment;

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
#using scripts\zm\_zm_perk_light_fix;

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
#using scripts\zm\zm_rain;

function main()
{
    register_client_fields();
    configure_weapon_inspection();
    
    zm_usermap::main();
    
    setup_playable_zones();
    remove_players_names();

    // Use CW M1911 as start weapon
    level.start_weapon = GetWeapon("t9_1911");
    level._zombie_custom_add_weapons = &custom_add_weapons;

    level util::set_lighting_state(0);
    level thread monitor_power_state();

    //TODO: remove
    level.player_starting_points = 500000;
}

function register_client_fields()
{
}

function configure_weapon_inspection()
{
    inspectable::add_inspectable_weapon(GetWeapon("t9_1911"), 3.33);
    inspectable::add_inspectable_weapon(GetWeapon("t9_1911_rdw_up"), 5);
    inspectable::add_inspectable_weapon(GetWeapon("t9_1911_ldw_up"), 5);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_asval"), 5.76);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_asval_up"), 5.76);
}

function custom_add_weapons()
{
    zm_weapons::load_weapon_spec_from_table("gamedata/weapons/zm/zm_test_weapons.csv", 1);
}

function setup_playable_zones()
{
    //Setup the levels Zombie Zone Volumes
    level.zones = [];
    level.zone_manager_init_func = &add_adjacent_zones;
    init_zones[0] = "start_zone";
    level thread zm_zonemgr::manage_zones(init_zones);

    // Must be defined for AI pathing
    level.pathdist_type = PATHDIST_ORIGINAL;
}

function add_adjacent_zones()
{
    zm_zonemgr::add_adjacent_zone("start_zone", "second_zone", "enter_second_zone");
    zm_zonemgr::add_adjacent_zone("second_zone", "third_zone", "enter_third_zone");
    zm_zonemgr::add_adjacent_zone("third_zone", "fourth_zone", "enter_fourth_zone");
} 

function remove_players_names()
{
    // Remove names
    SetDvar("cg_overheadNamesSize", "0");
    SetDvar("cg_overheadIconSize", "0");
    SetDvar("cg_overheadRankSize", "0");
}

function monitor_power_state()
{
    level flag::wait_till("initial_blackscreen_passed");
    level flag::wait_till("power_on");

    // TODO: still needed ?
}