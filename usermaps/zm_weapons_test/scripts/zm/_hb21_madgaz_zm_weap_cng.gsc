/*#==================================================================###
###                                                                  ###
###                 Harry Bo21 & Madgazs Black Ops 3                 ###
###                        Compact Nuke Gun                          ###
###                                                                  ###
###==================================================================#*/

/*======================================================================
                                CREDITS
========================================================================
alexbgt
AllModz
AndyWhelen
Azsry
BluntStuffy
Collie
DTZxPorter
Easyskanka
Erthrock
Frost Iceforge
GerardS0406
Hubashuba
IperBreach
JAMAKINBACONMAN
JBird632
JiffyNoodles
Lilrifa
MadGaz
MZSlayer
NoobForLunch
PCModder
ProGamerzFTW
ProRevenge
Raptroes
RedSpace200
Scobalula
Sethnorris
Smasher248
StevieWonder87
Symbo
TheIronicTruth
TheSkyeLord
thezombieproject
TomBMX
Treyarch and Activision
Will Luffey
WillJones1989
Yen466
Zeroy
=====================================================================*/

#using scripts\codescripts\struct;
#using scripts\shared\array_shared;
#using scripts\shared\system_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\compass;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\animation_shared;
#using scripts\shared\util_shared;
#using scripts\shared\trigger_shared;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\ai\zombie_shared;
#using scripts\shared\system_shared;
#using scripts\zm\_util;
#using scripts\zm\_load;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_zonemgr;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_net;
#using scripts\zm\_zm_weap_thundergun;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\zm\_hb21_madgaz_zm_weap_cng.gsh;

#using_animtree("generic");

#namespace hb21_madgaz_zm_weap_cng; 

#precache("fx", CNG_ELECTRIC_BOLT);
#precache("fx", CNG_STORMED);

REGISTER_SYSTEM("hb21_madgaz_zm_weap_cng", &__init__, undefined)

//*****************************************************************************
// MAIN
//*****************************************************************************

function __init__()
{
    callback::on_spawned(&cng_on_player_spawned);
    
    zm::register_player_friendly_fire_callback(&cng_friendly_damage_override);
    zm::register_actor_damage_callback(&cng_actor_damage_override);
}

function cng_friendly_damage_override(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, weapon, vPoint, vDir, sHitLoc, psOffsetTime, boneIndex)
{
    if (self laststand::player_is_in_laststand() && isDefined(weapon) && is_cng_upgraded(weapon))
        self notify("remote_revive", eAttacker);
    
}

function cng_on_player_spawned()
{
    self thread cng_wait_for_fired();
    self thread monitor_cng_charge_level();
}

function monitor_cng_charge_level() 
{
    self endon("death_or_disconnect");
    self notify("monitor_cng_charge_level");
    self endon("monitor_cng_charge_level");

    self.cng_charge_level = 1;
    while (isDefined(self))
    {
        w_weapon = self getCurrentWeapon();
        
        if (is_cng_weapon(w_weapon))
        {
            cng_charge_level = self get_current_cng_charge_level(w_weapon);
            
            if (!isDefined(self.cng_charge_level) || self.cng_charge_level != cng_charge_level)
                self.cng_charge_level = cng_charge_level;
            
        }
        wait .05;
    }
}

function get_current_cng_charge_level(w_weapon) 
{
    array = [];
    array[0] = 1;
    array[1] = 2;
    array[2] = 3;
    
    remaining_in_clip = int(self getWeaponAmmoClip(w_weapon));
    
    cng_charge_level = 0;
    for (i = 0; i < self.chargeshotlevel; i++)
    {
        if (remaining_in_clip < array[i])
            break;
        
        cng_charge_level++;
    }
    
    return cng_charge_level;
}

