#using scripts\codescripts\struct;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\math_shared;
#using scripts\shared\system_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\util_shared;
#using scripts\shared\ai\systems\gib;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\ai\zombie_death;
#using scripts\zm\_zm;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_utility;

#using scripts\zm\_hb21_zm_weap_utility;
#using scripts\zm\_hb21_zm_weap_staff_utility;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\zm\_hb21_zm_weap_staff_fire.gsh;
#insert scripts\zm\_hb21_zm_weap_staff_utility.gsh;

#precache("fx", FIRESTAFF_UPGRADE_GLOW);

#namespace hb21_zm_weap_staff_fire; 

REGISTER_SYSTEM_EX("hb21_zm_weap_staff_fire", &__init__, &__main__, undefined)


// ai.b_staff_fire_immune - BOOLEAN - enable on ai to stop the Staff of Fire damaging them
// ai.b_staff_fire_upgraded_immune - BOOLEAN - enable on ai to stop the upgraded Staff of Fire damaging them

// ai.ptr_staff_fire_actor_damage_cb - FUNCTION_POINTER - set your own function here to manipulate the damage caused from the Staff of Fire on actors
//                                                      - (e_inflictor, e_attacker, n_damage, f_flags, str_means_of_death, w_weapon, v_point, v_direction, str_hit_loc, n_offset_time, n_bone_index, str_surface_type)
//                                                      - modify the damage dealt
//                                                      - return the finalised damage amount (Int)
//                                                      - return -1 for no change
// ai.ptr_staff_fire_vehicle_damage_cb - FUNCTION_POINTER - set your own function here to manipulate the damage caused from the Staff of Fire on vehicles
//                                                        - (e_inflictor, e_attacker, n_damage, str_flags, str_means_of_death, w_weapon, v_point, v_direction, str_hit_loc, v_damage_origin, n_offset_time, b_damage_drom_underneath, n_model_index, str_part_name, str_surface_type)
//                                                        - modify the damage dealt
//                                                        - return the finalised damage amount (Int)
//                                                        - return original damage for no change
// ai.ptr_staff_fire_zombie_damage_cb - FUNCTION_POINTER - set your own function here to change what happens when a zombie is hit by the Staff of Fire
//                                                       - (str_means_of_death, str_hit_loc, v_point, e_attacker, n_damage, w_weapon, v_direction, str_tag_name, str_model_name, str_part_name, f_flags, e_inflictor, n_charge_level)
//                                                       - function that is called after an ai is damaged - doesnt trigger if the damage kills the ai
//                                                       - return true / 1 to stop any other zombie damage callbacks still in the queue
// ai.ptr_staff_fire_death_cb - FUNCTION_POINTER - set your own function here to change the death behavior when killed by the Staff of Fire
//                                               - (e_attacker)
//                                               - function that is called when an ai dies

// ai.b_staff_fire_volcano_immune - BOOLEAN - enable on ai to stop the volcano being able to effect them at all
// ai.n_staff_fire_volcano_range_check_multiplier - FLOAT - option to increase the distance checks used in the volcano logic checks - can be important on flying AI as their height from the ground has a dramatic impact vs an ai on the ground

function __init__()
{    
    level.a_staff_fire_weaponfiles = [];
    
    staff_fire_register_weapon_for_level("t9_1911_rdw_up_up", undefined, undefined); // don't use staff_fire_fired if not on a projectile ...
    staff_fire_register_weapon_for_level("iw8_ak47_up_up", undefined, &staff_fire_upgrade_fired);
    
    clientfield::register("scriptmover", FIRESTAFF_VOLCANO_CF, VERSION_SHIP, 1, "int");
    clientfield::register("actor", FIRESTAFF_ZOMBIE_BURN_CF, VERSION_SHIP, 1, "int");
    clientfield::register("vehicle", FIRESTAFF_ZOMBIE_BURN_CF, VERSION_SHIP, 1, "int");
    
    zm::register_actor_damage_callback(&staff_fire_zombie_actor_damage_cb);
    zm::register_vehicle_damage_callback(&staff_fire_vehicle_damage_cb);
    zm_spawner::register_zombie_damage_callback(&staff_fire_zombie_damage_cb);
    zm_spawner::register_zombie_death_event_callback(&staff_fire_death_event_cb);
    
    level.ptr_staff_fire_zombie_set_and_restore_flame_state = &staff_fire_zombie_set_and_restore_flame_state;
    
    spawner::add_archetype_spawn_function("parasite", &staff_fire_parasite_init_cb, undefined, undefined, undefined, undefined, undefined );
    spawner::add_archetype_spawn_function("zombie_dog", &staff_fire_dog_init_cb, undefined, undefined, undefined, undefined, undefined );
}

