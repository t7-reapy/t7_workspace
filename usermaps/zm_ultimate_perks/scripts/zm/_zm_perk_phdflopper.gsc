#using scripts\codescripts\struct;
#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\system_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\shared\util_shared;
#using scripts\shared\ai\zombie_utility;
#using scripts\zm\gametypes\_globallogic_score;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_perk_utility;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_perk_phdflopper.gsh;

#precache( "string", "HB21_ZM_PERKS_PHDFLOPPER" );
#precache( "triggerstring", "HB21_ZM_PERKS_PHDFLOPPER", PHDFLOPPER_PERK_COST_STRING );
#precache( "fx", PHDFLOPPER_MACHINE_LIGHT_FX );

#namespace zm_perk_phdflopper;

REGISTER_SYSTEM_EX( "zm_perk_phdflopper", &__init__, &__main__, undefined )

// CALLBACKS AND OVERRIDES
// 
// ai.b_phdflopper_slide_explode_immune = true / false ------- prevent PHD slide explode damage on that ai
// ai.ptr_phdflopper_slide_explode_cb = function( e_attacker ) ------ run different logic for this ai

//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------
function __init__()
{
	if ( IS_TRUE( PHDFLOPPER_LEVEL_USE_PERK ) )
		enable_phdflopper_perk_for_level();
			
}

function __main__()
{
	if ( IS_TRUE( PHDFLOPPER_LEVEL_USE_PERK ) )
		phdflopper_main();
			
}

