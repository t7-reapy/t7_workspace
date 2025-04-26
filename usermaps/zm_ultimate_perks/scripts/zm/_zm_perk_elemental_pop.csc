#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_perk_utility;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_perk_elemental_pop.gsh;

#precache( "client_fx", ELEMENTAL_POP_MACHINE_LIGHT_FX );
#precache( "client_fx", ELEMENTAL_POP_VULTUREAID_WAYPOINT );

#namespace zm_perk_elemental_pop;

REGISTER_SYSTEM_EX( "zm_perk_elemental_pop", &__init__, &__main__, undefined )

//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------	
function __init__()
{
	if ( IS_TRUE( ELEMENTAL_POP_LEVEL_USE_PERK ) )
		enable_elemental_pop_perk_for_level();
	
}

function __main__()
{
	if ( IS_TRUE( ELEMENTAL_POP_LEVEL_USE_PERK ) )
		elemental_pop_main();
	
}

function enable_elemental_pop_perk_for_level()
{
	zm_perks::register_perk_clientfields( ELEMENTAL_POP_PERK, &elemental_pop_client_field_func, &elemental_pop_callback_func );
	zm_perks::register_perk_effects( ELEMENTAL_POP_PERK, ELEMENTAL_POP_PERK );
	zm_perks::register_perk_init_thread( ELEMENTAL_POP_PERK, &elemental_pop_init );
	zm_perk_utility::vulture_aid_register_perk_fx( ELEMENTAL_POP_PERK, ELEMENTAL_POP_MACHINE_DISABLED_MODEL, ELEMENTAL_POP_MACHINE_ACTIVE_MODEL, ELEMENTAL_POP_VULTUREAID_WAYPOINT );
}

function elemental_pop_init()
{
	level._effect[ ELEMENTAL_POP_PERK ] = ELEMENTAL_POP_MACHINE_LIGHT_FX;
}

function elemental_pop_client_field_func() 
{
	clientfield::register( "clientuimodel", ELEMENTAL_POP_CLIENTFIELD, VERSION_SHIP, 2, "int", undefined, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "clientuimodel", ELEMENTAL_POP_UI_GLOW_CLIENTFIELD, VERSION_SHIP, 1, "int", undefined, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
}

function elemental_pop_callback_func() {}

//-----------------------------------------------------------------------------------
// FUNCTIONALITY
//-----------------------------------------------------------------------------------
function elemental_pop_main()
{
}