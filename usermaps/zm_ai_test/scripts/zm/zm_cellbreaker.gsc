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
#using scripts\shared\clientfield_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\shared\ai_shared;

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
//#using scripts\zm\zm_zod_idgun_quest;

#using scripts\shared\ai\zombie_utility;

#insert scripts\shared\archetype_shared\archetype_shared.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\shared\aat_zm.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\shared\ai\systems\animation_state_machine.gsh;
#insert scripts\shared\ai\systems\behavior.gsh;
#insert scripts\shared\ai\systems\behavior_tree.gsh;
#insert scripts\shared\ai\systems\blackboard.gsh;

#using scripts\shared\ai\systems\animation_state_machine_utility;
#using scripts\shared\ai\systems\animation_state_machine_notetracks;
#using scripts\shared\ai\systems\animation_state_machine_mocomp;
#using scripts\shared\ai\archetype_utility;
#using scripts\shared\ai\systems\behavior_tree_utility;
#using scripts\shared\ai\systems\blackboard;
#using scripts\shared\ai\systems\debug;
#using scripts\shared\ai\systems\gib;
#using scripts\shared\ai\archetype_mocomps_utility;
#using scripts\shared\ai\systems\ai_interface;
#using scripts\shared\scene_shared;

#using scripts\zm\_zm_score;
#using scripts\zm\_zm_zonemgr;
#insert scripts\zm\zm_cellbreaker.gsh;

#precache("model", "c_zom_cellbreaker_helmet");
#precache("fx", "custom/AI/cellbreaker_spawn");
#precache("fx", "custom/AI/cellbreaker_death");

REGISTER_SYSTEM("zm_cellbreaker", &init, undefined)
#namespace zm_cellbreaker;

function init()
{
    //BT_REGISTER_API("brutusTargetService", &brutusTargetService); //not used
    BT_REGISTER_API("brutusBoardService", &brutusBoardService);
    BT_REGISTER_API("brutusTeargasService", &brutusTeargasService);

    BT_REGISTER_API("brutusshouldturnberserk", &brutusshouldturnberserk);
    BT_REGISTER_API("brutusplayedberserkintro", &brutusplayedberserkintro);

    BT_REGISTER_API("brutusshouldbreakboard", &brutusshouldbreakboard);
    BT_REGISTER_API("brutusboardsmash", &brutusboardsmash);

    BT_REGISTER_API("brutusshouldDoGasAttack", &brutusshouldDoGasAttack);
    BT_REGISTER_API("brutusplayedGasAttack", &brutusplayedGasAttack);

    BT_REGISTER_API("brutusshouldThrowGas", &brutusshouldThrowGas);
    BT_REGISTER_API("brutusplayedThrowGas", &brutusplayedThrowGas);

    BT_REGISTER_API("brutusshouldwait", &brutusshouldwait);

    ASM_REGISTER_MOCOMP("mocomp_teleport_traversal@cellbreaker", &mocompBrutusTeleportTraversalInit, undefined, undefined);

    ASM_REGISTER_NOTETRACK_HANDLER("fire", &melee_track);
    ASM_REGISTER_NOTETRACK_HANDLER("grenade_drop", &drop_teargas);
    ASM_REGISTER_NOTETRACK_HANDLER("yeet_nade", &throw_teargas);

    spawner::add_archetype_spawn_function("cellbreaker", &zombie_utility::zombieSpawnSetup);
    spawner::add_archetype_spawn_function("cellbreaker", &brutusSpawnSetup);

    clientfield::register("actor", "brutus_fx", VERSION_SHIP, 2, "int");
    clientfield::register("actor", "brutus_lamp_fx", VERSION_SHIP, 1, "int");
    clientfield::register("scriptmover", "brutus_tp_fx", VERSION_SHIP, 1, "int");

    aat::register_immunity(ZM_AAT_BLAST_FURNACE_NAME,"cellbreaker",1,1,1);
    aat::register_immunity(ZM_AAT_DEAD_WIRE_NAME,"cellbreaker",1,1,1);
    aat::register_immunity(ZM_AAT_FIRE_WORKS_NAME,"cellbreaker",1,1,1);
    aat::register_immunity(ZM_AAT_THUNDER_WALL_NAME,"cellbreaker",1,1,1);
    aat::register_immunity(ZM_AAT_TURNED_NAME,"cellbreaker",1,1,1);

    level.cellbreaker_dont_use_tear_gas = 0;
    if(struct::get_array("cellbreaker_gas_spot", "targetname").size < 1 && !DROP_GAS_ANYWHERE)
    {
        level.cellbreaker_dont_use_tear_gas = 1;
    }

    level waittill("initial_blackscreen_passed");

    barricades = struct::get_array("exterior_goal", "targetname");
    level.brutus_barricade_spots = array();

    foreach(windows in barricades)
    {
        structs = struct::get_array(windows.target, "targetname");
        ArrayInsert(level.brutus_barricade_spots, structs[0], 0);
    }

    thread setup_autospawn();
}

