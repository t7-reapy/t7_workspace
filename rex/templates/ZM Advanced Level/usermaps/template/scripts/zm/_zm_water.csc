#using scripts\codescripts\struct;
#using scripts\shared\audio_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;
#using scripts\shared\system_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#define WATER_BUBBLES	"dlc2/island/fx_plyr_swim_bubbles_body_isl"
#define WATER_DEBRIS	"water/fx_water_floating_debris_biodomes"

//#precache( "client_fx", WATER_BUBBLES );
//#precache( "client_fx", WATER_DEBRIS );

#namespace zm_water;

REGISTER_SYSTEM_EX("zm_water", &__init__, &__main__, undefined)

function __init__(){}

function __main__()
{
    callback::on_localclient_connect( &on_player_connect );
	callback::on_spawned( &on_player_spawned );

	level._effect["water_bubbles"] = WATER_BUBBLES;
	level._effect["water_debris"] = WATER_DEBRIS;
}

function on_player_connect( localclientnum )
{
	// Need this for floatie dyn models
	SetDvar( "phys_buoyancy", 1 );
	// Need this for float dead zombies
	SetDvar( "phys_ragdoll_buoyancy", 1 );
}

function on_player_spawned( localclientnum )
{
	self thread PlayerUnderWaterLogic( localclientnum );
}

function PlayerUnderWaterLogic( localclientnum )
{
	self endon( "entityshutdown" );
	self endon("death");
	
	while( true )
	{ 
		self waittill( "water_surface_underwater_begin");
		self thread PlayerUnderwaterEnter(localclientnum);
		
		self waittill( "water_surface_underwater_end" );
		self thread PlayerUnderwaterExit(localclientnum);
	}	
}

function PlayerUnderwaterEnter(localclientnum)
{
	self endon( "water_surface_underwater_end" );
	self endon( "entityshutdown" );
	self endon("death");

	while(isdefined(self))
	{
		if(self IsPlayerSwimmingUnderwater())
		{
			while(self IsPlayerSwimmingUnderwater())
			{
				self.firstperson_water_fx = PlayFXOnCamera( localClientNum, level._effect["water_bubbles"], (0,0,0), (1,0,0), (0,0,1)  );
				self.firstperson_water_fx = PlayFXOnCamera( localClientNum, level._effect["water_debris"], (0,0,0), (1,0,0), (0,0,1)  );
				wait(2);
			}
		}
		wait(2);
	}
}

function PlayerUnderwaterExit(localclientnum)
{
	self endon( "water_surface_underwater_begin" );
	self endon("death");
}