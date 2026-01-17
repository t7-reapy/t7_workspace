#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;

#using scripts\zm\_zm_magicbox;
#using scripts\zm\_zm_unitrigger;
#using scripts\zm\_zm_utility;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#precache( "fx", "kingslayer_kyle/s2_mystery_box_marker" );

REGISTER_SYSTEM_EX( "zm_s2_mystery_box", &__init__, &__main__, undefined )

function __init__()
{
	clientfield::register( "scriptmover", "magic_box_weapon_rise_fx", VERSION_SHIP, 1, "counter" );
	
	level.chest_joker_model = "tag_origin";
	level.magic_box_zbarrier_state_func = &process_magic_box_zbarrier_state;
    level.custom_magic_box_do_weapon_rise = &magic_box_do_weapon_rise;
    level.custom_magic_box_weapon_wait = &magic_box_weapon_wait;
}

function __main__()
{
	level._effect["lght_marker"] = "kingslayer_kyle/s2_mystery_box_marker";
}

function process_magic_box_zbarrier_state( state )
{
	switch( state )
	{
		case "away":
			self ShowZBarrierPiece( 0 );
			self.state = "away";
			break;

		case "arriving":
			self ShowZBarrierPiece( 1 );
			self thread zm_magicbox::magic_box_arrives();
			self.state = "arriving";
			break;

		case "initial":
			self ShowZBarrierPiece( 1 );
			self thread zm_magicbox::magic_box_initial();
			thread zm_unitrigger::register_static_unitrigger( self.owner.unitrigger_stub, &zm_magicbox::magicbox_unitrigger_think );
			self.state = "initial";
			break;

		case "open":
			self ShowZBarrierPiece( 2 );
			self thread zm_magicbox::magic_box_opens();
			self thread magic_box_weapon_rise_fx();
			self PlayLoopSound( "zmb_mystrybox_lp_01_front", 3 );
			self.state = "open";
			break;

		case "close":
			self ShowZBarrierPiece( 2 );
			self thread zm_magicbox::magic_box_closes();
			self StopLoopSound( 3 );
			self.state = "close";
			break;

		case "leaving":
			self showZBarrierPiece( 1 );
			self thread zm_magicbox::magic_box_leaves();
			self StopLoopSound( 3 );
			self.state = "leaving";
			break;

		default:
			if( IsDefined( level.custom_magicbox_state_handler ) )
			{
				self [[ level.custom_magicbox_state_handler ]]( state );
			}
			break;
	}
}

function magic_box_weapon_rise_fx()
{
	self endon( "box_hacked_respin" );

	self waittill( "randomization_done" );

	util::wait_network_frame();

	while( true )
	{
		wait_time = RandomFloatRange( 1.25, 2.50 );

		if( isdefined( self.weapon_model ) && !IS_EQUAL( self.weapon_model.model, level.chest_joker_model ) )
		{
			self.weapon_model clientfield::increment( "magic_box_weapon_rise_fx" );
		}
		else
		{
			break;
		}

		wait( wait_time );
	}
}

function magic_box_do_weapon_rise()
{
	self endon( "box_hacked_respin" );

    wait( 3 );

	self SetZBarrierPieceState( 3, "closed" );
	self SetZBarrierPieceState( 4, "closed" );
	
	util::wait_network_frame();

	self ZBarrierPieceUseBoxRiseLogic( 3 );
	self ZBarrierPieceUseBoxRiseLogic( 4 );
	
	self ShowZBarrierPiece( 3 );
	self ShowZBarrierPiece( 4 );
	self SetZBarrierPieceState( 3, "opening" );
	self SetZBarrierPieceState( 4, "opening" );
	
	while( self GetZBarrierPieceState( 3 ) != "open" )
	{
		wait( 0.5 );
	}
	
	self HideZBarrierPiece( 3 );
	self HideZBarrierPiece( 4 );
}

function magic_box_weapon_wait()
{
    self endon( "box_hacked_respin" );

    wait( 3 );
}
