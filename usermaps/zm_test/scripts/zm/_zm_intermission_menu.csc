#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

// Client-side half: just makes the LUI menu available to OpenMenu.
REGISTER_SYSTEM("zm_intermission_menu", &__init__, undefined)

function __init__()
{
    LuiLoad("ui.uieditor.menus.Intermission.Intermission_Main");
}
