#using scripts\shared\callbacks_shared;
#using scripts\shared\system_shared;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_utility.gsh;

#namespace hb21_zm_weap_utility;

REGISTER_SYSTEM("hb21_zm_weap_utility", &__init__, undefined)

function __init__()
{
    level.headshots_only = 0;   
    
    callback::on_spawned(&on_player_spawned);
}

function on_player_spawned()
{
    self thread monitor_weapon_fired();
    self thread monitor_weapon_missile_fired();
    self thread monitor_grenade_launcher_fired();
    self thread monitor_weapon_projectile_impact();
}

function monitor_grenade_launcher_fired()
{
    self endon("death_or_disconnect");
    self notify("monitor_grenade_launcher_fired");
    self endon("monitor_grenade_launcher_fired");
    
    while (isDefined(self))
    {
        self waittill("grenade_launcher_fire", e_grenade, w_weapon);
        
        if (isDefined(w_weapon.ptr_grenade_launcher_fired_cb))
            self thread [[w_weapon.ptr_grenade_launcher_fired_cb]](e_grenade, w_weapon);
            
    }
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

function monitor_weapon_projectile_impact()
{
    self endon("death_or_disconnect");
    self notify("monitor_weapon_projectile_impact");
    self endon("monitor_weapon_projectile_impact");
    
    while (isDefined(self))
    {
        self waittill("projectile_impact", w_weapon, v_position, n_radius, attacker, v_normal);
        
        if (isDefined(w_weapon.ptr_weapon_projectile_impact_cb))
            self thread [[w_weapon.ptr_weapon_projectile_impact_cb]](w_weapon, v_position, n_radius, attacker, v_normal);
            
    }
}

function register_weapon_exclude_for_explode_death_anims(w_weapon)
{
    DEFAULT(level.a_explode_death_excluded_weapons, []);
    ARRAY_ADD(level.a_explode_death_excluded_weapons, w_weapon);
}

