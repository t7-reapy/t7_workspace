#using scripts\codescripts\struct;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\util_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\system_shared;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\ai\systems\blackboard;
#using scripts\zm\_zm;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_utility;

#using scripts\zm\_hb21_zm_weap_utility;
#using scripts\zm\_hb21_zm_weap_staff_utility;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\shared\ai\systems\blackboard.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\zm\_hb21_zm_weap_staff_lightning.gsh;
#insert scripts\zm\_hb21_zm_weap_staff_utility.gsh;

#precache("model", LIGHTNINGSTAFF_MODEL);
#precache("model", LIGHTNINGSTAFF_UPGRADED_MODEL);
#precache("model", LIGHTNINGSTAFF_PLINTH_MODEL);
#precache("model", LIGHTNINGSTAFF_PLINTH_BASE_MODEL);

#precache("fx", LIGHTNINGSTAFF_UPGRADE_GLOW);
#precache("fx", LIGHTNINGSTAFF_TRAIL_FX);

#namespace hb21_zm_weap_staff_lightning; 

REGISTER_SYSTEM_EX("hb21_zm_weap_staff_lightning", &__init__, &__main__, undefined)

// ============================== DEVELOPER OVERRIDES AND CALLBACKS ==============================

// ai.b_staff_lightning_immune - BOOLEAN - enable on ai to stop the Staff of Lightning damaging them
// ai.b_staff_lightning_upgraded_immune - BOOLEAN - enable on ai to stop the upgraded Staff of Lightning damaging them

// ai.ptr_staff_lightning_actor_damage_cb - FUNCTION_POINTER - set your own function here to manipulate the damage caused from the Staff of Lightning on actors
// ai.ptr_staff_lightning_vehicle_damage_cb - FUNCTION_POINTER - set your own function here to manipulate the damage caused from the Staff of Lightning on vehicles

// ai.ptr_staff_lightning_zombie_damage_cb - FUNCTION_POINTER - set your own function here to change what happens when a zombie is hit by the Staff of Lightning
// ai.ptr_staff_lightning_death_cb - FUNCTION_POINTER - - set your own function here to change the death behavior when killed by the Staff of Lightning

// ai.b_staff_lightning_ball_immune - BOOLEAN - enable on ai to stop the ball being able to effect them at all
// ai.n_staff_lightning_ball_range_check_multiplier - FLOAT - option to increase the distance checks used in the ball logic checks - can be important on flying AI as their height from the ground has a dramatic impact vs an ai on the ground

// ============================== DEVELOPER OVERRIDES AND CALLBACKS ==============================


function __init__()
{    
    level.a_staff_lightning_weaponfiles = [];
    
    staff_lightning_register_weapon_for_level("t9_1911_ldw_up_up");
    staff_lightning_register_weapon_for_level("s4_double_barrel_sawn_rdw_up_up");
    staff_lightning_register_weapon_for_level("s4_double_barrel_sawn_ldw_up_up");
    staff_lightning_register_weapon_for_level("iw8_m4a1_up_up", undefined, &staff_lightning_upgrade_fired);

    clientfield::register("scriptmover", LIGHTNINGSTAFF_BALL_CF, VERSION_SHIP, 1, "int");
    clientfield::register("actor", LIGHTNINGSTAFF_IMPACT_FX_CF, VERSION_SHIP, 1, "counter");
    clientfield::register("vehicle", LIGHTNINGSTAFF_IMPACT_FX_VEH_CF, VERSION_SHIP, 1, "counter");
    clientfield::register("actor", LIGHTNINGSTAFF_SHOCK_EYES_FX_CF, VERSION_SHIP, 1, "counter");
    clientfield::register("vehicle", LIGHTNINGSTAFF_SHOCK_EYES_FX_VEH_CF, VERSION_SHIP, 1, "counter");    
    
    zm::register_actor_damage_callback(&staff_lightning_zombie_actor_damage_cb);
    zm::register_vehicle_damage_callback(&staff_lightning_vehicle_damage_cb);
    zm_spawner::register_zombie_damage_callback(&staff_lightning_zombie_damage_cb);
    zm_spawner::register_zombie_death_event_callback(&staff_lightning_death_event_cb);
    
    level.ptr_staff_lightning_zombie_shockd_fx_cb = &staff_lightning_zombie_shocked_fx;
    level.ptr_staff_lightning_stun_zombie = &staff_lightning_stun_zombie;
    
    spawner::add_archetype_spawn_function("parasite", &staff_lightning_parasite_init_cb, undefined, undefined, undefined, undefined, undefined);
    spawner::add_archetype_spawn_function("zombie_dog", &staff_lightning_dog_init_cb, undefined, undefined, undefined, undefined, undefined);
}