/* region Behavior Tree callbacks */

function brutusBoardService(entity)
{
    if(struct::get_array("exterior_goal", "targetname").size < 1)
    {
        return false;
    }

    closest_board = ArrayGetClosest(entity.origin, level.brutus_barricade_spots);

    //closest_exterior_goal = ArrayGetClosest(closest_board.origin,struct::get_array("exterior_goal", "targetname"));

    zbarriers = array();
    foreach(bar in GetZBarrierArray())
    {
        if(bar IsZBarrier())
        {
            ArrayInsert(zbarriers, bar, 0);
        }
    }

    if(zbarriers.size < 1)
    {
        return false;
    }

    if(GetTime() < entity.next_barricade_time)
    {
        return false;
    }

    if(Distance(closest_board.origin, entity.origin) > GAS_SPOT_ATTRACT_DISTANCE)
    {
        return false;
    }

    closest_zbarrier = ArrayGetClosest(closest_board.origin,zbarriers);
    if(!closest_zbarrier IsZBarrier())
    {
        return false;
    }

    if(closest_zbarrier IsZBarrierOpen())
    {
        entity.v_zombie_custom_goal_pos = undefined;
        return false;
    }


    if(!entity CanPath(entity.origin, closest_board.origin))
    {
        return false;
    }

    entity.barrier_to_break = closest_zbarrier;
    entity.v_zombie_custom_goal_pos = closest_board.origin;

    if(Distance(entity.origin,closest_board.origin) < 32)
    {
        //entity OrientMode("face point", undefined, undefined, closest_zbarrier.origin);
        entity OrientMode("face angle", closest_board.angles[1]);
        entity.go_break_barrier = 1;
        
        return true;
    }

    //idk
    return false;
}

function brutusTeargasService(entity)
{
    if(level.cellbreaker_dont_use_tear_gas == 1)
    {
        return false;
    }

    if(GetTime() < entity.next_teargas_time)
    {
        return false;
    }

    if(entity.go_berserk == 1)
    {
        return false;
    }

    if(entity.throw_teargas == 1 || entity.drop_teargas == 1)
    {
        return false;
    }

    if(!isdefined(entity.enemy))
    {
        return false;
    }

    if(struct::get_array("cellbreaker_gas_spot", "targetname").size > 0)
    {
        closest_drop_spot = ArrayGetClosest(entity.origin, struct::get_array("cellbreaker_gas_spot", "targetname"));
        if(Distance(entity.origin,closest_drop_spot.origin) < GAS_SPOT_ATTRACT_DISTANCE)
        {
            entity.v_zombie_custom_goal_pos = closest_drop_spot.origin;
        }
    }
    else
    {
        closest_drop_spot = entity;
    }

    if(Distance(entity.origin, entity.enemy.origin) > 500 
    && (Distance(closest_drop_spot.origin, entity.origin) > 500 || closest_drop_spot == entity)
    && entity CanSee(entity.enemy) 
    && !isdefined(entity.v_zombie_custom_goal_pos))
    {
        entity.throw_teargas = 1;
    }
    else if(struct::get_array("cellbreaker_gas_spot", "targetname").size > 0 && Distance(entity.origin,closest_drop_spot.origin) < 32)
    {
        entity.drop_teargas = 1;
        //entity.v_zombie_custom_goal_pos = undefined;
    }
    else if(struct::get_array("cellbreaker_gas_spot", "targetname").size < 1 && DROP_GAS_ANYWHERE)
    {
        entity.drop_teargas = 1;
    }
}

