#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_perk_utility;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_perk_electric_cherry.gsh;

#precache( "client_fx", ELECTRIC_CHERRY_MACHINE_LIGHT_FX );
#precache( "client_fx", ELECTRIC_CHERRY_EXPLODE_FX );
#precache( "client_fx", ELECTRIC_CHERRY_AI_SHOCK_FX );
#precache( "client_fx", ELECTRIC_CHERRY_AI_EYE_FX );
#precache( "client_fx", ELECTRIC_CHERRY_VEHICLE_SHOCK_TRAIL_FX );
#precache( "client_fx", ELECTRIC_CHERRY_VEHICLE_SHOCK_FX );
#precache( "client_fx", ELECTRIC_CHERRY_VULTUREAID_WAYPOINT );

#namespace zm_perk_electric_cherry;

REGISTER_SYSTEM_EX( "zm_perk_electric_cherry", &__init__, &__main__, undefined )

//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------
function __init__()
{
	script = toLower( getDvarString( "mapname" ) );
	if ( script == "zm_factory" || script == "zm_zod" || script == "zm_prototype" || script == "zm_asylum" || script == "zm_sumpf" || script == "zm_theater" || script == "zm_cosmodrome" || script == "zm_temple" || script == "zm_moon" )
		return;
		
	if ( IS_TRUE( ELECTRIC_CHERRY_LEVEL_USE_PERK ) )
		enable_electric_cherry_perk_for_level();
	
}

function __main__()
{
	script = toLower( getDvarString( "mapname" ) );
	if ( script == "zm_factory" || script == "zm_zod" || script == "zm_prototype" || script == "zm_asylum" || script == "zm_sumpf" || script == "zm_theater" || script == "zm_cosmodrome" || script == "zm_temple" || script == "zm_moon" )
		return;
	
	if ( IS_TRUE( ELECTRIC_CHERRY_LEVEL_USE_PERK ) )
		electric_cherry_main();
	
}

function enable_electric_cherry_perk_for_level()
{
	zm_perks::register_perk_clientfields( ELECTRIC_CHERRY_PERK, &electric_cherry_client_field_func, &electric_cherry_code_callback_func );
	zm_perks::register_perk_effects( ELECTRIC_CHERRY_PERK, ELECTRIC_CHERRY_PERK );
	zm_perks::register_perk_init_thread( ELECTRIC_CHERRY_PERK, &electric_cherry_init );
	zm_perk_utility::vulture_aid_register_perk_fx( ELECTRIC_CHERRY_PERK, ELECTRIC_CHERRY_MACHINE_DISABLED_MODEL, ELECTRIC_CHERRY_MACHINE_ACTIVE_MODEL, ELECTRIC_CHERRY_VULTUREAID_WAYPOINT );
}

function electric_cherry_init()
{
	level._effect[ ELECTRIC_CHERRY_PERK ]	= ELECTRIC_CHERRY_MACHINE_LIGHT_FX;
}

