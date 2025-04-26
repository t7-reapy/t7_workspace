#using scripts\codescripts\struct;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_perk_utility;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_perk_quick_revive.gsh;

#precache( "string", "ZOMBIE_PERK_QUICKREVIVE" );
#precache( "triggerstring", "ZOMBIE_PERK_QUICKREVIVE", QUICK_REVIVE_PERK_COST_STRING );
#precache( "triggerstring", "ZOMBIE_PERK_QUICKREVIVE", QUICK_REVIVE_PERK_SOLO_COST_STRING );
#precache( "fx", QUICK_REVIVE_MACHINE_LIGHT_FX );

#namespace zm_perk_quick_revive;

REGISTER_SYSTEM_EX( "zm_perk_quick_revive", &__init__, &__main__, undefined )

// CALLBACKS AND OVERRIDES
// 
// NONE

//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------
function __init__()
{
	if ( IS_TRUE( QUICK_REVIVE_LEVEL_USE_PERK ) )
		enable_quick_revive_perk_for_level();
	
}

function __main__()
{
	if ( IS_TRUE( QUICK_REVIVE_LEVEL_USE_PERK ) )
		quick_revive_main();
	
}

function enable_quick_revive_perk_for_level()
{	
	zm_perks::register_perk_basic_info( QUICK_REVIVE_PERK, QUICK_REVIVE_ALIAS, &quick_revive_cost_override, &"ZOMBIE_PERK_QUICKREVIVE", getWeapon( QUICK_REVIVE_PERK_BOTTLE_WEAPON ) );
	zm_perks::register_perk_precache_func( QUICK_REVIVE_PERK, &quick_revive_precache );
	zm_perks::register_perk_clientfields( QUICK_REVIVE_PERK, &quick_revive_register_clientfield, &quick_revive_set_clientfield );
	zm_perks::register_perk_machine( QUICK_REVIVE_PERK, &quick_revive_perk_machine_setup );
	zm_perks::register_perk_threads( QUICK_REVIVE_PERK, &quick_revive_give_perk, &quick_revive_take_perk );
	zm_perks::register_perk_host_migration_params( QUICK_REVIVE_PERK, QUICK_REVIVE_RADIANT_MACHINE_NAME, 	QUICK_REVIVE_PERK );
	zm_perks::register_perk_machine_power_override( QUICK_REVIVE_PERK, &quick_revive_host_migration_func );
	
	level flag::init( "solo_revive" );
}

function quick_revive_precache()
{
	level._effect[ QUICK_REVIVE_PERK ] = QUICK_REVIVE_MACHINE_LIGHT_FX;
	
	level.machine_assets[ QUICK_REVIVE_PERK ] = spawnStruct();
	level.machine_assets[ QUICK_REVIVE_PERK ].weapon = getWeapon( QUICK_REVIVE_PERK_BOTTLE_WEAPON );
	level.machine_assets[ QUICK_REVIVE_PERK ].off_model = QUICK_REVIVE_MACHINE_DISABLED_MODEL;
	level.machine_assets[ QUICK_REVIVE_PERK ].on_model = QUICK_REVIVE_MACHINE_ACTIVE_MODEL;	
}

function quick_revive_register_clientfield() 
{
	clientfield::register( "clientuimodel", QUICK_REVIVE_CLIENTFIELD, VERSION_SHIP, 2, "int" );
}

function quick_revive_set_clientfield( n_state ) 
{
	if ( n_state != 0 && ( level zm_perk_utility::is_perk_paused( QUICK_REVIVE_PERK ) || self zm_perk_utility::is_perk_paused( QUICK_REVIVE_PERK ) ) )
		n_state = 2;
	
	self clientfield::set_player_uimodel( QUICK_REVIVE_CLIENTFIELD, n_state );
}

function quick_revive_perk_machine_setup( e_use_trigger, e_perk_machine, e_bump_trigger, e_collision )
{
	e_use_trigger.script_sound = QUICK_REVIVE_JINGLE;
	e_use_trigger.script_string 	= QUICK_REVIVE_SCRIPT_STRING;
	e_use_trigger.script_label = QUICK_REVIVE_STING;
	e_use_trigger.target = QUICK_REVIVE_RADIANT_MACHINE_NAME;
	e_perk_machine.script_string = QUICK_REVIVE_SCRIPT_STRING;
	e_perk_machine.targetname = QUICK_REVIVE_RADIANT_MACHINE_NAME;
	if ( isDefined( e_bump_trigger ) )
		e_bump_trigger.script_string = QUICK_REVIVE_SCRIPT_STRING;
	
	e_perk_machine thread zm_perk_utility::register_vulture_perk_safe();
}

