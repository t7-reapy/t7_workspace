#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_magicbox;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace tomb_magicbox;

#precache( "client_fx", "dlc5/tomb/fx_tomb_magicbox_on" );
#precache( "client_fx", "dlc5/tomb/fx_tomb_magicbox_off" );
#precache( "client_fx", "dlc5/tomb/fx_tomb_magicbox_open" );
#precache( "client_fx", "dlc5/tomb/fx_tomb_magicbox_leave" );
#precache( "client_fx", "dlc5/tomb/fx_tomb_magicbox_portal" );
#precache( "client_fx", "dlc5/tomb/fx_tomb_magicbox_amb_base" );
#precache( "client_fx", "dlc5/tomb/fx_tomb_magicbox_amb_slab" );
#precache( "client_fx", "dlc5/tomb/fx_tomb_magicbox_beam_tgt_left" );
#precache( "client_fx", "dlc5/tomb/fx_tomb_magicbox_beam_tgt_right" );

REGISTER_SYSTEM_EX( "tomb_magicbox", &__init__, &__main__, undefined )

function __init__()
{
	clientfield::register( "zbarrier", "tomb_magicbox_initial_fx", VERSION_SHIP, 1, "int", &tomb_magicbox_initial_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "zbarrier", "tomb_magicbox_amb_fx", VERSION_SHIP, 2, "int", &tomb_magicbox_amb_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "zbarrier", "tomb_magicbox_open_fx", VERSION_SHIP, 1, "int", &tomb_magicbox_open_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "zbarrier", "tomb_magicbox_leaving_fx", VERSION_SHIP, 1, "int", &tomb_magicbox_leaving_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );

	level._effect[ "tomb_magicbox_powered" ] 				= "dlc5/tomb/fx_tomb_magicbox_on";
	level._effect[ "tomb_magicbox_unpowered" ] 			= "dlc5/tomb/fx_tomb_magicbox_off";
	level._effect[ "tomb_magicbox_is_open" ] 				= "dlc5/tomb/fx_tomb_magicbox_open";
	level._effect[ "tomb_magicbox_is_leaving" ] 			= "dlc5/tomb/fx_tomb_magicbox_leave";
	level._effect[ "tomb_magicbox_portal" ] 				= "dlc5/tomb/fx_tomb_magicbox_portal";
	level._effect[ "tomb_magicbox_gone_ambient" ] 		= "dlc5/tomb/fx_tomb_magicbox_amb_base";
	level._effect[ "tomb_magicbox_here_ambient" ] 		= "dlc5/tomb/fx_tomb_magicbox_amb_slab";
	level._effect[ "tomb_magicbox_is_open_beam_left" ] 	= "dlc5/tomb/fx_tomb_magicbox_beam_tgt_left";
	level._effect[ "tomb_magicbox_is_open_beam_right" ] 	= "dlc5/tomb/fx_tomb_magicbox_beam_tgt_right";
}

function __main__()
{
}


function tomb_magicbox_leaving_fx(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump)
{
	if(!isdefined(self.fx_obj))
	{
		self.fx_obj = spawn(localclientnum, self.origin, "script_model");
		self.fx_obj.angles = self.angles;
		self.fx_obj setmodel("tag_origin");
	}
	if(newval == 1)
	{
		self.fx_obj.curr_leaving_fx = playfxontag(localclientnum, level._effect["tomb_magicbox_is_leaving"], self.fx_obj, "tag_origin");
	}
}

function tomb_magicbox_open_fx(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump)
{
	if(!isdefined(self.fx_obj))
	{
		self.fx_obj = util::spawn_model( localclientnum, "tag_origin", self.origin, self.angles );
		self.fx_obj.angles = self.angles;
		self.fx_obj setmodel("tag_origin");
	}
	if(!newval)
	{
		stopfx(localclientnum, self.fx_obj.curr_open_fx);
		self.fx_obj stoploopsound(1);
		self notify("magicbox_portal_finished");
	}
	else if(newval)
	{
		self.fx_obj.curr_open_fx = playfxontag(localclientnum, level._effect["tomb_magicbox_is_open"], self.fx_obj, "tag_origin");
		self.fx_obj playloopsound("zmb_hellbox_open_effect");
		self thread fx_magicbox_portal(localclientnum);
	}
}