function __main__()
{
}

/* 
STAFF FIRE REGISTER WEAPON FOR LEVEL
Description : This function handles registering this weapon file as a staff of fire variant and sets up some required properties
Notes : None
*/
function staff_fire_register_weapon_for_level(str_weapon, ptr_weapon_fired_cb = undefined, ptr_weapon_missile_fired_cb = undefined, ptr_weapon_grenade_fired_cb = undefined, ptr_weapon_obtained_cb = undefined, ptr_weapon_lost_cb = undefined, ptr_weapon_reloaded_cb = undefined, ptr_weapon_pullout_cb = undefined, ptr_weapon_putaway_cb = undefined)
{
    DEFAULT(level.a_staff_fire_weaponfiles, []);
    
    a_weapon_data = tableLookupRow(STAFF_FIRE_TABLE_FILE, tableLookupRowNum(STAFF_FIRE_TABLE_FILE, STAFF_TABLE_COLUMN_WEAPONFILE, str_weapon));
    if (!isDefined(a_weapon_data))
    {
        a_weapon_data = tableLookupRow(STAFF_FIRE_TABLE_FILE, tableLookupRowNum(STAFF_FIRE_TABLE_FILE, STAFF_TABLE_COLUMN_WEAPONFILE,     "default")            );
    }
    if (!isDefined(a_weapon_data))
    {
        return;
    }
        
    w_weapon = getWeapon(str_weapon);
    w_weapon.b_is_upgrade = (toLower(  a_weapon_data[STAFF_TABLE_COLUMN_IS_UPGRADE]) == "true");
    w_weapon.n_damage = int(a_weapon_data[STAFF_TABLE_COLUMN_DAMAGE]);
    w_weapon.n_burn_damage = int(a_weapon_data[STAFF_FIRE_TABLE_COLUMN_BURN_DAMAGE]);
    w_weapon.n_burn_duration = float(a_weapon_data[STAFF_FIRE_TABLE_COLUMN_BURN_DURATION]);
    w_weapon.n_volcano_range = int(a_weapon_data[STAFF_FIRE_TABLE_COLUMN_VOLCANO_RANGE]);
    w_weapon.n_volcano_lifetime = float(a_weapon_data[STAFF_FIRE_TABLE_COLUMN_VOLCANO_LIFETIME]);
    
    hb21_zm_weap_staff_utility::register_staff_weapon_for_level(w_weapon, ptr_weapon_fired_cb, ptr_weapon_missile_fired_cb, ptr_weapon_grenade_fired_cb, ptr_weapon_obtained_cb, ptr_weapon_lost_cb, ptr_weapon_reloaded_cb, ptr_weapon_pullout_cb, ptr_weapon_putaway_cb);
    
    ARRAY_ADD(level.a_staff_fire_weaponfiles, w_weapon);
}

