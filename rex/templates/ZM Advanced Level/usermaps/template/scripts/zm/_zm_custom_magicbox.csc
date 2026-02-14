#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_magicbox;
#using scripts\zm\_zm_magicbox_zod;
#using scripts\zm\_zm_magicbox_tomb;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#precache( "client_fx", "zombie/fx_weapon_box_open_glow_zmb" );
#precache( "client_fx", "zombie/fx_weapon_box_closed_glow_zmb" );

#namespace zm_custom_magicbox;

REGISTER_SYSTEM( "zm_custom_magicbox", &__init__, undefined )

function __init__()
{
	level._effect["chest_light"] = "zombie/fx_weapon_box_open_glow_zmb"; 
	level._effect["chest_light_closed"] = "zombie/fx_weapon_box_closed_glow_zmb"; 
	clientfield::register( "zbarrier", "custom_zbarrier_show_sounds", VERSION_SHIP, 1, "counter", &magicbox_show_sounds_callback, CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);
	clientfield::register( "zbarrier", "custom_zbarrier_leave_sounds", VERSION_SHIP, 1, "counter", &magicbox_leave_sounds_callback, CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);
}

function magicbox_show_sounds_callback( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump )
{
	playsound( localClientNum, "zmb_box_poof_land", self.origin  );
	playsound( localClientNum, "zmb_couch_slam", self.origin  );
	playsound( localClientNum, "zmb_box_poof", self.origin );
}

function magicbox_leave_sounds_callback( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump )
{
	playsound(localClientNum, "zmb_box_move", self.origin);
	playsound(localClientNum, "zmb_whoosh", self.origin );		
}
