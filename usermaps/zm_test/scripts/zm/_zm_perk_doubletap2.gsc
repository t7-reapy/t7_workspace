#using scripts\codescripts\struct;
#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_perk_utility;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_perk_doubletap2.gsh;

#precache( "string", "ZOMBIE_PERK_DOUBLETAP" );
#precache( "triggerstring", "ZOMBIE_PERK_DOUBLETAP", DOUBLETAP2_PERK_COST_STRING );
#precache( "fx", DOUBLETAP2_MACHINE_LIGHT_FX );

#namespace zm_perk_doubletap2;

REGISTER_SYSTEM_EX( "zm_perk_doubletap2", &__init__, &__main__, undefined )

// CALLBACKS AND OVERRIDES
// 
// ai.b_immune_to_doubletap2_projectile_impact_buff = true / false ------- prevent damage modifier on that ai
// ai.ptr_doubletap2_projectile_damage_cb = function( str_inflictor, e_attacker, n_damage, b_flags, str_means_of_death, w_weapon, v_point, v_dir, str_hit_loc, n_ps_offset_time, n_bone_index, str_surface_type ) ------ run different logic for this ai ( return final damage )
// ai.b_immune_to_doubletap2_impact_buff = true / false ------- prevent damage modifier on that ai
// ai.ptr_doubletap2_impact_damage_cb = function( str_inflictor, e_attacker, n_damage, b_flags, str_means_of_death, w_weapon, v_point, v_dir, str_hit_loc, n_ps_offset_time, n_bone_index, str_surface_type ) ------ run different logic for this ai ( return final damage )
// ai.b_immune_to_doubletap2_splash_buff = true / false ------- prevent damage modifier on that ai
// ai.ptr_doubletap2_splash_damage_cb = function( str_inflictor, e_attacker, n_damage, b_flags, str_means_of_death, w_weapon, v_point, v_dir, str_hit_loc, n_ps_offset_time, n_bone_index, str_surface_type ) ------ run different logic for this ai ( return final damage )
// ai.b_immune_to_doubletap2_melee_buff = true / false ------- prevent damage modifier on that ai
// ai.ptr_doubletap2_melee_damage_cb = function( str_inflictor, e_attacker, n_damage, b_flags, str_means_of_death, w_weapon, v_point, v_dir, str_hit_loc, n_ps_offset_time, n_bone_index, str_surface_type ) ------ run different logic for this ai ( return final damage )

//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------
function __init__()
{
	if ( IS_TRUE( DOUBLETAP2_LEVEL_USE_PERK ) )
		enable_double_tap2_perk_for_level();
	
}

function __main__()
{
	if ( IS_TRUE( DOUBLETAP2_LEVEL_USE_PERK ) )
		double_tap2_main();
	
}

