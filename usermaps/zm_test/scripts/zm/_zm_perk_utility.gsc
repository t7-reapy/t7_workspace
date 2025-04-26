#using scripts\codescripts\struct;
#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\gameobjects_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\system_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\callbacks_shared;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_bgb;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_weap_riotshield;
#using scripts\zm\_zm_hero_weapon;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_perk_utility.gsh;

#precache( "lui_menu_data", "whoswho_clone_name" );
#precache( "lui_menu_data", "whoswho_clone_revive_percent" );
#precache( "lui_menu_data", "whoswho_clone_bleedout_percent" );
#precache( "triggerstring", "ZOMBIE_BUTTON_BUY_OPEN_DOOR_COST","1250" );
#precache( "triggerstring", "ZOMBIE_BUTTON_BUY_OPEN_DOOR_COST","750" );
#precache( "triggerstring", "ZOMBIE_BUTTON_BUY_CLEAR_DEBRIS_COST","1000" );
#precache( "triggerstring", "ZOMBIE_BUTTON_BUY_TRAP","1000" );
#precache( "triggerstring", "ZOMBIE_UNDEFINED" );
#precache( "triggerstring", "ZOMBIE_RANDOM_WEAPON_COST","950" );
#precache( "triggerstring", "ZOMBIE_RANDOM_WEAPON_COST","10" );
#precache( "triggerstring", "ZOMBIE_PERK_PACKAPUNCH","5000" );
#precache( "triggerstring", "ZOMBIE_PERK_PACKAPUNCH_AAT","2500" );
#precache( "triggerstring", "ZOMBIE_REVIVING" );
#precache( "string", "ZOMBIE_BGB_MACHINE_OUT_OF" );
#precache( "string", "ZOMBIE_BGB_MACHINE_OFFERING" );
#precache( "string", "ZOMBIE_BGB_MACHINE_AVAILABLE_CFILL" );
#precache( "string", "ZOMBIE_BGB_MACHINE_AVAILABLE", "10" );
#precache( "string", "ZOMBIE_BGB_MACHINE_AVAILABLE", "500" );
#precache( "string", "ZOMBIE_BGB_MACHINE_COMEBACK" );

#namespace zm_perk_utility;

REGISTER_SYSTEM_EX( "zm_perk_utility", &__init__, &__main__, undefined )

function __init__() 
{
}

function __main__() 
{
	if ( IS_TRUE( SETUP_CHECK_FOR_CHANGE ) )
		zm_perks::spare_change();
	
	if ( IS_TRUE( SETUP_NO_TARGET_OVERRIDE ) )
		level.no_target_override = &no_target_override;
	
	level.weaponZMDeathThroe = getWeapon( "t6_bare_hands_death" );
	level.perk_lost_func = &perk_lost_callback;
	
	gameobjects::main();
	level.numGametypeReservedObjectives = 1;
	
	level._actor_damage_callbacks = level.actor_damage_callbacks;
	level.actor_damage_callbacks = [];
	level.actor_damage_callbacks[ 0 ] = &actor_damage_callback_override;
}

function check_actor_damage_callbacks( inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, sHitLoc, psOffsetTime, boneIndex, surfaceType )
{
    if ( !isDefined( level._actor_damage_callbacks ) )
        return damage;
    
    for ( i = 0; i < level._actor_damage_callbacks.size; i++ )
    {
        newDamage = self [ [ level._actor_damage_callbacks[ i ] ] ]( inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, sHitLoc, psOffsetTime, boneIndex, surfaceType );
        if ( -1 != newDamage )
            return newDamage;
        
    }

    return damage;
}

function actor_damage_callback_override( str_inflictor, e_attacker, n_damage, b_flags, str_means_of_death, w_weapon, v_point, v_dir, str_hit_loc, n_ps_offset_time, n_bone_index, str_surface_type )
{
	n_damage = self check_actor_damage_callbacks( str_inflictor, e_attacker, n_damage, b_flags, str_means_of_death, w_weapon, v_point, v_dir, str_hit_loc, n_ps_offset_time, n_bone_index, str_surface_type );
	
	if ( isDefined( level.ptr_double_tab_2_damage_buff ) )
		n_damage = [ [ level.ptr_double_tab_2_damage_buff ] ]( str_inflictor, e_attacker, n_damage, b_flags, str_means_of_death, w_weapon, v_point, v_dir, str_hit_loc, n_ps_offset_time, n_bone_index, str_surface_type );
	
	if ( isDefined( level.ptr_dead_shot_damage_buff ) )
		n_damage = [ [ level.ptr_dead_shot_damage_buff ] ]( str_inflictor, e_attacker, n_damage, b_flags, str_means_of_death, w_weapon, v_point, v_dir, str_hit_loc, n_ps_offset_time, n_bone_index, str_surface_type );
	
	return n_damage;
}