/* 
STAFF FIRE ACTOR DAMAGE CB
Description : This function handles the damage modifications when a zombie is hit from a Staff of Fire
Notes : None
*/
function staff_fire_zombie_actor_damage_cb(e_inflictor, e_attacker, n_damage, f_flags, str_means_of_death, w_weapon, v_point, v_direction, str_hit_loc, n_offset_time, n_bone_index, str_surface_type)
{
    if (!isDefined(e_attacker) || !isPlayer(e_attacker))
        return -1;
    
    if (!hb21_zm_weap_staff_utility::is_staff_weapon(w_weapon, level.a_staff_fire_weaponfiles))
        return -1;
    
    if (hb21_zm_weap_staff_utility::is_upgraded_staff_weapon(w_weapon) && IS_TRUE(self.b_staff_fire_upgraded_immune))
        return 0;
    else if (!hb21_zm_weap_staff_utility::is_upgraded_staff_weapon(w_weapon) && IS_TRUE(self.b_staff_fire_immune))
        return 0;
    
    if (str_means_of_death == "MOD_MELEE")
        return -1;
    
    if (str_means_of_death != "MOD_BURNED")
    {
        n_pct_from_center = (n_damage - 1) / 10;
        n_pct_damage = .5 + (.5 * n_pct_from_center);
        
        n_damage = ((isDefined(e_attacker) && isPlayer(e_attacker) && e_attacker zm_powerups::is_insta_kill_active()) ? self.health + 666 : int(n_pct_damage * w_weapon.n_damage));
                
        if (isDefined(self.ptr_staff_fire_actor_damage_cb))
            n_damage = [[self.ptr_staff_fire_actor_damage_cb]](e_inflictor, e_attacker, n_damage, f_flags, str_means_of_death, w_weapon, v_point, v_direction, str_hit_loc, n_offset_time, n_bone_index, str_surface_type);
        
        if ((IS_TRUE(self.in_the_ground) || IS_TRUE(self.in_the_ceiling)) || (isDefined(w_weapon) && IS_TRUE(w_weapon.b_is_upgrade) && n_pct_from_center > .5 && n_damage > self.health && math::cointoss()))
            self.b_staff_fire_death_will_gib = 1;
            
        return n_damage;
    }
    return -1;
}

/* 
STAFF FIRE VEHICLE DAMAGE CB
Description : This function handles the damage modifications when a zombie vehicle is hit from a Staff of Fire
Notes : None
*/
function staff_fire_vehicle_damage_cb(e_inflictor, e_attacker, n_damage, str_flags, str_means_of_death, w_weapon, v_point, v_direction, str_hit_loc, v_damage_origin, n_offset_time, b_damage_drom_underneath, n_model_index, str_part_name, str_surface_type)
{
    if (!isDefined(e_attacker) || !isPlayer(e_attacker))
        return n_damage;
    
    if (!isDefined(self.damageweapon) || self.damageweapon != w_weapon)
        self.damageweapon = w_weapon;
    if (!isDefined(self.damagemod) || self.damagemod != str_means_of_death)
        self.damagemod = str_means_of_death;
    if (!isDefined(self.damagehit_origin) || self.damagehit_origin != v_point)
        self.damagehit_origin = v_point;
    if (!isDefined(self.damagelocation) || self.damagelocation != str_hit_loc)
        self.damagelocation = str_hit_loc;
        
    if (!hb21_zm_weap_staff_utility::is_staff_weapon(w_weapon, level.a_staff_fire_weaponfiles))
        return n_damage;
    if (hb21_zm_weap_staff_utility::is_upgraded_staff_weapon(w_weapon) && IS_TRUE(self.b_staff_fire_upgraded_immune))
        return 0;
    else if (!hb21_zm_weap_staff_utility::is_upgraded_staff_weapon(w_weapon) && IS_TRUE(self.b_staff_fire_immune))
        return 0;
    
    if (str_means_of_death == "MOD_MELEE")
        return n_damage;
    
    if (str_means_of_death != "MOD_BURNED")
    {
        n_pct_from_center = (n_damage - 1) / 10;
        n_pct_damage = .5 + (.5 * n_pct_from_center);
        
        n_damage = ((isDefined(e_attacker) && isPlayer(e_attacker) && e_attacker zm_powerups::is_insta_kill_active()) ? self.health + 666 : int(n_pct_damage * w_weapon.n_damage));
        
        if (isDefined(self.ptr_staff_fire_vehicle_damage_cb))
            n_damage = [[self.ptr_staff_fire_vehicle_damage_cb]](e_inflictor, e_attacker, n_damage, str_flags, str_means_of_death, w_weapon, v_point, v_direction, str_hit_loc, v_damage_origin, n_offset_time, b_damage_drom_underneath, n_model_index, str_part_name, str_surface_type);
        
        if (isDefined(w_weapon) && IS_TRUE(w_weapon.b_is_upgrade) && n_pct_from_center > .5 && n_damage > self.health && math::cointoss())
            self.b_staff_fire_death_will_gib = 1;
        
    }
    return n_damage;
}

