#using scripts\codescripts\struct;
#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_magicbox;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_unitrigger;
#using scripts\zm\_zm_utility;
#using scripts\zm\_hb21_zm_magicbox_botd;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace hb21_zm_magicbox;

REGISTER_SYSTEM_EX( "hb21_zm_magicbox", &__init__, &__main__, undefined )

function __init__()
{
	clientfield::register( "zbarrier", "default_zbarrier_show_sounds", 	VERSION_SHIP, 1, "counter" );
	clientfield::register( "zbarrier", "default_zbarrier_leave_sounds", 	VERSION_SHIP, 1, "counter" );
	
	level.custom_magicbox_float_height 				= 40;
	level.chest_joker_custom_movement 				= &default_chest_joker_custom_movement;
	level.custom_magic_box_timer_til_despawn 	= &default_magic_box_timer_til_despawn;
	level.custom_magic_box_do_weapon_rise 		= &default_magic_box_do_weapon_rise;
	level.custom_magic_box_weapon_wait 			= &magic_box_weapon_wait;
	level.custom_magic_box_fx 							= &default_magic_box_fx;
	level.custom_treasure_chest_glowfx 				= &default_chest_glowfx;
	level.magic_box_zbarrier_state_func 				= &default_process_magic_box_zbarrier_state;
	level.pandora_show_func 								= &custom_pandora_show_func;
	level.pandora_fx_func 									= &custom_pandora_fx_func;
}

function __main__()
{
	zm_audio::sndAnnouncerVoxAdd( "boxmove2", "event_magicbox_0" );
	zm_audio::sndAnnouncerVoxAdd( "boxmove", "" );
	
	// Random Weapon Chest
	zm_utility::add_sound( "open_chest", "" );
	zm_utility::add_sound( "music_chest", "" );
	zm_utility::add_sound( "close_chest", "" );
	
	// Random Weapon Chest
	zm_utility::add_sound( "open_chest2", "zmb_lid_open" );
	zm_utility::add_sound( "music_chest2", "zmb_music_box" );
	zm_utility::add_sound( "close_chest2", "zmb_lid_close" );
	
	level._effect[ "poltergeist" ] = "";
	
	level.zmb_laugh_alias = "";
	
	thread delay_box_hacks();
}

function delay_box_hacks()
{
	while ( !isDefined( level.chests ) )
		WAIT_SERVER_FRAME;
		
	foreach ( s_chest in level.chests )
	{
		s_chest.box_hacks = [];
		s_chest.box_hacks[ "summon_box" ] = &default_show_box;
	}
}

function default_show_box( b_hide )
{
	str_classname = self.zbarrier.classname;
	if ( isDefined( level.a_box_classnames[ str_classname ] ) && isDefined( level.a_box_classnames[ str_classname ].ptr_show_box ) )
	{
		self.zbarrier clientfield::set( "magicbox_open_glow", 0 );
		self.zbarrier clientfield::set( "magicbox_closed_glow", 0 );
		// self.zbarrier clientfield::set( "zbarrier_show_sounds", 0 );
		// self.zbarrier clientfield::set( "zbarrier_leave_sounds", 0 );
		self [ [ level.a_box_classnames[ str_classname ].ptr_show_box ] ]( b_hide );
		return;
	}
	if ( !b_hide )
		self.zbarrier clientfield::increment( "default_zbarrier_show_sounds" );
	else
	{
		self.zbarrier clientfield::increment( "default_zbarrier_leave_sounds" );
		level thread zm_audio::sndAnnouncerPlayVox( "boxmove2" );
	}
}

function default_magic_box_timer_til_despawn( s_magic_box )
{
	str_classname = s_magic_box.classname;
	if ( isDefined( level.a_box_classnames[ str_classname ] ) && isDefined( level.a_box_classnames[ str_classname ].ptr_magic_box_timer_til_despawn ) )
	{
		self [ [ level.a_box_classnames[ str_classname ].ptr_magic_box_timer_til_despawn ] ]( s_magic_box );
		return;
	}
	self zm_magicbox::timer_til_despawn( anglesToUp( s_magic_box.angles ) * level.custom_magicbox_float_height );
}

function custom_pandora_show_func( e_anchor, e_anchor_target, a_pieces )
{	
	str_classname = self.zbarrier.classname;
	if ( isDefined( level.a_box_classnames[ str_classname ] ) && isDefined( level.a_box_classnames[ str_classname ].ptr_pandora_show_func ) )
	{
		self [ [ level.a_box_classnames[ str_classname ].ptr_pandora_show_func ] ]( e_anchor, e_anchor_target, a_pieces );
		self thread [ [ level.pandora_fx_func ] ]();
		return;
	}
	self zm_magicbox::default_pandora_show_func();
}

