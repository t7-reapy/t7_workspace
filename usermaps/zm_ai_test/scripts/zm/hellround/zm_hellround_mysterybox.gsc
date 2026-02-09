#using scripts\zm\_zm_powerup_fire_sale; 
#using scripts\zm\_zm_weapons; 
#using scripts\shared\clientfield_shared; 
#using scripts\zm\_zm_unitrigger; 
#using scripts\zm\_zm_magicbox; 

#using scripts\zm\_zm; 
#using scripts\zm\_util;
#using scripts\zm\_zm_utility;

#using scripts\shared\array_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\spawner_shared; 
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_hb21_zm_magicbox;
#using scripts\zm\_hb21_zm_magicbox_botd;

#using scripts\zm\hellround\zm_hellround_shared;
#insert scripts\zm\hellround\zm_hellround_shared.gsh;
#insert scripts\zm\hellround\zm_hellround_mysterybox.gsh;

#namespace zm_hellround_mysterybox;
REGISTER_SYSTEM_EX("zm_hellround_mysterybox", &init, &main, undefined)

class HellroundMysteryBox {
    var original_chests; // indexed by script_noteworthy
    var hellround_chests; // indexed by script_noteworthy

    var mysterybox_models;
    var chests_lookuptable;
    var permanent_unlock;
}

function private init()
{
    clientfield::register("world", "add_extra_weapons_to_box", VERSION_SHIP, 1, "int");

    level.hellround_mystery_box = new HellroundMysteryBox();
    level.hellround_mystery_box.original_chests = [];
    level.hellround_mystery_box.hellround_chests = [];
    level.hellround_mystery_box.mysterybox_models = GetEntArray(HRMB_MODEL_TO_HIDE, "targetname");
    level.hellround_mystery_box.chests_lookuptable = [];
    level.hellround_mystery_box.permanent_unlock = false;
}

function private main()
{
    if (DEBUG_HELLROUNDS)
    {
        level._zombiemode_chest_joker_chance_override_func = &box_always_move;
        thread modvar_debug_hellround_mysterybox();
    }

    wait_for_chest_initialized();
    add_all_extra_weapons_to_mysterybox(false);
    overwrite_level_chests_and_register_hellround_chests();
    build_chests_lookup_tables();
    zm_hellround_shared::wait_for_map_load();
    hide_all_hellround_chests();
    override_box_prices_for_hellround();

    thread fix_moving_chest_state();
}

/* region public */

function toggle_hellround_mysteryboxes(b_enabled)
{
    b_enabled = IS_TRUE(b_enabled);

    if (level.hellround_mystery_box.permanent_unlock)
    {
        PRINT_HR_DEBUG("Permanent unlocked set. No toggling.");
        return;
    }

    waittill_all_chests_idle();

    foreach (model in level.hellround_mystery_box.mysterybox_models)
    {
        if (b_enabled)
        {
            model Hide();
        }
        else
        {
            model Show();
        }
    }

    foreach(chest in level.chests)
    {
        if (chest == level.chests[level.chest_index])
        {
            continue;
        }
        chest thread force_show_standard_box(!b_enabled);
        hellround_chest = level.hellround_mystery_box.hellround_chests[level.hellround_mystery_box.chests_lookuptable[chest.script_noteworthy]];
        hellround_chest thread hb21_zm_magicbox_botd::botd_force_show_box(b_enabled);
    }

    thread toggle_firesale(!b_enabled);
    if (b_enabled)
    {
        thread watch_for_post_hellround_firesale_start();
        overwrite_active_box(zm_hellround_shared::is_collector_iteration(zm_hellround_shared::get_current_iteration()));
    }
    else
    {
        restore_active_box();
    }

    thread add_all_extra_weapons_to_mysterybox(b_enabled);
}

