#using scripts\codescripts\struct;
#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\system_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\zm\gametypes\_globallogic_score;
#using scripts\zm\_zm_clone;
#using scripts\zm\_zm_laststand;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_perk_utility;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_perk_whoswho.gsh;
#insert scripts\zm\_zm_perk_utility.gsh;

#precache( "string", "HB21_ZM_PERKS_WHOSWHO" );
#precache( "triggerstring", "HB21_ZM_PERKS_WHOSWHO", WHOSWHO_PERK_COST_STRING );
#precache( "fx", WHOSWHO_MACHINE_LIGHT_FX );
#precache( "fx", WHOSWHO_BLEDOUT_FX );
#precache( "fx", WHOSWHO_REVIVED_FX );

#using_animtree( "all_player" );

#namespace zm_perk_whoswho;

REGISTER_SYSTEM_EX( "zm_perk_whoswho", &__init__, &__main__, undefined )

// CALLBACKS AND OVERRIDES
// 
// NONE

//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------
function __init__()
{
	if ( IS_TRUE( WHOSWHO_LEVEL_USE_PERK ) )
		enable_whoswho_perk_for_level();
		
}

function __main__()
{
	if ( IS_TRUE( WHOSWHO_LEVEL_USE_PERK ) )
		whoswho_main();
		
}

