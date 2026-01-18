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
    
    zombie_utility::set_zombie_var("zombie_powerup_sword_powerup_on", false, undefined, undefined, false);
    zombie_utility::set_zombie_var("zombie_powerup_sword_powerup_time", N_POWERUP_DEFAULT_TIME, undefined, undefined, false);

    zm_powerups::register_powerup("sword_powerup", &grab_sword);
    if(ToLower(GetDvarString("g_gametype")) != "zcleansed")
    {
        zm_powerups::add_zombie_powerup("sword_powerup", 
            "wpn_t7_zmb_zod_sword2_projectile", 
            "", 
            &func_should_drop, 
            POWERUP_ONLY_AFFECTS_GRABBER, 
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
    player thread give_sword_powerup(); 
    player thread notify_and_show_on_hud(); 
}

function give_sword_powerup() // self == player
{
    player = self;
    if (IS_TRUE(player.solo_powerups_running["sword_powerup"]))
    {
        return;
    }

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

    while (self.zombie_vars["zombie_powerup_sword_powerup_time"] > 0)
    {
        WAIT_SERVER_FRAME;
    } 

    PlayFX("zombie/fx_sword_quest_egg_explo_zod_zmb", ai.origin);
    PlaySoundAtPosition("zmb_dragonshield_prj_imp", ai.origin);
    ai Delete();
}

function notify_and_show_on_hud() // self == player
{
    team = self.team;
    level notify("powerup sword_powerup_" + team);
    level endon("powerup sword_powerup_" + team);

    self thread show_on_hud("sword_powerup");
}

function func_should_drop()
{
    return true;
}

function show_on_hud(str_powerup) // self == player
{
    self endon ("disconnect");
    
    str_index_on   = "zombie_powerup_" + str_powerup + "_on";
    str_index_time = "zombie_powerup_" + str_powerup + "_time";
    n_wait_time = N_POWERUP_DEFAULT_TIME;

    self.zombie_vars[str_index_on] = true;
    self.zombie_vars[str_index_time] = n_wait_time;
    level.zombie_vars[self.team]["zombie_" + str_powerup] = true;   
    self._show_solo_hud = true;

    self thread time_remaining_on_powerup(str_powerup);
}

function time_remaining_on_powerup(str_powerup) // self == player
{
    if (!IsArray(self.solo_powerups_running))
    {
        self.solo_powerups_running = [];
    }

    if (IS_TRUE(self.solo_powerups_running[str_powerup]))
    {
        return;
    }
    else
    {
        self.solo_powerups_running[str_powerup] = true;
    }
    

    str_index_on   = "zombie_powerup_" + str_powerup + "_on";
    str_index_time = "zombie_powerup_" + str_powerup + "_time";
    str_sound_loop = "zmb_" + str_powerup + "_loop";
    str_sound_off  = "zmb_" + str_powerup + "_loop_off";
    
    temp_ent = Spawn("script_origin", (0,0,0));
    temp_ent PlayLoopSound (str_sound_loop);
    
    while (self.zombie_vars[str_index_time] >= 0)
    {
        WAIT_SERVER_FRAME;
        self.zombie_vars[str_index_time] = self.zombie_vars[str_index_time] - 0.05;
    }
    
    GetPlayers()[0] PlaySoundToTeam(str_sound_off, self.team);

    temp_ent StopLoopSound(2);
    temp_ent Delete();

    self.zombie_vars[str_index_on] = false;
    self.zombie_vars[str_index_time] = 0;
    level.zombie_vars[self.team]["zombie_" + str_powerup] = false;   
    self._show_solo_hud = false;
    self.solo_powerups_running[str_powerup] = false;
    self notify(str_powerup + "_over");
}