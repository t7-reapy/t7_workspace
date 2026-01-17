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

#namespace hb21_zm_magicbox_genesis;

REGISTER_SYSTEM_EX( "hb21_zm_magicbox_genesis", &__init__, &__main__, undefined )

function __init__()
{
	DEFAULT( level.a_box_classnames, [] );
	
	clientfield::register( "zbarrier", "genesis_magicbox_open_glow", 	VERSION_SHIP, 1, "int" );
	clientfield::register( "zbarrier", "genesis_magicbox_closed_glow", 	VERSION_SHIP, 1, "int" );

	level._effect[ "genesis_light_marker" ] = "zombie/fx_weapon_box_marker_genesis";
	
	if ( isDefined( level.a_box_classnames[ "zbarrier_zmcore_magicbox_genesis" ] ) )
		return;
		
	s_struct 										= spawnStruct();
	s_struct.ptr_show_box 					= &genesis_show_box;
	s_struct.ptr_pandora_show_func 	= &genesis_pandora_show_func;
	s_struct.ptr_pandora_fx_func 			= &genesis_pandora_fx_func;
	s_struct.ptr_chest_glowfx 				= &genesis_treasure_chest_glowfx;
	level.a_box_classnames[ "zbarrier_zmcore_magicbox_genesis" ] = s_struct;
}

function __main__()
{
}

function genesis_show_box( b_hide )
{
	if ( b_hide )
	{
	}
	else
	{
	}
}

function genesis_pandora_show_func( e_anchor, e_anchor_target, a_pieces )
{
	if ( !isDefined( self.pandora_light ) )
		self thread genesis_pandora_fx_func();
	
}

function genesis_pandora_fx_func()
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

function genesis_treasure_chest_glowfx()
{
	self clientfield::set( "genesis_magicbox_open_glow", 1 );
	self clientfield::set ("genesis_magicbox_closed_glow", 0 );
	str_ret_val = self util::waittill_any_return( "weapon_grabbed", "box_moving" );
	self clientfield::set( "genesis_magicbox_open_glow", 0 );
	if ( "box_moving" != str_ret_val )
		self clientfield::set( "genesis_magicbox_closed_glow", 1 );
	
}