function brutusshouldturnberserk(entity)
{
    if(entity.go_berserk == 1)
    {
        return true;
    }
    return false;
}

function brutusplayedberserkintro(entity) //after anim
{
    self endon("death");
    entity.go_berserk = 0;
    entity.next_teargas_time += BERSERK_TIME*1000;

    entity thread berserk_timeout();
    Blackboard::SetBlackBoardAttribute(entity, LOCOMOTION_SPEED_TYPE, LOCOMOTION_SPEED_SPRINT);
    entity ASMSetAnimationRate(1.05);
}

function berserk_timeout()
{
    self endon("death");
    wait BERSERK_TIME;
    Blackboard::SetBlackBoardAttribute(self, LOCOMOTION_SPEED_TYPE, LOCOMOTION_SPEED_RUN);
    self ASMSetAnimationRate(1);
}

function brutusshouldbreakboard(entity)
{
    if(entity.go_break_barrier == 1)
    {
        return true;
    }
    return false;    
}

function brutusboardsmash(entity)
{
    //get nearest board and smash
    for(i=0; i < entity.barrier_to_break GetNumZBarrierPieces(); i++)
    {
        if(entity.barrier_to_break GetZBarrierPieceState(i) == "closed")
        {
            entity.barrier_to_break SetZBarrierPieceState(i, "opening" , 1);
        }
    }

    entity.go_break_barrier = 0;
    //entity.barrier_to_break = undefined;
    entity.v_zombie_custom_goal_pos = undefined;
    entity.next_barricade_time = GetTime()+BARRICADE_BREAK_INTERVAL*1000;
    entity OrientMode("face default");
}

function brutusshouldDoGasAttack(entity)
{
    if(level.cellbreaker_dont_use_tear_gas == 1)
    {
        return false;
    }

    if(entity.drop_teargas == 0)
    {
        return false;
    }

    if(entity.throw_teargas == 1)
    {
        return false;
    }

    return true;
}

function brutusplayedGasAttack(entity)
{
    entity endon("death");
    entity.drop_teargas = 0;
    entity.next_teargas_time = GetTime()+GAS_DROP_INTERVAL*1000;
    entity.v_zombie_custom_goal_pos = undefined;

    entity waittill("nades_dropped", pos);
    entity thread do_teargas_damage(pos);
}

function do_teargas_damage(spot)
{
    level endon("end_game");
    wait 4; //for teargas to come in

    stoptime = GetTime()+25000;

    while(GetTime() < stoptime)
    {
        foreach(player in GetPlayers())
        {
            if(Distance(player.origin, spot) < 75)
            {
                player DoDamage(15, spot, self);
                player SetBlur(10, 0.1);
            }
            else 
            {
                player SetBlur(0, 1);
            }
        }
        wait 0.25;
    }
}

function brutusshouldThrowGas(entity)
{
    if(level.cellbreaker_dont_use_tear_gas == 1)
    {
        return false;
    }

    if(entity.drop_teargas == 1)
    {
        return false;
    }

    if(entity.throw_teargas == 0)
    {
        return false;
    }

    return true;
}

