#using scripts\zm\_zm_xcdylan93_utils; 
#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;

#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_bgb;
#using scripts\zm\_zm_equipment;
#using scripts\zm\_zm_magicbox;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\zm.gsh;
#insert scripts\zm\_zm_s2_pack_a_punch.gsh;

#precache("triggerstring", WEAPON_HOLDER_LOCALIZE_SET, WEAPON_HOLDER_PRICE_SET);
#precache("triggerstring", WEAPON_HOLDER_LOCALIZE_GET, WEAPON_HOLDER_PRICE_GET);
#precache("triggerstring", WEAPON_HOLDER_LOCALIZE_SWAP, WEAPON_HOLDER_PRICE_SWAP);

REGISTER_SYSTEM_EX("zm_s2_pack_a_punch", &__init__, &__main__, undefined)

function __init__()
{
    weapon_holder_entities = GetEntArray("zm_s2_pack_a_punch", "targetname");

    if(weapon_holder_entities.size < 1)
        return;

    DEFAULT(level.weapon_holder_triggers, []);

    array::run_all(weapon_holder_entities, &weapon_holder_spawn_init);
}

function __main__()
{
    if(!isdefined(level.weapon_holder_triggers))
        return;

    array::run_all(level.weapon_holder_triggers, &flag::init, "weapon_holder_holding");
    array::thread_all(level.weapon_holder_triggers, &weapon_holder_set_cost);
    array::thread_all(level.weapon_holder_triggers, &weapon_holder_hint_string);
    array::thread_all(level.weapon_holder_triggers, &weapon_holder_think);
}

function weapon_holder_spawn_init()
{
    if(!isdefined(self.model))
        return;

    self SetDedicatedShadow(true);
    self.machine = self;
    self.machine.angles = self.angles;
    self.machine.targetname = "fxanim_zmb_pack_a_punch_01";

    self.use_trigger = Spawn("trigger_box_use", self.origin, 0, 64, 64, 64);
    self.use_trigger TriggerIgnoreTeam();
    self.use_trigger SetHintString(&"ZOMBIE_NEED_POWER");
    self.use_trigger SetCursorHint("HINT_NOICON");
    self.use_trigger.owner = self;

    level.weapon_holder_triggers[level.weapon_holder_triggers.size] = self.use_trigger;
}

function weapon_holder_set_cost()
{
    self.set_cost = Int(WEAPON_HOLDER_PRICE_SET);
    self.get_cost = Int(WEAPON_HOLDER_PRICE_GET);
    self.swap_cost = Int(WEAPON_HOLDER_PRICE_SWAP);
}

function weapon_holder_hint_string()
{
    level endon("end_game");

    level flag::wait_till("power_on");

    while(true)
    {
        foreach(player in GetPlayers())
        {
            if(player IsTouching(self))
            {
                self update_hint_string_for_player(player);
            }
        }
        
        WAIT_SERVER_FRAME;
    }
}

function update_hint_string_for_player(player) // self == trigger
{
    weapon_limit = zm_utility::get_player_weapon_limit(player);
    primaries = player GetWeaponsListPrimaries();

    if (self flag::get("weapon_holder_holding") && isdefined(primaries) && primaries.size >= weapon_limit)
    {
        self SetHintStringForPlayer(player, &WEAPON_HOLDER_LOCALIZE_SWAP, self.swap_cost);
    }
    else if (self flag::get("weapon_holder_holding"))
    {
        self SetHintStringForPlayer(player, &WEAPON_HOLDER_LOCALIZE_GET, self.get_cost);
    }
    else
    {
        self SetHintStringForPlayer(player, &WEAPON_HOLDER_LOCALIZE_SET, self.set_cost);
    }
}

