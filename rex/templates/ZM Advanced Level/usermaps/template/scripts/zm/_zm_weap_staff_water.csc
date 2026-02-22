#using scripts\codescripts\struct;
#using scripts\shared\ai_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\duplicaterender_mgr;
#using scripts\shared\duplicaterenderbundle;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_weap_staff_common;

#insert scripts\shared\duplicaterender.gsh;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#precache( "client_fx", "dlc5/zmb_weapon/fx_staff_ice_impact_ug_hit" );
#precache( "client_fx", "dlc5/zmb_weapon/fx_staff_ice_trail_bolt" );
#precache( "client_fx", "dlc5/zmb_weapon/fx_staff_charge_ice_lv1" );

#namespace zm_weap_staff_water; 

REGISTER_SYSTEM_EX( "zm_weap_staff_water", &__init__, &__main__, undefined )

function __init__()
{
	level.a_staff_water_weaponfiles = [];

	staff_water_register_weapon_for_level( "staff_water" );
	staff_water_register_weapon_for_level( "staff_water_upgraded" );
	staff_water_register_weapon_for_level( "staff_water_upgraded2" );
	staff_water_register_weapon_for_level( "staff_water_upgraded3" );

	clientfield::register( "scriptmover", "staff_water_blizzard_fx", VERSION_SHIP, 1,"int", &staff_water_blizzard_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "actor", "staff_water_freeze_zombie", VERSION_SHIP, 1, "int", &staff_water_freeze_zombie, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "vehicle", "staff_water_freeze_zombie", VERSION_SHIP, 1,	"int", &staff_water_freeze_zombie, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "actor", "staff_water_freeze_fx", VERSION_SHIP, 1, "int", &staff_water_freeze_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "vehicle", "staff_water_freeze_fx", VERSION_SHIP, 1, "int", &staff_water_freeze_fx, CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );

	duplicate_render::set_dr_filter_framebuffer_duplicate( "staff_water_freeze", 10, "staff_water_freeze_on", undefined, DR_TYPE_FRAMEBUFFER_DUPLICATE, "mc/mtl_freezeover", DR_CULL_NEVER );

	ai::add_archetype_spawn_function( "parasite", &staff_water_parasite_init );
}

function __main__()
{
}

function staff_water_register_weapon_for_level( str_weapon )
{
	DEFAULT( level.a_staff_water_weaponfiles, [] );
	
	a_weapon_data = tableLookupRow( "gamedata/weapons/zm/staff_water_settings.csv", tableLookupRowNum( "gamedata/weapons/zm/staff_water_settings.csv", 0, str_weapon ) );
	if ( !isDefined( a_weapon_data ) )
		a_weapon_data = tableLookupRow( "gamedata/weapons/zm/staff_water_settings.csv", tableLookupRowNum( "gamedata/weapons/zm/staff_water_settings.csv", 0, "default" ) );
	if ( !isDefined( a_weapon_data ) )	
		return;
	
	w_weapon 						= getWeapon( str_weapon );
	w_weapon.b_is_upgrade			= ( toLower( a_weapon_data[ true ] ) == "true" );
	w_weapon.n_damage				= int( a_weapon_data[ 2 ] );
	w_weapon.n_cone_fov				= int( a_weapon_data[ 3 ] );
	w_weapon.n_cone_range			= int( a_weapon_data[ 4 ] );
	w_weapon.n_blizzard_lifetime	= float( a_weapon_data[ 5 ] );
	w_weapon.n_blizzard_range		= int( a_weapon_data[ 6 ] );
	zm_weap_staff_common::register_staff_weapon_for_level( w_weapon, undefined, undefined, undefined, undefined, undefined, undefined, undefined, &staff_water_charge_up_effects_cb, undefined, "dlc5/zmb_weapon/fx_staff_charge_ice_lv1" );
	
	ARRAY_ADD( level.a_staff_water_weaponfiles, w_weapon );
}


function staff_water_charge_up_effects_cb( n_local_client_num, w_weapon, n_charge_level = 0 )
{
	self zm_weap_staff_common::play_staff_charge_up_sounds( n_local_client_num, w_weapon, n_charge_level, "wpn_waterstaff_charge_" + n_charge_level, ( n_charge_level == 1 ? "wpn_waterstaff_charge_loop" : undefined ) );
}

