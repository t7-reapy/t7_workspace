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

#insert scripts\zm\zm_bloody_environment.gsh;
#namespace zm_bloody_environment;

REGISTER_SYSTEM_EX("zm_bloody_environment", &init, &main, undefined)

function init()
{
    level.blood_decals_show = BLOOD_DECALS_SHOW_INIT;
    clientfield::register("world", "decal_toggle_blood", VERSION_SHIP, 1, "int");    
}

function main()
{    
    level flag::wait_till("initial_blackscreen_passed");
    level clientfield::set("decal_toggle_blood", BLOOD_DECALS_SHOW_INIT);
}

function toggle_blood_decals() {
    level.blood_decals_show = !level.blood_decals_show;
    level clientfield::set("decal_toggle_blood", level.blood_decals_show);
}

function enable_red_atmosphere()
{
    IPrintLnBold("enable red atmo");
    level util::set_lighting_state(1);
    util::clientNotify("blood_fog_start");
}

function disable_red_atmosphere()
{
    IPrintLnBold("disable red atmo");
    level util::set_lighting_state(0);
    util::clientNotify("blood_fog_stop");
}