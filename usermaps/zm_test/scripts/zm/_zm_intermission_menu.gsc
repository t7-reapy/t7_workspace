#using scripts\codescripts\struct;

#using scripts\shared\callbacks_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#precache("menu", "Intermission_Main");

// Restart/leave buttons overlaid on the gameover_camera travels. The buttons live
// in Intermission_Main.lua; this only decides when to show them.
REGISTER_SYSTEM_EX("zm_intermission_menu", &__init__, &__main__, undefined)

function __init__()
{
    callback::on_connect(&on_player_connect);
}

function __main__()
{
    // Our own gate (NOT stock level.disable_intermission, which pauses the whole
    // end-game sequence). Cleared on the room-of-thanks win to skip the buttons.
    level.show_intermission_menu = true;
}

function on_player_connect()
{
    self thread intermission_menu_handler();
}

function intermission_menu_handler()
{
    self endon("disconnect");

    level waittill("end_game");

    if (!IS_TRUE(level.show_intermission_menu))
    {
        return;
    }

    // Let the stock intermission play (music/score/camera), then overlay the
    // buttons once it hands off to the camera travels.
    level waittill("intermission");
    wait 1;

    self OpenMenu("Intermission_Main");
}