// --------------------------------
//	NO TARGET OVERRIDE
// --------------------------------
function validate_and_set_no_target_position( position )
{
	if( isDefined( position ) )
	{
		goal_point = getClosestPointOnNavMesh( position.origin, 100 );
		if( isDefined( goal_point ) )
		{
			self setGoal( goal_point );
			self.has_exit_point = 1;
			return 1;
		}
	}
	
	return 0;
}

function no_target_override( zombie )
{
	if( isDefined( zombie.has_exit_point ) )
		return;
	
	players = level.players;
	
	dist_zombie = 0;
	dist_player = 0;
	dest = 0;

	if ( isDefined( level.zm_loc_types[ "dog_location" ] ) )
	{
		locs = array::randomize( level.zm_loc_types[ "dog_location" ] );
		
		for ( i = 0; i < locs.size; i++ )
		{
			found_point = 0;
			foreach( player in players )
			{
				if( player laststand::player_is_in_laststand() )
					continue;
				
				away = vectorNormalize( self.origin - player.origin );
				endPos = self.origin + VectorScale( away, 600 );
				dist_zombie = distanceSquared( locs[ i ].origin, endPos );
				dist_player = distanceSquared( locs[ i ].origin, player.origin );
		
				if ( dist_zombie < dist_player )
				{
					dest = i;
					found_point = 1;
				}
				else
					found_point = 0;
				
			}
			if( found_point )
			{
				if( zombie validate_and_set_no_target_position( locs[ i ] ) )
					return;
				
			}
		}
	}
	
	escape_position = zombie get_escape_position_in_current_zone();
			
	if( zombie validate_and_set_no_target_position( escape_position ) )
		return;
	
	escape_position = zombie get_escape_position();
	
	if( zombie validate_and_set_no_target_position( escape_position ) )
		return;
	
	zombie.has_exit_point = 1;
	
	zombie setGoal( zombie.origin );
}

function get_escape_position()
{
	self endon( "death" );
	
	str_zone = self.zone_name;
	
	if( !isDefined( str_zone ) )
		str_zone = self.zone_name;

	if ( isDefined( str_zone ) )
	{
		a_zones = get_adjacencies_to_zone( str_zone );
		a_wait_locations = get_wait_locations_in_zones( a_zones );
		s_farthest = self get_farthest_wait_location( a_wait_locations );
	}
	return s_farthest;
}

function get_wait_locations_in_zones( a_zones )
{
	a_wait_locations = [];
	
	foreach ( zone in a_zones )
		a_wait_locations = arrayCombine( a_wait_locations, level.zones[ zone ].a_loc_types[ "dog_location" ], true, false );

	return a_wait_locations;
}

function get_adjacencies_to_zone( str_zone )
{
	a_adjacencies = [];
	a_adjacencies[ 0 ] = str_zone;
	
	a_adjacent_zones = getArrayKeys( level.zones[ str_zone ].adjacent_zones );
	for ( i = 0; i < a_adjacent_zones.size; i++ )
	{
		if ( level.zones[ str_zone ].adjacent_zones[ a_adjacent_zones[ i ] ].is_connected )
			ARRAY_ADD( a_adjacencies, a_adjacent_zones[ i ] );
		
	}
	return a_adjacencies;
}

function get_escape_position_in_current_zone()
{
	self endon( "death" );
	
	str_zone = self.zone_name; 
	
	if ( !isDefined( str_zone ) )
		str_zone = self.zone_name;

	if ( isDefined( str_zone ) )
	{
		a_wait_locations = get_wait_locations_in_zone( str_zone );

		if ( isDefined( a_wait_locations ) )
			s_farthest = self get_farthest_wait_location( a_wait_locations );
		
	}
	return s_farthest;
}

function get_wait_locations_in_zone( zone )
{
	if ( isDefined( level.zones[ zone ].a_loc_types[ "dog_location" ] ) )
	{
		a_wait_locations = [];
		a_wait_locations = arrayCombine( a_wait_locations, level.zones[ zone ].a_loc_types[ "dog_location" ], true, false );
		return a_wait_locations;
	}
	return undefined;
}

function get_farthest_wait_location( a_wait_locations )
{
	if ( !isDefined( a_wait_locations ) || a_wait_locations.size == 0 )
		return undefined;
	
	n_farthest_index = 0;
	n_distance_farthest = 0;
	for ( i = 0; i < a_wait_locations.size; i++ )
	{
		n_distance_sq = distanceSquared( self.origin, a_wait_locations[ i ].origin );
		
		if ( n_distance_sq > n_distance_farthest )
		{
			n_distance_farthest = n_distance_sq;
			n_farthest_index = i;
		}
	}
	
	return a_wait_locations[ n_farthest_index ];
}

