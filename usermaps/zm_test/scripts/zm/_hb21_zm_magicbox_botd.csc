#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_magicbox;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace hb21_zm_magicbox_botd;

#precache( "client_fx", "harry/motd_mysterybox/fx_motd_mystery_box_use" );
#precache( "client_fx", "harry/motd_mysterybox/fx_motd_mystery_box_loop" );

REGISTER_SYSTEM_EX( "hb21_zm_magicbox_botd", &__init__, &__main__, undefined )

function __init__()
{
	clientfield::register( "zbarrier", "motd_magicbox_open_fx", 				VERSION_SHIP, 1, "int", &motd_magicbox_open_fx, 		!CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "zbarrier", "motd_magicbox_amb_fx", 				VERSION_SHIP, 2, "int", &motd_magicbox_amb_fx, 			!CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	
	level._effect[ "motd_box_open" ] = "harry/motd_mysterybox/fx_motd_mystery_box_use";
	level._effect[ "motd_box_amb" ] = "harry/motd_mysterybox/fx_motd_mystery_box_loop";
}

function __main__()
{
}

function motd_magicbox_open_fx( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	self thread zm_magicbox::magicbox_glow_callback( n_local_client_num, n_new_val, level._effect[ "motd_box_open" ] );
}

function motd_magicbox_amb_fx( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	util::waitforclient(n_local_client_num);

	if ( !isDefined( self.fx_obj ) )
		self.fx_obj = util::spawn_model( n_local_client_num, "tag_origin", self.origin, self.angles );
	
	if ( isDefined( self.fx_obj.curr_amb_fx ) )
	{
		stopFx( n_local_client_num, self.fx_obj.curr_amb_fx );
		self.fx_obj.curr_amb_fx = undefined;
	}
	if ( isDefined( self.fx_obj.curr_amb_sound ) )
	{
		self.fx_obj stopLoopSound( self.fx_obj.curr_amb_sound, 1 );
		self.fx_obj.curr_amb_sound = undefined;
	}

	if ( n_new_val == 1 )
		self.fx_obj.curr_amb_sound = self.fx_obj playLoopSound( "zmb_motd_magicbox_loop_low" );
	else if ( n_new_val == 2 )
	{
		self.fx_obj.curr_amb_fx = playFXOnTag( n_local_client_num, level._effect[ "motd_box_amb" ], self.fx_obj, "tag_origin" );
		self.fx_obj.curr_amb_sound = self.fx_obj playLoopSound( "zmb_motd_magicbox_loop_high" );
	}
}
