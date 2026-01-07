#using scripts\codescripts\struct;

#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\filter_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\vehicle_shared;
#using scripts\shared\ai\margwa;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_glaive.gsh;

#namespace glaive;

REGISTER_SYSTEM( "glaive", &__init__, undefined )

function __init__()
{	
	clientfield::register( "vehicle", GLAIVE_BLOOD_FX, VERSION_DLC3, 1, "int", &glaiveBloodFxHandler, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
}

function private glaiveBloodFxHandler( localClientNum, oldValue, newValue, bNewEnt, bInitialSnap, fieldName, wasDemoJump )
{	
	if ( IsDefined( self.bloodFxHandle ) )
	{
		StopFX( localClientNum, self.bloodFxHandle );
		self.bloodFxHandle = undefined;
	}
	
	settings = struct::get_script_bundle( "vehiclecustomsettings", "glaivesettings" );
	
	if( IsDefined( settings ) )
	{
		if( newValue )
		{
			self.bloodFxHandle = PlayFXOnTag( localClientNum, settings.weakspotfx, self, "j_spineupper" );
		}
	}
}