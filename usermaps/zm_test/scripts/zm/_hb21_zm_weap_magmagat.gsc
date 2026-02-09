#using scripts\codescripts\struct;
#using scripts\shared\_burnplayer;
#using scripts\shared\array_shared;
#using scripts\shared\system_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\animation_shared;
#using scripts\shared\util_shared;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\ai\systems\gib;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_utility;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_hb21_zm_weap_magmagat.gsh;

#namespace hb21_zm_weap_magmagat; 

#precache("xmodel", MAGMAGAT_PROJECTILE_MODEL);

#using_animtree("generic");

REGISTER_SYSTEM_EX("hb21_zm_weap_magmagat", &__init__, &__main__, undefined)

function __init__()
{
    clientfield::register("missile", "magmagat_missile", VERSION_SHIP, 1, "int");
    
    level._effect["magmagat_aoe"] = MAGMAGAT_AOE_FX;
    level._effect["magmagat_impact"] = MAGMAGAT_IMPACT_FX;
    
    level.w_magmagat = getWeapon(MAGMAGAT_WEAPONFILE);
    level.w_magmagat.ptr_weapon_grenade_fired_cb = &magmagat_fired;
    level.w_magmagat_upgraded = getWeapon(MAGMAGAT_UPGRADED_WEAPONFILE);
    level.w_magmagat_upgraded.ptr_weapon_grenade_fired_cb = &magmagat_fired;
    
    callback::on_spawned(&magmagat_on_player_spawned);
    zm_spawner::register_zombie_damage_callback(&magmagat_zombie_damage_response);
}

function __main__()
{
    array::thread_all(level.zombie_spawners, &spawner::add_spawn_function, &magmagat_watch_for_lava_pool_zombie);
}

function magmagat_on_player_spawned()
{
    self thread magmagat_watch_for_lava_pool_player();
    self thread monitor_weapon_fired();
    self thread monitor_weapon_missile_fired();
    self thread monitor_weapon_grenade_fired();
}

function magmagat_zombie_damage_response(str_mod, str_hit_location, v_hit_origin, e_player, n_amount, w_weapon, v_direction_vec, str_tag_name, str_model_name, str_part_name, str_flags, e_inflictor, n_chargeLevel)
{
    if (isDefined(w_weapon) && (w_weapon == level.w_magmagat || w_weapon == level.w_magmagat_upgraded))
        return 1;
    
    return 0;
}

function monitor_weapon_fired()
{
    self endon("death_or_disconnect");
    self notify("monitor_weapon_fired");
    self endon("monitor_weapon_fired");
    
    while (isDefined(self))
    {
        self waittill("weapon_fired", w_weapon);
        
        if (isDefined(w_weapon.ptr_weapon_fired_cb))
            self thread [[w_weapon.ptr_weapon_fired_cb]](w_weapon);
            
    }
}

function monitor_weapon_missile_fired()
{
    self endon("death_or_disconnect");
    self notify("monitor_weapon_missile_fired");
    self endon("monitor_weapon_missile_fired");
    
    while (isDefined(self))
    {
        self waittill("missile_fire", e_projectile, w_weapon);
        
        if (isDefined(e_projectile) && IS_TRUE(e_projectile.b_additional_shot))
            continue;
        
        if (isDefined(w_weapon.ptr_weapon_missile_fired_cb))
            self thread [[w_weapon.ptr_weapon_missile_fired_cb]](e_projectile, w_weapon, self.chargeshotlevel);
            
    }
}

function monitor_weapon_grenade_fired()
{
    self endon("death_or_disconnect");
    self notify("monitor_weapon_grenade_fired");
    self endon("monitor_weapon_grenade_fired");
    
    while (isDefined(self))
    {
        self waittill("grenade_fire", e_projectile, w_weapon);
        
        if (isDefined(e_projectile) && IS_TRUE(e_projectile.b_additional_shot))
            continue;
        
        if (isDefined(w_weapon.ptr_weapon_grenade_fired_cb))
            self thread [[w_weapon.ptr_weapon_grenade_fired_cb]](e_projectile, w_weapon, self.chargeshotlevel);
            
    }
}

function magmagat_fired(e_projectile, w_weapon)
{
    b_is_not_upgraded = w_weapon != level.w_magmagat_upgraded;
    
    e_projectile util::waittill_any("death", "grenade_bounce", "stationary", "grenade_stuck");
    
    if (!isDefined(e_projectile))
        return;
    
    a_targets = getAITeamArray(level.zombie_team);
    for (i = 0; i < a_targets.size; i++)
    {
        if (e_projectile isLinkedTo(a_targets[i]))
        {
            e_projectile zm_utility::create_zombie_point_of_interest((b_is_not_upgraded ? 250 : 500) , (b_is_not_upgraded ? 5 : 10), 10000);
            a_targets[i] thread magmagat_target_animate_and_die(1, self);
            e_projectile thread magmagat_grenade_detonate_on_target_death(a_targets[i]);
            return;
        }
    }
    
    e_trigger_radius = spawn("trigger_radius", e_projectile.origin, 1, (b_is_not_upgraded ? 32 : 64), 32);
    e_trigger_radius.targetname = "magmagat_lava_pool";
    e_trigger_radius.owner = self;
    e_trigger_radius.w_weapon = w_weapon;
    
    e_projectile zm_utility::create_zombie_point_of_interest((b_is_not_upgraded ? 250 : 500) , (b_is_not_upgraded ? 5 : 10), 10000);
    e_projectile setModel(MAGMAGAT_PROJECTILE_MODEL);
    e_projectile clientfield::set("magmagat_missile", 1);

    wait MAGMAGAT_LAVA_POOL_DURATION;
    
    e_trigger_radius delete();
    e_projectile delete();
}

