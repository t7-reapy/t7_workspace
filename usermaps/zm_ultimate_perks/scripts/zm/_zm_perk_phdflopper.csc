#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_perk_utility;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_perk_phdflopper.gsh;

#precache( "client_fx", PHDFLOPPER_MACHINE_LIGHT_FX );
#precache( "client_fx", PHDFLOPPER_VULTUREAID_WAYPOINT );
#precache( "client_fx", PHDFLOPPER_TRAIL_FX );
#precache( "client_fx", PHDFLOPPER_EXPLODE_FX );

#namespace zm_perk_phdflopper;

REGISTER_SYSTEM_EX( "zm_perk_phdflopper", &__init__, &__main__, undefined )

//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------
function __init__()
{
	if ( IS_TRUE( PHDFLOPPER_LEVEL_USE_PERK ) )
		enable_phdflopper_perk_for_level();
	
}

function __main__()
{
	if ( IS_TRUE( PHDFLOPPER_LEVEL_USE_PERK ) )
		phdflopper_main();
	
}

function enable_phdflopper_perk_for_level()
{
	zm_perks::register_perk_clientfields( PHDFLOPPER_PERK, &phdflopper_client_field_func, &phdflopper_code_callback_func );
	zm_perks::register_perk_effects( PHDFLOPPER_PERK, PHDFLOPPER_PERK );
	zm_perks::register_perk_init_thread( PHDFLOPPER_PERK, &phdflopper_init );
	zm_perk_utility::vulture_aid_register_perk_fx( PHDFLOPPER_PERK, PHDFLOPPER_MACHINE_DISABLED_MODEL, PHDFLOPPER_MACHINE_ACTIVE_MODEL, PHDFLOPPER_VULTUREAID_WAYPOINT );
}

function phdflopper_init()
{
	level._effect[ PHDFLOPPER_PERK ] = PHDFLOPPER_MACHINE_LIGHT_FX;
}

function phdflopper_client_field_func() 
{
	clientfield::register( "clientuimodel", PHDFLOPPER_CLIENTFIELD, VERSION_SHIP, 2, "int", undefined, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "missile", PHDFLOPPER_MULTIGRENADE_TRAIL_FX_CF,	VERSION_SHIP, 1, "int", &phdflopper_multigrenade_trail_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "allplayers", PHDFLOPPER_SLIDE_EXPLODE_FX_CF, VERSION_SHIP, 1, "int", &phdflopper_slide_explode_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
}

function phdflopper_code_callback_func() {}

//-----------------------------------------------------------------------------------
// FUNCTIONALITY
//-----------------------------------------------------------------------------------
function phdflopper_main()
{
	visionset_mgr::register_visionset_info( PHDFLOPPER_VISION_STRING, VERSION_SHIP, 400, undefined, PHDFLOPPER_VISION );
}

function phdflopper_multigrenade_trail_fx( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	if ( IS_TRUE( n_new_val ) )
		self.fx_phdflopper_multigrenade_trail = playFXOnTag( n_local_client_num, PHDFLOPPER_TRAIL_FX, self, "tag_origin" );
	else
	{
		if ( isDefined( self.fx_phdflopper_multigrenade_trail ) )
			stopFX( n_local_client_num, self.fx_phdflopper_multigrenade_trail );			
		
		self.fx_phdflopper_multigrenade_trail = undefined;
	}
}

function phdflopper_slide_explode_fx( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	if ( IS_TRUE( n_new_val ) )
		self.fx_phdflopper_explosion = playFx( n_local_client_num, PHDFLOPPER_EXPLODE_FX, self.origin );
	else
	{
		if ( isDefined( self.fx_phdflopper_explosion ) )
			stopFX( n_local_client_num, self.fx_phdflopper_explosion );			
		
		self.fx_phdflopper_explosion = undefined;
	}
}
