#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\laststand_shared;
#using scripts\zm\gametypes\_globallogic_score;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_laststand;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_perk_utility;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_perk_tombstone.gsh;

#precache( "string", "HB21_ZM_PERKS_TOMBSTONE" );
#precache( "triggerstring", "ZOMBIE_BUTTON_TO_SUICIDE" );
#precache( "triggerstring", "HB21_ZM_PERKS_TOMBSTONE", TOMBSTONE_PERK_COST_STRING );
#precache( "model", TOMBSTONE_DROP_MODEL );
#precache( "fx", TOMBSTONE_MACHINE_LIGHT_FX );
#precache( "fx", TOMBSTONE_GRAVE_FX );

#namespace zm_perk_tombstone;

REGISTER_SYSTEM_EX( "zm_perk_tombstone", &__init__, &__main__, undefined )

// CALLBACKS AND OVERRIDES
// 
// NONE

//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------
function __init__()
{
	if ( IS_TRUE( TOMBSTONE_LEVEL_USE_PERK ) )
		enable_tombstone_perk_for_level();
	
}

function __main__()
{
	if ( IS_TRUE( TOMBSTONE_LEVEL_USE_PERK ) )
		tombstone_main();
	
}

function enable_tombstone_perk_for_level()
{	
	zm_perks::register_perk_basic_info( TOMBSTONE_PERK, TOMBSTONE_ALIAS, TOMBSTONE_PERK_COST, &"HB21_ZM_PERKS_TOMBSTONE", getWeapon( TOMBSTONE_PERK_BOTTLE_WEAPON ) );
	zm_perks::register_perk_precache_func( TOMBSTONE_PERK, &tombstone_precache );
	zm_perks::register_perk_clientfields( TOMBSTONE_PERK, &tombstone_register_clientfield, &tombstone_set_clientfield );
	zm_perks::register_perk_machine( TOMBSTONE_PERK, &tombstone_perk_machine_setup );
	zm_perks::register_perk_threads( TOMBSTONE_PERK, &tombstone_give_perk, &tombstone_take_perk );
	zm_perks::register_perk_host_migration_params( TOMBSTONE_PERK, TOMBSTONE_RADIANT_MACHINE_NAME, 	TOMBSTONE_PERK );
	if ( zm_perk_utility::is_stock_map() && ( level.script == "zm_zod" || level.script == "zm_genesis" || level.script == "zm_tomb" ) )
		zm_perks::register_perk_machine_power_override( TOMBSTONE_PERK, &tombstone_power_override );
				
	if ( level.script == "zm_zod" )
		zm_perk_utility::place_perk_machine( ( 848, -5631, 384 ), ( 0, 90, 0 ), TOMBSTONE_PERK, TOMBSTONE_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_factory" )
		zm_perk_utility::place_perk_machine( ( -584, 536, -6 ), ( 0, 90, 0 ), TOMBSTONE_PERK, TOMBSTONE_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_castle" )
		zm_perk_utility::place_perk_machine( ( 792, 2447, 640 ), ( 0, 180, 0 ), TOMBSTONE_PERK, TOMBSTONE_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_island" )
		zm_perk_utility::place_perk_machine( ( 490, 1840, -345 ), ( 0, 0, 0 ), TOMBSTONE_PERK, TOMBSTONE_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_stalingrad" )
		zm_perk_utility::place_perk_machine( ( -521, 5135, 304 ), ( 0, 180, 0 ), TOMBSTONE_PERK, TOMBSTONE_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_genesis" )
		zm_perk_utility::place_perk_machine( ( -92, -7161, -1311 ), ( 0, 180, 0 ), TOMBSTONE_PERK, TOMBSTONE_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_asylum" )
		zm_perk_utility::place_perk_machine( ( -287, -439, 226 ), ( 0, -90 + 90, 0 ), TOMBSTONE_PERK, TOMBSTONE_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_sumpf" )
		zm_perk_utility::place_perk_machine( ( 10811, 410, -660 ), ( 0, 90 + 90, 0 ), TOMBSTONE_PERK, TOMBSTONE_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_theater" )
		zm_perk_utility::place_perk_machine( ( -1343, 951, 0 ), ( 0, 180 + 90, 0 ), TOMBSTONE_PERK, TOMBSTONE_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_cosmodrome" )
		zm_perk_utility::place_perk_machine( ( -104, -794, -165 ), ( 0, 0 + 90, 0 ), TOMBSTONE_PERK, TOMBSTONE_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_temple" )
		zm_perk_utility::place_perk_machine( ( 860, -2000, -176 ), ( 0, 90 + 90, 0 ), TOMBSTONE_PERK, TOMBSTONE_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_moon" )
		zm_perk_utility::place_perk_machine( ( 1610, 844, -221 ), ( 0, -180 + 90, 0 ), TOMBSTONE_PERK, TOMBSTONE_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_tomb" )
		zm_perk_utility::place_perk_machine( ( -200, -882, 80 ), ( 0, 0 + 90, 0 ), TOMBSTONE_PERK, TOMBSTONE_MACHINE_DISABLED_MODEL );
	
}

function tombstone_precache()
{
	level._effect[ TOMBSTONE_PERK ] = TOMBSTONE_MACHINE_LIGHT_FX;
	
	level.machine_assets[ TOMBSTONE_PERK ] = spawnStruct();
	level.machine_assets[ TOMBSTONE_PERK ].weapon = getWeapon( TOMBSTONE_PERK_BOTTLE_WEAPON );
	level.machine_assets[ TOMBSTONE_PERK ].off_model = TOMBSTONE_MACHINE_DISABLED_MODEL;
	level.machine_assets[ TOMBSTONE_PERK ].on_model = TOMBSTONE_MACHINE_ACTIVE_MODEL;
}

function tombstone_register_clientfield() 
{
	clientfield::register( "clientuimodel", TOMBSTONE_CLIENTFIELD, VERSION_SHIP, 2, "int" );
}

function tombstone_set_clientfield( n_state ) 
{
	if ( n_state != 0 && ( level zm_perk_utility::is_perk_paused( TOMBSTONE_PERK ) || self zm_perk_utility::is_perk_paused( TOMBSTONE_PERK ) ) )
		n_state = 2;
	
	self clientfield::set_player_uimodel( TOMBSTONE_CLIENTFIELD, n_state );
}

function tombstone_perk_machine_setup( e_use_trigger, e_perk_machine, e_bump_trigger, e_collision )
{
	e_use_trigger.script_sound = TOMBSTONE_JINGLE;
	e_use_trigger.script_string = TOMBSTONE_SCRIPT_STRING;
	e_use_trigger.script_label = TOMBSTONE_STING;
	e_use_trigger.target = TOMBSTONE_RADIANT_MACHINE_NAME;
	e_perk_machine.script_string = TOMBSTONE_SCRIPT_STRING;
	e_perk_machine.targetname = TOMBSTONE_RADIANT_MACHINE_NAME;
	if ( isDefined( e_bump_trigger ) )
		e_bump_trigger.script_string = TOMBSTONE_SCRIPT_STRING;
	
	e_perk_machine thread zm_perk_utility::register_vulture_perk_safe();
}

function tombstone_give_perk() 
{
	zm_perk_utility::print_version( TOMBSTONE_PERK, TOMBSTONE_VERSION );
	
	if ( level zm_perk_utility::is_perk_paused( TOMBSTONE_PERK ) )
		self zm_perk_utility::player_pause_perk( TOMBSTONE_PERK );
	
	if ( self zm_perk_utility::is_perk_paused( TOMBSTONE_PERK ) )
		return;
	
	self notify( "tombstone_obtained" );
}

function tombstone_take_perk( b_pause, str_perk, str_result ) {}

function tombstone_power_override()
{
	zm_perk_utility::force_power( TOMBSTONE_PERK );
}

//-----------------------------------------------------------------------------------
// FUNCTIONALITY
//-----------------------------------------------------------------------------------
function tombstone_main()
{		
	if ( IS_TRUE( TOMBSTONE_USE_SOLO_VERSION ) )
		zm_perks::register_perk_damage_override_func( &tombstone_damage_override );
	else
	{
		callback::on_connect( &tombstone_player_connect );
		callback::on_disconnect( &tombstone_player_disconnect );
		level thread tombstone_solo_remove_check();
	}
	
	level.tombstone_active = 1;
	
	callback::on_connect( &tombstone_register_stat );
	callback::on_laststand( &tombstone_suicide_trigger_spawn );
	
	if ( IS_TRUE( TOMBSTONE_IN_WONDERFIZZ ) )
		zm_perk_utility::add_perk_to_wunderfizz( TOMBSTONE_PERK );
	
	level thread tombstone_hostmigration();
}

function tombstone_damage_override( e_inflictor, e_attacker, n_damage, str_flags, str_means_of_death, w_weapon, v_point, v_dir, str_hit_loc, f_offset_time )
{
	/*
	if ( self hasPerk( "specialty_phdflopper" ) )
	{
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
	}
	*/
	if ( isDefined( level.w_widows_wine_grenade ) && w_weapon == level.w_widows_wine_grenade )
		return 0;
	
	a_players = getPlayers();
	if ( IS_TRUE( TOMBSTONE_USE_SOLO_VERSION ) && a_players.size == 1 && n_damage >= self.health && self hasPerk( TOMBSTONE_PERK ) )
	{
		self.downs++;
		self.pers[ "downs" ]++;
		self zm_stats::increment_client_stat( "downs" );	
		self zm_stats::increment_player_stat( "downs" );
		self thread tombstone_spawn();
		self notify( "player_downed" );
		self thread tombstone_fake_revive();
		return 0;
	}	
	return n_damage;
}

function tombstone_fake_revive()
{
	level notify( "fake_revive" );
	self notify( "fake_revive" );
	
	self zm_perk_utility::remove_player_loadout();
	
	self zm_weapons::weapon_give( getWeapon( "t6_bare_hands_death" ), 0, 0, 1, 1 );
	
	self allowStand( 0 );
	self allowCrouch( 0 );
	self allowProne( 1 );
	self.ignoreme = 1;
	self enableInvulnerability();
	wait .1;
	self freezeControls( 1 );
	wait 1.9;
	
	self zm_weapons::weapon_take( getWeapon( "t6_bare_hands_death" ) );
	
	s_spawn_point = self zm_perk_utility::get_player_spawn_point( TOMBSTONE_RESPAWN_RANGE_MIN, TOMBSTONE_RESPAWN_RANGE_MAX, TOMBSTONE_RESPAWN_HALF_HEIGHT, TOMBSTONE_RESPAWN_INNER_SPACING, TOMBSTONE_RESPAWN_RADIUS_FROM_EDGES );

	if ( !isDefined( s_spawn_point ) )
		s_spawn_point = self zm_perk_utility::get_player_spawn_point( 100, TOMBSTONE_RESPAWN_RANGE_MAX, TOMBSTONE_RESPAWN_HALF_HEIGHT, TOMBSTONE_RESPAWN_INNER_SPACING, TOMBSTONE_RESPAWN_RADIUS_FROM_EDGES );
	
	if ( isDefined( s_spawn_point ) )
		self setOrigin( s_spawn_point.origin );
	
	// self setPlayerAngles( s_spawn_point.angles );
		
	self.health = self.maxhealth;
	self notify( "clear_red_flashing_overlay" );
	
	self allowStand( 1 );
	self allowCrouch( 1 );
	self allowProne( 1 );
	self.ignoreme = 0;
	self setStance( "stand" );
	self freezeControls( 0 );
	
	if ( isDefined( TOMBSTONE_SOLO_RESPAWN_WEAPON ) )
		self zm_weapons::weapon_give( getWeapon( TOMBSTONE_SOLO_RESPAWN_WEAPON ), 0, 0, 1, 1 );
	else
		self zm_weapons::weapon_give( level.start_weapon, 0, 0, 1, 1 );
	
	self giveWeapon( level.zombie_melee_weapon_player_init );
	self giveWeapon( level.zombie_lethal_grenade_player_init );
	self setWeaponAmmoClip( level.zombie_lethal_grenade_player_init, 2 );
	
	wait 1;
	self notify( "spawned_player" );
	self disableInvulnerability();
}

function tombstone_suicide_trigger_spawn()
{
	if ( !self hasPerk( TOMBSTONE_PERK ) && IS_TRUE( level.tombstone_active ) )
		return;
		
	self thread tombstone_spawn();
	
	self.suicidePrompt = newClientHudElem( self );
	self.suicidePrompt.alignX = "center";
	self.suicidePrompt.alignY = "middle";
	self.suicidePrompt.horzAlign = "center";
	self.suicidePrompt.vertAlign = "bottom";
	self.suicidePrompt.y = -170;
	
	if ( self isSplitScreen() )
		self.suicidePrompt.y = -132;
	
	self.suicidePrompt.foreground = true;
	self.suicidePrompt.font = "default";
	self.suicidePrompt.fontScale = 1.5;
	self.suicidePrompt.alpha = 1;
	self.suicidePrompt.color = ( 1, 1, 1 );
	self.suicidePrompt.hidewheninmenu = true;

	self thread tombstone_suicide_trigger_think();
}

function tombstone_suicide_trigger_think()
{
	self endon ( "disconnect" );
	self endon ( "zombified" );
	self endon ( "stop_revive_trigger" );
	self endon ( "player_revived" );
	self endon ( "bled_out" );
	self endon ( "fake_death" );
	level endon( "end_game" );
	level endon( "stop_suicide_trigger" );
	
	self thread laststand::clean_up_suicide_hud_on_end_game();
	self thread laststand::clean_up_suicide_hud_on_bled_out();
	
	while ( self useButtonPressed() )
		WAIT_SERVER_FRAME;
	
	if ( !isDefined( self.suicidePrompt ) )
		return;
	
	while ( 1 )
	{
		WAIT_SERVER_FRAME;
		
		if ( !isDefined( self.suicidePrompt ) )
			return;
					
		self.suicidePrompt setText( &"ZOMBIE_BUTTON_TO_SUICIDE" );
		
		if ( !self zm_laststand::is_suiciding() )
			continue;

		self.w_pre_suicide_weapon = self getCurrentWeapon();
		self zm_weapons::weapon_give( getWeapon( TOMBSTONE_SUICIDE_WEAPON ), 0, 0, 1, 1 );
		n_duration = TOMBSTONE_SUICIDE_TRGGER_USE_TIME;

		b_suicide_success = zm_laststand::suicide_do_suicide( n_duration );
		self.laststand = undefined;
		self takeWeapon( getWeapon( TOMBSTONE_SUICIDE_WEAPON ) );

		if ( IS_TRUE( b_suicide_success ) )
		{
			self notify( "player_suicide" );
			util::wait_network_frame();
			self zm_laststand::bleed_out();
			return;
		}
		
		self switchToWeapon( self.w_pre_suicide_weapon );
		self.w_pre_suicide_weapon = undefined;
	}
}

function tombstone_register_stat()
{
	globallogic_score::initPersStat( TOMBSTONE_PERK + "_drank", false );	
}

function tombstone_spawn()
{
	e_tombstone = spawn( "script_model", self.origin + vectorScale( ( 0, 0, 1 ), 20 ) );
	e_tombstone.angles = self.angles;
	e_tombstone setModel( TOMBSTONE_DROP_MODEL );
	e_tombstone.script_noteworthy = "player_tombstone_model";
	e_tombstone.player = self;
	
	e_tombstone thread tombstone_wobble();
	e_tombstone thread tombstone_watch_for_reviving( self );
	
	playSoundAtPosition( "zmb_tombstone_spawn", self.origin );
	e_tombstone playLoopSound( "zmb_tombstone_looper" );
	
	e_tombstone.s_loadout = self zm_perk_utility::get_player_loadout( array( TOMBSTONE_PERK ) );
	
	result = self util::waittill_any_return( "player_revived", "spawned_player", "disconnect" );
	if ( result == "player_revived" || result == "disconnect" )
	{
		e_tombstone notify( "tombstone_timedout" );
		e_tombstone delete();
		return;
	}
	e_tombstone thread tombstone_timeout();
	e_tombstone thread tombstone_grab();
	e_tombstone thread tombstone_obtained_or_disconnect( self );
}

function tombstone_watch_for_reviving( player )
{
	self endon( "tombstone_timedout" );
	player endon( "disconnect" );
	shown = 1;
	while ( isDefined( self ) && isDefined( player ) )
	{
		if ( isDefined( player.revivetrigger ) && isDefined( player.revivetrigger.beingrevived ) && player.revivetrigger.beingrevived )
		{
			if ( IS_TRUE( shown ) )
			{
				shown = 0;
				self hide();
			}
		}
		else
		{
			if ( !IS_TRUE( shown ) )
			{
				shown = 1;
				self show();
			}
		}
		WAIT_SERVER_FRAME;
	}
}

function tombstone_grab()
{
	self endon( "tombstone_timedout" );
	self endon( "tombstone_grabbed" );
	wait 1;
	while ( isDefined( self ) )
	{
		players = getPlayers();
		for ( i = 0; i < players.size; i++ )
		{
			if ( IS_TRUE( players[ i ].is_zombie ) || players[ i ] laststand::player_is_in_laststand() || "playing" != players[ i ].sessionstate  )
				continue;
			
			if ( isDefined( self.player ) && players[ i ] == self.player )
			{
				dist = distance( players[ i ].origin, self.origin );
				if ( dist < 64 )
				{
					playFx( level._effect[ "powerup_grabbed" ], self.origin );
					players[ i ] zm_perk_utility::give_player_loadout( self.s_loadout, 1, 0, 0, array( TOMBSTONE_PERK ) );
					playSoundAtPosition( "zmb_tombstone_grab", self.origin );
					self stopLoopSound();
					self delete();
					players[ i ] notify( "dance_on_my_grave" );
					self notify( "tombstone_grabbed" );
				}
			}
		}
		WAIT_SERVER_FRAME;
	}
}

function play_tombstone_timer_audio()
{
	self endon( "tombstone_grabbed" );
	self endon( "tombstone_timedout" );
	player = self.player;
	self thread play_tombstone_timer_out( player );
	while ( 1 )
	{
		player playSoundToPlayer( "zmb_tombstone_timer_count", player );
		wait 1;
	}
}

function play_tombstone_timer_out( player )
{
	self endon( "tombstone_grabbed" );
	self waittill( "tombstone_timedout" );
	player playSoundToPlayer( "zmb_tombstone_timer_out", player );
}

function tombstone_wobble()
{
	self endon( "tombstone_grabbed" );
	self endon( "tombstone_timedout" );
	if ( isDefined( self ) )
	{
		playFxOnTag( TOMBSTONE_GRAVE_FX, self, "tag_origin" );
		playSoundAtPosition( "zmb_spawn_powerup", self.origin );
		self playLoopSound( "zmb_spawn_powerup_loop" );
	}
	while ( isDefined( self ) )
	{
		self rotateYaw( 360, 3 );
		wait 2.9;
	}
}

function tombstone_timeout()
{
	self endon( "tombstone_grabbed" );
	if ( !IS_TRUE( TOMBSTONE_USE_TIMEOUT ) )
		return;
	
	if ( IS_TRUE( TOMBSTONE_USE_AUDIO_BEEPS ) )
		self thread play_tombstone_timer_audio();
	
	wait TOMBSTONE_TIMEOUT - 1.5;
	i = 0;
	while ( i < 40 )
	{
		if ( i % 2 )
			self ghost();
		else
			self show();
		
		if ( i < 15 )
		{
			wait .5;
			i++;
			continue;
		}
		else if ( i < 25 )
		{
			wait .25;
			i++;
			continue;
		}
		else
			wait .1;
		
		i++;
	}
	self notify( "tombstone_timedout" );
	self stopLoopSound();
	self delete();
}

function tombstone_obtained_or_disconnect( e_player )
{
	self endon( "tombstone_grabbed" );
	e_player util::waittill_any( "tombstone_obtained", "disconnect" );
	self notify( "tombstone_timedout" );
	self stopLoopSound();
	self delete();
}

function disable_tombstone_perk_for_level()
{
	zm_perk_utility::global_pause_perk( TOMBSTONE_PERK );
	
	machines = getEntArray( "zombie_vending", "targetname" );
	if ( isDefined( machines ) && machines.size > 0 )
	{
		for ( i = 0; i < machines.size; i++ )
		{
			if ( machines[ i ].script_noteworthy == TOMBSTONE_PERK )
			{
				machines[ i ].bump triggerEnable( 0 );
				machines[ i ] triggerEnable( 0 );
				machines[ i ].machine hide();
				machines[ i ] zm_perks::perk_fx( undefined, 1 );
				playFX( level._effect[ "poltergeist" ], machines[ i ].origin );
				playSoundAtPosition( "zmb_box_poof", machines[ i ].origin );
			}
		}
	}
	level notify( "stop_suicide_trigger" );
}

function reenable_tombstone_perk_for_level()
{
	zm_perk_utility::global_unpause_perk( TOMBSTONE_PERK );
	
	machines = getEntArray( "zombie_vending", "targetname" );
	if ( isDefined( machines ) && machines.size > 0 )
	{
		for ( i = 0; i < machines.size; i++ )
		{
			if ( machines[ i ].script_noteworthy == TOMBSTONE_PERK )
			{
				machines[ i ].bump triggerEnable( 1 );
				machines[ i ] triggerEnable( 1 );
				machines[ i ].machine show();
				machines[ i ] zm_perks::perk_fx( undefined, 1 );
				playFX( level._effect[ "poltergeist" ], machines[ i ].origin );
				playSoundAtPosition( "zmb_box_poof", machines[ i ].origin );
			}
		}
	}
}

function tombstone_hostmigration()
{
	level endon( "end_game" );
	level notify( "tombstone_hostmigration" );
	level endon( "tombstone_hostmigration" );
	while ( 1 )
	{
		level waittill( "host_migration_end" );
		tombstones = getEntArray( "player_tombstone_model", "script_noteworthy" );
		_a564 = tombstones;
		_k564 = getFirstArrayKey( _a564 );
		while ( isDefined( _k564 ) )
		{
			model = _a564[ _k564 ];
			playFxOnTag( TOMBSTONE_GRAVE_FX, model, "tag_origin" );
			_k564 = getNextArrayKey( _a564, _k564 );
		}
	}
}

function tombstone_player_disconnect()
{
	players = getPlayers();
	
	if ( players.size > 1 && isDefined( level.tombstone_active ) && level.tombstone_active )
		return;
	
	disable_tombstone_perk_for_level();
}

function tombstone_player_connect()
{
	players = getPlayers();
	
	if ( players.size > 1 && IS_TRUE( level.tombstone_active ) )
		return;
	
	reenable_tombstone_perk_for_level();
}

function tombstone_solo_remove_check()
{
	zm_perk_utility::delay_if_blackscreen_pending();
	
	players = getPlayers();
	if ( players.size < 2 )
		disable_tombstone_perk_for_level();
	
}
