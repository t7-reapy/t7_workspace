#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\visionset_mgr_shared;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace zm_ai_sonic;

REGISTER_SYSTEM_EX( "zm_ai_sonic", &__init__, undefined, undefined )

function __init__()
{
	visionset_mgr::register_overlay_info_style_blur( "zm_ai_screecher_blur", VERSION_SHIP, 15, .1, .25, 20 );
	init_clientfields();
}

function init_clientfields()
{
	clientfield::register( "actor", "issonic", VERSION_SHIP, 1, "int", &sonic_zombie_callback, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
}

function sonic_zombie_callback( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
	if ( newval )
		self thread sonic_ambient_sounds( localclientnum );
	else
		self thread sonic_stop_ambient_sounds( localclientnum );
	
}

function sonic_ambient_sounds( client_num )
{
	if ( client_num != 0 )
		return;
	
	self playLoopSound( "evt_sonic_ambient_loop", 1 );
}

function sonic_stop_ambient_sounds( client_num )
{
	self notify( "stop_sounds" );
}