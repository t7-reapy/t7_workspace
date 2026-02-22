#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_magicbox;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace zod_magicbox;

#precache( "client_fx", "zombie/fx_weapon_box_open_zod_zmb" );
#precache( "client_fx", "zombie/fx_weapon_box_closed_zod_zmb" );

REGISTER_SYSTEM_EX( "zod_magicbox", &init, undefined, undefined )

function init()
{
	level._effect["zod_box_open"] = "zombie/fx_weapon_box_open_zod_zmb";
	level._effect["zod_box_closed"] = "zombie/fx_weapon_box_closed_zod_zmb";
	clientfield::register("zbarrier", "zod_magicbox_initial_fx", VERSION_SHIP, 1, "int", &zod_magicbox_initial_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register("zbarrier", "zod_magicbox_amb_sound", VERSION_SHIP, 1, "int", &zod_magicbox_amb_sound, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register("zbarrier", "zod_magicbox_open_fx", VERSION_SHIP, 3, "int", &zod_magicbox_open_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
}

function zod_magicbox_open_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump )
{
	if ( !isdefined( self.fx_obj ) )
		self.fx_obj = util::spawn_model( localclientnum, "tag_origin", self.origin, self.angles );
	
	if( !isdefined( self.open_sound ) )
		self.open_sound = util::spawn_model( localclientnum, "tag_origin", self.origin, self.angles );
	
	switch ( newval )
	{
		case 0:
		case 3:
		{
			if ( isdefined( self.fx_obj.open_fx ) )
				stopFx( localclientnum, self.fx_obj.open_fx );
			
			self.fx_obj.open_fx = playFXOnTag( localclientnum, level._effect[ "zod_box_closed" ], self.fx_obj, "tag_origin" );
			self.open_sound stopAllLoopSounds( 1 );
			break;
		}
		case 1:
		{
			if ( isdefined( self.fx_obj.open_fx ) )
				stopFx( localclientnum, self.fx_obj.open_fx );
			
			self.fx_obj.open_fx = playFXOnTag( localclientnum, level._effect[ "zod_box_open" ], self.fx_obj, "tag_origin" );
			self.open_sound playLoopSound( "zmb_zod_box_open" );
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

function zod_magicbox_initial_fx(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
	if(!isdefined(self.fx_obj))
	{
		self.fx_obj = util::spawn_model(localclientnum, "tag_origin", self.origin, self.angles);
	}
	else
	{
		return;
	}
	if(newval == 1)
	{
		self.fx_obj playloopsound("zmb_hellbox_amb_low");
	}
}

function zod_magicbox_amb_sound(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
	if(!isdefined(self.fx_obj))
	{
		self.fx_obj = util::spawn_model(localclientnum, "tag_origin", self.origin, self.angles);
	}
	if(isdefined(self.fx_obj.curr_amb_fx))
	{
		stopfx(localclientnum, self.fx_obj.curr_amb_fx);
	}
	if(newval == 0)
	{
		self.fx_obj playloopsound("zmb_hellbox_amb_low");
		playsound(0, "zmb_zod_box_leave", self.fx_obj.origin);
	}
	else if(newval == 1)
	{
		self.fx_obj playloopsound("zmb_hellbox_amb_low");
		playsound(0, "zmb_zod_box_arrive", self.fx_obj.origin);
	}
}

