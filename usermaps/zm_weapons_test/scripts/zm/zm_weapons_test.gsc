#using scripts\lilrobot\_inspectable_weapons; 
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

// CNG
#using scripts\zm\_hb21_madgaz_zm_weap_cng;

//Traps
#using scripts\zm\_zm_trap_electric;

#using scripts\zm\zm_usermap;
#using scripts\zm\_zm_xcdylan93_utils;

//*****************************************************************************
// MAIN
//*****************************************************************************

function main()
{
    configure_weapon_inspection();
    zm_usermap::main();
    setup_weapons();
    setup_zones();
    setup_camo_trigger();

    level.player_starting_points = 500000;
    
    callback::on_spawned(&on_player_spawned);
}

function usermap_test_zone_init()
{
    level flag::init("always_on");
    level flag::set("always_on");
}    

function setup_weapons()
{
    // PaP Camo
    level.pack_a_punch_camo_index = 3;
    level.pack_a_punch_camo_index_number_variants = 34;

    level._zombie_custom_add_weapons = &custom_add_weapons;

    // Use CW M1911 as start and laststand pistol
    level.start_weapon = GetWeapon("iw8_50gs");
    level.laststandpistol = level.start_weapon;
    level.default_laststandpistol = level.start_weapon;
    level.default_solo_laststandpistol = GetWeapon("iw8_50gs_rdw_up");

    // Override default melee weapon
    zm_utility::register_melee_weapon_for_level("t8_knife");
    level.weaponbasemelee = getweapon("t8_knife");
}

function private update_weapons_camo_for_hellround(enable) // self == player
{
    foreach (weapon in self GetWeaponsListPrimaries())
    {
        self update_weapon_camo_for_hellround(enable, weapon);
    }
}

function private update_weapon_camo_for_hellround(enable, weapon) // self == player
{
    if (!(self HasWeapon(weapon, true)))
    {
        return;
    }

    // Initial state of weapon if missing
    weapon = zm_weapons::get_nonalternate_weapon(weapon);
    if (!isdefined(weapon.original_hellround_camo))
    {
        weapon.original_hellround_camo = array(undefined, undefined, undefined, undefined);
    }

    // Update camo
    client_number = self GetEntityNumber();
    camo_index = 0;
    if (enable)
    {
        camo_index = 1; // USE CONST HERE.
        weapon.original_hellround_camo[client_number] = (zm_weapons::is_weapon_upgraded(weapon) ? weapon.pap_camo_to_use : 0);
    }
    else
    {
        camo_index = weapon.original_hellround_camo[client_number];
        weapon.original_hellround_camo[client_number] = undefined;
    }

    if (isdefined(camo_index))
    {
        zm_xcdylan93_utils::update_weapon_camo(camo_index, weapon, weapon.altWeapon, 0);
    }
}

function setup_camo_trigger()
{
    switch_camo_trigger = GetEnt("switch_camo", "targetname");
    switch_camo_trigger SetHintString("Hold ^3[{+activate}]^7 to switch camo");

    switch_camo_trigger thread watch_trigger();
} 

function on_player_spawned()
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

function watch_trigger() // self == trigger
{    
    while(1)
    {
        // Enable hellround camo
        self waittill("trigger", ent);
        foreach (player in GetPlayers())
        {
            player update_weapons_camo_for_hellround(true);
        }

        // Disable hellround camo
        self waittill("trigger", ent);
        foreach (player in GetPlayers())
        {
            player update_weapons_camo_for_hellround(false);
        }
    }
}

function custom_add_weapons()
{
    zm_weapons::load_weapon_spec_from_table("gamedata/weapons/zm/zm_weapons.csv", 1);
}

function private configure_weapon_inspection()
{
    // T9
    inspectable::add_inspectable_weapon(GetWeapon("t9_1911"), 3.33);
    inspectable::add_inspectable_weapon(GetWeapon("t9_1911_rdw_up"), 5);
    inspectable::add_inspectable_weapon(GetWeapon("t9_1911_ldw_up"), 5);

    inspectable::add_inspectable_weapon(GetWeapon("t9_diamatti"), 6.23);
    inspectable::add_inspectable_weapon(GetWeapon("t9_diamatti_up"), 6.23);

    inspectable::add_inspectable_weapon(GetWeapon("t9_rpk"), 5.83);
    inspectable::add_inspectable_weapon(GetWeapon("t9_rpk_up"), 5.83);

	inspectable::add_inspectable_weapon(GetWeapon("t9_ffar1"), 4.83);
	inspectable::add_inspectable_weapon(GetWeapon("t9_ffar1_up"), 4.83);
    
    inspectable::add_inspectable_weapon(GetWeapon("t9_groza"), 6.13);
    inspectable::add_inspectable_weapon(GetWeapon("t9_groza_up"), 6.13);

    inspectable::add_inspectable_weapon(GetWeapon("t9_m60"), 10);
    inspectable::add_inspectable_weapon(GetWeapon("t9_m60_up"), 10);

    inspectable::add_inspectable_weapon(GetWeapon("t9_streetsweeper"), 5.6);
    inspectable::add_inspectable_weapon(GetWeapon("t9_streetsweeper_up"), 5.6);

    inspectable::add_inspectable_weapon(GetWeapon("t9_semiauto_cosplay"), 4.33);
    inspectable::add_inspectable_weapon(GetWeapon("t9_semiauto_cosplay_up"), 4.33);

    inspectable::add_inspectable_weapon(GetWeapon("t9_me_knife_russian"), 4.18);
    inspectable::add_inspectable_weapon(GetWeapon("t9_me_knife_russian_up"), 4.18);

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
    
    inspectable::add_inspectable_weapon( GetWeapon("iw8_spr208_irons"), 5.26 );
    inspectable::add_inspectable_weapon( GetWeapon("iw8_spr208_irons_up"), 5.26 );

    inspectable::add_inspectable_weapon( GetWeapon("iw8_vlkrogue"), 5.33 );
    inspectable::add_inspectable_weapon( GetWeapon("iw8_vlkrogue_up"), 5.33 );
    
    inspectable::add_inspectable_weapon( GetWeapon("iw8_mp5"), 5.16 );
    inspectable::add_inspectable_weapon( GetWeapon("iw8_mp5_up"), 5.16 );
    inspectable::add_inspectable_weapon( GetWeapon("iw8_mp5k"), 5.16 );
    inspectable::add_inspectable_weapon( GetWeapon("iw8_mp5k_up"), 5.16 );
    inspectable::add_inspectable_weapon( GetWeapon("iw8_mp5sd"), 5.16 );
    inspectable::add_inspectable_weapon( GetWeapon("iw8_mp5sd_up"), 5.16 );

    // SW2
    inspectable::add_inspectable_weapon( GetWeapon("s2_vmg1927"), 5 );
    inspectable::add_inspectable_weapon( GetWeapon("s2_vmg1927_up"), 5 );

}

function private setup_zones()
{
    //Setup the levels Zombie Zone Volumes
    level.zones = [];
    level.zone_manager_init_func = &usermap_test_zone_init;
    init_zones[0] = "start_zone";
    level thread zm_zonemgr::manage_zones(init_zones);

    level.pathdist_type = PATHDIST_ORIGINAL;
}