function brutusplayedThrowGas(entity)
{
    entity.throw_teargas = 0;

    entity.next_teargas_time = GetTime()+GAS_DROP_INTERVAL*1000;
}

function private BrutusShouldWait(entity)
{
    if (IS_TRUE(entity.waiting))
    {
        return true;
    }

    return false;
}

/* endregion */
/* region AI Setup */

function private brutusSpawnSetup()
{
    //PRINT_CB_DEBUG("mechz spawnsetup");
    self DisableAimAssist();

    self.disableAmmoDrop = true;
    self.no_gib = true;
    self.ignore_nuke = true;
    self.ignore_enemy_count = true;
    self.ignore_round_robbin_death = true; 

    self.ignoreRunAndGunDist = true;
    
    self.is_boss = true;

    AiUtility::AddAIOverrideDamageCallback(self, &brutusDamageCallback);

    self PushActors(true);

    Blackboard::CreateBlackBoardForEntity(self);
    self AiUtility::RegisterUtilityBlackboardAttributes();
    ai::CreateInterfaceForEntity(self);
    BB_REGISTER_ATTRIBUTE(LOCOMOTION_SPEED_TYPE, LOCOMOTION_SPEED_RUN, undefined);
    Blackboard::SetBlackBoardAttribute(self, LOCOMOTION_SPEED_TYPE, LOCOMOTION_SPEED_RUN);

    self.team = level.zombie_team;
/*
    self PathMode("move allowed");
    self.ai_state = "zombie_think";
    self.script_string = "find_flesh";
    self.completed_emerging_into_playable_area = true;
    self ASMRequestSubstate("move@cellbreaker");
    self.keep_moving = 1;
*/
    self.helmet_health = HELMET_HEALTH * zm::get_round_number();
    self.go_berserk = 0;
    self.drop_teargas = 0;
    self.throw_teargas = 0;
    self.go_break_barrier = 0;
    self.next_teargas_time = GetTime()+GAS_DROP_INTERVAL*1000;
    self.next_barricade_time = GetTime()+BARRICADE_BREAK_INTERVAL*1000;
    self.barrier_to_break = undefined;

    self.helmet = Spawn("script_model", self GetTagOrigin("j_head"));
    self.helmet.angles = self GetTagAngles("j_head");
    self.helmet SetModel("c_zom_cellbreaker_helmet");
    self.helmet EnableLinkTo();
    self.helmet LinkTo(self, "j_head");

    self clientfield::set("brutus_lamp_fx", 1);

    self thread brutusDeathEvent();
}

/* endregion */
/* region Damage management */

function brutusDamageCallback(inflictor, attacker, damage, dFlags, mod, weapon, point, dir, hitLoc, offsetTime, boneIndex, modelIndex)
{
    if(isDefined(attacker) && IsPlayer(attacker) && IsAlive(attacker) && (level.zombie_vars[attacker.team]["zombie_insta_kill"] || IS_TRUE(attacker.personal_instakill))) //instakill does normal damage
    {
        damage = damage*2; //make instakill usefull
    }

    if (hitLoc == "head")
    {
        self track_helmet(damage);
    }

    return damage;
}

function private track_helmet(damage)
{
    if(self.helmet_health <= 0)
    {
        return;
    }

    self.helmet_health -= damage;

    if(self.helmet_health <= 0)
    {
        self.helmet Delete();
        self clientfield::set("brutus_fx", 1);
        self.go_berserk = 1;
        self PlaySound("evt_brutus_helmet");
    }
}

function brutusDeathEvent()
{
    self waittill("death", attacker, damageType);
    attacker zm_score::add_to_player_score(1000);

    if(isdefined(self.helmet))
    {
        self.helmet Delete();
    }

    PlaySoundAtPosition("zmb_ai_cellbreaker_death", self.origin);
    //self PlaySound("zmb_ai_cellbreaker_vox_death");
    self clientfield::set("brutus_fx", 1);
    self clientfield::set("brutus_lamp_fx", 0);

    //PlayFXOnTag("custom/AI/cellbreaker_death", self, "j_spineupper");
    self clientfield::set("brutus_fx", 2);

    //PlayFX("custom/AI/cellbreaker_death", self.origin);
}

