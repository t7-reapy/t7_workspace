#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\math_shared;
#using scripts\shared\ai_shared;
#using scripts\shared\ai\systems\animation_state_machine_utility;
#using scripts\shared\ai\systems\animation_state_machine_notetracks;
#using scripts\shared\ai\systems\animation_state_machine_mocomp;
#using scripts\shared\ai\archetype_utility;
#using scripts\shared\ai\archetype_locomotion_utility;
#using scripts\shared\ai\systems\behavior_tree_utility;
#using scripts\shared\ai\systems\blackboard;
#using scripts\shared\ai\zombie;
#using scripts\shared\ai\zombie_utility;

#using scripts\zm\_zm_attackables;
#using scripts\zm\_zm_behavior_utility;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_utility;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\ai\zombie.gsh;
#insert scripts\shared\ai\systems\animation_state_machine.gsh;
#insert scripts\shared\ai\systems\behavior.gsh;
#insert scripts\shared\ai\systems\behavior_tree.gsh;
#insert scripts\shared\ai\systems\blackboard.gsh;
#insert scripts\shared\ai\utility.gsh;
#insert scripts\shared\archetype_shared\archetype_shared.gsh;
#insert scripts\shared\aat_zm.gsh;

#insert scripts\zm\_zm_behavior.gsh;

#define ZOMBIE_SIDE_STEP_CHANCE .7
#define ZOMBIE_RIGHT_STEP_CHANCE .5
#define ZOMBIE_FORWARD_STEP_CHANCE .3

#define ZOMBIE_REACTION_INTERVAL 2000
#define ZOMBIE_MIN_REACTION_DIST 64
#define ZOMBIE_MAX_REACTION_DIST 1000

#namespace hb21_zm_behavior;

REGISTER_SYSTEM_EX( "hb21_zm_behavior", &__init__, &__main__, undefined )

function __init__()
{
    // ------- ZOMBIE SOE EXPLOSIVE DEATHS -----------//
    BT_REGISTER_API("explosivekillinvalid", &explosive_kill_invalid);

    // ------- ZOMBIE IDGUN -----------//
    BT_REGISTER_API("waskilledbyidgun", &was_killed_by_idgun);

    // ------- ZOMBIE GERSH DEVICE -----------//
    BT_REGISTER_ACTION("hb21zombieblackholebombpullaction", &zombie_black_hole_bomb_pull_start, &zombie_black_hole_bomb_pull_update, &zombie_black_hole_bomb_pull_end);
    BT_REGISTER_API("waskilledbyblackholebomb", &was_killed_by_black_hole_bomb);

    // ------- ZOMBIE STAFFS -----------//
    BT_REGISTER_API("waskilledbywaterstaff", &is_staff_water_damage);
    BT_REGISTER_API("waskilledbylightningstaff", &is_staff_lightning_damage);
    BT_REGISTER_API("wasstunnedbylightningstaff", &was_stunned_by_lightning_staff);
    BT_REGISTER_API("zombiestunlightningactionend", &zombie_stun_lightning_action_end);
    BT_REGISTER_API("zombieshouldwhirlwind", &zombie_should_whirlwind);
    BT_REGISTER_API("wasstunnedbyfirestaff", &was_stunned_by_fire_staff);
    BT_REGISTER_API("zombiestunfireactionend", &zombie_stun_fire_action_end);
    BT_REGISTER_API("waskilledbyfirestaff", &is_staff_fire_damage);

    // ------- ZOMBIE WAVEGUN -----------//
    BT_REGISTER_API("moonzombiekilledbymicrowavegun", &is_microwavegun_damage);
    BT_REGISTER_API("moonzombiekilledbymicrowavegundw", &is_zapgun_damage);

    // ------- ZOMBIE INERT -----------//
    BT_REGISTER_API("zombieshouldinertidle", &zombie_should_inert_idle);
    BT_REGISTER_API("zombieshouldinertwakeup", &zombie_should_inert_wakeup);
    BT_REGISTER_API("zombieshouldinertterminate", &zombie_inert_terminate);

    // ------- ZOMBIE SLIQUIFIER -----------//
    BT_REGISTER_API("zombieshouldslip", &zombie_should_slip);
    BT_REGISTER_API("zombieslippedactionstart", &zombie_slipped_action_start);
    BT_REGISTER_API("zombieslippedactionupdate", &zombie_slipped_action_update);
    BT_REGISTER_API("zombieslippedactionterminate", &zombie_slipped_action_terminate);

    // ------- ZOMBIE ACID -----------//
    BT_REGISTER_API("wasstunnedbyacid", &was_stunned_by_acid);
    BT_REGISTER_API("zombiestunacidactionend", &zombie_stun_acid_action_end);

    // ------- ZOMBIE SIDE STEP -----------//
    BB_REGISTER_ATTRIBUTE("_zombie_side_step_type", "none", &zombie_side_step_type);
    BT_REGISTER_API("zombiesidestepservice", &zombie_side_step_service);
    BT_REGISTER_API("zombieshouldsidestep", &zombie_should_side_step);
    BT_REGISTER_ACTION("zombiesidestepaction", &zombie_side_step_action, undefined, &zombie_side_step_terminate);
}

