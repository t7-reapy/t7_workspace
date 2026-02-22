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

#using scripts\lilrobot\_inspectable_weapons;
#using scripts\zm\_hb21_zm_weap_staff_fire;
#using scripts\zm\_hb21_zm_weap_staff_lightning;
#using scripts\zm\_hb21_zm_weap_black_hole_projectile;
#using scripts\zm\_hb21_zm_weap_magmagat;

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

//Hell rounds
#using scripts\zm\hellround\zm_hellround;

//Fauna
#using scripts\zm\zm_animated_fauna;

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

// Sphynx's Console Commands
#using scripts\Sphynx\commands\_zm_commands;

//*****************************************************************************
// MAIN
//*****************************************************************************

function main()
{
    zm_usermap::main();

    // Tweaks powerups for testing
    zombie_utility::set_zombie_var("zombie_powerup_drop_increment", 200); // lower this to make drop happen more often
	zombie_utility::set_zombie_var("zombie_powerup_drop_max_per_round", 8); // raise this to make drop happen more often

    level._zombie_custom_add_weapons =&custom_add_weapons;
    thread configure_weapon_inspection();
    thread setup_weapons();
    thread setup_xanims_triggers();
    
    //Setup the levels Zombie Zone Volumes
    level.zones = [];
    level.zone_manager_init_func =&usermap_test_zone_init;
    init_zones[0] = "start_zone";
    level thread zm_zonemgr::manage_zones( init_zones );

    level.pathdist_type = PATHDIST_ORIGINAL;

    callback::on_connect(&disable_hitmarkers);
    
    level.player_starting_points = 500000;

    // level thread give_player_location();
}

function usermap_test_zone_init()
{
    level flag::init( "always_on" );
    level flag::set( "always_on" );
}

function private disable_hitmarkers() // self == player
{
    while(!isdefined(self.hud_damagefeedback) && !isdefined(self.hud_damagefeedback_additional))
    {
        WAIT_SERVER_FRAME;
    }

    self.hud_damagefeedback = undefined;
    self.hud_damagefeedback_additional = undefined;
}

function private give_player_location()
{
    while(1)
    {
        IPrintLnBold("current_location: " + level.players[0].origin);
        wait 2;
    }
}

function custom_add_weapons()
{
    zm_weapons::load_weapon_spec_from_table("gamedata/weapons/zm/zm_test_weapons.csv", 1);
}

function private setup_weapons()
{
    // PaP Camo
    level.pack_a_punch_camo_index = 2;
    level.pack_a_punch_camo_index_number_variants = 2;

    level._zombie_custom_add_weapons = &custom_add_weapons;

    // Use CW M1911 as start and laststand pistol
    level.start_weapon = GetWeapon("t9_1911");
    level.laststandpistol = level.start_weapon;
    level.default_laststandpistol = level.start_weapon;
    level.pistol_values[0] = level.default_laststandpistol;

    // For solo games
    level.default_solo_laststandpistol = GetWeapon("t9_1911_rdw_up");
    level.pistol_values[3] = level.default_solo_laststandpistol;

    // Override default melee weapon
    zm_utility::register_melee_weapon_for_level("t8_knife");
    level.weaponbasemelee = getweapon("t8_knife");
}

