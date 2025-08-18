#using scripts\shared\flag_shared; 
#using scripts\shared\callbacks_shared; 
#using scripts\shared\util_shared; 
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\hellround\zm_hellround_shared;
#insert scripts\zm\hellround\zm_hellround_shared.gsh;
#insert scripts\zm\hellround\zm_hellround_environment.gsh;
#namespace zm_hellround_environment;

REGISTER_SYSTEM_EX("zm_hellround_environment", &init, &main, undefined)

class HellroundEnvironment
{
    var clips_show;
    var clips_hide;

    var models_show;
    var models_hide;
}

function private init()
{
    clientfield::register("world", HRENV_TOGGLE_CLIENT_FIELD, VERSION_SHIP, 1, "int");

    level.hellround_environment = new HellroundEnvironment();
    level.hellround_environment.clips_show = GetEntArray("hellround_clip_show", "targetname");
    level.hellround_environment.clips_hide = GetEntArray("hellround_clip_hide", "targetname");
    level.hellround_environment.models_show = GetEntArray("hellround_model_show", "targetname");
    level.hellround_environment.models_hide = GetEntArray("hellround_model_hide", "targetname");
    
    callback::on_connect(&sync_hellround_environment);
}

function private sync_hellround_environment() // self == player
{
    self toggle_hellround_environment(zm_hellround_shared::is_hellround_running());
}

function private main()
{
	zm_hellround_shared::wait_for_map_load();

    // At first, force lightstate switch to happen once (cleans fx on state outside of HRENV_LIGHTSTATE_INDEX_NORMAL).
    update_lightstate(true);
    WAIT_SERVER_FRAME;
    update_lightstate(false);

    if (DEBUG_HELLROUNDS)
    {
        thread modvar_debug_hellround_environment();
    }
}

function toggle_hellround_environment(b_enable) // self == player or undefined
{
    PRINT_HR_DEBUG("toggle_hellround_environment: " + b_enable);

    level clientfield::set(HRENV_TOGGLE_CLIENT_FIELD, b_enable);

    show_hellround_models(IS_TRUE(b_enable))
    show_hellround_clips(IS_TRUE(b_enable));

    if (!b_enable)
    {
        fog_switch_amount = 2;
        // In case the hellround environment is disabled, we want the 
        // lightstate switch happening after fog transition happens.
        wait HRENV_FOG_TRANSITION_TIME - fog_switch_amount * HRENV_FOG_RADIANT_TIME;
    }
    self update_lightstate(b_enable);
}

function private update_lightstate(b_enable) // self == player or undefined
{
    lightstate = (IS_TRUE(b_enable) ? HRENV_LIGHTSTATE_INDEX_BLOODY : HRENV_LIGHTSTATE_INDEX_NORMAL);
    if (isdefined(self) && IsPlayer(self))
    {
        self util::set_lighting_state(lightstate);
    }
    else
    {
        level util::set_lighting_state(lightstate);
    }
}

// #region brush clip

function private show_hellround_clips(b_show)
{
    if(b_show)
    {
        foreach(clip in level.hellround_environment.clips_show)
        {
            clip Show();
        }

        foreach(clip in level.hellround_environment.clips_hide)
        {
            clip Hide();
        }
    }
    else
    {
        foreach(clip in level.hellround_environment.clips_show)
        {
            clip Hide();
        }

        foreach(clip in level.hellround_environment.clips_hide)
        {
            clip Show();
        }
    }
}

// #endregion
// #region models

function private show_hellround_models(b_show)
{
    if (b_show)
    {
        foreach(model in level.hellround_environment.models_show)
        {
            model Show();
            model Solid();
        }

        foreach(model in level.hellround_environment.models_hide)
        {
            model Hide();
            model NotSolid();
        }
    }
    else
    {
        foreach(model in level.hellround_environment.models_show)
        {
            model Hide();
            model NotSolid();
        }

        foreach(model in level.hellround_environment.models_hide)
        {
            model Show();
            model Solid();
        }
    }
}

// #endregion
// #region debug

function private modvar_debug_hellround_environment()
{
    ModVar("hrenv", "");

    while(true)
    {
        WAIT_SERVER_FRAME;

        dvar_value = GetDvarString("hrenv", "");

        if(!isdefined(dvar_value) || dvar_value == "")
        {
            continue;
        }
        ModVar("hrenv", "");

        switch(Int(dvar_value))
        {
            case 1:
                toggle_hellround_environment(true);
                break;
            default:
                toggle_hellround_environment(false);
                break;
        }
    }
}

// #endregion
