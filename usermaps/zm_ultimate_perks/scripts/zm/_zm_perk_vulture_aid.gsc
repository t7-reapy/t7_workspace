#using scripts\codescripts\struct;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\gametypes\_globallogic_score;
#using scripts\zm\_zm;
#using scripts\zm\_zm_laststand;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_perk_utility;
#insert scripts\zm\_zm_powerups.gsh;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\zm\_zm_perk_vulture_aid.gsh;
#insert scripts\zm\_zm_perk_utility.gsh;

#precache( "string", "HB21_ZM_PERKS_VULTUREAID" );
#precache( "triggerstring", "HB21_ZM_PERKS_VULTUREAID", VULTUREAID_PERK_COST_STRING );
#precache( "model", VULTUREAID_AMMO_MODEL );
#precache( "model", VULTUREAID_POINTS_MODEL );
#precache( "fx", VULTUREAID_MACHINE_LIGHT_FX );
#precache( "fx", VULTUREAID_DROPS_GLOW_FX );

#namespace zm_perk_vulture_aid;

REGISTER_SYSTEM_EX( "zm_perk_vulture_aid", &__init__, &__main__, undefined )

// CALLBACKS AND OVERRIDES
// 
// NONE

//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------
function __init__()
{	
	script = toLower( getDvarString( "mapname" ) );
	if ( script == "zm_castle" )
		return;
		
	if ( IS_TRUE( VULTUREAID_LEVEL_USE_PERK ) )
		enable_vulture_aid_perk_for_level();
	
}

function __main__()
{	
	script = toLower( getDvarString( "mapname" ) );
	if ( script == "zm_castle" )
		return;
		
	if ( IS_TRUE( VULTUREAID_LEVEL_USE_PERK ) )
		vulture_aid_main();
	
}

