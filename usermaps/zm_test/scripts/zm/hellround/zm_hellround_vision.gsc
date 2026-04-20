#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_magicbox;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_unitrigger;
#using scripts\zm\_zm_utility;
#using scripts\shared\visionset_mgr_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\hellround\zm_hellround_shared.gsh;
#insert scripts\zm\hellround\zm_hellround_vision.gsh;

#namespace zm_hellround_vision;

REGISTER_SYSTEM_EX("zm_hellround_vision", &init, &main, undefined)

function init()
{
    visionset_mgr::register_info("visionset", HRVIS_VISIONSET, VERSION_SHIP, 1, 31, 1, &visionset_mgr::ramp_in_out_thread_per_player, 0);
}

function main()
{
    if (DEBUG_HELLROUNDS)
    {
        thread _modvar_debug_hellround_vision();
    }
}

function toggle_hellround_vision(b_enabled)
{
    if (IS_TRUE(b_enabled))
    {
        _activate_hellround_vision();
    }
    else
    {
        _deactivate_hellround_vision();
    }
}

function private _activate_hellround_vision()
{
    foreach (player in GetPlayers())
    {
        visionset_mgr::activate("visionset", HRVIS_VISIONSET, player, 0, &_wait_forever);
    }
}

function private _deactivate_hellround_vision()
{
    foreach (player in GetPlayers())
    {
        visionset_mgr::deactivate("visionset", HRVIS_VISIONSET, player);
        player notify("hellround_vision");
    }
}

function private _wait_forever() // self == player
{
    level endon("end_game");
    self endon("hellround_vision");

    while(true)
    {
        wait 5;
    }
}

/* region debug */

function private _modvar_debug_hellround_vision()
{
    ModVar("hrvision", "");

    while(true)
    {
        WAIT_SERVER_FRAME;

        dvar_value = GetDvarString("hrvision", "");

        if(!isdefined(dvar_value) || dvar_value == "")
        {
            continue;
        }
        ModVar("hrvision", "");
        
        switch(Int(dvar_value))
        {
            case 0:
                _deactivate_hellround_vision();
                break;
            case 1:
                _activate_hellround_vision();
                break;
            default:
                PRINT_HR_DEBUG("Unknown command");
                break;
        }
    }
}

/* endregion */