function is_cng_weapon(w_weapon)
{
    if (!isDefined(w_weapon))
        return 0;
    if (w_weapon.name != CNG_WEAPONFILE 
        && w_weapon.name != CNG_2_WEAPONFILE 
        && w_weapon.name != CNG_3_WEAPONFILE 
        && w_weapon.name != CNG_UPGRADED_WEAPONFILE 
        && w_weapon.name != CNG_2_UPGRADED_WEAPONFILE 
        && w_weapon.name != CNG_3_UPGRADED_WEAPONFILE)
        return 0;
    
    return 1;
}

function is_cng_upgraded(w_weapon)
{
    if (!isDefined(w_weapon))
        return 0;
    if (w_weapon.name != CNG_UPGRADED_WEAPONFILE && w_weapon.name != CNG_2_UPGRADED_WEAPONFILE && w_weapon.name != CNG_3_UPGRADED_WEAPONFILE)
        return 0;
    
    return 1;
}

function get_cng_base_weapon(w_weapon)
{
    if (w_weapon.name == CNG_WEAPONFILE || w_weapon.name == CNG_2_WEAPONFILE || w_weapon.name == CNG_3_WEAPONFILE)
        return getWeapon(CNG_WEAPONFILE);
    else if (w_weapon.name == CNG_UPGRADED_WEAPONFILE || w_weapon.name == CNG_2_UPGRADED_WEAPONFILE || w_weapon.name == CNG_3_UPGRADED_WEAPONFILE)
        return getWeapon(CNG_UPGRADED_WEAPONFILE);
}

function cng_wait_for_fired()
{
    self endon("death_or_disconnect");
    self notify("cng_wait_for_fired");
    self endon("cng_wait_for_fired");
    
    for (;;)
    {
        self waittill("weapon_fired", w_weapon);
        
        if (!is_cng_weapon(w_weapon))
            continue;
        
        self cng_fired(w_weapon);        
    }
}

function cng_fired(w_weapon)
{
    w_weapon = get_cng_base_weapon(w_weapon);
    
    remaining_in_clip = int(self getWeaponAmmoClip(w_weapon));
    
    if (self.cng_charge_level == 3)
        self setWeaponAmmoClip(w_weapon, remaining_in_clip - 2);
    else if (self.cng_charge_level == 2)
        self setWeaponAmmoClip(w_weapon, remaining_in_clip - 1);
    
    self thundergun(w_weapon);
}

function thundergun(w_weapon)
{
    n_damage = 500;
    n_range = 150;
    
    fire_angles = self getPlayerAngles();
    fire_origin = self getPlayerCameraPos();
    a_targets = getAiSpeciesArray("axis", "all");
    a_targets = util::get_array_of_closest(self.origin, a_targets, undefined, 12, n_range);
    
    _a675 = a_targets;
    _k675 = getFirstArrayKey(_a675);
    while (isDefined(_k675))
    {
        target = _a675[_k675];
        if (isAi(target) && !IS_TRUE(target.buzz) && !IS_TRUE(target.stormed))
        {
            if (self zm_powerups::is_insta_kill_active())
                n_damage = target.health;
                            
            target thread fire_damage_over_time(self);
            target doDamage(n_damage, target.origin, self, self, 0, "MOD_IMPACT", -1, w_weapon);
                
            if (target.health <= 0)
            {
                playSoundAtPosition("evt_cng_launch", target.origin);
                target startRagDoll();
                target launchRagdoll(staff_air_determine_launch_vector(self, target));
            }
            else
            {
                target zm_weap_thundergun::zombie_knockdown(self, 1);
            }    
                
        }
        _k675 = getNextArrayKey(_a675, _k675);
    }
}