function fx_magicbox_portal(localclientnum)
{
	wait(0.5);
	self.fx_obj.curr_portal_fx = playfxontag(localclientnum, level._effect["tomb_magicbox_portal"], self.fx_obj, "tag_origin");
	self waittill("magicbox_portal_finished");
	stopfx(localclientnum, self.fx_obj.curr_portal_fx);
}

function tomb_magicbox_initial_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
	if ( !isdefined( self.fx_obj ) )
		self.fx_obj = util::spawn_model( localclientnum, "tag_origin", self.origin, self.angles );
	
	if ( isdefined( self.fx_obj.tomb_amb_sound ) )
	{
		self.fx_obj stopLoopSound( self.fx_obj.tomb_amb_sound, 1 );
		self.fx_obj.tomb_amb_sound = undefined;
	}
	
	if ( newval )
		self.fx_obj.tomb_amb_sound = self.fx_obj playLoopSound( "zmb_hellbox_amb_low" );
	
}

function magicbox_initial_closed_fx(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump)
{
	if(!isdefined(self.fx_obj))
	{
		self.fx_obj = spawn(localclientnum, self.origin, "script_model");
		self.fx_obj.angles = self.angles;
		self.fx_obj setmodel("tag_origin");
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

function tomb_magicbox_amb_fx(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump)
{
	if(!isdefined(self.fx_obj))
	{
		self.fx_obj = spawn(localclientnum, self.origin, "script_model");
		self.fx_obj.angles = self.angles;
		self.fx_obj setmodel("tag_origin");
	}
	if(isdefined(self.fx_obj.curr_amb_fx))
	{
		stopfx(localclientnum, self.fx_obj.curr_amb_fx);
	}
	if(isdefined(self.fx_obj.curr_amb_fx_power))
	{
		stopfx(localclientnum, self.fx_obj.curr_amb_fx_power);
	}
	if(newval == 0)
	{
		self.fx_obj playloopsound("zmb_hellbox_amb_low");
		playsound(0, "zmb_hellbox_leave", self.fx_obj.origin);
		stopfx(localclientnum, self.fx_obj.curr_amb_fx);
	}
	else if (newval == 1)
	{
		self.fx_obj.curr_amb_fx_power = playFXOnTag( localclientnum, level._effect[ "tomb_magicbox_unpowered" ], self.fx_obj, "tag_origin" );
		self.fx_obj.curr_amb_fx = playFXOnTag( localclientnum, level._effect[ "tomb_magicbox_here_ambient" ], self.fx_obj, "tag_origin" );
		self.fx_obj playLoopSound( "zmb_hellbox_amb_low" );
		playSound( 0, "zmb_hellbox_arrive", self.fx_obj.origin );
	}
	else if(newval == 2)
	{
		self.fx_obj.curr_amb_fx_power = playFXOnTag( localclientnum, level._effect[ "tomb_magicbox_powered"], self.fx_obj, "tag_origin" );
		self.fx_obj.curr_amb_fx = playFXOnTag( localclientnum, level._effect[ "tomb_magicbox_here_ambient"], self.fx_obj, "tag_origin" );
		self.fx_obj playLoopSound( "zmb_hellbox_amb_high" );
		playSound( 0, "zmb_hellbox_arrive", self.fx_obj.origin );
	}
	else if (newval == 3)
	{
		self.fx_obj.curr_amb_fx_power = playFXOnTag( localclientnum, level._effect[ "tomb_magicbox_unpowered" ], self.fx_obj, "tag_origin" );
		self.fx_obj.curr_amb_fx = playFXOnTag( localclientnum, level._effect[ "tomb_magicbox_gone_ambient" ], self.fx_obj, "tag_origin" );
		self.fx_obj playLoopSound( "zmb_hellbox_amb_high" );
		playSound( 0, "zmb_hellbox_leave", self.fx_obj.origin );
	}
}