function get_player_specific_perk_limit()
{
	if ( !isDefined( level.perk_purchase_limit ) )
		return 0;
	
	player_perk_limit = level.perk_purchase_limit;
	
	if ( isDefined( self.additional_perk_slots ) && self.additional_perk_slots > 0 )
		player_perk_limit += self.additional_perk_slots;
		
	return player_perk_limit;
}

function check_under_player_limit()
{
	players_current_perk_limit = self get_player_specific_perk_limit();
	
	players_current_perk_list = self zm_perks::get_perk_array();
	
	if ( isDefined( players_current_perk_list ) && players_current_perk_list.size >= players_current_perk_limit )
		return 0;
	
	return 1;
}

function level_total_available_perks()
{
	perks_in_level = level._random_perk_machine_perk_list;
	if ( !isDefined( perks_in_level ) || perks_in_level.size < 1 )
		return 0;
	
	obtainable_perks_at_this_time = 0;
	for ( i = 0; i < perks_in_level.size; i++ )
	{
		if ( self zm_perk_utility::is_perk_paused( perks_in_level[ i ] ) )
			continue;
		if ( level zm_perk_utility::is_perk_paused( perks_in_level[ i ] ) )
			continue;
		
		obtainable_perks_at_this_time++;
	}
	return obtainable_perks_at_this_time;
}

function add_perk_to_wunderfizz( perk )
{
	if ( !isDefined( level._random_perk_machine_perk_list ) )
		level._random_perk_machine_perk_list = [];
	
	if ( isDefined( level._random_perk_machine_perk_list ) && level._random_perk_machine_perk_list.size > 0 )
	{
		for ( i = 0; i < level._random_perk_machine_perk_list.size; i++ )
		{
			if ( level._random_perk_machine_perk_list[ i ] === perk )
				return;
		
		}
	}
	
	level._random_perk_machine_perk_list[ level._random_perk_machine_perk_list.size ] = perk;
}

function in_wunderfizz_queue( perk )
{
	if ( !isDefined( level._random_perk_machine_perk_list ) )
		level._random_perk_machine_perk_list = [];
	
	if ( isDefined( level._random_perk_machine_perk_list ) && level._random_perk_machine_perk_list.size > 0 )
	{
		for ( i = 0; i < level._random_perk_machine_perk_list.size; i++ )
		{
			if ( level._random_perk_machine_perk_list[ i ] === perk )
				return 1;
		
		}
	}
	return 0;
}

function pause_to_wunderfizz( perk )
{
	if ( !isDefined( level.wunderfizz_paused_queue ) )
		level.wunderfizz_paused_queue = [];
	
	if ( !in_wunderfizz_queue( perk ) )
		return;
	
	ARRAY_ADD( level.wunderfizz_paused_queue, perk );
	arrayRemoveValue( level._random_perk_machine_perk_list, perk );
}

function unpause_to_wunderfizz( perk )
{
	if ( !isDefined( level.wunderfizz_paused_queue ) )
		level.wunderfizz_paused_queue = [];
	
	if ( !isDefined( level._random_perk_machine_perk_list ) )
		level._random_perk_machine_perk_list = [];
	
	if ( !is_wunderfizz_paused( perk ) || in_wunderfizz_queue( perk ) )
		return;
	
	ARRAY_ADD( level._random_perk_machine_perk_list, perk );
	arrayRemoveValue( level.wunderfizz_paused_queue, perk );
}

function is_wunderfizz_paused( perk )
{
	if ( !isDefined( level.wunderfizz_paused_queue ) )
		level.wunderfizz_paused_queue = [];
	
	for ( i = 0; i < level.wunderfizz_paused_queue.size; i++ )
	{
		if ( level.wunderfizz_paused_queue[ i ] == perk )
			return 1;
		
	}
	return 0;
}

function global_pause_perk( perk, retain_perk = 1 )
{
	if ( !isDefined( level.disabled_perks ) )
		level.disabled_perks = [];
	
	if ( IS_TRUE( retain_perk ) )
		level.disabled_perks[ perk ] = 1;
	else
		level.disabled_perks[ perk ] = 0;
	
	all_players_pause_perk( perk, retain_perk );
	pause_to_wunderfizz( perk );
}

function global_unpause_perk( perk )
{
	if ( !isDefined( level.disabled_perks ) )
		level.disabled_perks = [];
	
	level.disabled_perks[ perk ] = 0;
	
	all_players_unpause_perk( perk );
	unpause_to_wunderfizz( perk );
}

function _hasPerk( str_perk, b_count_paused = 1 )
{
	if ( self hasPerk( str_perk ) || ( IS_TRUE( b_count_paused ) && self is_perk_paused( str_perk ) ) )
		return 1;
	
	return 0;
}

function perk_lost_callback( str_perk )
{
	if ( self is_perk_paused( str_perk ) )
		self.disabled_perks[ str_perk ] = 0;
	
}

