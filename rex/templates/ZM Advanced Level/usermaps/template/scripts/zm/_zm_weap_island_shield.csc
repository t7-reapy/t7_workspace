#using scripts\codescripts\struct;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_weapons;

#namespace island_shield;

function autoexec __init__sytem__()
{
	system::register("zm_weap_island_shield", &__init__, undefined, undefined);
}

function __init__()
{
}

