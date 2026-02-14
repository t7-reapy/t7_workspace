#using scripts\codescripts\struct;
#using scripts\shared\ai_shared;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\system_shared;
#using scripts\shared\vehicle_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_util;
#using scripts\zm\_zm;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_weap_staff_common;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_utility.gsh;

#namespace zm_weap_staff_revive; 

REGISTER_SYSTEM_EX( "zm_weap_staff_revive", &__init__, &__main__, undefined )

function __init__()
{	
	level.a_staff_revive_weaponfiles = [];
	staff_revive_register_weapon_for_level( "staff_revive", undefined, undefined, undefined, &staff_revive_weapon_obtained, &staff_revive_weapon_lost );
	zm::register_player_friendly_fire_callback( &staff_revive_friendly_fire );
}

function __main__()
{
}

function staff_revive_register_weapon_for_level( str_weapon, staff_weapon_fired = undefined, staff_weapon_missile_fired = undefined, staff_weapon_grenade_fired = undefined, staff_weapon_obtained = undefined, staff_weapon_lost = undefined, staff_weapon_reloaded = undefined, staff_weapon_pullout = undefined, staff_weapon_putaway = undefined )
{
	DEFAULT( level.a_staff_revive_weaponfiles, [] );
	w_weapon = getWeapon( str_weapon );
	w_weapon.b_is_upgrade = 0;
	
	zm_weap_staff_common::register_staff_weapon_for_level( 	w_weapon, staff_weapon_fired, staff_weapon_missile_fired, staff_weapon_grenade_fired, &staff_revive_weapon_obtained, staff_weapon_lost, staff_weapon_reloaded, staff_weapon_pullout, staff_weapon_putaway );
	
	ARRAY_ADD( level.a_staff_revive_weaponfiles, w_weapon );
}

function staff_revive_weapon_obtained( w_weapon )
{
	
}

function staff_revive_weapon_lost( w_weapon )
{
	
}

function staff_revive_friendly_fire( e_inflictor, e_attacker, n_damage, f_flags, str_means_of_death, w_weapon, v_point, v_direction, str_hit_loc, n_offset_time, n_bone_index )
{
	if ( !zm_weap_staff_common::is_staff_weapon( w_weapon, level.a_staff_revive_weaponfiles ) )
		return;
	
	if ( self != e_attacker && self laststand::player_is_in_laststand() )
	{
		self notify( "remote_revive", e_attacker );
		self playSoundToPlayer( "wpn_revivestaff_revive_plr", e_attacker );
	}
}