/* 
STAFF FIRE ZOMBIE DAMAGE CB
Description : This function handles the reaction when a zombie is hit from a Staff of Fire
Notes : None
*/
function staff_fire_zombie_damage_cb(str_means_of_death, str_hit_loc, v_point, e_attacker, n_damage, w_weapon, v_direction, str_tag_name, str_model_name, str_part_name, f_flags, e_inflictor, n_charge_level)
{
    if (!isDefined(e_attacker) || !isPlayer(e_attacker))
        return 0;
    
    if (!hb21_zm_weap_staff_utility::is_staff_weapon(w_weapon, level.a_staff_fire_weaponfiles) || str_means_of_death == "MOD_MELEE")
        return 0;
    
    if (isDefined(self.ptr_staff_fire_zombie_damage_cb))
        return [[self.ptr_staff_fire_zombie_damage_cb]](str_means_of_death, str_hit_loc, v_point, e_attacker, n_damage, w_weapon, v_direction, str_tag_name, str_model_name, str_part_name, f_flags, e_inflictor, n_charge_level);
    else
        self thread staff_fire_flame_damage_fx(w_weapon, e_attacker, float(n_damage / w_weapon.n_damage));
    
    return 1;
}

/* 
STAFF FIRE DEATH EVENT CB
Description : This function handles logic for zombies killed by the Staff of Fire
Notes : None
*/
function staff_fire_death_event_cb(e_attacker)
{
    if (!isDefined(e_attacker) || !isPlayer(e_attacker))
        return;
    
    if (!isDefined(self) || !hb21_zm_weap_staff_utility::is_staff_weapon(self.damageweapon, level.a_staff_fire_weaponfiles) || self.damagemod == "MOD_MELEE")
        return;
    
    self setCanDamage(0);
    
    if (isDefined(self.ptr_staff_fire_death_cb))
        self [[self.ptr_staff_fire_death_cb]](e_attacker);
    else
    {
        self clientfield::set(FIRESTAFF_ZOMBIE_BURN_CF, 1);
        self thread zombie_utility::zombie_eye_glow_stop();        
    }
}

/* 
STAFF FIRE FIRED
Description : This function handles when a player fires a Staff of Fire
Notes : None
*/
function staff_fire_fired(w_weapon)
{
    self thread staff_fire_spread_shots(w_weapon);
}

/* 
STAFF FIRE UPGRADE FIRED
Description : This function handles when a player fires a Staff of Fire that is upgraded and charged
Notes : None
*/
function staff_fire_upgrade_fired(e_projectile, w_weapon, n_charge_level)
{
    e_projectile thread staff_fire_find_source(self, w_weapon);
    self thread staff_fire_additional_shots(w_weapon);
}