function permanent_unlock()
{
    level notify("cancel_custom_waittill_mysterybox_transitions");
    wait DELAY_BEFORE_PERMANENT_UNLOCK;
    // TODO: vox for completion? or in the spawn manager ?
    toggle_hellround_mysteryboxes(true);
    level.hellround_mystery_box.permanent_unlock = true;

    for (i = 0 ; i < level.chests.size; i++)
    {
        chest = level.chests[i];
        chest.no_fly_away = undefined;

        // Current chest is hellround one, skip it. 
        if (chest == level.chests[level.chest_index])
        {
            continue;
        }
        
        hellround_chest = level.hellround_mystery_box.hellround_chests[level.hellround_mystery_box.chests_lookuptable[chest.script_noteworthy]];
        level.chests[i] = hellround_chest;
    }
}

/* endregion */
/* region setup */

function private overwrite_level_chests_and_register_hellround_chests()
{
    previous_chest = level.chests[level.chest_index];
    
    level.hellround_mystery_box.hellround_chests = get_hellround_mysteryboxes();
    level.hellround_mystery_box.original_chests = get_standard_mysteryboxes();

    level.chests = [];
    i = 0; // since original_chests is indexed by string we need to compute int index here
    foreach (chest in level.hellround_mystery_box.original_chests)
    {
        level.chests[i] = chest;
        i++;
    }
    
    level.chests = array::randomize(level.chests);

    // Even after randomization, first chest should stay the first current chest.
    start_chest_index = undefined;
    for (i = 0; i < level.chests.size; i++)
    {
        if (level.chests[i].script_noteworthy == "start_chest")
        {
            start_chest_index = i;
        }
    }
    level.chest_index = (isdefined(start_chest_index) ? start_chest_index : RandomInt(level.chests.size));

    previous_chest thread custom_hide_chest();
    level.chests[level.chest_index].zbarrier thread zm_magicbox::set_magic_box_zbarrier_state("initial");
}

function private hide_all_hellround_chests()
{
    foreach(chest in level.hellround_mystery_box.hellround_chests)
    {
        chest thread hb21_zm_magicbox_botd::botd_force_show_box(false);
    }
}

function private build_chests_lookup_tables()
{
    standard_chests = HRMB_NORMAL_CHESTS;
    hellround_chests = HRMB_HELLROUND_CHESTS;

    for(i = 0; i < standard_chests.size; i++)
    {
        level.hellround_mystery_box.chests_lookuptable[standard_chests[i]] = hellround_chests[i];
    }
}

/* endregion */
/* region main logic */

function private fix_moving_chest_state()
{
    level endon("end_game");
    while(true)
    {
        level flag::wait_till("moving_chest_now");
        previous_chest = level.chests[level.chest_index];
        level flag::wait_till_clear("moving_chest_now");
        // The chest, even when not used, can get stuck into this state for piece 2 after moving
        if (previous_chest.zbarrier GetZBarrierPieceState(2) == "open")
        {
            // Force the chest to have proper state for next idle checks.
            previous_chest.zbarrier SetZBarrierPieceState(2, "closed");
        }
    }
} 

function private overwrite_active_box(is_collector_iteration)
{
    if (IS_TRUE(is_collector_iteration))
    {
        PRINT_HR_DEBUG("Hidding all mystery boxes on collector rounds");

        foreach(chest in level.chests)
        {
            chest custom_hide_chest();
            chest thread force_show_standard_box(false);
            chest thread restore_standard_box_after_collector_iteration();
            hellround_chest = level.hellround_mystery_box.hellround_chests[level.hellround_mystery_box.chests_lookuptable[chest.script_noteworthy]];
            hellround_chest thread hb21_zm_magicbox_botd::botd_force_show_box(true);
            hellround_chest thread hide_box_after_collector_iteration();
        }

        return;
    }

    current_chest = level.chests[level.chest_index];

    if (!isdefined(current_chest))
    {
        PRINT_HR_DEBUG("current chest at index undefined.");
        return;
    }

    if (!isdefined(current_chest.script_noteworthy))
    {
        PRINT_HR_DEBUG("current chest has no script_noteworthy.");
        return;
    }

    if (isdefined(level.hellround_mystery_box.hellround_chests[current_chest.script_noteworthy]))
    {
        PRINT_HR_DEBUG("can not override an already hellround chest.");
        return;
    }

    current_chest waittill_chest_idle();
    if (level flag::get("moving_chest_now"))
    {
        thread overwrite_active_box(is_collector_iteration);
        return;
    }

    current_chest custom_hide_chest();
    current_chest force_show_standard_box(false);

    new_chest = level.hellround_mystery_box.hellround_chests[level.hellround_mystery_box.chests_lookuptable[current_chest.script_noteworthy]];
    new_chest.chest_to_restore = current_chest;
    level.chests[level.chest_index] = new_chest;

    new_chest zm_magicbox::show_chest();
    new_chest.no_fly_away = true; // to avoid having the box leaving after one usage.

    PRINT_HR_DEBUG("standard chest was: " + current_chest.script_noteworthy);
    PRINT_HR_DEBUG("hellround chest is: " + new_chest.script_noteworthy);
}

