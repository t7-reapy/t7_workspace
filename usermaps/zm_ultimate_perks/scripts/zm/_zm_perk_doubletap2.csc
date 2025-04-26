#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_perk_utility;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_perk_doubletap2.gsh;

#precache( "client_fx", DOUBLETAP2_MACHINE_LIGHT_FX );
#precache( "client_fx", DOUBLETAP2_VULTUREAID_WAYPOINT );

#namespace zm_perk_doubletap2;

REGISTER_SYSTEM_EX( "zm_perk_doubletap2", &__init__, &__main__, undefined )

//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------
function __init__()
{
	if ( IS_TRUE( DOUBLETAP2_LEVEL_USE_PERK ) )
		enable_double_tap2_perk_for_level();
	
}

function __main__()
{
	if ( IS_TRUE( DOUBLETAP2_LEVEL_USE_PERK ) )
		double_tap2_main();
	
}

function enable_double_tap2_perk_for_level()
{
	zm_perks::register_perk_clientfields( DOUBLETAP2_PERK, &double_tap2_client_field_func, &double_tap2_code_callback_func );
	zm_perks::register_perk_effects( DOUBLETAP2_PERK, DOUBLETAP2_PERK );
	zm_perks::register_perk_init_thread( DOUBLETAP2_PERK, &double_tap2_init );
	zm_perk_utility::vulture_aid_register_perk_fx( DOUBLETAP2_PERK, DOUBLETAP2_MACHINE_DISABLED_MODEL, DOUBLETAP2_MACHINE_ACTIVE_MODEL, DOUBLETAP2_VULTUREAID_WAYPOINT );
}

function double_tap2_init()
{
	level._effect[ DOUBLETAP2_PERK ] = DOUBLETAP2_MACHINE_LIGHT_FX;
}

function double_tap2_client_field_func() 
{
	clientfield::register( "clientuimodel", DOUBLETAP2_CLIENTFIELD, VERSION_SHIP, 2, "int", undefined, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
}

function double_tap2_code_callback_func() {}

//-----------------------------------------------------------------------------------
// FUNCTIONALITY
//-----------------------------------------------------------------------------------
function double_tap2_main() 
{
}