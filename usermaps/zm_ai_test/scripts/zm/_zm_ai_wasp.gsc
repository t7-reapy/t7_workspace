#using scripts\codescripts\struct;

#using scripts\shared\aat_shared;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\system_shared;
#using scripts\shared\trigger_shared;
#using scripts\shared\util_shared;
#using scripts\shared\vehicle_shared;
#using scripts\shared\vehicles\_parasite;
#using scripts\shared\clientfield_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\shared\ai_shared;
#using scripts\shared\vehicles\_parasite;
#using scripts\shared\vehicles\_wasp;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\weapons\grapple.gsh;

#using scripts\zm\_util;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_net;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_utility;
// #using scripts\zm\zm_zod_idgun_quest;

#using scripts\shared\ai\zombie_utility;

#insert scripts\shared\archetype_shared\archetype_shared.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\shared\aat_zm.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_ai_wasp.gsh;
// #insert scripts\zm\zm_zod_craftables.gsh;

#precache("fx", "zombie/fx_parasite_spawn_buildup_zod_zmb");

#define N_MAX_WASPS 16    // Max number that can be alive at any one time (mainly limited by networking concerns)
#define N_MAX_WASPS_PER_PLAYER 5    // Max alive per player in the game

#define N_SWARM_SIZE 1

// Number of wasps to spawn = N_NUM_WASPS_PER_ROUND * (a scalar if more than one player)
#define N_NUM_WASPS_PER_ROUND 10
#define N_WASP_PLAYER_SCALAR 0.75

#define N_SPAWN_HEIGHT_MIN 60    // Minimum ground height to spawn at
#define N_WASP_HEALTH_INCREASE 50    // Amount to increase Wasp health
#define N_WASP_HEALTH_MAX 1600    // Maximum health
#define N_WASP_KILL_POINTS 70    // Points per kill

#namespace zm_ai_wasp;

function init()
{
    zm_audio::musicState_Create("parasite_start", 3, "zod_parasite_start");
    zm_audio::musicState_Create("parasite_over", 3, "zod_parasite_end");
    
    level.wasp_enabled = true;
    level.wasp_rounds_enabled = false;
    level.wasp_round_count = 1;

    level.wasp_spawners = [];

    level.a_wasp_priority_targets = [];

    level flag::init("wasp_round");
    level flag::init("wasp_round_in_progress");
    
    level.melee_range_sav  = GetDvarString("ai_meleeRange");
    level.melee_width_sav = GetDvarString("ai_meleeWidth");
    level.melee_height_sav  = GetDvarString("ai_meleeHeight");

    DEFAULT(level.vsmgr_prio_overlay_zm_wasp_round, ZM_WASP_VISION_OVERLAY_PRIORITY);

    clientfield::register("toplayer", "parasite_round_fx", VERSION_SHIP, 1, "counter");
    clientfield::register("toplayer", PARASITE_ROUND_RING_FX, VERSION_SHIP, 1, "counter");
    
    visionset_mgr::register_info("visionset", ZM_WASP_ROUND_VISIONSET, VERSION_SHIP, level.vsmgr_prio_overlay_zm_wasp_round, ZM_WASP_VISION_LERP_COUNT, false, &visionset_mgr::ramp_in_out_thread, false);

    level._effect["lightning_wasp_spawn"] = "zombie/fx_parasite_spawn_buildup_zod_zmb";

    callback::on_connect(&watch_player_melee_events);
    
    // AAT IMMUNITIES
    level thread aat::register_immunity(ZM_AAT_BLAST_FURNACE_NAME, ARCHETYPE_PARASITE, true, true, true);
    level thread aat::register_immunity(ZM_AAT_DEAD_WIRE_NAME, ARCHETYPE_PARASITE, true, true, true);
    level thread aat::register_immunity(ZM_AAT_FIRE_WORKS_NAME, ARCHETYPE_PARASITE, true, true, true);
    level thread aat::register_immunity(ZM_AAT_THUNDER_WALL_NAME, ARCHETYPE_PARASITE, true, true, true);
    level thread aat::register_immunity(ZM_AAT_TURNED_NAME, ARCHETYPE_PARASITE, true, true, true);
    
    // Init wasp targets - mainly for testing purposes.
    //    If you spawn a wasp without having a wasp round, you'll get SREs on hunted_by.
    wasp_spawner_init();
}