function cng_actor_damage_override(inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, sHitLoc, psOffsetTime, boneIndex, surfaceType)
{    
    if (IS_TRUE(self.stormed))
        return 0;
    
    if (!is_cng_weapon(weapon))        
        return -1;
    
    if (meansofdeath != "MOD_PISTOL_BULLET")
        return -1;
    
    if (!isDefined(attacker.cng_charge_level))
        return -1;
    
    if (attacker.cng_charge_level == 3)
    {
        if (isDefined(meansofdeath) && meansofdeath == "MOD_PISTOL_BULLET")
            self thread fire_damage_over_time(attacker);
        
        dist1 = CNG_INNER_RANGE_CHARGE_3;
        if (is_cng_upgraded(weapon))
            dist1 = CNG_UPGRADED_INNER_RANGE_CHARGE_3;
        
        dist2 = CNG_OUTER_RANGE_CHARGE_3;
        if (is_cng_upgraded(weapon))
            dist2 = CNG_UPGRADED_OUTER_RANGE_CHARGE_3;
        
        damage = CNG_CHARGE_DAMAGE_3;
        if (is_cng_upgraded(weapon))
            damage = CNG_UPGRADED_CHARGE_DAMAGE_3;
        
        if (distance(self.origin, attacker.origin) < dist1)
        {
            self thread storm_hit(attacker, attacker.cng_charge_level, is_cng_upgraded(weapon));
            return 0;
        }    
        else if (distance(self.origin, attacker.origin) < dist2)
        {
            if (self.health <= damage)
            {
                playSoundAtPosition("evt_cng_launch", self.origin);
                self startRagDoll();
                self launchRagdoll(staff_air_determine_launch_vector(attacker, self));
            }
            else
                self zm_weap_thundergun::zombie_knockdown(attacker, 1);
            
            return damage;
        }
        else
            self zm_weap_thundergun::zombie_knockdown(attacker, 1);
        
    }
    else if (attacker.cng_charge_level == 2)
    {
        if (isDefined(meansofdeath) && meansofdeath == "MOD_PISTOL_BULLET")
            self thread fire_damage_over_time(attacker);
        
        dist1 = CNG_INNER_RANGE_CHARGE_2;
        if (is_cng_upgraded(weapon))
            dist1 = CNG_UPGRADED_INNER_RANGE_CHARGE_2;
        
        dist2 = CNG_OUTER_RANGE_CHARGE_2;
        if (is_cng_upgraded(weapon))
            dist2 = CNG_UPGRADED_OUTER_RANGE_CHARGE_2;
        
        damage = CNG_CHARGE_DAMAGE_2;
        if (is_cng_upgraded(weapon))
            damage = CNG_UPGRADED_CHARGE_DAMAGE_2;
        
        if (distance(self.origin, attacker.origin) < dist1)
        {
            self thread storm_hit(attacker, attacker.cng_charge_level, is_cng_upgraded(weapon));
            return 0;
        }    
        else if (distance(self.origin, attacker.origin) < dist2)
        {
            if (self.health <= damage)
            {
                playSoundAtPosition("evt_cng_launch", self.origin);
                self startRagDoll();
                self launchRagdoll(staff_air_determine_launch_vector(attacker, self));
            }
            else
                self zm_weap_thundergun::zombie_knockdown(attacker, 1);
            
            return damage;
        }
        else
            self zm_weap_thundergun::zombie_knockdown(attacker, 1);
        
    }
    else
    {
        if (isDefined(meansofdeath) && meansofdeath == "MOD_PISTOL_BULLET")
            self thread fire_damage_over_time(attacker);
        
        dist1 = CNG_OUTER_RANGE_CHARGE_1;
        if (is_cng_upgraded(weapon))
            dist1 = CNG_UPGRADED_OUTER_RANGE_CHARGE_1;
        
        damage = CNG_CHARGE_DAMAGE_1;
        if (is_cng_upgraded(weapon))
            damage = CNG_UPGRADED_CHARGE_DAMAGE_1;
        
        if (distance(self.origin, attacker.origin) < dist1)
        {
            if (self.health <= damage)
            {
                playSoundAtPosition("evt_cng_launch", self.origin);
                self startRagDoll();
                self launchRagdoll(staff_air_determine_launch_vector(attacker, self));
            }
            else
                self zm_weap_thundergun::zombie_knockdown(attacker, 1);
            
            return damage;
        }
        else
            self zm_weap_thundergun::zombie_knockdown(attacker, 1);
                
    }
    
    return -1;
}

