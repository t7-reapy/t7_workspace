#using scripts\zm\gametypes\_globallogic_score; 
#using scripts\zm\_zm_powerup_fire_sale; 
#using scripts\zm\_zm_powerup_carpenter; 
#using scripts\codescripts\struct;

#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\archetype_shared\archetype_shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\shared\ai\zombie_death;

#using scripts\zm\_zm;
#using scripts\zm\_zm_blockers;
#using scripts\zm\_zm_melee_weapon;
#using scripts\zm\_zm_pers_upgrades;
#using scripts\zm\_zm_pers_upgrades_functions;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;

#insert scripts\zm\_zm_powerups.gsh;
#insert scripts\zm\_zm_utility.gsh;

#using scripts\zm\hellround\zm_hellround_shared;
#insert scripts\zm\hellround\zm_hellround_shared.gsh;
#insert scripts\zm\hellround\zm_hellround_powerup.gsh;

#precache("material", "zom_icon_minigun");
#precache("xmodel", HRPWRUP_MODEL);
#precache("string", "ZOMBIE_POWERUP_MINIGUN");
#precache("fx", HRPWRUP_FX);

#namespace zm_hellround_powerup;

REGISTER_SYSTEM_EX("zm_hellround_powerup", &init, &main, undefined)

// #region setup

function private init()
{
    zm_powerups::register_powerup(HRPWRUP_NAME, &grab_minigun);
    zm_powerups::register_powerup_weapon(HRPWRUP_NAME, &minigun_countdown);
    zm_powerups::powerup_set_prevent_pick_up_if_drinking(HRPWRUP_NAME, true);
    zm_powerups::set_weapon_ignore_max_ammo(HRPWRUP_NAME);

    if(ToLower(GetDvarString("g_gametype")) != "zcleansed")
    {
        zm_powerups::add_zombie_powerup(
            HRPWRUP_NAME, 
            HRPWRUP_MODEL, 
            &"ZOMBIE_POWERUP_MINIGUN", 
            &func_should_drop_minigun, 
            POWERUP_ONLY_AFFECTS_GRABBER, 
            !POWERUP_ANY_TEAM,
            !POWERUP_ZOMBIE_GRABBABLE, 
            HRPWRUP_FX, 
            HRPWRUP_CLIENTFIELD, 
            HRPWRUP_TIME_NAME, 
            HRPWRUP_ON_NAME
        );
        level.zombie_powerup_weapon[HRPWRUP_NAME] = GetWeapon(HRPWRUP_WEAPON);
    }
    
    callback::on_connect(&init_player_zombie_vars);
    zm::register_actor_damage_callback(&minigun_damage_adjust);    
}

function private main()
{
    // The hellround minigun powerup is the only minigun powerup that should be used.
    zm_powerups::powerup_remove_from_regular_drops("minigun");

    level.zombie_powerups["carpenter"].func_should_drop_with_regular_powerups = &func_should_drop_carpenter_powerup;
    level.zombie_powerups["nuke"].func_should_drop_with_regular_powerups = &func_should_drop_nuke_powerup;
    level.zombie_powerups["fire_sale"].func_should_drop_with_regular_powerups = &func_should_drop_fire_sale_powerup;
    level.zombie_powerups["insta_kill"].func_should_drop_with_regular_powerups = &func_should_drop_insta_kill_powerup;
    level.zombie_powerups["double_points"].func_should_drop_with_regular_powerups = &func_should_drop_double_points_powerup;
    level.zombie_powerups["full_ammo"].func_should_drop_with_regular_powerups = &func_should_drop_full_ammo_powerup;
}

// #region powerup drop functions

// #region powerup specific

function private func_should_drop_carpenter_powerup()
{
    return self func_should_drop_powerup("carpenter");
}

function private func_should_drop_nuke_powerup()
{
    return self func_should_drop_powerup("nuke");
}

function private func_should_drop_fire_sale_powerup()
{
    return self func_should_drop_powerup("fire_sale");
}

function private func_should_drop_insta_kill_powerup()
{
    return self func_should_drop_powerup("insta_kill");
}

function private func_should_drop_double_points_powerup()
{
    return self func_should_drop_powerup("double_points");
}

function private func_should_drop_full_ammo_powerup()
{
    return self func_should_drop_powerup("full_ammo");
}

// #endregion

