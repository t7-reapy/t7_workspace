#using scripts\zm\_zm_laststand; 
#using scripts\shared\callbacks_shared; 
#using scripts\zm\_zm_powerup_weapon_minigun; 
#using scripts\zm\_zm_powerup_fire_sale; 
#using scripts\zm\_zm_powerup_carpenter;
#using scripts\_NSZ\nsz_powerup_empty_bottle;
#using scripts\zm\_zm_powerups;
#using scripts\shared\system_shared;

// Sword powerup
#using scripts\zm\sword_powerup;
#using scripts\zm\_glaive;

#insert scripts\shared\shared.gsh;

#using scripts\zm\hellround\zm_hellround_mysterybox;
#using scripts\zm\hellround\zm_hellround_shared;
#insert scripts\zm\hellround\zm_hellround_shared.gsh;
#insert scripts\zm\hellround\zm_hellround_powerup.gsh;

#precache("xmodel", HRPWRUP_MODEL);

#namespace zm_hellround_powerup;

REGISTER_SYSTEM_EX("zm_hellround_powerup", &init, &main, undefined)

function private init()
{
    level.hellround_powerup_round_thresholds = HRPWRUP_ROUND_THRESHOLDS;
    level.hellround_powerup_weapons = HRPWRUP_WEAPONS;
    level.hellround_powerup_minigun_callbacks = [];
    level._grab_minigun = &grab_minigun;

    callback::on_spawned(&give_hellround_minigun);
    callback::on_connect(&revive_gives_back_minigun); // Because callback on_laststand doesn't include a "self", we use this instead.
}

function private main()
{
    level.zombie_powerups["minigun"].func_should_drop_with_regular_powerups = &func_should_drop_minigun_powerup;
    level.zombie_powerups["carpenter"].func_should_drop_with_regular_powerups = &func_should_drop_carpenter_powerup;
    level.zombie_powerups["nuke"].func_should_drop_with_regular_powerups = &func_should_drop_nuke_powerup;
    level.zombie_powerups["fire_sale"].func_should_drop_with_regular_powerups = &func_should_drop_fire_sale_powerup;
    level.zombie_powerups["insta_kill"].func_should_drop_with_regular_powerups = &func_should_drop_insta_kill_powerup;
    level.zombie_powerups["double_points"].func_should_drop_with_regular_powerups = &func_should_drop_double_points_powerup;
    level.zombie_powerups["full_ammo"].func_should_drop_with_regular_powerups = &func_should_drop_full_ammo_powerup;
    level.zombie_powerups["empty_bottle"].func_should_drop_with_regular_powerups = &func_should_drop_empty_bottle_powerup;
    level.zombie_powerups["sword_powerup"].func_should_drop_with_regular_powerups = &func_should_drop_sword_powerup;
    
    change_powerup_model("minigun", HRPWRUP_MODEL);
    change_powerup_weapon_timeout_logic("minigun", &lose_minigun);
    change_powerup_solo_fx(HRPWRUP_FX, HRPWRUP_GRAB_FX);
}

function private give_hellround_minigun() // self == player
{
    self notify("no_double_hellround_minigun");
    self endon("no_double_hellround_minigun");
    level endon("hellround_powerup_ended");

    // Revive can cycle weapons once, let's wait 1 server frame to wait for other scripts interfering to complete their stuff.
    wait 1;

    player = self;
    if (!isdefined(player.laststand) && is_powerup_active())
    {
        player thread zm_powerups::powerup_vo("minigun");
        level zm_powerup_weapon_minigun::minigun_weapon_powerup(player);
        
        player DisableOffhandWeapons();
        player DisableWeaponCycling();
    }
}

function private is_powerup_active()
{
    iteration = zm_hellround_shared::get_current_iteration();
    return iteration > 0 
        && iteration != HELLROUND_BAD_ITERATION 
        && zm_hellround_shared::is_hellround_running();
}

/* region laststand */

function private revive_gives_back_minigun() // self == player in laststand
{
	level endon("end_game");
	self endon("disconnect");
	self endon("death");
	
    while(1)
    {
        self waittill("player_revived", reviver);
        self thread give_hellround_minigun();
    }
}

function private register_custom_hellround_revive() // self == player
{
    self.hellround_revive_struct = self zm_laststand::register_revive_override(&player_is_reviving, &player_can_revive, HRPWRUP_REVIVING_GIVES_REVIVE_TOOL);
}

function private unregister_custom_hellround_revive() // self == player
{
    self zm_laststand::deregister_revive_override(self.hellround_revive_struct);
}

function private player_is_reviving(e_revivee) // self == reviver player
{
    // Inspired from _zm_laststand.gsc:1129 
    return self UseButtonPressed() && self player_can_revive(e_revivee);
}

function private player_can_revive(e_revivee) // self == reviver player
{
    // Inspired from _zm_laststand.gsc:865
    return is_powerup_active() && self IsTouching(e_revivee.revivetrigger);
}

/* endregion */

/* region powerup drop functions */
/* region powerup specific */