function private configure_weapon_inspection()
{
    // T9
    inspectable::add_inspectable_weapon(GetWeapon("t9_me_knife_russian"), 4.18);
    inspectable::add_inspectable_weapon(GetWeapon("t9_me_knife_russian_up"), 4.18);
    inspectable::add_inspectable_weapon(GetWeapon("t9_me_knife_russian_up_up"), 4.18);
    
    inspectable::add_inspectable_weapon(GetWeapon("t9_1911"), 3.33);
    inspectable::add_inspectable_weapon(GetWeapon("t9_1911_rdw_up"), 5);
    inspectable::add_inspectable_weapon(GetWeapon("t9_1911_ldw_up"), 5);
    inspectable::add_inspectable_weapon(GetWeapon("t9_1911_rdw_up_up"), 5);
    inspectable::add_inspectable_weapon(GetWeapon("t9_1911_ldw_up_up"), 5);

    inspectable::add_inspectable_weapon(GetWeapon("t9_diamatti"), 6.23);
    inspectable::add_inspectable_weapon(GetWeapon("t9_diamatti_up"), 6.23);
    inspectable::add_inspectable_weapon(GetWeapon("t9_diamatti_up_up"), 6.23);

    inspectable::add_inspectable_weapon(GetWeapon("t9_rpk"), 5.83);
    inspectable::add_inspectable_weapon(GetWeapon("t9_rpk_up"), 5.83);
    inspectable::add_inspectable_weapon(GetWeapon("t9_rpk_up_up"), 5.83);

    inspectable::add_inspectable_weapon(GetWeapon("t9_ffar1"), 4.83);
    inspectable::add_inspectable_weapon(GetWeapon("t9_ffar1_up"), 4.83);
    inspectable::add_inspectable_weapon(GetWeapon("t9_ffar1_up_up"), 4.83);
    
    inspectable::add_inspectable_weapon(GetWeapon("t9_groza"), 6.13);
    inspectable::add_inspectable_weapon(GetWeapon("t9_groza_up"), 6.13);
    inspectable::add_inspectable_weapon(GetWeapon("t9_groza_up_up"), 6.13);

    inspectable::add_inspectable_weapon(GetWeapon("t9_m60"), 10);
    inspectable::add_inspectable_weapon(GetWeapon("t9_m60_up"), 10);
    inspectable::add_inspectable_weapon(GetWeapon("t9_m60_up_up"), 10);

    inspectable::add_inspectable_weapon(GetWeapon("t9_streetsweeper"), 5.6);
    inspectable::add_inspectable_weapon(GetWeapon("t9_streetsweeper_up"), 5.6);
    inspectable::add_inspectable_weapon(GetWeapon("t9_streetsweeper_up_up"), 5.6);

    inspectable::add_inspectable_weapon(GetWeapon("t9_semiauto_cosplay"), 4.33);
    inspectable::add_inspectable_weapon(GetWeapon("t9_semiauto_cosplay_up"), 4.33);
    inspectable::add_inspectable_weapon(GetWeapon("t9_semiauto_cosplay_up_up"), 4.33);

    // IW8
    inspectable::add_inspectable_weapon(GetWeapon("iw8_asval"), 5.76);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_asval_up"), 5.76);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_asval_up_up"), 5.76);
    
    inspectable::add_inspectable_weapon(GetWeapon("iw8_50gs"), 4.66);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_50gs_rdw_up"), 4.66);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_50gs_ldw_up"), 4.66);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_50gs_rdw_up_up"), 4.66);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_50gs_ldw_up_up"), 4.66);

    inspectable::add_inspectable_weapon(GetWeapon("shredder_rdw_up_up"), 4.66);
    inspectable::add_inspectable_weapon(GetWeapon("shredder_ldw_up_up"), 4.66);

    inspectable::add_inspectable_weapon(GetWeapon("iw8_ak47"), 5.13);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_ak47_up"), 5.13);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_ak47_up_up"), 5.13);
    
    inspectable::add_inspectable_weapon(GetWeapon("iw8_iso"), 5.13);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_iso_up"), 5.13);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_iso_up_up"), 5.13);
        
    inspectable::add_inspectable_weapon(GetWeapon("iw8_m4a1"), 5.13);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_m4a1_up"), 5.13);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_m4a1_up_up"), 5.13);

    inspectable::add_inspectable_weapon(GetWeapon("iw8_minigun"), 5.26);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_minigun_up"), 5.26);
    
    inspectable::add_inspectable_weapon(GetWeapon("iw8_spr208_irons"), 5.26);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_spr208_irons_up"), 5.26);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_spr208_irons_up_up"), 5.26);

    inspectable::add_inspectable_weapon(GetWeapon("iw8_vlkrogue"), 5.33);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_vlkrogue_up"), 5.33);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_vlkrogue_up_up"), 5.33);
    
    inspectable::add_inspectable_weapon(GetWeapon("iw8_mp5k"), 5.16);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_mp5sd_up"), 5.16);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_mp5sd_up_up"), 5.16);
    
    inspectable::add_inspectable_weapon(GetWeapon("iw8_model680"), 5.16);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_model680_up"), 5.16);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_model680_up_up"), 5.16);

    // SW2
    inspectable::add_inspectable_weapon(GetWeapon("s2_vmg1927"), 5);
    inspectable::add_inspectable_weapon(GetWeapon("s2_vmg1927_up"), 5);
    inspectable::add_inspectable_weapon(GetWeapon("s2_vmg1927_up_up"), 5);
}

function setup_xanims_triggers()
{
    toggle_ravens_trigger = GetEnt("toggle_ravens", "targetname");
    toggle_ravens_trigger SetHintString("Hold ^3[{+activate}]^7 to toggle raven xanims");
    toggle_ravens_trigger thread trigger_think(&zm_animated_fauna::toggle_ravens);

    toggle_rats_trigger = GetEnt("toggle_rats", "targetname");
    toggle_rats_trigger SetHintString("Hold ^3[{+activate}]^7 to toggle rats xanims");
    toggle_rats_trigger thread trigger_think(&zm_animated_fauna::toggle_rats);
}

function trigger_think(callback) // self == trigger
{
    toggled = false;
    while(1)
    {
        self waittill("trigger");
        [[ callback ]](toggled);
        toggled = !toggled;
    }
}