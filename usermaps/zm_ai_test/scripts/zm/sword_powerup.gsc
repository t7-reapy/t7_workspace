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
    zm_powerups::register_powerup("sword_powerup", &grab_dragon);
    if(ToLower(GetDvarString("g_gametype")) != "zcleansed")
    {
        zm_powerups::add_zombie_powerup("sword_powerup", 
			"wpn_t7_zmb_zod_sword2_projectile", 
			"", 
			&func_should_drop, 
			!POWERUP_ONLY_AFFECTS_GRABBER, 
			!POWERUP_ANY_TEAM, 
			!POWERUP_ZOMBIE_GRABBABLE/*,
			undefined,
			"sword_powerup"*/);
    }
}

function grab_dragon(player)
{
    player notify("sword_powerup_grabbed");
    thread give_dragon_powerup(player); 
}


function give_dragon_powerup( grabber)
{
    origin = CheckNavMeshDirection(grabber.origin, anglesToForward(grabber.angles), 100, 30);
    //grabber.dragon_powerup_active = true; 
    grabber PlaySound("sword_powerup");
    ai = SpawnVehicle("spawner_bo3_glaive_ally_tool", origin + (0, 0, 50), grabber.angles);
    ai.owner = grabber;
    ai SetInvisibleToAll();
    ai.spawn_time = GetTime();
    ai.ignore_enemy_count = true;
    ai PlaySound("zmb_dragonshield_prj_imp");
    PlayFX("zombie/fx_sword_quest_egg_explo_zod_zmb", ai.origin);
    wait 0.5;
    ai SetVisibleToAll();
    wait N_POWERUP_DEFAULT_TIME;
    PlayFX("zombie/fx_sword_quest_egg_explo_zod_zmb", ai.origin);
    PlaySoundAtPosition("zmb_dragonshield_prj_imp", ai.origin);
    ai Delete();
}


function wait_til_timeout(player, hud)
{
    player util::waittill_notify_or_timeout("sword_powerup_grabbed", N_POWERUP_DEFAULT_TIME);

    //player.dragon_powerup_active = false; 
    player playsound("zmb_insta_kill_loop_off");    
}

function func_should_drop()
{
	return true;
}