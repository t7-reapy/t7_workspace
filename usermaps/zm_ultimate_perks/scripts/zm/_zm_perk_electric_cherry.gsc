#using scripts\codescripts\struct;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\math_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\ai\zombie_utility;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_perk_utility;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_perk_electric_cherry.gsh;

#precache( "string", "HB21_ZM_PERKS_ELECTRIC_CHERRY" );
#precache( "triggerstring", "HB21_ZM_PERKS_ELECTRIC_CHERRY", ELECTRIC_CHERRY_PERK_COST_STRING );
#precache( "fx", ELECTRIC_CHERRY_MACHINE_LIGHT_FX );
#precache( "fx", ELECTRIC_CHERRY_EXPLODE_FX );

#namespace zm_perk_electric_cherry;

REGISTER_SYSTEM_EX( "zm_perk_electric_cherry", &__init__, &__main__, undefined )

// CALLBACKS AND OVERRIDES
// 
// ai.b_electric_cherry_stun_immune = true / false ------- prevent stun on that ai
// ai.b_electric_cherry_fx_immune = true / false ------- prevent fx on that ai
// ai.b_electric_cherry_damage_immune = true / false ------- prevent cherry damage on that ai
// ai.ptr_electric_cherry_damage_cb = function( e_attacker ) ------ run different logic for this ai

//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------
function __init__()
{
	script = toLower( getDvarString( "mapname" ) );
	if ( script == "zm_factory" || script == "zm_zod" || script == "zm_prototype" || script == "zm_asylum" || script == "zm_sumpf" || script == "zm_theater" || script == "zm_cosmodrome" || script == "zm_temple" || script == "zm_moon" )
		return;
	
	if ( IS_TRUE( ELECTRIC_CHERRY_LEVEL_USE_PERK ) )
		enable_electric_cherry_perk_for_level();
	
}

function __main__()
{
	script = toLower( getDvarString( "mapname" ) );
	if ( script == "zm_factory" || script == "zm_zod" || script == "zm_prototype" || script == "zm_asylum" || script == "zm_sumpf" || script == "zm_theater" || script == "zm_cosmodrome" || script == "zm_temple" || script == "zm_moon" )
		return;
	
	if ( IS_TRUE( ELECTRIC_CHERRY_LEVEL_USE_PERK ) )
		electric_cherry_main();
	
}

