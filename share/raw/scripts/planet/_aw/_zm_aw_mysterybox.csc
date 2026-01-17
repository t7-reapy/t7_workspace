#using scripts\codescripts\struct;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\shared\duplicaterender.gsh;

#using scripts\shared\visionset_mgr_shared;
#using scripts\shared\duplicaterender_mgr;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\shared\system_shared;
#using scripts\shared\clientfield_shared;

#namespace aw_mbox;

REGISTER_SYSTEM_EX("aw_mbox", &__init__, &__main__, undefined)

#define HOLO_DUPRENDER_MTL                        "mc/dr_fx_holo"

//*****************************************************************************
// MAIN
//*****************************************************************************

function __init__(){
	clientfield::register( "scriptmover", "exo_magicbox_dr_holo", VERSION_SHIP, 1, "int", &handle_holo_dr, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	duplicate_render::set_dr_filter_framebuffer_duplicate("aw_holo_box_overlay", 30, "aw_holo_box_overlay_enable", undefined, DR_TYPE_FRAMEBUFFER_DUPLICATE, HOLO_DUPRENDER_MTL, DR_CULL_NEVER);
}

function handle_holo_dr(localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump){
	if(newVal){
		self duplicate_render::set_dr_flag("aw_holo_box_overlay_enable", 1);
		self duplicate_render::update_dr_filters(localClientNum);
	}
	else{
		self duplicate_render::set_dr_flag("aw_holo_box_overlay_enable", 0);
		self duplicate_render::update_dr_filters(localClientNum);
	}
}

function __main__(){}