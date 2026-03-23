#using scripts\shared\laststand_shared; 
#using scripts\shared\aat_shared; 
#using scripts\shared\flag_shared; 
#using scripts\shared\array_shared; 
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared; 

#using scripts\zm\_zm_zonemgr; 
#using scripts\zm\_zm_powerups; 

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\zm_easter_egg_bones.gsh;

#precache("xmodel", MODEL_SKELETON_0);
#precache("xmodel", MODEL_SKELETON_1);
#precache("xmodel", MODEL_SKELETON_2);
#precache("xmodel", MODEL_BONES_FLOAT);
#precache("fx", FX_BONES_START);
#precache("fx", FX_BONES_LOOP);
#precache("fx", FX_BONES_END);
#precache("fx", FX_BONES_TRAIL);
#precache("fx", FX_BONES_MERGE);
#precache("script_bundle", BUNDLE_BONES_FLOAT);
#using_animtree(ANIMTREE_BONES_FLOAT);

#define TRIGGER_NOTIFICATION "level_notify_ee_bones_shot"
#define TRIGGERS_COMPLETE_NOTIFICATION "level_notify_every_ee_bones_shot"

#namespace zm_easter_egg_bones;

REGISTER_SYSTEM_EX("zm_easter_egg_bones", &_init, &_main, undefined)

/* region init & run */

class ShootableBonesEasterEgg
{
    var triggers;
    var reward_ents;
}

function private _init()
{
    level.shootable_easter_egg = new ShootableBonesEasterEgg();
    level.shootable_easter_egg.triggers = _retrieve_and_setup_triggers();
    level.shootable_easter_egg.reward_ents = GetEntArray(EASTER_EGG_REWARD_LOCATION_NAME, "targetname");
}

function private _retrieve_and_setup_triggers()
{
    triggers = [];

    origins = GetEntArray(EASTER_EGG_TRIGGER_ORIGIN, "targetname");
    MAKE_ARRAY(origins);
    foreach (origin in origins)
    {
        trigger = GetEnt(origin.target, "targetname");
        trigger.angles = origin.angles;
        triggers[triggers.size] = trigger;
    }

    return triggers;
}

function private _main()
{
    if (DEBUG_SKULL)
    {
        thread _modvar_debug_bones();
        level flag::wait_till("initial_blackscreen_passed");
    }

    triggers = _select_bone_piles_triggers_for_level(level.shootable_easter_egg.triggers);
    if (!IsArray(triggers) || triggers.size == 0)
    {
        PRINT_DEBUG_SKULL("No triggers were selected for easter egg");
        return;
    }

    foreach (trigger in triggers)
    {
        trigger thread _trigger_think();
    }

    thread _wait_for_all_triggers(triggers.size);
    level.shootable_easter_egg.reward_ents thread _callback_on_completion();
}

/* endregion */
/* region trigger logic */

function private _select_bone_piles_triggers_for_level(triggers)
{
    MAKE_ARRAY(triggers);
    triggers = array::randomize(triggers);
    valid_triggers = [];

    trigger_index = 0;
    foreach (trigger in triggers)
    {
        trigger.target_models = GetEntArray(trigger.target, "targetname");
        if (!IsArray(trigger.target_models) || trigger.target_models.size == 0)
        {
            PRINT_DEBUG_SKULL("skull trigger has no models");
            continue;
        }

        if (trigger_index >= EASTER_EGG_MAX_SPOTS)
        {
            foreach (model in trigger.target_models)
            {
                model Delete();
            }
            trigger Delete();
            continue;
        }

        valid_triggers[valid_triggers.size] = trigger;
        trigger_index++;
    }

    return valid_triggers;
}

function private _trigger_think() // self == trigger
{
    level endon("end_game");
    trigger = self;

    do
    {
        trigger waittill("trigger", who);
    } 
    while (!IsPlayer(who) || !who _has_turned_aat());

    trigger _play_bones_animation();

    level notify(TRIGGER_NOTIFICATION);
    trigger Delete();
}

function private _has_turned_aat() // self == player
{
    current_aat = self aat::getAATOnWeapon(self GetCurrentWeapon());
    return isdefined(current_aat) && current_aat.name == ZM_AAT_TURNED_NAME;
}

/* endregion */
/* region fx sound & animation */