function staff_water_blizzard_fx( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump )
{
	if ( IS_TRUE( n_new_value ) )
	{
		self.fx_water_staff_blizzard = playFxOnTag( n_local_client_num, "dlc5/zmb_weapon/fx_staff_ice_impact_ug_hit", self, "tag_origin" );
		self playRumbleOnEntity( n_local_client_num, "artillery_rumble" );
		self thread zm_weap_staff_common::staff_shake_and_rumble( n_local_client_num, .3, 1, 100, "artillery_rumble" );
		self thread zm_weap_staff_common::staff_aoe_looping_sound( n_local_client_num, "wpn_waterstaff_storm", "wpn_waterstaff_storm_imp", undefined, 1.5, 1.5 );
	}
	else
	{
		self notify( "staff_shake_and_rumble" );
		self notify( "staff_aoe_looping_sound_end" );
		stopFx( n_local_client_num, self.fx_water_staff_blizzard );
		self.fx_water_staff_blizzard = undefined;
	}
}

function staff_water_freeze_fx( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump ) 
{
	self notify( "staff_water_freeze_fx" );
	self endon( "staff_water_freeze_fx" );
	self endon( "entityshutdown" );
	
	if ( IS_TRUE( n_new_value ) )
	{
		if ( isDefined( self.fx_water_staff_frozen ) )
			deleteFx( n_local_client_num, self.fx_water_staff_frozen, 1 );
		
		self.fx_water_staff_frozen = playFxOnTag( n_local_client_num, "dlc5/zmb_weapon/fx_staff_ice_trail_bolt", self, ( isDefined( self.str_staff_water_freeze_fx_tag_override ) ? self.str_staff_water_freeze_fx_tag_override : "j_spine4" ) );
	}
	else
	{
		if ( isDefined( self.fx_water_staff_frozen ) )
			deleteFx( n_local_client_num, self.fx_water_staff_frozen, 1 );
		
		self.fx_water_staff_frozen = undefined;
	
	}
}

function staff_water_freeze_zombie( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump ) 
{
	self notify( "staff_water_freeze_zombie" );
	self endon( "staff_water_freeze_zombie" );
	self endon( "entityshutdown" );

	if ( !isDefined( self ) )
		return;

	if ( !isDefined( self.n_water_staff_frozen ) )
		self.n_water_staff_frozen = ( IS_TRUE( n_new_value ) ? .02 : 0 );
	
	if ( IS_TRUE( n_new_value ) )
	{
		self duplicate_render::set_dr_flag( "staff_water_freeze_on", n_new_value );
		self duplicate_render::update_dr_filters( n_local_client_num );
		self playSound( n_local_client_num, "wpn_waterstaff_freeze_zombie" );
	}
	n_incriment = ( IS_TRUE( n_new_value ) ? .02 : 0 - .01 );
	
	n_emmisive_buff = 1;
	
	self mapShaderConstant( n_local_client_num, 0, "scriptVector0", self.n_water_staff_frozen, self.n_water_staff_frozen, self.n_water_staff_frozen, self.n_water_staff_frozen );
	self mapShaderConstant( n_local_client_num, 8, "scriptVector2", self.n_water_staff_frozen * n_emmisive_buff, self.n_water_staff_frozen * n_emmisive_buff, 0, 0 );
	while ( isDefined( self ) )
	{
		if ( self.n_water_staff_frozen > 1 && IS_TRUE( n_new_value ) )
		{
			self.n_water_staff_frozen = 1;
			self mapShaderConstant( n_local_client_num, 0, "scriptVector0", 1, 1, 1, 1 );
			self mapShaderConstant( n_local_client_num, 8, "scriptVector2", n_emmisive_buff, n_emmisive_buff, 0, 0 );
			self notify( "staff_water_freeze_zombie" );
		}
		else if ( self.n_water_staff_frozen < 0 && !IS_TRUE( n_new_value ) )
		{
			self.n_water_staff_frozen = 0;
			self mapShaderConstant( n_local_client_num, 0, "scriptVector0", 0, 0, 0, 0 );
			self mapShaderConstant( n_local_client_num, 8, "scriptVector2", 0, 0, 0, 0 );
			break;
		}
		
		self.n_water_staff_frozen += n_incriment;
		self mapShaderConstant( n_local_client_num, 0, "scriptVector0", self.n_water_staff_frozen, self.n_water_staff_frozen, self.n_water_staff_frozen, self.n_water_staff_frozen );
		self mapShaderConstant( n_local_client_num, 8, "scriptVector2", self.n_water_staff_frozen * n_emmisive_buff, self.n_water_staff_frozen * n_emmisive_buff, 0, 0 );
		WAIT_CLIENT_FRAME;
	}
	if ( !IS_TRUE( n_new_value ) )
	{
		self duplicate_render::set_dr_flag( "staff_water_freeze_on", n_new_value );
		self duplicate_render::update_dr_filters( n_local_client_num );
	}
}

function staff_water_parasite_init()
{
	self.str_staff_water_gib_tag_override = "j_spine";
}