#using scripts\codescripts\struct;
#using scripts\shared\ai_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_weap_staff_common;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace zm_weap_staff_lightning; 

#precache( "client_fx", "dlc5/zmb_weapon/fx_staff_elec_impact_ug_hit_torso" );
#precache( "client_fx", "dlc5/zmb_weapon/fx_staff_elec_impact_ug_hit_eyes" );
#precache( "client_fx", "dlc5/zmb_weapon/fx_staff_elec_impact_ug_miss" );
#precache( "client_fx", "dlc5/zmb_weapon/fx_staff_charge_elec_lv1" );

REGISTER_SYSTEM_EX( "zm_weap_staff_lightning", &__init__, &__main__, undefined )

function __init__()
{	
	level.a_staff_lightning_weaponfiles = [];

	staff_lightning_register_weapon_for_level( "staff_bolt" );
	staff_lightning_register_weapon_for_level( "staff_bolt_upgraded" );
	staff_lightning_register_weapon_for_level( "staff_bolt_upgraded2" );
	staff_lightning_register_weapon_for_level( "staff_bolt_upgraded3" );

	clientfield::register( "scriptmover", "staff_lightning_ball_fx", VERSION_SHIP, 1, "int", &staff_lightning_ball_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "actor", "staff_lightning_impact_fx", VERSION_SHIP, 1, "counter", &staff_lightning_impact_play_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "vehicle", "staff_lightning_impact_fx_veh", VERSION_SHIP, 1, "counter", &staff_lightning_impact_play_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "actor", "staff_lightning_shock_eyes_fx", VERSION_SHIP, 1, "counter", &staff_lightning_shock_eyes_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "vehicle", "staff_lightning_shock_eyes_fx_veh", VERSION_SHIP, 1, "counter", &staff_lightning_shock_eyes_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );

	ai::add_archetype_spawn_function( "parasite", &staff_lightning_parasite_init );
}

function __main__()
{
}

function staff_lightning_register_weapon_for_level( str_weapon, staff_weapon_fired = undefined )
{
	DEFAULT( level.a_staff_lightning_weaponfiles, [] );
	
	a_weapon_data = tableLookupRow( "gamedata/weapons/zm/staff_bolt_settings.csv", tableLookupRowNum( "gamedata/weapons/zm/staff_bolt_settings.csv", 0, str_weapon ));
	if ( !isDefined( a_weapon_data ) )
		a_weapon_data = tableLookupRow( "gamedata/weapons/zm/staff_bolt_settings.csv", tableLookupRowNum( "gamedata/weapons/zm/staff_bolt_settings.csv", 0, "default" )	);
	if ( !isDefined( a_weapon_data ) )	
		return;
		
	w_weapon = getWeapon( str_weapon );
	w_weapon.b_is_upgrade = ( toLower( a_weapon_data[ true ] ) == "true" );
	w_weapon.n_damage = int( a_weapon_data[ 2 ]	);
	w_weapon.n_min_damage = int( a_weapon_data[ 3 ] );
	w_weapon.n_ball_move_distance = int( a_weapon_data[ 4 ] );
	w_weapon.n_ball_damage_per_second = int( a_weapon_data[ 5 ] );
	w_weapon.n_ball_range = int( a_weapon_data[ 6 ] );
	
	zm_weap_staff_common::register_staff_weapon_for_level( 	w_weapon, undefined, undefined, undefined, undefined, undefined, undefined, undefined, &staff_lightning_charge_up_effects, undefined, "dlc5/zmb_weapon/fx_staff_charge_elec_lv1"												 );
	
	ARRAY_ADD( level.a_staff_lightning_weaponfiles, w_weapon );
}

function staff_lightning_charge_up_effects( n_local_client_num, w_weapon, n_charge_level = 0 )
{
	self zm_weap_staff_common::play_staff_charge_up_sounds( n_local_client_num, w_weapon, n_charge_level, "wpn_lightningstaff_charge_" + n_charge_level, ( n_charge_level == 1 ? "wpn_lightningstaff_charge_loop" : undefined ) );
}

function staff_lightning_ball_fx( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump )
{
	if ( IS_TRUE( n_new_value ) )
	{
		self.fx_lightning_staff_ball = playFxOnTag( n_local_client_num, "dlc5/zmb_weapon/fx_staff_elec_impact_ug_miss", self, "tag_origin" );
		self playRumbleOnEntity( n_local_client_num, "artillery_rumble" );
		self thread zm_weap_staff_common::staff_shake_and_rumble( n_local_client_num, .3, 1, 100, "artillery_rumble" );
		self thread zm_weap_staff_common::staff_aoe_looping_sound( n_local_client_num, "wpn_lightningstaff_ball", undefined, undefined, 0 );
	}
	else
	{
		self notify( "staff_shake_and_rumble" );
		self notify( "staff_aoe_looping_sound_end" );
		stopFx( n_local_client_num, self.fx_lightning_staff_ball );
		self.fx_lightning_staff_ball = undefined;
	}
}

function staff_lightning_impact_play_fx( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump )
{
	self notify( "staff_lightning_impact_play_fx" );
	self endon( "staff_lightning_impact_play_fx" );
	self endon( "entityshutdown" );
	
	if ( isDefined( self.fx_staff_lightning_impact_torso ) )
		stopFx( n_local_client_num, self.fx_staff_lightning_impact_torso );
		self.fx_staff_lightning_impact_torso = undefined;
	
	str_tag = ( isDefined( self.str_staff_lightning_impact_fx_tag ) ? self.str_staff_lightning_impact_fx_tag : "dlc5/zmb_weapon/fx_staff_elec_impact_ug_hit_torso" );
		
	self.fx_staff_lightning_impact_torso = playFxOnTag( n_local_client_num, "dlc5/zmb_weapon/fx_staff_elec_impact_ug_hit_torso", self, str_tag );
	setFxIgnorePause( n_local_client_num, self.fx_staff_lightning_impact_torso, 1 );
	self playSound( n_local_client_num, "wpn_imp_lightningstaff" );
	
	wait 2;
	
	if ( isDefined( self.fx_staff_lightning_impact_torso ) )
		stopFx( n_local_client_num, self.fx_staff_lightning_impact_torso );
	
	self.fx_staff_lightning_impact_torso = undefined;
}

function staff_lightning_shock_eyes_fx( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump )
{
	self notify( "staff_lightning_shock_eyes_fx_callback" );
	self endon( "staff_lightning_shock_eyes_fx_callback" );
	self endon( "entityshutdown" );
	
	if ( isDefined( self.fx_staff_lightning_shock_eyes ) )
		stopFx( n_local_client_num, self.fx_staff_lightning_shock_eyes );
		self.fx_staff_lightning_shock_eyes = undefined;

	self.fx_staff_lightning_shock_eyes = playFxOnTag( n_local_client_num, "dlc5/zmb_weapon/fx_staff_elec_impact_ug_hit_eyes", self, "j_eyeball_le" );
	setFxIgnorePause( n_local_client_num, self.fx_staff_lightning_shock_eyes, 1 );
	
	wait 2;
	
	if ( isDefined( self.fx_staff_lightning_shock_eyes ) )
		stopFx( n_local_client_num, self.fx_staff_lightning_shock_eyes );
	
	self.fx_staff_lightning_shock_eyes = undefined;
}

function staff_lightning_parasite_init()
{
	self.str_staff_lightning_impact_fx_tag = "j_spine1";
}