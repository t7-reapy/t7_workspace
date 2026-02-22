#using scripts\zm\_zm; 
#using scripts\zm\_util;
#using scripts\zm\_zm_utility;

#using scripts\shared\animation_shared; 
#using scripts\shared\array_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\zm_animated_fauna.gsh;

#precache("script_bundle", "p7_fxanim_cp_lotus_atrium_ravens_bundle");
#precache("script_bundle", "p7_fxanim_mp_apartments_rat_comd_p1_bundle");
#precache("script_bundle", "p7_fxanim_mp_apartments_rat_heli_p2_bundle");
#precache("script_bundle", "p7_fxanim_mp_apartments_rat_kit_p3_bundle");
#using_animtree(ANIMTREE);

#namespace zm_animated_fauna;

REGISTER_SYSTEM_EX("zm_animated_fauna", &_init, &_main, undefined)

/* region Classes */

class Rat
{
    var ScriptModel;
    var ScriptModelOrigin;
    var Animation;

    constructor()
    {
        ScriptModel = undefined;
        ScriptModelOrigin = undefined;
        Animation = undefined;
    }

    function IsInitialized()
    {
        if (DEBUG_FAUNA)
        {
            if (!isdefined(ScriptModel))
            {
                PRINT_FAUNA_DEBUG("Rat ScriptModel is not defined");
            }

            if (!isdefined(ScriptModelOrigin))
            {
                PRINT_FAUNA_DEBUG("Rat ScriptModelOrigin is not defined");
            }

            if (!isdefined(Animation))
            {
                PRINT_FAUNA_DEBUG("Rat Animation are not defined");
            }
        }

        return isdefined(ScriptModel) 
            && isdefined(ScriptModelOrigin)
            && isdefined(Animation);
    }

    function Setup(script_model, animations)
    {
        ScriptModel = script_model;
        ScriptModel UseAnimTree(#animtree);
        ScriptModelOrigin = script_model.origin;
        Animation = animations;
        ShowModel(false);
    }
    
    function private ShowModel(b_enabled)
    {
        // Keep things visible if we are debugging.
        if (DEBUG_FAUNA)
        {
            return;
        }

        if (IS_TRUE(b_enabled))
        {
            ScriptModel Show();
        }
        else
        {
            ScriptModel Hide();
        }
    }

    function PlayAnimation()
    {
        if (!IsInitialized())
        {
            PRINT_FAUNA_DEBUG("Rat is not initialized");
            return;
        }

        if (ScriptModel IsPlayingAnimScripted())
        {
            PRINT_FAUNA_DEBUG("Rat animation is already playing. Skipping.");
            return;
        }

        ShowModel(true);
        PRINT_FAUNA_DEBUG("Playing rat animation.");

        ScriptModel.origin = ScriptModelOrigin;
        ScriptModel AnimScripted("notify", ScriptModel.origin, ScriptModel.angles, Animation, "normal", Animation, RAVEN_ANIMATION_RATE, 0);
        wait RAT_ANIMATION_MAX_TIME;
        ScriptModel StopAnimScripted(0, true);
        
        PRINT_FAUNA_DEBUG("Rat animation done.");
        ShowModel(false);
    }

    function StopAnimation()
    {
        if (!IsInitialized())
        {
            PRINT_FAUNA_DEBUG("Rat is not initialized");
            return;
        }

        if (!ScriptModel IsPlayingAnimScripted())
        {
            PRINT_FAUNA_DEBUG("Rat animation is not playing. Skipping.");
            return;
        }

        ScriptModel StopAnimScripted(0, true);
        ScriptModel.origin = ScriptModelOrigin;
        ShowModel(false);
    }
}

class Raven
{
    var ScriptModel;
    var ScriptModelOrigin;
    var Animations;

    constructor()
    {
        ScriptModel = undefined;
        ScriptModelOrigin = undefined;
        Animations = undefined;
    }

    function IsInitialized()
    {
        if (DEBUG_FAUNA)
        {
            if (!isdefined(ScriptModel))
            {
                PRINT_FAUNA_DEBUG("Raven ScriptModel is not defined");
            }

            if (!isdefined(ScriptModelOrigin))
            {
                PRINT_FAUNA_DEBUG("Raven ScriptModelOrigin is not defined");
            }

            if (!isdefined(Animations))
            {
                PRINT_FAUNA_DEBUG("Raven Animations are not defined");
            }
        }

        return isdefined(ScriptModel)
            && isdefined(ScriptModelOrigin)
            && isdefined(Animations);
    }

    function Setup(script_model, anims)
    {
        ScriptModel = script_model;
        ScriptModel UseAnimTree(#animtree);
        ScriptModelOrigin = script_model.origin;
        Animations = anims;
        ShowModel(false);
    }
    
    function private ShowModel(b_enabled)
    {
        // Keep things visible if we are debugging.
        if (DEBUG_FAUNA)
        {
            return;
        }

        if (IS_TRUE(b_enabled))
        {
            ScriptModel Show();
        }
        else
        {
            ScriptModel Hide();
        }
    }

    function PlayAnimation()
    {
        if (!IsInitialized())
        {
            PRINT_FAUNA_DEBUG("Raven is not initialized");
            return;
        }

        if (ScriptModel IsPlayingAnimScripted())
        {
            PRINT_FAUNA_DEBUG("Raven animation is already playing. Skipping.");
            return;
        }

        ShowModel(true);
        animation = Animations[RandomInt(Animations.size)];
        PRINT_FAUNA_DEBUG("Playing raven animation: " + animation);

        ScriptModel.origin = ScriptModelOrigin;
        ScriptModel AnimScripted("notify", ScriptModel.origin, ScriptModel.angles, animation, "normal", animation, RAVEN_ANIMATION_RATE, 0);
        wait GetAnimLength(animation);
        ScriptModel StopAnimScripted(0, true);

        PRINT_FAUNA_DEBUG("Raven animation done.");
        ShowModel(false);
    }

    function StopAnimation()
    {
        if (!IsInitialized())
        {
            PRINT_FAUNA_DEBUG("Raven is not initialized");
            return;
        }

        if (!ScriptModel IsPlayingAnimScripted())
        {
            PRINT_FAUNA_DEBUG("Raven animation is not playing. Skipping.");
            return;
        }

        ScriptModel StopAnimScripted(0, true);
        ScriptModel.origin = ScriptModelOrigin;
        ShowModel(false);
    }
}

class Fauna
{
    var Rats;
    var Ravens;

