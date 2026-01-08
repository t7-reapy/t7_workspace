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

#precache("vehicle", "spawner_bo3_glaive_ally_tool");
#precache("model", "wpn_t7_zmb_zod_sword2_projectile");
#precache("fx", "zombie/fx_sword_quest_egg_explo_zod_zmb");
#precache("material", "sword_hud_powerup");

REGISTER_SYSTEM("sword_powerup", &__init__, undefined)

//-----------------------------------------------------------------------------------
// setup
//-----------------------------------------------------------------------------------
function __init__()
{
	
	zombie_utility::set_zombie_var( "zombie_powerup_sword_powerup_on", false, undefined, undefined, true );
	zombie_utility::set_zombie_var( "zombie_powerup_sword_powerup_time", N_POWERUP_DEFAULT_TIME, undefined, undefined, true );

    zm_powerups::register_powerup("sword_powerup", &grab_sword);
    if(ToLower(GetDvarString("g_gametype")) != "zcleansed")
    {
        zm_powerups::add_zombie_powerup("sword_powerup", 
			"wpn_t7_zmb_zod_sword2_projectile", 
			"", 
			&func_should_drop, 
			!POWERUP_ONLY_AFFECTS_GRABBER, 
			!POWERUP_ANY_TEAM, 
			!POWERUP_ZOMBIE_GRABBABLE,
			undefined,
			"powerup_sword_powerup",
			"zombie_powerup_sword_powerup_time", 
			"zombie_powerup_sword_powerup_on");
    }
}

function grab_sword(player)
{
    player notify("sword_powerup_grabbed");
    thread give_sword_powerup(player); 
    thread notify_and_show_on_hud(player); 
}

function give_sword_powerup(player)
{
    origin = CheckNavMeshDirection(player.origin, anglesToForward(player.angles), 100, 30);
    player PlaySound("sword_powerup");
    ai = SpawnVehicle("spawner_bo3_glaive_ally_tool", origin + (0, 0, 50), player.angles);
    ai.owner = player;
    ai SetInvisibleToAll();
    ai.spawn_time = GetTime();
    ai.ignore_enemy_count = true;
    ai PlaySound("zmb_dragonshield_prj_imp");
    PlayFX("zombie/fx_sword_quest_egg_explo_zod_zmb", ai.origin);
    wait 0.5;
    ai SetVisibleToAll();
	n_wait_time = N_POWERUP_DEFAULT_TIME;
	wait n_wait_time;	
    PlayFX("zombie/fx_sword_quest_egg_explo_zod_zmb", ai.origin);
    PlaySoundAtPosition("zmb_dragonshield_prj_imp", ai.origin);
    ai Delete();
}

function notify_and_show_on_hud(player)
{
	level notify( "powerup sword_powerup_" + player.team );
	level endon( "powerup sword_powerup_" + player.team );
	
	team = player.team;
	level thread zm_powerups::show_on_hud( team, "sword_powerup" );
	level.zombie_vars[team]["zombie_sword_powerup"] = 1;	
	n_wait_time = N_POWERUP_DEFAULT_TIME;
	wait n_wait_time;	
	level.zombie_vars[team]["zombie_sword_powerup"] = 0;

	players = GetPlayers( team );
	for( i=0; i<players.size; i++ )
	{
		if( isdefined(players[i]) )
		{
			players[i] notify( "sword_powerup_over" );
		}
	}
}

function func_should_drop()
{
	return true;
}