function __main__()
{
    level.zombie_total_set_func = &zombie_total_update;
}

function zombie_total_update()
{
    level.zombiesLeftBeforeNapalmSpawn = randomIntRange(int(level.zombie_total * .25), int(level.zombie_total * .75));
    level.zombiesLeftBeforeSonicSpawn = randomIntRange(int(level.zombie_total * .25), int(level.zombie_total * .75));
    level.zombie_total_update = 1;
    level.zombies_left_before_astro_spawn = 1;
    if (level.zombie_total > 1)
        level.zombies_left_before_astro_spawn = randomIntRange(int(level.zombie_total * .25), int(level.zombie_total * .75));
}

function set_zombie_aat_override()
{
    level.aat[ZM_AAT_BLAST_FURNACE_NAME].validation_func = &zombie_aat_override;
    level.aat[ZM_AAT_DEAD_WIRE_NAME].validation_func = &zombie_aat_override;
    level.aat[ZM_AAT_FIRE_WORKS_NAME].validation_func = &zombie_aat_override;
    level.aat[ZM_AAT_THUNDER_WALL_NAME].validation_func = &zombie_aat_override;
    level.aat[ZM_AAT_TURNED_NAME].validation_func = &zombie_aat_override;
}

function zombie_aat_override()
{
    if (isDefined(self) && isDefined(self.animName) && (self.animName == "astro_zombie" || self.animName == "sonic_zombie" || self.animName == "napalm_zombie"))
        return 0;

    return 1;
}

function enable_side_step()
{
    self.n_stepped_direction = 0;
    self.n_zombie_can_side_step = 1;
    self.n_zombie_can_forward_step = 1;
    self.n_zombie_side_step_step_chance = ZOMBIE_SIDE_STEP_CHANCE;
    self.n_zombie_right_step_step_chance = ZOMBIE_RIGHT_STEP_CHANCE;
    self.n_zombie_forward_step_step_chance = ZOMBIE_FORWARD_STEP_CHANCE;
    self.n_zombie_reaction_interval = ZOMBIE_REACTION_INTERVAL;
    self.n_zombie_min_reaction_dist = ZOMBIE_MIN_REACTION_DIST;
    self.n_zombie_max_reaction_dist = ZOMBIE_MAX_REACTION_DIST;
}

function disable_ai_pain()
{
    self.a.disablepain = 1;
    self.allowpain = 0;
    self.a.disableReact = 1;
    self.allowReact = 0;
}

function enable_ai_pain()
{
    self.a.disablepain = 0;
    self.allowpain = 1;
    self.a.disableReact = 0;
    self.allowReact = 1;
}

function zombie_side_step_type()
{
    return self._zombie_side_step_type;
}