/* endregion */
/* region AI Spawn */

function spawn_brutus(health)
{
    s_struct = choose_a_spawn("cellbreaker_spot");

    if(!isDefined(s_struct))
    {
        PRINT_CB_DEBUG("NO VALID SPAWN POINTS FOUND");
        return undefined;
    }

    spawner = GetEntArray("cellbreaker_spawner", "targetname");
    spawner = spawner[0];

    if(!isdefined(spawner))
    {
        PRINT_CB_DEBUG("no spawner");
        return;
    }

    thread zm_utility::really_play_2D_sound("zmb_ai_brutus_spawn_2d");    
    wait(RandomIntRange(3,5));

    e_ai = zombie_utility::spawn_zombie(spawner, "cellbreaker");

    if(!isDefined(e_ai))
    {
        PRINT_CB_DEBUG("no e_ai");
        return;
    }
    e_ai endon("death");

    e_ai.health = BRUTUS_HEALTH * zm::get_round_number();
    if(isdefined(health))
    {
        e_ai.health = health;
    }

    ang = e_ai to_player_angles(s_struct);

    e_ai ForceTeleport(s_struct.origin, ang, 0);
    e_ai thread scene::play("ai_zombie_cellbreaker_spawn", e_ai);
    e_ai PlaySound("zmb_ai_cellbreaker_vox_spawn");
    //PlayFX("custom/AI/cellbreaker_spawn", e_ai.origin, AnglesToForward(ang));
    
    return e_ai;
}

function to_player_angles(s_struct) //self = slender
{
    target = ArrayGetClosest(self.origin, GetPlayers());

    origin = target.origin - s_struct.origin;
    v_to_enemy = FLAT_ORIGIN(origin);
    v_to_enemy = VectorNormalize(v_to_enemy);
    goalAngles = VectortoAngles(v_to_enemy);

    return goalAngles; 
}

function choose_a_spawn(noteworthy) // REQUIRES ATLEAST 2 ZONES or no
{
    structs = struct::get_array(noteworthy, "targetname");

    if(!isdefined(structs) || structs.size < 1)
    {
        PRINT_CB_DEBUG("noteworthy_position");
        structs = struct::get_array(noteworthy, "script_noteworthy");
    }

    players = getplayers(); 
    players = array::randomize(players); 
    player = players[0]; 

    while(1)
    {
        spot = ArrayGetClosest(player.origin,structs);
        zone = zm_zonemgr::get_zone_from_position(spot.origin, 1);

        if(level.newzones.size < 2)
        {
            return spot;    
        }

        if(zm_zonemgr::zone_is_enabled(zone))
        {
            //PRINT_CB_DEBUG("success");            
            return spot;
        }
        else
        {
            ArrayRemoveValue(structs,spot);    
        }
    }        
    PRINT_CB_DEBUG("failed "+ noteworthy +" spawn"); 
}

function setup_autospawn()
{
    next_spawn_round = FIRST_SPAWN_ROUND;

    while(AUTOSPAWN)
    {
        level waittill("between_round_over");
        if(level.round_number != next_spawn_round)
        {
            continue;
        }

        health = level.round_number*HEALTH_PER_ROUND;
        if(health > MAX_HEALTH)
        {
            health = MAX_HEALTH;
        }

        wait(RandomIntRange(10,20));
        spawn_brutus(health);
        
        if(level.round_number >= DUAL_SPAWN_ROUND)
        {
            wait(RandomIntRange(10,20));
            spawn_brutus(health);
        }

        next_spawn_round += SPAWN_ROUND_INTERVAL;
    }
}

/* endregion */
/* region Animation State Mocomp */