function staff_air_determine_launch_vector(e_attacker, ai_target)
{
    v_launch = (vectorNormalize(ai_target.origin - e_attacker.origin) * randomIntRange(125, 150)) + (0, 0, randomIntRange(75, 150));
    return v_launch;
}

function fire_damage_over_time(attacker)
{
    self endon("death");
    self notify("stop_flame_damage");
    self notify("fire_damage_over_time");
    self endon("fire_damage_over_time");
    
    self playSound("evt_cng_ignite");
    
    if (isVehicle(self))
        self thread clientfield::increment("zm_aat_blast_furnace_burn_vehicle");
    else
        self thread clientfield::increment("zm_aat_blast_furnace_burn");
    
    self.is_on_fire = 1;
    self thread zm_spawner::damage_on_fire(attacker);
    
    wait 10;
    self.is_on_fire = undefined;
}

function damage_on_fire(player)
{
    self endon("death");
    self endon("stop_flame_damage");
    wait 2;
    
    while (IS_TRUE(self.is_on_fire))
    {
        if (level.round_number < 6)
            dmg = level.zombie_health * RandomFloatRange(.2, .3); // 20% - 30%
        else if (level.round_number < 9)
            dmg = level.zombie_health * RandomFloatRange(.15, .25);
        else if (level.round_number < 11)
            dmg = level.zombie_health * RandomFloatRange(.1, .2);
        else
            dmg = level.zombie_health * RandomFloatRange(.1, .15);

        if (isDefined(player) && isAlive(player))
            self doDamage(dmg, self.origin, player, player, undefined, "MOD_BURNED");
        else
            self doDamage(dmg, self.origin, level, level, undefined, "MOD_BURNED");
        
        wait randomFloatRange(1, 3);
    }
}

function storm_hit(attacker, cng_charge_level, upgraded)
{
    if (IS_TRUE(self.isdog))
        return;
    
    if (IS_TRUE(self.stormed))
        return;
    
    if (IS_TRUE(self.in_the_ground) || !IS_TRUE(self.completed_emerging_into_playable_area))
        return;
    
    self.stormed = 1;
    self.allowdeath = 0;
    self playSound("evt_cng_stormed");
    
    if (isVehicle(self))
    {
        self clientfield::set("tesla_shock_eyes_fx_veh", 1);
        self clientfield::set("tesla_death_fx_veh", 1);
    }
    else
    {
        self clientfield::set("tesla_shock_eyes_fx", 1);
        self clientfield::set("tesla_death_fx", 1);
    }
    
    playFxOnTag(CNG_STORMED, self, "j_spineupper");
    
    self thread staff_lightning_arc_to_surrounding_zombies(attacker, cng_charge_level, upgraded);
    
    self scene::play("cin_zm_dlc3_zombie_dth_deathray_0" + randomIntRange(1, 5), self);
    
    self.stormed = undefined;
    self.allowdeath = 1;
    
    playSoundAtPosition("evt_cng_launch", self.origin);
    self startRagDoll();
    self launchRagdoll(staff_air_determine_launch_vector(attacker, self));
    self doDamage(self.health + 666, self.origin, attacker);
}