function is_perk_paused( perk )
{
	if ( !isDefined( self.disabled_perks ) )
		self.disabled_perks = [];
	
	if ( !isDefined( self.disabled_perks[ perk ] ) )
		self.disabled_perks[ perk ] = 0;
	
	return self.disabled_perks[ perk ];
}

function all_players_pause_perk( perk, retain_perk = 1 )
{
	players = getPlayers();
	for ( i = 0; i < players.size; i++ )
		players[ i ] player_pause_perk( perk, retain_perk );
	
}

function all_players_unpause_perk( perk )
{
	players = getPlayers();
	for ( i = 0; i < players.size; i++ )
		players[ i ] player_unpause_perk( perk );
	
}

function player_pause_perk( perk, retain_perk = 1 )
{
	if ( !isDefined( self.disabled_perks ) )
		self.disabled_perks = [];
	
	if ( IS_TRUE( self.disabled_perks[ perk ] ) )
		return;
	
	if ( !self hasPerk( perk ) )
		return;
	
	if ( IS_TRUE( retain_perk ) )
		self.disabled_perks[ perk ] = 1;
	else
		self.disabled_perks[ perk ] = 0;
	
	self unsetPerk( perk );
	self.num_perks--;
	
	if ( isDefined( level._custom_perks[ perk ] ) && isDefined( level._custom_perks[ perk ].player_thread_take ) )
		self thread [[ level._custom_perks[ perk ].player_thread_take ]]( 1 );
	if ( isDefined( level._custom_perks[ perk ] ) && isDefined( level._custom_perks[ perk ].clientfield_set ) )
		self thread [[ level._custom_perks[ perk ].clientfield_set ]]( 2 );
	
	self notify( perk + "_paused" );
}

function player_unpause_perk( perk )
{
	if ( !isDefined( self.disabled_perks ) )
		self.disabled_perks = [];
	
	if ( !IS_TRUE( self.disabled_perks[ perk ] ) )
		return;
	
	if ( self hasPerk( perk ) )
		return;
	
	self.disabled_perks[ perk ] = 0;
	
	self setPerk( perk );
	self.num_perks++;
	
	if ( isDefined( level._custom_perks[ perk ] ) && isDefined( level._custom_perks[ perk ].player_thread_give ) )
		self thread [[ level._custom_perks[ perk ].player_thread_give ]]();
	if ( isDefined( level._custom_perks[ perk ] ) && isDefined( level._custom_perks[ perk ].clientfield_set ) )
		self thread [[ level._custom_perks[ perk ].clientfield_set ]]( 1 );

	self notify( perk + "_unpaused" );
}

function give_random_perk()
{
	random_perk = undefined;

	a_str_perks = GetArrayKeys( level._custom_perks );

	perks = [];
	for ( i = 0; i < a_str_perks.size; i++ )
	{
		perk = a_str_perks[i];

		if ( isdefined( self.perk_purchased ) && self.perk_purchased == perk )
		{
			continue;
		}

		if ( !self HasPerk( perk ) && !self is_perk_paused( perk ) && !level is_perk_paused( perk ) )
		{
			perks[ perks.size ] = perk;
		}
	}

	if ( perks.size > 0 )
	{
		perks = array::randomize( perks );
		random_perk = perks[0];
		self zm_perks::give_perk( random_perk );
	}
	else
	{
		// No Perks Left To Get
		self playSoundToPlayer( level.zmb_laugh_alias, self );
	}

	return( random_perk );
}

function is_stock_map()
{
	if ( level.script == "zm_factory" || level.script == "zm_zod" || level.script == "zm_castle" || level.script == "zm_island" || level.script == "zm_stalingrad" || level.script == "zm_genesis" || level.script == "zm_prototype" || level.script == "zm_asylum" || level.script == "zm_sumpf" || level.script == "zm_theater" || level.script == "zm_cosmodrome" || level.script == "zm_temple" || level.script == "zm_moon" || level.script == "zm_tomb" )
		return 1;
	
	return 0;
}

function place_perk_machine( origin, angles, perk, model )
{
	t_use = spawn( "trigger_radius_use", origin + ( 0, 0, 60 ), 0, 40, 80 );
	t_use.targetname = "zombie_vending";			
	t_use.script_noteworthy = perk;	
	t_use TriggerIgnoreTeam();
	
	perk_machine = spawn( "script_model", origin );
	if ( !isDefined( angles ) )
		angles = ( 0, 0, 0 );
	
	perk_machine.angles = angles;
	perk_machine setModel( model );
	bump_trigger = spawn( "trigger_radius", origin + ( 0, 0, 30 ), 0, 40, 80 );
	bump_trigger.script_activated = 1;
	bump_trigger.script_sound = "zmb_perks_bump_bottle";
	bump_trigger.targetname = "audio_bump_trigger";
	
	collision = spawn( "script_model", origin, 1 );
	collision.angles = angles;
	collision setModel( "zm_collision_perks1" );
	collision.script_noteworthy = "clip";
	collision disconnectPaths();
	
	t_use.clip = collision;
	t_use.machine = perk_machine;
	t_use.bump = bump_trigger;
	
	[[ level._custom_perks[ perk ].perk_machine_set_kvps ]]( t_use, perk_machine, bump_trigger, collision );
}