/* 
MAIN 
Description : This function starts the script and will setup everything required - POST-load
Notes : None  
*/
function __main__()
{
}

/* 
STAFF LIGHTNING REGISTER WEAPON FOR LEVEL
Description : This function handles registering this weapon file as a staff of fire variant and sets up some required properties
Notes : None
*/
function staff_lightning_register_weapon_for_level(str_weapon, ptr_weapon_fired_cb = undefined, ptr_weapon_missile_fired_cb = undefined, ptr_weapon_grenade_fired_cb = undefined, ptr_weapon_obtained_cb = undefined, ptr_weapon_lost_cb = undefined, ptr_weapon_reloaded_cb = undefined, ptr_weapon_pullout_cb = undefined, ptr_weapon_putaway_cb = undefined)
{
    DEFAULT(level.a_staff_lightning_weaponfiles, []                                                                                                                                                                                                                                         );
    
    a_weapon_data = tableLookupRow(STAFF_LIGHTNING_TABLE_FILE, tableLookupRowNum(STAFF_LIGHTNING_TABLE_FILE, STAFF_TABLE_COLUMN_WEAPONFILE, str_weapon));
    if (!isDefined(a_weapon_data))
    {
        a_weapon_data = tableLookupRow(STAFF_LIGHTNING_TABLE_FILE, tableLookupRowNum(STAFF_LIGHTNING_TABLE_FILE, STAFF_TABLE_COLUMN_WEAPONFILE, "default"));
    }
    if (!isDefined(a_weapon_data))
    {
        return;
    }
 
    w_weapon = getWeapon(str_weapon);
    w_weapon.b_is_upgrade = (toLower(a_weapon_data[STAFF_TABLE_COLUMN_IS_UPGRADE]) == "true");
    w_weapon.n_damage = int(a_weapon_data[STAFF_TABLE_COLUMN_DAMAGE]);
    w_weapon.n_min_damage = int(a_weapon_data[STAFF_LIGHTNING_TABLE_COLUMN_MIN_DAMAGE]);
    w_weapon.n_ball_move_distance = int(a_weapon_data[STAFF_LIGHTNING_TABLE_COLUMN_BALL_MOVE_DISTANCE]);
    w_weapon.n_ball_damage_per_second = int(a_weapon_data[STAFF_LIGHTNING_TABLE_COLUMN_BALL_DAMAGE_PER_SECOND]);
    w_weapon.n_ball_range = int(a_weapon_data[STAFF_LIGHTNING_TABLE_COLUMN_BALL_RADIUS]);
    
    hb21_zm_weap_staff_utility::register_staff_weapon_for_level(w_weapon, ptr_weapon_fired_cb, ptr_weapon_missile_fired_cb, ptr_weapon_grenade_fired_cb, ptr_weapon_obtained_cb, ptr_weapon_lost_cb, ptr_weapon_reloaded_cb, ptr_weapon_pullout_cb, ptr_weapon_putaway_cb);
    
    ARRAY_ADD(level.a_staff_lightning_weaponfiles, w_weapon);
}