function enable_electric_cherry_perk_for_level()
{	
	zm_perks::register_perk_basic_info( ELECTRIC_CHERRY_PERK, ELECTRIC_CHERRY_ALIAS, ELECTRIC_CHERRY_PERK_COST, &"HB21_ZM_PERKS_ELECTRIC_CHERRY", getWeapon( ELECTRIC_CHERRY_PERK_BOTTLE_WEAPON ) );
	zm_perks::register_perk_precache_func( ELECTRIC_CHERRY_PERK, &electric_cherry_precache );
	zm_perks::register_perk_clientfields( ELECTRIC_CHERRY_PERK, &electric_cherry_register_clientfield, &electric_cherry_set_clientfield );
	zm_perks::register_perk_machine( ELECTRIC_CHERRY_PERK, &electric_cherry_perk_machine_setup );
	zm_perks::register_perk_host_migration_params( ELECTRIC_CHERRY_PERK, ELECTRIC_CHERRY_RADIANT_MACHINE_NAME, 	ELECTRIC_CHERRY_PERK );
	zm_perks::register_perk_threads( ELECTRIC_CHERRY_PERK, &electric_cherry_give_perk, &electric_cherry_take_perk );
	if ( zm_perk_utility::is_stock_map() && ( level.script == "zm_zod" || level.script == "zm_genesis" || level.script == "zm_tomb" ) )
		zm_perks::register_perk_machine_power_override( 			ELECTRIC_CHERRY_PERK, &electric_cherry_power_override );
	
	if ( level.script == "zm_zod" )
		zm_perk_utility::place_perk_machine( ( 1992, -3417, -400 ),  ( 0, 180 + 90, 0 ), ELECTRIC_CHERRY_PERK, ELECTRIC_CHERRY_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_factory" )
		zm_perk_utility::place_perk_machine( ( 63, -1464, 191 ), ( 0, 90 + 90, 0 ), ELECTRIC_CHERRY_PERK, ELECTRIC_CHERRY_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_castle" )
		zm_perk_utility::place_perk_machine( ( 1502, 3094, 408 ), ( 0, -163 + 90, 0 ), ELECTRIC_CHERRY_PERK, ELECTRIC_CHERRY_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_island" )
		zm_perk_utility::place_perk_machine( ( 1684, 908, -4399 ), ( 0, 90 + 90, 0 ), ELECTRIC_CHERRY_PERK, ELECTRIC_CHERRY_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_stalingrad" )
		zm_perk_utility::place_perk_machine( ( -905, 3335, 160 ),  ( 0, -90 + 90, 0 ), ELECTRIC_CHERRY_PERK, ELECTRIC_CHERRY_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_genesis" )
		zm_perk_utility::place_perk_machine( ( -82, -411, -3381 ), ( 0, 0 + 90, 0 ), ELECTRIC_CHERRY_PERK, ELECTRIC_CHERRY_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_tomb" )
		zm_perk_utility::place_perk_machine( ( 1542, -2222, -37 - 5 ), ( 0, 180 + 90, 0 ), ELECTRIC_CHERRY_PERK, ELECTRIC_CHERRY_MACHINE_DISABLED_MODEL );
		
}

function electric_cherry_precache()
{
	level._effect[ ELECTRIC_CHERRY_PERK ]	= ELECTRIC_CHERRY_MACHINE_LIGHT_FX;
	
	level.machine_assets[ ELECTRIC_CHERRY_PERK ] = spawnStruct();
	level.machine_assets[ ELECTRIC_CHERRY_PERK ].weapon = getWeapon( ELECTRIC_CHERRY_PERK_BOTTLE_WEAPON );
	level.machine_assets[ ELECTRIC_CHERRY_PERK ].off_model = ELECTRIC_CHERRY_MACHINE_DISABLED_MODEL;
	level.machine_assets[ ELECTRIC_CHERRY_PERK ].on_model = ELECTRIC_CHERRY_MACHINE_ACTIVE_MODEL;
}

function electric_cherry_register_clientfield() 
{
	clientfield::register( "clientuimodel", ELECTRIC_CHERRY_CLIENTFIELD, VERSION_SHIP, 2, "int" );
	clientfield::register( "allplayers", ELECTRIC_CHERRY_RELOAD_FX_CF, VERSION_SHIP, 1, "int" );
	clientfield::register( "actor", ELECTRIC_CHERRY_TESLA_DEATH_FX_CF, VERSION_SHIP, 1, "int" );
	clientfield::register( "vehicle", ELECTRIC_CHERRY_TESLA_DEATH_FX_VEH_CF, VERSION_TU10, 1, "int" );
	clientfield::register( "actor", ELECTRIC_CHERRY_TESLA_SHOCK_EYES_FX_CF, VERSION_SHIP, 	1, "int" );
	clientfield::register( "vehicle", ELECTRIC_CHERRY_TESLA_SHOCK_EYES_FX_VEH_CF, VERSION_TU10, 1, "int" );
}

function electric_cherry_set_clientfield( n_state ) 
{
	if ( n_state != 0 && ( level zm_perk_utility::is_perk_paused( ELECTRIC_CHERRY_PERK ) || self zm_perk_utility::is_perk_paused( ELECTRIC_CHERRY_PERK ) ) )
		n_state = 2;
	
	self clientfield::set_player_uimodel( ELECTRIC_CHERRY_CLIENTFIELD, n_state );
}

function electric_cherry_perk_machine_setup( e_use_trigger, e_perk_machine, e_bump_trigger, e_collision )
{
	e_use_trigger.script_sound = ELECTRIC_CHERRY_JINGLE;
	e_use_trigger.script_string 	= ELECTRIC_CHERRY_SCRIPT_STRING;
	e_use_trigger.script_label = ELECTRIC_CHERRY_STING;
	e_use_trigger.target = ELECTRIC_CHERRY_RADIANT_MACHINE_NAME;
	e_perk_machine.script_string = ELECTRIC_CHERRY_SCRIPT_STRING;
	e_perk_machine.targetname = ELECTRIC_CHERRY_RADIANT_MACHINE_NAME;
	if( isDefined( e_bump_trigger ) )
		e_bump_trigger.script_string = ELECTRIC_CHERRY_SCRIPT_STRING;
	
	e_perk_machine thread zm_perk_utility::register_vulture_perk_safe();
}

function electric_cherry_give_perk()
{	
	zm_perk_utility::print_version( ELECTRIC_CHERRY_PERK, ELECTRIC_CHERRY_VERSION );
	
	if ( level zm_perk_utility::is_perk_paused( ELECTRIC_CHERRY_PERK ) )
		self zm_perk_utility::player_pause_perk( ELECTRIC_CHERRY_PERK );
	
	if ( self zm_perk_utility::is_perk_paused( ELECTRIC_CHERRY_PERK ) )
		return;
	
	self electric_cherry_enabled( 1 );
}

function electric_cherry_take_perk( b_pause, str_perk, str_result ) 
{
	self electric_cherry_enabled( 0 );
}

function electric_cherry_power_override()
{
	zm_perk_utility::force_power( ELECTRIC_CHERRY_PERK );
}

//-----------------------------------------------------------------------------------
// FUNCTIONALITY
//-----------------------------------------------------------------------------------
function electric_cherry_main()
{	
	level._effect[ "electric_cherry_explode" ] = ELECTRIC_CHERRY_EXPLODE_FX;
	
	callback::on_laststand( &electric_cherry_laststand );
	
	zombie_utility::set_zombie_var( "tesla_head_gib_chance", ELECTRIC_CHERRY_GIB_CHANCE );
	
	if ( IS_TRUE( ELECTRIC_CHERRY_IN_WONDERFIZZ ) )
		zm_perk_utility::add_perk_to_wunderfizz( ELECTRIC_CHERRY_PERK );
	
}

function electric_cherry_enabled( b_enabled )
{
	if ( IS_TRUE( b_enabled ) )
		self thread electric_cherry_setup();
	else
		self notify( "stop_electric_cherry_logic" );
		
}

function electric_cherry_laststand()
{	
	if ( !self hasPerk( ELECTRIC_CHERRY_PERK ) )
		return;
	
	if ( isDefined( self ) )
	{
		playFX( level._effect[ "electric_cherry_explode" ], self.origin );
		self playSound( "zmb_cherry_explode" );
		
		WAIT_SERVER_FRAME;
			
		a_zombies = zombie_utility::get_round_enemy_array();
		a_zombies = util::get_array_of_closest( self.origin, a_zombies, undefined, undefined, ELECTRIC_CHERRY_DOWNED_ATTACK_RADIUS );
		
		for ( i = 0; i < a_zombies.size; i++ )
		{
			if ( isAlive( self ) && isAlive( a_zombies[ i ] ) )
			{
				if ( IS_TRUE( a_zombies[ i ].b_electric_cherry_damage_immune ) )
					continue;
				if ( isDefined( a_zombies[ i ].ptr_electric_cherry_damage_cb ) )
				{
					a_zombies[ i ] [ [ a_zombies[ i ].ptr_electric_cherry_damage_cb ] ]( self );
					continue;
				}
				if ( a_zombies[ i ].health <= ELECTRIC_CHERRY_DOWNED_ATTACK_DAMAGE )
				{
					if ( !IS_TRUE( a_zombies[ i ].b_electric_cherry_fx_immune ) )
						a_zombies[ i ] thread electric_cherry_death_fx();
					
					self zm_score::add_to_player_score( ELECTRIC_CHERRY_DOWNED_ATTACK_POINTS );
				}
				else
				{
					if ( !IS_TRUE( a_zombies[ i ].b_electric_cherry_stun_immune ) )
						a_zombies[ i ] thread electric_cherry_stun();
					if ( !IS_TRUE( a_zombies[ i ].b_electric_cherry_fx_immune ) )
						a_zombies[ i ] thread electric_cherry_shock_fx();
					
				}
				
				WAIT_SERVER_FRAME;
				a_zombies[ i ] doDamage( ELECTRIC_CHERRY_DOWNED_ATTACK_DAMAGE, self.origin, self, self, "none" );
			}
		}
	}
}

function electric_cherry_death_fx()
{
	self endon( "death" );
	
	self playSound( "zmb_elec_jib_zombie" );
	
	if ( !IS_TRUE( self.head_gibbed ) )
	{
		if( isVehicle( self ) )
			self clientfield::set( ELECTRIC_CHERRY_TESLA_SHOCK_EYES_FX_VEH_CF, 1 );
		else
			self clientfield::set( ELECTRIC_CHERRY_TESLA_SHOCK_EYES_FX_CF, 1 );
	}
	else
	{
		if ( isVehicle( self ) )
			self clientfield::set( ELECTRIC_CHERRY_TESLA_DEATH_FX_VEH_CF, 1 );
		else
			self clientfield::set( ELECTRIC_CHERRY_TESLA_DEATH_FX_CF, 1 );
		
	}		
}

function electric_cherry_shock_fx()
{
	self endon( "death" );
	
	if ( isVehicle( self ) )
		self clientfield::set( ELECTRIC_CHERRY_TESLA_SHOCK_EYES_FX_VEH_CF, 1 );
	else
		self clientfield::set( ELECTRIC_CHERRY_TESLA_SHOCK_EYES_FX_CF, 1 );
	
	self playSound( "zmb_elec_jib_zombie" );
	
	self waittill( "stun_fx_end" );	

	if ( isVehicle( self ) )
		self clientfield::set( ELECTRIC_CHERRY_TESLA_SHOCK_EYES_FX_VEH_CF, 0 );
	else
		self clientfield::set( ELECTRIC_CHERRY_TESLA_SHOCK_EYES_FX_CF, 0 );
	
}

function electric_cherry_stun()
{
	self endon( "death" );
	self notify( "stun_zombie" );
	self endon( "stun_zombie" );

	if ( self.health <= 0 )
		return;
	
	if ( self.ai_state !== "zombie_think" )
		return;	
	
	self.zombie_tesla_hit = 1;		
	self zm_perk_utility::increment_ignoreall();

	wait ELECTRIC_CHERRY_STUN_CYCLES;

	if ( isDefined( self ) )
	{	
		self.zombie_tesla_hit = 0;		
		self zm_perk_utility::decrement_ignoreall();
		self notify( "stun_fx_end" );	
	}
}

function electric_cherry_setup()
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "stop_electric_cherry_logic" );
	
	self.a_wait_on_reload = [];
	self.n_consecutive_electric_cherry_attacks = 0;
	
	while ( 1 )
	{
		self waittill( "reload_start" );
		
		w_current_weapon = self getCurrentWeapon();
		
		if ( isInArray( self.a_wait_on_reload, w_current_weapon ) )
			continue;	
		
		self.a_wait_on_reload[ self.a_wait_on_reload.size ] = w_current_weapon;
		
		self.n_consecutive_electric_cherry_attacks++;
		
		n_clip_current 	= self getWeaponAmmoClip( w_current_weapon );
		n_clip_max 		= w_current_weapon.clipSize;
		f_fraction 		= n_clip_current / n_clip_max;
	
		f_perk_radius 	= math::linear_map( f_fraction, 1, 0, ELECTRIC_CHERRY_RELOAD_ATTACK_MIN_RADIUS, 	ELECTRIC_CHERRY_RELOAD_ATTACK_MAX_RADIUS );
		f_perk_dmg 	= math::linear_map( f_fraction, 1, 0, ELECTRIC_CHERRY_RELOAD_ATTACK_MIN_DAMAGE, 	ELECTRIC_CHERRY_RELOAD_ATTACK_MAX_DAMAGE );
		
		self thread electric_cherry_check_for_reload_complete( w_current_weapon );
		
		if ( isDefined( self ) )
		{			
			switch( self.n_consecutive_electric_cherry_attacks )
			{
				case 0:
				case 1:
					n_zombie_limit = undefined;
					break;
				case 2:
					n_zombie_limit = ELECTRIC_CHERRY_RELOAD_ATTACK_ZOMBIE_LIMIT_2_CONSECUTIVE_RELOADS;
					break;
				case 3:
					n_zombie_limit = ELECTRIC_CHERRY_RELOAD_ATTACK_ZOMBIE_LIMIT_3_CONSECUTIVE_RELOADS;
					break;
				case 4:
					n_zombie_limit = ELECTRIC_CHERRY_RELOAD_ATTACK_ZOMBIE_LIMIT_4_CONSECUTIVE_RELOADS;
					break;
				default:
					n_zombie_limit = 0;
			
			}

			self thread electric_cherry_cooldown_timer( w_current_weapon );
			
			if( isDefined( n_zombie_limit ) && ( n_zombie_limit == 0 ) )
				continue;
			
			self thread electric_cherry_reload_fx();
			self playSound( "zmb_cherry_explode" );
			
			a_zombies = zombie_utility::get_round_enemy_array();
			a_zombies = util::get_array_of_closest( self.origin, a_zombies, undefined, undefined, f_perk_radius );
			
			n_zombies_hit = 0;
			
			for ( i = 0; i < a_zombies.size; i++ )
			{
				if ( isAlive( self ) && isAlive( a_zombies[ i ] ) )
				{
					if ( isDefined( n_zombie_limit ) )
					{
						if ( n_zombies_hit < n_zombie_limit )
							n_zombies_hit++;							
						else
							break;
						
					}
					
					if ( a_zombies[ i ].health <= f_perk_dmg )
					{
						if ( !IS_TRUE( a_zombies[ i ].b_electric_cherry_fx_immune ) )
							a_zombies[ i ] thread electric_cherry_death_fx();					
						
						self zm_score::add_to_player_score( ELECTRIC_CHERRY_RELOAD_ATTACK_POINTS );
					}
					else
					{
						if ( !IS_TRUE( a_zombies[ i ].b_electric_cherry_stun_immune ) )
							a_zombies[ i ] thread electric_cherry_stun();	
						if ( !IS_TRUE( a_zombies[ i ].b_electric_cherry_fx_immune ) )
							a_zombies[ i ] thread electric_cherry_shock_fx();
						
					}
					
					WAIT_SERVER_FRAME;
					if ( isDefined( a_zombies[ i ] ) && isAlive( a_zombies[ i ] ) )
						a_zombies[ i ] doDamage( f_perk_dmg, self.origin, self, self, "none" );
					
				}
			}
		}
	}
}

function electric_cherry_cooldown_timer( w_current_weapon )
{
	self notify( "electric_cherry_cooldown_started" );
	self endon( "electric_cherry_cooldown_started" );
	self endon( "death" );
	self endon( "disconnect" );
	
	f_reload_time = w_current_weapon.reloadTime;
	if ( self hasPerk( "specialty_fastreload" ) )
		f_reload_time *= ELECTRIC_CHERRY_RELOAD_ATTACK_COOLDOWN_TIMER_SPEED_COLA_MODIFIER;
	
	f_cooldown_time = f_reload_time + ELECTRIC_CHERRY_RELOAD_ATTACK_COOLDOWN_TIMER;
	
	wait f_cooldown_time;
	
	self.n_consecutive_electric_cherry_attacks = 0;
}

function electric_cherry_check_for_reload_complete( w_weapon )
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "player_lost_weapon_" + w_weapon.name );
	
	self thread electric_cherry_weapon_replaced_monitor( w_weapon );
	
	while ( 1 )
	{
		self waittill( "reload" );
		
		w_current_weapon = self getCurrentWeapon();
		if ( w_current_weapon == w_weapon )
		{
			arrayRemoveValue( self.a_wait_on_reload, w_weapon );
			self notify( "weapon_reload_complete_" + w_weapon.name );
			break;
		}
	}
}

function electric_cherry_weapon_replaced_monitor( w_weapon )
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "weapon_reload_complete_" + w_weapon.name );
	
	while ( 1 )
	{
		self waittill( "weapon_change" );

		a_primary_weapons = self getWeaponsListPrimaries();
		if ( !isInArray( a_primary_weapons, w_weapon ) )
		{
			self notify( "player_lost_weapon_" + w_weapon.name );
			arrayRemoveValue( self.a_wait_on_reload, w_weapon );
			break;
		}
	}
}

function electric_cherry_reload_fx()
{
	self clientfield::set( ELECTRIC_CHERRY_RELOAD_FX_CF, 1 );	
	wait 1;
	self clientfield::set( ELECTRIC_CHERRY_RELOAD_FX_CF, 0 );
}

//-----------------------------------------------------------------------------------
// ORIGINS HOT FIX
//-----------------------------------------------------------------------------------
function electric_cherry_perk_lost( b_pause, str_perk, str_result )
{
	self electric_cherry_take_perk( b_pause, str_perk, str_result );
}