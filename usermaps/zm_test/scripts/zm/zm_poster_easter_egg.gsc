#using scripts\zm\_zm_zonemgr; 
#using scripts\zm\_zm_powerups; 
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
#precache("fx", POSTER_TRIGGER_FX);

#namespace zm_poster_easter_egg;

REGISTER_SYSTEM_EX("zm_poster_easter_egg", &_init, &_main, undefined)

class ShootablePosterEasterEgg
{
    var triggers;
    var reward_ents;
}

function private _init()
{
    level.shootable_easter_egg = new ShootablePosterEasterEgg();
    level.shootable_easter_egg.triggers = GetEntArray(POSTER_TRIGGER_NAME, "targetname");
    level.shootable_easter_egg.reward_ents = GetEntArray(POSTER_REWARD_ENTITY_NAME, "targetname");
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

    triggers = _retrieve_models_and_randomize_posters(triggers);
    
    foreach (trigger in triggers)
    {
        trigger thread _trigger_think();
    }

    thread _wait_for_all_triggers(triggers.size);
    level.shootable_easter_egg.reward_ents thread _callback_on_completion();
}

function private _retrieve_models_and_randomize_posters(triggers)
{
    triggers = array::randomize(triggers);
    valid_triggers = [];

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

        // In case we already used all available materials, we delete other posters.
        // This creates even more randomness considering their location.
        if (override_index == model_overrides.size)
        {
            trigger.target_model Delete();
            trigger Delete();
            continue;
        }

        model_override = model_overrides[override_index];
        PRINT_DEBUG_POSTER("override model is: " + model_override);
        trigger.target_model SetModel(model_override);
        valid_triggers[valid_triggers.size] = trigger;
        override_index++;

        if (DEBUG_POSTER)
        {
            wait 1;
        }
    }

    return valid_triggers;
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

    PlayFX(POSTER_TRIGGER_FX, trigger.origin, AnglesToForward(trigger.angles), AnglesToUp(trigger.angles), false);
    PlaySoundAtPosition(POSTER_TRIGGER_SOUND, trigger.origin);
    
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

function private _callback_on_completion() // self == reward ent array
{
    level endon("end_game");

    level waittill(POSTER_COMPLETION_LEVEL_NOTIFICATION);
    PRINT_DEBUG_POSTER("Shootable posters easter egg completed !");

    // Setup
    reward_entities = self;
    MAKE_ARRAY(reward_entities);
    reward_location = _choose_reward_location(reward_entities);
    spawn_location = GetClosestPointOnNavMesh(reward_location, 100, 5);
    PRINT_DEBUG_POSTER("spawn reward location is: " + spawn_location);

    // Rewards & Events
    level thread zm_powerups::specific_powerup_drop("empty_bottle", spawn_location, undefined, undefined, undefined, undefined, true);
    VideoStart(POSTER_EVENT_VIDEO_NAME, true);
    // TODO: enable cameras
}

function stop_video_and_cameras()
{
    VideoStop(POSTER_EVENT_VIDEO_NAME);
}

function private _choose_reward_location(ents)
{
    players = GetPlayers();
    player = players[RandomInt(players.size)]; 

    while(ents.size > 0)
    {
        WAIT_SERVER_FRAME;
        candidate_spot = ArrayGetClosest(player.origin, ents);
        zone = zm_zonemgr::get_zone_from_position(candidate_spot.origin, true);

        if (!isdefined(zone))
        {
            PRINT_DEBUG_POSTER("zone for candidate at " + candidate_spot.origin + " is undefined");
            continue;
        }

        if(zm_zonemgr::zone_is_enabled(zone))
        {
            PRINT_DEBUG_POSTER("candidate_spot found");
            return candidate_spot.origin;
        }
        else
        {
            PRINT_DEBUG_POSTER("zone for candidate at " + candidate_spot.origin + " is not active");
            ArrayRemoveValue(ents, candidate_spot);
        }
    }

    PRINT_DEBUG_POSTER("Could not find any valid candidate for the reward");
    return player.origin + (150, 150, 0);
}