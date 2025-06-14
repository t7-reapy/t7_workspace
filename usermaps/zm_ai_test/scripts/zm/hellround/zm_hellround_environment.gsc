#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\compass;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;
#using scripts\shared\system_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_util;
#using scripts\zm\_zm_utility;
#insert scripts\zm\_zm_utility.gsh;

#insert scripts\zm\hellround\zm_hellround_environment.gsh;
#namespace zm_hellround_environment;

REGISTER_SYSTEM_EX("zm_hellround_environment", &init, &main, undefined)

function init()
{
    level.bloody_environment_show = BLOODY_ENV_SHOW_INIT;
    level.blood_models_show = BLOODY_ENV_SHOW_INIT;
    clientfield::register("world", BLOODY_TOGGLE_CLIENT_FIELD, VERSION_SHIP, 1, "int");    
}

function main()
{    
    level flag::wait_till("initial_blackscreen_passed");
    level clientfield::set(BLOODY_TOGGLE_CLIENT_FIELD, BLOODY_ENV_SHOW_INIT);
}

function toggle_bloody_environment() {
    level.bloody_environment_show = !level.bloody_environment_show;

    if (level.bloody_environment_show)
    {
        enable_red_atmosphere();
    }
    else
    {
        disable_red_atmosphere();
    }
    level clientfield::set(BLOODY_TOGGLE_CLIENT_FIELD, level.bloody_environment_show);
}

function enable_red_atmosphere()
{
    level util::set_lighting_state(1);
}

function disable_red_atmosphere()
{
    level util::set_lighting_state(0);
}