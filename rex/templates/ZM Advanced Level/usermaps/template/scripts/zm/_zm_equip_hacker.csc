#using scripts\shared\clientfield_shared;
#using scripts\shared\callbacks_shared; 
#using scripts\shared\filter_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\zm\_zm_equipment;

#namespace zm_equip_hacker;

function autoexec __init__sytem__()
{
	system::register("zm_equip_hacker", &__init__, undefined, undefined);
}

function __init__()
{
	clientfield::register("clientuimodel", "hudItems.showDpadDown_HackTool", 21000, 1, "int", undefined, 0, 0);
}