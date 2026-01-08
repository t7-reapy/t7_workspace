#using scripts\codescripts\struct;
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

#precache( "fx", "zombie/fx_weapon_box_marker_genesis" );


#namespace trinket_box_custom; // <<<<< name of the custom gsc

REGISTER_SYSTEM_EX( "trinket_box_custom", &__init__, &__main__, undefined ) // <<<<< name of the custom gsc

function __init__()
{
	DEFAULT( level.a_box_classnames, [] );
	
	clientfield::register( "zbarrier", "genesis_magicbox_open_glow", 	VERSION_SHIP, 1, "int" );//leave
	clientfield::register( "zbarrier", "genesis_magicbox_closed_glow", 	VERSION_SHIP, 1, "int" );

	level._effect[ "genesis_light_marker" ] = "zombie/fx_weapon_box_marker_genesis"; //leave
	
	if ( isDefined( level.a_box_classnames[ "trinket_box" ] ) ) // <<<<<<<<<< change trinket_box

		return;
		
	trinket_box_struct 								= spawnStruct();
	trinket_box_struct.ptr_show_box 				= &trinket_box_show_box;                 // <<<<<<<< here in the custom gsc we can change the names here
	trinket_box_struct.ptr_pandora_show_func      	= &trinket_box_pandora_show_func;
	trinket_box_struct.ptr_joker_custom_movement 	= &trinket_box_joker_movement;
	trinket_box_struct.ptr_pandora_fx_func 			= &trinket_box_pandora_fx_func;
	trinket_box_struct.ptr_chest_glowfx 			= &trinket_box_treasure_chest_glowfx;
	level.a_box_classnames[ "trinket_box" ] = trinket_box_struct; //this gets all from abouve ad adds it to the struct that spawnd
}

function __main__()
{
}

function trinket_box_show_box( b_hide ) // change ww2_box to what you put ^ top for example &ww2_box_show_box; same as this function
{
	if ( b_hide )
	{
	}
	else
	{
	}
}

function trinket_box_pandora_show_func( e_anchor, e_anchor_target, a_pieces )
{
	if ( !isDefined( self.pandora_light ) )
		self thread trinket_box_pandora_fx_func();  // <<<<<<<< here in the custom gsc we can change the names here
}


function trinket_box_pandora_fx_func()
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
		playFXOnTag( level._effect[ "genesis_light_marker" ], self.pandora_light, "tag_origin" );
	
}

function trinket_box_treasure_chest_glowfx()
{
	self clientfield::set( "genesis_magicbox_open_glow", 1 );
	self clientfield::set ("genesis_magicbox_closed_glow", 0 );
	str_ret_val = self util::waittill_any_return( "weapon_grabbed", "box_moving" );
	self clientfield::set( "genesis_magicbox_open_glow", 0 );
	if ( "box_moving" != str_ret_val )
		self clientfield::set( "genesis_magicbox_closed_glow", 1 );
	
}
function trinket_box_joker_movement()
{
	v_origin = self.weapon_model.origin;
	self.weapon_model delete();
	pya = spawn( "script_model", v_origin );
	pya setModel( "p7_zm_moo_styrofoam_pyramd" );
	pya.angles = self.angles;
	pya rotateYaw( 180, .5, .5 );
	wait .5;
	level notify( "weapon_fly_away_start" );
	wait 2;
	if ( isDefined( pya ) )
	{
		v_fly_away = self.origin + anglesToUp( self.angles ) * 500;
		pya moveTo( v_fly_away, 4, 3 );
	}
	//if ( isDefined( self.weapon_model_dw ) )
	//{
	//	v_fly_away = self.origin + anglesToUp( self.angles ) * 500;
	//	self.weapon_model_dw moveTo( v_fly_away, 4, 3 );
	//}
	pya waittill( "movedone");
	self.weapon_model_dw moveTo( self.origin, 1 );
	pya waittill( "movedone");
	pya delete();

	self notify( "box_moving" );
	level notify( "weapon_fly_away_end" );
}