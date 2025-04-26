#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_perk_utility;
#using scripts\shared\duplicaterender_mgr;
#using scripts\shared\postfx_shared;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\shared\duplicaterender.gsh;
#insert scripts\zm\_zm_perk_whoswho.gsh;

#precache( "client_fx", WHOSWHO_MACHINE_LIGHT_FX );
#precache( "client_fx", WHOSWHO_VULTUREAID_WAYPOINT );

#namespace zm_perk_whoswho;

REGISTER_SYSTEM_EX( "zm_perk_whoswho", &__init__, &__main__, undefined )

#define WHOSWHOMTL "mc/whoswho_body_filter"

//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------
function __init__()
{
	if ( IS_TRUE( WHOSWHO_LEVEL_USE_PERK ) )
		enable_whoswho_perk_for_level();
	
}

function __main__()
{
	if ( IS_TRUE( WHOSWHO_LEVEL_USE_PERK ) )
		whoswho_main();
	
}

function enable_whoswho_perk_for_level()
{
	zm_perks::register_perk_clientfields( WHOSWHO_PERK, &whoswho_client_field_func, &whoswho_code_callback_func );
	zm_perks::register_perk_effects( WHOSWHO_PERK, WHOSWHO_PERK );
	zm_perks::register_perk_init_thread( WHOSWHO_PERK, &whoswho_init );
	zm_perk_utility::vulture_aid_register_perk_fx( WHOSWHO_PERK, WHOSWHO_MACHINE_DISABLED_MODEL, WHOSWHO_MACHINE_ACTIVE_MODEL, WHOSWHO_VULTUREAID_WAYPOINT );
}

function whoswho_init()
{
	level._effect[ WHOSWHO_PERK ]		= WHOSWHO_MACHINE_LIGHT_FX;
}

function whoswho_client_field_func()
{ 
	clientfield::register( "clientuimodel", WHOSWHO_CLIENTFIELD, VERSION_SHIP, 2, "int", undefined, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "scriptmover", "whoswho_register_body", VERSION_SHIP, getMinBitCountForNum( 4 ), "int", &whoswho_register_body, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "toplayer", WHOSWHO_SCRIPT_STRING, VERSION_SHIP, 1, "int", &whos_who_active, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
}

function whoswho_code_callback_func() {}

//-----------------------------------------------------------------------------------
// FUNCTIONALITY
//-----------------------------------------------------------------------------------
function whoswho_main()
{
	level.whos_who_vision = WHOSWHO_VISION;
	if ( IS_TRUE( WHOSWHO_USE_ALTERNATE_VISIONSET ) )
		level.whos_who_vision =  WHOSWHO_VISION_ALTERNATE;
	
	visionset_mgr::register_visionset_info( level.whos_who_vision, 			VERSION_SHIP, WHOSWHO_VISIONSET_LERP_COUNT, undefined, level.whos_who_vision );
	
	duplicate_render::set_dr_filter_framebuffer_duplicate( 	"whoswho", 10, "whoswho_on", undefined, DR_TYPE_FRAMEBUFFER_DUPLICATE, WHOSWHOMTL, DR_CULL_NEVER );
}

function whoswho_register_body( n_local_client, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field, b_was_time_jump )
{
	if ( n_new_val == getLocalPlayers()[ n_local_client ] getEntityNumber() + 1 )
		self duplicate_render::set_dr_flag( "whoswho_on", 1 );
	
	self duplicate_render::set_dr_flag( "keyline_active", 1 );
	self duplicate_render::set_dr_flag( "keyline_ls", 1 );
	self duplicate_render::update_dr_filters( n_local_client );
}

function whos_who_active( n_local_client, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field, b_was_time_jump )
{
	if ( n_new_val == 1 )
	{
		enableSpeedBlur( n_local_client, .4, .5, 1.0, true, 300, 1, 1, 1 );
		self.soundEnt = spawn( n_local_client, self.origin, "script_origin" );
		self playSound( n_local_client, "zmb_perks_whoswho_begin" );
		self.soundEnt playLoopSound( "zmb_perks_whoswho_loop", 3 );
		self thread postfx::playPostfxBundle( "pstfx_zm_screen_warp" );
	}
	else if ( n_new_val == 0 )
	{
		disableSpeedBlur( n_local_client );
		self.soundEnt delete();
		self playSound( n_local_client, "zmb_perks_whoswho_deactivate" );
		self thread postfx::stopPlayingPostfxBundle();
	}
}