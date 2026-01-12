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

    var chests_lookuptable;
}

function private init()
{
    clientfield::register("world", "add_extra_weapons_to_box", VERSION_SHIP, 1, "int");

    level.hellround_mystery_box = new HellroundMysteryBox();
    level.hellround_mystery_box.original_chests = [];
    level.hellround_mystery_box.hellround_chests = [];
    level.hellround_mystery_box.chests_lookuptable = [];
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
}

/* region setup */

function private overwrite_level_chests_and_register_hellround_chests()
{
    previous_chest = level.chests[level.chest_index];
    
    level.hellround_mystery_box.hellround_chests = get_hellround_mysteryboxes();
    level.hellround_mystery_box.original_chests = get_standard_mysteryboxes();

    foreach (chest in level.hellround_mystery_box.hellround_chests)
    {
        chest.zombie_cost = HRMB_CHEST_COST;
        
    }

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

function private overwrite_active_box()
{
    while (level flag::get("moving_chest_now"))
    {
        WAIT_SERVER_FRAME;
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
        thread overwrite_active_box();
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

function private restore_active_box()
{
    while (level flag::get("moving_chest_now"))
    {
        WAIT_SERVER_FRAME;
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
    current_chest.no_fly_away = false;
    current_chest custom_hide_chest();
    current_chest hb21_zm_magicbox_botd::botd_force_show_box(false);

    new_chest = current_chest.chest_to_restore;
    level.chests[level.chest_index] = new_chest;

    new_chest zm_magicbox::show_chest();
}

function toggle_hellround_mysteryboxes(b_enabled)
{
    b_enabled = IS_TRUE(b_enabled);

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

    thread add_all_extra_weapons_to_mysterybox(b_enabled);

    if (b_enabled)
    {
        thread overwrite_active_box();
    }
    else
    {
        thread restore_active_box();
    }
}

/* endregion */
/* region util */

function private waittill_chest_idle() // self == chest
{
    // If chest moves, state doesn't change and get stuck.
    level endon("moving_chest_now");

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
        WAIT_SERVER_FRAME;
    }
}

function private force_show_standard_box(b_show) // self == chest struct
{
    b_show = IS_TRUE(b_show);
    chest = self;
    
    if (b_show)
    {
        for (piece_number = 0; piece_number < chest.zbarrier GetNumZBarrierPieces(); piece_number++)
        {
            if (piece_number == 2)
            {
                continue;
            }
            chest.zbarrier ShowZBarrierPiece(piece_number);
        }
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
    PRINT_HR_DEBUG("weapon " + weapon_name + " was " + ( b_include_weapon ? "added to" : "removed_from" ) + " box");
}

/* endregion */
/* region debug */

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
    return original_joker_chance;
    //return 100; // joker_chance = 100%, means box always move.
}

/* endregion */