function private _play_bones_animation() // self == trigger
{
    level endon("end_game");
    origin = self.origin;
    angles = self.angles;
    PRINT_DEBUG_SKULL("Pile of bones origin is: " + origin);
    PRINT_DEBUG_SKULL("Pile of bones angle is: " + angles);

    self _make_bones_disappear(origin);
    thread _loop_bones_fx(origin, angles);
    thread _float_bones_animation(origin, angles);
    thread _float_trail_animation(origin, angles);
    waitrealtime(BONES_FLOAT_TRAVEL_TIME + BONES_FLOAT_ASSEMBLE_TIME);
    
    PlayFx(FX_BONES_END, origin, (0, 0, 0), (0, 0, 0));

    skeleton = _spawn_skeleton(origin + (0, 0, BONES_FLOAT_DISTANCE), angles);
    skeleton thread _float_skeleton_animation();
    skeleton thread _rotate_skeleton_animation();

    skeleton thread _remove_skeleton_on_completion();
}

function private _make_bones_disappear(origin) // self == trigger
{
    PlayFX(FX_BONES_START, origin, (0, 0, 0), (0, 0, 0));
    PlaySoundAtPosition(SOUND_BONES_SHOT, origin);
    waitrealtime(FX_BONES_START_TIME);
    
    foreach(model in self.target_models)
    {
        model Delete();
    }
    PlaySoundAtPosition(SOUND_BONES_POOF, origin);
}

function private _loop_bones_fx(origin, angles)
{
    trigger_origin = util::spawn_model("tag_origin", origin, (0, 0, 0));
    PlayFXOnTag(FX_BONES_LOOP, trigger_origin, "tag_origin");
    waitrealtime(BONES_FLOAT_TRAVEL_TIME + BONES_FLOAT_ASSEMBLE_TIME);
    trigger_origin Delete();
}