function private restore_standard_box_after_collector_iteration() // self == chest
{
    level waittill("restore_chests_after_collector_iteration");
    self force_show_standard_box(true);
    if (self == level.chests[level.chest_index])
    {
        self zm_magicbox::show_chest();
    }
}

function private hide_box_after_collector_iteration() // self == chest
{
    level waittill("restore_chests_after_collector_iteration");
    self hb21_zm_magicbox_botd::botd_force_show_box(false);
}

function private restore_active_box()
{
    level notify("restore_chests_after_collector_iteration");

    if (level.hellround_mystery_box.permanent_unlock)
    {
        PRINT_HR_DEBUG("Permanent unlocked set. No restoring.");
        return;
    }

    current_chest = level.chests[level.chest_index];

    if (!isdefined(current_chest) || !isdefined(current_chest.chest_to_restore))
    {
        PRINT_HR_DEBUG("hellround chest does not have restore reference.");
        return;
    }

    if (!isdefined(current_chest.script_noteworthy))
    {
        PRINT_HR_DEBUG("current chest has no script_noteworthy.");
        return;
    }

    if (isdefined(level.hellround_mystery_box.original_chests[current_chest.script_noteworthy]))
    {
        PRINT_HR_DEBUG("can not restore an already standard chest.");
        return;
    }

    current_chest waittill_chest_idle();
    if (level flag::get("moving_chest_now"))
    {
        thread restore_active_box();
        return;
    }
    current_chest.no_fly_away = undefined;
    current_chest custom_hide_chest();
    current_chest hb21_zm_magicbox_botd::botd_force_show_box(false);

    new_chest = current_chest.chest_to_restore;
    level.chests[level.chest_index] = new_chest;

    new_chest zm_magicbox::show_chest();
}

function private remove_chest_now()
{
    self custom_hide_chest();
    self force_show_standard_box(false);
    PRINT_HR_DEBUG("Hidden the chest " + self.script_noteworthy);
}

/* endregion */
/* region util */

function private waittill_all_chests_idle()
{
    chest_active = true;
    while (chest_active)
    {
        chest_active = false;
        foreach (chest in level.chests)
        {
            if (!chest is_chest_idle())
            {
                PRINT_HR_DEBUG(chest.script_noteworthy + " is still active");
                chest_active = true;
            }
        }
        WAIT_SERVER_FRAME;
    }
}

function private is_chest_idle() // self == chest
{
    return !level flag::get("moving_chest_now")
        && self.zbarrier GetZBarrierPieceState(1) != "opening" // Chest is not arriving...
        && self.zbarrier GetZBarrierPieceState(2) != "opening" // Chest is not opening...
        && self.zbarrier GetZBarrierPieceState(2) != "closing" // Chest is not closing...
        && self.zbarrier GetZBarrierPieceState(1) != "closing" // Chest is not leaving...
        && self.zbarrier GetZBarrierPieceState(2) != "open"; // Chest is not being used...
}