function force_power( perk )
{
	str_endon = perk + PERK_END_POWER_THREAD;
	level endon( str_endon );
	
	str_on = perk + "_on";
	str_off = perk + "_off";
	str_notify = perk + "_power_on";
	
	script = toLower( getDvarString( "mapname" ) );
	
	if ( script == "zm_tomb" )
	{
		level flag::wait_till( "initial_blackscreen_passed" );
		level.zone_capture.perk_machines_always_on[ level.zone_capture.perk_machines_always_on.size ] = perk;
		
		machine = getEntArray( level._custom_perks[ perk ].radiant_machine_name, "targetname" );
		machine_triggers = getEntArray( level._custom_perks[ perk ].radiant_machine_name, "target" );
		
		for ( i = 0; i < machine.size; i++ )
		{
			machine[ i ] setModel( level.machine_assets[ perk ].on_model );
			machine[ i ] vibrate( ( 0, -100, 0 ), .3, .4, 3 );
			machine[ i ] playSound( "zmb_perks_power_on" );
			machine[ i ] thread zm_perks::perk_fx( level._custom_perks[ perk ].machine_light_effect );
			machine[ i ] thread zm_perks::play_loop_on_machine();
		}
		
		level notify( str_notify );
		return;
	}
	level flag::wait_till( "initial_blackscreen_passed" );
	
	while ( true )
	{
		machine = getEntArray( level._custom_perks[ perk ].radiant_machine_name, "targetname" );
		machine_triggers = getEntArray( level._custom_perks[ perk ].radiant_machine_name, "target" );
		
		for ( i = 0; i < machine.size; i++ )
		{
			machine[ i ] setModel( level.machine_assets[ perk ].on_model );
			machine[ i ] vibrate( ( 0, -100, 0 ), .3, .4, 3 );
			machine[ i ] playSound( "zmb_perks_power_on" );
			machine[ i ] thread zm_perks::perk_fx( level._custom_perks[ perk ].machine_light_effect );
			machine[ i ] thread zm_perks::play_loop_on_machine();
		}
		level notify( str_notify );
		
		array::thread_all( machine_triggers, &zm_perks::set_power_on, 1 );
		if ( isDefined( level.machine_assets[ perk ].power_on_callback ) )
			array::thread_all( machine, level.machine_assets[ perk ].power_on_callback );
		
		level waittill( str_off );
			
		if ( isDefined( level.machine_assets[ perk ].power_off_callback ) )
			array::thread_all( machine, level.machine_assets[ perk ].power_off_callback );
		
		array::thread_all( machine, &zm_perks::turn_perk_off );
		
		for ( i = 0; i < machine.size; i++ )
			machine[ i ] setModel( level.machine_assets[ perk ].off_model );
		
		level thread zm_perks::do_initial_power_off_callback( machine, perk );
		array::thread_all( machine_triggers, &zm_perks::set_power_on, 0 );
	
		level waittill( str_on );
	}
}

function handle_bgb_perk_lose_specialty_conflict( ns_specialty, str_perk, ns_bgb = undefined )
{
	self endon( "death_or_disconnect" );
	
	if ( isArray( ns_specialty ) )
	{
		for ( i = 0; i < ns_specialty.size; i++ )
			self thread handle_bgb_perk_lose_specialty_conflict( ns_specialty[ i ], str_perk, ns_bgb );
		
		return;
	}
	
	while ( 1 )
	{
		while ( self hasPerk( ns_specialty ) )
			WAIT_SERVER_FRAME;
		
		if ( !self hasPerk( str_perk ) && ( isDefined( ns_bgb ) && !is_bgb_active( ns_bgb ) ) )
			break;
			
		self setPerk( ns_specialty );
	}
}

function is_bgb_active( ns_bgb )
{
	if ( !isArray( ns_bgb ) )
	{
		if ( self bgb::is_enabled( ns_bgb ) || self bgb::is_active( ns_bgb ) )
			return 1;
		
		return 0;		
	}
	
	for ( i = 0; i < ns_bgb.size; i++ )
		if ( self bgb::is_enabled( ns_bgb[ i ] ) || self bgb::is_active( ns_bgb[ i ] ) )
			return 1;
	
	return 0;
}

function print_version( str_perk, str_version )
{
	if ( IS_TRUE( PRINT_VERSION_NUMBERS ) )
		iPrintLnBold( "HARRY : " + str_perk + " : " + str_version );
	
}

