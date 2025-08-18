#using scripts\shared\duplicaterender_mgr; 
#using scripts\codescripts\struct;
#using scripts\shared\audio_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_load;
#using scripts\zm\_zm_weapons;

//Perks
#using scripts\zm\_zm_pack_a_punch;
#using scripts\zm\_zm_perk_additionalprimaryweapon;
#using scripts\zm\_zm_perk_doubletap2;
#using scripts\zm\_zm_perk_deadshot;
#using scripts\zm\_zm_perk_juggernaut;
#using scripts\zm\_zm_perk_quick_revive;
#using scripts\zm\_zm_perk_sleight_of_hand;
#using scripts\zm\_zm_perk_staminup;
#using scripts\zm\_zm_perk_electric_cherry;
#using scripts\zm\_zm_perk_tombstone;
#using scripts\zm\_zm_perk_phdflopper;

// Needed for harrybo21 perks to work
#using scripts\zm\_zm_perk_widows_wine; 

//Powerups
#using scripts\zm\_zm_powerup_double_points;
#using scripts\zm\_zm_powerup_carpenter;
#using scripts\zm\_zm_powerup_fire_sale;
#using scripts\zm\_zm_powerup_free_perk;
#using scripts\zm\_zm_powerup_full_ammo;
#using scripts\zm\_zm_powerup_insta_kill;
#using scripts\zm\_zm_powerup_nuke;

// CNG
#using scripts\zm\_hb21_madgaz_zm_weap_cng;

//Traps
#using scripts\zm\_zm_trap_electric;

// Ambient sounds
#using scripts\zm\_ambient_room;

// Weather
#using scripts\zm\weather\zm_weather;

//Hell rounds
#using scripts\zm\hellround\zm_hellround;

#using scripts\zm\zm_usermap;

// TODO: remove
// Sphynx's Console Commands
#using scripts\Sphynx\commands\_zm_commands;

function autoexec init() {}

function main()
{    
	luiLoad("ui.uieditor.menus.hud.t7hud_zm_custom");

    zm_usermap::main();

	callback::on_localclient_connect(&on_connect);

    include_weapons();
}

function include_weapons()
{
    zm_weapons::load_weapon_spec_from_table("gamedata/weapons/zm/zm_test_weapons.csv", 1);
}

function private on_connect(n_local_client_num)
{
	self thread disable_player_outline(n_local_client_num);
}

function private disable_player_outline(n_local_client_num)
{
	foreach (player in GetPlayers(n_local_client_num))
	{
		player duplicate_render::set_dr_flag("keyline_active", 0);
	}
	
	self duplicate_render::update_dr_filters(n_local_client_num);
}