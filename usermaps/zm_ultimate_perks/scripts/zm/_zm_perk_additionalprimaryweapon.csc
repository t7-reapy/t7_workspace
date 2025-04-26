#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_perk_utility;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\zm\_zm_perk_additionalprimaryweapon.gsh;

#precache( "client_fx", ADDITIONAL_PRIMARY_WEAPON_MACHINE_LIGHT_FX );
#precache( "client_fx", ADDITIONAL_PRIMARY_WEAPON_VULTUREAID_WAYPOINT );

#namespace zm_perk_additionalprimaryweapon;

REGISTER_SYSTEM_EX( "zm_perk_additionalprimaryweapon", &__init__, &__main__, undefined )

//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------	
function __init__()
{
	if ( IS_TRUE( ADDITIONAL_PRIMARY_WEAPON_LEVEL_USE_PERK ) )
		enable_additional_primary_weapon_perk_for_level();
	
}

function __main__()
{
	if ( IS_TRUE( ADDITIONAL_PRIMARY_WEAPON_LEVEL_USE_PERK ) )
		addtional_primary_main();
	
}

function enable_additional_primary_weapon_perk_for_level()
{
	zm_perks::register_perk_clientfields( ADDITIONAL_PRIMARY_WEAPON_PERK, &additional_primary_weapon_client_field_func, &additional_primary_weapon_code_callback_func );
	zm_perks::register_perk_effects( ADDITIONAL_PRIMARY_WEAPON_PERK, ADDITIONAL_PRIMARY_WEAPON_PERK );
	zm_perks::register_perk_init_thread( ADDITIONAL_PRIMARY_WEAPON_PERK, &additional_primary_weapon_init );
	zm_perk_utility::vulture_aid_register_perk_fx( ADDITIONAL_PRIMARY_WEAPON_PERK, ADDITIONAL_PRIMARY_WEAPON_MACHINE_DISABLED_MODEL, ADDITIONAL_PRIMARY_WEAPON_MACHINE_ACTIVE_MODEL, ADDITIONAL_PRIMARY_WEAPON_VULTUREAID_WAYPOINT );
}

function additional_primary_weapon_init()
{
	level._effect[ ADDITIONAL_PRIMARY_WEAPON_PERK ]	= ADDITIONAL_PRIMARY_WEAPON_MACHINE_LIGHT_FX;	
}

function additional_primary_weapon_client_field_func() 
{
	clientfield::register( "clientuimodel", ADDITIONAL_PRIMARY_WEAPON_UI_GLOW_CLIENTFIELD, VERSION_SHIP, 1, "int", undefined, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "clientuimodel", ADDITIONAL_PRIMARY_WEAPON_CLIENTFIELD, VERSION_SHIP, 2, "int", undefined, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
}

function additional_primary_weapon_code_callback_func() {}

//-----------------------------------------------------------------------------------
// FUNCTIONALITY
//-----------------------------------------------------------------------------------
function addtional_primary_main() {}