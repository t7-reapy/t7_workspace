#using scripts\shared\postfx_shared; 
#using scripts\shared\water_surface; 
// -------------------------------------------------------------------------------
// On-Screen Raindrops for Black Ops III - Harry's Downfall Edition
// Copyright (c) 2022 Philip/Scobalula
// -------------------------------------------------------------------------------
// Licensed under the "Do whatever you want thx hun bun" license.
// -------------------------------------------------------------------------------
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\filter_shared;
#using scripts\shared\util_shared;
#using scripts\shared\trigger_shared;
#using scripts\shared\visionset_mgr_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\weather\zm_weather_shared.gsh;
#insert scripts\zm\weather\zm_weather_rain.gsh;
#insert scripts\zm\weather\rain\zm_weather_rain_drops_postfx.gsh;

#namespace zm_weather_rain_drops_postfx;

// Init
function init()
{
    // Clientfields
    clientfield::register("toplayer", ZM_POSTFX_RAIN_DROPS_CF_NAME, VERSION_SHIP, 1, "int", &rain_drops_toggle, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);
    // Callbacks
    callback::on_localclient_connect(&on_connect);
}

function run()
{
    // filter::init_filter_raindrops(self);
    // filter::init_filter_sgen_sprite_rain(self);

    // local_client_number = self GetLocalClientNumber();
    // self waterfallOverlay(local_client_number);
}

// Runs on connect logic.
function on_connect(local_client_number)
{
    filter::init_filter_raindrops(self);
    filter::init_filter_sgen_sprite_rain(self);

    self waterfallOverlay(local_client_number);
}

// Runs the clientfield logic.
function rain_drops_toggle(local_client_number, old_val, new_val, b_new_ent, b_initial_snap, s_field_name, b_was_time_jump)
{
    // TODO: I reversed these
    if(new_val == 1)
    {
        self thread rain_disable(local_client_number);
    }
    else
    {
        self thread rain_enable(local_client_number);
    }
}

// Disables the on-screen rain drops.
function rain_disable(local_client_number)
{
    self notify("stop_raining");

    self endon("entityshutdown");
    self endon("raining");
    self endon("stop_raining");

    if(IsFunctionPtr(level.zm_rain_drops_on_rain_disabled_callback))
    {
        self [[level.zm_rain_drops_on_rain_disabled_callback]](local_client_number);
    }

    if(isdefined(self.rain_opacity))
    {
        while(self.rain_opacity > 0)
        {
            self.rain_opacity -= 0.01;
            filter::set_filter_sprite_rain_opacity(self, ZM_POSTFX_RAIN_DROPS_FILTER_ID, self.rain_opacity);
            filter::set_filter_sprite_rain_elapsed(self, ZM_POSTFX_RAIN_DROPS_FILTER_ID, self GetClientTime());
            WAIT_CLIENT_FRAME;
        }
    }

    self.rain_opacity = 0;
    filter::disable_filter_sprite_rain(self, ZM_POSTFX_RAIN_DROPS_FILTER_ID);
}

// Enables the on-screen rain drops.
function rain_enable(local_client_number)
{
    self notify("raining");
    self endon("entityshutdown");
    self endon("raining");
    self endon("stop_raining");

    if(IsFunctionPtr(level.zm_rain_drops_on_rain_enabled_callback))
    {
        self [[level.zm_rain_drops_on_rain_enabled_callback]](local_client_number);
    }
    
    if(!isdefined(self.rain_opacity))
    {
        self.rain_opacity = 0.2;
    }

    if(self.rain_opacity == 0)
    {
        filter::set_filter_sprite_rain_seed_offset(self, ZM_POSTFX_RAIN_DROPS_FILTER_ID, 0.2);
    }

    //filter::enable_filter_sgen_sprite_rain(self, ZM_POSTFX_RAIN_DROPS_FILTER_ID);
    filter::enable_filter_sprite_rain(self, ZM_POSTFX_RAIN_DROPS_FILTER_ID);

    while(1)
    {
        self.rain_opacity += 0.001;

        if(self.rain_opacity > 1)
            self.rain_opacity = 0.5;

        filter::set_filter_sprite_rain_opacity(self, ZM_POSTFX_RAIN_DROPS_FILTER_ID, self.rain_opacity);
        filter::set_filter_sprite_rain_elapsed(self, ZM_POSTFX_RAIN_DROPS_FILTER_ID, self GetClientTime());
        WAIT_CLIENT_FRAME;
    }
}

/////////////////////////////// -- waterfall -- 

function waterfallOverlay( localClientNum )
{
    triggers = GetEntArray( localClientNum, "waterfall", "targetname" );
    foreach( trigger in triggers )
    {
        trigger thread setupWaterfall( localClientNum );
    }
}

function setupWaterfall( localClientNum )
{
    level notify( "setupWaterfall_waterfall_csc" + localclientnum  );
    level endon ( "setupWaterfall_waterfall_csc" + localclientnum  );

    trigger = self;
    for(;;)
    {
        trigger waittill( "trigger", trigPlayer );
        
        if ( !trigPlayer islocalplayer() )
        {
            continue;
        }
        
        localclientnum = trigPlayer getlocalclientnumber();
        if ( isdefined( localclientnum ) )
        {
            localplayer = getlocalplayer( localclientnum );
        }
        else
        {
            localplayer = trigPlayer;
        }

        trigger thread trigger::function_thread( localplayer, &trig_enter_waterfall, &trig_leave_waterfall );
    }
}

function trig_enter_waterfall( localplayer )
{
    trigger = self;
    localclientnum = localplayer.localclientnum;
    localplayer thread postfx::playPostfxBundle( "pstfx_waterfall" );

    playsound(0, "amb_waterfall_hit", (0,0,0));
            
    while ( trigger istouching( localplayer ) )
    {
        localplayer PlayRumbleOnEntity( localClientNum, "waterfall_rumble" );
        wait( 0.1 );
    }
}

function trig_leave_waterfall( localplayer )
{
    WEATHER_PRINT_DEBUG("WATERFALL TRIGGER LEAVE");
    trigger = self;
    localClientNum = localplayer.localClientNum;
    localplayer postfx::StopPostfxBundle();
    if ( IsUnderwater( localClientNum ) == false )
    {
        localplayer thread water_surface::startWaterSheeting();
    }
}
