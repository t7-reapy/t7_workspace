#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\hellround\zm_hellround_shared.gsh;
#insert scripts\zm\hellround\zm_hellround_vision.gsh;

#namespace zm_hellround_vision;

REGISTER_SYSTEM("zm_hellround_vision", &init, undefined)

function init()
{
    visionset_mgr::register_visionset_info(HRVIS_VISIONSET, VERSION_SHIP, 1, undefined, HRVIS_VISIONSET);
}
