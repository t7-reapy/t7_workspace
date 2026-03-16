#using scripts\shared\array_shared; 
// Inspired from Fearlessninja98's Perk Poster Challenge
#using scripts\zm\_zm_utility;
#using scripts\shared\flag_shared; 
#using scripts\shared\callbacks_shared; 
#using scripts\shared\util_shared; 
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\zm_poster_easter_egg.gsh;

#precache("xmodel", POSTER_MODEL_1);
#precache("xmodel", POSTER_MODEL_2);
#precache("xmodel", POSTER_MODEL_3);
#precache("xmodel", POSTER_MODEL_4);
#precache("xmodel", POSTER_MODEL_5);
#precache("xmodel", POSTER_MODEL_6);
#precache("xmodel", POSTER_MODEL_7);
#precache("xmodel", POSTER_MODEL_8);
#precache("xmodel", POSTER_MODEL_9);
#precache("xmodel", POSTER_MODEL_10);
#precache("xmodel", POSTER_MODEL_11);

#namespace zm_poster_easter_egg;

REGISTER_SYSTEM_EX("zm_poster_easter_egg", &_init, &_main, undefined)

class ShootablePosterEasterEgg
{
    var triggers;
}

function private _init()
{
    level.shootable_easter_egg = new ShootablePosterEasterEgg();
    level.shootable_easter_egg.triggers = GetEntArray(POSTER_TRIGGER_NAME, "targetname");
}

function private _main()
{
    if (DEBUG_POSTER)
    {
        level flag::wait_till("initial_blackscreen_passed");
    }

    triggers = level.shootable_easter_egg.triggers;
    if (!IsArray(triggers) || triggers.size == 0)
    {
        return;
    }

    _retrieve_models_and_randomize_posters(triggers);
    
    foreach (trigger in triggers)
    {
        trigger thread _trigger_think();
    }

    thread _wait_for_all_triggers(triggers.size);
    thread _callback_on_completion();
}

function private _retrieve_models_and_randomize_posters(triggers)
{
    model_overrides = POSTER_MODEL_OVERRIDES; 
    MAKE_ARRAY(model_overrides);
    model_overrides = array::randomize(model_overrides);
    PRINT_DEBUG_POSTER("Poster models areat the number of: " + model_overrides.size);

    if (!IsArray(model_overrides) || model_overrides.size <= 0)
    {
        PRINT_DEBUG_POSTER("model_overrides is not a valid array.");
        return;
    }

    override_index = 0;
    foreach (trigger in triggers)
    {
        trigger.target_model = GetEnt(trigger.target, "targetname");
        PRINT_DEBUG_POSTER("trigger.target_model is found: " + IsEntity(trigger.target_model));

        if (!IsEntity(trigger.target_model))
        {
            continue;
        }

        model_override = model_overrides[override_index % model_overrides.size];
        PRINT_DEBUG_POSTER("override model is: " + model_override);
        trigger.target_model SetModel(model_override);
        override_index++;

        if (DEBUG_POSTER)
        {
            wait 1;
        }
    }
}

function private _trigger_think() // self == trigger
{
    level endon("end_game");

    trigger = self;
    model = trigger.target_model;
    player = undefined;

    if (!isdefined(model))
    {
        return;
    }
    
    while (!IsPlayer(player))
    {
        trigger waittill("trigger", player);
    }

    //TODO: play fx on the model/trigger's origin POSTER_TRIGGER_FX
    //TODO: play sound on the model/trigger's origin POSTER_TRIGGER_SOUND
    
    level notify(POSTER_TRIGGER_LEVEL_NOTIFICATION);
    trigger Delete();
    model Delete();
}

function private _wait_for_all_triggers(count)
{
    level endon("end_game");

    for (i = 0; i < count; i++)
    {
        level waittill(POSTER_TRIGGER_LEVEL_NOTIFICATION);
        PRINT_DEBUG_POSTER("Shootable poster shot !");
    }

    level notify(POSTER_COMPLETION_LEVEL_NOTIFICATION);
}

function private _callback_on_completion()
{
    level endon("end_game");

    level waittill(POSTER_COMPLETION_LEVEL_NOTIFICATION);
    PRINT_DEBUG_POSTER("Shootable posters easter egg completed !");

    // TODO: reward/event
}