/* 
STAFF LIGHTNING ACTOR DAMAGE CB
Description : This function handles the damage modifications when a zombie is hit from a Staff of Lightning
Notes : None
*/
function staff_lightning_zombie_actor_damage_cb(e_inflictor, e_attacker, n_damage, f_flags, str_means_of_death, w_weapon, v_point, v_direction, str_hit_loc, n_offset_time, n_bone_index, str_surface_type)
{
    if (!isDefined(e_attacker) || !isPlayer(e_attacker))
        return -1;
    
    if (!hb21_zm_weap_staff_utility::is_staff_weapon(w_weapon, level.a_staff_lightning_weaponfiles))
        return -1;
    
    if (hb21_zm_weap_staff_utility::is_upgraded_staff_weapon(w_weapon) && IS_TRUE(self.b_staff_lightning_upgraded_immune))
        return 0;
    else if (!hb21_zm_weap_staff_utility::is_upgraded_staff_weapon(w_weapon) && IS_TRUE(self.b_staff_lightning_immune))
        return 0;
    
    if (str_means_of_death == "MOD_MELEE")
        return -1;
    
    if (str_means_of_death != "MOD_RIFLE_BULLET")
    {        
        b_instakill_active = (isDefined(e_attacker) && isPlayer(e_attacker) && e_attacker zm_powerups::is_insta_kill_active());
        if (IS_TRUE(b_instakill_active))
            n_damage = self.health + 666;
        else
        {
            n_min_damage = w_weapon.n_min_damage;
            n_max_damage = w_weapon.n_damage;
            n_difference = n_max_damage - n_min_damage;
            
            n_pct_from_center = (n_damage - 1) / 10;
            n_new_damage = int(n_pct_from_center * n_difference);
            
            n_damage = int(n_min_damage + n_new_damage);
        }
        
        if (isDefined(self.ptr_staff_lightning_actor_damage_cb))
            return [[self.ptr_staff_lightning_actor_damage_cb]](e_inflictor, e_attacker, n_damage, f_flags, str_means_of_death, w_weapon, v_point, v_direction, str_hit_loc, n_offset_time, n_bone_index, str_surface_type);

        return n_damage;
    }
    return -1;
}

/* 
STAFF LIGHTNING VEHICLE DAMAGE CB
Description : This function handles the damage modifications when a zombie vehicle is hit from a Staff of Lightning
Notes : None
*/
function staff_lightning_vehicle_damage_cb(e_inflictor, e_attacker, n_damage, str_flags, str_means_of_death, w_weapon, v_point, v_direction, str_hit_loc, v_damage_origin, n_offset_time, b_damage_drom_underneath, n_model_index, str_part_name, str_surface_type)
{
    if (!isDefined(e_attacker) || !isPlayer(e_attacker))
        return n_damage;
    
    if (!isDefined(self.damageweapon) || self.damageweapon != w_weapon)
        self.damageweapon = w_weapon;
    if (!isDefined(self.damagemod) || self.damagemod != str_means_of_death)
        self.damagemod = str_means_of_death;
    
    if (!hb21_zm_weap_staff_utility::is_staff_weapon(w_weapon, level.a_staff_lightning_weaponfiles))
        return n_damage;
    
    if (hb21_zm_weap_staff_utility::is_upgraded_staff_weapon(w_weapon) && IS_TRUE(self.b_staff_lightning_upgraded_immune))
        return 0;
    else if (!hb21_zm_weap_staff_utility::is_upgraded_staff_weapon(w_weapon) && IS_TRUE(self.b_staff_lightning_immune))
        return 0;
    
    if (str_means_of_death == "MOD_MELEE")
        return n_damage;
    
    if (str_means_of_death != "MOD_RIFLE_BULLET")
    {    
        b_instakill_active = (isDefined(e_attacker) && isPlayer(e_attacker) && e_attacker zm_powerups::is_insta_kill_active());
        if (IS_TRUE(b_instakill_active))
            n_damage = self.health + 666;
        else
        {
            n_min_damage = w_weapon.n_min_damage;
            n_max_damage = w_weapon.n_damage;
            n_difference = n_max_damage - n_min_damage;
            
            n_pct_from_center = (n_damage - 1) / 10;
            n_new_damage = int(n_pct_from_center * n_difference);
            
            n_damage = int(n_min_damage + n_new_damage);
        }
        
        if (isDefined(self.ptr_staff_lightning_vehicle_damage_cb))
            return [[self.ptr_staff_lightning_vehicle_damage_cb]](e_inflictor, e_attacker, n_damage, str_flags, str_means_of_death, w_weapon, v_point, v_direction, str_hit_loc, v_damage_origin, n_offset_time, b_damage_drom_underneath, n_model_index, str_part_name, str_surface_type);

        return n_damage;
    }
    return n_damage;
}