function enable_phdflopper_perk_for_level()
{	
	zm_perks::register_perk_basic_info( PHDFLOPPER_PERK, PHDFLOPPER_ALIAS, PHDFLOPPER_PERK_COST, &"HB21_ZM_PERKS_PHDFLOPPER", getWeapon( PHDFLOPPER_PERK_BOTTLE_WEAPON ) );
	zm_perks::register_perk_precache_func( PHDFLOPPER_PERK, &phdflopper_precache );
	zm_perks::register_perk_clientfields( PHDFLOPPER_PERK, &phdflopper_register_clientfield, &phdflopper_set_clientfield );
	zm_perks::register_perk_machine( PHDFLOPPER_PERK, &phdflopper_perk_machine_setup );
	zm_perks::register_perk_host_migration_params( PHDFLOPPER_PERK, PHDFLOPPER_RADIANT_MACHINE_NAME, 	PHDFLOPPER_PERK );
	zm_perks::register_perk_threads( PHDFLOPPER_PERK, &phdflopper_give_perk, &phdflopper_take_perk );
	if ( zm_perk_utility::is_stock_map() && ( level.script == "zm_zod" || level.script == "zm_genesis" || level.script == "zm_tomb" ) )
		zm_perks::register_perk_machine_power_override( PHDFLOPPER_PERK, &phdflopper_power_override );
		
	if ( level.script == "zm_zod" )
		zm_perk_utility::place_perk_machine( ( 3059, -5478, 128 ), ( 0, 90, 0 ), PHDFLOPPER_PERK, PHDFLOPPER_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_factory" )
		zm_perk_utility::place_perk_machine( ( -732, -40, 70 ), ( 0, 0, 0 ), PHDFLOPPER_PERK, PHDFLOPPER_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_castle" )
		zm_perk_utility::place_perk_machine( ( -1284, 2843, 824 ), ( 0, -25, 0 ), PHDFLOPPER_PERK, PHDFLOPPER_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_island" )
		zm_perk_utility::place_perk_machine( ( -2005, -1205, -303 ), ( 0, 23, 0 ), PHDFLOPPER_PERK, PHDFLOPPER_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_stalingrad" )
		zm_perk_utility::place_perk_machine( ( -1050, 2972, 160 ), ( 0, 180, 0 ), PHDFLOPPER_PERK, PHDFLOPPER_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_genesis" )
		zm_perk_utility::place_perk_machine( ( 675, 4541, 1226 ), ( 0, -10, 0 ), PHDFLOPPER_PERK, PHDFLOPPER_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_asylum" )
		zm_perk_utility::place_perk_machine( ( 704, -161, 226 ), ( 0, -90 + 90, 0 ), PHDFLOPPER_PERK, PHDFLOPPER_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_sumpf" )
		zm_perk_utility::place_perk_machine( ( 10422, 1385, -660 ), ( 0, -90 + 90, 0 ), PHDFLOPPER_PERK, PHDFLOPPER_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_theater" )
		zm_perk_utility::place_perk_machine( ( -1328, -489, 79 ), ( 0, 0 + 90, 0 ), PHDFLOPPER_PERK, PHDFLOPPER_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_cosmodrome" )
		zm_perk_utility::place_perk_machine( ( -955, 1311, -140 ), ( 0, 90 + 90, 0 ), PHDFLOPPER_PERK, PHDFLOPPER_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_temple" )
		zm_perk_utility::place_perk_machine( ( 1338, -1020, 17 ), ( 0, 90 + 90, 0 ), PHDFLOPPER_PERK, PHDFLOPPER_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_moon" )
		zm_perk_utility::place_perk_machine( ( 6158, 650, -205 ), ( 0, -90 + 90, 0 ), PHDFLOPPER_PERK, PHDFLOPPER_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_tomb" )
		zm_perk_utility::place_perk_machine( ( 3040, 942, -209 ), ( 0, -90 + 90, 0 ), PHDFLOPPER_PERK, PHDFLOPPER_MACHINE_DISABLED_MODEL );
		
}

function phdflopper_precache()
{	
	level._effect[ PHDFLOPPER_PERK ] = PHDFLOPPER_MACHINE_LIGHT_FX;
	
	level.machine_assets[ PHDFLOPPER_PERK ] = spawnStruct();
	level.machine_assets[ PHDFLOPPER_PERK ].weapon = getWeapon( PHDFLOPPER_PERK_BOTTLE_WEAPON );
	level.machine_assets[ PHDFLOPPER_PERK ].off_model = PHDFLOPPER_MACHINE_DISABLED_MODEL;
	level.machine_assets[ PHDFLOPPER_PERK ].on_model = PHDFLOPPER_MACHINE_ACTIVE_MODEL;
}

function phdflopper_register_clientfield() 
{
	clientfield::register( "clientuimodel", PHDFLOPPER_CLIENTFIELD, VERSION_SHIP, 2, "int" );
	clientfield::register( "missile", PHDFLOPPER_MULTIGRENADE_TRAIL_FX_CF, VERSION_SHIP, 1, "int" );
	clientfield::register( "allplayers", PHDFLOPPER_SLIDE_EXPLODE_FX_CF, VERSION_SHIP, 1, "int" );
}

function phdflopper_set_clientfield( n_state ) 
{
	if ( n_state != 0 && ( level zm_perk_utility::is_perk_paused( PHDFLOPPER_PERK ) || self zm_perk_utility::is_perk_paused( PHDFLOPPER_PERK ) ) )
		n_state = 2;
	
	self clientfield::set_player_uimodel( PHDFLOPPER_CLIENTFIELD, n_state );
}

function phdflopper_perk_machine_setup( e_use_trigger, e_perk_machine, e_bump_trigger, e_collision )
{
	e_use_trigger.script_sound = PHDFLOPPER_JINGLE;	
	e_use_trigger.script_string = PHDFLOPPER_SCRIPT_STRING;
	e_use_trigger.script_label = PHDFLOPPER_STING;	
	e_use_trigger.target = PHDFLOPPER_RADIANT_MACHINE_NAME;
	e_perk_machine.script_string = PHDFLOPPER_SCRIPT_STRING;
	e_perk_machine.targetname = PHDFLOPPER_RADIANT_MACHINE_NAME;
	if ( isDefined( e_bump_trigger ) )
		e_bump_trigger.script_string = PHDFLOPPER_SCRIPT_STRING;
	
	e_perk_machine thread zm_perk_utility::register_vulture_perk_safe();
}

function phdflopper_give_perk()
{
	zm_perk_utility::print_version( PHDFLOPPER_PERK, PHDFLOPPER_VERSION );
	
	if ( level zm_perk_utility::is_perk_paused( PHDFLOPPER_PERK ) )
		self zm_perk_utility::player_pause_perk( PHDFLOPPER_PERK );
	
	if ( self zm_perk_utility::is_perk_paused( PHDFLOPPER_PERK ) )
		return;
		
	self phdflopper_enabled( 1 );
}

function phdflopper_take_perk( b_pause, str_perk, str_result )
{
	self phdflopper_enabled( 0 );
}

function phdflopper_power_override()
{
	zm_perk_utility::force_power( PHDFLOPPER_PERK );
}

//-----------------------------------------------------------------------------------
// FUNCTIONALITY
//-----------------------------------------------------------------------------------
function phdflopper_main()
{
	visionset_mgr::register_info( "visionset", PHDFLOPPER_VISION_STRING, VERSION_SHIP, 31, 400, 1, &visionset_mgr::ramp_in_out_thread_per_player, 1 );
	
	callback::on_connect( &phdflopper_register_stat );

	// zm_perks::register_perk_damage_override_func( &phdflopper_damage_override );
	array::push( level.perk_damage_override, &phdflopper_damage_override, 0 );
	
	
	if ( IS_TRUE( PHDFLOPPER_IN_WONDERFIZZ ) )
		zm_perk_utility::add_perk_to_wunderfizz( PHDFLOPPER_PERK );
	
}

function phdflopper_register_stat()
{
	globallogic_score::initPersStat( PHDFLOPPER_PERK + "_drank", 0 );	
}

function phdflopper_enabled( b_enabled )
{
	if ( IS_TRUE( b_enabled ) )
	{
		self thread phdflopper_grenade_multispawn();
		self thread phdflopper_slide_explode();
	}
	else
	{
		self notify( "phdflopper_grenade_multispawn" );
		self notify( "phdflopper_slide_explode" );
	}
}

function phdflopper_explode()
{
	self endon( "disconnect" );
	
	if ( IS_TRUE( self clientfield::get( PHDFLOPPER_SLIDE_EXPLODE_FX_CF ) ) )
	{
		self clientfield::set( PHDFLOPPER_SLIDE_EXPLODE_FX_CF, 0 );
		WAIT_SERVER_FRAME
	}
	
	v_origin = self.origin;
	v_angles = self.angles;
	visionset_mgr::activate( "visionset", PHDFLOPPER_VISION_STRING, self, .1, .1, .1 );
	earthquake( 1, 1, v_origin, PHDFLOPPER_EXPLODE_RADIUS );
	playSoundAtPosition( "zmb_phdflop_explo", v_origin );
	grenadeExplosionEffect( v_origin );
	self clientfield::set( PHDFLOPPER_SLIDE_EXPLODE_FX_CF, 1 );
	
	a_zombies = util::get_array_of_closest( v_origin, zombie_utility::get_round_enemy_array(), undefined, undefined, PHDFLOPPER_EXPLODE_RADIUS );
	n_network_stall_counter = 0;
	
	if ( isDefined( a_zombies ) && isArray( a_zombies ) && a_zombies.size > 0 )
	{
		for ( i = 0; i < a_zombies.size; i++ )
		{
			if ( !isAlive( a_zombies[ i ] ) )
				continue;
			
			if ( IS_TRUE( a_zombies[ i ].b_phdflopper_slide_explode_immune ) )
				continue;
			
			str_tag = "j_spineupper";
			if ( IS_TRUE( a_zombies[ i ].isdog ) )
				str_tag = "j_spine1";
			
			if ( !sightTracePassed( self getEye(), a_zombies[ i ] getTagOrigin( str_tag ), 0, undefined ) )
				continue;
			
			n_dist = distance( a_zombies[ i ].origin, v_origin );
			n_damage = PHDFLOPPER_EXPLODE_MIN_DAMAGE + PHDFLOPPER_EXPLODE_MAX_DAMAGE - PHDFLOPPER_EXPLODE_MIN_DAMAGE * 1 - n_dist / PHDFLOPPER_EXPLODE_RADIUS;
			
			if ( isDefined( a_zombies[ i ].ptr_phdflopper_slide_explode_cb ) )
				a_zombies[ i ] [ [ a_zombies[ i ].ptr_phdflopper_slide_explode_cb ] ]( self );
			else
			{
				a_zombies[ i ] doDamage( n_damage, a_zombies[ i ].origin, self, self, 0, "MOD_GRENADE_SPLASH" );
					
				if ( a_zombies[ i ].health <= 0 )
					a_zombies[ i ] zm_perk_utility::launch_dead_zombie_away_from_point( v_origin, PHDFLOPPER_EXPLODE_MIN_DIRECTIONAL_FORCE, PHDFLOPPER_EXPLODE_MAX_DIRECTIONAL_FORCE, PHDFLOPPER_EXPLODE_MIN_UPWARD_FORCE, PHDFLOPPER_EXPLODE_MAX_UPWARD_FORCE );
			
			}		
			n_network_stall_counter--;
			if ( n_network_stall_counter <= 0 )
			{
				util::wait_network_frame();
				n_network_stall_counter = randomIntRange( 1, 3 );
			}
		}
	}
}

function phdflopper_slide_explode()
{
	self notify( "phdflopper_slide_explode" );
	self endon( "phdflopper_slide_explode" );
	
	if ( !IS_TRUE( PHDFLOPPER_USE_SLIDE_EXPLODE ) )
		return;
	
	while ( 1 )
	{
		f_z_difference = 0;
		while ( !self zm_utility::is_jumping() )
			WAIT_SERVER_FRAME;
		
		f_start_z = self.origin[ 2 ];
		
		while ( self zm_utility::is_jumping() )
			WAIT_SERVER_FRAME;
		
		util::wait_network_frame();
		
		if ( !self isSliding() )
			continue;
		
		if ( isDefined( f_start_z ) && isDefined( self.origin[ 0 ] ) && isDefined( self.origin[ 2 ] ) )
			f_z_difference = f_start_z - self.origin[ 2 ];
		
		if ( f_z_difference > PHDFLOPPER_EXPLODE_MIN_DROP_REQUIRED )
			self thread phdflopper_explode();
					
	}
}

function phdflopper_damage_override( e_inflictor, e_attacker, n_damage, str_flags, str_means_of_death, w_weapon, v_point, v_dir, str_hit_loc, f_offset_time )
{
	if ( !self hasPerk( PHDFLOPPER_PERK ) )
		return n_damage;
	
	switch ( str_means_of_death )
	{
		case "MOD_FALLING":
		case "MOD_GRENADE":
		case "MOD_GRENADE_SPLASH":
		case "MOD_PROJECTILE":
		case "MOD_PROJECTILE_SPLASH":
		case "MOD_EXPLOSIVE":
		case "MOD_EXPLOSIVE_SPLASH":
			return 0;
		default:
			break;
			
	}
	return n_damage;
}

function phdflopper_grenade_multispawn()
{
	self notify( "phdflopper_grenade_multispawn" );
	self endon( "phdflopper_grenade_multispawn" );
	
	if ( !IS_TRUE( PHDFLOPPER_USE_MULTIGRENADE ) )
		return;
	
	while ( 1 )
	{
		self waittill( "grenade_pullback" );
		n_start_time = getTime();
		self waittill( "grenade_fire", e_grenade, w_weapon, n_fuse_time );
		
		if ( !self hasPerk( PHDFLOPPER_PERK ) )
			continue;
		
		if ( phdflopper_grenade_excluded_from_modifier( w_weapon.name ) )
			continue;
		
		if ( !isDefined( e_grenade ) )
			continue;
		
		if ( IS_TRUE( e_grenade.b_phd_multigrenade ) ) 
			continue;
		
		w_current_lethal = self zm_utility::get_player_lethal_grenade();
		if ( w_weapon != w_current_lethal )
			continue;
		
		e_grenade clientfield::set( PHDFLOPPER_MULTIGRENADE_TRAIL_FX_CF, 1 );
		e_grenade.b_phd_multigrenade = 1;
		self thread phdflopper_spawn_grenade( e_grenade, w_weapon, n_fuse_time, n_start_time );
	}
}

function phdflopper_spawn_grenade( e_grenade, w_weapon, n_fuse_time, n_start_time = getTime() )
{
	self endon( "disconnect" );
	e_grenade endon( "grenade_dud" );
	
	if ( !isDefined( e_grenade ) )
		return;
	
	if ( !isDefined( w_weapon ) )
		return;
	
	e_grenade thread phdflopper_handle_multigrenade();
	
	e_grenade waittill( "phdflopper_multigrenade_activate", v_origin );
	
	if ( !isDefined( v_origin ) )
		return;
	
	if ( IS_TRUE( e_grenade.threwBack ) )
		return;
	
	if ( !isDefined( e_grenade ) || !isDefined( n_fuse_time ) )
		n_fuse_remaining = PHDFLOPPER_MULTIGRENADE_DEFAULT_FUSE_TIME;
	else
	{
		n_time_between = getTime() - n_start_time;
		n_fuse_remaining = ( n_fuse_time - n_time_between ) / 1000;
		
		if ( !isDefined( n_fuse_remaining ) || n_fuse_remaining < 0 )
			n_fuse_remaining = PHDFLOPPER_MULTIGRENADE_DEFAULT_FUSE_TIME;
		
	}
	playSoundAtPosition( "zmb_perks_phdflopper_grenade", v_origin );
	
	n_amount_to_spawn = randomIntRange( PHDFLOPPER_MULTIGRENADE_MIN_SPAWN_AMOUNT, PHDFLOPPER_MULTIGRENADE_MAX_SPAWN_AMOUNT );
	f_incriment = 360 / n_amount_to_spawn;
	f_offset = randomFloat( f_incriment );
	
	for ( i = 0; i < n_amount_to_spawn; i++ )
	{
		f_new_angle = f_offset + ( f_incriment * i );
		
		n_directional_force = randomIntRange( PHDFLOPPER_MULTIGRENADE_MIN_DIRECTIONAL_FORCE, PHDFLOPPER_MULTIGRENADE_MAX_DIRECTIONAL_FORCE );
		n_upward_force = randomIntRange( PHDFLOPPER_MULTIGRENADE_MIN_UPWARD_FORCE, PHDFLOPPER_MULTIGRENADE_MAX_UPWARD_FORCE );
		
		n_forward_velocity = ( cos( f_new_angle ) * n_directional_force, sin( f_new_angle ) * n_directional_force, n_upward_force );
		e_spawned_grenade = self magicGrenadeType( w_weapon, v_origin + ( 0, 0, 25 ), n_forward_velocity, n_fuse_remaining );
		
		e_spawned_grenade clientfield::set( PHDFLOPPER_MULTIGRENADE_TRAIL_FX_CF, 1 );
		e_spawned_grenade.b_phd_multigrenade = 1;
		WAIT_SERVER_FRAME;
		WAIT_SERVER_FRAME;
		WAIT_SERVER_FRAME;
	}
}

function phdflopper_handle_multigrenade()
{
	self thread phdflopper_handle_multigrenade_detonate();
	self thread phdflopper_handle_multigrenade_impact();
	self thread phdflopper_handle_multigrenade_timeout();
	self thread phdflopper_handle_multigrenade_stuck();
	self thread phdflopper_handle_multigrenade_stationary();
}

function phdflopper_handle_multigrenade_detonate()
{
	self endon( "grenade_dud" );
	self endon( "phdflopper_multigrenade_activate" );
	self waittill( "detonate", v_origin );
	self notify( "phdflopper_multigrenade_activate", v_origin );
}

function phdflopper_handle_multigrenade_impact()
{
	self endon( "grenade_dud" );
	self endon( "phdflopper_multigrenade_activate" );
	self waittill( "grenade_bounce", v_origin );
	self notify( "phdflopper_multigrenade_activate", v_origin );
}

function phdflopper_handle_multigrenade_stuck()
{
	self endon( "grenade_dud" );
	self endon( "phdflopper_multigrenade_activate" );
	self waittill( "grenade_stuck", v_origin );
	self notify( "phdflopper_multigrenade_activate", v_origin );
}

function phdflopper_handle_multigrenade_stationary()
{
	self endon( "grenade_dud" );
	self endon( "phdflopper_multigrenade_activate" );
	self waittill( "stationary", v_origin );
	self notify( "phdflopper_multigrenade_activate", v_origin );
}

function phdflopper_handle_multigrenade_timeout()
{
	self endon( "grenade_dud" );
	self endon( "phdflopper_multigrenade_activate" );
	self waittill( "explode", v_origin );
	self notify( "phdflopper_multigrenade_activate", v_origin );
}

function phdflopper_add_grenade_to_exception_list( str_weapon_name )
{
	DEFAULT( level.a_phdflopper_grenade_exception_list, [] );
	
	if ( !isInArray( level.a_phdflopper_grenade_exception_list, str_weapon_name ) )
		ARRAY_ADD( level.a_phdflopper_grenade_exception_list, str_weapon_name );
	
}

function phdflopper_grenade_excluded_from_modifier( str_weapon_name )
{
	if ( !isDefined( level.a_phdflopper_grenade_exception_list ) || !isArray( level.a_phdflopper_grenade_exception_list ) || level.a_phdflopper_grenade_exception_list.size < 1 )
		return 0;
	
	if ( isInArray( level.a_phdflopper_grenade_exception_list, str_weapon_name ) )
		return 1;
	
	return 0;
}