function enable_double_tap2_perk_for_level()
{	
	zm_perks::register_perk_basic_info( DOUBLETAP2_PERK, DOUBLETAP2_ALIAS, DOUBLETAP2_PERK_COST, &"ZOMBIE_PERK_DOUBLETAP", getWeapon( DOUBLETAP2_PERK_BOTTLE_WEAPON ) );
	zm_perks::register_perk_precache_func( DOUBLETAP2_PERK, &double_tap2_precache );
	zm_perks::register_perk_clientfields( DOUBLETAP2_PERK, &double_tap2_register_clientfield, &double_tap2_set_clientfield );
	zm_perks::register_perk_machine( DOUBLETAP2_PERK, &double_tap2_perk_machine_setup );
	zm_perks::register_perk_threads( DOUBLETAP2_PERK, &double_tap2_give_perk, &double_tap2_take_perk );
	zm_perks::register_perk_host_migration_params( DOUBLETAP2_PERK, DOUBLETAP2_RADIANT_MACHINE_NAME, DOUBLETAP2_PERK );
	if ( zm_perk_utility::is_stock_map() && level.script == "zm_tomb" )
		zm_perks::register_perk_machine_power_override( DOUBLETAP2_PERK, &double_tap2_power_override );
		
	if ( level.script == "zm_cosmodrome" )
		zm_perk_utility::place_perk_machine( ( -234, 1242, -485 ), ( 0, -90 + 90, 0 ), DOUBLETAP2_PERK, DOUBLETAP2_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_tomb" )
		zm_perk_utility::place_perk_machine( ( -167, 3680, -291 ), ( 0, -90 + 90, 0 ), DOUBLETAP2_PERK, DOUBLETAP2_MACHINE_DISABLED_MODEL );
	
}

function double_tap2_precache()
{
	level._effect[ DOUBLETAP2_PERK ] = DOUBLETAP2_MACHINE_LIGHT_FX;
	
	level.machine_assets[ DOUBLETAP2_PERK ] = spawnStruct();
	level.machine_assets[ DOUBLETAP2_PERK ].weapon = getWeapon( DOUBLETAP2_PERK_BOTTLE_WEAPON );
	level.machine_assets[ DOUBLETAP2_PERK ].off_model = DOUBLETAP2_MACHINE_DISABLED_MODEL;
	level.machine_assets[ DOUBLETAP2_PERK ].on_model = DOUBLETAP2_MACHINE_ACTIVE_MODEL;
}

function double_tap2_register_clientfield() 
{
	clientfield::register( "clientuimodel", DOUBLETAP2_CLIENTFIELD, VERSION_SHIP, 2, "int" );
}

function double_tap2_set_clientfield( n_state ) 
{
	if ( n_state != 0 && ( level zm_perk_utility::is_perk_paused( DOUBLETAP2_PERK ) || self zm_perk_utility::is_perk_paused( DOUBLETAP2_PERK ) ) )
		n_state = 2;
	
	self clientfield::set_player_uimodel( DOUBLETAP2_CLIENTFIELD, n_state );
}

function double_tap2_perk_machine_setup( e_use_trigger, e_perk_machine, e_bump_trigger, e_collision )
{
	e_use_trigger.script_sound = DOUBLETAP2_JINGLE;
	e_use_trigger.script_string = DOUBLETAP2_SCRIPT_STRING;
	e_use_trigger.script_label = DOUBLETAP2_STING;
	e_use_trigger.target = DOUBLETAP2_RADIANT_MACHINE_NAME;
	e_perk_machine.script_string = DOUBLETAP2_SCRIPT_STRING;
	e_perk_machine.targetname = DOUBLETAP2_RADIANT_MACHINE_NAME;
	if ( isDefined( e_bump_trigger ) )
		e_bump_trigger.script_string = DOUBLETAP2_SCRIPT_STRING;
	
	e_perk_machine thread zm_perk_utility::register_vulture_perk_safe();
}

function double_tap2_give_perk() 
{
	zm_perk_utility::print_version( DOUBLETAP2_PERK, DOUBLETAP2_VERSION );
	
	if ( level zm_perk_utility::is_perk_paused( DOUBLETAP2_PERK ) )
		self zm_perk_utility::player_pause_perk( DOUBLETAP2_PERK );
	
	if ( self zm_perk_utility::is_perk_paused( DOUBLETAP2_PERK ) )
		return;
		
}

function double_tap2_take_perk( b_pause, str_perk, str_result ) {}

function double_tap2_power_override()
{
	zm_perk_utility::force_power( DOUBLETAP2_PERK );
}

//-----------------------------------------------------------------------------------
// FUNCTIONALITY
//-----------------------------------------------------------------------------------
function double_tap2_main() 
{
	level.ptr_double_tab_2_damage_buff = &double_tap2_damage_modifier;
	
	if ( IS_TRUE( DOUBLETAP2_IN_WONDERFIZZ ) )
		zm_perk_utility::add_perk_to_wunderfizz( DOUBLETAP2_PERK );
	
}

function double_tap2_damage_modifier( str_inflictor, e_attacker, n_damage, b_flags, str_means_of_death, w_weapon, v_point, v_dir, str_hit_loc, n_ps_offset_time, n_bone_index, str_surface_type )
{
	if ( !isDefined( str_means_of_death ) || !isString( str_means_of_death ) || !isDefined( w_weapon ) || !isWeapon( w_weapon ) )
		return n_damage;
	
	if ( !isDefined( e_attacker ) || !isPlayer( e_attacker ) || !e_attacker hasPerk( DOUBLETAP2_PERK ) )
		return n_damage;
	
	if ( IS_TRUE( DOUBLETAP2_ALLOW_WEAPON_EXCLUDE_LIST ) && double_tap2_weapon_excluded_from_modifier( w_weapon.name ) )
		return n_damage;
	
	if ( str_means_of_death == "MOD_PROJECTILE" )
	{
		if ( !IS_TRUE( DOUBLETAP2_INCREASE_PROJECTILE_DAMAGE ) || IS_TRUE( self.b_immune_to_doubletap2_projectile_impact_buff ) )
			return n_damage;
		
		if ( isDefined( self.ptr_doubletap2_projectile_damage_cb ) )
		{
			n_damage = self [ [ self.ptr_doubletap2_projectile_damage_cb ] ]( str_inflictor, e_attacker, n_damage, b_flags, str_means_of_death, w_weapon, v_point, v_dir, str_hit_loc, n_ps_offset_time, n_bone_index, str_surface_type );
			return n_damage;
		}
		n_damage = int( n_damage * DOUBLETAP2_PROJECTILE_DAMAGE_MULTIPLIER );
	}
	else if ( str_means_of_death == "MOD_IMPACT" )
	{
		if ( !IS_TRUE( DOUBLETAP2_INCREASE_IMPACT_DAMAGE ) || IS_TRUE( self.b_immune_to_doubletap2_impact_buff ) )
			return n_damage;
		
		if ( isDefined( self.ptr_doubletap2_impact_damage_cb ) )
		{
			n_damage = self [ [ self.ptr_doubletap2_impact_damage_cb ] ]( str_inflictor, e_attacker, n_damage, b_flags, str_means_of_death, w_weapon, v_point, v_dir, str_hit_loc, n_ps_offset_time, n_bone_index, str_surface_type );
			return n_damage;
		}
		n_damage = int( n_damage * DOUBLETAP2_IMPACT_DAMAGE_MULTIPLIER );
	}
	else if ( str_means_of_death == "MOD_GRENADE_SPLASH" || str_means_of_death == "MOD_PROJECTILE_SPLASH" )
	{
		if ( !IS_TRUE( DOUBLETAP2_INCREASE_SPLASH_DAMAGE ) || IS_TRUE( self.b_immune_to_doubletap2_splash_buff ) )
			return n_damage;
		
		if ( isDefined( self.ptr_doubletap2_splash_damage_cb ) )
		{
			n_damage = self [ [ self.ptr_doubletap2_splash_damage_cb ] ]( str_inflictor, e_attacker, n_damage, b_flags, str_means_of_death, w_weapon, v_point, v_dir, str_hit_loc, n_ps_offset_time, n_bone_index, str_surface_type );
			return n_damage;
		}
		n_damage = int( n_damage * DOUBLETAP2_SPLASH_DAMAGE_MULTIPLIER );
	}
	else if ( str_means_of_death == "MOD_MELEE" )
	{
		if ( !IS_TRUE( DOUBLETAP2_INCREASE_MELEE_DAMAGE ) || IS_TRUE( self.b_immune_to_doubletap2_melee_buff ) )
			return n_damage;
		
		if ( isDefined( self.ptr_doubletap2_melee_damage_cb ) )
		{
			n_damage = self [ [ self.ptr_doubletap2_melee_damage_cb ] ]( str_inflictor, e_attacker, n_damage, b_flags, str_means_of_death, w_weapon, v_point, v_dir, str_hit_loc, n_ps_offset_time, n_bone_index, str_surface_type );
			return n_damage;
		}
		n_damage = int( n_damage * DOUBLETAP2_MELEE_DAMAGE_MULTIPLIER );
	}
	else
		return n_damage;
	
	if ( IS_TRUE( DOUBLETAP2_CAP_INCREASED_DAMAGE ) && n_damage > DOUBLETAP2_DAMAGE_CAP )
		n_damage = DOUBLETAP2_DAMAGE_CAP;
	
	return n_damage;
}

function double_tap2_add_weapon_to_exception_list( str_weapon_name )
{
	DEFAULT( level.a_double_tap2_weapon_exception_list, [] );
	
	if ( !isInArray( level.a_double_tap2_weapon_exception_list, str_weapon_name ) )
		ARRAY_ADD( level.a_double_tap2_weapon_exception_list, str_weapon_name );
	
}

function double_tap2_weapon_excluded_from_modifier( str_weapon_name )
{
	if ( !isDefined( level.a_double_tap2_weapon_exception_list ) || !isArray( level.a_double_tap2_weapon_exception_list ) || level.a_double_tap2_weapon_exception_list.size < 1 )
		return 0;
	
	if ( isInArray( level.a_double_tap2_weapon_exception_list, str_weapon_name ) )
		return 1;
	
	return 0;
}