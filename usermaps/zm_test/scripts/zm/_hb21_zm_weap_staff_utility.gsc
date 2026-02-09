#using scripts\codescripts\struct;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\util_shared;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\system_shared;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_unitrigger;
#using scripts\zm\_zm_utility;
#using scripts\zm\_hb21_zm_weap_utility;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\zm\_hb21_zm_weap_staff_utility.gsh;
#insert scripts\zm\_hb21_zm_weap_staff_fire.gsh;
#insert scripts\zm\_hb21_zm_weap_staff_lightning.gsh;

#namespace hb21_zm_weap_staff_utility; 

REGISTER_SYSTEM_EX("hb21_zm_weap_staff_utility", &__init__, &__main__, undefined)


function __init__()
{
    clientfield::register("clientuimodel", STAFF_ICON_CF, VERSION_SHIP, 1, "int");
    clientfield::register("toplayer", STAFF_CHARGE_CF, VERSION_SHIP, 3, "int");
    
    level.a_staff_weaponfiles = [];
    level.a_staff_upgrade_pedestals = [];
    level.n_active_ragdolls = 0;
    setDvar("bg_chargeShotExponentialAmmoPerChargeLevel", "1");
    
    callback::on_spawned(&on_player_spawned);
    level.ragdoll_limit_check = &staff_ragdoll_attempt;
    level.ptr_is_staff_weapon = &is_staff_weapon;
}

function __main__()
{
}

/* 
REGISTER STAFF WEAPON FOR LEVEL
Description : This function handles registering this weapon file as a staff and sets up some required properties
Notes : None
*/
function register_staff_weapon_for_level(ut_weapon, ptr_weapon_fired_cb = undefined, ptr_weapon_missile_fired_cb = undefined, ptr_weapon_grenade_fired_cb = undefined, ptr_weapon_obtained_cb = &staff_upgraded_weapon_obtained_cb, ptr_weapon_lost_cb = &staff_upgraded_weapon_lost_cb, ptr_weapon_reloaded_cb = undefined, ptr_weapon_pullout_cb = &staff_upgraded_weapon_pullout_cb, ptr_weapon_putaway_cb = &staff_upgraded_weapon_putaway_cb, ptr_weapon_first_raise_cb = undefined, ptr_weapon_charge_cb = undefined)
{    
    w_weapon = (!isWeapon(ut_weapon) ? getWeapon(ut_weapon) : ut_weapon);
    
    w_weapon.ptr_weapon_fired_cb = ptr_weapon_fired_cb;
    w_weapon.ptr_weapon_missile_fired_cb = ptr_weapon_missile_fired_cb;
    w_weapon.ptr_weapon_grenade_fired_cb = ptr_weapon_grenade_fired_cb;
    w_weapon.ptr_weapon_obtained_cb = ptr_weapon_obtained_cb;
    w_weapon.ptr_weapon_lost_cb = ptr_weapon_lost_cb;
    w_weapon.ptr_weapon_reloaded_cb = ptr_weapon_reloaded_cb;
    w_weapon.ptr_weapon_pullout_cb = ptr_weapon_pullout_cb;
    w_weapon.ptr_weapon_putaway_cb = ptr_weapon_putaway_cb;
    w_weapon.ptr_weapon_first_raise_cb = ptr_weapon_first_raise_cb;
    w_weapon.ptr_weapon_charge_cb = ptr_weapon_charge_cb;
    
    zombie_utility::add_zombie_gib_weapon_callback(w_weapon.name, undefined, &staff_head_gib_nullify);
    hb21_zm_weap_utility::register_weapon_exclude_for_explode_death_anims(w_weapon);
    
    ARRAY_ADD(level.a_staff_weaponfiles, w_weapon);
}

/* 
ON PLAYER SPAWNED 
Description : This function defines all the required values and functions on the players
Notes : None  
*/
function on_player_spawned()
{
    self thread staff_watch_charge_level();
}

/* 
STAFF RAGDOLL ATTEMPT
Description : This function handles logic to make sure there are not too many ragdolls at once
Notes : None  
*/
function staff_ragdoll_attempt()
{
    DEFAULT(level.n_active_ragdolls, 0);
    
    if (level.n_active_ragdolls >= RAGDOLL_LIMIT)
        return 0;
    
    level thread staff_add_ragdoll();
    return 1;
}

/* 
IS STAFF WEAPON
Description : This function checks a weapon to see if it is a staff, or if it is in the specific array passed
Notes : None  
*/
function is_staff_weapon(w_weapon, a_array = level.a_staff_weaponfiles)
{
    return (isDefined(a_array) && isArray(a_array) && isInArray(a_array, w_weapon));
}

