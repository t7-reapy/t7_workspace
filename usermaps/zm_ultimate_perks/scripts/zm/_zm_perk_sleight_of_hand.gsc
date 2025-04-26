#using scripts\codescripts\struct;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\util_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\system_shared;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_perk_utility;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_perk_sleight_of_hand.gsh;

#precache( "string", "ZOMBIE_PERK_FASTRELOAD" );
#precache( "triggerstring", "ZOMBIE_PERK_FASTRELOAD", SLEIGHT_OF_HAND_PERK_COST_STRING );
#precache( "fx", SLEIGHT_OF_HAND_MACHINE_LIGHT_FX );
#precache( "model", SLEIGHT_OF_HAND_MACHINE_CANS_MODEL );

#namespace zm_perk_sleight_of_hand;

REGISTER_SYSTEM_EX( "zm_perk_sleight_of_hand", &__init__, &__main__, undefined )

// CALLBACKS AND OVERRIDES
// 
// NONE

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
	zm_perks::register_perk_basic_info( SLEIGHT_OF_HAND_PERK, SLEIGHT_OF_HAND_ALIAS, SLEIGHT_OF_HAND_PERK_COST, &"ZOMBIE_PERK_FASTRELOAD", getWeapon( SLEIGHT_OF_HAND_PERK_BOTTLE_WEAPON ) );
	zm_perks::register_perk_precache_func( SLEIGHT_OF_HAND_PERK, &sleight_of_hand_precache );
	zm_perks::register_perk_clientfields( SLEIGHT_OF_HAND_PERK, &sleight_of_hand_register_clientfield, &sleight_of_hand_set_clientfield );
	zm_perks::register_perk_machine( SLEIGHT_OF_HAND_PERK, &sleight_of_hand_perk_machine_setup );
	zm_perks::register_perk_threads( SLEIGHT_OF_HAND_PERK, &sleight_of_hand_give_perk, &sleight_of_hand_take_perk );
	zm_perks::register_perk_host_migration_params( SLEIGHT_OF_HAND_PERK, SLEIGHT_OF_HAND_RADIANT_MACHINE_NAME, SLEIGHT_OF_HAND_PERK );
}

function sleight_of_hand_precache()
{
	level._effect[ SLEIGHT_OF_HAND_PERK ]	= SLEIGHT_OF_HAND_MACHINE_LIGHT_FX;
	
	level.machine_assets[ SLEIGHT_OF_HAND_PERK ] = spawnStruct();
	level.machine_assets[ SLEIGHT_OF_HAND_PERK ].weapon = getWeapon( SLEIGHT_OF_HAND_PERK_BOTTLE_WEAPON );
	level.machine_assets[ SLEIGHT_OF_HAND_PERK ].off_model = SLEIGHT_OF_HAND_MACHINE_DISABLED_MODEL;
	level.machine_assets[ SLEIGHT_OF_HAND_PERK ].on_model = SLEIGHT_OF_HAND_MACHINE_ACTIVE_MODEL;	
	level.machine_assets[ SLEIGHT_OF_HAND_PERK ].power_on_callback = &sleight_of_hand_power_on_cb;	
	level.machine_assets[ SLEIGHT_OF_HAND_PERK ].power_off_callback = &sleight_of_hand_power_off_cb;	
}

function sleight_of_hand_register_clientfield() 
{
	clientfield::register( "clientuimodel", SLEIGHT_OF_HAND_CLIENTFIELD, VERSION_SHIP, 2, "int" );
}

function sleight_of_hand_set_clientfield( n_state ) 
{
	if ( n_state != 0 && ( level zm_perk_utility::is_perk_paused( SLEIGHT_OF_HAND_PERK ) || self zm_perk_utility::is_perk_paused( SLEIGHT_OF_HAND_PERK ) ) )
		n_state = 2;
	
	self clientfield::set_player_uimodel( SLEIGHT_OF_HAND_CLIENTFIELD, n_state );
}

