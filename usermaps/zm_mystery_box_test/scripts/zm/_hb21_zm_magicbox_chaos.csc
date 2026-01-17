#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_magicbox;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace hb21_zm_magicbox_chaos;

#precache( "client_fx", "harry/chaos_box/fx_chaos_box_eye_blue" );
#precache( "client_fx", "harry/chaos_box/fx_chaos_box_open_glow" );
#precache( "client_fx", "harry/chaos_box/fx_chaos_box_skull" );
#precache( "client_fx", "harry/chaos_box/fx_chaos_box_blood_drip" );
#precache( "client_fx", "harry/chaos_box/fx_chaos_box_leave" );
#precache( "client_fx", "harry/chaos_box/fx_chaos_box_arrive" );
#precache( "client_fx", "harry/chaos_box/fx_chaos_box_closed_glow" );
#precache( "client_fx", "harry/chaos_box/fx_chaos_box_eye_blue_no_lf" );
#precache( "client_fx", "harry/chaos_box/fx_chaos_box_debris_glow" );
#precache( "client_fx", "harry/chaos_box/fx_chaos_box_lid_glow" );
#precache( "client_fx", "harry/chaos_box/fx_chaos_box_lid_drips" );

REGISTER_SYSTEM_EX( "hb21_zm_magicbox_chaos", &__init__, &__main__, undefined )