/* 
STAFF UPGRADED WEAPON PULLOUT CB
Description : This function is logic for a player changing weapon to a upgraded staff weapon
Notes : None  
*/
function staff_upgraded_weapon_pullout_cb(w_previous_weapon, w_new_weapon)
{
    if (!is_upgraded_staff_weapon(w_new_weapon))
        return;

    self clientfield::set_player_uimodel("hudItems.showDpadLeft_Staff", 1);
}

/* 
STAFF UPGRADED WEAPON OBTAINED CB
Description : This function is logic for a player obtaining a upgraded staff weapon
Notes : None  
*/
function staff_upgraded_weapon_obtained_cb(w_weapon)
{
    if (isDefined(w_weapon.n_ammo_clip) && IS_TRUE(STAFF_USE_SHARED_AMMO))
        self setWeaponAmmoClip(w_weapon, w_weapon.n_ammo_clip);
    if (isDefined(w_weapon.n_ammo_stock) && IS_TRUE(STAFF_USE_SHARED_AMMO))
        self setWeaponAmmoStock(w_weapon, w_weapon.n_ammo_stock);
    
    self thread staff_ammo_recorder(w_weapon);
}

/* 
STAFF UPGRADED WEAPON LOST CB
Description : This function is logic for a player dropping a upgraded staff weapon
Notes : None  
*/
function staff_upgraded_weapon_lost_cb(w_weapon)
{    

}

/* 
STAFF UPGRADED WEAPON PUTAWAY CB
Description : This function is logic for a player changing weapon from a upgraded staff weapon
Notes : None  
*/
function staff_upgraded_weapon_putaway_cb(w_previous_weapon, w_new_weapon)
{
    if (!is_upgraded_staff_weapon(w_previous_weapon))
        return;
        
    self setActionSlot(3, "");
    self clientfield::set_player_uimodel("hudItems.showDpadLeft_Staff", 0);
    self.attachment_ammo_weapon = undefined;
}

/* 
STAFF HEAD GIB NULLIFY
Description : This function is just to nullify head gibs on zombies killed by the staffs
Notes : None  
*/
function staff_head_gib_nullify(str_damage_location)
{
    return 0;
}

/* 
STAFF AMMO RECORDER
Description : This function records the staff weapons ammo repeatadly
Notes : None  
*/
function staff_ammo_recorder(w_staff_weapon)
{
    self endon("death_or_disconnect");
    while (isDefined(self))
    {
        if (!self hasWeapon(w_staff_weapon))
            break;
        
        foreach(w_weapon in self getWeaponsList(1))
        {
            if (w_weapon == w_staff_weapon)
            {
                w_weapon.n_ammo_clip = self getWeaponAmmoClip(w_weapon);
                w_weapon.n_ammo_stock = self getWeaponAmmoStock(w_weapon);
            }
        }
        WAIT_SERVER_FRAME;
    }
}

/* 
STAFF DISTANCE 2D SQUARED PASSED
Description : This function is used to perform checks on an ai to consider distances with optional modifiers
Notes : None
*/
function staff_distance_2d_squared_passed(v_start_origin, v_end_origin, n_range, n_range_multiplier = 1)
{
    return (distance2dSquared(v_start_origin, v_end_origin) < SQR(n_range ) );
}

/* 
STAFF TRACE PASSED
Description : This function is used to perform checks on an with optional parameters 
Notes : None
*/
function staff_trace_passed(v_start_origin, v_end_origin, b_hit_characters = 0, e_ignore_ent = undefined, e_ignore_ent_2 = undefined, b_fx_visibility = 0, b_ignore_water = 1, ptr_extra_function_run_after_check = undefined)
{
    b_trace_result = (bulletTracePassed(v_start_origin + (10, 10, 32), v_end_origin + (10, 10, 32), b_hit_characters, e_ignore_ent, e_ignore_ent_2, b_fx_visibility, b_ignore_water) || bulletTracePassed(v_start_origin + (-10, -10, 64), v_end_origin + (-10, -10, 64), b_hit_characters, e_ignore_ent, e_ignore_ent_2, b_fx_visibility, b_ignore_water));
    if (IS_TRUE(b_trace_result) && isDefined(ptr_extra_function_run_after_check))
        b_trace_result = [[ptr_extra_function_run_after_check]]();
    
    return b_trace_result;
}

