#using scripts\codescripts\struct;
#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_magicbox;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_unitrigger;
#using scripts\zm\_zm_utility;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#precache( "fx", "harry/chaos_box/fx_chaos_box_marker" );

#namespace hb21_zm_magicbox_chaos;

REGISTER_SYSTEM_EX( "hb21_zm_magicbox_chaos", &__init__, &__main__, undefined )

function __init__()
{
	DEFAULT( level.a_box_classnames, [] );
	
	clientfield::register( "zbarrier", "chaos_magicbox_amb_fx", 				VERSION_SHIP, 2, "int" );
	clientfield::register( "zbarrier", "chaos_magicbox_debris_amb_fx", 	VERSION_SHIP, 1, "int" );
	clientfield::register( "zbarrier", "chaos_magicbox_skull_fx", 				VERSION_SHIP, 1, "int" );
	clientfield::register( "zbarrier", "chaos_magicbox_arrive_fx", 			VERSION_SHIP, 1, "int" );
	clientfield::register( "zbarrier", "chaos_magicbox_leave_fx", 				VERSION_SHIP, 1, "int" );
	clientfield::register( "zbarrier", "chaos_magicbox_closed_fx", 			VERSION_SHIP, 1, "int" );
	clientfield::register( "zbarrier", "chaos_magicbox_open_fx", 				VERSION_SHIP, 1, "int" );

	level._effect[ "chaos_light_marker" ] = "harry/chaos_box/fx_chaos_box_marker";
	
	if ( isDefined( level.a_box_classnames[ "zbarrier_zmcore_magicbox_chaos" ] ) )
		return;
		
	s_struct 															= spawnStruct();
	s_struct.ptr_show_box 										= &chaos_show_box;
	s_struct.ptr_magic_box_timer_til_despawn 			= &chaos_timer_til_despawn;
	s_struct.ptr_pandora_show_func 						= &chaos_pandora_show_func;
	s_struct.ptr_pandora_fx_func 								= &chaos_pandora_fx_func;
	s_struct.ptr_joker_custom_movement 				= &chaos_joker_movement;
	s_struct.ptr_chest_glowfx 									= &chaos_treasure_chest_glowfx;
	s_struct.ptr_magic_box_do_weapon_rise 			= &chaos_magic_box_do_weapon_rise;
	s_struct.ptr_process_magic_box_zbarrier_state 	= &chaos_process_magic_box_zbarrier_state;
	level.a_box_classnames[ "zbarrier_zmcore_magicbox_chaos" ] = s_struct;
	
	level thread chaos_wait_then_create_base_magic_box_fx();
	level thread chaos_handle_fire_sale();
}



function __main__()
{
}

function chaos_show_box( b_hide )
{
	if ( b_hide )
	{
	}
	else
	{
	}
}

function chaos_timer_til_despawn( s_magic_box )
{
	v_float = anglesToUp( s_magic_box.angles ) * level.custom_magicbox_float_height;
	self endon( "kill_weapon_movement" );
	n_put_back_time = 12;
	self moveTo( self.origin - ( v_float * .85 ), n_put_back_time, n_put_back_time * .5 );
	wait n_put_back_time;
	if ( isDefined( self ) )
		self delete();
	
}

function chaos_pandora_show_func( e_anchor, e_anchor_target, a_pieces )
{
}

function chaos_pandora_fx_func()
{
	self endon( "death" );
	self.pandora_light = spawn( "script_model", self.zbarrier.origin );
	self.pandora_light.angles = self.zbarrier.angles + vectorScale( ( -1, 0, -1 ), 90 );
	self.pandora_light setModel( "tag_origin" );
	if ( !IS_TRUE( level._box_initialized ) )
	{
		level flag::wait_till( "start_zombie_round_logic" );
		level._box_initialized = 1;
	}
	wait 1;
	if ( isDefined( self ) && isDefined( self.pandora_light ) )
		playFXOnTag( level._effect[ "chaos_light_marker" ], self.pandora_light, "tag_origin" );
	
}

