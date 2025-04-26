#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_perk_utility;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_perk_staminup.gsh;

#precache( "client_fx", STAMINUP_MACHINE_LIGHT_FX );
#precache( "client_fx", STAMINUP_VULTUREAID_WAYPOINT );

#namespace zm_perk_staminup;

REGISTER_SYSTEM_EX( "zm_perk_staminup", &__init__, &__main__, undefined )

//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------	
function __init__()
{
	if ( IS_TRUE( STAMINUP_LEVEL_USE_PERK ) )
		enable_staminup_perk_for_level();
	
}

function __main__()
{
	if ( IS_TRUE( STAMINUP_LEVEL_USE_PERK ) )
		staminup_main();
	
}

function enable_staminup_perk_for_level()
{
	zm_perks::register_perk_clientfields( STAMINUP_PERK, &staminup_client_field_func, &staminup_callback_func );
	zm_perks::register_perk_effects( STAMINUP_PERK, STAMINUP_PERK );
	zm_perks::register_perk_init_thread( STAMINUP_PERK, &staminup_init );
	zm_perk_utility::vulture_aid_register_perk_fx( STAMINUP_PERK, STAMINUP_MACHINE_DISABLED_MODEL, STAMINUP_MACHINE_ACTIVE_MODEL, STAMINUP_VULTUREAID_WAYPOINT );
}

function staminup_init()
{
	level._effect[ STAMINUP_PERK ] = STAMINUP_MACHINE_LIGHT_FX;
}

function staminup_client_field_func() 
{
	clientfield::register( "clientuimodel", STAMINUP_CLIENTFIELD, VERSION_SHIP, 2, "int", undefined, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
}

function staminup_callback_func() {}

//-----------------------------------------------------------------------------------
// FUNCTIONALITY
//-----------------------------------------------------------------------------------
function staminup_main()
{
}