/* 
STAFF LIGHTNING ZOMBIE DAMAGE CB
Description : This function handles the reaction when a zombie is hit from a Staff of Lightning
Notes : None
*/
function staff_lightning_zombie_damage_cb(str_means_of_death, str_hit_loc, v_point, e_attacker, n_damage, w_weapon, v_direction, str_tag_name, str_model_name, str_part_name, f_flags, e_inflictor, n_charge_level)
{
    if (!isDefined(e_attacker) || !isPlayer(e_attacker))
        return 0;
    
    if (!hb21_zm_weap_staff_utility::is_staff_weapon(w_weapon, level.a_staff_lightning_weaponfiles) || str_means_of_death == "MOD_MELEE")
        return 0;
    
    if (isDefined(self.ptr_staff_lightning_zombie_damage_cb))
        return [[self.ptr_staff_lightning_zombie_damage_cb]](str_means_of_death, str_hit_loc, v_point, e_attacker, n_damage, w_weapon, v_direction, str_tag_name, str_model_name, str_part_name, f_flags, e_inflictor, n_charge_level);
    
    self thread staff_lightning_stun_zombie();
    
    return 1;
}

/* 
STAFF LIGHTNING DEATH EVENT
Description : This function handles logic for zombies killed by the Staff of Lightning
Notes : None
*/
function staff_lightning_death_event_cb(e_attacker)
{
    if (!isDefined(e_attacker) || !isPlayer(e_attacker))
        return;
    
    if (!isDefined(self) || !hb21_zm_weap_staff_utility::is_staff_weapon(self.damageweapon, level.a_staff_lightning_weaponfiles) || self.damagemod == "MOD_MELEE")
        return;
    
    self setCanDamage(0);
    if (isDefined(self.ptr_staff_lightning_death_cb))
        self [[self.ptr_staff_lightning_death_cb]](e_attacker, self.damagemod);    
    else
    {
        self clientfield::increment((isVehicle(self) ? LIGHTNINGSTAFF_IMPACT_FX_VEH_CF : LIGHTNINGSTAFF_IMPACT_FX_CF), 1);
        self clientfield::increment((isVehicle(self) ? LIGHTNINGSTAFF_SHOCK_EYES_FX_VEH_CF : LIGHTNINGSTAFF_SHOCK_EYES_FX_CF), 2);
        
        self thread staff_lightning_stun_zombie();
        self thread zombie_utility::zombie_eye_glow_stop();
    }
}

/* 
STAFF LIGHTNING FIRED
Description : This function handles when a player fires a Staff of Lightning
Notes : None
*/
function staff_lightning_fired(e_projectile, w_weapon, n_charge_level)
{
}

/* 
STAFF LIGHTNING UPGRADE FIRED
Description : This function handles when a player fires a Staff of Lightning that is upgraded and charged
Notes : None
*/
function staff_lightning_upgrade_fired(e_projectile, w_weapon, n_charge_level)
{
    e_projectile thread staff_lightning_position_ball(self, w_weapon, n_charge_level);
}

