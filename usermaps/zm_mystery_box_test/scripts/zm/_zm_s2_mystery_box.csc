#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#precache( "client_fx", "kingslayer_kyle/s2_mystery_box_weapon_rise" );
#precache( "client_fx", "steam/fx_steam_slow" );
#precache( "client_fx", "fog/fx_fog_ground_100x100" );

REGISTER_SYSTEM_EX( "zm_s2_mystery_box", &__init__, &__main__, undefined )

function __init__()
{
    clientfield::register( "scriptmover", "magic_box_weapon_rise_fx", VERSION_SHIP, 1, "counter", &magic_box_weapon_rise_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );

    level._effect["s2_mystery_box_weapon_rise"] = "kingslayer_kyle/s2_mystery_box_weapon_rise";
}

function __main__()
{
	level._effect["chest_light"] = "steam/fx_steam_slow";
	level._effect["chest_light_closed"] = "fog/fx_fog_ground_100x100";
}

function magic_box_weapon_rise_fx( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump )
{
	play_fx_on_ent( localClientNum, level._effect["s2_mystery_box_weapon_rise"], "tag_origin" );
}

function play_fx_on_ent( localClientNum, fxPath, tagName )
{
	self endon( "entityshutdown" );
	
	self util::waittill_dobj( localClientNum );

	if( isdefined( self.fx ) )
	{
		StopFx( localClientNum, self.fx );
		self.fx = undefined;
	}

	self.fx = PlayFXOnTag( localClientNum, fxPath, self, tagName );
}
