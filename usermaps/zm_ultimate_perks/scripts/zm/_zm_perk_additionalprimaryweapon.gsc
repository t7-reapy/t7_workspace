#using scripts\codescripts\struct;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_perk_utility;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_perk_additionalprimaryweapon.gsh;

#precache( "string", "ZOMBIE_PERK_ADDITIONALPRIMARYWEAPON" );
#precache( "triggerstring", "ZOMBIE_PERK_ADDITIONALPRIMARYWEAPON", ADDITIONAL_PRIMARY_WEAPON_PERK_COST_STRING );
#precache( "fx", ADDITIONAL_PRIMARY_WEAPON_MACHINE_LIGHT_FX );

#namespace zm_perk_additionalprimaryweapon;

REGISTER_SYSTEM_EX( "zm_perk_additionalprimaryweapon", &__init__, &__main__, undefined )

// CALLBACKS AND OVERRIDES
// 
// level.additionalprimaryweapon_limit = int // changed amount of guns you can hold with mule kick

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
	zm_perks::register_perk_basic_info( ADDITIONAL_PRIMARY_WEAPON_PERK, ADDITIONAL_PRIMARY_WEAPON_ALIAS, ADDITIONAL_PRIMARY_WEAPON_PERK_COST, &"ZOMBIE_PERK_ADDITIONALPRIMARYWEAPON", getWeapon( ADDITIONAL_PRIMARY_WEAPON_PERK_BOTTLE_WEAPON ) );
	zm_perks::register_perk_precache_func( ADDITIONAL_PRIMARY_WEAPON_PERK, &additional_primary_weapon_precache );
	zm_perks::register_perk_clientfields( ADDITIONAL_PRIMARY_WEAPON_PERK, &additional_primary_weapon_register_clientfield, &additional_primary_weapon_set_clientfield );
	zm_perks::register_perk_machine( ADDITIONAL_PRIMARY_WEAPON_PERK, &additional_primary_weapon_perk_machine_setup );
	zm_perks::register_perk_threads( ADDITIONAL_PRIMARY_WEAPON_PERK, &additional_primary_give_perk, &additional_primary_take_perk );
	zm_perks::register_perk_host_migration_params( ADDITIONAL_PRIMARY_WEAPON_PERK, ADDITIONAL_PRIMARY_WEAPON_RADIANT_MACHINE_NAME, ADDITIONAL_PRIMARY_WEAPON_PERK );
}

function additional_primary_weapon_precache()
{
	level._effect[ ADDITIONAL_PRIMARY_WEAPON_PERK ]	= ADDITIONAL_PRIMARY_WEAPON_MACHINE_LIGHT_FX;
	
	level.machine_assets[ ADDITIONAL_PRIMARY_WEAPON_PERK ] = spawnStruct();
	level.machine_assets[ ADDITIONAL_PRIMARY_WEAPON_PERK ].weapon = getWeapon( ADDITIONAL_PRIMARY_WEAPON_PERK_BOTTLE_WEAPON );
	level.machine_assets[ ADDITIONAL_PRIMARY_WEAPON_PERK ].off_model = ADDITIONAL_PRIMARY_WEAPON_MACHINE_DISABLED_MODEL;
	level.machine_assets[ ADDITIONAL_PRIMARY_WEAPON_PERK ].on_model = ADDITIONAL_PRIMARY_WEAPON_MACHINE_ACTIVE_MODEL;
}

function additional_primary_weapon_register_clientfield() 
{
	clientfield::register( "clientuimodel", ADDITIONAL_PRIMARY_WEAPON_UI_GLOW_CLIENTFIELD, VERSION_SHIP, 1, "int" );
	clientfield::register( "clientuimodel", ADDITIONAL_PRIMARY_WEAPON_CLIENTFIELD, VERSION_SHIP, 2, "int" );
}