    function SetupRats()
    {
        Rats = [];
        rat_models = SCRIPTMODELS_RATS;
        rat_anims = XANIMS_RATS;
        for (i = 0; i < rat_models.size; i++)
        {
            script_model = GetEnt(rat_models[i], "targetname");

            Rat = new Rat();
            [[Rat]]->Setup(script_model, rat_anims[i]);
            Rats[level.Fauna.Rats.size] = Rat;
        }
    }

    function SetupRavens()
    {
        Ravens = [];
        ravens_models = SCRIPTMODEL_RAVENS;
        raven_anims = XANIMS_RAVEN;
        foreach (raven_model in ravens_models)
        {
            script_model = GetEnt(raven_model, "targetname");

            Raven = new Raven();
            [[Raven]]->Setup(script_model, raven_anims);
            Ravens[Ravens.size] = Raven;
        }
    }
}

/* endregion */

function private _init()
{
    level.Fauna = new Fauna();
    [[level.Fauna]]->SetupRats();
    [[level.Fauna]]->SetupRavens();
}

function private _main()
{
    if (DEBUG_FAUNA)
    {
        thread modvar_debug_fauna();
    }
}

/* region Rat logic */

function toggle_rats(b_enabled)
{
    if (IS_TRUE(b_enabled))
    {
        thread _loop_rat_animations();
        PRINT_FAUNA_DEBUG("Enabled rat animations");
    }
    else
    {
        thread _stop_rat_animations();
        PRINT_FAUNA_DEBUG("Disabled rat animations");
    }
}

function _loop_rat_animations()
{
    level endon("end_game");
    level notify("_stop_rat_animations");
    level endon("_stop_rat_animations");

    while(true)
    {
        WAIT_SERVER_FRAME;

        rats_running = RandomIntRange(1, MAX_RATS_RUNNING + 1);
        rats = array::randomize(level.Fauna.Rats);
        PRINT_FAUNA_DEBUG("Rats are at the number of: " + rats.size);
        foreach (rat in rats)
        {
            thread [[rat]]->PlayAnimation();
            
            rats_running--;
            if (rats_running <= 0)
            {
                break;
            }
            wait RandomFloatRange(MIN_DELAY_BETWEEN_RATS_ANIMATIONS, MAX_DELAY_BETWEEN_RATS_ANIMATIONS);
        }

        wait RandomFloatRange(MIN_DELAY_BETWEEN_RATS_ANIMATION_LOOP, MAX_DELAY_BETWEEN_RATS_ANIMATION_LOOP);
    }
}

function private _stop_rat_animations()
{
    level notify("_stop_rat_animations");

    foreach (rat in level.Fauna.Rats)
    {
        thread [[rat]]->StopAnimation();
    }
}

/* endregion */
/* region Raven logic */

function toggle_ravens(b_enabled)
{
    if (IS_TRUE(b_enabled))
    {
        thread _loop_raven_animations();
        PRINT_FAUNA_DEBUG("Enabled raven animations");
    }
    else
    {
        thread _stop_raven_animations();
        PRINT_FAUNA_DEBUG("Disabled raven animations");
    }
}

function _loop_raven_animations()
{
    level endon("end_game");
    level notify("_stop_raven_animations");
    level endon("_stop_raven_animations");

    while(true)
    {
        ravens_flying = RandomIntRange(1, MAX_RAVENS_FLYING + 1);
        ravens = array::randomize(level.Fauna.Ravens);
        PRINT_FAUNA_DEBUG("Ravens are at the number of: " + ravens.size);
        foreach (raven in ravens)
        {
            thread [[raven]]->PlayAnimation();
            
            ravens_flying--;
            if (ravens_flying <= 0)
            {
                break;
            }
            wait RandomFloatRange(MIN_DELAY_BETWEEN_RAVENS_ANIMATIONS, MAX_DELAY_BETWEEN_RAVENS_ANIMATIONS);
        }

        wait RandomFloatRange(MIN_DELAY_BETWEEN_RAVENS_ANIMATION_LOOP, MAX_DELAY_BETWEEN_RAVENS_ANIMATION_LOOP);
    }
}

function private _stop_raven_animations()
{
    level notify("_stop_raven_animations");

    foreach (raven in level.Fauna.Ravens)
    {
        thread [[raven]]->StopAnimation();
    }
}

/* endregion */

function private modvar_debug_fauna()
{
    ModVar("fauna", "");

    while(true)
    {
        WAIT_SERVER_FRAME;

        dvar_value = GetDvarString("fauna", "");

        if(!isdefined(dvar_value) || dvar_value == "")
        {
            continue;
        }
        ModVar("fauna", "");

        switch(Int(dvar_value))
        {
            case 0:
                toggle_rats(true);
                break;
            case 1:
                toggle_rats(false);
                break;
            case 2:
                toggle_ravens(true);
                break;
            case 3:
                toggle_ravens(false);
                break;
        }
    }
}
