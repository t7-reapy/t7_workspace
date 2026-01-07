#using scripts\codescripts\struct;

#using scripts\shared\aat_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\laststand_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#using scripts\shared\ai\zombie_utility;

#using scripts\zm\_zm_blockers;
#using scripts\zm\_zm_pers_upgrades;
#using scripts\zm\_zm_pers_upgrades_functions;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_equipment;
#using scripts\zm\_zm_pack_a_punch_util;
#using scripts\zm\_zm_power;
#using scripts\shared\flag_shared;
#using scripts\shared\array_shared;

#insert scripts\zm\_zm_powerups.gsh;
#insert scripts\zm\_zm_utility.gsh;

#precache( "vehicle", "spawner_bo3_glaive_ally_tool");
#precache( "model", "wpn_t7_zmb_zod_sword2_projectile" );
#precache( "fx", "zombie/fx_sword_quest_egg_explo_zod_zmb");
#precache( "material", "sword_hud_powerup");

REGISTER_SYSTEM( "sword_powerup", &__init__, undefined )

//-----------------------------------------------------------------------------------
// setup
//-----------------------------------------------------------------------------------
function __init__()
{
	zm_powerups::register_powerup( "sword_powerup", &grab_dragon );
	if( ToLower( GetDvarString( "g_gametype" ) ) != "zcleansed" )
	{
		zm_powerups::add_zombie_powerup( "sword_powerup", "wpn_t7_zmb_zod_sword2_projectile", "", &func_should_drop, !POWERUP_ONLY_AFFECTS_GRABBER, !POWERUP_ANY_TEAM, !POWERUP_ZOMBIE_GRABBABLE );
	}
}

function grab_dragon( player )
{
	player notify( "sword_powerup_grabbed" ); 
	players = GetPlayers(); 
	thread give_dragon_powerup( player); 
}


function give_dragon_powerup(  grabber )
{
	
	grabber thread add_powerup_hud( "sword_hud_powerup", N_POWERUP_DEFAULT_TIME ); 
	origin = CheckNavMeshDirection(grabber.origin,anglesToForward( grabber.angles ),100, 30);
	//grabber.dragon_powerup_active = true; 
	grabber PlaySound("sword_powerup");
	ai = SpawnVehicle("spawner_bo3_glaive_ally_tool",origin + (0,0,50),grabber.angles);
	ai.owner = grabber;
	ai SetInvisibleToAll();
	ai.spawn_time = GetTime();
	ai.ignore_enemy_count = true;
	ai PlaySound("zmb_dragonshield_prj_imp");
	PlayFX("zombie/fx_sword_quest_egg_explo_zod_zmb",ai.origin);
	wait 0.5;
	ai SetVisibleToAll();
	wait N_POWERUP_DEFAULT_TIME;
	PlayFX("zombie/fx_sword_quest_egg_explo_zod_zmb",ai.origin);
	PlaySoundAtPosition("zmb_dragonshield_prj_imp",ai.origin);
	ai Delete();
}


function wait_til_timeout( player, hud )
{
	player endon( "delete_hud_sword" );
	if( !isDefined(hud.sound_ent) )
	{
		hud.sound_ent = Spawn("script_origin", (0,0,0));
		hud.sound_ent playloopsound ("zmb_insta_kill_loop");
		hud.sound_ent thread wait_for_another_grab(); 
	}
	//wait N_POWERUP_DEFAULT_TIME;
	player util::waittill_notify_or_timeout("sword_powerup_grabbed", N_POWERUP_DEFAULT_TIME);

	//player.dragon_powerup_active = false; 
	player playsound("zmb_insta_kill_loop_off"); 
	if( isDefined(hud.sound_ent) )
	{
		hud.sound_ent StopLoopSound(2);
		hud.sound_ent delete(); 
	}
	player remove_powerup_hud( "sword_hud_powerup" ); 
	
}

function wait_for_another_grab()
{
	self waittill( "sword_powerup_grabbed" ); 
	self StopLoopSound(2); 
	self delete(); 
}

function add_powerup_hud( powerup, timer )
{
	if ( !isDefined( self.powerup_hud ) )
		self.powerup_hud = [];
	
	self notify( "delete_hud_sword" );
	self remove_powerup_hud( "sword_hud_powerup" );

	self endon( "disconnect" );
	hud = NewClientHudElem( self );
	hud.powerup = powerup;
	hud.foreground = true;
	hud.hidewheninmenu = false;
	hud.alignX = "center";
	hud.alignY = "bottom";
	hud.horzAlign = "center";
	hud.vertAlign = "bottom";
	hud.x = hud.x;
	hud.y = hud.y - 50;
	hud.alpha = 1;
	hud SetShader( powerup , 64, 64 );
	hud scaleOverTime( .5, 32, 32 );
	hud.time = timer;
	hud thread harrybo21_blink_powerup_hud();
	thread wait_til_timeout( self, hud ); 
	
	self.powerup_hud[ powerup ] = hud;
	
	a_keys = GetArrayKeys( self.powerup_hud );
	for ( i = 0; i < a_keys.size; i++ )
	 	self.powerup_hud[ a_keys[i] ] thread move_hud( .5, 0 - ( 24 * ( self.powerup_hud.size ) ) + ( i * 37.5 ) + 25, self.powerup_hud[ a_keys[i] ].y );
	
	return false; // powerup is not already active
}

function move_hud( time, x, y )
{
	self moveOverTime( time );
	self.x = x;
	self.y = y;
}

function harrybo21_blink_powerup_hud()
{
	self endon( "delete_hud_sword" );
	self endon( "stop_fade" );
	while( isDefined( self ) )
	{
		if ( self.time >= 20 )
		{
			self.alpha = 1; 
			wait 1;
			self.time--;
			continue;
		}
		fade_time = 1;
		if ( self.time < 10 )
			fade_time = .5;
		if ( self.time < 5 )
			fade_time = .25;
			
		self fadeOverTime( fade_time );
		self.alpha = !self.alpha;
		
		wait( fade_time );
	}
}

function remove_powerup_hud( powerup )
{
	self.powerup_hud[ powerup ] destroy();
	self.powerup_hud[ powerup ] notify( "stop_fade" );
	self.powerup_hud[ powerup ] fadeOverTime( .2 );
	self.alpha = 0;
	wait .2;
	self.powerup_hud[ powerup ] delete();
	self.powerup_hud[ powerup ] = undefined;
	self.powerup_hud = array::remove_index( self.powerup_hud, self.powerup_hud[ powerup ], true );
	
	a_keys = GetArrayKeys( self.powerup_hud );
	for ( i = 0; i < a_keys.size; i++ )
	 	self.powerup_hud[ a_keys[i] ] thread move_hud( .5, 0 - ( 24 * ( self.powerup_hud.size ) ) + ( i * 37.5 ) + 25, self.powerup_hud[ a_keys[i] ].y );
}
function func_should_drop()
{
	return true;
}