function staff_lightning_arc_to_surrounding_zombies(e_player, cng_charge_level, upgraded)
{
    self endon("death");
    
    origin = self getTagOrigin("j_spineupper");
    
    n_range = CNG_ELECTRIC_RANGE_1;
    if (IS_TRUE(upgraded))
        n_range = CNG_UPGRADED_ELECTRIC_RANGE_1;
    if (cng_charge_level == 3)
    {
        n_range = CNG_ELECTRIC_RANGE_2;
        if (IS_TRUE(upgraded))
            n_range = CNG_UPGRADED_ELECTRIC_RANGE_2;
        
    }
    while (1)
    {
        a_enemies = getAiSpeciesArray("axis", "all");
        a_enemies = util::get_array_of_closest(origin, a_enemies, undefined, undefined, n_range);
        
        if (isDefined(a_enemies))
        {        
            for (i = 0; i < 5; i++)
            {
                if (!isDefined(a_enemies[i]))
                    break;
                if (a_enemies[i] == self)
                    continue;
                if (IS_TRUE(a_enemies[i].in_the_ground) || !IS_TRUE(a_enemies[i].completed_emerging_into_playable_area))
                    continue;
                if (IS_TRUE(a_enemies[i].buzz))
                    continue;
                
                a_enemies[i] thread staff_lightning_fx_arc_to_zombie(origin);
                a_enemies[i] thread hit_by_electric(e_player, cng_charge_level, upgraded);
            }
        }
        wait randomFloatRange(.5, .75);
    }
}

function staff_lightning_fx_arc_to_zombie(begin_origin)
{
    e_ball_fx = spawn("script_model", begin_origin);
    e_ball_fx setModel("tag_origin");
    playFxOnTag(CNG_ELECTRIC_BOLT, e_ball_fx, "tag_origin");
    e_ball_fx moveTo(self getTagOrigin("j_spineupper"), .25);
    wait .25;
    e_ball_fx delete();
}

function hit_by_electric(attacker, cng_charge_level, upgraded)
{
    self endon("death");
    anims = [];
    anims[0] = "ai_zombie_zod_stunned_electrobolt_a";
    anims[1] = "ai_zombie_zod_stunned_electrobolt_b";
    anims[2] = "ai_zombie_zod_stunned_electrobolt_c";
    anims[3] = "ai_zombie_zod_stunned_electrobolt_d";
    anims[4] = "ai_zombie_zod_stunned_electrobolt_e";
    
    self.buzz = 1;
    wait .25;
    self playSound("evt_cng_electric");
    self playSound("wpn_tesla_bounce");
    
    if (isVehicle(self))
    {
        self clientfield::set("tesla_shock_eyes_fx_veh", 1);
        self clientfield::set("tesla_death_fx_veh", 1);
    }
    else
    {
        self clientfield::set("tesla_shock_eyes_fx", 1);
        self clientfield::set("tesla_death_fx", 1);
    }
    
    self.zombie_tesla_hit = 1;
    self.tesla_death = 1;
    
    self thread fire_damage_over_time(attacker);
    
    if (!IS_TRUE(self.isdog))
        self thread animation::play(anims[randomInt(5)]);
    
    duration = CNG_ELECTRIC_DURATION_1;
    if (IS_TRUE(upgraded))
        duration = CNG_UPGRADED_ELECTRIC_DURATION_1;
    if (cng_charge_level == 3)
    {
        duration = CNG_ELECTRIC_DURATION_2;
        if (IS_TRUE(upgraded))
            duration = CNG_UPGRADED_ELECTRIC_DURATION_2;
    
    }
    wait duration;
    
    self.buzz = 0;
    
    damage = CNG_ELECTRIC_DAMAGE_1;
    if (IS_TRUE(upgraded))
        damage = CNG_UPGRADED_ELECTRIC_DAMAGE_1;
    if (cng_charge_level == 3)
    {
        damage = CNG_ELECTRIC_DAMAGE_2;
        if (IS_TRUE(upgraded))
            damage = CNG_UPGRADED_ELECTRIC_DAMAGE_2;
        
    }
    self doDamage(damage, self.origin, attacker);
    
    if (!isAlive(self))
        return;
    
    self.zombie_tesla_hit = 0;
    self.tesla_death = 0;
    self animation::stop();
    
    if (isVehicle(self))
    {
        self clientfield::set("tesla_shock_eyes_fx_veh", 0);
        self clientfield::set("tesla_death_fx_veh", 0);
    }
    else
    {
        self clientfield::set("tesla_shock_eyes_fx", 0);
        self clientfield::set("tesla_death_fx", 0);
    }
}