/* 
STAFF DO DAMAGE
Description : This function runs callbacks or deals the appropriate damage to a zombie hit by the chosen Staff
Notes : None
*/
function staff_do_damage(n_amount = undefined, v_source_origin = self.origin, e_attacker = level, e_inflictor = undefined, str_hit_location = undefined, str_means_of_death = "MOD_UNKNOWN", n_id_flag = 0, w_weapon = level.weaponNone, n_destructable_piece_index = undefined, b_force_pain = 0)
{
    n_amount = ((isDefined(e_attacker) && isPlayer(e_attacker) && e_attacker zm_powerups::is_insta_kill_active()) ? self.health + 666 : n_amount);
    self doDamage((isDefined(n_amount) ? ((isDefined(n_amount) && n_amount == -1) ? self.health + 666 : n_amount) : (isDefined(w_weapon.n_damage) ? w_weapon.n_damage : 0)), v_source_origin, e_attacker, e_inflictor, str_hit_location, str_means_of_death, n_id_flag, w_weapon, n_destructable_piece_index, b_force_pain);
}

/* 
STAFF ADD RAGDOLL
Description : This function adds a ragdoll to the queue
Notes : None
*/
function staff_add_ragdoll()
{
    DEFAULT(level.n_active_ragdolls, 0);
    
    level.n_active_ragdolls++;
    wait 1;
    if (level.n_active_ragdolls > 0)
        level.n_active_ragdolls--;
    
}

/* 
STAFF WATCH CHARGE LEVEL
Description : This function handles the sound and fx logic when a player is charging their staff
Notes : None
*/
function staff_watch_charge_level()
{
    self endon("death_or_disconnect");
    self notify("staff_watch_charge_level");
    self endon("staff_watch_charge_level");
    
    while (isDefined(self))
    {
        n_charge_level = 0;
        self clientfield::set_to_player(STAFF_CHARGE_CF, 0);
        
        while (!self attackButtonPressed())
            WAIT_SERVER_FRAME;
        
        while (!self isSwitchingWeapons() && !self isFiring() && !self isReloading() && self attackButtonPressed())
        {
            if (n_charge_level != self.chargeshotlevel && self.chargeshotlevel > 0)
            {
                n_charge_level = self.chargeshotlevel;
                self clientfield::set_to_player(STAFF_CHARGE_CF, n_charge_level);
            }
            WAIT_SERVER_FRAME;
        }
        WAIT_SERVER_FRAME;
    }
}

/* 
IS UPGRADED STAFF WEAPON
Description : This is a function checks if this weapon is a upgraded staff weapon
Notes : None
*/
function is_upgraded_staff_weapon(w_weapon)
{
    return (is_staff_weapon(w_weapon) && IS_TRUE(w_weapon.b_is_upgrade));
}

/* 
HAS UPGRADED STAFF
Description : This is a function checks if a player has a upgraded staff weapon
Notes : None
*/
function has_upgraded_staff()
{
    foreach(w_weapon in self getWeaponsListPrimaries())
        if (is_upgraded_staff_weapon(w_weapon))
            return 1;
    
    return 0;
}

/* 
DISABLE FIND FLESH
Description : This is a function to disable pain reactions on a ai
Notes : None
*/
function disable_pain_and_reaction(b_store_previous_state = 1, b_bypass_if_state_already_stored = 1)
{
    if (IS_TRUE(b_store_previous_state))
    {
        self.olddisablepain = (!isDefined(self.olddisablepain) ? self.a.disablepain : (IS_TRUE(b_bypass_if_state_already_stored) ? self.olddisablepain : self.a.disablepain));
        self.oldallowpain = (!isDefined(self.oldallowpain) ? self.allowpain : (IS_TRUE(b_bypass_if_state_already_stored) ? self.oldallowpain : self.allowpain));
        self.olddisableReact = (!isDefined(self.olddisableReact) ? self.a.disableReact : (IS_TRUE(b_bypass_if_state_already_stored) ? self.olddisableReact : self.a.disableReact));
        self.oldallowReact = (!isDefined(self.oldallowReact) ? self.allowReact : (IS_TRUE(b_bypass_if_state_already_stored) ? self.oldallowReact : self.allowReact));
    }    
    
    self.olddisablepain = self.a.disablepain;
    self.oldallowpain = self.allowpain;    
    self.olddisableReact = self.disableReact;    
    self.oldallowReact = self.allowReact;    
    self.a.disablepain = 1;
    self.allowpain = 0;
    self.a.disableReact = 1;
    self.allowReact = 0;
}

