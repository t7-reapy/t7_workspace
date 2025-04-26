#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\system_shared;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_perk_utility;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_perk_deadshot.gsh;

#precache( "client_fx", DEADSHOT_MACHINE_LIGHT_FX );
#precache( "client_fx", DEADSHOT_VULTUREAID_WAYPOINT );

#namespace zm_perk_deadshot;

REGISTER_SYSTEM_EX( "zm_perk_deadshot", &__init__, &__main__, undefined )

//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------
function __init__()
{
	if ( IS_TRUE( DEADSHOT_LEVEL_USE_PERK ) )
		enable_deadshot_perk_for_level();
	
}

function __main__()
{
	if ( IS_TRUE( DEADSHOT_LEVEL_USE_PERK ) )
		deadshot_main();
	
}

function enable_deadshot_perk_for_level()
{
	zm_perks::register_perk_clientfields( DEADSHOT_PERK, &deadshot_client_field_func, &deadshot_code_callback_func );
	zm_perks::register_perk_effects( DEADSHOT_PERK, DEADSHOT_PERK );
	zm_perks::register_perk_init_thread( DEADSHOT_PERK, &deadshot_init );
	zm_perk_utility::vulture_aid_register_perk_fx( DEADSHOT_PERK, DEADSHOT_MACHINE_DISABLED_MODEL, DEADSHOT_MACHINE_ACTIVE_MODEL, DEADSHOT_VULTUREAID_WAYPOINT );
}

function deadshot_init()
{
	level._effect[ DEADSHOT_PERK ]= DEADSHOT_MACHINE_LIGHT_FX;
}

function deadshot_client_field_func()
{
	clientfield::register( "clientuimodel", DEADSHOT_CLIENTFIELD, VERSION_SHIP, 2, "int", undefined, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "clientuimodel", DEADSHOT_UI_GLOW_CLIENTFIELD, VERSION_SHIP, 1, "int", undefined, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "toplayer", DEADSHOT_SCRIPT_STRING, VERSION_SHIP, 1, "int", &deadshot_perk_player_handler, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT ); 
}

function deadshot_code_callback_func() {}

//-----------------------------------------------------------------------------------
// FUNCTIONALITY
//-----------------------------------------------------------------------------------
function deadshot_main()
{
}

function deadshot_perk_player_handler( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	if ( !self isLocalPlayer() || isSpectating( n_local_client_num, 0 ) || ( ( isDefined( level.localPlayers[ n_local_client_num ] ) ) && ( self getEntityNumber() != level.localPlayers[ n_local_client_num ] getEntityNumber() ) ) )
		return;
	
	if ( IS_TRUE( n_new_val ) )
		self useAlternateAimParams();
	else
		self clearAlternateAimParams();
	
}