function enable_whoswho_perk_for_level()
{	
	zm_perks::register_perk_basic_info( WHOSWHO_PERK, WHOSWHO_ALIAS, WHOSWHO_PERK_COST, &"HB21_ZM_PERKS_WHOSWHO", getWeapon( WHOSWHO_PERK_BOTTLE_WEAPON ) );
	zm_perks::register_perk_precache_func( WHOSWHO_PERK, &whoswho_precache );
	zm_perks::register_perk_clientfields( WHOSWHO_PERK, &whoswho_register_clientfield, &whoswho_set_clientfield );
	zm_perks::register_perk_machine( WHOSWHO_PERK, &whoswho_perk_machine_setup );
	zm_perks::register_perk_threads( WHOSWHO_PERK, &whoswho_give_perk, &whoswho_take_perk  );
	zm_perks::register_perk_host_migration_params( WHOSWHO_PERK, WHOSWHO_RADIANT_MACHINE_NAME, WHOSWHO_PERK );
	if ( zm_perk_utility::is_stock_map() && ( level.script == "zm_zod" || level.script == "zm_genesis" || level.script == "zm_tomb" ) )
		zm_perks::register_perk_machine_power_override( WHOSWHO_PERK, &whoswho_power_override );
		
	if ( level.script == "zm_zod" )
		zm_perk_utility::place_perk_machine( ( 1087, -3784, 258 ), ( 0, 90, 0 ), WHOSWHO_PERK, WHOSWHO_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_factory" )
		zm_perk_utility::place_perk_machine( ( 632, 144, 64 ), ( 0, 90, 0 ), WHOSWHO_PERK, WHOSWHO_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_castle" )
		zm_perk_utility::place_perk_machine( ( 895, 2484, 441 ), ( 0, 0 + 90, 0 ), WHOSWHO_PERK, WHOSWHO_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_island" )
		zm_perk_utility::place_perk_machine( ( 831, -985, -453 ), ( 0, 0, 0 ), WHOSWHO_PERK, WHOSWHO_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_stalingrad" )
		zm_perk_utility::place_perk_machine( ( 1721, 3395, -117 ), ( 0, 0, 0 ), WHOSWHO_PERK, WHOSWHO_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_genesis" )
		zm_perk_utility::place_perk_machine( ( 50, -9144, -1479 ), ( 0, 230, 0 ), WHOSWHO_PERK, WHOSWHO_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_asylum" )
		zm_perk_utility::place_perk_machine( ( -608, 416, 226 ), ( 0, 0 + 90, 0 ), WHOSWHO_PERK, WHOSWHO_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_sumpf" )
		zm_perk_utility::place_perk_machine( ( 10811, 410, -660 ), ( 0, -90 + 90, 0 ), WHOSWHO_PERK, WHOSWHO_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_theater" )
		zm_perk_utility::place_perk_machine( ( -1165, 1147, 168 ), ( 0, 90 + 90, 0 ), WHOSWHO_PERK, WHOSWHO_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_cosmodrome" )
		zm_perk_utility::place_perk_machine( ( 510, -1332, -57 ), ( 0, -90 + 90, 0 ), WHOSWHO_PERK, WHOSWHO_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_temple" )
		zm_perk_utility::place_perk_machine( ( 1426, -1264, -358 ), ( 0, 0 + 90, 0 ), WHOSWHO_PERK, WHOSWHO_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_moon" )
		zm_perk_utility::place_perk_machine( ( 1360, 2542, -388 ), ( 0, 90 + 90, 0 ), WHOSWHO_PERK, WHOSWHO_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_tomb" )
		zm_perk_utility::place_perk_machine( ( -165, -2478, 48 ), ( 0, 80 + 90, 0 ), WHOSWHO_PERK, WHOSWHO_MACHINE_DISABLED_MODEL );
	
}

function whoswho_precache()
{
	level._effect[ WHOSWHO_PERK ]	= WHOSWHO_MACHINE_LIGHT_FX;
	
	level.machine_assets[ WHOSWHO_PERK ] = spawnStruct();
	level.machine_assets[ WHOSWHO_PERK ].weapon = getWeapon( WHOSWHO_PERK_BOTTLE_WEAPON );
	level.machine_assets[ WHOSWHO_PERK ].off_model = WHOSWHO_MACHINE_DISABLED_MODEL;
	level.machine_assets[ WHOSWHO_PERK ].on_model = WHOSWHO_MACHINE_ACTIVE_MODEL;
}

function whoswho_register_clientfield()
{
	clientfield::register( "clientuimodel", WHOSWHO_CLIENTFIELD, VERSION_SHIP, 2, "int" );
	clientfield::register( "scriptmover", "whoswho_register_body", VERSION_SHIP, getMinBitCountForNum( 4 ), "int" );
	clientfield::register( "toplayer", WHOSWHO_SCRIPT_STRING, VERSION_SHIP, 1, "int" );
}

function whoswho_set_clientfield( n_state ) 
{
	if ( n_state != 0 && ( level zm_perk_utility::is_perk_paused( WHOSWHO_PERK ) || self zm_perk_utility::is_perk_paused( WHOSWHO_PERK ) ) )
		n_state = 2;
	
	self clientfield::set_player_uimodel( WHOSWHO_CLIENTFIELD, n_state );
}

function whoswho_perk_machine_setup( e_use_trigger, e_perk_machine, e_bump_trigger, e_collision )
{
	e_use_trigger.script_sound = WHOSWHO_JINGLE;
	e_use_trigger.script_string = WHOSWHO_SCRIPT_STRING;
	e_use_trigger.script_label = WHOSWHO_STING;
	e_use_trigger.target = WHOSWHO_RADIANT_MACHINE_NAME;
	e_perk_machine.script_string = WHOSWHO_SCRIPT_STRING;
	e_perk_machine.targetname = WHOSWHO_RADIANT_MACHINE_NAME;
	if ( isDefined( e_bump_trigger ) )
		e_bump_trigger.script_string = WHOSWHO_SCRIPT_STRING;
	
	e_perk_machine thread zm_perk_utility::register_vulture_perk_safe();
}

function whoswho_give_perk()
{
	zm_perk_utility::print_version( WHOSWHO_PERK, WHOSWHO_VERSION );
	
	if ( level zm_perk_utility::is_perk_paused( WHOSWHO_PERK ) )
		self zm_perk_utility::player_pause_perk( WHOSWHO_PERK );
	
	if ( self zm_perk_utility::is_perk_paused( WHOSWHO_PERK ) )
		return;
	
	self whoswho_enabled( 1 );
}

function whoswho_take_perk( b_pause, str_perk, str_result ) {}

function whoswho_power_override()
{
	zm_perk_utility::force_power( WHOSWHO_PERK );
}

//-----------------------------------------------------------------------------------
// FUNCTIONALITY
//-----------------------------------------------------------------------------------
function whoswho_main()
{	
	callback::on_connect( &whoswho_register_stat );
	
	level.whoswho_laststand_func = &whoswho_laststand;
	
	level.whos_who_client_setup = 1;
	level.chugabud_shellshock = "whoswho";
	
	level.whos_who_vision = WHOSWHO_VISION;
	if ( IS_TRUE( WHOSWHO_USE_ALTERNATE_VISIONSET ) )
		level.whos_who_vision =  WHOSWHO_VISION_ALTERNATE;
	
	visionset_mgr::register_info( "visionset", level.whos_who_vision, VERSION_SHIP, WHOSWHO_VISIONSET_PRIORITY, WHOSWHO_VISIONSET_LERP_COUNT, 1, &visionset_mgr::ramp_in_out_thread_per_player, 1 );
	
	if ( IS_TRUE( WHOSWHO_IN_WONDERFIZZ ) )
		zm_perk_utility::add_perk_to_wunderfizz( WHOSWHO_PERK );	
	
}

function whoswho_register_stat()
{
	globallogic_score::initPersStat( WHOSWHO_PERK + "_drank", false );	
}

function whoswho_enabled( enabled )
{
	if ( IS_TRUE( enabled ) )
	{
		if ( !isDefined( self.lives ) || self.lives < 1 )
			self.lives = 1;
	
		self notify( "chugabud_effects_cleanup" );
	}
}

function whoswho_laststand()
{
	self endon( "player_suicide" );
	self endon( "disconnect" );
	self endon( "chugabud_bleedout" );
	zm_laststand::increment_downed_stat();
	self.ignore_insta_kill = 1;
	self.health = 1;
	self whoswho_save_loadout();
	self whoswho_fake_death();
	wait 3;
	if ( IS_TRUE( self.insta_killed ) || IS_TRUE( self.disable_chugabud_corpse ) )
		create_corpse = 0;
	else
		create_corpse = 1;
	
	if ( create_corpse == 1 )
	{
		if ( isDefined( level._chugabug_reject_corpse_override_func ) )
		{
			reject_corpse = self [[ level._chugabug_reject_corpse_override_func ]]( self.origin );
			if ( reject_corpse )
				create_corpse = 0;
			
		}
	}
	if ( create_corpse == 1 )
	{
		self thread whoswho_activate_effects_and_audio();
		corpse = self whoswho_spawn_corpse();
		self.e_chugabud_corpse = corpse;
		corpse thread whoswho_corpse_cleanup_on_spectator( self );
	}
	
	self whoswho_fake_revive();
	wait .1;
	self.ignore_insta_kill = undefined;
	self.disable_chugabud_corpse = undefined;
	if ( create_corpse == 0 )
	{
		self notify( "chugabud_effects_cleanup" );
		return;
	}
	bleedout_time = getDvarFloat( "player_lastStandBleedoutTime" );
	self thread whoswho_bleed_timeout( bleedout_time, corpse );
	self thread whoswho_handle_multiple_instances( corpse );
	
	corpse waittill( "player_revived", e_reviver );	
	
	if ( isDefined( e_reviver ) && e_reviver == self )
		self notify( "whos_who_self_revive" );
	
	self zm_perks::perk_abort_drinking( .1 );
	self zm_perks::perk_set_max_health_if_jugg( "health_reboot", 1, 0 );
	self setorigin( corpse.origin );
	self setplayerangles( corpse.angles );
	if ( self laststand::player_is_in_laststand() )
	{
		self thread whoswho_laststand_cleanup( corpse, "player_revived" );
		self zm_laststand::auto_revive( self, 1 );
		return;
	}
	self whoswho_laststand_cleanup( corpse, undefined );
}

function whoswho_distort_vision_for_player()
{
	self endon( "disconnect" );
	
	if ( !IS_TRUE( WHOSWHO_USE_VISIONSET ) )
		return;
	
	if ( IS_TRUE( self.whoswho_vision_on ) )
		return;
	
	self.whoswho_vision_on = 1;
	
	visionset_mgr::activate( "visionset", 	level.whos_who_vision,	self, WHOSWHO_ENTER_DURATION, &whoswho_distort_vision_loop, WHOSWHO_EXIT_DURATION );
	
	self waittill( "chugabud_effects_cleanup" );
	
	wait WHOSWHO_EXIT_DURATION;
	self.whoswho_vision_on = undefined;
}

function whoswho_distort_vision_loop()
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "chugabud_effects_cleanup" );
	while ( IS_TRUE( self.whoswho_vision_on ) )
		WAIT_SERVER_FRAME;
	
}

function whoswho_activate_effects_and_audio()
{
	if ( isDefined( level.whos_who_client_setup ) )
	{
		if ( !IS_TRUE( self.whos_who_effects_active ) )
		{
			if ( isDefined( level.chugabud_shellshock ) )
				self shellshock( level.chugabud_shellshock, 60 );

			self clientfield::set_to_player( WHOSWHO_SCRIPT_STRING, 1 );
			self.whos_who_effects_active = 1;
			self thread whoswho_deactivate_effects_and_audio();
		}
	}
}

function whoswho_deactivate_effects_and_audio()
{
	self endon( "disconnect" );
	self util::waittill_any( "death", "chugabud_effects_cleanup" );
	if ( isDefined( level.whos_who_client_setup ) )
	{
		if ( IS_TRUE( self.whos_who_effects_active ) )
		{
			if ( isDefined( level.chugabud_shellshock ) )
				self stopshellshock();

			self clientfield::set_to_player( WHOSWHO_SCRIPT_STRING, 0 );
		}
		self.whos_who_effects_active = undefined;
	}
}

function whoswho_corpse_cleanup_on_spectator( player )
{
	self endon( "death" );
	player endon( "disconnect" );
	while ( 1 )
	{
		if ( player.sessionstate == "spectator" )
			break;
		else
			WAIT_SERVER_FRAME;
		
	}
	player whoswho_corpse_cleanup( self, 0 );
}

function whoswho_fake_death()
{
	level notify( "fake_death" );
	self notify( "fake_death" );
	
	self zm_perk_utility::remove_player_loadout();
	
	self zm_weapons::weapon_give( getWeapon( WHOSWHO_DEATH_HANDS_WEAPON ), 0, 0, 1, 1 );
	
	self allowStand( 0 );
	self allowCrouch( 0 );
	self allowProne( 1 );
	self.ignoreme = 1;
	self enableInvulnerability();
	wait .1;
	self freezeControls( 1 );
	wait .9;
}

function whoswho_fake_revive()
{
	level notify( "fake_revive" );
	self notify( "fake_revive" );
	playSoundAtPosition( "zmb_perks_whoswho_disappear", self.origin );
	playFx( WHOSWHO_REVIVED_FX, self.origin );
	
	self thread whoswho_distort_vision_for_player();
	
	self takeAllWeapons();
	
	spawn_point = self zm_perk_utility::get_player_spawn_point( WHOSWHO_RESPAWN_RANGE_MIN, WHOSWHO_RESPAWN_RANGE_MAX, WHOSWHO_RESPAWN_HALF_HEIGHT, WHOSWHO_RESPAWN_INNER_SPACING, WHOSWHO_RESPAWN_RADIUS_FROM_EDGES );
	
	if ( !isDefined( spawn_point ) )
		spawn_point = self zm_perk_utility::get_player_spawn_point( 100, WHOSWHO_RESPAWN_RANGE_MAX, WHOSWHO_RESPAWN_HALF_HEIGHT, WHOSWHO_RESPAWN_INNER_SPACING, WHOSWHO_RESPAWN_RADIUS_FROM_EDGES );
	
	if ( isDefined( spawn_point ) )
		self setOrigin( spawn_point.origin );
	
	self setVelocity( ( anglesToForward( self.angles ) * WHOSWHO_RESPAWN_FORWARD_VELOCITY ) + ( anglesToUp( self.angles ) * WHOSWHO_RESPAWN_UPWARD_VELOCITY ) );
	
	playSoundAtPosition( "zmb_perks_whoswho_appear", spawn_point.origin );
	playFx( WHOSWHO_REVIVED_FX, spawn_point.origin );
	
	self.health = self.maxhealth;
	self notify( "clear_red_flashing_overlay" );
	
	self allowStand( 1 );
	self allowCrouch( 1 );
	self allowProne( 1 );
	self AllowSprint( 1 );
	self.ignoreme = 0;
	self setStance( "stand" );
	self freezeControls( 0 );
	
	self giveWeapon( level.zombie_melee_weapon_player_init );
	self whoswho_give_respawn_weapon( 1 );
	self.score = self.s_loadout.n_score;
	self.pers[ "score" ] = self.s_loadout.n_score;
	self giveWeapon( level.zombie_lethal_grenade_player_init );
	self setWeaponAmmoClip( level.zombie_lethal_grenade_player_init, 2 );
	wait 1;
	self disableInvulnerability();
}

function whoswho_give_respawn_weapon( b_switch_weapon )
{
	if ( isDefined( WHOSWHO_RESPAWN_WEAPON ) )
		self zm_weapons::weapon_give( getWeapon( WHOSWHO_RESPAWN_WEAPON ), 0, 0, 1, b_switch_weapon );
	else
		self zm_weapons::weapon_give( level.start_weapon, 0, 0, 1, 1 );

}

function whoswho_bleed_timeout( delay, corpse )
{
	self endon( "player_suicide" );
	self endon( "disconnect" );
	corpse endon( "death" );
	
	corpse.bleedout_time = delay;
	n_bleedout_time = corpse.bleedout_time;
	
	while ( corpse.bleedout_time > 0 )
	{
		corpse.bleedout_time -= 1;
		objective_SetUIModelValue( corpse.n_obj_id, "whoswho_clone_bleedout_percent", corpse.bleedout_time / n_bleedout_time );
				
		wait 1;
	}
	
	if ( isDefined( corpse.revivetrigger ) )
	{
		while ( corpse.revivetrigger.beingrevived )
			WAIT_SERVER_FRAME;
		
	}
	if ( isDefined( self.s_loadout.a_perks ) && level flag::exists( "solo_game" ) && level flag::get( "solo_game" ) )
	{
		i = 0;
		while ( i < self.s_loadout.a_perks.size )
		{
			perk = self.s_loadout.a_perks[ i ];
			if ( perk == "specialty_quickrevive" )
			{
				arrayremovevalue( self.s_loadout.a_perks, self.s_loadout.a_perks[ i ] );
				corpse notify( "player_revived", self );
				return;
			}
			i++;
		}
	}
	self whoswho_corpse_cleanup( corpse, 0 );
}

function whoswho_handle_multiple_instances( corpse )
{
	corpse endon( "death" );
	self waittill( "chugabud_effects_cleanup" );
	if ( isDefined( corpse ) )
		self whoswho_corpse_cleanup( corpse, 0 );
	
}

function whoswho_laststand_cleanup( corpse, str_notify )
{
	if ( isDefined( str_notify ) )
		self waittill( str_notify );
	
	self whoswho_give_loadout();
	self whoswho_corpse_cleanup( corpse, 1 );
}

function whoswho_corpse_cleanup( corpse, was_revived )
{
	self notify( "chugabud_effects_cleanup" );
	if ( was_revived )
	{
		playSoundAtPosition( "zmb_perks_whoswho_appear", corpse.origin );
		playFx( WHOSWHO_REVIVED_FX, corpse.origin );
	}
	else
	{
		playSoundAtPosition( "zmb_perks_whoswho_disappear", corpse.origin );
		playFx( WHOSWHO_BLEDOUT_FX, corpse.origin );
		self notify( "chugabud_bleedout" );
	}
	if ( isDefined( corpse.revivetrigger ) )
	{
		corpse notify( "stop_revive_trigger" );
		corpse.revivetrigger delete();
		corpse.revivetrigger = undefined;
	}
	wait .1;
	corpse zm_perk_utility::destroy_waypoint();
	corpse delete();
	self.e_chugabud_corpse = undefined;
}

function whoswho_save_loadout()
{
	self.s_loadout = self zm_perk_utility::get_player_loadout( array( WHOSWHO_PERK ) );
	self.s_loadout.score = self.score;
}

function whoswho_spawn_corpse()
{
	corpse = zm_clone::spawn_player_clone( self, self.origin, level.default_laststandpistol, self getCharacterBodyModel() );
	corpse useAnimTree( #animtree );
	corpse animScripted( "pb_laststand_idle", self.origin , self.angles, %pb_laststand_idle );
	
	script = toLower( getDvarString( "mapname" ) );
	if ( script != "zm_castle" )
		corpse clientfield::set( "whoswho_register_body", self getEntityNumber() + 1 );
		
	corpse.angles = self.angles;
	corpse.revive_hud = self whoswho_revive_hud_create();
	
	corpse thread zm_perk_utility::setup_whoswho_waypoint(self);
	corpse thread whoswho_revive_trigger_spawn(corpse.n_obj_id);
	return corpse;
}

function whoswho_revive_hud_create()
{
	revive_hud = newclienthudelem( self );
	revive_hud.alignx = "center";
	revive_hud.aligny = "middle";
	revive_hud.horzalign = "center";
	revive_hud.vertalign = "bottom";
	revive_hud.y = -50;
	revive_hud.foreground = 1;
	revive_hud.font = "default";
	revive_hud.fontscale = 1.5;
	revive_hud.alpha = 0;
	revive_hud.color = ( 1, 1, 1 );
	revive_hud settext( "" );
	return self.revive_hud;
}

function whoswho_give_loadout()
{
	self.score = self.s_loadout.score;
	self zm_perk_utility::give_player_loadout( self.s_loadout, 1, 0, 1, array( WHOSWHO_PERK ) );
}

function whoswho_revive_trigger_spawn(n_obj_id)
{
	if ( isDefined( level.revive_trigger_spawn_override_link ) )
		[[ level.revive_trigger_spawn_override_link ]]( self );
	else
	{
		radius = getDvarInt( "revive_trigger_radius" );
		self.revivetrigger = spawn( "trigger_radius", (0.0,0.0,0.0), 0, radius, radius );
		self.revivetrigger setHintString( "" ); // only show the hint string if the triggerer is facing me
		self.revivetrigger setCursorHint( "HINT_NOICON" );
		self.revivetrigger setMovingPlatformEnabled( true );
		self.revivetrigger enableLinkTo();
		self.revivetrigger.origin = self.origin;
		self.revivetrigger linkTo( self );
		self.revivetrigger setInvisibleToPlayer( self );

		self.revivetrigger.beingRevived = 0;
		self.revivetrigger.createtime = getTime();
	}

	self thread whoswho_revive_trigger_think(undefined, n_obj_id);
}

function whoswho_revive_trigger_think( t_secondary,n_obj_id )
{
	self endon ( "disconnect" );
	self endon ( "zombified" );
	self endon ( "stop_revive_trigger" );
	level endon("end_game");
	self endon( "death" );
	
	while ( 1 )
	{
		WAIT_SERVER_FRAME;

		if ( isDefined( t_secondary ) )
			t_revive = t_secondary;
		else
			t_revive = self.revivetrigger;
		
		t_revive setHintString( "" );

		for ( i = 0; i < level.players.size; i++ )
		{
			n_depth = 0;
			n_depth = self depthInWater();			
			
			if ( isDefined( t_secondary ) )
			{
				if ( ( level.players[ i ] zm_laststand::can_revive( self, 1, 1 ) && level.players[ i ] isTouching( t_revive ) ) || n_depth > 20 )
				{
					t_revive setReviveHintString( &"ZOMBIE_BUTTON_TO_REVIVE_PLAYER", self.team );
					break;			
				}
			}
			else
			{
				if ( level.players[ i ] zm_laststand::can_revive_via_override( self ) || level.players[ i ] zm_laststand::can_revive( self ) || n_depth > 20 )
				{				
					t_revive setReviveHintString( &"ZOMBIE_BUTTON_TO_REVIVE_PLAYER", self.team );
					break;			
				}
			}			
		}		

		for ( i = 0; i < level.players.size; i++ )
		{
			e_reviver = level.players[ i ];
			
			if( self == e_reviver || !e_reviver zm_laststand::is_reviving( self, t_secondary ) )
				continue;
			
			if ( !isDefined( e_reviver.s_revive_override_used ) || e_reviver.s_revive_override_used.b_use_revive_tool )
			{
				w_revive_tool = level.weaponReviveTool; 
				if ( isDefined(e_reviver.weaponReviveTool) )
					w_revive_tool = e_reviver.weaponReviveTool; 
				
				w_reviver = e_reviver getCurrentWeapon();
				assert( isDefined( w_reviver ) );
				if ( w_reviver == w_revive_tool )
					continue;
	
				e_reviver giveWeapon( w_revive_tool );
				e_reviver switchToWeapon( w_revive_tool );
				e_reviver setWeaponAmmoStock( w_revive_tool, 1 );
	
				e_reviver thread zm_laststand::revive_give_back_weapons_when_done( w_reviver, w_revive_tool, self );
			}
			else
			{
				w_reviver = undefined;
				w_revive_tool = undefined;
			}
			
			b_revive_successful = e_reviver whoswho_revive_do_revive( self, w_reviver, w_revive_tool, t_secondary,n_obj_id );
			
			e_reviver notify( "revive_done" );
			
			if ( isPlayer( self ) )
				self allowJump( 1 );
			
			self.laststand = undefined;

			if ( b_revive_successful )
			{
				if ( isDefined( level.a_revive_success_perk_func ) )
				{
					foreach ( func in level.a_revive_success_perk_func )
						self [[ func ]]();
					
				}
				
				self thread zm_laststand::revive_success( e_reviver );
				self laststand::cleanup_suicide_hud();
					
				self notify( "stop_revive_trigger" ); // will endon primary or secondary as necessary
				return;
			}
		}
	}
}

function whoswho_revive_do_revive( e_revivee, w_reviver, w_revive_tool, t_secondary,n_obj_id )
{
	assert( self zm_laststand::is_reviving( e_revivee, t_secondary ) );

	reviveTime = self zm_laststand::revive_get_revive_time( e_revivee );

	timer = 0;
	revived = false;
	
	e_revivee.revivetrigger.beingRevived = 1;
	name = level.player_name_directive[ self getEntityNumber() ];
	e_revivee.revive_hud setText( &"ZOMBIE_PLAYER_IS_REVIVING_YOU", name );
	e_revivee laststand::revive_hud_show_n_fade( 3.0 );
	
	e_revivee.revivetrigger setHintString( "" );
	
	if ( isPlayer( e_revivee ) )
		e_revivee startrevive( self );

	if ( WHOSWHO_SHOW_LAST_STAND_PROGRESS_BAR && !isDefined(self.reviveProgressBar) )
		self.reviveProgressBar = 1;

	if ( !isDefined(self.reviveTextHud) )
		self.reviveTextHud = newClientHudElem( self );
	
	self thread zm_laststand::laststand_clean_up_on_disconnect( e_revivee, w_reviver, w_revive_tool );

	if ( !isDefined( self.is_reviving_any ) )
		self.is_reviving_any = 0;
	
	self.is_reviving_any++;
	self thread zm_laststand::laststand_clean_up_reviving_any( e_revivee );

	self.reviveTextHud.alignX = "center";
	self.reviveTextHud.alignY = "middle";
	self.reviveTextHud.horzAlign = "center";
	self.reviveTextHud.vertAlign = "bottom";
	self.reviveTextHud.y = -113;
	if ( self isSplitScreen() )
		self.reviveTextHud.y = -347;
	
	self.reviveTextHud.foreground = 1;
	self.reviveTextHud.font = "default";
	self.reviveTextHud.fontScale = 1.8;
	self.reviveTextHud.alpha = 1;
	self.reviveTextHud.color = ( 1, 1, 1 );
	self.reviveTextHud.hidewheninmenu = 1;
	self.reviveTextHud setText( &"ZOMBIE_REVIVING" );
	
	self thread zm_laststand::check_for_failed_revive(e_revivee);
	
	iterations = reviveTime / .05; // 60
	incriment = 100 / iterations; // 1.666666
	progress = 0;
	
	objective_State( n_obj_id, "current" );
	objective_SetUIModelValue( n_obj_id, "whoswho_clone_revive_percent", 0.0 );
	// objective_SetUIModelValue( n_obj_id, "whoswho_clone_state", "Reviving" );
	
	while ( self zm_laststand::is_reviving( e_revivee, t_secondary ) )
	{
		WAIT_SERVER_FRAME;
		timer += .05;
		progress += incriment;
		
		if ( progress > 100 )
			progress = 100;
		
		objective_SetUIModelValue( n_obj_id, "whoswho_clone_revive_percent", progress / 100 );
		
		if ( self laststand::player_is_in_laststand() )
			break;
		
		if ( isDefined( e_revivee.revivetrigger.auto_revive ) && e_revivee.revivetrigger.auto_revive == 1 )
			break;

		if( timer >= reviveTime)
		{
			revived = 1;
			break;
		}
	}
	objective_State( n_obj_id, "active" );
	// objective_SetUIModelValue( n_obj_id, "whoswho_clone_state", "BleedingOut_Low" );
	
	if ( !revived )
		objective_SetUIModelValue( n_obj_id, "whoswho_clone_revive_percent", 0.0 );
	
	if ( isDefined( self.reviveTextHud ) )
		self.reviveTextHud destroy();
	
	if ( isDefined( e_revivee.revivetrigger.auto_revive ) && e_revivee.revivetrigger.auto_revive == 1 )
	{}
	else if ( !revived )
	{
		if ( isPlayer( e_revivee ) )
			e_revivee stoprevive( self );
		
	}

	e_revivee.revivetrigger setHintString( &"ZOMBIE_BUTTON_TO_REVIVE_PLAYER" );
	e_revivee.revivetrigger.beingRevived = 0;

	self notify( "do_revive_ended_normally" );
	self.is_reviving_any--;

	if ( !revived )
		e_revivee thread zm_laststand::checkforbleedout( self );
	
	return revived;
}