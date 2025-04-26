#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_perk_utility;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_perk_staminup.gsh;

#precache( "string", "ZOMBIE_PERK_MARATHON" );
#precache( "triggerstring", "ZOMBIE_PERK_MARATHON", STAMINUP_PERK_COST_STRING );
#precache( "fx", STAMINUP_MACHINE_LIGHT_FX );

#namespace zm_perk_staminup;

REGISTER_SYSTEM_EX( "zm_perk_staminup", &__init__, &__main__, undefined )

// CALLBACKS AND OVERRIDES
// 
// NONE

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
	zm_perks::register_perk_basic_info( STAMINUP_PERK, STAMINUP_ALIAS, STAMINUP_PERK_COST, &"ZOMBIE_PERK_MARATHON", getWeapon( STAMINUP_PERK_BOTTLE_WEAPON ) );
	zm_perks::register_perk_precache_func( STAMINUP_PERK, &staminup_precache );
	zm_perks::register_perk_clientfields( STAMINUP_PERK, &staminup_register_clientfield, &staminup_set_clientfield );
	zm_perks::register_perk_machine( STAMINUP_PERK, &staminup_perk_machine_setup );
	zm_perks::register_perk_threads( STAMINUP_PERK, &staminup_give_perk, &staminup_take_perk );
	zm_perks::register_perk_host_migration_params( STAMINUP_PERK, STAMINUP_RADIANT_MACHINE_NAME, STAMINUP_PERK );
	if ( zm_perk_utility::is_stock_map() && ( level.script == "zm_zod" || level.script == "zm_genesis" ) )
		zm_perks::register_perk_machine_power_override( STAMINUP_PERK, &staminup_power_override );
		
	if ( level.script == "zm_asylum" )
		zm_perk_utility::place_perk_machine( ( -134, -392, 226 ), ( 0, 90 + 90, 0 ), STAMINUP_PERK, STAMINUP_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_sumpf" )
		zm_perk_utility::place_perk_machine( ( 11017, 3412, -661 ), ( 0, 130 + 90, 0 ), STAMINUP_PERK, STAMINUP_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_theater" )
		zm_perk_utility::place_perk_machine( ( -1, 908, -87 ), ( 0, -90 + 90, 0 ), STAMINUP_PERK, STAMINUP_MACHINE_DISABLED_MODEL );
		
}

function staminup_precache()
{
	level._effect[ STAMINUP_PERK ] = STAMINUP_MACHINE_LIGHT_FX;
	
	level.machine_assets[ STAMINUP_PERK ] = spawnStruct();
	level.machine_assets[ STAMINUP_PERK ].weapon = getWeapon( STAMINUP_PERK_BOTTLE_WEAPON );
	level.machine_assets[ STAMINUP_PERK ].off_model = STAMINUP_MACHINE_DISABLED_MODEL;
	level.machine_assets[ STAMINUP_PERK ].on_model = STAMINUP_MACHINE_ACTIVE_MODEL;	
}

function staminup_register_clientfield() 
{
	clientfield::register( "clientuimodel", STAMINUP_CLIENTFIELD, VERSION_SHIP, 2, "int" );
}

function staminup_set_clientfield( n_state ) 
{
	if ( n_state != 0 && ( level zm_perk_utility::is_perk_paused( STAMINUP_PERK ) || self zm_perk_utility::is_perk_paused( STAMINUP_PERK ) ) )
		n_state = 2;
	
	self clientfield::set_player_uimodel( STAMINUP_CLIENTFIELD, n_state );
}

function staminup_perk_machine_setup( e_use_trigger, e_perk_machine, e_bump_trigger, e_collision )
{
	e_use_trigger.script_sound = STAMINUP_JINGLE;
	e_use_trigger.script_string = STAMINUP_SCRIPT_STRING;
	e_use_trigger.script_label = STAMINUP_STING;
	e_use_trigger.target = STAMINUP_RADIANT_MACHINE_NAME;
	e_perk_machine.script_string = STAMINUP_SCRIPT_STRING;
	e_perk_machine.targetname = STAMINUP_RADIANT_MACHINE_NAME;
	if ( isDefined( e_bump_trigger ) )
		e_bump_trigger.script_string = STAMINUP_SCRIPT_STRING;
	
	e_perk_machine thread zm_perk_utility::register_vulture_perk_safe();
}

function staminup_give_perk() 
{
	zm_perk_utility::print_version( STAMINUP_PERK, STAMINUP_VERSION );
	
	if ( level zm_perk_utility::is_perk_paused( STAMINUP_PERK ) )
		self zm_perk_utility::player_pause_perk( STAMINUP_PERK );
	
	if ( self zm_perk_utility::is_perk_paused( STAMINUP_PERK ) )
		return;
	
	self staminup_enabled( 1 );
}

function staminup_take_perk( b_pause, str_perk, str_result ) 
{
	self staminup_enabled( 0 );
}

function staminup_power_override()
{
	zm_perk_utility::force_power( STAMINUP_PERK );
}

//-----------------------------------------------------------------------------------
// FUNCTIONALITY
//-----------------------------------------------------------------------------------
function staminup_main()
{
	if ( IS_TRUE( STAMINUP_IN_WONDERFIZZ ) )
		zm_perk_utility::add_perk_to_wunderfizz( STAMINUP_PERK );
	
}

function staminup_enabled( b_enabled )
{
	if ( IS_TRUE( b_enabled ) )
	{
		if ( IS_TRUE( STAMINUP_USE_SECONDARY_PERKS ) )
		{
			for ( i = 0; i < STAMINUP_SECONDARY_PERKS.size; i++ )
				self setPerk( STAMINUP_SECONDARY_PERKS[ i ] );
	
			self thread zm_perk_utility::handle_bgb_perk_lose_specialty_conflict( STAMINUP_SECONDARY_PERKS, STAMINUP_PERK, STAMINUP_SECONDARY_PERK_CONFLICT_BGBS );	
		}
	}
	else
	{
		if ( IS_TRUE( STAMINUP_USE_SECONDARY_PERKS ) )
		{
			for ( i = 0; i < STAMINUP_SECONDARY_PERKS.size; i++ )
				self unsetPerk( STAMINUP_SECONDARY_PERKS[ i ] );
			
		}
	}
}