function custom_pandora_fx_func()
{
	str_classname = self.zbarrier.classname;
	if ( isDefined( level.a_box_classnames[ str_classname ] ) && isDefined( level.a_box_classnames[ str_classname ].ptr_pandora_fx_func ) )
	{
		self [ [ level.a_box_classnames[ str_classname ].ptr_pandora_fx_func ] ]();
		return;
	}
	self zm_magicbox::default_pandora_fx_func();
}

function default_chest_joker_custom_movement()
{
	str_classname = self.classname;
	if ( isDefined( level.a_box_classnames[ str_classname ] ) && isDefined( level.a_box_classnames[ str_classname ].ptr_joker_custom_movement ) )
	{
		self [ [ level.a_box_classnames[ str_classname ].ptr_joker_custom_movement ] ]();
		return;
	}
	
	array::thread_all( level.players, &default_play_crazi_sound );
	
	v_origin = self.weapon_model.origin;
	self.weapon_model delete();
	self.weapon_model = spawn( "script_model", v_origin );
	self.weapon_model setModel( level.chest_joker_model );
	self.weapon_model.angles = self.angles + vectorScale( ( 0, 1, 0 ), 180 );
	wait .5;
	level notify( "weapon_fly_away_start" );
	wait 2;
	if ( isDefined( self.weapon_model ) )
	{
		v_fly_away = self.origin + anglesToUp( self.angles ) * 500;
		self.weapon_model moveTo( v_fly_away, 4, 3 );
	}
	if ( isDefined( self.weapon_model_dw ) )
	{
		v_fly_away = self.origin + anglesToUp( self.angles ) * 500;
		self.weapon_model_dw moveTo( v_fly_away, 4, 3 );
	}
	self.weapon_model waittill( "movedone");
	self.weapon_model delete();
	if ( isDefined( self.weapon_model_dw ) )
	{
		self.weapon_model_dw delete();
		self.weapon_model_dw = undefined;
	}
	self notify( "box_moving" );
	level notify( "weapon_fly_away_end" );
}

function default_chest_glowfx()
{
	str_classname = self.classname;
	if ( isDefined( level.a_box_classnames[ str_classname ] ) && isDefined( level.a_box_classnames[ str_classname ].ptr_chest_glowfx ) )
	{
		self [ [ level.a_box_classnames[ str_classname ].ptr_chest_glowfx ] ]();
		return;
	}
	self zm_magicbox::treasure_chest_glowfx();
}

function default_process_magic_box_zbarrier_state( str_state )
{
	str_classname = self.classname;
	if ( isDefined( level.a_box_classnames[ str_classname ] ) && isDefined( level.a_box_classnames[ str_classname ].ptr_process_magic_box_zbarrier_state ) )
	{
		self [ [ level.a_box_classnames[ str_classname ].ptr_process_magic_box_zbarrier_state ] ]( str_state );
		return;
	}
	
	switch ( str_state )
	{
		case "away":
		{
			self showZBarrierPiece( 0 );
			self.state = "away";
			break;
		}
		case "arriving":
		{
			self showZBarrierPiece( 1 );
			self thread zm_magicbox::magic_box_arrives();
			self.state = "arriving";
			break;
		}
		case "initial":
		{
			self showZBarrierPiece( 1 );
			self thread zm_magicbox::magic_box_initial();
			thread zm_unitrigger::register_static_unitrigger( self.owner.unitrigger_stub, &zm_magicbox::magicbox_unitrigger_think );
			self.state = "initial";
			break;
		}
		case "open":
		{
			self showZBarrierPiece( 2 );
			self thread zm_magicbox::magic_box_opens();
			self.state = "open";
			zm_utility::play_sound_at_pos( "open_chest2", self.origin );
			zm_utility::play_sound_at_pos( "music_chest2", self.origin );
			break;
		}
		case "close":
		{
			self showZBarrierPiece( 2 );
			self thread zm_magicbox::magic_box_closes();
			self.state = "close";
			zm_utility::play_sound_at_pos( "close_chest2", self.origin );
			break;
		}
		case "leaving":
		{
			self showZBarrierPiece( 1 );
			self thread zm_magicbox::magic_box_leaves();
			self thread default_box_poltergeist();
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

function default_box_poltergeist()
{
	self waittill( "left" );
	playFX( "zombie/fx_barrier_buy_zmb", self.origin, anglesToUp( self.angles ), anglesToForward( self.angles ) );
}

function default_magic_box_do_weapon_rise()
{
	str_classname = self.classname;
	if ( isDefined( level.a_box_classnames[ str_classname ] ) && isDefined( level.a_box_classnames[ str_classname ].ptr_magic_box_do_weapon_rise ) )
	{
		self [ [ level.a_box_classnames[ str_classname ].ptr_magic_box_do_weapon_rise ] ]();
		return;
	}
	self zm_magicbox::magic_box_do_weapon_rise();
}

function default_magic_box_fx()
{
}

function magic_box_weapon_wait()
{
	wait .5;
}

function default_play_crazi_sound()
{
	self playLocalSound( "zmb_laugh_child" );
}