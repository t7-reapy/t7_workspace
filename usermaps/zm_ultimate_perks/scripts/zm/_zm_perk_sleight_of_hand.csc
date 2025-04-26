#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_perk_utility;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_perk_sleight_of_hand.gsh;

#precache( "client_fx", SLEIGHT_OF_HAND_MACHINE_LIGHT_FX );
#precache( "client_fx", SLEIGHT_OF_HAND_VULTUREAID_WAYPOINT );

#namespace zm_perk_sleight_of_hand;

REGISTER_SYSTEM_EX( "zm_perk_sleight_of_hand", &__init__, &__main__, undefined )

//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------
function __init__()
{
	if ( IS_TRUE( SLEIGHT_OF_HAND_LEVEL_USE_PERK ) )
		enable_sleight_of_hand_perk_for_level();
	
}

function __main__()
{
	if ( IS_TRUE( SLEIGHT_OF_HAND_LEVEL_USE_PERK ) )
		sleight_of_hand_main();
	
}

function enable_sleight_of_hand_perk_for_level()
{
	zm_perks::register_perk_clientfields( SLEIGHT_OF_HAND_PERK, &sleight_of_hand_client_field_func, &sleight_of_hand_code_callback_func );
	zm_perks::register_perk_effects( SLEIGHT_OF_HAND_PERK, SLEIGHT_OF_HAND_PERK );
	zm_perks::register_perk_init_thread( SLEIGHT_OF_HAND_PERK, &init_sleight_of_hand );
	zm_perk_utility::vulture_aid_register_perk_fx( SLEIGHT_OF_HAND_PERK, SLEIGHT_OF_HAND_MACHINE_DISABLED_MODEL, SLEIGHT_OF_HAND_MACHINE_ACTIVE_MODEL, SLEIGHT_OF_HAND_VULTUREAID_WAYPOINT );
}

function init_sleight_of_hand()
{
	level._effect[ SLEIGHT_OF_HAND_PERK ]	= SLEIGHT_OF_HAND_MACHINE_LIGHT_FX;
}

function sleight_of_hand_client_field_func() 
{
	clientfield::register( "clientuimodel", SLEIGHT_OF_HAND_CLIENTFIELD, VERSION_SHIP, 2, "int", undefined, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
}

function sleight_of_hand_code_callback_func() {}

//-----------------------------------------------------------------------------------
// FUNCTIONALITY
//-----------------------------------------------------------------------------------
function sleight_of_hand_main()
{
}