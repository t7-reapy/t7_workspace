#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_perk_utility;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_perk_quick_revive.gsh;

#precache( "client_fx", QUICK_REVIVE_MACHINE_LIGHT_FX );
#precache( "client_fx", QUICK_REVIVE_VULTUREAID_WAYPOINT );

#namespace zm_perk_quick_revive;

REGISTER_SYSTEM_EX( "zm_perk_quick_revive", &__init__, &__main__, undefined )

//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------
function __init__()
{
	if ( IS_TRUE( QUICK_REVIVE_LEVEL_USE_PERK ) )
		enable_quick_revive_perk_for_level();
	
}

function __main__()
{
	if ( IS_TRUE( QUICK_REVIVE_LEVEL_USE_PERK ) )
		quick_revive_main();
	
}

function enable_quick_revive_perk_for_level()
{
	zm_perks::register_perk_clientfields( QUICK_REVIVE_PERK, &quick_revive_client_field_func, &quick_revive_callback_func );
	zm_perks::register_perk_effects( QUICK_REVIVE_PERK, QUICK_REVIVE_PERK );
	zm_perks::register_perk_init_thread( QUICK_REVIVE_PERK, &quick_revive_init );
	zm_perk_utility::vulture_aid_register_perk_fx( QUICK_REVIVE_PERK, QUICK_REVIVE_MACHINE_DISABLED_MODEL, QUICK_REVIVE_MACHINE_ACTIVE_MODEL, QUICK_REVIVE_VULTUREAID_WAYPOINT );
}

function quick_revive_init()
{
	level._effect[ QUICK_REVIVE_PERK ] = QUICK_REVIVE_MACHINE_LIGHT_FX;
}

function quick_revive_client_field_func() 
{
	clientfield::register( "clientuimodel", QUICK_REVIVE_CLIENTFIELD, VERSION_SHIP, 2, "int", undefined, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
}

function quick_revive_callback_func() {}

//-----------------------------------------------------------------------------------
// FUNCTIONALITY
//-----------------------------------------------------------------------------------
function quick_revive_main()
{
}