/* 
STAFF FIRE SPREAD SHOTS
Description : This function handles firing the extra shots for the Staff of Fire's and upgraded 'uncharged' triple shot
Notes : None
*/
function staff_fire_spread_shots(w_weapon)
{
    util::wait_network_frame();
    util::wait_network_frame();
    
    v_fwd = self getWeaponForwardDir();
    v_fire_angles = vectorToAngles(v_fwd);
    v_fire_origin = self getWeaponMuzzlePoint();
    
    n_trace = bulletTrace(v_fire_origin, v_fire_origin + v_fwd * 100, 0, undefined);
    if (n_trace["fraction"] != 1)
        return;
    
    v_left_angles = (v_fire_angles[0], v_fire_angles[1] - 15, v_fire_angles[2]);
    v_left = anglesToForward(v_left_angles);
    e_proj = magicBullet(w_weapon, v_fire_origin + v_fwd * 50, v_fire_origin + v_left * 100, self);
    e_proj.b_additional_shot = 1;
    
    util::wait_network_frame();
    util::wait_network_frame();
    
    v_fwd = self getWeaponForwardDir();
    v_fire_angles = vectorToAngles(v_fwd);
    v_fire_origin = self getWeaponMuzzlePoint();
    
    n_trace = bulletTrace(v_fire_origin, v_fire_origin + v_fwd * 100, 0, undefined);
    if (n_trace["fraction"] != 1)
        return;
    
    v_right_angles = (v_fire_angles[0], v_fire_angles[1] + 15, v_fire_angles[2]);
    v_right = anglesToForward(v_right_angles);
    e_proj = magicBullet(w_weapon, v_fire_origin + v_fwd * 50, v_fire_origin + v_right * 100, self);
    e_proj.b_additional_shot = 1;
}

/* 
STAFF FIRE FLAME DAMAGE FX
Description : This function sets up the zombie taking fire damage over time logic
Notes : None
*/
function staff_fire_flame_damage_fx(w_weapon, e_attacker, n_pct_damage = 1)
{
    self endon("death");
    if (IS_TRUE(self.is_on_fire))
        return;
    
    self.is_on_fire = 1;
    self thread staff_fire_zombie_set_and_restore_flame_state();
    wait .5;
    self thread staff_fire_flame_damage_over_time(e_attacker, w_weapon, n_pct_damage);
}

/* 
STAFF FIRE FLAME DAMAGE OVER TIME
Description : This function handles zombies taking damage over time when they are on fire
Notes : None
*/
function staff_fire_flame_damage_over_time(e_attacker, w_weapon, n_pct_damage)
{
    e_attacker endon("disconnect");
    self endon("death");
    self endon("stop_flame_damage");
    
    self thread staff_fire_on_fire_timeout(w_weapon.n_burn_duration);
    while (isDefined(self))
    {
        if (isDefined(e_attacker) && isPlayer(e_attacker))
            self hb21_zm_weap_staff_utility::staff_do_damage(int(w_weapon.n_burn_damage * n_pct_damage), self.origin, e_attacker, e_attacker, undefined, "MOD_BURNED", 0, w_weapon, undefined, undefined);
            
        wait 1;
    }
}

/* 
STAFF FIRE ADDITIONAL SHOTS
Description : This function handles firing the extra shots for the Staff of Fire's upgraded 'charged' triple / double shot
Notes : None
*/
function staff_fire_additional_shots(w_weapon)
{
    self endon("disconnect");
    self endon("death");
    self endon("weapon_change");
    
    v_player_angles = vectorToAngles(self getWeaponForwardDir());
    n_player_pitch = v_player_angles[0] + 5;
    n_player_yaw = v_player_angles[1] + randomFloatRange(-15, 15);
    v_shot_angles = (n_player_pitch, n_player_yaw, v_player_angles[2]);
    
    v_shot_start = self getWeaponMuzzlePoint();
    v_shot_end = v_shot_start + anglesToForward(v_shot_angles);
    
    e_projectile = magicBullet(w_weapon, v_shot_start, v_shot_end, self);
    e_projectile.b_additional_shot = 1;
    
    e_projectile thread staff_fire_find_source(self, w_weapon);
    util::wait_network_frame();
}

function waittill_not_moving()
{
    self endon("death");
    self endon("explode");
    self endon("stationary");

    prevorigin = self.origin;
    while (1)
    {
        wait .15;
        if (self.origin == prevorigin)
            break;
    
        prevorigin = self.origin;
    }
    
    self notify("stationary");
}