function quick_revive_give_perk()
{
	zm_perk_utility::print_version( QUICK_REVIVE_PERK, QUICK_REVIVE_VERSION );
	
	if ( level zm_perk_utility::is_perk_paused( QUICK_REVIVE_PERK ) )
		self zm_perk_utility::player_pause_perk( QUICK_REVIVE_PERK );
	
	if ( self zm_perk_utility::is_perk_paused( QUICK_REVIVE_PERK ) )
		return;
		
	self thread quick_revive_enabled( 1 );
}

function quick_revive_take_perk( b_pause, str_perk, str_result ) {}

function quick_revive_host_migration_func()
{
	quick_revive_turn_on();
}

//-----------------------------------------------------------------------------------
// FUNCTIONALITY
//-----------------------------------------------------------------------------------
function quick_revive_main()
{	
	level.check_quickrevive_hotjoin = &quick_revive_check_for_hotjoin;

	if ( IS_TRUE( QUICK_REVIVE_IN_WONDERFIZZ ) )
		zm_perk_utility::add_perk_to_wunderfizz( QUICK_REVIVE_PERK );
	
}

function quick_revive_enabled( b_enabled )
{
	if ( IS_TRUE( b_enabled ) )
		self thread quick_revive_logic();
	
}

function quick_revive_logic()
{
	if ( zm_perks::use_solo_revive() )
	{
		self.lives = 1;
		
		if ( !isDefined( level.solo_lives_given ) )
			level.solo_lives_given = 0;

		if ( isDefined( level.solo_game_free_player_quickrevive ) )
			level.solo_game_free_player_quickrevive = undefined;
		else
			level.solo_lives_given++;
		
		if ( level.solo_lives_given >= QUICK_REVIVE_SOLO_REVIVE_LIMIT )
			level flag::set( "solo_revive" );
		
		self thread quick_revive_solo_buy_trigger_move( QUICK_REVIVE_PERK );
	}
}

function quick_revive_cost_override()
{
	solo = zm_perks::use_solo_revive();
	
	if ( solo )
		return QUICK_REVIVE_PERK_SOLO_COST;
	else
		return QUICK_REVIVE_PERK_COST;
	
}

