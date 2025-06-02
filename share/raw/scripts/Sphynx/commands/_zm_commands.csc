#using scripts\codescripts\struct;
#using scripts\shared\audio_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;
#using scripts\shared\system_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\shared\duplicaterender.gsh;
#using scripts\shared\visionset_mgr_shared;

#using scripts\shared\duplicaterender_mgr;

#namespace zm_commands;

#define DEBUG_KEYLINE_MATERIAL                 "mc/hud_outline_model_green"
#define DEBUG_ZOMBIE_KEYLINE_MATERIAL                 "mc/hud_outline_model_z_red"

function autoexec init()
{
    if(ToLower( GetDvarString( "mapname" ) ) != "zm_castle") {
        //Debug Outlines
        clientfield::register( "scriptmover",     "debug_enable_keyline",                 VERSION_SHIP,     1, "int", &debug_enable_keyline,                 !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
        //duplicate_render::set_dr_filter_offscreen( "debug_enable_keyline", 30, "debug_enable_keyline_active", "debug_enable_keyline_disabled", DR_TYPE_OFFSCREEN, DEBUG_KEYLINE_MATERIAL, 0    );
        duplicate_render::set_dr_filter_framebuffer_duplicate( "debug_enable_keyline", 10, "debug_enable_keyline_active", undefined, DR_TYPE_FRAMEBUFFER_DUPLICATE, DEBUG_KEYLINE_MATERIAL, DR_CULL_NEVER );

        //Debug Zombie Outlines
        clientfield::register( "actor",     "debug_zombie_enable_keyline",                 VERSION_SHIP,     1, "int", &debug_zombie_enable_keyline,                 !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
        duplicate_render::set_dr_filter_offscreen( "debug_zombie_enable_keyline", 30, "debug_zombie_enable_keyline_active", "debug_zombie_enable_keyline_disabled", DR_TYPE_OFFSCREEN, DEBUG_ZOMBIE_KEYLINE_MATERIAL, DR_CULL_NEVER );
    }

	util::register_system( "subtitleMessage", &subtitlesMessage );

    callback::on_localplayer_spawned(&onSpawned);
}

function onSpawned(localClientNum)
{
    self thread OED_SitRepScan_OnSpawned(localClientNum);
}

function private OED_SitRepScan_OnSpawned(localClientNum)
{
    self endon("entityshutdown");
    self endon("disconnect");
    self endon("death");
    self endon("bled_out");

    self notify("OED_SitRepScan_OnSpawned");
    self endon("OED_SitRepScan_OnSpawned");

    while(isdefined(self) && IsAlive(self))
    {
        self OED_SitRepScan_Enable( 3 );
        self OED_SitRepScan_SetOutline( 1 );
        self OED_SitRepScan_SetSolid( 0 );
        self OED_SitRepScan_SetLineWidth( 1 );
        self OED_SitRepScan_SetRadius( 1400 );
        self OED_SitRepScan_SetFalloff( 1 );
        self OED_SitRepScan_SetDesat( 0 );

        wait(0.05);
    }
}

function subtitlesMessage( n_local_client_num, message ) 
{
	SubtitlePrint(n_local_client_num, 100, message);
}

function debug_enable_keyline( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
    if ( IS_TRUE( n_new_val ) )
    {
        self duplicate_render::set_dr_flag( "debug_enable_keyline_active", 1 );
        self duplicate_render::update_dr_filters( n_local_client_num );
    }
    else
    {
        self duplicate_render::set_dr_flag( "debug_enable_keyline_active", 0 );
        self duplicate_render::update_dr_filters( n_local_client_num );
    }
}

function debug_zombie_enable_keyline( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
    if ( IS_TRUE( n_new_val ) )
    {
        self duplicate_render::set_dr_flag( "debug_zombie_enable_keyline_active", 1 );
        self duplicate_render::update_dr_filters( n_local_client_num );
    }
    else
    {
        self duplicate_render::set_dr_flag( "debug_zombie_enable_keyline_active", 0 );
        self duplicate_render::update_dr_filters( n_local_client_num );
    }
}