function zombie_side_step_service(behavior_tree_entity)
{
    if (!IS_TRUE(behavior_tree_entity.n_zombie_can_side_step))
        return;

    if (!isDefined(behavior_tree_entity.n_last_side_step_time))
        behavior_tree_entity.n_last_side_step_time = getTime();

    if (isDefined(behavior_tree_entity.enemy))
    {
        behavior_tree_entity.str_side_step_type = behavior_tree_entity zombie_get_side_step();

        if (behavior_tree_entity.str_side_step_type != "none")
        {
            behavior_tree_entity._juke_direction = behavior_tree_entity zombie_get_desired_side_step_direction();

            if (behavior_tree_entity._juke_direction == "none")
                return;

            str_anim_name = behavior_tree_entity animMappingSearch(iString("anim_" + behavior_tree_entity.archetype + "_side_" + behavior_tree_entity.str_side_step_type + "_" + behavior_tree_entity._juke_direction));
            if (behavior_tree_entity mayMoveFromPointToPoint(behavior_tree_entity.origin, zombie_utility::getAnimEndPos(str_anim_name)))
            {
                behavior_tree_entity._zombie_side_step_type = behavior_tree_entity.str_side_step_type + "_" + behavior_tree_entity._juke_direction;
                behavior_tree_entity.n_zombie_side_step = 1;
            }
        }
    }
}

function zombie_get_side_step()
{
    if (self zombie_can_side_step() && isPlayer(self.enemy) && self.enemy isLookingAt(self))
    {
        if (IS_TRUE(self.n_zombie_can_side_step) && randomFloat(1) < self.n_zombie_side_step_step_chance)
            return "step";
    }
    return "none";
}

function zombie_can_side_step()
{
    if (!IS_TRUE(self.n_zombie_can_side_step))
        return 0;

    if (getTime() - self.n_last_side_step_time < self.n_zombie_reaction_interval)
        return 0;

    self.n_last_side_step_time = getTime();
    if (!isDefined(self.enemy))
        return 0;

    if (IS_TRUE(self.missingLegs))
        return 0;

    dist_sq_from_enemy = distanceSquared(self.origin, self.enemy.origin);

    if (dist_sq_from_enemy < (self.n_zombie_min_reaction_dist * self.n_zombie_min_reaction_dist))
        return 0;

    if (dist_sq_from_enemy > (self.n_zombie_max_reaction_dist * self.n_zombie_max_reaction_dist))
        return 0;

    if (!isDefined(self.pathgoalpos) || distanceSquared(self.origin, self.pathgoalpos) < (self.n_zombie_min_reaction_dist * self.n_zombie_min_reaction_dist))
        return 0;

    if (abs(self getMotionAngle()) > 15)
        return 0;

    yaw = zombie_utility::getYawToOrigin(self.enemy.origin);

    if (abs(yaw) > 45)
        return 0;

    return 1;
}

function zombie_get_desired_side_step_direction()
{
    // if ( self.str_side_step_type == "roll" || self.str_side_step_type == "phase" )
    //     return "forward";

    randomRoll = randomFloat(1);

    if (randomRoll < self.n_zombie_forward_step_step_chance)
        return "forward";

    if (self.n_stepped_direction < 0)
        return "right";
    else if (self.n_stepped_direction > 0)
        return "left";
    else if (randomRoll < self.n_zombie_right_step_step_chance)
        return "right";
    else if (randomRoll < self.n_zombie_right_step_step_chance * 2)
        return "left";

    return "none";
}

function zombie_should_side_step(behaviorTreeEntity)
{
    if (IS_TRUE(behaviorTreeEntity.n_zombie_side_step))
        return 1;

    return 0;
}

function zombie_side_step_action(behavior_tree_entity, asm_state_name)
{
    behavior_tree_entity disable_ai_pain();
    AnimationStateNetworkUtility::RequestState(behavior_tree_entity, asm_state_name);

    return BHTN_RUNNING;
}

function zombie_side_step_terminate(behavior_tree_entity, asm_state_name)
{
    behavior_tree_entity enable_ai_pain();
    behavior_tree_entity.n_zombie_side_step = undefined;

    if (behavior_tree_entity._juke_direction == "left")
        behavior_tree_entity.n_stepped_direction--;
    else
        behavior_tree_entity.n_stepped_direction++;

    behavior_tree_entity.n_last_side_step_time = getTime();

    return BHTN_SUCCESS;
}