function quick_revive_turn_on()
{
	level endon( "stop_quickrevive_logic" );  

	level flag::wait_till( "start_zombie_round_logic" );

	solo_mode = 0;
	if ( zm_perks::use_solo_revive() )
		solo_mode = 1;
	
	if ( solo_mode && !IS_TRUE( level.solo_revive_init ) )
		level.solo_revive_init = 1;
	
	while ( 1 )
	{
		machine = getEntArray( QUICK_REVIVE_RADIANT_MACHINE_NAME, "targetname" );
		machine_triggers = GetEntArray( QUICK_REVIVE_RADIANT_MACHINE_NAME, "target" );
		
		for ( i = 0; i < machine.size; i++ )
		{
			if ( flag::exists( "solo_game" ) && flag::exists( "solo_revive" ) && level flag::get( "solo_game" ) && level flag::get( "solo_revive" ) )
				machine[ i ] hide();
			
			machine[ i ] setModel( level.machine_assets[ QUICK_REVIVE_PERK ].off_model );
			
			if ( isDefined( level.quick_revive_final_pos ) )
				level.quick_revive_default_origin = level.quick_revive_final_pos;
			
			if ( !isDefined( level.quick_revive_default_origin ) )
			{
				level.quick_revive_default_origin = machine[ i ].origin;
				level.quick_revive_default_angles = machine[ i ].angles;
			}
			level.quick_revive_machine = machine[ i ];
		}
			
		array::thread_all( machine_triggers, &zm_perks::set_power_on, 0 );
		
		if ( IS_TRUE( level.initial_quick_revive_power_off ) )
			level waittill( "revive_on" );
		else if ( !IS_TRUE( solo_mode ) )
			level waittill( "revive_on" );
			
		level notify( "revive_on" );
		
		for ( i = 0; i < machine.size; i++ )
		{
			if ( isDefined( machine[ i ].classname ) && machine[ i ].classname == "script_model" )
			{
				if ( isDefined( machine[ i ].script_noteworthy ) && machine[ i ].script_noteworthy == "clip" )
					machine_clip = machine[ i ];
				else
				{	
					machine[ i ] setModel( level.machine_assets[ QUICK_REVIVE_PERK ].on_model );
					machine[ i ] playSound( "zmb_perks_power_on" );
					machine[ i ] vibrate( ( 0, -100, 0 ), .3, .4, 3 );
					machine_model = machine[ i ];
					machine[ i ] thread zm_perks::perk_fx( QUICK_REVIVE_PERK );
					machine[ i ] notify( "stop_loopsound" );
					machine[ i ] thread zm_perks::play_loop_on_machine();
					
					if ( isDefined( machine_triggers[ i ] ) )
						machine_clip = machine_triggers[ i ].clip;
					if ( isDefined( machine_triggers[ i ] ) )
						blocker_model = machine_triggers[ i ].blocker_model;
					
				}
			}
		}
		util::wait_network_frame();
		if ( solo_mode && isDefined( machine_model ) && !IS_TRUE( machine_model.ishidden ) )
			machine_model thread quick_revive_solo_fx( machine_clip, blocker_model );
		
		array::thread_all( machine_triggers, &zm_perks::set_power_on, 1 );
		if( isDefined( level.machine_assets[ QUICK_REVIVE_PERK ].power_on_callback ) )
			array::thread_all( machine, level.machine_assets[ QUICK_REVIVE_PERK ].power_on_callback );
		
		level notify( "specialty_quickrevive_power_on" );
		
		if ( isDefined( machine_model ) )
			machine_model.ishidden = 0;
		
		notify_str = level util::waittill_any_return( "revive_off", "revive_hide" );
		should_hide = 0;
		if ( notify_str == "revive_hide" )
			should_hide = 1;
		
		if ( isDefined( level.machine_assets[ QUICK_REVIVE_PERK ].power_off_callback ) )
			array::thread_all( machine, level.machine_assets[ QUICK_REVIVE_PERK ].power_off_callback );
		
		for ( i = 0; i < machine.size; i++ )
		{
			if ( isDefined( machine[ i ].classname ) && machine[ i ].classname == "script_model" )
				machine[ i ] zm_perks::turn_perk_off( should_hide );
			
		}
	}
}

function quick_revive_reenable( machine_clip, solo_mode )
{
	if ( isDefined( level.revive_machine_spawned ) && !IS_TRUE( level.revive_machine_spawned ) )
		return;
	
	wait .1;
	power_state = 0;
	
	if ( IS_TRUE( solo_mode ) )
	{	
		power_state = 1;
		should_pause = 1;
		
		players = getPlayers();
		foreach ( player in players )
		{
			if ( isDefined( player.lives ) && player.lives > 0 && power_state )
				should_pause = 0;
			else if ( isDefined( player.lives ) && player.lives < 1 )
				should_pause = 1;
			
		}
		
		if ( should_pause )
			zm_perks::perk_pause( QUICK_REVIVE_PERK );
		else
			zm_perks::perk_unpause( QUICK_REVIVE_PERK );		
		
		if( IS_TRUE( level.solo_revive_init ) && level flag::get( "solo_revive" )  )
		{		
			quick_revive_disable( machine_clip );
			return;
		}
		
		quick_revive_update_power_state( 1 );
		
		quick_revive_unhide();	
		
		quick_revive_restart();
		
		level notify( "revive_off" );
		wait .1;
		level notify( "stop_quickrevive_logic" );			
	}
	else
	{
		if ( !IS_TRUE( level._dont_unhide_quickervive_on_hotjoin ) )
		{
			quick_revive_unhide();
			level notify( "revive_off" );
			wait .1;
		}
		level notify( "revive_hide");
		level notify( "stop_quickrevive_logic" );
		
		quick_revive_restart();

		triggers = getEntArray( "zombie_vending", "targetname" );		
		foreach ( trigger in triggers )
		{
			if ( !isDefined( trigger.script_noteworthy ) )
			 continue;
			
			if ( trigger.script_noteworthy == QUICK_REVIVE_PERK )
			{
				if ( isDefined( trigger.script_int ) )
				{
					if ( level flag::get( "power_on" + trigger.script_int ) )
						power_state = 1;
					
				}
				else
				{
					if ( level flag::get( "power_on" ) )
						power_state = 1;
					
				}	
			}
		}		

		quick_revive_update_power_state( power_state );			
	}
	
	level thread quick_revive_turn_on();
	if ( power_state )
	{	
		zm_perks::perk_unpause( QUICK_REVIVE_PERK );
		level notify( "revive_on" );
		wait .1;
		level notify( QUICK_REVIVE_PERK + "_power_on" );
	}
	else
		zm_perks::perk_pause( QUICK_REVIVE_PERK );	
	
	if ( !IS_TRUE( solo_mode ) )
		return;
	
	should_pause = 1;
	players = getPlayers();
	foreach ( player in players )
	{
		if ( !zm_utility::is_player_valid( player ) )
			continue;
		if ( player hasPerk( QUICK_REVIVE_PERK ) )
		{
			if ( !isDefined( player.lives ) )
				player.lives = 0;
			
			if ( !isDefined( level.solo_lives_given  ) )
				level.solo_lives_given = 0;
				
			level.solo_lives_given++;
			player.lives++;
			
			if ( isDefined( player.lives ) && player.lives > 0 && power_state )
				should_pause = 0;
			else
				should_pause = 1;
								
		}
	}
	
	if ( should_pause )
		zm_perks::perk_pause( QUICK_REVIVE_PERK );
	else
		zm_perks::perk_unpause( QUICK_REVIVE_PERK );
	
}