function setup_whoswho_waypoint(player)
{
	n_free_number = gameobjects::get_next_obj_id();
	objective_Add( n_free_number, "active", self, istring( "waypoint_whoswho" ) );
	objective_SetVisibleToAll( n_free_number );
	objective_SetUIModelValue( n_free_number, "priority", 10 );
	objective_SetUIModelValue( n_free_number, "whoswho_clone_name", player.playername );
	objective_SetUIModelValue( n_free_number, "whoswho_clone_bleedout_percent", 1.0 );
	objective_SetUIModelValue( n_free_number, "whoswho_clone_revive_percent", 0.0 );
	
	self.n_obj_id = n_free_number;
}

function destroy_waypoint()
{
	objective_Delete( self.n_obj_id );
	gameobjects::release_obj_id( self.n_obj_id );	
}

function delay_if_blackscreen_pending()
{
	while ( !level flag::exists( "initial_blackscreen_passed" ) )
		WAIT_SERVER_FRAME;
	
	if ( !level flag::get( "initial_blackscreen_passed" ) )
		level flag::wait_till( "initial_blackscreen_passed" );
	
}

function delay_if_all_players_connected_pending()
{
	while ( !level flag::exists( "all_players_connected" ) )
		WAIT_SERVER_FRAME;
	
	if ( !level flag::get( "all_players_connected" ) )
		level flag::wait_till( "all_players_connected" );
	
}

function increment_ignoreall()
{
	DEFAULT( self.ignorall_count, 0 );
	self.ignorall_count++;
	self.ignoreall = ( self.ignorall_count > 0 );
}

function decrement_ignoreall()
{
	DEFAULT( self.ignorall_count, 0 );
	if ( self.ignorall_count > 0 )
		self.ignorall_count--;
	else
		assertMsg( "making ignorall_count less than 0" );
	
	self.ignoreall = ( self.ignorall_count > 0 );
}

function launch_dead_zombie_away_from_point( v_origin, n_min_forward_force, n_max_forward_force, n_min_upward_force, n_max_upward_force, str_tag = "tag_origin" )
{
	if ( isDefined( self ) )
		v_launch = vectorScale( vectorNormalize( self.origin - v_origin ), randomIntRange( n_min_forward_force, n_max_forward_force ) ) + ( 0, 0, randomIntRange( n_min_upward_force, n_max_upward_force ) );
	
	if ( !self isRagdoll() )
		self startRagDoll();
	
	self launchRagdoll( v_launch, str_tag );
}

function is_touching_teleport_exlusion( origin )
{
	a_exlusion_volumes = getEntArray( "player_no_spawn_volume", "targetname" );

	if ( !isDefined( a_exlusion_volumes ) || a_exlusion_volumes.size < 1 )
		return 0;
	
	if ( !isDefined( level.e_check_point ) )
		level.e_check_point = spawn( "script_origin", origin + ( 0, 0, 40 ) );
	else
		level.e_check_point.origin = origin + ( 0, 0, 40 );
	
	one_valid_zone = 0;
	for ( i = 0; i < a_exlusion_volumes.size; i++ )
	{
		if ( level.e_check_point isTouching( a_exlusion_volumes[ i ] ) )
		{
			one_valid_zone = 1;
			break;
		}
	}
	
	return one_valid_zone;
}

function get_player_spawn_point( n_min = 800, n_max = 1200, n_half_height = 200, n_inner_spacing = 32, n_radius_from_edges = 16 )
{
	v_position = self.origin;
	a_query_result = positionQuery_Source_Navigation(	v_position, n_min, n_max, n_half_height, n_inner_spacing, n_radius_from_edges );	

	if ( a_query_result.data.size )
	{
		a_s_locs = array::randomize( a_query_result.data );
	
		if ( isDefined( a_s_locs ) )
		{
			foreach ( s_loc in a_s_locs )
			{
				if ( zm_utility::check_point_in_enabled_zone( s_loc.origin, true, level.active_zones ) && !is_touching_teleport_exlusion( s_loc.origin ) )
					return s_loc;
				
			}
		}
	}
	
	return undefined;
}