function wasp_spawner_init()
{
    level.wasp_spawners = getEntArray("zombie_wasp_spawner", "script_noteworthy"); 
    
    if(level.wasp_spawners.size == 0)
    {
        return;
    }
    
    for(i = 0; i < level.wasp_spawners.size; i++)
    {
        if (zm_spawner::is_spawner_targeted_by_blocker(level.wasp_spawners[i]))
        {
            level.wasp_spawners[i].is_enabled = false;
        }
        else
        {
            level.wasp_spawners[i].is_enabled = true;
            level.wasp_spawners[i].script_forcespawn = true;
        }
    }

    assert(level.wasp_spawners.size > 0);
    level.wasp_health = 100;

    vehicle::add_main_callback("spawner_bo3_parasite_enemy_tool", &wasp_init);
    vehicle::add_main_callback("spawner_bo3_parasite_elite_enemy_tool", &wasp_init);
}

function get_current_wasp_count()
{
    wasps = GetEntArray("zombie_wasp", "targetname");
    num_alive_wasps = wasps.size;
    foreach(wasp in wasps)
    {
        if(!IsAlive(wasp))
        {
            num_alive_wasps--;
        }
    }
    return num_alive_wasps;
}

function parasite_round_fx()
{
    foreach (player in level.players)
    {
        player clientfield::increment_to_player("parasite_round_fx");
        player clientfield::increment_to_player(PARASITE_ROUND_RING_FX);
    }
}

function show_hit_marker()  // self = player
{
    if (IsDefined(self) && IsDefined(self.hud_damagefeedback))
    {
        self.hud_damagefeedback SetShader("damage_feedback", 24, 48);
        self.hud_damagefeedback.alpha = 1;
        self.hud_damagefeedback FadeOverTime(1);
        self.hud_damagefeedback.alpha = 0;
    }    
}

function waspDamage(inflictor, attacker, damage, dFlags, mod, weapon, point, dir, hitLoc, offsetTime, boneIndex, modelIndex)
{
    if(isdefined(attacker))
    {
        attacker show_hit_marker();
    }
    return damage;
}

// check if there's space and a place to spawn a wasp, and the spawning flag is set
function ready_to_spawn_wasp()
{
    n_wasps_alive = get_current_wasp_count();

    b_wasp_count_at_max = n_wasps_alive >= N_MAX_WASPS;
    b_wasp_count_per_player_at_max = n_wasps_alive >= level.players.size * N_MAX_WASPS_PER_PLAYER;

    if(b_wasp_count_at_max || b_wasp_count_per_player_at_max || !(level flag::get("spawn_zombies")))
    {
        return false;
    }
    return true;
}