function magmagat_watch_for_lava_pool_zombie()
{
    self notify("magmagat_watch_for_lava_pool_player");
    self endon("magmagat_watch_for_lava_pool_player");
    self endon("death_or_disconnect");
    while (1)
    {
        e_touching = undefined;
        a_lava_pools = getEntArray("magmagat_lava_pool", "targetname");
        if (isDefined(a_lava_pools) && isArray(a_lava_pools) && a_lava_pools.size > 0)
        {
            for (i = 0; i < a_lava_pools.size; i++)
            {
                if (self isTouching(a_lava_pools[i]) && isAlive(self))
                {
                    e_touching = a_lava_pools[i];
                    break;
                }
            }
        }
        if (isDefined(e_touching))
        {
            self.b_touching_magmagat_lava_pool = 1;
            self notify("touched_magmagat_lava_pool");
            n_damage = int(self.maxhealth / 4);
            self doDamage(n_damage, e_touching.origin, e_touching.owner, undefined, undefined, "MOD_BURNED", 0, e_touching.w_weapon);
            self clientfield::set("arch_actor_fire_fx", (isAlive(self) ? 1 : 2));
            self playLoopSound("chr_burning_loop", 1);
            wait .25;
        }
        else
        {
            if (IS_TRUE(self.b_touching_magmagat_lava_pool))
                self thread magmagat_watch_for_lava_pool_cancel_fire();
            
            WAIT_SERVER_FRAME;
        }
    }
}

function magmagat_watch_for_lava_pool_cancel_fire()
{
    self endon("death");
    self endon("touched_magmagat_lava_pool");
    self stopLoopSound(2);
    wait 4;
    self clientfield::set("arch_actor_fire_fx", 0);
}

function magmagat_watch_for_lava_pool_player()
{
    self notify("magmagat_watch_for_lava_pool_player");
    self endon("magmagat_watch_for_lava_pool_player");
    self endon("death_or_disconnect");
    while (1)
    {
        e_touching = undefined;
        a_lava_pools = getEntArray("magmagat_lava_pool", "targetname");
        if (isDefined(a_lava_pools) && isArray(a_lava_pools) && a_lava_pools.size > 0)
        {
            for (i = 0; i < a_lava_pools.size; i++)
            {
                if (self isTouching(a_lava_pools[i]) && zombie_utility::is_player_valid(self))
                {
                    e_touching = a_lava_pools[i];
                    break;
                }
            }
        }
        if (isDefined(e_touching))
        {
            self burnplayer::SetPlayerBurning(2, 0, 0, undefined, undefined);
            self playLoopSound("evt_searing_flesh", 1);
            self doDamage(20, e_touching.origin, self, undefined, undefined, "MOD_BURNED", 0, e_touching.w_weapon);
            wait .5;
        }
        else
        {
            self stopLoopSound(2);
            WAIT_SERVER_FRAME;
        }
    }
}

function magmagat_grenade_detonate_on_target_death(e_target)
{
    self endon("death");
    e_target endon("magmagat_target_timeout");
    e_target waittill("magmagat_target_killed");
    self.fuse_reset = 1;
    self resetMissileDetonationTime(.05);
}

function magmagat_target_timeout(n_fuse_timer = 1)
{
    self endon("death");
    self endon("magmagat_target_killed");
    wait n_fuse_timer;
    self notify("magmagat_target_timeout");
}

function magmagat_check_for_target_death()
{
    self endon("magmagat_target_killed");
    self waittill("death");
    self notify("killed_by_a_magmagat");
    self notify("magmagat_target_killed");
}

function magmagat_target_animate_and_die(n_fuse_timer, e_inflictor)
{
    self endon("death");
    self endon("magmagat_target_timeout");
    self thread magmagat_target_timeout(n_fuse_timer);
    self thread magmagat_check_for_target_death();
    self.blockingPain = 1;
    self.b_acid_stunned = 1;
    self clientfield::set("arch_actor_fire_fx", 1);
    self playLoopSound("chr_burning_loop", 1);
    wait n_fuse_timer;
    self notify("killed_by_a_magmagat");
    gibServerUtils::annihilate(self);
    self doDamage(self.health + 666, self.origin, e_inflictor);    
}
