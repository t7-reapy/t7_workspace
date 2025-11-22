#using scripts\zm\_zm_audio; 
#using scripts\zm\_zm_score; 
#using scripts\zm\_zm_utility; 
#using scripts\shared\exploder_shared; 
#using scripts\shared\flag_shared; 
#using scripts\shared\callbacks_shared; 
#using scripts\shared\util_shared; 
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\hellround\zm_hellround_shared;
#insert scripts\zm\hellround\zm_hellround_shared.gsh;
#insert scripts\zm\hellround\zm_hellround_meteor.gsh;
#namespace zm_hellround_meteor;

#precache("triggerstring", HRMETEOR_TRIGGER_LOCALIZED, HRMETEOR_TRIGGER_PRICE_STR);

REGISTER_SYSTEM_EX("zm_hellround_meteor", &init, &main, undefined)

class HellroundMeteor
{
    var meteor_has_fallen;

    var brush_show;
    var brush_hide;

    var models_show;
    var models_hide;

    var fx_exploder;
    var crumble_exploder;
    var falldown_exploder;

    var meteor_trigger;
    var meteor_trigger_callbacks;
}

function private init()
{
    clientfield::register("world", HRMETEOR_CLIENT_FIELD, VERSION_SHIP, 2, "int");

    level.hellround_meteor = new HellroundMeteor();
    level.hellround_meteor.meteor_has_fallen = false;
    level.hellround_meteor.brush_show = GetEntArray("hellround_meteor_brush_show", "targetname");
    level.hellround_meteor.brush_hide = GetEntArray("hellround_meteor_brush_hide", "targetname");
    level.hellround_meteor.models_show = GetEntArray("hellround_meteor_model_show", "targetname");
    level.hellround_meteor.models_hide = GetEntArray("hellround_meteor_model_hide", "targetname");
    level.hellround_meteor.fx_exploder = HRMETEOR_FX_EXPLODER_NAME;
    level.hellround_meteor.crumble_exploder = HRMETEOR_CRUMBLE_FX_EXPLODER_NAME;
    level.hellround_meteor.falldown_exploder = HRMETEOR_FALLDOWN_FX_EXPLODER_NAME;
    level.hellround_meteor.meteor_trigger = GetEnt("meteor_trigger", "targetname");
    level.hellround_meteor.meteor_trigger setup_meteor_trigger();
    level.hellround_meteor.meteor_trigger_callbacks = [];

    MAKE_ARRAY(level.hellround_meteor.brush_show);
    MAKE_ARRAY(level.hellround_meteor.brush_hide);
    MAKE_ARRAY(level.hellround_meteor.models_show);
    MAKE_ARRAY(level.hellround_meteor.models_hide);
    
    callback::on_connect(&sync_hellround_meteor);
}

function private sync_hellround_meteor() // self == player
{
    if (level.hellround_meteor.meteor_has_fallen)
    {
        self hellround_meteor_logic(true);
    }
}

function private main()
{
    zm_hellround_shared::wait_for_map_load();
    thread show_meteor_fxs(true, false);
    thread show_meteor_brushs(false);
    thread show_meteor_models(false);

    if (DEBUG_HELLROUNDS)
    {
        thread modvar_debug_hellround_meteor();
    }
}

function hellround_meteor_logic(skip_meteor_animation = false) // self == player or undefined
{
    skip_meteor_animation = IS_TRUE(skip_meteor_animation);
    PRINT_HR_DEBUG("hellround_meteor_logic: skip_meteor_animation " + skip_meteor_animation);
    if (level.hellround_meteor.meteor_has_fallen && !skip_meteor_animation)
    {
        PRINT_HR_DEBUG("meteor already fell. skipping");
        return;
    }
    level.hellround_meteor.meteor_has_fallen = true;
    level clientfield::set(HRMETEOR_CLIENT_FIELD, (skip_meteor_animation ? HRMETEOR_CLIENT_FIELD_FALLDOWN_SKIP : HRMETEOR_CLIENT_FIELD_FALLDOWN));

    if (!skip_meteor_animation)
    {
        wait HRMETEOR_TIME_BEFORE_METEORS;
    }
    thread show_meteor_fxs(skip_meteor_animation);
    if (!skip_meteor_animation)
    {
        timings = HRMETEOR_EXPLODER_IMPACT_TIMINGS;
        foreach(index, timing in timings)
        {
            thread play_meteor_earthquake(HRMETEOR_IMPACT_EARTHQUAKE_INTENSITY, timing, HRMETEOR_IMPACT_EARTHQUAKE_DURATION);

            if (index + 1 < timings.size)
            {
                less_intense_timing = timing + HRMETEOR_IMPACT_EARTHQUAKE_DURATION;
                thread play_meteor_earthquake(HRMETEOR_EARTHQUAKE_INTENSITY, less_intense_timing, timings[index + 1] - less_intense_timing);
            }
        }
        wait HRMETEOR_EXPLODER_TIME;
    }
    level.hellround_meteor.meteor_trigger notify("enable_meteor_trigger");
    thread show_meteor_brushs();
    thread show_meteor_models();
}