function quick_revive_update( solo_mode )
{
	if ( !isDefined( solo_mode ) )
		solo_mode = 0;
	
	clip = undefined;
	if ( isDefined( level.quick_revive_machine_clip ) )
		clip = level.quick_revive_machine_clip;
	
	level._custom_perks[ QUICK_REVIVE_PERK ].cost = quick_revive_cost_override();
	
	level.quick_revive_machine thread quick_revive_reenable( clip, solo_mode );
}

function quick_revive_check_for_hotjoin()
{
	level notify( "notify_check_quickrevive_for_hotjoin" );
	level endon( "notify_check_quickrevive_for_hotjoin" );
	
	solo_mode = 0;
	should_update = 0;
	
	WAIT_SERVER_FRAME;
	
	players = getPlayers();
	if ( players.size == 1 || IS_TRUE( level.force_solo_quick_revive ) )
	{
		solo_mode = 1;
		if ( !level flag::get( "solo_game" ) )
			should_update = 1;
		
		level flag::set( "solo_game" );
	}
	else
	{
		if ( level flag::get( "solo_game" ) )
			should_update = 1;
		
		level flag::clear("solo_game");
	}
	
	level.using_solo_revive = solo_mode;
	level.revive_machine_is_solo = solo_mode;
	
	zm::set_default_laststand_pistol( solo_mode );
	
	if ( should_update && isDefined( level.quick_revive_machine ) )
		quick_revive_update( solo_mode );	
	
}

function quick_revive_solo_fx( machine_clip, blocker_model )
{
	if ( level flag::exists( "solo_revive" ) && level flag::get( "solo_revive" ) && !level flag::get( "solo_game" ) )
		return;	
	
	if ( isDefined( machine_clip ) )
		level.quick_revive_machine_clip = machine_clip;	
	
	level notify( "revive_solo_fx" );
	level endon( "revive_solo_fx" );
	self endon( "death" );
	
	level flag::wait_till( "solo_revive" );

	if ( isDefined( level.revive_solo_fx_func ) )
		level thread [[ level.revive_solo_fx_func ]]();

	wait 2;

	self playSound( "zmb_box_move" );

	playSoundAtPosition( "zmb_whoosh", self.origin );

	if ( isDefined( self._linked_ent ) )
		self unLink();
		
	self moveTo( self.origin + ( 0, 0, 40 ), 3 );

	if ( isDefined( level.custom_vibrate_func ) )
		[ [ level.custom_vibrate_func ] ]( self );
	else
	{
	   direction = self.origin;
	   direction = ( direction[ 1 ], direction[ 0 ], 0 );
	   
	   if ( direction[ 1 ] < 0 || ( direction[ 0 ] > 0 && direction[ 1 ] > 0 ) )
            direction = ( direction[ 0 ], direction[ 1 ] * -1, 0 );
       else if ( direction[ 0 ] < 0 )
            direction = ( direction[ 0 ] * -1, direction[ 1 ], 0 );
	   
     self vibrate( direction, 10, .5, 5 );
	}
	
	self waittill( "movedone" );
	playFX( level._effect[ "poltergeist" ], self.origin );
	playSoundAtPosition ( "zmb_box_poof", self.origin );

	if ( isDefined( self.fx ) )
	{
		self.fx unLink();
		self.fx delete();	
	}
	
	if ( isDefined( machine_clip ) )
	{
		machine_clip hide();
		machine_clip connectPaths();	
	}
	
	if ( isDefined( blocker_model ) )
		blocker_model show();
	
	level notify( "revive_hide" );
}