function chaos_joker_movement()
{
	array::thread_all( level.players, &chaos_play_crazi_sound );
	self.weapon_model delete();
	
	self showZBarrierPiece( 3 );
	self clientfield::set( "chaos_magicbox_skull_fx", 1 );
	self SetZBarrierPieceState( 3, "closing" );
	wait .05;
	level notify( "weapon_fly_away_start" );
	while ( self getZBarrierPieceState( 3 ) != "closed" )
		wait .5;
	
	self clientfield::set( "chaos_magicbox_skull_fx", 0 );
	self hideZBarrierPiece( 3 );
	self notify( "box_moving" );
	level notify( "weapon_fly_away_end" );
}

function chaos_play_crazi_sound()
{
	self playLocalSound( "zmb_chaos_magicbox_bear" );
}

function chaos_treasure_chest_glowfx()
{
}

function chaos_magic_box_do_weapon_rise()
{
	self endon( "box_hacked_respin" );
	wait .5;
	self setZBarrierPieceState( 3, "closed" );
	self setZBarrierPieceState( 4, "closed" );
	util::wait_network_frame();
	self zBarrierPieceUseBoxRiseLogic( 3 );
	self zBarrierPieceUseBoxRiseLogic( 4 );
	self setZBarrierPieceState( 3, "opening" );
	self setZBarrierPieceState( 4, "opening" );
	while ( self getZBarrierPieceState( 3 ) != "open" )
		wait .5;
	
	self hideZBarrierPiece( 3 );
	self hideZBarrierPiece( 4 );
}

function chaos_process_magic_box_zbarrier_state( str_state )
{
	switch ( str_state )
	{
		case "away":
		{
			self showZBarrierPiece( 0 );
			self thread chaos_magic_box_teddy_twitches();
			self.state = "away";
			break;
		}
		case "arriving":
		{
			self showZBarrierPiece( 1 );
			self thread chaos_magic_box_arrives();
			self.state = "arriving";
			break;
		}
		case "initial":
		{
			self showZBarrierPiece( 5 );
			self thread chaos_magic_box_initial();
			thread zm_unitrigger::register_static_unitrigger( self.owner.unitrigger_stub, &zm_magicbox::magicbox_unitrigger_think );
			self.state = "initial";
			break;
		}
		case "open":
		{
			self showZBarrierPiece( 2 );
			self hideZBarrierPiece( 5 );
			self thread chaos_magic_box_opens();
			self.state = "open";
			break;
		}
		case "close":
		{
			self showZBarrierPiece( 2 );
			self thread chaos_magic_box_closes();
			self.state = "close";
			break;
		}
		case "leaving":
		{
			self showZBarrierPiece( 1 );
			self hideZBarrierPiece( 5 );
			self thread chaos_magic_box_leaves();
			self.state = "leaving";
			break;
		}
		default:
		{
			if ( isDefined( level.custom_magicbox_state_handler ) )
				self [ [ level.custom_magicbox_state_handler ] ]( str_state );
			
			break;
		}
	}
}

function chaos_magic_box_teddy_twitches()
{
	self endon( "zbarrier_state_change" );
	
	while ( 1 )
	{
		self setZBarrierPieceState( 0, "opening" );
		while ( self getZBarrierPieceState( 0 ) == "opening" )
			wait .05;
		
		self setZBarrierPieceState( 0, "closing" );
		while ( self getZBarrierPieceState( 0 ) == "closing" )
			wait .05;
		
	}
}

function chaos_magic_box_arrives()
{
	self setZBarrierPieceState( 1, "opening" );
	self clientfield::set( "chaos_magicbox_arrive_fx", 1 );
	while ( self getZBarrierPieceState( 1 ) == "opening" )
		wait .05;
	
	self notify( "arrived" );
	self clientfield::set( "chaos_magicbox_amb_fx", 1 );
	self clientfield::set( "chaos_magicbox_arrive_fx", 0 );
	self clientfield::set( "chaos_magicbox_closed_fx", 1 );
	self thread chaos_magic_box_idle();
}