/* 
ENABLE FIND FLESH
Description : This is a function to reenable pain reactions on a ai
Notes : None
*/
function enable_pain_and_reaction(b_restore_previous_state = 1)
{
    if (IS_TRUE(b_restore_previous_state))
    {
        self.a.disablepain = (isDefined(self.olddisablepain) ? self.olddisablepain : 0);
        self.allowpain = (isDefined(self.oldallowpain) ? self.oldallowpain : 1);
        self.a.disableReact = (isDefined(self.olddisableReact) ? self.olddisableReact : 0);
        self.allowReact = (isDefined(self.oldallowReact) ? self.oldallowReact : 1);
    }
    else
    {
        self.a.disablepain = 0;
        self.allowpain = 1;
        self.a.disableReact = 0;
        self.allowReact = 1;
        self.olddisablepain = undefined;
        self.oldallowpain = undefined;    
        self.olddisableReact = undefined;    
        self.oldallowReact = undefined;    
    }
}

/* 
DISABLE FIND FLESH
Description : This is a function to disable find flesh on a ai
Notes : None
*/
function disable_find_flesh(b_keep_goal = 0)
{
    v_origin = undefined;
    if (IS_TRUE(b_keep_goal))
    {
        if (isDefined(self.v_zombie_custom_goal_pos))
            v_origin = self.v_zombie_custom_goal_pos;
        else if (isDefined(self.favoriteenemy) && isDefined(self.favoriteenemy.origin))
            v_origin = self.favoriteenemy.origin;
        else if (isDefined(self.attackable) && isDefined(self.attackable.origin))
            v_origin = self.attackable.origin;
        else if (isDefined(self.attackable_slot) && isDefined(self.attackable_slot.origin))
            v_origin = self.attackable_slot.origin;
        else
            v_origin = self.origin + (anglesToForward(self.angles) * 40);
    }
    
    self.b_previous_ignore_find_flesh = self.ignore_find_flesh;
    self.b_previous_ignore_all = self.ignoreall;
    self.ignore_find_flesh = 1;
    self notify("stop_find_flesh");
    self.ignoreall = 1;
    
    if (isDefined(v_origin))
        self setGoal(v_origin);
    
}

/* 
ENABLE FIND FLESH
Description : This is a function to reenable find flesh on a ai
Notes : None
*/
function enable_find_flesh()
{
    self.ignore_find_flesh = (isDefined(self.b_previous_ignore_find_flesh) ? self.b_previous_ignore_find_flesh : 0);
    self.b_previous_ignore_find_flesh = undefined;
    self.ignoreall = (isDefined(self.b_previous_ignore_all) ? self.b_previous_ignore_all : 0);
    
    if (!IS_TRUE(self.ignore_find_flesh))
        self notify("zombie_acquire_enemy");
    
}

/* 
SPIN MODEL
Description : This function repeatadly rotates a model
Notes : None
*/
function spin_model(n_rotate_time = 20)
{
    self endon("death");
    while (isDefined(self))
    {
        self rotateYaw(360, n_rotate_time, 0, 0);
        self waittill("rotatedone");
    }
}


/* 
ZOMBIE GIB ALL
Description : This function gibs a zombies limbs
Notes : None
*/
function zombie_gib_all(str_fx_tag = "j_spinelower")
{
    if (!isDefined(self))
        return;
        
    v_origin = self getTagOrigin(str_fx_tag);
    if (isDefined(v_origin))
    {
        v_forward = anglesToForward((0, randomInt(360), 0));
        playFx(level._effect["zombie_guts_explosion"], v_origin, v_forward);
        playSoundAtPosition("zmb_death_gibs", self.origin + (0, 0, 64));
        playSoundAtPosition("zmb_zombie_head_gib", self.origin + (0, 0, 64));
    }
    
    a_gib_ref = [];
    a_gib_ref[0] = level._zombie_gib_piece_index_all;
    self gib("normal", a_gib_ref);
    self ghost();
    wait .4;
    if (isDefined(self))
        self delete();
    
}

/* 
ZOMBIE GIB GUTS
Description : This function gibs a zombies guts
Notes : None
*/
function zombie_gib_guts(str_fx_tag = "j_spinelower")
{
    if (!isDefined(self))
        return;
    
    v_origin = self getTagOrigin(str_fx_tag);
    if (isDefined(v_origin))
    {
        v_forward = anglesToForward((0, randomint(360), 0));
        playFx(level._effect["zombie_guts_explosion"], v_origin, v_forward);
        playSoundAtPosition("zmb_death_gibs", self.origin + (0, 0, 64));
        playSoundAtPosition("zmb_zombie_head_gib", self.origin + (0, 0, 64));
    }
    
    self ghost();
    wait randomFloatRange(.4, 1.1);
    if (isDefined(self))
        self delete();
        
}