function additional_primary_weapon_set_clientfield( n_state ) 
{
	if ( n_state != 0 && ( level zm_perk_utility::is_perk_paused( ADDITIONAL_PRIMARY_WEAPON_PERK ) || self zm_perk_utility::is_perk_paused( ADDITIONAL_PRIMARY_WEAPON_PERK ) ) )
		n_state = 2;
	
	if ( n_state != 1 )
		self clientfield::set_player_uimodel( ADDITIONAL_PRIMARY_WEAPON_UI_GLOW_CLIENTFIELD, 0 );
	
	self clientfield::set_player_uimodel( ADDITIONAL_PRIMARY_WEAPON_CLIENTFIELD, n_state );
}

function additional_primary_weapon_perk_machine_setup( e_use_trigger, e_perk_machine, e_bump_trigger, e_collision )
{
	e_use_trigger.script_sound = ADDITIONAL_PRIMARY_WEAPON_JINGLE;
	e_use_trigger.script_string 	= ADDITIONAL_PRIMARY_WEAPON_SCRIPT_STRING;
	e_use_trigger.script_label = ADDITIONAL_PRIMARY_WEAPON_STING;
	e_use_trigger.target = ADDITIONAL_PRIMARY_WEAPON_RADIANT_MACHINE_NAME;
	e_perk_machine.script_string = ADDITIONAL_PRIMARY_WEAPON_SCRIPT_STRING;
	e_perk_machine.targetname = ADDITIONAL_PRIMARY_WEAPON_RADIANT_MACHINE_NAME;
	if ( isDefined( e_bump_trigger ) )
		e_bump_trigger.script_string = ADDITIONAL_PRIMARY_WEAPON_SCRIPT_STRING;
	
	e_perk_machine thread zm_perk_utility::register_vulture_perk_safe();
}

function additional_primary_give_perk()
{
	zm_perk_utility::print_version( ADDITIONAL_PRIMARY_WEAPON_PERK, ADDITIONAL_PRIMARY_WEAPON_VERSION );
	
	if ( level zm_perk_utility::is_perk_paused( ADDITIONAL_PRIMARY_WEAPON_PERK ) )
		self zm_perk_utility::player_pause_perk( ADDITIONAL_PRIMARY_WEAPON_PERK );
	
	if ( self zm_perk_utility::is_perk_paused( ADDITIONAL_PRIMARY_WEAPON_PERK ) )
		return;
		
	self additional_primary_enabled( 1 );
}

function additional_primary_take_perk( b_pause, str_perk, str_result ) 
{
	self additional_primary_enabled( 0, ( IS_TRUE( b_pause ) || ( isDefined( str_result ) && isDefined( str_perk ) && str_result == str_perk ) ) );
	self clientfield::set_player_uimodel( ADDITIONAL_PRIMARY_WEAPON_UI_GLOW_CLIENTFIELD, 0 );
}

//-----------------------------------------------------------------------------------
// FUNCTIONALITY
//-----------------------------------------------------------------------------------
function addtional_primary_main()
{
	level.additionalprimaryweapon_limit = ADDITIONAL_PRIMARY_WEAPON_LIMIT;
	level.return_additionalprimaryweapon = &additional_primary_return_additional_primary_weapons;
	
	callback::on_spawned( &additional_primary_logic );
	
	if ( IS_TRUE( ADDITIONAL_PRIMARY_WEAPON_IN_WONDERFIZZ ) )
		zm_perk_utility::add_perk_to_wunderfizz( ADDITIONAL_PRIMARY_WEAPON_PERK );
		
}

function additional_primary_enabled( b_enabled, b_allow_weapon_switch )
{
	if ( IS_TRUE( b_enabled ) )
		self additional_primary_return_additional_primary_weapons();
	else
	{
		self clientfield::set_player_uimodel( ADDITIONAL_PRIMARY_WEAPON_UI_GLOW_CLIENTFIELD, 0 );
		self additional_primary_take_additional_primary_weapons( b_allow_weapon_switch );
	}
}