/* 
STAFF FIRE UPDATE GRENADE FUSE
Description : This function handles forcing the Staff of Fire's charge shot projectile to detonate on impact
Notes : None
*/
function staff_fire_update_grenade_fuse(e_player)
{
    e_player endon("disconnect");
    self endon("grenade_dud");
    self thread waittill_not_moving();
    // self endon("explode");
    self util::waittill_any("stationary", "grenade_bounce", "death");
    if (isDefined(self))
        self resetMissileDetonationTime(0);
    
}

/* 
STAFF FIRE FIND SOURCE
Description : This function handles logic for the Staff of Fire's upgraded charged attack
Notes : None
*/
function staff_fire_find_source(e_player, w_weapon)
{
    e_player endon("disconnect");
    
    self thread staff_fire_update_grenade_fuse(e_player);
    
    self waittill("explode", v_impact_origin);
    
    e_player thread staff_fire_position_volcano(v_impact_origin, w_weapon);
}

/* 
STAFF FIRE POSITION VOLCANO
Description : This function handles logic for the upgraded Staff of Fire's area of effect charge attack
Notes : None
*/
function staff_fire_position_volcano(v_impact_origin, w_weapon)
{
    e_fx_model = util::spawn_model("tag_origin", v_impact_origin);
    e_fx_model endon("death");
    
    e_fx_model clientfield::set(FIRESTAFF_VOLCANO_CF, 1);
    
    e_fx_model staff_fire_volcano_kill_zombies(w_weapon, self);
    
    e_fx_model clientfield::set(FIRESTAFF_VOLCANO_CF, 0);
    
    wait 4;
    e_fx_model delete();
}

/* 
STAFF FIRE VOLCANO KILL ZOMBIES
Description : This function handles logic for the Staff of Fire's upgraded charged attack area of effect effecting zombies
Notes : None
*/
function staff_fire_volcano_kill_zombies(w_weapon, e_player)
{
    e_player endon("death_or_disconnect");
    self endon("death");
    
    n_alive_time = w_weapon.n_volcano_lifetime;
    while (n_alive_time > 0 && isDefined(self))
    {
        a_zombies = self staff_fire_volcano_effected_zombies(w_weapon, n_alive_time);
        array::thread_all(a_zombies, &staff_fire_volcano_damage_zombie, w_weapon, e_player);
        
        wait FIRESTAFF_VOLCANO_STEP_SIZE;
        n_alive_time -= FIRESTAFF_VOLCANO_STEP_SIZE;
    }
}

/* 
STAFF FIRE VOLCANO EFFECTED ZOMBIES
Description : Returns an array of zombies in the Staff of Fire's charge attack area of effect
Notes : None
*/
function staff_fire_volcano_effected_zombies(w_weapon, n_alive_time)
{
    return array::filter(util::get_array_of_closest(self.origin, getAITeamArray(level.zombie_team), undefined, undefined, undefined), 1, &staff_fire_volcano_effect_zombie_valid, self, ((n_alive_time - FIRESTAFF_VOLCANO_STEP_SIZE <= 0) ? w_weapon.n_volcano_range * FIRESTAFF_VOLCANO_LAST_CHECK_RANGE_MULTIPLIER : w_weapon.n_volcano_range));
}

/* 
STAFF FIRE VOLCANO EFFECT ZOMBIE VALID
Description : This function is used to perform checks on each zombie passed to it are valid to be hit by the Staff of Fire's charged attack
Notes : None
*/
function staff_fire_volcano_effect_zombie_valid(e_ai_zombie, e_volcano, n_volcano_range)
{
    return (!IS_TRUE(e_ai_zombie.b_staff_fire_volcano_immune) && hb21_zm_weap_staff_utility::staff_distance_2d_squared_passed(e_volcano.origin, e_ai_zombie.origin, n_volcano_range, e_ai_zombie.n_staff_fire_volcano_range_check_multiplier) && !IS_TRUE(e_ai_zombie.is_on_fire) && isAlive(e_ai_zombie) && hb21_zm_weap_staff_utility::staff_trace_passed(e_volcano.origin, e_ai_zombie.origin));
}