function private waittill_chest_idle() // self == chest
{
    self notify("cancel_custom_waittill_mysterybox_transitions");
    self endon("cancel_custom_waittill_mysterybox_transitions");

    // If chest moves, state doesn't change and get stuck.
    level endon("moving_chest_now");

    if(self.zbarrier GetZBarrierPieceState(1) == "opening")
    {
        PRINT_HR_DEBUG("Chest is arriving...");
	    self.zbarrier waittill("arrived");
    }

    if(self.zbarrier GetZBarrierPieceState(2) == "opening")
    {
        PRINT_HR_DEBUG("Chest is opening...");
        self.zbarrier waittill("opened");
    }

    if(self.zbarrier GetZBarrierPieceState(2) == "closing")
    {
        PRINT_HR_DEBUG("Chest is closing...");
        self.zbarrier waittill("closed");
    }

    if(self.zbarrier GetZBarrierPieceState(1) == "closing")
    {
        PRINT_HR_DEBUG("Chest is leaving...");
        self.zbarrier waittill("left");
    }

    while (self.zbarrier GetZBarrierPieceState(2) == "open")
    {
        // Chest is being used...
        WAIT_SERVER_FRAME;
    }

    PRINT_HR_DEBUG("Chest now IDLE");
    waittillframeend;
}

function private force_show_standard_box(b_show) // self == chest struct
{
    b_show = IS_TRUE(b_show);
    chest = self;
    
    if (b_show)
    {
        chest.zbarrier ShowZBarrierPiece(0); // Idle disabled chest.
    }
    else
    {
        for (piece_number = 0; piece_number < chest.zbarrier GetNumZBarrierPieces(); piece_number++)
        {
            chest.zbarrier HideZBarrierPiece(piece_number);
        }
    }
}

// Inspired from zm_magicbox::hide_chest(doBoxLeave)
function private custom_hide_chest() // self == chest struct
{
    if(isdefined(self.unitrigger_stub))
    {
        thread zm_unitrigger::unregister_unitrigger(self.unitrigger_stub);
    }

    if (isdefined(self.pandora_light))
    {
        self.pandora_light delete();
    }

    self.zbarrier clientfield::set("magicbox_closed_glow", false);
    self.hidden = true;
    self.zbarrier thread zm_magicbox::set_magic_box_zbarrier_state("away");
}

function private wait_for_chest_initialized()
{
    level endon("end_game");
    chests_quantity_expected = (HRMB_HELLROUND_CHESTS).size + (HRMB_NORMAL_CHESTS).size;

    while(!IsArray(level.chests) || level.chests.size < chests_quantity_expected)
    {
        WAIT_SERVER_FRAME;
    }
}

function private get_hellround_mysteryboxes() // self == chest struct
{
    hellround_chests_names = HRMB_HELLROUND_CHESTS;
    hellround_chests = [];
    foreach (chest_name in hellround_chests_names)
    {
        foreach (chest in level.chests)
        {
            if (!isdefined(chest.script_noteworthy))
            {
                PRINT_HR_DEBUG("chest script_noteworthy is missing");
                continue;
            }

            if (chest.script_noteworthy == chest_name)
            {
                hellround_chests[chest.script_noteworthy] = chest;
            }
        }
    }
    PRINT_HR_DEBUG("found " + hellround_chests.size + " hellround chests !");
    return hellround_chests;
}

function private get_standard_mysteryboxes() // self == chest struct
{
    standard_chests_names = HRMB_NORMAL_CHESTS;
    standard_chests = [];
    foreach (chest_name in standard_chests_names)
    {
        foreach (chest in level.chests)
        {
            if (!isdefined(chest.script_noteworthy))
            {
                PRINT_HR_DEBUG("chest script_noteworthy is missing");
                continue;
            }

            if (chest.script_noteworthy == chest_name)
            {
                standard_chests[chest.script_noteworthy] = chest;
            }
        }
    }
    PRINT_HR_DEBUG("found " + standard_chests.size + " standard chests !");
    return standard_chests;
}

function private is_mysterybox_from_array(mysterybox_array) // self == chest struct
{
    if (DEBUG_HELLROUNDS && isdefined(self.script_noteworthy))
    {
        PRINT_HR_DEBUG("chest script_noteworthy equals " + self.script_noteworthy);
    }
    return isdefined(self.script_noteworthy) && array::contains(mysterybox_array, self.script_noteworthy);
}

/* endregion */
/* region weapon management (inspired from MystifiedTulips scripts) */