/* 
PROJECTILE DELETE
Description : This function deletes a projectile entity after a short delay
Notes : None
*/
function projectile_delete(n_lifetime = .75)
{
    self endon("death");
    wait n_lifetime;
    self delete();
}

/* 
STAFF UPGRADE PLYNTH VISIBILITY
Description : This function handles the hintstring logic for a upgrade plynth trigger
Notes : None
*/
function staff_upgrade_plynth_visibility(e_player)
{
    s_charger = self.stub.s_charger;
    w_weapon = e_player getCurrentWeapon();
    
    if (IS_TRUE(s_charger.b_upgrading))
        self.hint_string = &"";
    else if (IS_TRUE(s_charger.b_upgraded))
    {
        if (isDefined(s_charger.e_staff_placed) && s_charger.e_staff_placed == self.stub)
            self.hint_string = "Press & hold ^3&&1^7 to take " + makeLocalizedString(s_charger.w_staff_upgraded_weapon.displayname);
        else if (isDefined(w_weapon) && w_weapon == s_charger.w_staff_upgraded_weapon)
            self.hint_string = "Press & hold ^3&&1^7 to place " + makeLocalizedString(s_charger.w_staff_upgraded_weapon.displayname);
        else
            self.hint_string = &"";
        
    }
    else
    {
        if (isDefined(w_weapon) && w_weapon == s_charger.w_staff_weapon)
            self.hint_string = "Press & hold ^3&&1^7 to place " + makeLocalizedString(s_charger.w_staff_weapon.displayname);
        else
            self.hint_string = &"";
            
    }

    if (isDefined(self.hint_string))
        self setHintString(self.hint_string);
    
    return 1;
}

/* 
OPEN UPGRADE PLYNTH
Description : This function opens a staffs upgrade pedestal once the staff is picked up for the first time
Notes : None
*/
function open_upgrade_plynth(n_amount, n_time)
{
    self moveTo(self.origin + (0, 0, n_amount), n_time);
    self playLoopSound("zmb_chamber_plinth_move", .25);
    
    wait n_time;
    
    self stopLoopSound(.1);
    self playSound("zmb_chamber_plinth_stop");
}

/* 
STAFF UPGRADE PLYNTH SOULS COLLECTED
Description : This function will execute when a staff upgrade plynths soul chest is completed
Notes : None
*/
function staff_upgrade_plynth_souls_collected()
{
    self.script_noteworthy = undefined;
    self notify("staff_upgrade_complete");
}

/* 
TAKE ALL STAFF WEAPONS
Description : This function will remove all staff weapons from a player
Notes : None
*/
function take_all_staff_weapons()
{
    foreach (w_weapon in self getWeaponsList(1))
    {
        if (isInArray(level.a_staff_weaponfiles, w_weapon))
            self zm_weapons::weapon_take(w_weapon);
        
    }
}

/* 
STAFF PEDESTAL WATCH FOR LOSS
Description : This function will respawn the staff back at its crafting pedestal in the case it has become "lost"
Notes : None
*/
function staff_pedestal_watch_for_loss()
{
    s_charger = struct::get(self.equipname + "_charger", "script_noteworthy");
    e_staff_model = getEnt(self.equipname + "_model", "targetname");
    while (isDefined(self))
    {
        if (isDefined(s_charger) && isDefined(s_charger.e_staff_placed))
        {
            WAIT_SERVER_FRAME;
            continue;
        }
        
        b_lost = 1;
        foreach (e_player in level.players)
        {
            if (e_player laststand::player_is_in_laststand() || IS_TRUE(e_player.intermission))    
            {
                if (isInArray(e_player.laststandPrimaryWeapons, self.weaponname))
                {
                    b_lost = 0;
                    break;
                }
            }
            if (e_player hasWeapon(self.weaponname))
            {
                b_lost = 0;
                break;
            }
        }
        
        if (b_lost)
        {
            e_staff_model show();
            s_charger.e_staff_placed = self;
        }
        WAIT_SERVER_FRAME;
    }
}

/* 
ATTACH STAFF GLOW FX
Description : This function will create the glow effect using the correct colour for the staff name passed
Notes : None
*/
function attach_staff_glow_fx(str_staff_name)
{
    n_elem = 0;
    if (isSubStr(str_staff_name, "fire"))
        n_elem = 1;
    else if (isSubStr(str_staff_name, "air"))
        n_elem = 2;
    else if (isSubStr(str_staff_name, "bolt"))
        n_elem = 3;
    else if (isSubStr(str_staff_name, "water"))
        n_elem = 4;
        
    self clientfield::set("staff_element_glow_fx", n_elem);
}