/* region brush */

function private show_meteor_brushs(b_show = true)
{
    if(b_show)
    {
        foreach(brush in level.hellround_meteor.brush_show)
        {
            brush Show();
            brush Solid();
        }

        foreach(brush in level.hellround_meteor.brush_hide)
        {
            brush Hide();
            brush NotSolid();
        }
    }
    else
    {
        foreach(brush in level.hellround_meteor.brush_show)
        {
            brush Hide();
            brush NotSolid();
        }

        foreach(brush in level.hellround_meteor.brush_hide)
        {
            brush Show();
            brush Solid();
        }
    }
}

/* endregion */
/* region models */

function private show_meteor_models(b_show = true)
{
    if (b_show)
    {
        foreach(model in level.hellround_meteor.models_show)
        {
            model Show();
        }

        foreach(model in level.hellround_meteor.models_hide)
        {
            model Hide();
        }
    }
    else
    {
        foreach(model in level.hellround_meteor.models_show)
        {
            model Hide();
        }

        foreach(model in level.hellround_meteor.models_hide)
        {
            model Show();
        }
    }
}

/* endregion */
/* region fxs */

function private show_meteor_fxs(skip_meteor_animation, b_enable = true)
{
    if (!skip_meteor_animation)
    {
        exploder::exploder(level.hellround_meteor.falldown_exploder);
        wait HRMETEOR_EXPLODER_TIME;
    }

    if (b_enable)
    {
        exploder::exploder(level.hellround_meteor.fx_exploder);
    }
    else
    {
        exploder::kill_exploder(level.hellround_meteor.fx_exploder);
    }
}

/* endregion */
/* region earthquake */

function play_meteor_earthquake(intensity, delay, duration)
{
    if (delay > 0.0)
    {
        wait delay;
    }
    Earthquake(intensity, duration, (0, 0, 0), 50000);
    exploder::exploder(level.hellround_meteor.crumble_exploder);
}

/* endregion */
/* region trigger */

function private setup_meteor_trigger() // self == trigger
{
    self SetHintString(&HRMETEOR_TRIGGER_LOCALIZED, HRMETEOR_TRIGGER_PRICE_STR);
    self TriggerEnable(false);

    self waittill("enable_meteor_trigger");
    self TriggerEnable(true);

    while (true)
    {
        self waittill("trigger", player);
        if (player try_to_buy_meteor(self))
        {
            self TriggerEnable(false);
            self SetHintString("");
            break;
        }
    }

    level clientfield::set(HRMETEOR_CLIENT_FIELD, HRMETEOR_CLIENT_FIELD_TRIGGER);
    thread meteor_trigger_callbacks();
    PRINT_HR_DEBUG("meteor event is finished");
}

function private try_to_buy_meteor(meteor) // self == player
{
    player = self;
    if (!zm_utility::is_player_valid(player) || player zm_utility::in_revive_trigger())
    {
        return false;
    }

    cost = Int(HRMETEOR_TRIGGER_PRICE_STR);
    if (player zm_score::can_player_purchase(cost))
    {
        PRINT_HR_DEBUG("meteor was bought");
        player zm_score::minus_to_player_score(cost);
        return true;
    }
    else
    {
        PRINT_HR_DEBUG("meteor buying denied !");
        zm_utility::play_sound_at_pos("no_purchase", meteor.origin);
        player zm_audio::create_and_play_dialog("general", "outofmoney");
    }

    return false;
}

/* endregion */
/* region callback */

function add_meteor_trigger_callback(func_ptr)
{
    if (IsFunctionPtr(func_ptr))
    {
        ARRAY_ADD(level.hellround_meteor.meteor_trigger_callbacks, func_ptr);
    }
}

function private meteor_trigger_callbacks()
{
    foreach (callback in level.hellround_meteor.meteor_trigger_callbacks)
    {
        thread [[ callback ]]();
    }
}

/* endregion */
/* region debug */

function private modvar_debug_hellround_meteor()
{
    ModVar("hrmeteor", "");

    while(true)
    {
        WAIT_SERVER_FRAME;

        dvar_value = GetDvarString("hrmeteor", "");

        if(!isdefined(dvar_value) || dvar_value == "")
        {
            continue;
        }
        ModVar("hrmeteor", "");

        switch(Int(dvar_value))
        {
            case 1:
                hellround_meteor_logic(false);
                break;
            case 2: // skip animation
                hellround_meteor_logic(true);
                break;
            default:
                break;
        }
    }
}

/* endregion */