/* 
STAFF LIGHTNING POSITION SOURCE
Description : This function handles logic for the Staff of Lightning charge shot area of effect
Notes : None
*/
function staff_lightning_position_ball(e_player, w_weapon, n_charge_level)
{
    v_fire_angles = vectorToAngles(e_player getWeaponForwardDir());
    v_fire_origin = e_player getWeaponMuzzlePoint();
    v_fire_origin = v_fire_origin + anglesToForward(v_fire_angles) * 100;
    
    e_fx_model = util::spawn_model("tag_origin", v_fire_origin);
    e_fx_model clientfield::set(LIGHTNINGSTAFF_BALL_CF, 1);
    e_fx_model.b_staff_lightning_ball_active = 1;
    
    n_shot_range = w_weapon.n_ball_move_distance;
    v_end = v_fire_origin + anglesToForward(v_fire_angles) * n_shot_range;
        
    v_trace = bulletTrace(v_fire_origin, v_end, 0, undefined);
    if (v_trace["fraction"] != 1)
        v_end = v_trace["position"];
    
    n_staff_lightning_ball_speed = n_shot_range / LIGHTNINGSTAFF_BALL_BALL_SPEED_DIVIDER;
    n_dist = distance(e_fx_model.origin, v_end);
    
    n_max_movetime_s = n_shot_range / n_staff_lightning_ball_speed;
    n_movetime_s = n_dist / n_staff_lightning_ball_speed;
    
    n_leftover_time = n_max_movetime_s - n_movetime_s;
    
    e_fx_model thread staff_lightning_ball_kill_zombies(e_player, w_weapon);
    e_fx_model moveTo(v_end, n_movetime_s);
    b_finished_playing = e_fx_model staff_lightning_ball_wait(n_leftover_time);
    
    e_fx_model notify("staff_lightning_ball_stop_killing");
    e_fx_model clientfield::set(LIGHTNINGSTAFF_BALL_CF, 0);
    e_fx_model.b_staff_lightning_ball_active = 0;
    
    wait 4;
    if (isDefined(e_fx_model))
        e_fx_model delete();
    
}

/* 
STAFF LIGHTNING BALL WAIT
Description : This function handles logic for the ball of lightning while its still moving to delete after the appropriate time
Notes : None
*/
function staff_lightning_ball_wait(n_lifetime_after_move)
{
    self endon("death");
    self waittill("movedone");
    wait n_lifetime_after_move;
    return 1;
}

/* 
STAFF LIGHTNING BALL KILL ZOMBIE
Description : This function handles logic for killing zombies nearby the Staff of Lightning's charge shot area of effect
Notes : None
*/
function staff_lightning_ball_kill_zombies(e_attacker, w_weapon)
{
    self endon("death");
    self endon("staff_lightning_ball_stop_killing");
    while (isDefined(self))
    {
        a_zombies = self staff_lightning_ball_get_valid_targets(w_weapon.n_ball_range);
        array::run_all(a_zombies, &staff_lightning_ball_effect_zombie, self, w_weapon, e_attacker);
        if (!isDefined(a_zombies) || !isArray(a_zombies) || a_zombies.size < 1)
            WAIT_SERVER_FRAME;
        
    }
}

/* 
STAFF LIGHTNING BALL GET VALID TARGETS
Description : Returns a array of valid targets nearby the Staff of Lightning's charge attack area of effect
Notes : None
*/
function staff_lightning_ball_get_valid_targets(n_ball_range)
{
    return self array::filter(util::get_array_of_closest(self.origin, getAITeamArray(level.zombie_team)), 1, &staff_lightning_ball_effect_zombie_valid, n_ball_range);
}

/* 
STAFF LIGHTNING STORM EFFECT ZOMBIE VALID
Description : This function is used to perform checks on each zombie passed to it are valid to be hit by the Staff of Lightning charged attack
Notes : None
*/
function staff_lightning_ball_effect_zombie_valid(e_ai_zombie, n_ball_range)
{
    b_distance_passed = staff_lightning_distance_passed(self.origin, e_ai_zombie.origin, n_ball_range, e_ai_zombie.n_staff_lightning_ball_range_check_multiplier);
    b_trace_passed = staff_lightning_trace_passed(self.origin, e_ai_zombie.origin);
    return (b_trace_passed && b_distance_passed && !IS_TRUE(e_ai_zombie.in_the_ground) && !IS_TRUE(e_ai_zombie.in_the_ceiling) && !IS_TRUE(e_ai_zombie.b_staff_lightning_ball_immune) && !IS_TRUE(e_ai_zombie.b_staff_hit) && !IS_TRUE(e_ai_zombie.b_is_staff_lightning_zapped));
}

