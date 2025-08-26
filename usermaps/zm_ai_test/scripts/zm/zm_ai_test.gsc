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
    configure_weapon_inspection();

    zm_usermap::main();

    // Tweaks powerups for testing
    zombie_utility::set_zombie_var("zombie_powerup_drop_increment", 200); // lower this to make drop happen more often
	zombie_utility::set_zombie_var("zombie_powerup_drop_max_per_round", 8); // raise this to make drop happen more often

    // Use CW M1911 as start weapon
    //t9_1911 iw8_asval
    level.start_weapon = (getWeapon("t9_1911"));
    
    level._zombie_custom_add_weapons =&custom_add_weapons;
    
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

function configure_weapon_inspection()
{
    inspectable::add_inspectable_weapon(GetWeapon("t9_1911"), 3.33);
    inspectable::add_inspectable_weapon(GetWeapon("t9_1911_rdw_up"), 5);
    inspectable::add_inspectable_weapon(GetWeapon("t9_1911_ldw_up"), 5);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_asval"), 5.76);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_asval_up"), 5.76);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_vintorez"), 5.46);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_vintorez_up"), 5.76);
}