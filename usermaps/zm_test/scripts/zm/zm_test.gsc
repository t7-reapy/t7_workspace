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

// Needed for harrybo21 perks to work
#using scripts\zm\_zm_perk_widows_wine;

// Harrybo21 additional perks
#using scripts\zm\_zm_perk_electric_cherry;
#using scripts\zm\_zm_perk_tombstone;
#using scripts\zm\_zm_perk_phdflopper;

//Powerups
#using scripts\zm\_zm_powerup_double_points;
#using scripts\zm\_zm_powerup_carpenter;
#using scripts\zm\_zm_powerup_fire_sale;
#using scripts\zm\_zm_powerup_free_perk;
#using scripts\zm\_zm_powerup_full_ammo;
#using scripts\zm\_zm_powerup_insta_kill;
#using scripts\zm\_zm_powerup_nuke;
//#using scripts\zm\_zm_powerup_weapon_minigun;

// CNG
#using scripts\zm\_hb21_madgaz_zm_weap_cng;

//Traps
#using scripts\zm\_zm_trap_electric;

#using scripts\zm\zm_usermap;
#using scripts\zm\_zm_animated_switch;

// TODO: remove below
#using scripts\zm\hellround\zm_hellround_music;
#using scripts\zm\zm_rain;
// Sphynx's Console Commands
#using scripts\Sphynx\commands\_zm_commands;
#using scripts\Sphynx\commands\_zm_name_checker;


function private hellround_command_response(command_args)
{
    level.hellround_command = false;
    ModVar("hellround", "");

    while(true)
    {
        WAIT_SERVER_FRAME;

        dvar_value = ToLower(GetDvarString("hellround", ""));

        if(!isdefined(dvar_value) || dvar_value == "")
        {
            continue;
        }
        ModVar("hellround", "");

        switch(Int(dvar_value))
        {
            case 0:
                level.hellround_command = false;
                break;
            case 1:
                level.hellround_command = true;
                break;
            default:
                level.hellround_command = !level.hellround_command;
                break;
        }

        toggle_hellround_environment(level.hellround_command);
    }
}

function private toggle_hellround_environment(b_enable)
{
    if (IS_TRUE(b_enable))
    {
        util::set_lighting_state(3);
        level clientfield::set("hellround_debug", 1);
    }
    else
    {
        util::set_lighting_state(0);
        level clientfield::set("hellround_debug", 0);
    }
}

function main()
{
    register_client_fields();
    configure_weapon_inspection();
    
    zm_usermap::main();
    level thread zm_animated_switch::MasterSwitchInit();
    level util::set_lighting_state(0);
    
    setup_playable_zones();
    remove_players_names();
    setup_weapons();
    
    callback::on_spawned(&on_player_spawned);

    // TODO: remove
    thread hellround_command_response();
    level thread monitor_power_state();
    level.player_starting_points = 500000;
}

function register_client_fields()
{
    clientfield::register("world", "hellround_debug", VERSION_SHIP, 1, "int");
}

function configure_weapon_inspection()
{
    // T9
    inspectable::add_inspectable_weapon(GetWeapon("t9_me_knife_russian"), 4.18);
    inspectable::add_inspectable_weapon(GetWeapon("t9_me_knife_russian_up"), 4.18);
    
    inspectable::add_inspectable_weapon(GetWeapon("t9_1911"), 3.33);
    inspectable::add_inspectable_weapon(GetWeapon("t9_1911_rdw_up"), 5);
    inspectable::add_inspectable_weapon(GetWeapon("t9_1911_ldw_up"), 5);

    inspectable::add_inspectable_weapon(GetWeapon("t9_diamatti"), 6.23);
    inspectable::add_inspectable_weapon(GetWeapon("t9_diamatti_up"), 6.23);

    inspectable::add_inspectable_weapon(GetWeapon("t9_rpk"), 5.83);
    inspectable::add_inspectable_weapon(GetWeapon("t9_rpk_up"), 5.83);
    
    inspectable::add_inspectable_weapon(GetWeapon("t9_groza"), 6.13);
    inspectable::add_inspectable_weapon(GetWeapon("t9_groza_up"), 6.13);

    inspectable::add_inspectable_weapon(GetWeapon("t9_m60"), 10);
    inspectable::add_inspectable_weapon(GetWeapon("t9_m60_up"), 10);

    inspectable::add_inspectable_weapon(GetWeapon("t9_streetsweeper"), 5.6);
    inspectable::add_inspectable_weapon(GetWeapon("t9_streetsweeper_up"), 5.6);

    inspectable::add_inspectable_weapon(GetWeapon("t9_semiauto_cosplay"), 4.33);
    inspectable::add_inspectable_weapon(GetWeapon("t9_semiauto_cosplay_up"), 4.33);

    // IW8
    inspectable::add_inspectable_weapon(GetWeapon("iw8_asval"), 5.76);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_asval_up"), 5.76);
    
    inspectable::add_inspectable_weapon(GetWeapon("iw8_50gs"), 4.66);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_50gs_rdw_up"), 4.66);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_50gs_ldw_up"), 4.66);

    inspectable::add_inspectable_weapon(GetWeapon("iw8_ak47"), 5.13);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_ak47_up"), 5.13);
    
    inspectable::add_inspectable_weapon(GetWeapon("iw8_iso"), 5.13);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_iso_up"), 5.13);
        
    inspectable::add_inspectable_weapon(GetWeapon("iw8_m4a1"), 5.13);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_m4a1_up"), 5.13);

    inspectable::add_inspectable_weapon(GetWeapon("iw8_minigun"), 5.26);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_minigun_up"), 5.26);
    
    inspectable::add_inspectable_weapon(GetWeapon("iw8_spr208_irons"), 5.26);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_spr208_irons_up"), 5.26);

    inspectable::add_inspectable_weapon(GetWeapon("iw8_vlkrogue"), 5.33);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_vlkrogue_up"), 5.33);

    // SW2
    inspectable::add_inspectable_weapon(GetWeapon("s2_vmg1927"), 5);
    inspectable::add_inspectable_weapon(GetWeapon("s2_vmg1927_up"), 5);
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
	SetDvar("cg_disableplayernames", "1");
}

function setup_weapons()
{
    // PaP Camo
    level.pack_a_punch_camo_index = 3;
    level.pack_a_punch_camo_index_number_variants = 34;

    level._zombie_custom_add_weapons = &custom_add_weapons;

    // Use CW M1911 as start and laststand pistol
    level.start_weapon = GetWeapon("t9_1911");
    level.laststandpistol = level.start_weapon;
    level.default_laststandpistol = level.start_weapon;
    level.default_solo_laststandpistol = GetWeapon("t9_1911_rdw_up");

    // Override default melee weapon
    zm_utility::register_melee_weapon_for_level("t8_knife");
    level.weaponbasemelee = getweapon("t8_knife");
}

function on_player_spawned() // self == player
{
    self thread watch_blastomatic_acquisition();
}

function private watch_blastomatic_acquisition() // self == player
{
    level endon("end_game");
    self endon("disconnect");
    self endon("bled_out");

    while(true)
    {
        self waittill("weapon_give", weapon);

        if(weapon.name == "t9_semiauto_cosplay")
        {
            PlaySoundAtPosition("mus_raygun_stinger", (0, 0, 0));
        }
    }
}

function monitor_power_state()
{
    level flag::wait_till("initial_blackscreen_passed");
    level flag::wait_till("power_on");

    // TODO: still needed ?
}