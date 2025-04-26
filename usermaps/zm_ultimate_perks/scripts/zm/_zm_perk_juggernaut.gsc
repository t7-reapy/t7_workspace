#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\ai\zombie_utility;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_perk_utility;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_perk_juggernaut.gsh;
#insert scripts\zm\_zm_perk_utility.gsh;

#precache( "string", "ZOMBIE_PERK_JUGGERNAUT" );
#precache( "triggerstring", "ZOMBIE_PERK_JUGGERNAUT", JUGGERNAUT_PERK_COST_STRING );
#precache( "fx", JUGGERNAUT_MACHINE_LIGHT_FX );

#namespace zm_perk_juggernaut;

REGISTER_SYSTEM_EX( "zm_perk_juggernaut", &__init__, &__main__, undefined )

// CALLBACKS AND OVERRIDES
// 
// NONE

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
	zm_perks::register_perk_basic_info( JUGGERNAUT_PERK, JUGGERNAUT_ALIAS, JUGGERNAUT_PERK_COST, &"ZOMBIE_PERK_JUGGERNAUT", getWeapon( JUGGERNAUT_PERK_BOTTLE_WEAPON ) );
	zm_perks::register_perk_precache_func( JUGGERNAUT_PERK, &juggernaut_precache );
	zm_perks::register_perk_clientfields( JUGGERNAUT_PERK, &juggernaut_register_clientfield, &juggernaut_set_clientfield );
	zm_perks::register_perk_machine( JUGGERNAUT_PERK, &juggernaut_perk_machine_setup );
	zm_perks::register_perk_threads( JUGGERNAUT_PERK, &juggernaut_give_perk, &juggernaut_take_perk );
	zm_perks::register_perk_host_migration_params( JUGGERNAUT_PERK, JUGGERNAUT_RADIANT_MACHINE_NAME, 	JUGGERNAUT_PERK );
}	

function juggernaut_precache()
{	
	level._effect[ JUGGERNAUT_PERK ]	= JUGGERNAUT_MACHINE_LIGHT_FX;
	
	level.machine_assets[ JUGGERNAUT_PERK ] = spawnStruct();
	level.machine_assets[ JUGGERNAUT_PERK ].weapon = getWeapon( JUGGERNAUT_PERK_BOTTLE_WEAPON );
	level.machine_assets[ JUGGERNAUT_PERK ].off_model = JUGGERNAUT_MACHINE_DISABLED_MODEL;
	level.machine_assets[ JUGGERNAUT_PERK ].on_model = JUGGERNAUT_MACHINE_ACTIVE_MODEL;
}

function juggernaut_register_clientfield() 
{
	clientfield::register( "clientuimodel", JUGGERNAUT_CLIENTFIELD, VERSION_SHIP, 2, "int" );
}

function juggernaut_set_clientfield( n_state ) 
{
	if ( n_state != 0 && ( level zm_perk_utility::is_perk_paused( JUGGERNAUT_PERK ) || self zm_perk_utility::is_perk_paused( JUGGERNAUT_PERK ) ) )
		n_state = 2;
	
	self clientfield::set_player_uimodel( JUGGERNAUT_CLIENTFIELD, n_state );
}

function juggernaut_perk_machine_setup( e_use_trigger, e_perk_machine, e_bump_trigger, e_collision )
{
	e_use_trigger.script_sound = JUGGERNAUT_JINGLE;
	e_use_trigger.script_string = JUGGERNAUT_SCRIPT_STRING;
	e_use_trigger.script_label = JUGGERNAUT_STING;
	e_use_trigger.target = JUGGERNAUT_RADIANT_MACHINE_NAME;
	e_perk_machine.script_string = JUGGERNAUT_SCRIPT_STRING;
	e_perk_machine.targetname = JUGGERNAUT_RADIANT_MACHINE_NAME;
	if ( isDefined( e_bump_trigger ) )
		e_bump_trigger.script_string = JUGGERNAUT_SCRIPT_STRING;
	
	e_perk_machine thread zm_perk_utility::register_vulture_perk_safe();
}

function juggernaut_give_perk()
{
	zm_perk_utility::print_version( JUGGERNAUT_PERK, JUGGERNAUT_VERSION );
	
	if ( level zm_perk_utility::is_perk_paused( JUGGERNAUT_PERK ) )
		self zm_perk_utility::player_pause_perk( JUGGERNAUT_PERK );
	
	if ( self zm_perk_utility::is_perk_paused( JUGGERNAUT_PERK ) )
		return;
	
	self juggernaut_enabled( 1 );
}

function juggernaut_take_perk( b_pause, str_perk, str_result )
{
	self juggernaut_enabled( 0 );
}

//-----------------------------------------------------------------------------------
// FUNCTIONALITY
//-----------------------------------------------------------------------------------
function juggernaut_main()
{	
	zombie_utility::set_zombie_var( "zombie_perk_juggernaut_health", JUGGERNAUT_NORMAL_HEALTH );
	zombie_utility::set_zombie_var( "zombie_perk_juggernaut_health_upgrade", JUGGERNAUT_UPGRADED_HEALTH );
	
	if ( IS_TRUE( JUGGERNAUT_IN_WONDERFIZZ ) )
		zm_perks::register_perk_damage_override_func( &juggernaut_damage_override );
	
	if ( IS_TRUE( JUGGERNAUT_BLOCKS_ELECTRIC_AND_FIRE_DAMAGE ) )
		zm_perk_utility::add_perk_to_wunderfizz( JUGGERNAUT_PERK );	
	
}

function juggernaut_enabled( n_enabled )
{
	if ( IS_TRUE( n_enabled ) )
		self zm_perks::perk_set_max_health_if_jugg( JUGGERNAUT_PERK, 1, 0 );
	else
		self zm_perks::perk_set_max_health_if_jugg( "health_reboot", 1, 0 );
	
}

function juggernaut_damage_override( e_inflictor, e_attacker, n_damage, str_flags, str_means_of_death, w_weapon, v_point, v_dir, str_hit_loc, f_offset_time )
{
	if ( !self hasPerk( JUGGERNAUT_PERK ) )
		return undefined;
	
	switch ( str_means_of_death )
	{
		case "MOD_BURNED":
		case "MOD_ELECTOCUTED":
			return 0;
		default:
			break;
			
	}
	return undefined;
}