function chaos_magic_box_initial()
{
	level flag::wait_till( "all_players_spawned" );
	level flag::wait_till( "zones_initialized" );
	self setZBarrierPieceState( 1, "open" );
	self clientfield::set( "chaos_magicbox_amb_fx", 1 );
	self clientfield::set( "chaos_magicbox_closed_fx", 1 );
	self thread chaos_magic_box_idle();
}

function chaos_magic_box_opens()
{
	self notify( "stop_idle" );
	self setZBarrierPieceState( 2, "opening" );
	self clientfield::set( "chaos_magicbox_closed_fx", 0 );
	self clientfield::set( "chaos_magicbox_open_fx", 1 );
	self clientfield::set( "chaos_magicbox_amb_fx", 2 );
	while ( self getZBarrierPieceState( 2 ) == "opening" )
		wait .1;
	
	self notify( "opened" );
	self thread chaos_magic_box_open_idle();
}

function chaos_magic_box_open_idle()
{
	self notify( "chaos_magic_box_open_idle" );
	self endon( "chaos_magic_box_open_idle" );
	self endon( "stop_open_idle" );
	self hideZBarrierPiece( 2 );
	self showZBarrierPiece( 5 );
	while ( isDefined( self ) )
	{
		self setZBarrierPieceState( 5, "opening" );
		while ( self getZBarrierPieceState( 5 ) != "open" )
			wait .05;
		
	}
}

function chaos_magic_box_idle()
{
	self notify( "chaos_magic_box_idle" );
	self endon( "chaos_magic_box_idle" );
	self endon( "stop_idle" );
	self hideZBarrierPiece( 1 );
	self showZBarrierPiece( 5 );
	while ( isDefined( self ) )
	{
		self setZBarrierPieceState( 5, "closing" );
		while ( self getZBarrierPieceState( 5 ) != "closed" )
			wait .05;
		
	}
}

function chaos_magic_box_closes()
{
	self notify( "stop_open_idle" );
	self setZBarrierPieceState( 2, "closing" );
	self clientfield::set( "chaos_magicbox_open_fx", 0 );
	
	while ( self getZBarrierPieceState( 2 ) == "closing" )
		wait .1;
	
	self clientfield::set( "chaos_magicbox_closed_fx", 1 );
	self clientfield::set( "chaos_magicbox_amb_fx", 1 );
	self hideZBarrierPiece( 2 );
	self notify( "closed" );
	self thread chaos_magic_box_idle();
}

function chaos_magic_box_leaves()
{
	self notify( "stop_open_idle" );
	self setZBarrierPieceState( 1, "closing" );
	self clientfield::set( "chaos_magicbox_amb_fx", 0 );
	self clientfield::set( "chaos_magicbox_open_fx", 0 );
	self clientfield::set( "chaos_magicbox_leave_fx", 1 );
	self clientfield::set( "chaos_magicbox_closed_fx", 0 );
	while ( self getZBarrierPieceState( 1 ) == "closing" )
		wait .1;
	
	self notify( "left" );
	self clientfield::set( "chaos_magicbox_leave_fx", 0 );
}

function chaos_wait_then_create_base_magic_box_fx()
{
	while ( !isDefined( level.chests ) )
		WAIT_SERVER_FRAME;
		
	while ( !isDefined( level.chests[ level.chests.size - 1 ].zbarrier ) )
		WAIT_SERVER_FRAME;
		
	foreach ( e_chest in level.chests )
	{
		if ( e_chest.zbarrier.classname == "zbarrier_zmcore_magicbox_chaos" )
			e_chest.zbarrier clientfield::set( "chaos_magicbox_debris_amb_fx", 1 );
		
	}
}

function chaos_handle_fire_sale()
{
	while ( isDefined( self ) )
	{
		level waittill( "fire_sale_off" );
		for ( i = 0; i < level.chests.size; i++ )
		{
			if ( level.chest_index != i && isDefined( level.chests[ i ].was_temp ) )
			{
				if ( level.chests[ i ].zbarrier.classname != "zbarrier_zmcore_magicbox_chaos" )
					continue;
				
				level.chests[ i ].zbarrier clientfield::set( "chaos_magicbox_debris_amb_fx", 1 );
				continue;
			}
		}
	}
}