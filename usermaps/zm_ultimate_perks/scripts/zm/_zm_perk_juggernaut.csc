#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_perk_utility;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_perk_juggernaut.gsh;

#precache( "client_fx", JUGGERNAUT_MACHINE_LIGHT_FX );
#precache( "client_fx", JUGGERNAUT_VULTUREAID_WAYPOINT );

#namespace zm_perk_juggernaut;

REGISTER_SYSTEM_EX( "zm_perk_juggernaut", &__init__, &__main__, undefined )

//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------
function __init__()
{
	if ( IS_TRUE( JUGGERNAUT_LEVEL_USE_PERK ) )
		enable_juggernaut_perk_for_level();
	
}

function __main__()
{
	if ( IS_TRUE( JUGGERNAUT_LEVEL_USE_PERK ) )
		juggernaut_main();
	
}

function enable_juggernaut_perk_for_level()
{
	zm_perks::register_perk_clientfields( JUGGERNAUT_PERK, &juggernaut_client_field_func, &juggernaut_code_callback_func );
	zm_perks::register_perk_effects( JUGGERNAUT_PERK, JUGGERNAUT_PERK );
	zm_perks::register_perk_init_thread( JUGGERNAUT_PERK, &juggernaut_init );
	zm_perk_utility::vulture_aid_register_perk_fx( JUGGERNAUT_PERK, JUGGERNAUT_MACHINE_DISABLED_MODEL, JUGGERNAUT_MACHINE_ACTIVE_MODEL, JUGGERNAUT_VULTUREAID_WAYPOINT );
}

function juggernaut_init()
{
	level._effect[ JUGGERNAUT_PERK ] = JUGGERNAUT_MACHINE_LIGHT_FX;	
}

function juggernaut_client_field_func() 
{
	clientfield::register( "clientuimodel", JUGGERNAUT_CLIENTFIELD, 					VERSION_SHIP, 2, "int", undefined, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
}

function juggernaut_code_callback_func() {}

//-----------------------------------------------------------------------------------
// FUNCTIONALITY
//-----------------------------------------------------------------------------------
function juggernaut_main()
{
}