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

#precache( "fx", "zombie/fx_weapon_box_marker_zod_zmb" );
#precache( "fx", "zombie/fx_weapon_box_marker_fl_zod_zmb" );
#precache( "xmodel", "p7_zm_zod_magic_box_tentacle_teddy" );

#namespace hb21_zm_magicbox_soe;

REGISTER_SYSTEM_EX( "hb21_zm_magicbox_soe", &__init__, &__main__, undefined )

function __init__()
{
	DEFAULT( level.a_box_classnames, [] );
	
	clientfield::register( "zbarrier", "soe_magicbox_initial_fx", 		VERSION_SHIP, 1, "int" );
	clientfield::register( "zbarrier", "soe_magicbox_amb_sound", 	VERSION_SHIP, 1, "int" );
	clientfield::register( "zbarrier", "soe_magicbox_open_fx", 			VERSION_SHIP, 3, "int" );

	level._effect[ "soe_light_marker" ] 	= "zombie/fx_weapon_box_marker_zod_zmb";
	level._effect[ "soe_light_flare" ] 		= "zombie/fx_weapon_box_marker_fl_zod_zmb";
	
	if ( isDefined( level.a_box_classnames[ "zbarrier_zmcore_zod_magicbox" ] ) )
		return;
		
	s_struct 															= spawnStruct();
	s_struct.ptr_show_box 										= &soe_show_box;
	s_struct.ptr_magic_box_timer_til_despawn 			= &soe_timer_til_despawn;
	s_struct.ptr_pandora_show_func 						= &soe_pandora_show_func;
	s_struct.ptr_pandora_fx_func 								= &soe_pandora_fx_func;
	s_struct.ptr_joker_custom_movement 				= &soe_joker_movement;
	s_struct.ptr_chest_glowfx 									= &soe_treasure_chest_glowfx;
	s_struct.ptr_magic_box_do_weapon_rise 			= &soe_magic_box_do_weapon_rise;
	s_struct.ptr_process_magic_box_zbarrier_state 	= &soe_process_magic_box_zbarrier_state;
	level.a_box_classnames[ "zbarrier_zmcore_zod_magicbox" ] = s_struct;
	
	level thread soe_wait_then_create_base_magic_box_fx();
	level thread soe_handle_fire_sale();
}

function __main__()
{
}

function soe_show_box( b_hide )
{
	if ( b_hide )
	{
	}
	else
	{
	}
}

function soe_timer_til_despawn( s_magic_box )
{
	self endon( "kill_weapon_movement" );
	n_put_back_time = 12;
	v_float = anglesToUp( self.angles ) * level.custom_magicbox_float_height;
	self moveTo( self.origin - ( v_float * 0.4 ), n_put_back_time, n_put_back_time * .5 );
	wait n_put_back_time;
	if ( isDefined( self ) )
		self delete();
	
}

function soe_pandora_show_func( e_anchor, e_anchor_target, a_pieces )
{
	if ( !isDefined( self.pandora_light ) )
		self thread soe_pandora_fx_func();
	
	playFX( level._effect[ "soe_light_flare" ], self.pandora_light.origin );
}

function soe_pandora_fx_func()
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
		playFXOnTag( level._effect[ "soe_light_marker" ], self.pandora_light, "tag_origin" );
	
}

function soe_joker_movement()
{
	array::thread_all( level.players, &soe_play_crazi_sound );
	v_origin = self.weapon_model.origin - vectorScale( ( 0, 0, 1 ), 5 );
	self.weapon_model delete();
	m_lock = spawn( "script_model", v_origin );
	m_lock setModel( "p7_zm_zod_magic_box_tentacle_teddy" );
	m_lock.angles = self.angles + vectorScale( ( 0, 1, 0 ), 180 );
	m_lock playSound( "zmb_soe_magicbox_bear" );
	wait .5;
	level notify( "weapon_fly_away_start" );
	wait 1;
	m_lock rotateYaw( 3000, 4.5, 4.5 );
	wait 3;
	v_angles = anglesToForward( self.angles - vectorScale( ( 1, 1, 0 ), 90 ) );
	m_lock moveTo( m_lock.origin + 35 * v_angles, 1.5, 1 );
	m_lock waittill( "movedone" );
	m_lock moveTo( m_lock.origin + -100 * v_angles, .5, .5 );
	m_lock waittill( "movedone" );
	m_lock delete();
	self notify( "box_moving" );
	level notify( "weapon_fly_away_end" );
}

function soe_play_crazi_sound()
{
	self playLocalSound( "zmb_zod_box_laugh_child" );
}

function soe_treasure_chest_glowfx()
{
}

function soe_magic_box_do_weapon_rise()
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