function __init__()
{
	clientfield::register( "zbarrier", "chaos_magicbox_amb_fx", 				VERSION_SHIP, 2, "int", &chaos_magicbox_ambient_fx, 					!CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "zbarrier", "chaos_magicbox_debris_amb_fx", 	VERSION_SHIP, 1, "int", &chaos_magicbox_debris_ambient_fx, 		!CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "zbarrier", "chaos_magicbox_open_fx", 				VERSION_SHIP, 1, "int", &chaos_magicbox_open_glow_callback, 		!CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "zbarrier", "chaos_magicbox_closed_fx", 			VERSION_SHIP, 1, "int", &chaos_magicbox_closed_glow_callback, 	!CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "zbarrier", "chaos_magicbox_leave_fx", 				VERSION_SHIP, 1, "int", &chaos_magicbox_leave_fx, 						!CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "zbarrier", "chaos_magicbox_arrive_fx", 			VERSION_SHIP, 1, "int", &chaos_magicbox_arrive_fx, 						!CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "zbarrier", "chaos_magicbox_skull_fx", 				VERSION_SHIP, 1, "int", &chaos_magicbox_skull_fx, 						!CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	
	level._effect[ "chaos_box_blood" ] 				= "harry/chaos_box/fx_chaos_box_blood_drip";
	level._effect[ "chaos_box_blue_eyes" ] 		= "harry/chaos_box/fx_chaos_box_eye_blue_no_lf";
	level._effect[ "chaos_box_blue_lf_eyes" ] 	= "harry/chaos_box/fx_chaos_box_eye_blue";
	level._effect[ "chaos_box_skull_eyes" ] 		= "harry/chaos_box/fx_chaos_box_skull";
	level._effect[ "chaos_box_leave" ] 				= "harry/chaos_box/fx_chaos_box_leave";
	level._effect[ "chaos_box_arrive" ] 				= "harry/chaos_box/fx_chaos_box_arrive";
	level._effect[ "chaos_box_debris" ] 				= "harry/chaos_box/fx_chaos_box_debris_glow";
	level._effect[ "chaos_box_lid" ] 					= "harry/chaos_box/fx_chaos_box_lid_glow";
	level._effect[ "chaos_box_lid_drips" ] 			= "harry/chaos_box/fx_chaos_box_lid_drips";
	level._effect[ "chaos_chest_light" ] 				= "harry/chaos_box/fx_chaos_box_open_glow";
	level._effect[ "chaos_chest_light_closed" ] 	= "harry/chaos_box/fx_chaos_box_closed_glow";
}

function __main__()
{
}

function chaos_magicbox_closed_glow_callback( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	self thread zm_magicbox::magicbox_glow_callback( n_local_client_num, n_new_val, level._effect[ "chaos_chest_light_closed" ] );
}

function chaos_magicbox_open_glow_callback( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	if( !isDefined( self.open_sound ) )
		self.open_sound = util::spawn_model( n_local_client_num, "tag_origin", self.origin, self.angles );
	
	if ( n_new_val )
		self.open_sound.snd = self.open_sound playLoopSound( "zmb_chaos_magicbox_open_effect" );
	else
	{
		self.open_sound stopLoopSound( self.open_sound.snd, 1 );
		self.open_sound.snd = undefined;
	}
	self thread zm_magicbox::magicbox_glow_callback( n_local_client_num, n_new_val, level._effect[ "chaos_chest_light" ] );
}

function chaos_magicbox_skull_fx( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	if ( isDefined( self.fx_chaos_skull ) )
		stopFx( n_local_client_num, self.fx_chaos_skull );
	
	if ( IS_TRUE( n_new_val ) )
	{
		e_model = self zBarrierGetPiece( 3 );
		self.fx_chaos_skull = playFXOnTag( n_local_client_num, level._effect[ "chaos_box_skull_eyes" ], e_model, "tag_skull_jnt" );
	}
}

function chaos_magicbox_arrive_fx( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	if ( !isDefined( self.fx_obj ) )
		self.fx_obj = util::spawn_model( n_local_client_num, "tag_origin", self.origin, self.angles );
	
	if ( isDefined( self.fx_obj.fx_chaos_arrive ) )
	{
		stopFx( n_local_client_num, self.fx_obj.fx_chaos_arrive );
		self.fx_obj.fx_chaos_arrive = undefined;
	}
	if ( IS_TRUE( n_new_val ) )
	{
		self.fx_obj.fx_chaos_arrive = playFXOnTag( n_local_client_num, level._effect[ "chaos_box_arrive" ], self.fx_obj, "tag_origin" );
		playSound( 0, "zmb_chaos_magicbox_arriving", self.fx_obj.origin );
	}
}

function chaos_magicbox_leave_fx( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	if ( !isDefined( self.fx_obj ) )
		self.fx_obj = util::spawn_model( n_local_client_num, "tag_origin", self.origin, self.angles );
	
	if ( isDefined( self.fx_obj.fx_chaos_leave ) )
	{
		stopFx( n_local_client_num, self.fx_obj.fx_chaos_leave );
		self.fx_obj.fx_chaos_leave = undefined;
	}
	if ( IS_TRUE( n_new_val ) )
	{
		self.fx_obj.fx_chaos_leave = playFXOnTag( n_local_client_num, level._effect[ "chaos_box_leave" ], self.fx_obj, "tag_origin" );
		playSound( 0, "zmb_chaos_magicbox_leaving", self.fx_obj.origin );
	}
}

function chaos_box_play_eye_fx( n_local_client_num, n_model_index, b_lensflare = 0 )
{
	e_model = self zBarrierGetPiece( n_model_index );
	
	for ( i = 1; i < 19; i++ )
		self.fx_chaos_box[ self.fx_chaos_box.size ] = playFXOnTag( n_local_client_num, level._effect[ ( b_lensflare ? "chaos_box_blue_lf_eyes" : "chaos_box_blue_eyes" ) ], e_model, "tag_fx_eyeglow_" + ( ( i > 9 ) ? "" : "0" ) + i );
	
	self.fx_chaos_box[ self.fx_chaos_box.size ] = playFXOnTag( n_local_client_num, level._effect[ ( b_lensflare ? "chaos_box_blue_lf_eyes" : "chaos_box_blue_eyes" ) ], e_model, "tag_fx_eyeglow_lid01" );
	self.fx_chaos_box[ self.fx_chaos_box.size ] = playFXOnTag( n_local_client_num, level._effect[ ( b_lensflare ? "chaos_box_blue_lf_eyes" : "chaos_box_blue_eyes" ) ], e_model, "tag_fx_eyeglow_lid02" );
}
 
 function chaos_box_play_blood( n_local_client_num, n_model_index, b_bottom = 0 )
 {
	 e_model = self zBarrierGetPiece( n_model_index );
	for ( i = 1; i < 5; i++ )
		self.fx_chaos_box[ self.fx_chaos_box.size ] = playFXOnTag( n_local_client_num, level._effect[ "chaos_box_blood" ], e_model, "tag_fx_mouth_0" + i );
	
	if ( !b_bottom )
		return;
		
	for ( i = 5; i < 9; i++ )
		self.fx_chaos_box[ self.fx_chaos_box.size ] = playFXOnTag( n_local_client_num, level._effect[ "chaos_box_blood" ], e_model, "tag_fx_mouth_0" + i );
	
 }
 
function chaos_magicbox_debris_ambient_fx( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	if ( !isdefined( self.fx_obj ) )
		self.fx_obj = util::spawn_model( n_local_client_num, "tag_origin", self.origin, self.angles );
	
	if ( isDefined( self.fx_obj.fx_chaos_debris ) )
	{
		stopfx( n_local_client_num, self.fx_obj.fx_chaos_leave );
		self.fx_obj.fx_chaos_debris = undefined;
	}
	
	if ( n_new_val )
		self.fx_obj.fx_chaos_debris = playFXOnTag( n_local_client_num, level._effect[ "chaos_box_debris" ], self zBarrierGetPiece( 0 ), "tag_origin" );
	
}

function chaos_magicbox_ambient_fx( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	if ( !isDefined( self.fx_chaos_box ) )
		self.fx_chaos_box = [];
	
	if ( !isDefined( self.fx_obj ) )
		self.fx_obj = util::spawn_model( n_local_client_num, "tag_origin", self.origin, self.angles );
	
	if ( isDefined( self.fx_chaos_box ) && isArray( self.fx_chaos_box ) && self.fx_chaos_box.size > 0 )
	{
		for ( i = 0; i < self.fx_chaos_box.size; i++ )
			stopFx( n_local_client_num, self.fx_chaos_box[ i ] );
		
		self.fx_chaos_box = [];
	}
	
	self.fx_chaos_box[ self.fx_chaos_box.size ] = playFXOnTag(n_local_client_num, level._effect[ "chaos_box_lid" ], self zBarrierGetPiece( 1 ), "j_lid" );
	self.fx_chaos_box[ self.fx_chaos_box.size ] = playFXOnTag(n_local_client_num, level._effect[ "chaos_box_lid" ], self zBarrierGetPiece( 2 ), "j_lid" );
	self.fx_chaos_box[ self.fx_chaos_box.size ] = playFXOnTag(n_local_client_num, level._effect[ "chaos_box_lid" ], self zBarrierGetPiece( 5 ), "j_lid" );

	if ( n_new_val == 1 )
	{
		chaos_box_play_eye_fx( n_local_client_num, 1 );
		chaos_box_play_eye_fx( n_local_client_num, 2 );
		chaos_box_play_eye_fx( n_local_client_num, 5 );
		chaos_box_play_blood( n_local_client_num, 1, 1 );
		chaos_box_play_blood( n_local_client_num, 2, 1 );
		chaos_box_play_blood( n_local_client_num, 5, 1 );
	}
	if ( n_new_val == 2 )
	{
		self.fx_chaos_box[ self.fx_chaos_box.size ] = playFXOnTag(n_local_client_num, level._effect[ "chaos_box_lid_drips" ], self zBarrierGetPiece( 5 ), "j_lid" );
		chaos_box_play_eye_fx( n_local_client_num, 1, 1 );
		chaos_box_play_eye_fx( n_local_client_num, 2, 1 );
		chaos_box_play_eye_fx( n_local_client_num, 5, 1 );
		chaos_box_play_blood( n_local_client_num, 1 );
		chaos_box_play_blood( n_local_client_num, 2 );
		chaos_box_play_blood( n_local_client_num, 5 );
	}	
}