function weapon_holder_think()
{
    level endon("end_game");

    level flag::wait_till("power_on");
    PRINT_WH_DEBUG("Power on!");

    while(true)
    {
        self waittill("trigger", player);
        PRINT_WH_DEBUG("Player trigger!");

        if(!player weapon_holder_player_can_use_trigger())
        {
            PRINT_WH_DEBUG("Player cannot use the weapon holder!");
            continue;
        }

        current_weapon = player zm_weapons::switch_from_alt_weapon(player GetCurrentWeapon());
        alt_weapon = player GetCurrentWeaponAltWeapon();

        if(!zm_weapons::is_weapon_or_base_included(current_weapon))
        {
            PRINT_WH_DEBUG("is_weapon_or_base_included returned false!");
            continue;
        }

        current_cost = self get_weapon_holder_cost_for_player(player);
        if(!player zm_score::can_player_purchase(current_cost))
        {
            PRINT_WH_DEBUG("Player does not have the money!");
            self playsound("zmb_trap_deny"); // door_deny zmb_trap_deny evt_perk_deny zmb_perks_packa_deny
            player zm_audio::create_and_play_dialog("general", "outofmoney", 0);

            continue;
        }
        
        player zm_score::minus_to_player_score(current_cost);
        player zm_audio::create_and_play_dialog("general", "pap_wait");
        self TriggerEnable(false);

        self weapon_holder_spawn_weapon_model(player, current_weapon, alt_weapon);
        
        wait 3.0;

        self TriggerEnable(true);
        self SetCursorHint("HINT_WEAPON", current_weapon);
        self flag::set("weapon_holder_holding");

        self SetInvisibleToAll();
        self SetVisibleToPlayer(player);
        self thread weapon_holder_wait_for_take_or_swap(current_weapon, alt_weapon);
        self waittill("weapon_holder_taken");

        self TriggerEnable(false);
        self SetCursorHint("HINT_NOICON");
        self weapon_holder_delete_weapon_model();
        self flag::clear("weapon_holder_holding");
        
        wait 3.0;

        self TriggerEnable(true);
    }
}

function weapon_holder_player_can_use_trigger() // self == player
{
    if(self laststand::player_is_in_laststand() || IS_TRUE(self.intermission) || self IsThrowingGrenade() || self IsSwitchingWeapons())
    {
        return false;
    }

    if(self zm_equipment::hacker_active())
    {
        return false;
    }

    current_weapon = self GetCurrentWeapon();
    if(!self weapon_holder_player_can_deposit_weapon(current_weapon))
    {
        return false;
    }

    return true;
}

function get_weapon_holder_cost_for_player(player) // self == trigger
{    
    weapon_limit = zm_utility::get_player_weapon_limit(player);
    primaries = player GetWeaponsListPrimaries();

    if (self flag::get("weapon_holder_holding") && isdefined(primaries) && primaries.size >= weapon_limit)
    {
        return self.swap_cost;
    }
    else if (self flag::get("weapon_holder_holding"))
    {
        return self.get_cost;
    }
    else
    {
        return self.set_cost;
    }
}

function weapon_holder_player_can_deposit_weapon(weapon)
{
    if(weapon.isriotshield)
    {
        return false;
    }

    weapon = self zm_weapons::get_nonalternate_weapon(weapon);
    if(!zm_weapons::is_weapon_or_base_included(weapon))
    {
        return false;
    }

    return true;
}

function weapon_holder_spawn_weapon_model(player, current_weapon, alt_weapon, skip_animations = false) // self == trigger
{
    level endon("end_game");
    
    weapon_model_origin = self.owner.machine GetTagOrigin("lathe_02");
    weapon_model_angles = self.owner.machine GetTagAngles("lathe_02") + (0, 180, 0);

    zm_xcdylan93_utils::save_weapon_ammo_state(player, current_weapon, alt_weapon);
    player zm_weapons::weapon_take(current_weapon);
    self.owner.machine playsound("zmb_buildable_piece_add");

    camo_index = (zm_weapons::is_weapon_upgraded(current_weapon) ? current_weapon.pap_camo_to_use : 0);
    self.weapon_model = zm_utility::spawn_buildkit_weapon_model(player, current_weapon, camo_index, weapon_model_origin, weapon_model_angles);

    if(current_weapon.isDualWield)
    {
        self.weapon_model_dw = zm_utility::spawn_buildkit_weapon_model(player, current_weapon, camo_index, weapon_model_origin - (3, 3, 3), weapon_model_angles);
    }

    if (skip_animations)
    {
        return;
    }

    // self.owner.machine thread scene::play("zmb_pack_a_punch_01_bundle");
    self.owner.machine PlaySound(WEAPON_HOLDER_SOUND_START);
    self.owner.machine PlayLoopSound(WEAPON_HOLDER_SOUND_LOOP, 3.0);
    exploder::exploder(WEAPON_HOLDER_EXPLODER);
}