/* 
STAFF FIRE VOLCANO DAMAGE ZOMBIE
Description : This function handles logic for the upgraded Staff of Ice's area of effect charge attack damage to AI
Notes : None
*/
function staff_fire_volcano_damage_zombie(w_weapon, e_attacker)
{
    self thread staff_fire_flame_damage_fx(w_weapon, e_attacker);
}

/* 
STAFF FIRE ZOMBIE SET AND RESTORE FLAME DAMAGE
Description : This function sets the zombies move speed and fx for when hes on fire and sets it back after
Notes : None
*/
function staff_fire_zombie_set_and_restore_flame_state()
{
    self endon("death");
    // self endon("fire_staff_kill");
    if (!isAlive(self))
        return;
    
    self.b_staff_fire_stunned = 1;
    self zombie_utility::set_zombie_run_cycle_override_value("burned");
    self clientfield::set(FIRESTAFF_ZOMBIE_BURN_CF, 1);
    self waittill("stop_flame_damage");
    self clientfield::set(FIRESTAFF_ZOMBIE_BURN_CF, 0);
    self zombie_utility::set_zombie_run_cycle_restore_from_override();
}

/* 
STAFF FIRE ON FIRE TIMEOUT
Description : This function ends the fire damage over time logic after the time is up
Notes : None
*/
function staff_fire_on_fire_timeout(n_duration)
{
    self endon("death");
    wait n_duration;
    self.is_on_fire = undefined;
    self notify("stop_flame_damage");
}

function staff_fire_parasite_init_cb()
{
    self.n_staff_fire_volcano_range_check_multiplier = 1.8;
    self.ptr_staff_fire_vehicle_damage_cb = &staff_fire_parasite_damage_cb;
    self.ptr_staff_fire_zombie_damage_cb = &staff_fire_parasite_zombie_damage_cb;
    self.ptr_staff_fire_death_cb = &staff_fire_parasite_death_cb;
}

function staff_fire_parasite_damage_cb(e_inflictor, e_attacker, n_damage, str_flags, str_means_of_death, w_weapon, v_point, v_direction, str_hit_loc, v_damage_origin, n_offset_time, b_damage_drom_underneath, n_model_index, str_part_name, str_surface_type)
{
    return self.health + 666;
}

function staff_fire_parasite_zombie_damage_cb(str_means_of_death, str_hit_loc, v_point, e_attacker, n_damage, w_weapon, v_direction, str_tag_name, str_model_name, str_part_name, f_flags, e_inflictor, n_charge_level)
{
    return 1;
}

function staff_fire_parasite_death_cb(e_attacker)
{
    self thread hb21_zm_weap_staff_utility::zombie_gib_all("j_spine");
}

function staff_fire_dog_init_cb()
{
    self.ptr_staff_fire_actor_damage_cb = &staff_fire_dog_damage_cb;
    self.ptr_staff_fire_zombie_damage_cb = &staff_fire_dog_zombie_damage_cb;
    self.ptr_staff_fire_death_cb = &staff_fire_dog_death_cb;
}

function staff_fire_dog_damage_cb(e_inflictor, e_attacker, n_damage, f_flags, str_means_of_death, w_weapon, v_point, v_direction, str_hit_loc, n_offset_time, n_bone_index, str_surface_type)
{
    return self.health + 666;
}

function staff_fire_dog_zombie_damage_cb(str_means_of_death, str_hit_loc, v_point, e_attacker, n_damage, w_weapon, v_direction, str_tag_name, str_model_name, str_part_name, f_flags, e_inflictor, n_charge_level)
{
    return 1;
}

function staff_fire_dog_death_cb(e_attacker)
{
    self thread hb21_zm_weap_staff_utility::zombie_gib_all("j_spine");
}

