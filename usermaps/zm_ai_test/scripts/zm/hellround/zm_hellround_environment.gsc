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

function private init()
{
    clientfield::register("world", HRENV_TOGGLE_CLIENT_FIELD, VERSION_SHIP, 1, "int");

    level.clips_show = GetEntArray("hellround_clip_show", "targetname");
    level.clips_hide = GetEntArray("hellround_clip_hide", "targetname");
    
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

    self update_lightstate(b_enable);

    show_hellround_clips(IS_TRUE(b_enable));

    level clientfield::set(HRENV_TOGGLE_CLIENT_FIELD, b_enable);
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

//TODO: if brushmodel clip don't work, try collmaps.
function private show_hellround_clips(b_show)
{
    if(b_show)
    {
        foreach(clip in level.clips_show)
        {
            clip Show();
        }

        foreach(clip in level.clips_hide)
        {
            clip Hide();
        }
    }
    else
    {
        foreach(clip in level.clips_show)
        {
            clip Hide();
        }

        foreach(clip in level.clips_hide)
        {
            clip Show();
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