function weapon_holder_wait_for_take_or_swap(held_weapon, alt_weapon) // self == trigger
{
    level endon("end_game");

    while(true)
    {
        WAIT_SERVER_FRAME;
        self waittill("trigger", player);
        
        current_weapon = player GetCurrentWeapon();
        current_alt_weapon = player GetCurrentWeaponAltWeapon();
        if(!weapon_holder_player_can_take_weapon(player, current_weapon, held_weapon))
        {
            continue;
        }

        current_cost = self get_weapon_holder_cost_for_player(player);
        if(!player zm_score::can_player_purchase(current_cost))
        {
            PRINT_WH_DEBUG("Player does not have the money!");
            self playsound("zmb_trap_deny"); // door_deny zmb_trap_deny evt_perk_deny zmb_perks_packa_deny
            player zm_audio::create_and_play_dialog("general", "outofmoney", 0);

            continue;
        }

        weapon_limit = zm_utility::get_player_weapon_limit(player);
        player zm_weapons::take_fallback_weapon();
        primaries = player GetWeaponsListPrimaries();

        new_weapon_held = false;
        if(isdefined(primaries) && primaries.size >= weapon_limit)
        {
            if(!player weapon_holder_player_can_use_trigger())
            {
                PRINT_WH_DEBUG("Player cannot use the weapon holder!");
                continue;
            }

            if(!zm_weapons::is_weapon_or_base_included(current_weapon))
            {
                PRINT_WH_DEBUG("is_weapon_or_base_included returned false!");
                continue;
            }

            self weapon_holder_delete_weapon_model();
            self weapon_holder_spawn_weapon_model(player, current_weapon, current_alt_weapon, true);

            new_weapon_held = true;
        }

        held_weapon = player zm_weapons::give_build_kit_weapon(held_weapon); //player zm_weapons::weapon_give(held_weapon);
        zm_xcdylan93_utils::restore_weapon_ammo_state(player, held_weapon, alt_weapon);
        player zm_score::minus_to_player_score(current_cost);
        player notify("weapon_give", held_weapon);
        player SwitchToWeapon(held_weapon);
        player zm_weapons::play_weapon_vo(held_weapon);

        if (new_weapon_held)
        {
            held_weapon = current_weapon;
            alt_weapon = current_alt_weapon;
            continue; // A new weapon is in place, skip animations and flag updates/notifications.
        }

        self notify("weapon_holder_taken");
        player notify("weapon_holder_taken");
        self.owner.machine StopLoopSound(1.5);
        self.owner.machine PlaySound(WEAPON_HOLDER_SOUND_STOP);
        exploder::exploder_stop(WEAPON_HOLDER_EXPLODER);
        break;
    }
}

function weapon_holder_player_can_take_weapon(player, current_weapon, held_weapon)
{
    if(!zm_utility::is_player_valid(player))
    {
        return false;
    }

    if(IS_DRINKING(player.is_drinking))
    {
        return false;
    }

    if(zm_utility::is_placeable_mine(current_weapon))
    {
        return false;
    }

    if(zm_equipment::is_equipment(current_weapon))
    {
        return false;
    }

    if(player zm_utility::is_player_revive_tool(current_weapon))
    {
        return false;
    }

    if(IS_EQUAL(level.weaponNone, current_weapon))
    {
        return false;
    }

    if(player zm_equipment::hacker_active())
    {
        return false;
    }

    foreach(weapon in player GetWeaponsListPrimaries())
    {
        weapon_name = zm_weapons::get_nonalternate_weapon(weapon).name;
        if (weapon_name == held_weapon.name)
        {
            return false;
        }
    }

    return true;
}

function weapon_holder_delete_weapon_model() // self == trigger
{
    if(isdefined(self.weapon_model))
    {
        self.weapon_model Delete();
        self.weapon_model = undefined;
    }

    if(isdefined(self.weapon_model_dw))
    {
        self.weapon_model_dw Delete();
        self.weapon_model_dw = undefined;
    }
}