/* 
STAFF LIGHTNING BALL DAMAGE ZOMBIE
Description : This function handles logic for the upgraded Staff of Ice's area of effect charge attack damage to AI
Notes : None
*/
function staff_lightning_ball_effect_zombie(e_ball, w_weapon, e_attacker)
{
    // assert(!isDefined(self), "staff_water_ball_damage_zombie(w_weapon, e_attacker) - called on undefined entity");
    // assert(IS_TRUE(self.marked_for_death), "LIGHTNING BALL MISS - entity marked for death");
    
    // self endon("death");
    
    if (isDefined(self.ptr_staff_lightning_ball_damage_cb))
        self [[self.ptr_staff_lightning_ball_damage_cb]](e_attacker, w_weapon);
    else
        self thread staff_lightning_ball_damage_over_time(e_ball, e_attacker, w_weapon);
    
    wait .2;
}

/* 
STAFF LIGHTNING FX ARC TO ZOMBIE
Description : This function handles the trail fx from the Staff of Lightning's charged area of effect moving to the zombie
Notes : None
*/
function staff_lightning_fx_arc_to_zombie(e_ball)
{
    e_fx_model = util::spawn_model("tag_origin", e_ball.origin);
    e_fx_model linkTo(e_ball);
    self.fx_staff_bolt_arc = e_fx_model;
    
    e_fx_model endon("death");
    
    wait randomFloatRange(.1, .5);
    
    if (!isDefined(e_ball) || !isDefined(self))
    {
        if (isDefined(e_fx_model))
            e_fx_model delete();
        
        if (isDefined(self))
            self.fx_staff_bolt_arc = undefined;
        
        return;
    }
    e_fx_model unLink();
    playFxOnTag(LIGHTNINGSTAFF_TRAIL_FX, e_fx_model, "tag_origin");
    
    while (isDefined(e_fx_model) && isDefined(e_ball) && isDefined(self))
    {
        v_origin = (isDefined(self.str_staff_lightning_ball_arc_tag_override) ? (self getTagOrigin(self.str_staff_lightning_ball_arc_tag_override)) : (self getTagOrigin("j_spineupper")));
        e_fx_model moveTo(v_origin, .1);
        wait .5;
        
        if (!(isDefined(e_fx_model) && isDefined(e_ball) && isDefined(self) && isAlive(self)))
            break;
        
        e_fx_model moveTo(e_ball.origin, .1);
        wait .5;
    }
    e_fx_model delete();
    if (isDefined(self))
        self.fx_staff_bolt_arc = undefined;
        
}

/* 
STAFF LIGHTNING BALL DAMAGE OVER TIME
Description : This function handles logic for killing zombies effected by the Staff of Lightning's charge shot area of effect
Notes : None
*/
function staff_lightning_ball_damage_over_time(e_source, e_attacker, w_weapon)
{
    self endon("death");
    e_attacker endon("disconnect");
    
    self.b_is_staff_lightning_zapped = 1;
    
    self thread staff_lightning_fx_arc_to_zombie(e_source);
    WAIT_SERVER_FRAME;
    self notify("bhtn_action_notify", "electrocute");
    
    while (isDefined(e_source) && IS_TRUE(e_source.b_staff_lightning_ball_active) && isAlive(self) && distanceSquared(e_source.origin, self.origin) < SQR(w_weapon.n_ball_range))
    {
        while (IS_TRUE(self.b_staff_lightning_stunned))
            WAIT_SERVER_FRAME;
        
        self staff_lightning_zombie_shocked_fx(1);
        self hb21_zm_weap_staff_utility::staff_do_damage(w_weapon.n_ball_damage_per_second, self.origin, e_attacker, e_attacker, undefined, "MOD_RIFLE_BULLET", 0, w_weapon, undefined, undefined);
        // self doDamage(w_weapon.n_ball_damage_per_second, self.origin, e_attacker, e_attacker, 0, "MOD_RIFLE_BULLET", 0, w_weapon);
        wait 1;
    }
    if (isDefined(self))
    {
        self.b_is_staff_lightning_zapped = undefined;
        if (isDefined(self.fx_staff_bolt_arc))
            self.fx_staff_bolt_arc delete();
        
    }
}