function enable_vulture_aid_perk_for_level()
{		
	zm_perks::register_perk_basic_info( VULTUREAID_PERK, VULTUREAID_ALIAS, VULTUREAID_PERK_COST, &"HB21_ZM_PERKS_VULTUREAID", GetWeapon( VULTUREAID_PERK_BOTTLE_WEAPON ) );
	zm_perks::register_perk_precache_func( VULTUREAID_PERK, &vulture_aid_precache );
	zm_perks::register_perk_clientfields( VULTUREAID_PERK, &vulture_aid_register_clientfield, &vulture_aid_set_clientfield );
	zm_perks::register_perk_machine( VULTUREAID_PERK, &vulture_aid_perk_machine_setup );
	zm_perks::register_perk_threads( VULTUREAID_PERK, &vulture_aid_give_perk, &vulture_aid_take_perk );
	zm_perks::register_perk_host_migration_params( VULTUREAID_PERK, VULTUREAID_RADIANT_MACHINE_NAME, VULTUREAID_PERK );
	if ( zm_perk_utility::is_stock_map() && ( level.script == "zm_zod" || level.script == "zm_genesis" || level.script == "zm_tomb" ) )
		zm_perks::register_perk_machine_power_override( VULTUREAID_PERK, &vulture_aid_power_override );
	
	if ( level.script == "zm_zod" )
		zm_perk_utility::place_perk_machine( ( 1992, -3417, -400 ), ( 0, 180, 0 ), VULTUREAID_PERK, VULTUREAID_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_factory" )
		zm_perk_utility::place_perk_machine( ( -704, -1048, 200 ), ( 0, 0, 0 ), VULTUREAID_PERK, VULTUREAID_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_castle" )
		zm_perk_utility::place_perk_machine( ( 833, 3772, 672 ), ( 0, 270, 0 ), VULTUREAID_PERK, VULTUREAID_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_island" )
		zm_perk_utility::place_perk_machine( ( 2091, 1070, -703 ), ( 0, 40, 0 ), VULTUREAID_PERK, VULTUREAID_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_stalingrad" )
		zm_perk_utility::place_perk_machine( ( 164, 1911, 336 ), ( 0, -34, 0 ), VULTUREAID_PERK, VULTUREAID_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_genesis" )
		zm_perk_utility::place_perk_machine( ( 1457, 4168, 1478 ), ( 0, 90, 0 ), VULTUREAID_PERK, VULTUREAID_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_asylum" )
		zm_perk_utility::place_perk_machine( ( -329, 807, 226 ), ( 0, -180 + 90, 0 ), VULTUREAID_PERK, VULTUREAID_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_sumpf" )
		zm_perk_utility::place_perk_machine( ( 9161, -421, -707 ), ( 0, 90 + 90, 0 ), VULTUREAID_PERK, VULTUREAID_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_theater" )
		zm_perk_utility::place_perk_machine( ( 940, 1359, -15 ), ( 0, 90 + 90, 0 ), VULTUREAID_PERK, VULTUREAID_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_cosmodrome" )
		zm_perk_utility::place_perk_machine( ( 1710, 947, 368 ), ( 0, -180 + 90, 0 ), VULTUREAID_PERK, VULTUREAID_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_temple" )
		zm_perk_utility::place_perk_machine( ( -908, -1385, -465 ), ( 0, 90 + 90, 0 ), VULTUREAID_PERK, VULTUREAID_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_moon" )
		zm_perk_utility::place_perk_machine( ( -96, 5543, 0 ), ( 0, 90 + 90, 0 ), VULTUREAID_PERK, VULTUREAID_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_tomb" )
		zm_perk_utility::place_perk_machine( ( -2751, 335, 59 ), ( 0, -90 + 90, 0 ), VULTUREAID_PERK, VULTUREAID_MACHINE_DISABLED_MODEL );
	
}

function vulture_aid_precache()
{
	level._effect[ VULTUREAID_PERK ] = VULTUREAID_MACHINE_LIGHT_FX;
	
	level.machine_assets[ VULTUREAID_PERK ] = spawnStruct();
	level.machine_assets[ VULTUREAID_PERK ].weapon = getWeapon( VULTUREAID_PERK_BOTTLE_WEAPON );
	level.machine_assets[ VULTUREAID_PERK ].off_model = VULTUREAID_MACHINE_DISABLED_MODEL;
	level.machine_assets[ VULTUREAID_PERK ].on_model = VULTUREAID_MACHINE_ACTIVE_MODEL;
}

function vulture_aid_register_clientfield() 
{
	clientfield::register( "clientuimodel", VULTUREAID_CLIENTFIELD, VERSION_SHIP, 2, "int" );
	clientfield::register( "clientuimodel", VULTUREAID_DISEASE_METER_CF, VERSION_SHIP, 5, "float" );
	clientfield::register( "scriptmover", VULTUREAID_REGISTER_PERK_CF, VERSION_SHIP, 1, "int" );
	clientfield::register( "scriptmover", VULTUREAID_KEYLINE_WAYPOINTS_CF, VERSION_SHIP, 1, "int" );
	clientfield::register( "scriptmover", VULTUREAID_REGISTER_POWERUP_CF, VERSION_SHIP, getMinBitCountForNum( 4 ), "int" );
	clientfield::register( "scriptmover", VULTUREAID_REGISTER_STINK_CF, VERSION_SHIP, 1, "int" );
	clientfield::register( "zbarrier", VULTUREAID_REGISTER_BOX_CF, VERSION_SHIP, 2, "int" );
	clientfield::register( "zbarrier", VULTUREAID_REGISTER_FIZZ_CF, VERSION_SHIP, 2, "int" );
	clientfield::register( "zbarrier", VULTUREAID_REGISTER_PAP_CF, VERSION_SHIP, 2, "int" );
	clientfield::register( "zbarrier", VULTUREAID_REGISTER_BGB_CF, VERSION_SHIP, 1, "int" );
	clientfield::register( "toplayer", VULTUREAID_PERK_UPDATE_CF, VERSION_SHIP, 1, "counter" );
	clientfield::register( "toplayer", VULTUREAID_STINK_CF, VERSION_SHIP, 1, "int" );
	clientfield::register( "toplayer", VULTUREAID_PERK_TOPLAYER_CF, VERSION_SHIP, 1, "int" );
}

function vulture_aid_set_clientfield( n_state ) 
{
	if ( n_state != 0 && ( level zm_perk_utility::is_perk_paused( VULTUREAID_PERK ) || self zm_perk_utility::is_perk_paused( VULTUREAID_PERK ) ) )
		n_state = 2;
	
	if ( n_state != 1 )
		self clientfield::set_player_uimodel( VULTUREAID_DISEASE_METER_CF, 0 );
	
	self clientfield::set_player_uimodel( VULTUREAID_CLIENTFIELD, n_state );	
}

function vulture_aid_perk_machine_setup( e_use_trigger, e_perk_machine, e_bump_trigger, e_collision )
{
	e_use_trigger.script_sound = VULTUREAID_JINGLE;
	e_use_trigger.script_string = VULTUREAID_SCRIPT_STRING;
	e_use_trigger.script_label = VULTUREAID_STING;
	e_use_trigger.target = VULTUREAID_RADIANT_MACHINE_NAME;
	e_perk_machine.script_string = VULTUREAID_SCRIPT_STRING;
	e_perk_machine.targetname = VULTUREAID_RADIANT_MACHINE_NAME;
	if ( isDefined( e_bump_trigger ) )
		e_bump_trigger.script_string = VULTUREAID_SCRIPT_STRING;
	
	e_perk_machine thread zm_perk_utility::register_vulture_perk_safe();
}

function vulture_aid_give_perk()
{
	zm_perk_utility::print_version( VULTUREAID_PERK, VULTUREAID_VERSION );
	
	if ( level zm_perk_utility::is_perk_paused( VULTUREAID_PERK ) )
		self zm_perk_utility::player_pause_perk( VULTUREAID_PERK );
	
	if ( self zm_perk_utility::is_perk_paused( VULTUREAID_PERK ) )
		return;
	
	self vulture_aid_enabled( 1 );
}

function vulture_aid_take_perk( b_pause, str_perk, str_result )
{
	self vulture_aid_enabled( 0 );
}

function vulture_aid_power_override()
{
	zm_perk_utility::force_power( VULTUREAID_PERK );
}

//-----------------------------------------------------------------------------------
// FUNCTIONALITY
//-----------------------------------------------------------------------------------
function vulture_aid_main()
{	
	level.powerup_fx_func = &vulture_aid_powerup_wobble_fx;
	
	callback::on_connect( &vulture_aid_register_stat );
	callback::on_spawned( &vulture_aid_mist_watcher );
	callback::on_spawned( &vulture_aid_watch_for_perk );
	
	zm_spawner::add_custom_zombie_spawn_logic( &vulture_aid_zombie_function );
	
	thread vulture_aid_waypoint_fx_setup();
	
	if ( IS_TRUE( VULTUREAID_IN_WONDERFIZZ ) )
		zm_perk_utility::add_perk_to_wunderfizz( VULTUREAID_PERK );	
	
	level thread revive_hide_logic();
}

function revive_hide_logic()
{
	level endon( "game_over" );
	while ( 1 )
	{
		level util::waittill_any( "revive_off", "revive_hide" );
		vulture_aid_update_all_players();
	}
}

function vulture_aid_update_all_players()
{
	for ( i = 0; i < level.players.size; i++ )
	{
		level.players[ i ] activate_vulture();
		level.players[ i ] clientfield::increment_to_player( VULTUREAID_PERK_UPDATE_CF, 1 );
	}
}

function vulture_aid_watch_for_perk()
{
	self endon( "death_or_disconnect" );
	self notify( "vulture_aid_watch_for_perk" );
	self endon( "vulture_aid_watch_for_perk" );
	
	while ( 1 )
	{
		str_notify = self util::waittill_any_return( "perk_acquired", "perk_lost", "player_spawned" );
		self clientfield::increment_to_player( VULTUREAID_PERK_UPDATE_CF, 1 );
		self activate_vulture();
	}
}

function get_craftable_unbuilt_parts()
{
	a_parts = [];
	foreach ( uts_craftable in level.a_uts_craftables )
		foreach ( pieceSpawn in uts_craftable.craftableSpawn.a_pieceSpawns )
			a_parts[ a_parts.size ] = pieceSpawn;
		
	
	return a_parts;
}

function vulture_aid_waypoint_fx_setup()
{
	level endon( "end_game" );
	zm_perk_utility::delay_if_all_players_connected_pending();
	
	if ( isDefined( level.chests ) && level.chests.size > 0 )
	{
		for ( i = 0; i < level.chests.size; i++ )
		{
			n_active = int( !IS_TRUE( level.chests[ i ].hidden ) ) + 1;
			level.chests[ i ].zbarrier clientfield::set( VULTUREAID_REGISTER_BOX_CF, n_active );		
			level.chests[ i ].box_hacks[ "summon_box" ] = &vulture_aid_mystery_box_callback;
		}
	}
	a_perk_random_machines = getEntArray( "perk_random_machine", "targetname" );
	if ( isDefined( a_perk_random_machines ) && a_perk_random_machines.size > 0 )
	{
		for ( i = 0; i < a_perk_random_machines.size; i++ )
		{
			n_active = int( IS_TRUE( a_perk_random_machines[ i ].current_perk_random_machine ) ) + 1;
			a_perk_random_machines[ i ] clientfield::set( VULTUREAID_REGISTER_FIZZ_CF, n_active );
			a_perk_random_machines[ i ] thread vulture_aid_wonderfizz_logic();
		}
	}
	a_bgb_machines = getEntArray( "bgb_machine_use", "targetname" );
	if ( isDefined( a_bgb_machines ) && a_bgb_machines.size > 0 )
	{
		for ( i = 0; i < a_bgb_machines.size; i++ )
			a_bgb_machines[ i ] clientfield::set( VULTUREAID_REGISTER_BGB_CF, 1 );
	
	}	
	while ( !isDefined( getEntArray( "vending_packapunch", "targetname" ) ) || getEntArray( "vending_packapunch", "targetname" ).size < 1 )
		wait .05;
	
	a_pap_machines = getEntArray( "vending_packapunch", "targetname" );
	
	if ( isDefined( a_pap_machines ) && a_pap_machines.size > 0 )
	{
		for ( i = 0; i < a_pap_machines.size; i++ )
		{
			n_active = int( IS_TRUE( a_pap_machines[ i ].state != "hidden" ) ) + 1;
			a_pap_machines[ i ] clientfield::set( VULTUREAID_REGISTER_PAP_CF, n_active );
			a_pap_machines[ i ] thread vulture_aid_packapunch_logic();
		}
	}	
}

function vulture_aid_mystery_box_callback( b_inactive )
{
	if ( b_inactive )
		self.zbarrier clientfield::set( VULTUREAID_REGISTER_BOX_CF, 1 );
	else
		self.zbarrier clientfield::set( VULTUREAID_REGISTER_BOX_CF, 2 );
	
	vulture_aid_update_all_players();
}

function vulture_aid_wonderfizz_logic()
{
	level endon( "game_over" );
	while ( isDefined( self ) )
	{
		self waittill( "zbarrier_state_change" );
		vulture_aid_update_all_players();
	}
}

function vulture_aid_packapunch_logic()
{
	level endon( "game_over" );
	while ( isDefined( self ) )
	{
		self waittill( "zbarrier_state_change" );
		vulture_aid_update_all_players();
	}
}

function vulture_aid_register_stat()
{
	globallogic_score::initPersStat( VULTUREAID_PERK + "_drank", false );	
}

function vulture_aid_enabled( enabled )
{
	if ( IS_TRUE( enabled ) )
	{
		self clientfield::set_to_player( VULTUREAID_PERK_TOPLAYER_CF, 1 );
		self.vulture_stink_value = 0;
		self.is_in_zombie_stink = 0;
		self activate_vulture();
	}
	else
	{
		if ( IS_TRUE( self.is_in_zombie_stink ) )
			self zm_utility::decrement_ignoreme();
		
		self.is_in_zombie_stink = 0;
		self clientfield::set_to_player( VULTUREAID_PERK_TOPLAYER_CF, 0 );
		self.vulture_stink_value = 0;
		self clientfield::set_player_uimodel( VULTUREAID_DISEASE_METER_CF, 0 );
		self setBlur( 0, 0 );
		self notify( "vulture_aid_stink_stink_over" );
		self notify( "stop_vulture_aid_logic" );
		self thread _handle_zombie_stink( 0 );
	}
}

function activate_vulture()
{	
	if ( IS_TRUE( VULTUREAID_USE_KEYLINE_ON_WAYPOINT_CRAFT_ITEMS ) )
	{
		a_buildable_parts = get_craftable_unbuilt_parts();
		if ( isDefined ( a_buildable_parts ) && a_buildable_parts.size > 0 )
		{
			for ( i = 0; i < a_buildable_parts.size; i++ )
			{
				if ( isDefined( a_buildable_parts[ i ].model ) )
				{
					if ( !self hasPerk( VULTUREAID_PERK ) )
						a_buildable_parts[ i ].model clientfield::set( VULTUREAID_KEYLINE_WAYPOINTS_CF, 0 );
					else
						a_buildable_parts[ i ].model clientfield::set( VULTUREAID_KEYLINE_WAYPOINTS_CF, 1 );
				}
			}
		}
	}
}

function vulture_aid_powerup_wobble_fx()
{
	if ( self.only_affects_grabber )
	{
		self clientfield::set( CLIENTFIELD_POWERUP_FX_NAME, CLIENTFIELD_POWERUP_FX_ONLY_AFFECTS_GRABBER_ON );
		self clientfield::set( VULTUREAID_REGISTER_POWERUP_CF, 2 );
	}
	else if ( self.any_team )
	{
		self clientfield::set( CLIENTFIELD_POWERUP_FX_NAME, CLIENTFIELD_POWERUP_FX_ANY_TEAM_ON );
		self clientfield::set( VULTUREAID_REGISTER_POWERUP_CF, 4 );
	}
	else if ( self.zombie_grabbable )
	{
		self clientfield::set( CLIENTFIELD_POWERUP_FX_NAME, CLIENTFIELD_POWERUP_FX_ZOMBIE_GRABBABLE_ON );
		self clientfield::set( VULTUREAID_REGISTER_POWERUP_CF, 3 );
	}
	else
	{
		self clientfield::set( CLIENTFIELD_POWERUP_FX_NAME, CLIENTFIELD_POWERUP_FX_ON );
		self clientfield::set( VULTUREAID_REGISTER_POWERUP_CF, 1 );
	}
}

function vulture_aid_zombie_function()
{		
	if ( randomInt( 100 ) > VULTUREAID_DROP_CHANCE )
		return;
	
	a_vulture_mists = vulture_aid_get_mists();
	if ( !isDefined( a_vulture_mists ) || a_vulture_mists.size < VULTUREAID_MAX_STINK_ZOMBIES )
		n_total_weight = VULTUREAID_AMMO_CHANCE + VULTUREAID_POINTS_CHANCE + VULTUREAID_STINK_CHANCE;
	else
		n_total_weight = VULTUREAID_AMMO_CHANCE + VULTUREAID_POINTS_CHANCE;
	
	n_cutoff_ammo = VULTUREAID_AMMO_CHANCE;
	n_cutoff_points = VULTUREAID_AMMO_CHANCE + VULTUREAID_POINTS_CHANCE;
	n_roll = randomint( n_total_weight );
	
	if ( n_roll < n_cutoff_ammo )
		self thread vulture_aid_zombie_drop( "ammo" );
	else if ( n_roll > n_cutoff_ammo && n_roll < n_cutoff_points )
		self thread vulture_aid_zombie_drop( "points" );
	else
		self thread vulture_zombie_mist_watcher();
	
}

function vulture_aid_get_drops( str_playername )
{
	return getEntArray( str_playername + "_vulture_drop", "targetname" );
}

function vulture_aid_zombie_drop( str_type )
{
	if ( self.archetype != "zombie" )
		return;
	
	self waittill( "death" );
	
	if ( isDefined( self.attacker ) && isPlayer( self.attacker ) && self.attacker hasPerk( VULTUREAID_PERK ) )
	{
		a_player_drops = vulture_aid_get_drops( self.attacker.playername );
		if ( isDefined( a_player_drops ) && a_player_drops.size > 0 && a_player_drops.size > VULTUREAID_MAX_DROPS )
			return;
		
		if( !zm_utility::check_point_in_playable_area( self.origin + ( 0, 0, 5 ) ) )
			return;
		
		e_drop_model = spawn( "script_model", self.origin + ( 0, 0, 5 ) );
		
		e_drop_model thread vulture_aid_drop_to_floor( 80, 5 );
		e_drop_model.targetname = self.attacker.playername + "_vulture_drop";
		
		a_players = getPlayers();
		for( i = 0; i < a_players.size; i++ )
			e_drop_model setInvisibleToPlayer( a_players[ i ] ); 
		
		e_drop_model setVisibleToPlayer( self.attacker );
		
		if ( isDefined( e_drop_model ) )
		{
			if ( IS_TRUE( VULTUREAID_USE_KEYLINE_ON_DROP_PACKETS ) )
				e_drop_model clientfield::set( VULTUREAID_KEYLINE_WAYPOINTS_CF, 1 );
			
			e_drop_model playSound( "zmb_perks_vulture_drop" );
			e_drop_model playloopSound( "zmb_perks_vulture_loop", 1 );
			switch ( str_type )
			{
				case "points":
				{
			 		e_drop_model setModel( VULTUREAID_POINTS_MODEL );
			 		e_drop_model thread vulture_aid_drop_watcher( self.attacker, &vulture_aid_points_collect );
			 		break;
				}
				case "ammo":
				{
			 		e_drop_model setModel( VULTUREAID_AMMO_MODEL );
					e_drop_model thread vulture_aid_drop_watcher( self.attacker, &vulture_aid_ammo_collect );
					break;
				}
			}
			
			e_drop_model thread vulture_aid_lose_watcher( self.attacker );
			e_drop_model thread vulture_aid_timeout();
			e_drop_model thread vulture_aid_dissapear_on_death( self.attacker );
			if ( isDefined( e_drop_model ) )
				playFxOnTag( VULTUREAID_DROPS_GLOW_FX, e_drop_model, "tag_origin" );
		
		}
	}
}

function vulture_aid_drop_watcher( e_owner, ptr_function_to_run )
{
	self endon( "timeout" );
	while ( isDefined( self ) )
	{
		if ( isDefined( e_owner.origin ) && isDefined( self.origin ) && distance( e_owner.origin, self.origin ) < 48 && isAlive( e_owner ) && !e_owner laststand::player_is_in_laststand() )
		{
			e_owner [[ ptr_function_to_run ]]();
			break;
		}
		WAIT_SERVER_FRAME;
	}
	if ( !isDefined( self ) )
		return;
	
	if ( IS_TRUE( VULTUREAID_USE_KEYLINE_ON_DROP_PACKETS ) )
		self clientfield::set( VULTUREAID_KEYLINE_WAYPOINTS_CF, 0 );
	
	self notify( "grabbed" );
	self delete();
}

function vulture_aid_ammo_collect()
{
	self playSoundToPlayer( "zmb_perks_vulture_pickup", self );
			
	w_current_weapon = self getCurrentWeapon();
				
	if ( IS_TRUE( w_current_weapon.isClipOnly ) )
	{
		n_current_ammo = self getWeaponAmmoClip( w_current_weapon );
		self giveMaxAmmo( w_current_weapon );

		n_clip_size = w_current_weapon.clipSize;
				
		n_fraction = int( n_clip_size / VULTUREAID_AMMO_PACKETS_FRACTION );
				
		n_new_ammo = n_current_ammo + n_fraction;
				
		if ( n_new_ammo > n_clip_size )
			n_new_ammo = n_clip_size;
				
		self setWeaponAmmoClip( w_current_weapon, n_new_ammo );
	}
	else
	{
		n_current_ammo = self getWeaponAmmoStock( w_current_weapon );
	
		n_weapon_max = w_current_weapon.maxAmmo;
		n_lh_weapon_max = 0;
		if ( w_current_weapon.dualWieldWeapon != level.weaponNone )
			n_lh_weapon_max = w_current_weapon.dualWieldWeapon.maxAmmo;
					
		n_weapon_max += n_lh_weapon_max;
				
		n_clip = w_current_weapon.clipSize;
		n_lh_clip = 0;
		if ( w_current_weapon.dualWieldWeapon != level.weaponNone )
			n_lh_clip = w_current_weapon.dualWieldWeapon.clipSize;
		
		n_clip = int( n_clip + n_lh_clip );
		
		n_clip_add = int( n_clip / VULTUREAID_AMMO_PACKETS_FRACTION );
		if ( n_clip_add < 1 )
			n_clip_add = 1;
				
		n_new_ammo = int( n_current_ammo + n_clip_add );
		if ( n_new_ammo > n_weapon_max )
			n_new_ammo = n_weapon_max;
				
		self setWeaponAmmoStock( w_current_weapon, n_new_ammo );
	}
}

function vulture_aid_points_collect()
{
	self playSoundToPlayer( "zmb_perks_vulture_pickup", self );
	self playSoundToPlayer( "zmb_perks_vulture_money", self );
			
	n_score = VULTUREAID_POINT_PACKETS_MIN;
	n_rand = randomInt( 2 );
	if ( n_rand == 1 )
		n_score = VULTUREAID_POINT_PACKETS_MAX;
						
	n_score = n_score * level.zombie_vars[ self.team ][ "zombie_point_scalar" ];
			
	self zm_score::add_to_player_score( n_score );			
}

function vulture_aid_lose_watcher( e_player )
{
	self endon ( "grabbed" );
	self endon( "delete" );
	e_player endon( "disconnect" );
	e_player waittill( "stop_vulture_aid_logic" );
	if ( IS_TRUE( VULTUREAID_USE_KEYLINE_ON_DROP_PACKETS ) )
		self clientfield::set( VULTUREAID_KEYLINE_WAYPOINTS_CF, 0 );
	
	self delete();
}

function vulture_aid_timeout()
{
	self endon ( "grabbed" );
	self endon ( "timeout" );
	
	wait VULTUREAID_DROP_TIMEOUT_DURATION;
	for ( i = 0; i < 40; i++ )
	{
		if ( !isDefined( self ) )
			return;
		
		if ( i % 2 )
			self hide();
		else
		{
			self show();
			playFxOnTag( VULTUREAID_DROPS_GLOW_FX, self, "tag_origin" );
		}

		if ( i < 15 )
			wait .5;
		else if ( i < 25 )
			wait .25;
		else
			wait .1;
		
	}
	self notify( "timeout" );
	if ( IS_TRUE( VULTUREAID_USE_KEYLINE_ON_DROP_PACKETS ) )
		self clientfield::set( VULTUREAID_KEYLINE_WAYPOINTS_CF, 0 );
	
	self delete();
}

function vulture_aid_dissapear_on_death( e_player )
{
	self endon( "timeout" );
	self endon( "grabbed" );
	e_player waittill( "death_or_disconnect" );
	if ( IS_TRUE( VULTUREAID_USE_KEYLINE_ON_DROP_PACKETS ) )
		self clientfield::set( VULTUREAID_KEYLINE_WAYPOINTS_CF, 0 );
	
	self delete();
}

function vulture_aid_zombie_create_mist( v_origin, n_delay = 0 )
{
	e_vulture_mist = spawn( "script_model", v_origin, 1, 1, 1 );
	e_vulture_mist.targetname = "vulture_mist";
	e_vulture_mist setModel( "tag_origin" );
	if ( n_delay == 0 )
		e_vulture_mist clientfield::set( VULTUREAID_REGISTER_STINK_CF, 1 );
	else
		e_vulture_mist thread vulture_mist_fx_delayed( n_delay );
	
	return e_vulture_mist;
}

function vulture_mist_fx_delayed( n_delay )
{
	self notify( "vulture_mist_fx_delayed" );
	self endon( "vulture_mist_fx_delayed" );
	self endon( "death" );
	wait n_delay;
	self clientfield::set( VULTUREAID_REGISTER_STINK_CF, 1 );
}

function vulture_zombie_mist_watcher()
{
	e_vulture_mist = vulture_aid_zombie_create_mist( self getTagOrigin( "j_spine4" ), 3 );
	e_vulture_mist linkTo( self, "j_spine4" );
	
	self waittill( "death" );
	
	v_origin = e_vulture_mist.origin;
	e_vulture_mist unlink();
	e_vulture_mist delete();
	
	if ( !zm_utility::check_point_in_playable_area( v_origin - ( 0, 0, 40 ) ) )
		return;
	
	e_vulture_mist = vulture_aid_zombie_create_mist( v_origin );
	e_vulture_mist thread vulture_aid_drop_to_floor( 5, 50 );
	wait VULTUREAID_MIST_TIME;
	e_vulture_mist delete();
}

function vulture_aid_drop_to_floor( v_start_offset, v_end_offset )
{
	v_trace = playerPhysicsTrace( self.origin + ( 0, 0, v_start_offset ), self.origin - ( 0, 0, 1000 ) );
		
	v_new_origin = v_trace + ( 0, 0, v_end_offset );
	
	self moveTo( v_new_origin, 1, .25, .25 );
}

function vulture_aid_get_mists()
{
	return getEntArray( "vulture_mist", "targetname" );
}

function vulture_aid_mist_watcher()
{
	self endon( "death" );
	self endon( "disconnect" );
	while( 1 )
	{
		b_player_in_zombie_stink = 0;
		if ( self hasPerk( VULTUREAID_PERK ) )
		{
			a_vulture_mists = vulture_aid_get_mists();
			if ( a_vulture_mists.size > 0 )
			{
				a_close_points = arraySort( a_vulture_mists, self.origin, 1, 300 );
				if ( a_close_points.size > 0 )
					b_player_in_zombie_stink = self _is_player_in_zombie_stink( a_close_points );
				
			}
			self _handle_zombie_stink( b_player_in_zombie_stink );
		}
		else
			self _handle_zombie_stink( b_player_in_zombie_stink );
		
		wait randomFloatRange( .25, .5 );
	}
}

function _is_player_in_zombie_stink( a_points )
{
	b_is_in_stink = 0;
	for ( i = 0; i < a_points.size; i++ )
	{
		if ( isDefined( a_points[ i ] getLinkedEnt() ) )
			continue;
		
		if ( distanceSquared( a_points[ i ].origin, self.origin ) < 4900 )
			b_is_in_stink = 1;
		
	}
	return b_is_in_stink;
}

function _handle_zombie_stink( b_player_inside_radius )
{
	if ( !isDefined( self.is_in_zombie_stink ) )
		self.is_in_zombie_stink = 0;
	
	b_in_stink_last_check = self.is_in_zombie_stink;
	self.is_in_zombie_stink = b_player_inside_radius;
	if ( IS_TRUE( self.is_in_zombie_stink ) )
	{
		n_current_time = getTime();
		if( !b_in_stink_last_check )
		{
			self.stink_time_entered = n_current_time;
			self toggle_stink_overlay( 1 );
		}
		b_should_ignore_player = isDefined( self.stink_time_entered ) && n_current_time - self.stink_time_entered * .001 >= 0;
		if ( b_should_ignore_player )
			self vulture_aid_toggle_mist_invisibility( 1 );
		
	}
	else if ( b_in_stink_last_check )
	{
		self.stink_time_exit = getTime();
		self thread _zombies_reacquire_player_after_leaving_stink();
	}
}

function vulture_aid_toggle_mist_invisibility( b_activate = 0 )
{
	if ( IS_TRUE( b_activate ) )
	{
		if ( !IS_TRUE( self.b_vulture_hidden ) )
		{
			self zm_utility::increment_ignoreme();
			self.b_vulture_hidden = 1;
		}
	}
	else
	{
		if ( IS_TRUE( self.b_vulture_hidden ) )
		{
			self zm_utility::decrement_ignoreme();
			self.b_vulture_hidden = undefined;
		}
	}
}

function _zombies_reacquire_player_after_leaving_stink()
{
	self endon( "death_or_disconnect" );
	self notify( "vulture_perk_stop_zombie_reacquire_player" );
	self endon( "vulture_perk_stop_zombie_reacquire_player" );
	self toggle_stink_overlay( 0 );
	while ( self.vulture_stink_value > 0 )
		wait .25;
	
	self vulture_aid_toggle_mist_invisibility( 0 );
}

function toggle_stink_overlay( b_show_overlay = 0 )
{
	if ( !isDefined( self.vulture_stink_value ) )
		self.vulture_stink_value = 0;
	if ( b_show_overlay )
		self thread _ramp_up_stink_overlay();
	else
		self thread _ramp_down_stink_overlay();
	
}

function _ramp_up_stink_overlay( b_instant_change = 0 )
{
	self notify( "vulture_perk_stink_ramp_up_done" );
	self endon( "vulture_perk_stink_ramp_up_done" );
	self endon( "death_or_disconnect" );
	self endon( "vulture_perk_lost" );
	self clientfield::set_to_player( VULTUREAID_STINK_CF, 1 );
	if ( !isDefined( level.stink_change_increment ) )
		level.stink_change_increment = pow( 2, 5 ) * .25 / 8;
	
	while ( IS_TRUE( self.is_in_zombie_stink ) )
	{
		self.vulture_stink_value = self.vulture_stink_value + level.stink_change_increment;
		if ( self.vulture_stink_value > pow( 2, 5 ) )
		
			self.vulture_stink_value = pow( 2, 5 );
			
		fraction = self _get_disease_meter_fraction();
		self clientfield::set_player_uimodel( VULTUREAID_DISEASE_METER_CF, fraction );
		self setBlur( fraction * VULTUREAID_SCREN_BLUR_AMOUNT, .25 );
		wait .25;
	}
}

function _get_disease_meter_fraction()
{
	return self.vulture_stink_value / pow( 2, 5 );
}

function _ramp_down_stink_overlay( b_instant_change = 0 )
{
	self notify( "vulture_perk_stink_ramp_down_done" );
	self endon( "vulture_perk_stink_ramp_down_done" );
	self endon( "death_or_disconnect");
	self endon( "vulture_perk_lost" );
	self clientfield::set_to_player( VULTUREAID_STINK_CF, 0 );
	if ( !isDefined( level.stink_change_decrement ) )
		level.stink_change_decrement = pow( 2, 5 ) * .25 / 4;
	
	while( !IS_TRUE( self.is_in_zombie_stink ) && self.vulture_stink_value > 0 )
	{
		self.vulture_stink_value = self.vulture_stink_value - level.stink_change_decrement;
		if ( self.vulture_stink_value < 0 )
			self.vulture_stink_value = 0;
		
		fraction = self _get_disease_meter_fraction();
		self clientfield::set_player_uimodel( VULTUREAID_DISEASE_METER_CF, fraction );
		self setBlur( fraction * VULTUREAID_SCREN_BLUR_AMOUNT, .25 );
		wait .25;
	}
}