function quick_revive_disable( machine_clip )
{
	if ( IS_TRUE( level.solo_revive_init ) && level flag::get( "solo_revive" ) && isdefined( level.quick_revive_machine ) )
	{	
		triggers = getEntArray( "zombie_vending", "targetname" );		
		foreach ( trigger in triggers )
		{
			if ( !isDefined( trigger.script_noteworthy ) )
			 continue;
			
			if ( trigger.script_noteworthy == QUICK_REVIVE_PERK )
				trigger TriggerEnable( 0 );
			
		}		
		
		foreach ( item in level.powered_items )
		{
			if ( isDefined( item.target ) && isDefined( item.target.script_noteworthy ) && item.target.script_noteworthy == QUICK_REVIVE_PERK )
			{
				item.power = 1;
				item.self_powered = 1;
			}
		}
		
		if ( isDefined( level.quick_revive_machine.original_pos ) )
		{
			level.quick_revive_default_origin = level.quick_revive_machine.original_pos;
			level.quick_revive_default_angles = level.quick_revive_machine.original_angles;
		}
	
		move_org = level.quick_revive_default_origin;
		
		if ( isDefined( level.quick_revive_linked_ent ) )
		{
			move_org = level.quick_revive_linked_ent.origin;
			
			if( isDefined( level.quick_revive_linked_ent_offset ) )
				move_org += level.quick_revive_linked_ent_offset;
			
			level.quick_revive_machine unlink();
		}
		
		level.quick_revive_machine moveTo( move_org + ( 0, 0, 40 ), 3 );

		direction = level.quick_revive_machine.origin;
		direction = ( direction[ 1 ], direction[ 0 ], 0 );
		   
	   	if ( direction[ 1 ] < 0 || ( direction[ 0 ] > 0 && direction[ 1 ] > 0 ) )
	        direction = ( direction[ 0 ], direction[ 1 ] * -1, 0 );
	   	else if ( direction[ 0 ] < 0 )
	        direction = ( direction[ 0 ] * -1, direction[ 1 ], 0 );
		   
	    level.quick_revive_machine vibrate( direction, 10, .5, 4 );
	    level.quick_revive_machine waittill( "movedone" );		
		
		level.quick_revive_machine hide();
		level.quick_revive_machine.ishidden = 1;			
		if ( isDefined( level.quick_revive_machine_clip ) )
		{
			level.quick_revive_machine_clip hide();
			level.quick_revive_machine_clip connectPaths();
		}
		
		playFX( level._effect[ "poltergeist" ], level.quick_revive_machine.origin );
		if ( isDefined( level.quick_revive_trigger ) && isDefined( level.quick_revive_trigger.blocker_model ) )
			level.quick_revive_trigger.blocker_model show();
		
		level notify( "revive_hide" );
	}
}