function private add_all_extra_weapons_to_mysterybox(b_add)
{
    b_add = IS_TRUE(b_add);

    foreach (weapon_name in HRMB_EXTRA_WEAPONS)
    {
        thread temporarily_add_weapon_to_box(weapon_name, b_add);
    }

    foreach (weapon_name in HRMB_REGULAR_WEAPONS)
    {
        thread temporarily_add_weapon_to_box(weapon_name, !b_add);
    }

    level clientfield::set("add_extra_weapons_to_box", b_add);
}

function private temporarily_add_weapon_to_box(weapon_name, b_include_weapon)
{
    b_include_weapon = IS_TRUE(b_include_weapon);
    weapon = getWeapon(weapon_name);
    if (!zm_weapons::is_weapon_included(weapon))
    {
        PRINT_HR_DEBUG("weapon of name '" + weapon_name + "' is not registered in level weapons");
        return;
    }

    level.zombie_weapons[weapon].is_in_box = b_include_weapon;
}

/* endregion */
/* region firesale management */

function func_should_drop_fire_sale()
{
    // _zombiemode_check_firesale_loc_valid_func is used in this script has a global yes/no for firesale.
    if (self [[ level._zombiemode_check_firesale_loc_valid_func ]]())
    {
        return self zm_powerup_fire_sale::func_should_drop_fire_sale();
    }

    return false;
}

function private override_box_prices_for_hellround()
{
    foreach (chest in level.hellround_mystery_box.hellround_chests)
    {
        chest thread force_override_firesale_price();
        chest thread force_override_default_price();
    }
}

function private force_override_firesale_price()
{
    level endon("end_game");

    while (true)
    {
        WAIT_SERVER_FRAME;

        if (self.zombie_cost == 10)
        {
            self.zombie_cost = HRMB_OVERRIDE_FIRESALE_PRICE;
        }
    }
}

function private force_override_default_price()
{
    level endon("end_game");

    while (true)
    {
        WAIT_SERVER_FRAME;

        if (self.zombie_cost == 950)
        {
            self.zombie_cost = HRMB_OVERRIDE_DEFAULT_PRICE;
        }
    }
}

function private toggle_firesale(b_enabled)
{
    level notify("hrmb_toggle_firesale");
    level endon("hrmb_toggle_firesale");
    PRINT_HR_DEBUG("toggle_firesale: " + b_enabled);

    if (b_enabled)
    {
        level._zombiemode_check_firesale_loc_valid_func = &firesale_enabled;
        level notify("hrmb_watch_for_post_hellround_firesale_start");
        PRINT_HR_DEBUG("Firesale enabled");
    }
    else
    {
        level._zombiemode_check_firesale_loc_valid_func = &firesale_disabled;
        PRINT_HR_DEBUG("Firesale disabled");
        
        foreach (chest in level.chests)
        {
            if(isdefined(chest.sndEnt))
            {
                chest.sndEnt StopLoopSound();
                chest.sndEnt Delete();
                chest.sndEnt = undefined;
            }

            if (chest == level.chests[level.chest_index])
            {
                continue;
            }

            chest remove_chest_now();
        }

        level.zombie_vars["zombie_powerup_fire_sale_time"] = 0;
        level.zombie_vars["zombie_powerup_fire_sale_on"] = false;

        foreach (chest in level.hellround_mystery_box.original_chests)
        {
            chest.zombie_cost = 950;
        }
    }
}

function private firesale_enabled()
{
    return true;
}

function private firesale_disabled()
{
    if (level.hellround_mystery_box.permanent_unlock)
    {
        PRINT_HR_DEBUG("Permanently unlocked. Firesale enabled.");
        return true;
    }

    return false;
}

function private watch_for_post_hellround_firesale_start()
{
    level notify("hrmb_watch_for_post_hellround_firesale_start");
    level endon("hrmb_watch_for_post_hellround_firesale_start");

    while(!IS_TRUE(level.zombie_vars["zombie_powerup_fire_sale_on"]) || level.zombie_vars["zombie_powerup_fire_sale_time"] == 0)
    {
        WAIT_SERVER_FRAME;
    }
    PRINT_HR_DEBUG("Firesale grabbed");

    thread toggle_firesale(false);

    if ( ![[level._zombiemode_check_firesale_loc_valid_func]]() )
    {
        thread watch_for_post_hellround_firesale_start();
    }
}