//
//    Spawn in fx and initialization
// - ai.favoriteenemy = the wasps target
function wasp_spawn_init(ai, origin, should_spawn_fx = true)
{
    ai endon("death");
    
    ai SetInvisibleToAll();
    
    if (isdefined(origin))
    {
        v_origin = origin;
    }
    else
    {
        v_origin = ai.origin;
    }
    
    if(should_spawn_fx)
    {
        PlayFx(level._effect["lightning_wasp_spawn"], v_origin);
    }

    //    playsoundatposition("zmb_hellhound_prespawn", v_origin);
    wait(1.5);
    //    playsoundatposition("zmb_hellhound_bolt", v_origin);

    Earthquake(0.3, 0.5, v_origin, 256);
    //PlayRumbleOnPosition("explosion_generic", v_origin);
    //    playsoundatposition("zmb_hellhound_spawn", v_origin);

    // face the enemy
    if (IsDefined(ai.favoriteenemy))
        angle = VectorToAngles(ai.favoriteenemy.origin - v_origin);
    else
        angle = ai.angles;
    angles = (ai.angles[0], angle[1], ai.angles[2]);
        
    //DCS 080714: this should work for an ai vehicle but currently doesn't. Support should be added soon.
    //ai ForceTeleport(v_origin, angles);
    ai.origin = v_origin;
    ai.angles = angles;

    assert(isdefined(ai), "Ent isn't defined.");
    assert(IsAlive(ai), "Ent is dead.");

    ai thread zombie_setup_attack_properties_wasp();

    if(isdefined(level._wasp_death_cb))
    {
        ai callback::add_callback(#"on_vehicle_killed", level._wasp_death_cb);
    }
    
    ai SetVisibleToAll();
    ai.ignoreme = false; // don't let attack wasp give chase until it is visible
    ai notify("visible");
}

#define WASP_SPAWN_DIST_MIN 400
#define WASP_SPAWN_DIST_MAX 600
    
function wasp_spawn_logic(favorite_enemy)
{
	wasp_locs = level.zm_loc_types["wasp_location"];

	if (wasp_locs.size == 0)
	{
		IPrintLnBold("NO WASP LOCATION FOUND IN CURRENT ZONES");
		return undefined;
	}

	return wasp_locs[RandomIntRange(0, wasp_locs.size - 1)];
}

function get_favorite_enemy()
{
    // First check if we have a priority target
    if(level.a_wasp_priority_targets.size > 0)
    {
        e_enemy = level.a_wasp_priority_targets[0];
        if(isdefined(e_enemy))
        {
            ArrayRemoveValue(level.a_wasp_priority_targets, e_enemy);
            return(e_enemy);
        }
    }

    // Check for custom wasp spawner selection
    if (isdefined(level.fn_custom_wasp_favourate_enemy))
    {
        e_enemy = [[level.fn_custom_wasp_favourate_enemy]]();
        return(e_enemy);
    }
    
    target = parasite::get_parasite_enemy();
    
    return target;
}

function wasp_init()
{
    self.targetname = "zombie_wasp";
    self.script_noteworthy = undefined;
    self.animname = "zombie_wasp";         
    self.ignoreall = true; 
    self.ignoreme = true; // don't let attack wasp give chase until the wolf is visible
    self.allowdeath = true;             // allows death during animscripted calls
    self.allowpain = false;
    self.no_gib = true; //gibbing disabled for now
    self.is_zombie = true;             // needed for melee.gsc in the animscripts
    // out both legs and then the only allowed stance should be prone.
    self.gibbed = false; 
    self.head_gibbed = false;
    self.default_goalheight = 40;
    self.ignore_inert = true;    
    self.no_eye_glow = true;

    self.lightning_chain_immune = true;

    self.holdfire            = false;

    //    self.disableArrivals = true; 
    //    self.disableExits = true; 
    self.grenadeawareness = 0;
    self.badplaceawareness = 0;

    self.ignoreSuppression = true;     
    self.suppressionThreshold = 1; 
    self.noDodgeMove = true; 
    self.dontShootWhileMoving = true;
    self.pathenemylookahead = 0;

    self.badplaceawareness = 0;
    self.chatInitialized = false;
    self.missingLegs = false;
    self.isdog = false;
    self.teslafxtag = "tag_origin";

    self.grapple_type = GRAPPLE_TYPE_PULLENTIN;
    self SetGrapplableType(self.grapple_type);

    self.team = level.zombie_team;
    
    self.sword_kill_power = ZM_WASP_SWORD_KILL_POWER;
    
    parasite::parasite_initialize();
    /*
    self AllowPitchAngle(1);
    self setPitchOrient();
    self setAvoidanceMask("avoid none");

    self PushActors(true);
    */
    health_multiplier = 1.0;
    if (GetDvarString("scr_wasp_health_walk_multiplier") != "")
    {
        health_multiplier = GetDvarFloat("scr_wasp_health_walk_multiplier");
    }

    self.maxhealth = int(level.wasp_health * health_multiplier);
    if(IsDefined(level.a_zombie_respawn_health[self.archetype]) && level.a_zombie_respawn_health[self.archetype].size > 0)
    {
        self.health = level.a_zombie_respawn_health[self.archetype][0];
        ArrayRemoveValue(level.a_zombie_respawn_health[self.archetype], level.a_zombie_respawn_health[self.archetype][0]);        
    }
    else
    {
        self.health = int(level.wasp_health * health_multiplier);
    }

    self thread wasp_run_think();
    self thread watch_player_melee();

    self SetInvisibleToAll();

    self thread wasp_death();
    self thread wasp_cleanup_failsafe();
    
    level thread zm_spawner::zombie_death_event(self); 
    self thread zm_spawner::enemy_death_detection();

    self.thundergun_knockdown_func =&wasp_thundergun_knockdown;
    
    self zm_spawner::zombie_history("zombie_wasp_spawn_init -> Spawned = " + self.origin);
    
    if (isdefined(level.achievement_monitor_func))
    {
        self [[level.achievement_monitor_func]]();
    }
}


function wasp_thundergun_knockdown(e_player, gib)
{
    self endon("death");

    n_damage = Int(self.maxhealth * 0.5);
    self DoDamage(n_damage, self.origin, e_player);
}

#define N_WASP_NOT_MOVED_TIMEOUT 20
#define N_WASP_MAX_LIFE_TIMEOUT 150
#define N_WASP_HAS_MOVE_DIST 100
#define N_MSEC 1000

// Wasp failsafe cleanup conditions
function wasp_cleanup_failsafe()
{
    self endon("death");

    n_wasp_created_time = GetTime();
    
    n_check_time = n_wasp_created_time;
    v_check_position = self.origin;

    while(true)
    {
        n_current_time = GetTime();
        
        if(IS_TRUE(level.bzm_worldPaused))
        {
            n_check_time = n_current_time; //reset the stuck time when world is paused
            wait 1;
            continue;
        }
        
        // If the wasp has moved he is not stuck, so reset the position to check against
        n_dist = Distance(v_check_position, self.origin);
        if(n_dist > N_WASP_HAS_MOVE_DIST)
        {
            n_check_time = n_current_time;
            v_check_position = self.origin;
        }

        // Failsafe 1: If the wasp hasn't significantly moved for a while, kill him
        else
        {
            n_delta_time = (n_current_time - n_check_time) / N_MSEC;
            if(n_delta_time >= N_WASP_NOT_MOVED_TIMEOUT)
            {
                break;
            }
        }

        // Failsafe 2: If the wasp has been alive for too long, kill him
        n_delta_time = (n_current_time - n_wasp_created_time) / N_MSEC;
        if(n_delta_time >= N_WASP_MAX_LIFE_TIMEOUT)
        {
            break;
        }

        wait 1;
    }

    self DoDamage(self.health + 100, self.origin);
}

function wasp_death()
{
    self waittill("death", attacker);
    
    if (get_current_wasp_count() == 0 && level.zombie_total == 0)
    {
        // Can be overridded for mixed AI rounds, in this case the last AI may be a wasp or raps etc...
        if((!isdefined(level.zm_ai_round_over) || [[level.zm_ai_round_over]]()))
        {
            level.last_ai_origin = self.origin;
            level notify("last_ai_down", self);
        }
    }
    
    // score
    if(IsPlayer(attacker))
    {
        if(IS_TRUE(attacker.on_train))
        {
            attacker notify("wasp_train_kill");
        }

        attacker zm_score::player_add_points("death_wasp", N_WASP_KILL_POINTS);    // points awarded
        
        if(isdefined(level.hero_power_update))
        {
            [[level.hero_power_update]](attacker, self);
        }
        
        if(RandomIntRange(0,100) >= 80)
        {
            attacker zm_audio::create_and_play_dialog("kill", "hellhound");
        }
        
        //stats
        attacker zm_stats::increment_client_stat("zwasp_killed");
        attacker zm_stats::increment_player_stat("zwasp_killed");

    }

    // switch to inflictor when SP DoDamage supports it
    if(isdefined(attacker) && isai(attacker))
    {
        attacker notify("killed", self);
    }

    // sound
    self stoploopsound();
}


// this is where zombies go into attack mode, and need different attributes set up
function zombie_setup_attack_properties_wasp()
{
    self zm_spawner::zombie_history("zombie_setup_attack_properties()");
    
    self thread wasp_behind_audio();

    // allows zombie to attack again
    self.ignoreall = false; 

    //self.pathEnemyFightDist = 64;
    self.meleeAttackDist = 64;

    // turn off transition anims
    self.disableArrivals = true; 
    self.disableExits = true;
        
    if(level.wasp_round_count == 2)
    {
        self ai::set_behavior_attribute("firing_rate", "medium");
    }
    else if(level.wasp_round_count > 2)
    {
        self ai::set_behavior_attribute("firing_rate", "fast");
    }
}


//COLLIN'S Audio Scripts
function stop_wasp_sound_on_death()
{
    self waittill("death");
    self stopsounds();
}

function wasp_behind_audio()
{
    self thread stop_wasp_sound_on_death();

    self endon("death");
    self util::waittill_any("wasp_running", "wasp_combat");
    
    //self PlaySound("zmb_hellhound_vocals_close");
    wait(3);

    while(1)
    {
        players = GetPlayers();
        for(i=0;i<players.size;i++)
        {
            waspAngle = AngleClamp180(vectorToAngles(self.origin - players[i].origin)[1] - players[i].angles[1]);
        
            if(isAlive(players[i]) && !isdefined(players[i].revivetrigger))
            {
                if ((abs(waspAngle) > 90) && distance2d(self.origin,players[i].origin) > 100)
                {
                    //self playsound("zmb_hellhound_vocals_close");
                    wait(3);
                }
            }
        }
        
        wait(.75);
    }
}


//
//    Allows wasp to be spawned independent of the round spawning
/@
"Name: special_wasp_spawn(<n_to_spawn>, <spawn_point>, <radius> , <half-height>)"
"Summary: Allows wasp to be spawned independent of the round spawning. Can return spawned AI or boolean."
"Module: zm_ai_wasp"
"MandatoryArg: <spawn_point> - position where parasite will be spawned"    
"OptionalArg: <n_to_spawn> - Number to spawn, if left undefined, 1 will spawn."
"OptionalArg: <radius> - Radius horizontally that the parasite can spawn in from the spawn_point.  Defaults to 32 units"
"OptionalArg: <half_height> - Vertical offset that the parasite can spawn in from the spawn_point. Defaults to 32 units"
"OptionalArg: <b_non_round> - If true, parasite will not count to completing a parasite round, nor will it drop Xenomatter"
"OptionalArg: <spawn_fx> - Whether to use the parasite spawn fx or not. Defaults to true"
"OptionalArg: <b_return_ai> - If true, returns the wasp entity. Defaults to true"    
"OptionalArg: <spawner_override> - Specify a spawner to use instead of the default level wasp spawner.  Defaults to undefined"    
"Example: self zm_ai_wasp::special_wasp_spawn(s_temp, 1);"
"SPMP: Zombie"
@/
function special_wasp_spawn(n_to_spawn = 1, spawn_point, n_radius = 32, n_half_height = 32, b_non_round, spawn_fx = true, b_return_ai = true, spawner_override = undefined)
{
    wasp = GetEntArray("zombie_wasp", "targetname");

    if (isdefined(wasp) && wasp.size >= 9)
    {
        return false;
    }
    
    count = 0;
    while (count < n_to_spawn)
    {
        //update the player array.
        players = GetPlayers();
        favorite_enemy = get_favorite_enemy();
        spawn_enemy = favorite_enemy;
        if(!IsDefined(spawn_enemy))
        {
            spawn_enemy = players[0];
        }

        // Overrides standard parasite spawning
        if (isdefined(level.wasp_spawn_func))
        {
            spawn_point = [[level.wasp_spawn_func]](spawn_enemy);
        }
        
        // Rarely spawn_point will be undefined
        while (!isdefined(spawn_point))
        {
            if (!isdefined(spawn_point))
            {
                spawn_point = wasp_spawn_logic(spawn_enemy);
            }
            
            if (isdefined(spawn_point))
            {
                break;
            }
            
            wait(0.05);
        }
        
        spawner = array::random(level.wasp_spawners);

        if(isDefined(spawner_override))
        {
            spawner = spawner_override;
        }
            
        ai = zombie_utility::spawn_zombie(spawner);
        
        v_spawn_origin = spawn_point.origin;
            
        if (isdefined(ai))
        {
            // just try to path strait to a nearby position on the path
            queryResult = PositionQuery_Source_Navigation(v_spawn_origin, 0, n_radius, n_half_height, 15, "navvolume_small");
            if(queryResult.data.size)
            {
                point = queryResult.data[randomint(queryResult.data.size)];    
                v_spawn_origin = point.origin;
            }
            
            ai parasite::set_parasite_enemy(favorite_enemy);
            ai.does_not_count_to_round = b_non_round;
            level thread wasp_spawn_init(ai, v_spawn_origin, spawn_fx);
            count++;
        }

        wait level.zombie_vars["zombie_spawn_delay"];
    }

    if (b_return_ai)
    {
        return ai;
    }
    
    return true;
}

function wasp_run_think()
{
    self endon("death");

    // these should go back in when the stalking stuff is put back in, the visible check will do for now
    //self util::waittill_any("wasp_running", "wasp_combat");
    //self playsound("zwasp_close");
    self waittill("visible");
    
    // decrease health
    if (self.health > level.wasp_health)
    {
        self.maxhealth = level.wasp_health;
        self.health = level.wasp_health;
    }
    
    //Check to see if the enemy is not valid anymore
    while(1)
    {
        if(!zm_utility::is_player_valid(self.favoriteenemy))
        {
            //We are targetting an invalid player - select another one
            //self.favoriteenemy = get_favorite_enemy();
        }
        wait(0.2);
    }
}

#define MELEE_RANGE_SQ (72 * 72)
#define MELEE_RANGE_Z  (64)
#define MELEE_VIEW_DOT 0.5

function watch_player_melee()
{
    self endon("death");
    self waittill("visible");

    while(IsDefined(self))
    {
        level waittill("player_melee", player, weapon);

        peye = player GetEye(); 
        dist2 = Distance2DSquared(peye, self.origin);
        if (dist2 > MELEE_RANGE_SQ)
            continue;

        if (abs(peye[2] - self.origin[2]) > MELEE_RANGE_Z)
            continue;
                 
        pfwd = player GetWeaponForwardDir();
        tome = self.origin - peye; 
        tome = VectorNormalize(tome);
        dot = VectorDot(pfwd, tome);
        if (dot < MELEE_VIEW_DOT)
            continue;

        damage = 150; 
        if (IsDefined(weapon))
            damage = weapon.meleedamage;
        
        self DoDamage(damage, peye, player, player, "none", "MOD_MELEE", 0, weapon);
    }
}

function watch_player_melee_events()
{
    self endon("disconnect");
    for (;;)
    {
        self waittill("weapon_melee", weapon);
        level notify("player_melee", self, weapon);
    }
}