function get_player_loadout( a_exclude_perks = [] )
{
	s_loadout = spawnStruct(); 
	s_loadout.w_current_weapon = ( self getCurrentWeapon() != level.weaponNone && isWeapon( self getCurrentWeapon() ) && !zm_utility::is_offhand_weapon( self getCurrentWeapon() ) ? ( self getCurrentWeapon() ) : undefined );
	s_loadout.w_stowed_weapon = ( self getStowedWeapon() != level.weaponNone && isWeapon( self getStowedWeapon() ) ? ( self getStowedWeapon() ) : undefined );
	s_loadout.a_all_weapons = [];
	s_loadout.n_score = ( isDefined( self.score ) ? self.score : 0 );
	if ( self hasRiotShield() )
	{
		s_loadout.n_shield_health = self damageRiotShield( 0 );
		s_loadout.w_shield = self.weaponRiotshield;
	}
	
	a_all_weapons = self getWeaponsList();
	for ( i = 0; i < a_all_weapons.size; i++ )
		if ( isDefined( a_all_weapons[ i ] ) && a_all_weapons[ i ] != level.weaponNone && zm_weapons::is_weapon_included( a_all_weapons[ i ] ) || zm_weapons::is_weapon_upgraded( a_all_weapons[ i ] ) )
			array::add( s_loadout.a_all_weapons, zm_weapons::get_player_weapondata( self, a_all_weapons[ i ] ), 0 );
	
	s_loadout.a_perks = array::exclude( ( ( isDefined( self zm_perks::get_perk_array() ) ) ? self zm_perks::get_perk_array() : [] ), a_exclude_perks );
	s_loadout.a_disabled_perks = ( isDefined( self.disabled_perks ) && isArray( self.disabled_perks ) ? self.disabled_perks : [] );
	s_loadout.a_additional_primary_weapons_lost = self.a_additional_primary_weapons_lost;
	s_loadout.w_melee_weapon = self zm_utility::get_player_melee_weapon();
	s_loadout.w_lethal_grenade_weapon = self zm_utility::get_player_lethal_grenade();
	s_loadout.w_lethal_grenade_ammo = ( isDefined( s_loadout.w_lethal_grenade_weapon ) ? self getAmmoCount( s_loadout.w_lethal_grenade_weapon ) : 0 );
	s_loadout.w_tactical_grenade_weapon = self zm_utility::get_player_tactical_grenade();
	s_loadout.w_tactical_grenade_ammo = ( isDefined( s_loadout.w_tactical_grenade_weapon ) ? self getAmmoCount( s_loadout.w_tactical_grenade_weapon ) : 0 );
	s_loadout.w_mine_weapon = self zm_utility::get_player_placeable_mine();
	s_loadout.w_mine_ammo = ( isDefined( s_loadout.w_mine_weapon ) ? self getAmmoCount( s_loadout.w_mine_weapon ) : 0 );
	s_loadout.w_hero_weapon = self zm_utility::get_player_hero_weapon();
	s_loadout.w_hero_weapon_charge = self gadgetPowerGet( 0 );
	
	return s_loadout; 
}

function remove_player_loadout()
{
	self takeAllWeapons();
	self zm_hero_weapon::set_hero_weapon_state( undefined, 0 );
	self clientfield::set_player_uimodel( "hudItems.showDpadRight", 0 );
}

