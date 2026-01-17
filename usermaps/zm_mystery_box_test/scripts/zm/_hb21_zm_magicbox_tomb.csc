#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_magicbox;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace hb21_zm_magicbox_tomb;

#precache( "client_fx", "dlc5/tomb/fx_tomb_magicbox_on" );
#precache( "client_fx", "dlc5/tomb/fx_tomb_magicbox_off" );
#precache( "client_fx", "dlc5/tomb/fx_tomb_magicbox_amb_base" );
#precache( "client_fx", "dlc5/tomb/fx_tomb_magicbox_amb_slab" );
#precache( "client_fx", "dlc5/tomb/fx_tomb_magicbox_open" );
#precache( "client_fx", "dlc5/tomb/fx_tomb_magicbox_beam_tgt_left" );
#precache( "client_fx", "dlc5/tomb/fx_tomb_magicbox_beam_tgt_right" );
#precache( "client_fx", "dlc5/tomb/fx_tomb_magicbox_portal" );
#precache( "client_fx", "dlc5/tomb/fx_tomb_magicbox_leave" );

REGISTER_SYSTEM_EX( "hb21_zm_magicbox_tomb", &__init__, &__main__, undefined )

function __init__()
{
	clientfield::register( "zbarrier", "tomb_magicbox_initial_fx", 		VERSION_SHIP, 1, "int", &tomb_magicbox_initial_fx, 	!CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "zbarrier", "tomb_magicbox_amb_fx", 		VERSION_SHIP, 2, "int", &tomb_magicbox_amb_fx, 		!CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "zbarrier", "tomb_magicbox_open_fx", 		VERSION_SHIP, 1, "int", &tomb_magicbox_open_fx, 	!CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "zbarrier", "tomb_magicbox_leaving_fx", 	VERSION_SHIP, 1, "int", &tomb_magicbox_leaving_fx, 	!CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	
	level._effect[ "box_powered" ] 					= "dlc5/tomb/fx_tomb_magicbox_on";
	level._effect[ "box_unpowered" ] 				= "dlc5/tomb/fx_tomb_magicbox_off";
	level._effect[ "box_gone_ambient" ] 			= "dlc5/tomb/fx_tomb_magicbox_amb_base";
	level._effect[ "box_here_ambient" ] 			= "dlc5/tomb/fx_tomb_magicbox_amb_slab";
	level._effect[ "box_is_open" ] 					= "dlc5/tomb/fx_tomb_magicbox_open";
	level._effect[ "box_is_open_beam_left" ] 	= "dlc5/tomb/fx_tomb_magicbox_beam_tgt_left";
	level._effect[ "box_is_open_beam_right" ] 	= "dlc5/tomb/fx_tomb_magicbox_beam_tgt_right";
	level._effect[ "box_portal" ] 						= "dlc5/tomb/fx_tomb_magicbox_portal";
	level._effect[ "box_is_leaving" ] 					= "dlc5/tomb/fx_tomb_magicbox_leave";
}

function __main__()
{
}

function tomb_magicbox_leaving_fx( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	if ( !isDefined( self.fx_obj ) )
		self.fx_obj = util::spawn_model( n_local_client_num, "tag_origin", self.origin, self.angles );
	
	if ( isDefined( self.fx_obj.curr_leaving_fx ) )
	{
		stopFx( n_local_client_num, self.fx_obj.curr_leaving_fx );
		self.fx_obj.curr_leaving_fx = undefined;
	}
	
	if ( n_new_val )
		self.fx_obj.curr_leaving_fx = PlayFXOnTag( n_local_client_num, level._effect[ "box_is_leaving" ], self.fx_obj, "tag_origin" );
	
}

function tomb_magicbox_open_fx( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	if ( !isDefined( self.fx_obj ) )
		self.fx_obj = util::spawn_model( n_local_client_num, "tag_origin", self.origin, self.angles );
	// if ( !isDefined( self.fx_obj_2 ) )
		// self.fx_obj_2 = util::spawn_model( n_local_client_num, "tag_origin", self.origin, self.angles );
	if ( !n_new_val )
	{
		stopFx( n_local_client_num, self.fx_obj.curr_open_fx );
		self.fx_obj stopLoopSound( self.fx_obj.open_sound, 1 );
		self notify( "magicbox_portal_finished" );
	}
	else if ( n_new_val )
	{
		self.fx_obj.curr_open_fx = playFXOnTag( n_local_client_num, level._effect[ "box_is_open" ], self.fx_obj, "tag_origin" );
		self.fx_obj.open_sound = self.fx_obj playLoopSound(" zmb_hellbox_open_effect" );
		self thread fx_magicbox_portal( n_local_client_num );
	}
}

function fx_magicbox_portal( n_local_client_num )
{
	wait .5;
	self.fx_obj.curr_portal_fx = playFXOnTag( n_local_client_num, level._effect [ "box_portal" ], self.fx_obj, "tag_origin" );
	self waittill( "magicbox_portal_finished" );
	stopFx( n_local_client_num, self.fx_obj.curr_portal_fx );
}

function tomb_magicbox_initial_fx( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	if ( !isDefined( self.fx_obj ) )
		self.fx_obj = util::spawn_model( n_local_client_num, "tag_origin", self.origin, self.angles );
	
	if ( isDefined( self.fx_obj.tomb_amb_sound ) )
	{
		self.fx_obj stopLoopSound( self.fx_obj.tomb_amb_sound, 1 );
		self.fx_obj.tomb_amb_sound = undefined;
	}
	
	if ( n_new_val )
		self.fx_obj.tomb_amb_sound = self.fx_obj playLoopSound( "zmb_hellbox_amb_low" );
	
}

function tomb_magicbox_amb_fx( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	if ( !isDefined( self.fx_obj ) )
		self.fx_obj = util::spawn_model( n_local_client_num, "tag_origin", self.origin, self.angles );
	
	if ( isDefined(self.fx_obj.tomb_amb_sound ) )
	{
		self.fx_obj stopLoopSound( self.fx_obj.tomb_amb_sound, 1 );
		self.fx_obj.tomb_amb_sound = undefined;
	}
	if ( isDefined( self.fx_obj.curr_amb_fx ) )
	{
		stopFx( n_local_client_num, self.fx_obj.curr_amb_fx );
		self.fx_obj.curr_amb_fx = undefined;
	}
	if ( isDefined(self.fx_obj.curr_amb_fx_power ) )
	{
		stopFx( n_local_client_num, self.fx_obj.curr_amb_fx_power );
		self.fx_obj.curr_amb_fx_power = undefined;
	}
	if ( n_new_val == 0 )
	{
		self.fx_obj.tomb_amb_sound = self.fx_obj playLoopSound( "zmb_hellbox_amb_low" );
		playSound( 0, "zmb_hellbox_leave", self.fx_obj.origin );
		stopFx( n_local_client_num, self.fx_obj.curr_amb_fx );
	}
	else if ( n_new_val == 1 )
	{
		self.fx_obj.curr_amb_fx_power = playFXOnTag( n_local_client_num, level._effect[ "box_unpowered" ], self.fx_obj, "tag_origin" );
		self.fx_obj.curr_amb_fx = playFXOnTag( n_local_client_num, level._effect[ "box_here_ambient" ], self.fx_obj, "tag_origin" );
		self.fx_obj.tomb_amb_sound = self.fx_obj playLoopSound( "zmb_hellbox_amb_low" );
		playSound( 0, "zmb_hellbox_arrive", self.fx_obj.origin );
	}
	else if( n_new_val == 2)
	{
		self.fx_obj.curr_amb_fx_power = playFXOnTag( n_local_client_num, level._effect[ "box_powered"], self.fx_obj, "tag_origin" );
		self.fx_obj.curr_amb_fx = playFXOnTag( n_local_client_num, level._effect[ "box_here_ambient"], self.fx_obj, "tag_origin" );
		self.fx_obj.tomb_amb_sound = self.fx_obj playLoopSound( "zmb_hellbox_amb_high" );
		playSound( 0, "zmb_hellbox_arrive", self.fx_obj.origin );
	}
	else if ( n_new_val == 3 )
	{
		self.fx_obj.curr_amb_fx_power = playFXOnTag( n_local_client_num, level._effect[ "box_unpowered" ], self.fx_obj, "tag_origin" );
		self.fx_obj.curr_amb_fx = playFXOnTag( n_local_client_num, level._effect[ "box_gone_ambient" ], self.fx_obj, "tag_origin" );
		self.fx_obj.tomb_amb_sound = self.fx_obj playLoopSound( "zmb_hellbox_amb_high" );
		playSound( 0, "zmb_hellbox_leave", self.fx_obj.origin );
	}
}