#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_perk_utility;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_perk_tombstone.gsh;

#precache( "client_fx", TOMBSTONE_MACHINE_LIGHT_FX );
#precache( "client_fx", TOMBSTONE_VULTUREAID_WAYPOINT );

#namespace zm_perk_tombstone;

REGISTER_SYSTEM_EX( "zm_perk_tombstone", &__init__, &__main__, undefined )
	
//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------
function __init__()
{
	if ( IS_TRUE( TOMBSTONE_LEVEL_USE_PERK ) )
		enable_tombstone_perk_for_level();
	
}

function __main__()
{
	if ( IS_TRUE( TOMBSTONE_LEVEL_USE_PERK ) )
		tombstone_main();
	
}

function enable_tombstone_perk_for_level()
{
	zm_perks::register_perk_clientfields( TOMBSTONE_PERK, &tombstone_client_field_func, &tombstone_code_callback_func );
	zm_perks::register_perk_effects( TOMBSTONE_PERK, TOMBSTONE_PERK );
	zm_perks::register_perk_init_thread( TOMBSTONE_PERK, &tombstone_init );
	zm_perk_utility::vulture_aid_register_perk_fx( TOMBSTONE_PERK, TOMBSTONE_MACHINE_DISABLED_MODEL, TOMBSTONE_MACHINE_ACTIVE_MODEL, TOMBSTONE_VULTUREAID_WAYPOINT );
}

function tombstone_init()
{
	level._effect[ TOMBSTONE_PERK ] = TOMBSTONE_MACHINE_LIGHT_FX;
}

function tombstone_client_field_func() 
{
	clientfield::register( "clientuimodel", TOMBSTONE_CLIENTFIELD, VERSION_SHIP, 2, "int", undefined, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
}

function tombstone_code_callback_func() {}

//-----------------------------------------------------------------------------------
// FUNCTIONALITY
//-----------------------------------------------------------------------------------
function tombstone_main()
{
}