function private func_should_drop_powerup(power_up_name)
{
    //TODO.
    return false;

    switch (power_up_name)
    {
        case "nuke":
        case "insta_kill":
        case "double_points":
        case "full_ammo":
            return self zm_powerups::func_should_always_drop();
        case "fire_sale":
            return self zm_powerup_fire_sale::func_should_drop_fire_sale();
        case "carpenter":
            return self zm_powerup_carpenter::func_should_drop_carpenter();
        default: // "minigun"
            return self zm_powerups::func_should_never_drop();
    }
}

function func_should_drop_minigun()
{
    // TODO: drop when cerberus is fed. (next iteration is 1)
    return true;
}

// #endregion

// Creates zombie_vars that need to be tracked on an individual basis rather than as a group.
function init_player_zombie_vars()
{    
    self.zombie_vars[HRPWRUP_ON_NAME] = false; // minigun
    self.zombie_vars[HRPWRUP_TIME_NAME] = 0;
    
	self globallogic_score::initPersStat(HRPWRUP_STATS, false);
}

// #endregion

function grab_minigun(player)
{
    level thread minigun_weapon_powerup(player);
    player thread zm_powerups::powerup_vo("minigun"); // TODO: change vo?

    if(IsDefined(level._grab_minigun))
    {
        level thread [[ level._grab_minigun ]](player);
    }
}

// #region powerup logic

function minigun_weapon_powerup(ent_player, time)
{
    ent_player endon("disconnect");
    ent_player endon("death");
    ent_player endon("player_downed");
    
    if (!IsDefined(time))
    {
        time = 30;
    }
    if(isDefined(level._minigun_time_override))
    {
        time = level._minigun_time_override;
    }

    // Just replenish the time if it's already active
    if (ent_player.zombie_vars[HRPWRUP_ON_NAME] 
    && (level.zombie_powerup_weapon[HRPWRUP_NAME] == ent_player GetCurrentWeapon() || IS_TRUE(ent_player.has_powerup_weapon[HRPWRUP_NAME])))
    {
        if (ent_player.zombie_vars[HRPWRUP_TIME_NAME] < time)
        {
            ent_player.zombie_vars[HRPWRUP_TIME_NAME] = time;
        }
        return;
    }
    
    // make sure weapons are replaced properly if the player is downed
    level._zombie_minigun_powerup_last_stand_func = &minigun_powerup_last_stand;
    
    stance_disabled = false;
    //powerup cannot be switched to if player is in prone
    if(ent_player GetStance() === "prone")
    {
        ent_player AllowCrouch(false);
        ent_player AllowProne(false);
        stance_disabled = true;
        
        while(ent_player GetStance() != "stand")
        {
            WAIT_SERVER_FRAME;
        }
    }
    
    zm_powerups::weapon_powerup(ent_player, time, HRPWRUP_WEAPON, true);
    
    if(stance_disabled)
    {
        ent_player AllowCrouch(true);
        ent_player AllowProne(true);
    }
}

function minigun_powerup_last_stand()
{
    zm_powerups::weapon_watch_gunner_downed(HRPWRUP_WEAPON);
}

function minigun_countdown(ent_player, str_weapon_time)
{
    while (ent_player.zombie_vars[str_weapon_time] > 0)
    {
        WAIT_SERVER_FRAME;
        ent_player.zombie_vars[str_weapon_time] = ent_player.zombie_vars[str_weapon_time] - 0.05;
    }    
}

function minigun_weapon_powerup_off()
{
    self.zombie_vars[HRPWRUP_TIME_NAME] = 0;
}

function minigun_damage_adjust( inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, sHitLoc, psOffsetTime, boneIndex, surfaceType ) //self is an enemy
{
    if (weapon.name != HRPWRUP_WEAPON)
    {
        // Don't affect damage dealt if the weapon isn't the minigun, allow other damage callbacks to be evaluated - mbettelman 1/28/2016
        return -1;
    }
    if (self.archetype == ARCHETYPE_ZOMBIE || self.archetype == ARCHETYPE_ZOMBIE_DOG || self.archetype == ARCHETYPE_ZOMBIE_QUAD)
    {        
        n_percent_damage = self.health * (RandomFloatRange(.34, .75));
    }
    if (isdefined (level.minigun_damage_adjust_override))
    {
        n_override_damage = thread [[ level.minigun_damage_adjust_override ]]( inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, sHitLoc, psOffsetTime, boneIndex, surfaceType );
        if(isdefined(n_override_damage))
        {
            n_percent_damage = n_override_damage;
        }
    }
    
    if(isdefined(n_percent_damage)) 
    {
        damage += n_percent_damage;    
    }
    return damage;
}

// #endregion