function give_player_loadout( s_loadout, b_remove_player_weapons = 1, b_immediate_weapon_switch = 0, b_remove_player_perks = 0, a_exclude_perks = [], a_exclude_guns = [] )
{
	DEFAULT( self.disabled_perks, [] );
	
	if ( IS_TRUE( b_remove_player_weapons ) )
		self takeAllWeapons();
	if ( IS_TRUE( b_remove_player_perks ) )
	{
		a_player_current_perks = ( ( isDefined( self zm_perks::get_perk_array() ) && isArray( self zm_perks::get_perk_array() ) ) ? self zm_perks::get_perk_array() : [] );
		a_player_current_perks = arrayCombine( a_player_current_perks, self.disabled_perks, 0, 1 );
		a_loadout_perks = arrayCombine( s_loadout.a_perks, s_loadout.a_disabled_perks, 0, 1 );
		a_perks_to_take = array::exclude( a_loadout_perks, a_player_current_perks );
		
		for ( i = 0; i < a_perks_to_take.size; i++ )
		{
			if ( self zm_perk_utility::is_perk_paused( a_perks_to_take[ i ] ) )
				continue;
			
			self notify( a_perks_to_take[ i ] + "_stop" );
		}
	}
	
	a_perks = ( ( isDefined( s_loadout.a_perks ) ) ? s_loadout.a_perks : [] );
	if ( isDefined( s_loadout.a_disabled_perks ) && isArray( s_loadout.a_disabled_perks ) && s_loadout.a_disabled_perks.size > 0 )
		for ( i = 0; i < s_loadout.a_disabled_perks.size; i++ )
			if ( isDefined( s_loadout.a_disabled_perks[ i ] ) )
			{
				if ( !isInArray( a_perks, s_loadout.a_disabled_perks[ i ] ) )
					a_perks[ s_loadout.a_disabled_perks[ i ] ] = 1;
				
				self zm_perk_utility::player_pause_perk( s_loadout.a_disabled_perks[ i ] );
			}
	
	for ( i = 0; i < a_perks.size; i++ )
	{
		if ( isInArray( a_exclude_perks, a_perks[ i ] ) )
			continue;
		
		if ( level flag::exists( "solo_game" ) && level flag::exists( "solo_revive" ) && level flag::get( "solo_game" ) && !level flag::get( "solo_revive" ) && a_perks[ i ] == "specialty_quickrevive" )
			level.solo_lives_given--;
		
		if ( a_perks[ i ] == "specialty_additionalprimaryweapon" && !self hasPerk( "specialty_additionalprimaryweapon" ) )
		{
			a_additional_primary_weapons_lost = ( isDefined( self.a_additional_primary_weapons_lost ) && isArray( self.a_additional_primary_weapons_lost ) ? self.a_additional_primary_weapons_lost : s_loadout.a_additional_primary_weapons_lost );
			self.a_additional_primary_weapons_lost = undefined;
			self zm_perks::give_perk( a_perks[ i ] );
			self.a_additional_primary_weapons_lost = a_additional_primary_weapons_lost;
		}
		else
			self zm_perks::give_perk( a_perks[ i ] );
	
	}
	
	for ( i = 0; i < s_loadout.a_all_weapons.size; i++ )
		if ( isDefined( s_loadout.a_all_weapons[ i ][ "weapon" ] ) && !isInArray( a_exclude_guns, s_loadout.a_all_weapons[ i ][ "weapon" ].name ) && ( zm_utility::is_offhand_weapon( s_loadout.a_all_weapons[ i ][ "weapon" ] ) || self getWeaponsListPrimaries().size < zm_utility::get_player_weapon_limit( self ) ) )
			self zm_weapons::weapondata_give( s_loadout.a_all_weapons[ i ] );
	
	if ( isDefined( s_loadout.w_stowed_weapon ) && self hasWeapon( s_loadout.w_stowed_weapon ) )
		self setStowedWeapon( s_loadout.w_stowed_weapon );
	
	ptr_weapon_switch = ( IS_TRUE( b_immediate_weapon_switch ) ? &switchToWeaponImmediate : &switchToWeapon );
	if ( !isDefined( s_loadout.w_current_weapon ) )
		self [ [ ptr_weapon_switch ] ]();
	else
		self [ [ ptr_weapon_switch ] ]( s_loadout.w_current_weapon );
	
	if ( isDefined( s_loadout.n_shield_health ) )
	{
		n_shield_health = self damageRiotShield( s_loadout.w_shield.weaponStartHitPoints - s_loadout.n_shield_health );
		self riotshield::player_set_shield_health( n_shield_health, s_loadout.w_shield.weaponStartHitPoints );
	}
	
	if ( isDefined( s_loadout.w_melee_weapon ) )
	{
		self giveWeapon( s_loadout.w_melee_weapon );
		self zm_utility::set_player_melee_weapon( s_loadout.w_melee_weapon );
	}
	
	if ( isDefined( s_loadout.w_lethal_grenade_weapon ) )
	{
		self giveWeapon( s_loadout.w_lethal_grenade_weapon );
		self zm_utility::set_player_lethal_grenade( s_loadout.w_lethal_grenade_weapon );
		self setWeaponAmmoClip( s_loadout.w_lethal_grenade_weapon, s_loadout.w_lethal_grenade_ammo );
	}
	
	if ( isDefined( s_loadout.w_tactical_grenade_weapon ) )
	{
		self giveWeapon( s_loadout.w_tactical_grenade_weapon );
		self zm_utility::set_player_tactical_grenade( s_loadout.w_tactical_grenade_weapon );
		self setWeaponAmmoClip( s_loadout.w_tactical_grenade_weapon, s_loadout.w_tactical_grenade_ammo );
	}
	
	if ( isDefined( s_loadout.w_mine_weapon ) )
	{
		self giveWeapon( s_loadout.w_mine_weapon );
		self zm_utility::set_player_placeable_mine( s_loadout.w_mine_weapon );
		self setWeaponAmmoClip( s_loadout.w_mine_weapon, s_loadout.w_mine_ammo );
		self clientfield::set_player_uimodel( "hudItems.showDpadRight", 1 );
	}
	
	if ( isDefined( s_loadout.w_hero_weapon ) )
	{
		self giveWeapon( s_loadout.w_hero_weapon );
		self zm_utility::set_player_hero_weapon( s_loadout.w_hero_weapon );
		if ( isDefined( s_loadout.w_hero_weapon_charge ) )
		{
			self gadgetPowerSet( 0, s_loadout.w_hero_weapon_charge );
			if ( self gadgetPowerGet( 0 ) == 100 )
				self zm_hero_weapon::set_hero_weapon_state( 0, 2 );
			else
				self zm_hero_weapon::set_hero_weapon_state( 0, 1 );
			
		}
	}
}

function register_vulture_perk_safe()
{
	delay_if_blackscreen_pending();
	self clientfield::set( "vulture_aid_register_perk", 1 );
}