function zombie_black_hole_bomb_pull_start(e_behavior_tree_entity, str_asm_state_name)
{
    if (isDefined(level.black_hole_bomb_ai_fx))
        e_behavior_tree_entity thread [[level.black_hole_bomb_ai_fx]] (e_behavior_tree_entity, 1);

    e_behavior_tree_entity.pullTime = getTime();
    e_behavior_tree_entity.pullOrigin = e_behavior_tree_entity.origin;

    animationStateNetworkUtility::requestState(e_behavior_tree_entity, str_asm_state_name);

    zombie_update_black_hole_bomb_pull_state(e_behavior_tree_entity);

    if (isDefined(e_behavior_tree_entity.damageOrigin))
    {
        e_behavior_tree_entity.n_zombie_custom_goal_radius = 8;
        e_behavior_tree_entity.v_zombie_custom_goal_pos = e_behavior_tree_entity.damageOrigin;
    }

    return BHTN_RUNNING;
}

function zombie_update_black_hole_bomb_pull_state(e_behavior_tree_entity)
{
    n_dist_to_bomb = distanceSquared(e_behavior_tree_entity.origin, e_behavior_tree_entity.damageOrigin);

    if (n_dist_to_bomb < 16384)
        e_behavior_tree_entity._black_hole_bomb_collapse_death = 1;
    else if (n_dist_to_bomb < 1048576)
        blackboard::setBlackBoardAttribute(e_behavior_tree_entity, BLACKHOLEBOMB_PULL_STATE, BLACKHOLEBOMB_PULL_FAST);
    else if (n_dist_to_bomb < 4227136)
        blackboard::setBlackBoardAttribute(e_behavior_tree_entity, BLACKHOLEBOMB_PULL_STATE, BLACKHOLEBOMB_PULL_SLOW);
}

function zombie_black_hole_bomb_pull_update(e_behavior_tree_entity, str_asm_state_name)
{
    if (!isDefined(e_behavior_tree_entity.interdimensional_gun_kill))
        return BHTN_SUCCESS;

    zombie_update_black_hole_bomb_pull_state(e_behavior_tree_entity);

    if (IS_TRUE(e_behavior_tree_entity._black_hole_bomb_collapse_death))
    {
        e_behavior_tree_entity.skipAutoRagdoll = 1;
        e_behavior_tree_entity doDamage(e_behavior_tree_entity.health + 666, e_behavior_tree_entity.origin + (0, 0, 50), e_behavior_tree_entity.interdimensional_gun_attacker, undefined, undefined, "MOD_CRUSH", 0, e_behavior_tree_entity.interdimensional_gun_weapon);
        return BHTN_SUCCESS;
    }

    if (isDefined(e_behavior_tree_entity.damageOrigin))
        e_behavior_tree_entity.v_zombie_custom_goal_pos = e_behavior_tree_entity.damageOrigin;

    // if ( !IS_TRUE( e_behavior_tree_entity.missingLegs ) && ( GetTime() - e_behavior_tree_entity.pullTime > ZM_MOVE_TIME ) )
    if (getTime() - e_behavior_tree_entity.pullTime > ZM_MOVE_TIME)
    {
        n_dist_sq = distance2DSquared(e_behavior_tree_entity.origin, e_behavior_tree_entity.pullOrigin);
        if (n_dist_sq < ZM_MOVE_DIST_SQ)
        {
            e_behavior_tree_entity setAvoidanceMask("avoid all");
            e_behavior_tree_entity.cant_move = 1;

            if (isDefined(e_behavior_tree_entity.cant_move_cb))
                e_behavior_tree_entity [[e_behavior_tree_entity.cant_move_cb]] ();
        }
        else
        {
            e_behavior_tree_entity setAvoidanceMask("avoid none");
            e_behavior_tree_entity.cant_move = 0;
        }

        e_behavior_tree_entity.pullTime = getTime();
        e_behavior_tree_entity.pullOrigin = e_behavior_tree_entity.origin;
    }

    return BHTN_RUNNING;
}

function zombie_black_hole_bomb_pull_end(e_behavior_tree_entity, str_asm_state_name)
{
    if (isDefined(level.black_hole_bomb_ai_fx))
        e_behavior_tree_entity thread [[level.black_hole_bomb_ai_fx]] (e_behavior_tree_entity, 0);

    e_behavior_tree_entity.v_zombie_custom_goal_pos = undefined;
    e_behavior_tree_entity.n_zombie_custom_goal_radius = undefined;

    e_behavior_tree_entity.pullTime = undefined;
    e_behavior_tree_entity.pullOrigin = undefined;

    return BHTN_SUCCESS;
}

