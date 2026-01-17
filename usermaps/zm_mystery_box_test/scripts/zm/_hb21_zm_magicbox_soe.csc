#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_magicbox;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace hb21_zm_magicbox_soe;

#precache( "client_fx", "zombie/fx_weapon_box_open_zod_zmb" );
#precache( "client_fx", "zombie/fx_weapon_box_closed_zod_zmb" );

REGISTER_SYSTEM_EX( "hb21_zm_magicbox_soe", &__init__, &__main__, undefined )

function __init__()
{
	clientfield::register( "zbarrier", "soe_magicbox_initial_fx", 		VERSION_SHIP, 1, "int", &soe_magicbox_initial_fx, 		!CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "zbarrier", "soe_magicbox_amb_sound", 	VERSION_SHIP, 1, "int", &soe_magicbox_amb_sound, 	!CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "zbarrier", "soe_magicbox_open_fx", 			VERSION_SHIP, 3, "int", &soe_magicbox_open_fx, 		!CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	
	level._effect[ "soe_box_open" ] = "zombie/fx_weapon_box_open_zod_zmb";
	level._effect[ "soe_box_closed" ] = "zombie/fx_weapon_box_closed_zod_zmb";
}

function __main__()
{
}

function soe_magicbox_initial_fx( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	if ( !isDefined( self.fx_obj ) )
		self.fx_obj = util::spawn_model( n_local_client_num, "tag_origin", self.origin, self.angles );
	else
		return;
	
	if ( n_new_val )
		self.fx_obj.amb_sound = self.fx_obj playLoopSound( "zmb_hellbox_amb_low" );
	
}

function soe_magicbox_amb_sound( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	if ( !isDefined( self.fx_obj ) )
		self.fx_obj = util::spawn_model( n_local_client_num, "tag_origin", self.origin, self.angles );
	
	if ( isDefined( self.fx_obj.amb_sound ) )
	{
		self.fx_obj stopLoopSound( self.fx_obj.amb_sound, 1 );
		self.fx_obj.amb_sound = undefined;
	}
	if ( !n_new_val )
	{
		self.fx_obj.amb_sound = self.fx_obj playLoopSound( "zmb_hellbox_amb_low" );
		playSound( 0, "zmb_soe_magicbox_leave", self.fx_obj.origin );
	}
	else if ( n_new_val )
	{
		self.fx_obj.amb_sound = self.fx_obj playLoopSound( "zmb_hellbox_amb_low" );
		playSound( 0, "zmb_soe_magicbox_arrive", self.fx_obj.origin );
	}
}

function soe_magicbox_open_fx( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	if ( !isDefined( self.fx_obj ) )
		self.fx_obj = util::spawn_model( n_local_client_num, "tag_origin", self.origin, self.angles );
	
	if( !isDefined( self.open_sound ) )
		self.open_sound = util::spawn_model( n_local_client_num, "tag_origin", self.origin, self.angles );
	
	switch ( n_new_val )
	{
		case 0:
		case 3:
		{
			if ( isDefined( self.fx_obj.open_fx ) )
				stopFx( n_local_client_num, self.fx_obj.open_fx );
			
			self.fx_obj.open_fx = playFXOnTag( n_local_client_num, level._effect[ "soe_box_closed" ], self.fx_obj, "tag_origin" );
			self.open_sound stopAllLoopSounds( 1 );
			break;
		}
		case 1:
		{
			if ( isDefined( self.fx_obj.open_fx ) )
				stopFx( n_local_client_num, self.fx_obj.open_fx );
			
			self.fx_obj.open_fx = playFXOnTag( n_local_client_num, level._effect[ "soe_box_open" ], self.fx_obj, "tag_origin" );
			self.open_sound playLoopSound( "zmb_soe_magicbox_open_effect" );
			break;
		}
		case 2:
		{
			self.fx_obj delete();
			self.open_sound delete();
			break;
		}
	}
}
