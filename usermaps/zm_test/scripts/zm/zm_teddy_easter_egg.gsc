#using scripts\zm\_zm_zonemgr; 
#using scripts\zm\_zm_powerups; 
#using scripts\zm\_zm_utility;

#using scripts\shared\array_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\util_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\zm_teddy_easter_egg.gsh;

#precache("fx", TEDDY_TRIGGER_FX);

#namespace zm_teddy_easter_egg;

REGISTER_SYSTEM_EX("zm_teddy_easter_egg", &_init, &_main, undefined)

class ShootableTeddyEasterEgg
{
    var triggers;
    var music_started;
    var triggers_paused;
}

function private _init()
{
    clientfield::register("world", TEDDY_CLIENTFIELD_MUSIC, VERSION_SHIP, 1, "int");

    level.teddy_easter_egg = new ShootableTeddyEasterEgg();
    level.teddy_easter_egg.triggers = GetEntArray(TEDDY_TRIGGER_NAME, "targetname");
    level.teddy_easter_egg.music_started = false;
    level.teddy_easter_egg.triggers_paused = false;
}

function private _main()
{
    if (DEBUG_TEDDY)
    {
        level flag::wait_till("initial_blackscreen_passed");
    }

    triggers = level.teddy_easter_egg.triggers;
    if (!IsArray(triggers) || triggers.size == 0)
    {
        return;
    }

    triggers = _retrieve_models_and_randomize_teddys(triggers);
    PRINT_DEBUG_TEDDY("Teddy selected are: " + triggers.size);
    
    foreach (trigger in triggers)
    {
        trigger thread _trigger_think();
    }

    thread _wait_for_all_triggers(triggers.size);
    thread _callback_on_completion();
}

function private _retrieve_models_and_randomize_teddys(triggers)
{
    triggers = array::randomize(triggers);
    selected_triggers = [];
    PRINT_DEBUG_TEDDY("Teddy models are at the number of: " + triggers.size);

    triggers_selected_number = 0;
    foreach (trigger in triggers)
    {
        trigger.target_model = GetEnt(trigger.target, "targetname");
        if (!IsEntity(trigger.target_model))
        {
            PRINT_DEBUG_TEDDY("trigger.target_model was not found");
            continue;
        }

        // In case we reach the teddy bear limit, we delete other teddys.
        // This creates even more randomness considering their location.
        if (triggers_selected_number >= TEDDY_NUMBER)
        {
            trigger.target_model Delete();
            trigger Delete();
            continue;
        }

        selected_triggers[selected_triggers.size] = trigger;
        triggers_selected_number++;
    }

    return selected_triggers;
}

function private _trigger_think() // self == trigger
{
    level endon("end_game");

    trigger = self;
    model = trigger.target_model;
    player = undefined;
    
    model PlayLoopSound(TEDDY_IDLE_SOUND);

    while (level.teddy_easter_egg.triggers_paused || !IsPlayer(player))
    {
        trigger waittill("trigger", player);
    }

    PlayFX(TEDDY_TRIGGER_FX, trigger.origin, AnglesToForward(trigger.angles), AnglesToUp(trigger.angles), false);
    PlaySoundAtPosition(TEDDY_TRIGGER_SOUND, trigger.origin);
    
    level notify(TEDDY_TRIGGER_LEVEL_NOTIFICATION);
    trigger Delete();
    model Delete();
}

function private _wait_for_all_triggers(count)
{
    level endon("end_game");

    for (i = 0; i < count; i++)
    {
        PRINT_DEBUG_TEDDY("Left to found: " + (count - i));
        level waittill(TEDDY_TRIGGER_LEVEL_NOTIFICATION);        
        PRINT_DEBUG_TEDDY("Shootable teddy shot !");
    }

    level notify(TEDDY_COMPLETION_LEVEL_NOTIFICATION);
}

function private _callback_on_completion() // self == reward ent array
{
    level endon("end_game");

    level waittill(TEDDY_COMPLETION_LEVEL_NOTIFICATION);
    PRINT_DEBUG_TEDDY("Shootable teddys easter egg completed !");

    level clientfield::set(TEDDY_CLIENTFIELD_MUSIC, true);
    level.teddy_easter_egg.music_started = true;
}

function toggle_music_easter_egg(b_enable)
{
    enabled = IS_TRUE(b_enable);
    PRINT_DEBUG_TEDDY("toggle_music_easter_egg called with: " + enabled);
    level.teddy_easter_egg.triggers_paused = !enabled;
    level clientfield::set(TEDDY_CLIENTFIELD_MUSIC, enabled && level.teddy_easter_egg.music_started);
}
