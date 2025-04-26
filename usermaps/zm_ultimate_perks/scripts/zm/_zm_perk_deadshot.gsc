#using scripts\codescripts\struct;
#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_perk_utility;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_perk_deadshot.gsh;
#insert scripts\zm\_zm_perk_utility.gsh;

#precache( "triggerstring", "ZOMBIE_PERK_DEADSHOT", DEADSHOT_PERK_COST_STRING );
#precache( "string", "ZOMBIE_PERK_DEADSHOT" );
#precache( "fx", DEADSHOT_MACHINE_LIGHT_FX );

#namespace zm_perk_deadshot;

REGISTER_SYSTEM_EX( "zm_perk_deadshot", &__init__, &__main__, undefined )

// CALLBACKS AND OVERRIDES
// 
// ai.b_immune_to_deadshot_buff = true / false ------- prevent damage modifier on that ai
// ai.ptr_deadshot_damage_cb = function( str_inflictor, e_attacker, n_damage, b_flags, str_means_of_death, w_weapon, v_point, v_dir, str_hit_loc, n_ps_offset_time, n_bone_index, str_surface_type ) ------ run different logic for this ai ( return final damage )

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
	zm_perks::register_perk_basic_info( DEADSHOT_PERK, DEADSHOT_ALIAS, DEADSHOT_PERK_COST, &"ZOMBIE_PERK_DEADSHOT", getWeapon( DEADSHOT_PERK_BOTTLE_WEAPON ) );
	zm_perks::register_perk_precache_func( DEADSHOT_PERK, &deadshot_precache );
	zm_perks::register_perk_clientfields( DEADSHOT_PERK, &deadshot_register_clientfield, &deadshot_set_clientfield );
	zm_perks::register_perk_machine( DEADSHOT_PERK, &deadshot_machine_setup );
	zm_perks::register_perk_threads( DEADSHOT_PERK, &deadshot_give_perk, &deadshot_take_perk );
	zm_perks::register_perk_host_migration_params( DEADSHOT_PERK, DEADSHOT_RADIANT_MACHINE_NAME, 	DEADSHOT_PERK );	
	if ( zm_perk_utility::is_stock_map() && ( level.script == "zm_zod" || level.script == "zm_genesis" || level.script == "zm_tomb" ) )
		zm_perks::register_perk_machine_power_override( DEADSHOT_PERK, &deadshot_power_override );
		
	if ( level.script == "zm_asylum" )
		zm_perk_utility::place_perk_machine( ( 1152, -53, 64 ), ( 0, 180 + 90, 0 ), DEADSHOT_PERK, DEADSHOT_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_sumpf" )
		zm_perk_utility::place_perk_machine( ( 10640, 906, -528 ), ( 0, -180 + 90, 0 ), DEADSHOT_PERK, DEADSHOT_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_theater" )
		zm_perk_utility::place_perk_machine( ( -248, -535, 80 ), ( 0, -90 + 90, 0 ), DEADSHOT_PERK, DEADSHOT_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_cosmodrome" )
		zm_perk_utility::place_perk_machine( ( -679, 1296, -119 ), ( 0, -90 + 90, 0 ), DEADSHOT_PERK, DEADSHOT_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_tomb" )
		zm_perk_utility::place_perk_machine( ( 1868, 4088, -4353 ), ( 0, 180 + 90, 0 ), DEADSHOT_PERK, DEADSHOT_MACHINE_DISABLED_MODEL );
		
	
}

function deadshot_precache()
{
	level._effect[ DEADSHOT_PERK ] = DEADSHOT_MACHINE_LIGHT_FX;
	
	level.machine_assets[ DEADSHOT_PERK ] = spawnStruct();
	level.machine_assets[ DEADSHOT_PERK ].weapon = getWeapon( DEADSHOT_PERK_BOTTLE_WEAPON );
	level.machine_assets[ DEADSHOT_PERK ].off_model = DEADSHOT_MACHINE_DISABLED_MODEL;
	level.machine_assets[ DEADSHOT_PERK ].on_model = DEADSHOT_MACHINE_ACTIVE_MODEL;
}

function deadshot_register_clientfield()
{
	clientfield::register( "clientuimodel", DEADSHOT_CLIENTFIELD, VERSION_SHIP, 2, "int" );
	clientfield::register( "clientuimodel", DEADSHOT_UI_GLOW_CLIENTFIELD, VERSION_SHIP, 1, "int" );
	clientfield::register( "toplayer", DEADSHOT_SCRIPT_STRING, VERSION_SHIP, 1, "int" );
}

function deadshot_set_clientfield( n_state )
{
	if ( n_state != 0 && ( level zm_perk_utility::is_perk_paused( DEADSHOT_PERK ) || self zm_perk_utility::is_perk_paused( DEADSHOT_PERK ) ) )
		n_state = 2;
	
	if ( n_state != 1 )
		self clientfield::set_player_uimodel( DEADSHOT_UI_GLOW_CLIENTFIELD, 0 );
	
	self clientfield::set_player_uimodel( DEADSHOT_CLIENTFIELD, n_state );
}

function deadshot_machine_setup( e_use_trigger, e_perk_machine, e_bump_trigger, e_collision )
{
	e_use_trigger.script_sound = DEADSHOT_JINGLE;
	e_use_trigger.script_string 	= DEADSHOT_SCRIPT_STRING;
	e_use_trigger.script_label = DEADSHOT_STING;
	e_use_trigger.target = DEADSHOT_RADIANT_MACHINE_NAME;
	e_perk_machine.script_string = DEADSHOT_SCRIPT_STRING;
	e_perk_machine.targetname = DEADSHOT_RADIANT_MACHINE_NAME;
	if ( isDefined( e_bump_trigger ) )
		e_bump_trigger.script_string = DEADSHOT_SCRIPT_STRING;
	
	e_perk_machine thread zm_perk_utility::register_vulture_perk_safe();
}

function deadshot_give_perk()
{
	zm_perk_utility::print_version( DEADSHOT_PERK, DEADSHOT_VERSION );
	
	if ( level zm_perk_utility::is_perk_paused( DEADSHOT_PERK ) )
		self zm_perk_utility::player_pause_perk( DEADSHOT_PERK );
	
	if ( self zm_perk_utility::is_perk_paused( DEADSHOT_PERK ) )
		return;
		
	self deadshot_enabled( 1 );
}

function deadshot_take_perk( b_pause, str_perk, str_result )
{
	self deadshot_enabled( 0 );
}

function deadshot_power_override()
{
	zm_perk_utility::force_power( DEADSHOT_PERK );
}

//-----------------------------------------------------------------------------------
// FUNCTIONALITY
//-----------------------------------------------------------------------------------
function deadshot_main()
{
	level.ptr_dead_shot_damage_buff = &deadshot_damage_modifier;
	zm_spawner::register_zombie_death_event_callback( &deadshot_death_event_points_bonus );
	
	setDvar( "perk_weapSpreadMultiplier", DEADSHOT_HIPFIRE_SPREAD_MULTIPLIER );
	
	if ( IS_TRUE( DEADSHOT_IN_WONDERFIZZ ) )
		zm_perk_utility::add_perk_to_wunderfizz( DEADSHOT_PERK );
		
}

function deadshot_enabled( b_enabled )
{
	if ( IS_TRUE( b_enabled ) )
	{
		self clientfield::set_to_player( DEADSHOT_SCRIPT_STRING, 1 );
		
		if ( IS_TRUE( DEADSHOT_USE_SECONDARY_PERKS ) )
		{
			for ( i = 0; i < DEADSHOT_SECONDARY_PERKS.size; i++ )
				self setPerk( DEADSHOT_SECONDARY_PERKS[ i ] );
	
			self thread zm_perk_utility::handle_bgb_perk_lose_specialty_conflict( DEADSHOT_SECONDARY_PERKS, DEADSHOT_PERK, DEADSHOT_SECONDARY_PERK_CONFLICT_BGBS );	
		}
	}
	else
	{
		self clientfield::set_to_player( DEADSHOT_SCRIPT_STRING, 0 );
		
		if ( IS_TRUE( DEADSHOT_USE_SECONDARY_PERKS ) )
		{
			for ( i = 0; i < DEADSHOT_SECONDARY_PERKS.size; i++ )
				self unsetPerk( DEADSHOT_SECONDARY_PERKS[ i ] );
			
		}
		self clientfield::set_player_uimodel( DEADSHOT_UI_GLOW_CLIENTFIELD, 0 );
	}
}

function deadshot_damage_ui_glow()
{
	self notify( "deadshot_damage_ui_glow" );
	self endon( "deadshot_damage_ui_glow" );
	self clientfield::set_player_uimodel( DEADSHOT_UI_GLOW_CLIENTFIELD, 1 );
	wait DEADSHOT_SHOW_UI_GLOW_DURATION;
	self clientfield::set_player_uimodel( DEADSHOT_UI_GLOW_CLIENTFIELD, 0 );
}

function deadshot_damage_modifier( str_inflictor, e_attacker, n_damage, b_flags, str_means_of_death, w_weapon, v_point, v_dir, str_hit_loc, n_ps_offset_time, n_bone_index, str_surface_type )
{
	if ( !zm_utility::is_headshot( w_weapon, str_hit_loc, str_means_of_death ) )
		return n_damage;
	
	if ( !isDefined( e_attacker ) || !isPlayer( e_attacker ) || !e_attacker hasPerk( DEADSHOT_PERK ) )
		return n_damage;
	
	if ( str_means_of_death == "MOD_PROJECTILE" || str_means_of_death == "MOD_GRENADE_SPLASH" || str_means_of_death == "MOD_PROJECTILE_SPLASH" )
		return n_damage;
	
	if ( IS_TRUE( DEADSHOT_SHOW_UI_GLOW_ON_HEADSHOTS ) )
		e_attacker thread deadshot_damage_ui_glow();
	
	if ( !IS_TRUE( DEADSHOT_INCREASED_HEAD_DAMAGE ) )
		return n_damage;
	
	if ( IS_TRUE( self.b_immune_to_deadshot_buff ) )
		return n_damage;
	
	if ( isDefined( self.ptr_deadshot_damage_cb ) )
	{
		n_damage = self [ [ self.ptr_deadshot_damage_cb ] ]( str_inflictor, e_attacker, n_damage, b_flags, str_means_of_death, w_weapon, v_point, v_dir, str_hit_loc, n_ps_offset_time, n_bone_index, str_surface_type );
		return n_damage;
	}
	
	n_damage = int( n_damage * DEADSHOT_HEAD_DAMAGE_MULTIPLIER );
	
	return n_damage;
}

function deadshot_death_event_points_bonus( e_attacker )
{
	if ( !isDefined( e_attacker ) || !isPlayer( e_attacker ) || !e_attacker hasPerk( DEADSHOT_PERK ) || !IS_TRUE( DEADSHOT_KILL_AWARDS_BONUS_POINTS ) )
		return;
	
	if ( !zm_utility::is_headshot( self.damageweapon, self.damagelocation, self.damagemod ) )
		return;
	
	if ( IS_TRUE( DEADSHOT_SHOW_UI_GLOW_ON_HEADSHOTS ) )
		e_attacker thread deadshot_damage_ui_glow();
	
	if ( IS_TRUE( self.b_immune_to_deadshot_buff ) )
		return;
	
	e_attacker zm_score::add_to_player_score( DEADSHOT_HEADSHOT_KILL_BONUS_POINTS );
}