function melee_track(entity)
{
    if(self.archetype != "cellbreaker") // Because of Witches.
    {
        return;
    }

    self Melee();
    self PlaySound("vox_brutus_exert");
}

function drop_teargas(entity)
{
    nade_1 = self MagicGrenadeType(GetWeapon("cellbreaker_teargas_grenade"), self GetTagOrigin("tag_weapon_left"),(0,0,0));
    nade_2 = self MagicGrenadeType(GetWeapon("cellbreaker_teargas_grenade"), self GetTagOrigin("tag_weapon_right"),(0,0,0));

    nade_1 endon("explode"); //maybe
    nade_1 waittill("grenade_bounce", pos, normal, ent, surface);
    nade_1 Detonate();
    nade_2 Detonate();
    self notify("nades_dropped", pos);
}

function throw_teargas(entity)
{
    if(entity.throw_teargas == 0) //cuz melee anim
    {
        return false;
    }

    target_pos = entity.enemy.origin;

    dir = VectorToAngles(target_pos - entity.origin);
    dir = AnglesToForward(dir);

    dist = Distance(entity.origin, target_pos);

    velocity = dir * dist;
    velocity = velocity + (0,0,120);

    nade_1 = self MagicGrenadeType(GetWeapon("cellbreaker_teargas_grenade"), self GetTagOrigin("j_mid_le_3"),velocity);
    nade_1 endon("explode"); //maybe

    //nade_1 waittill("explode", position, surface);
    nade_1 waittill("grenade_bounce", pos, normal, ent, surface);
    nade_1 Detonate();
    entity thread do_teargas_damage(pos);
}

/* endregion */
/* region Traversals */

function private mocompBrutusTeleportTraversalInit(entity, mocompAnim, mocompAnimBlendOutTime, mocompAnimFlag, mocompDuration)
{
    entity OrientMode("face angle", entity.angles[1]);
    entity AnimMode(AI_ANIM_MOVE_CODE);
    if (isdefined(entity.traverseEndNode))
    {
        entity.teleportStart = entity.origin;
        entity.teleportPos = entity.traverseEndNode.origin;
        //self clientfield::increment(MARGWA_FX_OUT_CLIENTFIELD, MARGWA_TELEPORT_ON);

        if (isdefined(entity.traverseStartNode))
        {
            if (isdefined(entity.traverseStartNode.speed))
            {
                entity.teleport_speed = entity.traverseStartNode.speed;
            }

            entity.waiting = true;
            entity PathMode("dont move");

            entity.traveler = Spawn("script_model", entity.origin+(0,0,32)); //for fx
            entity.traveler SetModel("tag_origin");
            entity.traveler NotSolid();

            entity.traveler clientfield::set("brutus_tp_fx", 1);
            wait 0.5;            
            entity Ghost();
            if(isdefined(entity.helmet))
                entity.helmet Hide();


            entity thread cellbreaker_traversal();
        }
        return false;
    }

    return false;
}

function cellbreaker_traversal()
{
    //self endon("death");
    destPos = self.teleportPos + (0, 0, 48);
    dist = Distance(self.teleportStart, destPos);
    time = dist / 100;

    wait 1; //wait for fx

    // if (isdefined(self.teleport_speed))
    // {
    //     time = dist / self.teleport_speed;
    // }

    //PlayFXOnTag(level._effect["powerup_on_solo"],self.traveler, "tag_origin");

    self LinkTo(self.traveler);

    self.traveler MoveTo(destPos, time);
    self.traveler util::waittill_any_ex((time + 0.1), "movedone", self, "death");
    self.traveler Delete();

    self clientfield::set("brutus_fx", 3);

    self Unlink();
    //self ForceTeleport(destPos);
    self PathMode("move allowed");

    self Show();

    if(isdefined(self.helmet))
    {
        self.helmet Show();
    }

    self.waiting = false;

    wait 1;
    self clientfield::set("brutus_fx", 0);
}

/* endregion */