/* 
STAFF LIGHTNING STUN ZOMBIE
Description : This function handles logic for zombies stunned by the Staff of Lightning
Notes : None
*/
function staff_lightning_stun_zombie()
{
    self endon("death");
    self.b_staff_lightning_stunned = 2;
    self staff_lightning_zombie_shocked_fx(1);
    self notify("bhtn_action_notify", "electrocute");
}

/* 
STAFF LIGHTNING ZOMBIE SHOCKED FX
Description : This function handles logic for killing zombies fx getting shocked by the Staff of Lightning
Notes : None
*/
function staff_lightning_zombie_shocked_fx(b_play)
{
    self endon("death");
    
    if (!IS_TRUE(b_play))
    {
        self clientfield::increment((isVehicle(self) ? LIGHTNINGSTAFF_SHOCK_EYES_FX_VEH_CF : LIGHTNINGSTAFF_SHOCK_EYES_FX_CF), 2);
        self clientfield::increment((isVehicle(self) ? LIGHTNINGSTAFF_IMPACT_FX_VEH_CF : LIGHTNINGSTAFF_IMPACT_FX_CF), 2);
        return;
    }
    
    self playSound(LIGHTNINGSTAFF_ZOMBIE_SIZZLE_SOUND);
    self playSound(LIGHTNINGSTAFF_ZOMBIE_FX_SOUND);
    
    self clientfield::increment((isVehicle(self) ? LIGHTNINGSTAFF_SHOCK_EYES_FX_VEH_CF : LIGHTNINGSTAFF_SHOCK_EYES_FX_CF), (IS_TRUE(self.head_gibbed) ? 2 : 1));
    self clientfield::increment((isVehicle(self) ? LIGHTNINGSTAFF_IMPACT_FX_VEH_CF : LIGHTNINGSTAFF_IMPACT_FX_CF), 1);
}

/* 
STAFF LIGHTNING DISTANCE PASSED
Description : This function is used to perform checks on each zombie passed to it are valid to be hit by the Staff of Lightning charged attack
Notes : None
*/
function staff_lightning_distance_passed(v_start_origin, v_end_origin, n_range, n_range_multiplier = 1)
{
    return (distance2dSquared(v_start_origin, v_end_origin) < SQR(n_range) * n_range_multiplier);
}

/* 
STAFF LIGHTNING TRACE PASSED === CHECK
Description : This function is used to perform checks on each zombie passed to it are valid to be hit by the Staff of Lightning charged attack
Notes : None
*/
function staff_lightning_trace_passed(v_start_origin, v_end_origin, b_hit_characters = 0, e_ignore_ent = undefined, e_ignore_ent_2 = undefined, b_fx_visibility = 0, b_ignore_water = 1)
{
    return (bulletTracePassed(v_start_origin + (10, 10, 32), v_end_origin + (10, 10, 32), b_hit_characters, e_ignore_ent, e_ignore_ent_2, b_fx_visibility, b_ignore_water) || bulletTracePassed(v_start_origin + (-10, -10, 64), v_end_origin + (-10, -10, 64), b_hit_characters, e_ignore_ent, e_ignore_ent_2, b_fx_visibility, b_ignore_water));
}    


function staff_lightning_parasite_init_cb()
{
    self.str_staff_lightning_ball_arc_tag_override = "j_spine";
    // self.n_staff_fire_volcano_range_check_multiplier = 1.8;
    // self.ptr_staff_fire_death_cb = &staff_fire_parasite_death_cb;
}

function staff_lightning_dog_init_cb()
{
    self.str_staff_lightning_ball_arc_tag_override = "j_spine";
    // self.str_staff_fire_volcano_tag_check_override = "j_spine";
    // self.n_staff_fire_volcano_range_check_multiplier = 1.8;
    // self.ptr_staff_fire_death_cb = &staff_fire_parasite_death_cb;
}