function private _float_bones_animation(origin, angles)
{
    distance_offset = AnglesToForward(angles) * 20;
    float_model = util::spawn_model(MODEL_BONES_FLOAT, origin + (0, 0, -10) + distance_offset, angles);
    float_model MoveZ(BONES_FLOAT_DISTANCE, BONES_FLOAT_TRAVEL_TIME);
    float_model Vibrate((0, 100, 0), 1.5, BONES_FLOAT_TRAVEL_TIME/4, BONES_FLOAT_TRAVEL_TIME);
    waitrealtime(BONES_FLOAT_TRAVEL_TIME - 0.5);

    float_model RotateTo(CombineAngles(angles, ANGLES_BONES_FLOAT), 0.5);
    float_model MoveTo(float_model.origin + (0, 0, 10) - distance_offset, 0.5);
    PlaySoundAtPosition(SOUND_BONES_ASSEMBLE, float_model.origin);
    waitrealtime(0.5);

    float_model UseAnimTree(#animtree);
    float_model AnimScripted("notify", float_model.origin, float_model.angles, ANIM_BONES_FLOAT, "normal", ANIM_BONES_FLOAT);
    sound_play_offset = 0.5;
    waitrealtime(BONES_FLOAT_ASSEMBLE_TIME - sound_play_offset);
    PlaySoundAtPosition(SOUND_BONES_MERGE, float_model.origin);
    waitrealtime(sound_play_offset);
    PlayFX(FX_BONES_MERGE, float_model.origin, (0, 0, 0), (0, 0, 0));

    float_model StopAnimScripted(0, true);
    float_model Delete();
}

function private _float_trail_animation(origin, angles)
{
    fx_trail_origin = util::spawn_model("tag_origin", origin, angles);
    PlayFXOnTag(FX_BONES_TRAIL, fx_trail_origin, "tag_origin");
    fx_trail_origin MoveZ(BONES_FLOAT_DISTANCE, BONES_FLOAT_TRAVEL_TIME);
    waitrealtime(BONES_FLOAT_TRAVEL_TIME);
    fx_trail_origin Delete();
}

function private _spawn_skeleton(origin, angles)
{
    skeletons = MODELS_SKELETONS;
    respective_angles = ANGLES_SKELETONS;
    index = RandomInt(skeletons.size);

    return util::spawn_model(skeletons[index], origin + SKELETON_ORIGIN_DISTANCE_OFFSET, CombineAngles(angles, respective_angles[index]));
}

function private _float_skeleton_animation() // self == skeleton model
{
    level endon("end_game");
    self endon("deleted");

    offset = SKELETON_FLOAT_DISTANCE;
    self PlayLoopSound(SOUND_BONES_FLOAT_LOOP, 1.0);
    while(true)
    {
        self MoveZ(offset, SKELETON_FLOAT_TIME, SKELETON_FLOAT_TIME/2, SKELETON_FLOAT_TIME/2);
        self waittill("movedone");
        offset *= -1;
    }
}

function private _rotate_skeleton_animation() // self == skeleton model
{
    level endon("end_game");
    self endon("deleted");

    while(true)
    {
        self RotateYaw(360, SKELETON_ROTATION_TIME);
        self waittill("rotatedone");
    }
}

function private _remove_skeleton_on_completion() // self == skeleton model
{
    level waittill(TRIGGERS_COMPLETE_NOTIFICATION);
    
    waitrealtime(FX_BONES_DISAPPEAR_DELAY);
    PlayFX(FX_BONES_MERGE, self.origin, (0, 0, 0), (0, 0, 0));
    PlaySoundAtPosition(SOUND_BONES_POOF, self.origin);

    self notify("deleted");
    self Delete();
}

/* endregion */
/* region reward logic */

function private _wait_for_all_triggers(count)
{
    level endon("end_game");

    for (i = 0; i < count; i++)
    {
        level waittill(TRIGGER_NOTIFICATION);
        PRINT_DEBUG_SKULL("Pile of bones shot !");
    }

    level notify(TRIGGERS_COMPLETE_NOTIFICATION);
}

function private _callback_on_completion() // self == reward ent array
{
    level endon("end_game");

    level waittill(TRIGGERS_COMPLETE_NOTIFICATION);
    PRINT_DEBUG_SKULL("Shootable skeleton easter egg completed !");

    // Setup
    reward_location = _choose_reward_location(self);
    spawn_location = GetClosestPointOnNavMesh(reward_location, 100, 5);

    // Rewards & Events
    wait 0.75;
    PlaySoundAtPosition(SOUND_BONES_COMPLETED, spawn_location);
    level thread zm_powerups::specific_powerup_drop(EASTER_EGG_POWERUP_REWARD, spawn_location, undefined, undefined, undefined, undefined, true);
}

function private _choose_reward_location(ents)
{
    MAKE_ARRAY(ents);
    players = array::randomize(GetPlayers());
    player = undefined;
    foreach(player_candidate in players)
    {
        if (!player_candidate laststand::player_is_in_laststand() 
        && (!isdefined(player_candidate.sessionstate) || player_candidate.sessionstate != "spectator"))
        {
            player = player_candidate;
            break;
        }
    }

    while(ents.size > 0)
    {
        WAIT_SERVER_FRAME;
        candidate_spot = ArrayGetClosest(player.origin, ents);
        zone = zm_zonemgr::get_zone_from_position(candidate_spot.origin, true);

        if (!isdefined(zone))
        {
            PRINT_DEBUG_SKULL("zone for candidate at " + candidate_spot.origin + " is undefined");
            continue;
        }

        if(zm_zonemgr::zone_is_enabled(zone))
        {
            PRINT_DEBUG_SKULL("candidate_spot found at " + candidate_spot.origin);
            return candidate_spot.origin;
        }
        else
        {
            PRINT_DEBUG_SKULL("zone for candidate at " + candidate_spot.origin + " is not active");
            ArrayRemoveValue(ents, candidate_spot);
        }
    }

    if (isdefined(player))
    {
        PRINT_DEBUG_SKULL("Could not find any valid candidate for the reward. Spawning next to player.");
        return player.origin + (150, 150, 0);
    }
    else
    {
        PRINT_DEBUG_SKULL("Could not find any valid candidate for the reward. Spawning on (0 0 0).");
        return GetClosestPointOnNavMesh((0, 0, 0), 50000, 100);
    }
}

/* endregion */
/* region debug */

function private _modvar_debug_bones()
{
    ModVar("eebones", "");

    while(true)
    {
        WAIT_SERVER_FRAME;

        dvar_value = GetDvarString("eebones", "");

        if(!isdefined(dvar_value) || dvar_value == "")
        {
            continue;
        }
        ModVar("eebones", "");

        switch(Int(dvar_value))
        {
            case 1:
                _give_turned_weapon_to_host();
                break;
            default:
                break;
        }
    }
}

function private _give_turned_weapon_to_host()
{
    foreach(player in GetPlayers())
    {
        if (player IsHost())
        {
            weapon = player GetCurrentWeapon();
            player aat::acquire(weapon, ZM_AAT_TURNED_NAME);
            break;
        }
    }
}

/* endregion */
