#using scripts\codescripts\struct;
#using scripts\shared\ai_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_weap_staff_common;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#precache( "client_fx", "dlc5/zmb_weapon/fx_staff_air_impact" );
#precache( "client_fx", "dlc5/zmb_weapon/fx_staff_air_impact_ug_miss" );
#precache( "client_fx", "dlc5/zmb_weapon/fx_staff_charge_air_lv1" );
#precache( "client_fx", "dlc5/tomb/fx_tomb_elem_reveal_air_glow" );

#namespace zm_weap_staff_air; 

REGISTER_SYSTEM_EX( "zm_weap_staff_air", &__init__, &__main__, undefined )

function __init__()
{
	level.a_staff_air_weaponfiles = [];
	staff_air_register_weapon_for_level( "staff_air" );
	staff_air_register_weapon_for_level( "staff_air_upgraded" );
	staff_air_register_weapon_for_level( "staff_air_upgraded2" );
	staff_air_register_weapon_for_level( "staff_air_upgraded3" );

	clientfield::register( "scriptmover", "staff_air_aoe_fx", VERSION_SHIP, 1, "int", &staff_air_whirlwind_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "scriptmover", "staff_air_set_launch_source", VERSION_SHIP, 1, "int", &staff_air_set_launch_source, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "actor",	"staff_air_launch_zombie", VERSION_SHIP, 1, "int", &staff_air_launch_zombie, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "actor", "staff_air_ragdoll_impact_watch", VERSION_SHIP, 1, "int", &staff_air_ragdoll_impact_watch, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "vehicle", "staff_air_ragdoll_impact_watch", VERSION_SHIP, 1, "int", &staff_air_ragdoll_impact_watch, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );

	ai::add_archetype_spawn_function( "parasite", &staff_air_parasite_init );
}

function __main__()
{
}

function staff_air_register_weapon_for_level( str_weapon )
{
	DEFAULT( level.a_staff_air_weaponfiles, [] );
	
	a_weapon_data = tableLookupRow( "gamedata/weapons/zm/staff_air_settings.csv", tableLookupRowNum( "gamedata/weapons/zm/staff_air_settings.csv", 0, str_weapon ) );
	if ( !isDefined( a_weapon_data ) )
		a_weapon_data = tableLookupRow( "gamedata/weapons/zm/staff_air_settings.csv", tableLookupRowNum( "gamedata/weapons/zm/staff_air_settings.csv", 0, "default" ));
	if ( !isDefined( a_weapon_data ) )	
		return;
	
	w_weapon = getWeapon( str_weapon );
	w_weapon.b_is_upgrade = ( toLower( a_weapon_data[ true ] ) == "true" );
	w_weapon.n_damage = int( a_weapon_data[ 2 ] );
	w_weapon.n_cone_fov	 = int( a_weapon_data[ 3 ] );
	w_weapon.n_cone_range = int( a_weapon_data[ 4 ]	);
	w_weapon.b_whirlwind_supercharged =	( toLower( a_weapon_data[ 5 ] ) == "true" );
	w_weapon.n_whirlwind_lifetime = float( a_weapon_data[ 6 ] );
	w_weapon.n_whirlwind_range = int( a_weapon_data[ 7 ] );
	
	zm_weap_staff_common::register_staff_weapon_for_level(	w_weapon, undefined, undefined, undefined, undefined, undefined, undefined, undefined, &staff_air_charge_up_effects, undefined, "dlc5/zmb_weapon/fx_staff_charge_air_lv1" );

	ARRAY_ADD( level.a_staff_air_weaponfiles, w_weapon );
}

function staff_air_charge_up_effects( n_local_client_num, w_weapon, n_charge_level = 0 )
{
	self zm_weap_staff_common::play_staff_charge_up_sounds( n_local_client_num, w_weapon, n_charge_level, "wpn_airstaff_charge_" + n_charge_level, ( n_charge_level == 1 ? "wpn_airstaff_charge_loop" : undefined ) );
}

function staff_air_whirlwind_fx( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump )
{
	if ( IS_TRUE( n_new_value ) )
	{
		self.fx_staff_air_whirlwind = playFxOnTag( n_local_client_num, "dlc5/zmb_weapon/fx_staff_air_impact_ug_miss", self, "tag_origin" );
		self playRumbleOnEntity( n_local_client_num, "artillery_rumble" );
		self thread zm_weap_staff_common::staff_shake_and_rumble( n_local_client_num, .3, 1, 100, "artillery_rumble" );
		self thread zm_weap_staff_common::staff_aoe_looping_sound( n_local_client_num, "wpn_airstaff_tornado", undefined, undefined, .5, 1.5 );
	}
	else
	{
		playFx( n_local_client_num, "dlc5/zmb_weapon/fx_staff_air_impact", self.origin, anglesToForward( self.angles ), anglesToUp( self.angles ) );
		self notify( "staff_shake_and_rumble" );
		self notify( "staff_aoe_looping_sound_end" );
		stopFx( n_local_client_num, self.fx_staff_air_whirlwind );
		self.fx_staff_air_whirlwind = undefined;
	}
}

function staff_air_set_launch_source( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump )
{
	if ( !isDefined( level.e_staff_air_launch_source ) )
		level.e_staff_air_launch_source = self;

}

function staff_air_launch_zombie( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump )
{
	self endon( "entityshutdown" );
	util::server_wait( n_local_client_num, .05, CLIENT_FRAME );
	v_direction = vectorNormalize( self.origin - level.e_staff_air_launch_source.origin );
	v_launch = vectorScale( ( v_direction[ 0 ], v_direction[ 1 ], randomFloatRange( .05, .35 ) ), ( length( v_direction ) * 300 ) );
	self launchRagdoll( v_launch );
	self thread staff_air_ragdoll_impact_watch( n_local_client_num, 0, 1 );
}

function staff_air_ragdoll_impact_watch( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump )
{
	if ( !IS_TRUE( n_new_value ) )
		return;
	
	self endon( "entityshutdown" );
 	self.v_start_pos = self.origin;
 
	v_prev_origin = self.origin;
	waitRealTime( .05 );

	v_prev_vel = self.origin - v_prev_origin;
	n_prev_speed = length( v_prev_vel );
	v_prev_origin = self.origin;
	waitRealTime( .05 );

	b_first_loop = 1;

	while ( isDefined( self ) )
	{
 		v_vel = self.origin - v_prev_origin;
		n_speed = length( v_vel );

		if ( n_speed < n_prev_speed * .5 && !b_first_loop )
		{
			if ( n_prev_speed < 20 && self.origin[ 2 ] < ( self.v_start_pos[ 2 ] + 128 ) )
				break;
			
			playFX( n_local_client_num, level._effect[ "zombie_guts_explosion" ], self getTagOrigin( ( isDefined( self.str_staff_air_gib_fx_tag ) ? self.str_staff_air_gib_fx_tag : "j_spine4" ) ) );
			self hide();
			break;
 		}

		v_prev_origin = self.origin;
		n_prev_speed = n_speed;
		b_first_loop = 0;

		waitRealTime( .05 );
	}      
}


function staff_air_parasite_init()
{
	self.str_staff_air_gib_fx_tag = "j_spine";
}