function private func_should_drop_minigun_powerup()
{
    return self func_should_drop_powerup("minigun");
}

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

function private func_should_drop_empty_bottle_powerup()
{
    return self func_should_drop_powerup("empty_bottle");
}


function private func_should_drop_sword_powerup()
{
    return self func_should_drop_powerup("sword_powerup");
}

/* endregion */

function private func_should_drop_powerup(power_up_name)
{
    // Because a kill can trigger a powerup drop, and the cerberus head, 
    // a conflict can occur in the same server frame... And because this 
    // function is called in a while(1) loop, and is_hellround_running() 
    // will always return false, the server will crash... Therefore, do 
    // not remove the below line.
    WAIT_SERVER_FRAME;
    
    PRINT_HR_DEBUG("Checking if powerup " + power_up_name + " should drop.");

    // No powerups during hellrounds
    if (zm_hellround_shared::is_hellround_running())
    {
        return power_up_name == "sword_powerup";
    }

    // Default behavior for other powerups
    switch (power_up_name)
    {
        case "minigun":
            return should_drop_hellround_powerup();
        case "sword_powerup":
            return should_drop_sword_powerup();
        case "nuke":
        case "insta_kill":
        case "double_points":
        case "full_ammo":
            return self zm_powerups::func_should_always_drop();
        case "fire_sale":
            return self zm_hellround_mysterybox::func_should_drop_fire_sale();
        case "carpenter":
            return self zm_powerups::func_should_never_drop(); // self zm_powerup_carpenter::func_should_drop_carpenter();
        case "empty_bottle": // Only for rewards.
        default:
            return self zm_powerups::func_should_never_drop();
    }
}

function private should_drop_hellround_powerup()
{
    if (level.hellround.progress_stopped)
    {
        return false;
    }

    current_iteration = zm_hellround_shared::get_current_iteration();
    drop_random_percent = RandomInt(100) < HRPWRUP_DROP_CHANCE_PERCENTAGE;
    minimum_round_reached = level.round_number >= level.hellround_powerup_round_thresholds[current_iteration];

    update_minigun_weapon();
    return minimum_round_reached 
        && drop_random_percent 
        && !zm_hellround_shared::is_last_iteration_completed()
        && current_iteration > 0 
        && current_iteration != HELLROUND_BAD_ITERATION;
}

function private should_drop_sword_powerup()
{
    return zm_hellround_shared::is_bad_iteration_survived();
}

function private change_powerup_model(powerup_name, model_name)
{
    level.zombie_powerups[powerup_name].model_name = model_name;
}

function private change_powerup_solo_fx(solo_fx, solo_grab_fx)
{
    level._effect["powerup_on_solo"] = solo_fx;
    level._effect["powerup_grabbed_solo"] = solo_grab_fx;
}

function private change_powerup_weapon(powerup_name, weapon_name)
{
    level.zombie_powerup_weapon[powerup_name] = GetWeapon(weapon_name);
}

function private change_powerup_weapon_timeout_logic(powerup_name, timeout_logic_func)
{
    level._custom_powerups[powerup_name].weapon_countdown = timeout_logic_func;
}

function toggle_powerups(b_enabled)
{
    level.no_powerups = b_enabled;
}

/* endregion */
/* region powerup logic */

function private update_minigun_weapon()
{
    current_iteration = zm_hellround_shared::get_current_iteration();
    weapon = level.hellround_powerup_weapons[current_iteration];
    change_powerup_weapon("minigun", weapon);

    PRINT_HR_DEBUG("minigun weapon was updated to " + weapon);
}

function private grab_minigun(grabber_player)
{
    foreach(player in GetPlayers())
    {
        if (!IsAlive(player) || isdefined(player.laststand))
        {
            continue;
        }

        if (player != grabber_player)
        {
            level thread zm_powerup_weapon_minigun::minigun_weapon_powerup(player);
            player thread zm_powerups::powerup_vo("minigun");
        }
        
        player DisableOffhandWeapons();
        player DisableWeaponCycling();
        player register_custom_hellround_revive();
    }
    
    foreach(callback in level.hellround_powerup_minigun_callbacks)
    {
        thread [[ callback ]] ();
    }
}

function add_minigun_callback(func_ptr)
{
    if (IsFunctionPtr(func_ptr))
    {
        level.hellround_powerup_minigun_callbacks[level.hellround_powerup_minigun_callbacks.size] = func_ptr;
    }
}

function private lose_minigun()
{
    level waittill("hellround_powerup_ended");
    foreach(player in GetPlayers())
    {
        player EnableOffhandWeapons();
        player EnableWeaponCycling();
        player unregister_custom_hellround_revive();
    }
}

function lose_minigun_callback(b_enable = false)
{
    // This function callback is only for removal of minigun powerup, never to start it.
    if (b_enable)
    {
        return;
    }

    level notify("hellround_powerup_ended");
}

function unregister_minigun_powerup()
{
    level._custom_powerups["minigun"].grab_powerup = &_void;
}

function private _void() { }

/* endregion */