function private explosive_kill_invalid(e_behavior_tree_entity)
{
    if (isDefined(level.ptr_is_explode_death_anim_excluded))
        return [[level.ptr_is_explode_death_anim_excluded]] (e_behavior_tree_entity.damageweapon);

    return 0;
}

function private was_killed_by_idgun(e_behavior_tree_entity)
{
    if (!isDefined(e_behavior_tree_entity.killby_interdimensional_gun_hole) && IS_TRUE(e_behavior_tree_entity.interdimensional_gun_kill) && isDefined(e_behavior_tree_entity.interdimensional_gun_weapon) && isWeapon(e_behavior_tree_entity.interdimensional_gun_weapon) && isInArray(level.idgun_weapons, e_behavior_tree_entity.interdimensional_gun_weapon) && isAlive(e_behavior_tree_entity))
    {
        return 1;
    }
    return 0;
}

function private was_killed_by_black_hole_bomb(e_behavior_tree_entity)
{
    if (IS_TRUE(e_behavior_tree_entity.interdimensional_gun_kill) && isDefined(e_behavior_tree_entity.interdimensional_gun_weapon) && isWeapon(e_behavior_tree_entity.interdimensional_gun_weapon) && e_behavior_tree_entity.interdimensional_gun_weapon.name == "t7_black_hole_bomb" && isAlive(e_behavior_tree_entity))
    {
        return 1;
    }
    return 0;
}

function private is_staff_water_damage(e_behavior_tree_entity)
{
    if (!isDefined(level.ptr_is_staff_weapon) || e_behavior_tree_entity.damagemod == "MOD_MELEE")
        return 0;

    return [[level.ptr_is_staff_weapon]] (e_behavior_tree_entity.damageweapon, level.a_staff_water_weaponfiles);
}

function private is_staff_lightning_damage(e_behavior_tree_entity)
{
    if (!isDefined(level.ptr_is_staff_weapon) || e_behavior_tree_entity.damagemod == "MOD_MELEE")
        return 0;

    return [[level.ptr_is_staff_weapon]] (e_behavior_tree_entity.damageweapon, level.a_staff_lightning_weaponfiles);
}

function private was_stunned_by_lightning_staff(e_behavior_tree_entity)
{
    return IS_TRUE(e_behavior_tree_entity.b_staff_lightning_stunned);
}

function private zombie_stun_lightning_action_end(e_behavior_tree_entity)
{
    if (isDefined(e_behavior_tree_entity.b_staff_lightning_stunned) && e_behavior_tree_entity.b_staff_lightning_stunned > 1)
    {
        e_behavior_tree_entity.b_staff_lightning_stunned--;
        if (isDefined(level.ptr_staff_lightning_zombie_shockd_fx_cb))
            e_behavior_tree_entity [[level.ptr_staff_lightning_zombie_shockd_fx_cb]] (1);

        return BHTN_RUNNING;
    }
    e_behavior_tree_entity.b_staff_lightning_stunned = undefined;
    if (isAlive(e_behavior_tree_entity) && isDefined(level.ptr_staff_lightning_zombie_shockd_fx_cb))
        e_behavior_tree_entity [[level.ptr_staff_lightning_zombie_shockd_fx_cb]] (0);

    return BHTN_SUCCESS;
}

function private zombie_should_whirlwind(e_behavior_tree_entity)
{
    return IS_TRUE(e_behavior_tree_entity.b_staff_air_whirlwind_attract);
}

function private was_stunned_by_fire_staff(e_behavior_tree_entity)
{
    return IS_TRUE(e_behavior_tree_entity.b_staff_fire_stunned);
}

function private zombie_stun_fire_action_end(e_behavior_tree_entity)
{
    e_behavior_tree_entity.b_staff_fire_stunned = undefined;
    return BHTN_SUCCESS;
}

function private is_staff_fire_damage(e_behavior_tree_entity)
{
    if (!isDefined(level.ptr_is_staff_weapon) || e_behavior_tree_entity.damagemod == "MOD_MELEE")
        return 0;

    return [[level.ptr_is_staff_weapon]] (e_behavior_tree_entity.damageweapon, level.a_staff_fire_weaponfiles);
}

