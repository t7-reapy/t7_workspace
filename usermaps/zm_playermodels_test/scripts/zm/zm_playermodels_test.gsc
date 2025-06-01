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

#using scripts\zm\zm_usermap;

//*****************************************************************************
// MAIN
//*****************************************************************************

function main()
{
    zm_usermap::main();
    
    level._zombie_custom_add_weapons =&custom_add_weapons;

    setup_zones();
    thread setup_triggers();
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

function private setup_zones()
{
    //Setup the levels Zombie Zone Volumes
    level.zones = [];
    level.zone_manager_init_func =&usermap_test_zone_init;
    init_zones[0] = "start_zone";
    level thread zm_zonemgr::manage_zones( init_zones );

    level.pathdist_type = PATHDIST_ORIGINAL;
}

function private setup_triggers()
{
    switch_body_type_to_easteregg_trigger = GetEnt("bodytype_easteregg", "targetname");
    switch_body_type_to_easteregg_trigger SetHintString("Hold ^3[{+activate}]^7 to switch body style to ^2EASTER EGG");
    switch_body_type_to_easteregg_trigger thread watch_trigger(&bodystyle_for_easteregg);

    switch_body_type_to_hellround_trigger = GetEnt("bodytype_hellround", "targetname");
    switch_body_type_to_hellround_trigger SetHintString("Hold ^3[{+activate}]^7 to switch body style to ^1HELLROUND");
    switch_body_type_to_hellround_trigger thread watch_trigger(&bodystyle_for_hellround);

    switch_body_type_to_normal_trigger = GetEnt("bodytype_normal", "targetname");
    switch_body_type_to_normal_trigger SetHintString("Hold ^3[{+activate}]^7 to switch body style to ^3NORMAL");
    switch_body_type_to_normal_trigger thread watch_trigger(&bodystyle_back_to_normal);

    switch_body_type_to_01_trigger = GetEnt("bodytype_01", "targetname");
    switch_body_type_to_01_trigger SetHintString("Hold ^3[{+activate}]^7 to switch body type to ^301");
    switch_body_type_to_01_trigger thread watch_trigger(&bodytype_01);

    switch_body_type_to_02_trigger = GetEnt("bodytype_02", "targetname");
    switch_body_type_to_02_trigger SetHintString("Hold ^3[{+activate}]^7 to switch body type to ^302");
    switch_body_type_to_02_trigger thread watch_trigger(&bodytype_02);

    switch_body_type_to_03_trigger = GetEnt("bodytype_03", "targetname");
    switch_body_type_to_03_trigger SetHintString("Hold ^3[{+activate}]^7 to switch body type to ^303");
    switch_body_type_to_03_trigger thread watch_trigger(&bodytype_03);

    switch_body_type_to_04_trigger = GetEnt("bodytype_04", "targetname");
    switch_body_type_to_04_trigger SetHintString("Hold ^3[{+activate}]^7 to switch body type to ^304");
    switch_body_type_to_04_trigger thread watch_trigger(&bodytype_04);
}

function private watch_trigger(f_callback) // self == trigger
{
    while(1)
    {
        self waittill("trigger");
        foreach (player in GetPlayers())
        {
            player [[f_callback]]();
        }
    }
}

function private bodystyle_for_easteregg() // self == player
{
    IPrintLnBold("bodystyle_for_easteregg");
    self SetCharacterBodyStyle(2);
}

function private bodystyle_for_hellround() // self == player
{
    IPrintLnBold("bodystyle_for_hellround");
    self SetCharacterBodyStyle(1);
}

function private bodystyle_back_to_normal() // self == player
{
    IPrintLnBold("bodystyle_back_to_normal");
    self SetCharacterBodyStyle(0);
}

function private bodytype_01() // self == player
{
    IPrintLnBold("bodytype_01");
    self SetCharacterBodyType(0);
}

function private bodytype_02() // self == player
{
    IPrintLnBold("bodytype_02");
    self SetCharacterBodyType(1);
}

function private bodytype_03() // self == player
{
    IPrintLnBold("bodytype_03");
    self SetCharacterBodyType(2);
}

function private bodytype_04() // self == player
{
    IPrintLnBold("bodytype_04");
    self SetCharacterBodyType(3);
}