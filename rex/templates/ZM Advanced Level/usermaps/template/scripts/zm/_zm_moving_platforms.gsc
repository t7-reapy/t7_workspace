#using scripts\shared\system_shared; 
#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\compass;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\_zm_utility.gsh;

#using scripts\zm\_load;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_zonemgr;

#using scripts\shared\ai\zombie_utility;
#using scripts\shared\animation_shared;
#using scripts\shared\ai\systems\blackboard;
#using scripts\shared\ai\blackboard_vehicle;
#using scripts\shared\vehicle_shared;
#using scripts\zm\_zm_blockers;
#using scripts\zm\_zm_score;

#using_animtree( "generic" );

#define PLATFORM_SPEED 5
#define PLATFORM_ACC 2
#define HOVERING_SPEED 5

#define SLOWDOWN_DEST 5
#define SLOWDOWN_NEAR_DEST 3
#define SLOWDOWN_CURVE 7
#define SLOWDOWN_LOW 3
#define SLOWDOWN_MED 6

#namespace zm_moving_platforms;

function autoexec moving_platforms()
{
	system::register("zm_moving_platforms", &init_platforms, undefined, undefined);
}

function init_platforms()
{
	platforms = GetVehicleArray("moving_platform", "targetname");

	hovering_platforms = GetVehicleArray("hovering_platform", "targetname");

	level waittill("all_players_connected");

	wait 10;

	foreach(hovering_platform in hovering_platforms)
	{	
		hovering_platform thread setup_hovering_platform();

		wait 4;
	}

	foreach(platform in platforms)
	{	
		platform thread setup_platform();

		wait 4;
	}

}

function setup_platform()
{
	self useanimtree( #animtree );
	blackboard::CreateBlackBoardForEntity( self );
	self Blackboard::RegisterVehicleBlackBoardAttributes();
	self setmovingplatformenabled( 1 );
	self.supportsanimscripted = 1;
	self SetCanDamage(0);
    self SetMovingPlatformEnabled(1);
    self SetVehMaxSpeed( 25 );

	self thread move_platform();

	brushes = GetEntArray(self.script_string, "targetname");
	brush = ArrayGetClosest(self.origin, brushes);
	brush EnableLinkTo();
	brush LinkTo(self, "tag_origin");

	level waittill("end_game");

	self SetSpeed(0, 2, 2);
	wait 7;
	self Delete();
}

function move_platform()
{
	level endon("end_game");

    n_path_start = GetVehicleNode( self.target, "targetname" );

    self DrivePath(n_path_start);
	self SetSpeed(PLATFORM_SPEED, 1);
} 

function setup_hovering_platform()
{
	self useanimtree( #animtree );
	blackboard::CreateBlackBoardForEntity( self );
	self Blackboard::RegisterVehicleBlackBoardAttributes();
	self SetMovingPlatformEnabled( 1 );
	self SetCanDamage(0);
	self SetVehMaxSpeed( 25 );
	self.supportsanimscripted = 1;

	self thread move_hovering_platform();

	brushes = GetEntArray(self.script_string, "targetname");
	brush = ArrayGetClosest(self.origin, brushes);
	brush EnableLinkTo();
	brush LinkTo(self, "tag_origin");

	level waittill("end_game");

	self SetSpeed(0, 2, 2);
	wait 7;
	self Delete();
}

function move_hovering_platform()
{
    level endon("end_game");

    b_path_start = GetVehicleNode( self.target, "targetname" );

	while(1)
	{
		if( IsDefined( b_path_start ) )
    	{
			self DisconnectPaths(0);
			self SetSpeedImmediate(0);
			self AttachPath(b_path_start);
    		self DrivePath(b_path_start, false);
    		self SetSpeed(HOVERING_SPEED, 1);

    	    self waittill( "reached_node" );
    	    nextpoint = GetVehicleNode( "nextpoint", "targetname" );
    	    self SetSpeedImmediate(0);
    	    self DisconnectPaths(0);
    	    self AttachPath(nextpoint);
    	    self DrivePath(nextpoint, false);
    	    self SetSpeed(HOVERING_SPEED, 1);
		}
		self waittill( "reached_node" ); 
	}
}