function private is_microwavegun_damage(e_behavior_tree_entity)
{
    if (isDefined(level.ptr_is_wavegun_weapon))
        return [[level.ptr_is_wavegun_weapon]] (e_behavior_tree_entity.damageweapon);

    return 0;
}

function private is_zapgun_damage(e_behavior_tree_entity)
{
    if (isDefined(level.ptr_is_zapgun_weapon))
        return [[level.ptr_is_zapgun_weapon]] (e_behavior_tree_entity.damageweapon);

    return 0;
}

function private zombie_should_inert_idle(e_behavior_tree_entity)
{
    return (IS_TRUE(e_behavior_tree_entity.emp_inert));
}

function private zombie_should_inert_wakeup(e_behavior_tree_entity)
{
    return (IS_TRUE(e_behavior_tree_entity.wake_up));
}

function private zombie_inert_terminate(e_behavior_tree_entity)
{
    e_behavior_tree_entity.wake_up = undefined;
    e_behavior_tree_entity.v_zombie_custom_goal_pos = undefined;
}

function zombie_should_slip(e_behavior_tree_entity)
{
    return IS_TRUE(e_behavior_tree_entity.b_sliding_on_goo);
}

function zombie_slipped_action_start(e_behavior_tree_entity, str_asm_state_name)
{
    str_asm_state_name = "slipped@zombie";
    animationStateNetworkUtility::requestState(e_behavior_tree_entity, str_asm_state_name);

    if (!isDefined(e_behavior_tree_entity.slip_move_anim_end_time))
    {
        slip_action_result = e_behavior_tree_entity ASTSearch(iString(str_asm_state_name));
        slip_action_animation = AnimationStateNetworkUtility::SearchAnimationMap(e_behavior_tree_entity, slip_action_result[ASM_ALIAS_ATTRIBUTE]);
        e_behavior_tree_entity.slip_move_anim_end_time = getTime() + getAnimLength(slip_action_animation);
    }

    e_behavior_tree_entity.oldblockingPain = (isDefined(e_behavior_tree_entity.blockingPain) ? e_behavior_tree_entity.blockingPain : 0);
    e_behavior_tree_entity.blockingPain = 1;

    return BHTN_RUNNING;
}

function zombie_slipped_action_update(e_behavior_tree_entity)
{
    if (isDefined(e_behavior_tree_entity.slip_move_anim_end_time) && (getTime() >= e_behavior_tree_entity.slip_move_anim_end_time))
    {
        e_behavior_tree_entity.slip_move_anim_end_time = undefined;
        return BHTN_SUCCESS;
    }
    return BHTN_RUNNING;
}

function zombie_slipped_action_terminate(e_behavior_tree_entity)
{
    e_behavior_tree_entity.b_sliding_on_goo = undefined;
    e_behavior_tree_entity.blockingPain = (isDefined(e_behavior_tree_entity.oldblockingPain) ? e_behavior_tree_entity.oldblockingPain : 0);
    e_behavior_tree_entity.oldblockingPain = undefined;
    return BHTN_SUCCESS;
}

function private was_stunned_by_acid(e_behavior_tree_entity)
{
    return IS_TRUE(e_behavior_tree_entity.b_acid_stunned);
}

function private zombie_stun_acid_action_end(e_behavior_tree_entity)
{
    e_behavior_tree_entity.b_acid_stunned = undefined;
    return BHTN_SUCCESS;
}

function private napalm_can_explode(e_behavior_tree_entity)
{
    return IS_TRUE(e_behavior_tree_entity.b_napalm_explode);
}

function private napalm_explode_initialize(e_behavior_tree_entity)
{
    return BHTN_RUNNING;
}

function private napalm_explode_terminate(e_behavior_tree_entity)
{
    return BHTN_SUCCESS;
}

function private sonic_can_attack(e_behavior_tree_entity)
{
    return IS_TRUE(e_behavior_tree_entity.b_sonic_attack);
}

function private sonic_can_attack_initialize(e_behavior_tree_entity)
{
    return BHTN_RUNNING;
}

function private sonic_can_attack_terminate(e_behavior_tree_entity)
{
    return BHTN_SUCCESS;
}