function soe_process_magic_box_zbarrier_state( str_state )
{
	switch ( str_state )
	{
		case "away":
		{
			self showZBarrierPiece( 0 );
			self.state = "away";
			self.owner.is_locked = 0;
			break;
		}
		case "arriving":
		{
			self showZBarrierPiece( 1 );
			self thread soe_magic_box_arrives();
			self.state = "arriving";
			break;
		}
		case "initial":
		{
			self showZBarrierPiece( 1 );
			self thread soe_magic_box_initial();
			thread zm_unitrigger::register_static_unitrigger( self.owner.unitrigger_stub, &zm_magicbox::magicbox_unitrigger_think );
			self.state = "initial";
			break;
		}
		case "open":
		{
			self showZBarrierPiece( 2 );
			self thread soe_magic_box_opens();
			self.state = "open";
			break;
		}
		case "close":
		{
			self showZBarrierPiece( 2 );
			self thread soe_magic_box_closes();
			self.state = "close";
			break;
		}
		case "leaving":
		{
			self showZBarrierPiece( 1 );
			self thread soe_magic_box_leaves();
			self.state = "leaving";
			self.owner.is_locked = 0;
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

function soe_magic_box_arrives()
{
	self setZBarrierPieceState( 1, "opening" );
	while ( self getZBarrierPieceState( 1 ) == "opening" )
		wait .05;
	
	self notify( "arrived" );
	self.state = "close";
	self clientfield::set( "soe_magicbox_amb_sound", 1 );
	self clientfield::set( "soe_magicbox_open_fx", 1 );
}

function soe_magic_box_initial()
{
	level flag::wait_till( "all_players_spawned" );
	level flag::wait_till( "zones_initialized" );
	self setZBarrierPieceState( 1, "open" );
	self clientfield::set( "soe_magicbox_open_fx", 1 );
}

function soe_magic_box_opens()
{
	self notify( "stop_idle" );
	self setZBarrierPieceState( 2, "opening" );
	self clientfield::set( "soe_magicbox_open_fx", 1 );
	// self playSound( "zmb_hellbox_open" );
	while ( self getZBarrierPieceState( 2 ) == "opening" )
		wait .1;
	
	self notify( "opened" );
	self thread soe_magic_box_open_idle();
}

function soe_magic_box_open_idle()
{
	self notify( "soe_magic_box_open_idle" );
	self endon( "soe_magic_box_open_idle" );
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

function soe_magic_box_closes()
{
	self notify( "stop_open_idle" );
	self hideZBarrierPiece( 5 );
	self showZBarrierPiece( 2 );
	self setZBarrierPieceState( 2, "closing" );
	self clientfield::set( "soe_magicbox_open_fx", 0 );
	// self playSound( "zmb_hellbox_close" );
	while ( self getZBarrierPieceState( 2 ) == "closing" )
		wait .1;
	
	self notify( "closed" );
	self clientfield::set( "soe_magicbox_open_fx", 3 );
}

function soe_magic_box_leaves()
{
	self notify( "stop_open_idle" );
	self setZBarrierPieceState( 1, "closing" );
	// self clientfield::set( "magicbox_leaving_fx", 1 );
	self clientfield::set( "soe_magicbox_open_fx", 0 );
	while ( self getZBarrierPieceState( 1 ) == "closing" )
		wait .1;
	
	self notify( "left" );
	self clientfield::set( "soe_magicbox_open_fx", 2 );
}

function soe_wait_then_create_base_magic_box_fx()
{
	while ( !isDefined( level.chests ) )
		WAIT_SERVER_FRAME;
		
	while ( !isDefined( level.chests[ level.chests.size - 1 ].zbarrier ) )
		WAIT_SERVER_FRAME;
		
	foreach ( e_chest in level.chests )
	{
		if ( e_chest.zbarrier.classname == "zbarrier_zmcore_zod_magicbox" )
			e_chest.zbarrier clientfield::set( "soe_magicbox_open_fx", 2 );
		
	}
}

function soe_handle_fire_sale()
{
	while (  isDefined( self ) )
	{
		b_state = level util::waittill_any_return( "fire_sale_off", "fire_sale_on" );
		for ( i = 0; i < level.chests.size; i++ )
		{
			if ( level.chest_index != i && isDefined( level.chests[ i ].was_temp ) )
			{
				if ( level.chests[ i ].zbarrier.classname != "zbarrier_zmcore_zod_magicbox" )
					continue;
				
				if ( b_state == "fire_sale_on" )
				{
					level.chests[ i ].zbarrier clientfield::set( "soe_magicbox_amb_sound", 1 );
					level.chests[ i ].zbarrier clientfield::set( "soe_magicbox_open_fx", 3 );
					continue;
				}
				level.chests[ i ].zbarrier clientfield::set( "soe_magicbox_amb_sound", 0 );
				level.chests[ i ].zbarrier clientfield::set( "soe_magicbox_open_fx", 2 );
			}
		}
	}
}