function sleight_of_hand_perk_machine_setup( e_use_trigger, e_perk_machine, e_bump_trigger, e_collision )
{
	e_use_trigger.script_sound = SLEIGHT_OF_HAND_JINGLE;
	e_use_trigger.script_string = SLEIGHT_OF_HAND_SCRIPT_STRING;
	e_use_trigger.script_label = SLEIGHT_OF_HAND_STING;
	e_use_trigger.target = SLEIGHT_OF_HAND_RADIANT_MACHINE_NAME;
	e_perk_machine.script_string = SLEIGHT_OF_HAND_SCRIPT_STRING;
	e_perk_machine.targetname = SLEIGHT_OF_HAND_RADIANT_MACHINE_NAME;
	if ( isDefined( e_bump_trigger ) )
		e_bump_trigger.script_string = SLEIGHT_OF_HAND_SCRIPT_STRING;
	
	e_perk_machine thread zm_perk_utility::register_vulture_perk_safe();
	e_perk_machine.e_can_model = util::spawn_model( SLEIGHT_OF_HAND_MACHINE_CANS_MODEL, e_perk_machine.origin, e_perk_machine.angles );
}

function sleight_of_hand_power_on_cb()
{
	if ( isDefined( self.e_can_model ) )
		self.e_can_model thread scene::play( SLEIGHT_OF_HAND_MACHINE_CANS_SB, self.e_can_model );
	
}

function sleight_of_hand_power_off_cb()
{
	if ( isDefined( self.e_can_model ) )
		self.e_can_model thread scene::stop( SLEIGHT_OF_HAND_MACHINE_CANS_SB, self.e_can_model );

}

function sleight_of_hand_give_perk() 
{
	zm_perk_utility::print_version( SLEIGHT_OF_HAND_PERK, SLEIGHT_OF_HAND_VERSION );
	
	if ( level zm_perk_utility::is_perk_paused( SLEIGHT_OF_HAND_PERK ) )
		self zm_perk_utility::player_pause_perk( SLEIGHT_OF_HAND_PERK );
	
	if ( self zm_perk_utility::is_perk_paused( SLEIGHT_OF_HAND_PERK ) )
		return;
	
	self sleight_of_hand_enabled( 1 );
}

function sleight_of_hand_take_perk( b_pause, str_perk, str_result ) 
{
	self sleight_of_hand_enabled( 0 );
}

//-----------------------------------------------------------------------------------
// FUNCTIONALITY
//-----------------------------------------------------------------------------------
function sleight_of_hand_main() 
{
	if ( IS_TRUE( SLEIGHT_OF_HAND_IN_WONDERFIZZ ) )
		zm_perk_utility::add_perk_to_wunderfizz( SLEIGHT_OF_HAND_PERK );
	
}

function sleight_of_hand_enabled( b_enabled )
{
	if ( IS_TRUE( b_enabled ) )
	{
		if ( IS_TRUE( SLEIGHT_OF_HAND_USE_SECONDARY_PERKS ) )
		{
			for ( i = 0; i < SLEIGHT_OF_HAND_SECONDARY_PERKS.size; i++ )
				self setPerk( SLEIGHT_OF_HAND_SECONDARY_PERKS[ i ] );
	
			self thread zm_perk_utility::handle_bgb_perk_lose_specialty_conflict( SLEIGHT_OF_HAND_SECONDARY_PERKS, SLEIGHT_OF_HAND_PERK, SLEIGHT_OF_HAND_SECONDARY_PERK_CONFLICT_BGBS );	
		}
	}
	else
	{
		if ( IS_TRUE( SLEIGHT_OF_HAND_USE_SECONDARY_PERKS ) )
		{
			for ( i = 0; i < SLEIGHT_OF_HAND_SECONDARY_PERKS.size; i++ )
				self unsetPerk( SLEIGHT_OF_HAND_SECONDARY_PERKS[ i ] );
			
		}
	}
}