/* endregion */
/* region debug */

function private list_temp() // self == chest
{
    level notify("hrmb_list_temp_" + self.script_noteworthy);
    level endon("hrmb_list_temp_" + self.script_noteworthy);
    level endon("end_game");

    zbarrier = self.zbarrier;
    while (true)
    {
        PRINT_HR_DEBUG("zbarrier GetZBarrierPieceState(0) :" + zbarrier GetZBarrierPieceState(0));
        PRINT_HR_DEBUG("zbarrier GetZBarrierPieceState(1) :" + zbarrier GetZBarrierPieceState(1));
        PRINT_HR_DEBUG("zbarrier GetZBarrierPieceState(2) :" + zbarrier GetZBarrierPieceState(2));
        PRINT_HR_DEBUG("zbarrier GetZBarrierPieceState(3) :" + zbarrier GetZBarrierPieceState(3));
        PRINT_HR_DEBUG("zbarrier GetZBarrierPieceState(4) :" + zbarrier GetZBarrierPieceState(4));
        PRINT_HR_DEBUG("zbarrier GetZBarrierPieceState(5) :" + zbarrier GetZBarrierPieceState(5));
        wait 1.0;
    }
}

function private modvar_debug_hellround_mysterybox()
{
    ModVar("hrmb", "");

    while(true)
    {
        WAIT_SERVER_FRAME;

        dvar_value = GetDvarString("hrmb", "");

        if(!isdefined(dvar_value) || dvar_value == "")
        {
            continue;
        }
        ModVar("hrmb", "");

        switch(Int(dvar_value))
        {
            case 1:
                toggle_hellround_mysteryboxes(true);
                break;
            case 2:
                toggle_hellround_mysteryboxes(false);
                break;
            case 3:
                permanent_unlock();
                break;
            case 4:
                PRINT_HR_DEBUG("Current chest is:" + level.chests[level.chest_index].script_noteworthy);
                PRINT_HR_DEBUG("Current isdefined(no_fly_away) is:" + isdefined(level.chests[level.chest_index].no_fly_away));
                PRINT_HR_DEBUG("Current !treasure_chest_firesale_active() is:" + !zm_magicbox::treasure_chest_firesale_active());
                PRINT_HR_DEBUG("Current chest_min_move_usage count is:" + level.chest_min_move_usage);
                PRINT_HR_DEBUG("Current chest_accessed count is:" + level.chest_accessed);
                PRINT_HR_DEBUG("Current chest_moves count is:" + level.chest_moves);                
                break;
            default:
                PRINT_HR_DEBUG("The actual active chest are at the number of:" + level.chests.size);
                PRINT_HR_DEBUG("The registered standard ones are of:" + level.hellround_mystery_box.original_chests.size);
                PRINT_HR_DEBUG("The registered hellround ones are of:" + level.hellround_mystery_box.hellround_chests.size);
                standard_chests = "";
                foreach(chest_name in HRMB_NORMAL_CHESTS)
                {
                    standard_chests += " " + chest_name;
                }
                PRINT_HR_DEBUG("The standard ones are: " + standard_chests);
                hellround_chests = "";
                foreach(chest_name in HRMB_HELLROUND_CHESTS)
                {
                    hellround_chests += " " + chest_name;
                }
                PRINT_HR_DEBUG("The hellround ones are: " + hellround_chests);
                break;
        }
    }
}

function private box_always_move(original_joker_chance)
{
    PRINT_HR_DEBUG("original_joker_chance is " + original_joker_chance);
    PRINT_HR_DEBUG("level.chests[level.chest_index].no_fly_away is defined" + isdefined(level.chests[level.chest_index].no_fly_away));

    return original_joker_chance;
    //return 100; // joker_chance = 100%, means box always move.
}

/* endregion */