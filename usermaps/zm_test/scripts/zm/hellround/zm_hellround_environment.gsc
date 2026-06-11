#using scripts\shared\exploder_shared; 
#using scripts\shared\callbacks_shared; 
#using scripts\shared\util_shared; 
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\ai\zombie_utility;
#using scripts\codescripts\struct;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\hellround\zm_hellround_shared;
#insert scripts\zm\hellround\zm_hellround_shared.gsh;
#insert scripts\zm\hellround\zm_hellround_environment.gsh;

#namespace zm_hellround_environment;

#precache("fx", HRENV_TORNADO_BLOCKER_FX);

REGISTER_SYSTEM_EX("zm_hellround_environment", &init, &main, undefined)

class HellroundEnvironment
{
    var clips_show;
    var clips_hide;

    var models_show;
    var models_hide;

    var fx_exploder;

    var tornado_blockers;
}

function private init()
{
    level._effect["hellround_fire_tornado"] = HRENV_TORNADO_BLOCKER_FX;
    clientfield::register("world", HRENV_TOGGLE_CLIENT_FIELD, VERSION_SHIP, 1, "int");

    level.hellround_environment = new HellroundEnvironment();
    level.hellround_environment.clips_show = GetEntArray("hellround_clip_show", "targetname");
    level.hellround_environment.clips_hide = GetEntArray("hellround_clip_hide", "targetname");
    level.hellround_environment.models_show = GetEntArray("hellround_model_show", "targetname");
    level.hellround_environment.models_hide = GetEntArray("hellround_model_hide", "targetname");
    level.hellround_environment.fx_exploder = HRENV_FX_EXPLODER_NAME;
    level.hellround_environment.tornado_blockers = struct::get_array(HRENV_TORNADO_BLOCKER_NAME, "targetname");
    
    callback::on_connect(&sync_hellround_environment);
}

function private sync_hellround_environment() // self == player
{
    self toggle_hellround_environment(zm_hellround_shared::is_hellround_running());
}

function private main()
{
	zm_hellround_shared::wait_for_map_load();
    update_lightstate(false);
    show_hellround_fxs(false);

    if (DEBUG_HELLROUNDS)
    {
        thread modvar_debug_hellround_environment();
    }
}

function toggle_hellround_environment(b_enable) // self == player or undefined
{
    PRINT_HR_DEBUG("toggle_hellround_environment: " + b_enable);

    level clientfield::set(HRENV_TOGGLE_CLIENT_FIELD, b_enable);

    wait HRENV_FOG_RADIANT_TIME;
    self update_lightstate(b_enable);
    thread rotate_sky(IS_TRUE(b_enable));
    wait HRENV_FOG_TRANSITION_TIME - HRENV_FOG_RADIANT_TIME;

    thread show_hellround_fxs(IS_TRUE(b_enable));
    thread show_hellround_clips(IS_TRUE(b_enable));
    thread show_hellround_models(IS_TRUE(b_enable));
    thread show_hellround_blockers(IS_TRUE(b_enable));
}

function private update_lightstate(b_enable) // self == player or undefined
{
    lightstate = (IS_TRUE(b_enable) ? HRENV_LIGHTSTATE_INDEX_BLOODY : get_default_lightstate());
    if (isdefined(self) && IsPlayer(self))
    {
        self util::set_lighting_state(lightstate);
    }
    else
    {
        level util::set_lighting_state(lightstate);
    }
}

function private get_default_lightstate()
{
    return (isdefined(level.power_on_lightstate) ? level.power_on_lightstate : HRENV_LIGHTSTATE_INDEX_NORMAL);
}

/* region brush clip */

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

/* endregion */
/* region models */

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

/* endregion */
/* region blockers */

function private show_hellround_blockers(b_show)
{
    if (b_show)
    {
        foreach(blocker in level.hellround_environment.tornado_blockers)
        {
            blocker.damage_trigger = spawn("trigger_radius", blocker.origin, 1, 80, 70);
            blocker.damage_trigger thread _trigger_damage();

            blocker.fx = util::spawn_model("tag_origin", blocker.origin);
            playfxontag(level._effect["hellround_fire_tornado"], blocker.fx, "tag_origin");
            blocker.fx PlayLoopSound(HRENV_TORNADO_BLOCKER_SND);
            WAIT_SERVER_FRAME;
        }
    }
    else
    {
        foreach(blocker in level.hellround_environment.tornado_blockers)
        {
            if (isdefined(blocker.damage_trigger))
            {
                blocker.damage_trigger notify("end_fire_effect");
                WAIT_SERVER_FRAME;
                blocker.damage_trigger Delete();
                WAIT_SERVER_FRAME;
                blocker.damage_trigger = undefined;
            }

            if (isdefined(blocker.fx))
            {
                blocker.fx StopLoopSound();
                WAIT_SERVER_FRAME;
                blocker.fx Delete();
                WAIT_SERVER_FRAME;
                blocker.fx = undefined;
            }
        }
    }
}

function private _trigger_damage()
{
    level endon("end_game");
    self endon("end_fire_effect");
    while (true)
    {
        self waittill("trigger", who);
        if (IsPlayer(who) && zombie_utility::is_player_valid(who) && !IS_TRUE(who.hr_in_tornado))
        {
            who thread _burn_in_tornado(self); // self == the damage trigger
        }
    }
}

function private _burn_in_tornado(trig) // self == player
{
    self endon("disconnect");
    self.hr_in_tornado = true; // guard: one burn loop per player despite trigger re-fires

    while (isdefined(trig) && IsPlayer(self) && zombie_utility::is_player_valid(self) && self IsTouching(trig))
    {
        dmg = int(self.maxhealth * HRENV_TORNADO_BLOCKER_DAMAGE_FRACTION);
        self DoDamage(dmg, trig.origin, undefined, undefined, "none", HRENV_TORNADO_BLOCKER_DAMAGE_MOD);
        wait HRENV_TORNADO_BLOCKER_DAMAGE_INTERVAL;
    }

    self.hr_in_tornado = undefined;
}

/* endregion */
/* region debug */

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

/* endregion */
/* region fxs */

function private show_hellround_fxs(b_enable)
{
    if (b_enable)
    {
        exploder::exploder(level.hellround_environment.fx_exploder);
    }
    else
    {
        exploder::kill_exploder(level.hellround_environment.fx_exploder);
    }
}

/* endregion */
/* region skybox */

/@ Credits to Gmzorz and IceGrenade @/
function private rotate_sky(b_enable)
{
    if (!b_enable)
    {
        level notify("stop_rotate_sky");
        SetDvar("r_skyrotation", 0.0);
        return;
    }

    level notify("stop_rotate_sky");
    level endon("stop_rotate_sky");
    degree = GetDvarFloat("r_skyrotation", 0.0);
    while(true)
    {
        degree += HRENV_SKY_ROTATION_PER_FRAME;
        if (degree >= 359.9)
        {
            degree -= 359.9;
        }
        SetDvar("r_skyrotation", degree);
        WAIT_SERVER_FRAME;
    }
}

/* endregion */