function electric_cherry_client_field_func() 
{
	clientfield::register( "clientuimodel", ELECTRIC_CHERRY_CLIENTFIELD, VERSION_SHIP, 2, "int", undefined, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "allplayers", ELECTRIC_CHERRY_RELOAD_FX_CF, VERSION_SHIP, 1, "int", &electric_cherry_reload_attack_fx, 	!CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "actor", ELECTRIC_CHERRY_TESLA_DEATH_FX_CF, VERSION_SHIP, 1, "int", &tesla_death_fx_callback, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "vehicle", ELECTRIC_CHERRY_TESLA_DEATH_FX_VEH_CF, VERSION_TU10, 1, "int", &tesla_death_fx_veh_callback, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "actor", ELECTRIC_CHERRY_TESLA_SHOCK_EYES_FX_CF, VERSION_SHIP, 1, "int", &tesla_shock_eyes_fx_callback, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "vehicle", ELECTRIC_CHERRY_TESLA_SHOCK_EYES_FX_VEH_CF, VERSION_TU10, 1, "int", &tesla_shock_eyes_fx_veh_callback, 	!CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
}

function electric_cherry_code_callback_func() {}

//-----------------------------------------------------------------------------------
// FUNCTIONALITY
//-----------------------------------------------------------------------------------
function electric_cherry_main()
{
	level._effect[ "electric_cherry_explode" ]	= ELECTRIC_CHERRY_EXPLODE_FX;
	level._effect[ "tesla_death_cherry" ] = ELECTRIC_CHERRY_AI_SHOCK_FX;
	level._effect[ "tesla_shock_eyes_cherry" ] = ELECTRIC_CHERRY_AI_EYE_FX;
	level._effect[ "electric_cherry_trail" ] = ELECTRIC_CHERRY_VEHICLE_SHOCK_TRAIL_FX;
	level._effect[ "tesla_shock_cherry" ] = ELECTRIC_CHERRY_VEHICLE_SHOCK_FX;
}

function electric_cherry_reload_attack_fx( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{	
	if ( isDefined( self.fx_electric_cherry_reload_fx ) )
		stopFX( n_local_client_num, self.fx_electric_cherry_reload_fx );			
	
	if ( IS_TRUE( n_new_val ) )
		self.fx_electric_cherry_reload_fx = playFXOnTag( n_local_client_num, level._effect[ "electric_cherry_explode" ], self, "tag_origin" );
	else
	{
		if ( isDefined( self.fx_electric_cherry_reload_fx ) )
			stopFX( n_local_client_num, self.fx_electric_cherry_reload_fx );			
		
		self.fx_electric_cherry_reload_fx = undefined;
	}
}

function tesla_death_fx_callback( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	if ( IS_TRUE( n_new_val ) )
	{
		str_tag = "j_spineupper";

		if ( isDefined( self.str_tag_tesla_death_fx ) )
			str_tag = self.str_tag_tesla_death_fx;
		else if ( IS_TRUE( self.isdog ) )
			str_tag = "j_spine1";
		
		self.fx_death_fx = playFXOnTag( n_local_client_num, level._effect[ "tesla_death_cherry" ], self, str_tag );
		setFXIgnorePause( n_local_client_num, self.fx_death_fx, 1 );
	}
	else
	{
		if ( isDefined( self.fx_death_fx ) )
		{
			deleteFx( n_local_client_num, self.fx_death_fx, 1 );
			self.fx_death_fx = undefined;
		}
	}		
}

function tesla_death_fx_veh_callback( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	if ( IS_TRUE( n_new_val ) )
	{
		str_tag = "j_spineupper";

		if ( isDefined( self.str_tag_tesla_death_fx ) )
			str_tag = self.str_tag_tesla_death_fx;
		
		self.fx_death_fx = playFXOnTag( n_local_client_num, level._effect[ "tesla_shock_cherry" ], self, str_tag );
		setFXIgnorePause( n_local_client_num, self.fx_death_fx, 1 );
	}
	else
	{
		if ( isDefined( self.fx_death_fx ) )
		{
			deleteFx( n_local_client_num, self.fx_death_fx, 1 );
			self.fx_death_fx = undefined;
		}
	}		
}

function tesla_shock_eyes_fx_callback( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	if ( IS_TRUE( n_new_val ) )
	{
		str_tag = "j_spineupper";

		if ( isDefined( self.str_tag_tesla_shock_eyes_fx ) )
			str_tag = self.str_tag_tesla_shock_eyes_fx;
		else if ( IS_TRUE( self.isdog ) )
			str_tag = "j_spine1";
		
		self.fx_shock_eyes_fx = playFXOnTag( n_local_client_num, level._effect[ "tesla_shock_eyes_cherry" ], self, "j_eyeball_le" );
		SetFXIgnorePause( n_local_client_num, self.fx_shock_eyes_fx, 1 );
		
		self.fx_shock_fx = playFXOnTag( n_local_client_num, level._effect[ "tesla_death_cherry" ], self, str_tag );
		setFXIgnorePause( n_local_client_num, self.fx_shock_fx, 1 );
	}
	else
	{
		if ( isDefined( self.fx_shock_eyes_fx ) )
		{
			deleteFx( n_local_client_num, self.fx_shock_eyes_fx, 1 );
			self.fx_shock_eyes_fx = undefined;		
		}
		
		if ( isDefined( self.fx_shock_fx ) )
		{
			deleteFx( n_local_client_num, self.fx_shock_fx, 1 );
			self.fx_shock_fx = undefined;
		}
	}		
}

function tesla_shock_eyes_fx_veh_callback( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	if ( IS_TRUE( n_new_val ) )
	{
		str_tag = "j_spineupper";

		if ( isDefined( self.str_tag_tesla_shock_eyes_fx ) )
			str_tag = self.str_tag_tesla_shock_eyes_fx;
		
		self.fx_shock_eyes_fx = playFXOnTag( n_local_client_num, level._effect[ "electric_cherry_trail" ], self, str_tag );
		SetFXIgnorePause( n_local_client_num, self.fx_shock_eyes_fx, 1 );
		
		self.fx_shock_fx = playFXOnTag( n_local_client_num, level._effect[ "tesla_shock_cherry" ], self, str_tag );
		setFXIgnorePause( n_local_client_num, self.fx_shock_fx, 1 );
	}
	else
	{
		if ( isDefined( self.fx_shock_eyes_fx ) )
		{
			deleteFx( n_local_client_num, self.fx_shock_eyes_fx, 1 );
			self.fx_shock_eyes_fx = undefined;		
		}
		
		if ( isDefined( self.fx_shock_fx ) )
		{
			deleteFx( n_local_client_num, self.fx_shock_fx, 1 );
			self.fx_shock_fx = undefined;
		}
	}		
}