function additional_primary_take_additional_primary_weapons( b_allow_weapon_switch )
{
	a_weapons_to_take = [];
	a_primary_weapons_that_can_be_taken = [];

	a_primary_weapons = self getWeaponsListPrimaries();
	for ( i = 0; i < a_primary_weapons.size; i++ )
	{
		if ( isDefined( self.laststandpistol ) && self.laststandpistol == a_primary_weapons[ i ] )
			continue;
		
		a_primary_weapons_that_can_be_taken[ a_primary_weapons_that_can_be_taken.size ] = a_primary_weapons[ i ];
	}
	
	if ( !isDefined( a_primary_weapons_that_can_be_taken ) || !isArray( a_primary_weapons_that_can_be_taken ) || a_primary_weapons_that_can_be_taken.size < 3 )
		return;
	
	for ( i = 2; i < a_primary_weapons_that_can_be_taken.size; i++ )
	{
		w_weapon_to_take = a_primary_weapons_that_can_be_taken[ i ];
		
		a_weapons_to_take[ a_weapons_to_take.size ] = zm_weapons::get_player_weapondata( self, w_weapon_to_take );
		if ( w_weapon_to_take == self getCurrentWeapon() && !self laststand::player_is_in_laststand() && IS_TRUE( b_allow_weapon_switch ) )
			self switchToWeapon( a_primary_weapons_that_can_be_taken[ 0 ] );
		
		self takeWeapon( w_weapon_to_take );
	}
	
	self.weapon_taken_by_losing_specialty_additionalprimaryweapon = 1;
	self.a_additional_primary_weapons_lost = a_weapons_to_take;
}

function additional_primary_return_additional_primary_weapons( w_return )
{
	if ( !IS_TRUE( ADDITIONAL_PRIMARY_WEAPONS_RETURNED_WHEN_BOUGHT ) )
		return;
	
	if ( !isDefined( self.a_additional_primary_weapons_lost ) || !isArray( self.a_additional_primary_weapons_lost ) || self.a_additional_primary_weapons_lost < 1 )
		return;
	
	for ( i = 0; i < self.a_additional_primary_weapons_lost.size; i++ )
		self zm_weapons::weapondata_give( self.a_additional_primary_weapons_lost[ i ] );
	
	self.a_additional_primary_weapons_lost = undefined;
	self.weapon_taken_by_losing_specialty_additionalprimaryweapon = undefined;
}

function additional_primary_logic()
{
	self endon( "disconnect" );
	self endon( "death" );
	self notify( "additional_primary_watcher" );
	self endon( "additional_primary_watcher" );
	
	if ( isDefined( self.a_additional_primary_weapons_lost ) && IS_TRUE( ADDITIONAL_PRIMARY_WEAPONS_WEAPONS_LOST_ON_DEATH ) )
	{
		self.weapon_taken_by_losing_specialty_additionalprimaryweapon = undefined;
		self.a_additional_primary_weapons_lost = undefined;
	}
	
	if ( !IS_TRUE( ADDITIONAL_PRIMARY_WEAPONS_SHADER_EFFECTS ) )
		return;
	
	while ( 1 )
	{
		self util::waittill_any( "weapon_change", "weapon_change_complete" );
		
		if ( !self clientfield::get_player_uimodel( ADDITIONAL_PRIMARY_WEAPON_CLIENTFIELD ) )
			continue;
	
		w_weapon = self getCurrentWeapon();
		a_primary_weapons = self getWeaponsListPrimaries();
		
		if ( !isDefined( w_weapon ) || !isDefined( a_primary_weapons ) || a_primary_weapons.size < 1 )
		{
			self clientfield::set_player_uimodel( ADDITIONAL_PRIMARY_WEAPON_UI_GLOW_CLIENTFIELD, 0 );
			continue;
		}
		
		b_is_mule_kick_gun = 0;
		for ( i = 0; i < a_primary_weapons.size; i++ )
		{
			if ( w_weapon == a_primary_weapons[ i ] && i > 1 && self hasPerk( ADDITIONAL_PRIMARY_WEAPON_PERK ) )
			{
				b_is_mule_kick_gun = 1;
				break;
			}	
		}
		self clientfield::set_player_uimodel( ADDITIONAL_PRIMARY_WEAPON_UI_GLOW_CLIENTFIELD, IS_TRUE( b_is_mule_kick_gun ) );
	}
}