function quick_revive_unhide()
{
	while ( zm_perks::players_are_in_perk_area( level.quick_revive_machine ) )
		WAIT_SERVER_FRAME;
	
	if ( isDefined( level.quick_revive_machine_clip ) )
	{
		level.quick_revive_machine_clip show();
		level.quick_revive_machine_clip disconnectPaths();		
	}
	
	if ( isDefined( level.quick_revive_final_pos ) )
		level.quick_revive_machine.origin = level.quick_revive_final_pos;
	
	playFX( level._effect[ "poltergeist" ], level.quick_revive_machine.origin );
	if ( isDefined( level.quick_revive_trigger ) && isDefined( level.quick_revive_trigger.blocker_model ) )
		level.quick_revive_trigger.blocker_model hide();
	
	level.quick_revive_machine show();
	
	if ( isDefined( level.quick_revive_machine.original_pos ) )
	{
		level.quick_revive_default_origin = level.quick_revive_machine.original_pos;
		level.quick_revive_default_angles = level.quick_revive_machine.original_angles;
	}
		
	direction = level.quick_revive_machine.origin;
	direction = ( direction[ 1 ], direction[ 0 ], 0 );
   
	if ( direction[ 1 ] < 0 || ( direction[ 0 ] > 0 && direction[ 1 ] > 0 ) )
		direction = ( direction[ 0 ], direction[ 1 ] * -1, 0 );
	else if( direction[ 0 ] < 0 )
		direction = ( direction[ 0 ] * -1, direction[ 1 ], 0 );
	
	org = level.quick_revive_default_origin;
	
	if ( isDefined( level.quick_revive_linked_ent ) )
	{
		org = level.quick_revive_linked_ent.origin;
		
		if ( isDefined( level.quick_revive_linked_ent_offset ) )
			org += level.quick_revive_linked_ent_offset;
		
	}
	
	if ( !IS_TRUE( level.quick_revive_linked_ent_moves ) && ( level.quick_revive_machine.origin != org ) )
	{
		level.quick_revive_machine moveTo( org, 3 );
		
		level.quick_revive_machine vibrate( direction, 10, .5, 2.9 );
		level.quick_revive_machine waittill( "movedone" );
		
		level.quick_revive_machine.angles = level.quick_revive_default_angles;
	}
	else
	{
		if ( isDefined( level.quick_revive_linked_ent ) )
		{
			org = level.quick_revive_linked_ent.origin;
			
			if ( isDefined( level.quick_revive_linked_ent_offset ) )
				org += level.quick_revive_linked_ent_offset;
			
			level.quick_revive_machine.origin = org;
		}
		
		level.quick_revive_machine vibrate( ( 0, -100, 0 ), .3, .4, 3 );
	}

	if ( isDefined( level.quick_revive_linked_ent ) )
		level.quick_revive_machine linkTo( level.quick_revive_linked_ent );
	
	level.quick_revive_machine.ishidden = 0;
}

function quick_revive_restart()
{
	triggers = getEntArray( "zombie_vending", "targetname" );		
	foreach ( trigger in triggers )
	{
		if ( !isDefined( trigger.script_noteworthy ) )
		 continue;
		
		if ( trigger.script_noteworthy == QUICK_REVIVE_PERK )
		{
			trigger notify( "stop_quickrevive_logic" );
			trigger thread zm_perks::vending_trigger_think();
			trigger triggerEnable( 1 );
		}
	}
}

function quick_revive_update_power_state( poweron )
{
	foreach ( item in level.powered_items )
	{
		if ( isDefined( item.target ) && isDefined( item.target.script_noteworthy ) && item.target.script_noteworthy == QUICK_REVIVE_PERK )
		{
			if ( item.power && !poweron )
			{
				if ( !isDefined( item.powered_count ) )
					item.powered_count = 0;
				else if ( item.powered_count > 0 )
					item.powered_count--;
					
			}
			else if ( !item.power && poweron )
			{
				if ( !isDefined( item.powered_count ) )
					item.powered_count = 0;
				
				item.powered_count++;
			}

			if ( !isDefined( item.depowered_count ) )
				item.depowered_count = 0;

			item.power = poweron;
		}
	}
}

function quick_revive_solo_buy_trigger_move( revive_trigger_noteworthy )
{
	self endon( "death" );
	
	revive_perk_triggers = getEntArray( revive_trigger_noteworthy, "script_noteworthy" );
	
	foreach ( revive_perk_trigger in revive_perk_triggers )
		self thread quick_revive_solo_buy_trigger_move_trigger( revive_perk_trigger );
	
}

function quick_revive_solo_buy_trigger_move_trigger( revive_perk_trigger )
{
	self endon( "death" );
	
	revive_perk_trigger setInvisibleToPlayer( self );
	
	if ( level.solo_lives_given >= QUICK_REVIVE_SOLO_REVIVE_LIMIT )
	{
		revive_perk_trigger triggerEnable( 0 );
		
		if ( isDefined( level._solo_revive_machine_expire_func ) )
			revive_perk_trigger [[ level._solo_revive_machine_expire_func ]]();

		return;
	}
	
	while ( self.lives > 0 )
		WAIT_SERVER_FRAME;
	
	revive_perk_trigger setVisibleToPlayer( self );
}