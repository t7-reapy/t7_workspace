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

function init()
{
    clientfield::register("toplayer", ZM_POSTFX_RAIN_DROPS_CF_NAME, VERSION_SHIP, 2, "int", &rain_drops_toggle, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT);
        
    callback::on_localclient_connect(&on_connect);
}

function on_connect(local_client_number)
{
    filter::init_filter_raindrops(self);
    filter::init_filter_sprite_rain(self);
    filter::init_filter_sgen_sprite_rain(self);
    init_filter_sgen_sprite_rain_sm(self);
}

function rain_drops_toggle(local_client_number, old_intensity, new_intensity, b_new_ent, b_initial_snap, s_field_name, b_was_time_jump)
{
    if(new_intensity != RAIN_INTENSITY_OFF)
    {
        self thread rain_enable(local_client_number, new_intensity);
    }
    else
    {
        self thread rain_disable(local_client_number);
    }
}

function rain_disable(local_client_number)
{
    self notify("stop_raining");

    self endon("entityshutdown");
    self endon("raining");
    self endon("stop_raining");

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

function rain_enable(local_client_number, intensity)
{
    self notify("raining");

    self endon("entityshutdown");
    self endon("raining");
    self endon("stop_raining");
    
    filter::disable_filter_sprite_rain(self, ZM_POSTFX_RAIN_DROPS_FILTER_ID);

    if(!isdefined(self.rain_opacity))
    {
        self.rain_opacity = 0.2;
    }

    if(self.rain_opacity == 0)
    {
        filter::set_filter_sprite_rain_seed_offset(self, ZM_POSTFX_RAIN_DROPS_FILTER_ID, 0.2);
    }

    switch (intensity)
    {
        case RAIN_INTENSITY_LOW:
            enable_filter_sgen_sprite_rain_sm(self, ZM_POSTFX_RAIN_DROPS_FILTER_ID);
            break;
        case RAIN_INTENSITY_MED:
            filter::enable_filter_sgen_sprite_rain(self, ZM_POSTFX_RAIN_DROPS_FILTER_ID);
            break;
        case RAIN_INTENSITY_HIG:
            filter::enable_filter_sprite_rain(self, ZM_POSTFX_RAIN_DROPS_FILTER_ID);
            break;
        default:
            return;
    }

    while(true)
    {
        self.rain_opacity += 0.001;

        if(self.rain_opacity > 1)
            self.rain_opacity = 0.5;

        filter::set_filter_sprite_rain_opacity(self, ZM_POSTFX_RAIN_DROPS_FILTER_ID, self.rain_opacity);
        filter::set_filter_sprite_rain_elapsed(self, ZM_POSTFX_RAIN_DROPS_FILTER_ID, self GetClientTime());
        WAIT_CLIENT_FRAME;
    }
}

function private init_filter_sgen_sprite_rain_sm(player)
{
    filter::init_filter_indices();
    filter::map_material_helper(player, ZM_POSTFX_SMALL_MATERIAL_NAME);
}

function private enable_filter_sgen_sprite_rain_sm(player, filterid)
{
    setfilterpassmaterial(player.localClientNum, filterid, 0, filter::mapped_material_id(ZM_POSTFX_SMALL_MATERIAL_NAME));
    setfilterpassenabled(player.localClientNum, filterid, 0, true);
    setfilterpassquads(player.localClientNum, filterid, 0, 2048);
}

// TODO: use for wind callbacks.
function startWaterSheeting()
{
	self notify("startWaterSheeting_singleton");
	self endon("startWaterSheeting_singleton");
	
	self endon("entityshutdown");
	
	// enabled the filter
	filter::enable_filter_water_sheeting(self, FILTER_INDEX_WATER_SHEET); 

	// start everything revealed and scrolling
	filter::set_filter_water_sheet_reveal(self, FILTER_INDEX_WATER_SHEET, 1.0);
	filter::set_filter_water_sheet_speed(self, FILTER_INDEX_WATER_SHEET, 1.0);

	// taper down and hide
	for (i = WATER_SHEETING_OVERLAY_TIME; i > 0.0; i -= 0.01)
	{
		filter::set_filter_water_sheet_reveal(self, FILTER_INDEX_WATER_SHEET, i / 2.0);
		filter::set_filter_water_sheet_speed(self, FILTER_INDEX_WATER_SHEET, i / 2.0);
		// reveal the rivulets as well
		rivulet1 = (i / 2.0) - 0.19;
		rivulet2 = (i / 2.0) - 0.13;
		rivulet3 = (i / 2.0) - 0.07;
		filter::set_filter_water_sheet_rivulet_reveal(self, FILTER_INDEX_WATER_SHEET, rivulet1, rivulet2, rivulet3);
		// pause
		wait 0.01;
	}
	filter::set_filter_water_sheet_reveal(self, FILTER_INDEX_WATER_SHEET, 0.0);
	filter::set_filter_water_sheet_speed(self, FILTER_INDEX_WATER_SHEET, 0.0);
	filter::set_filter_water_sheet_rivulet_reveal(self, FILTER_INDEX_WATER_SHEET, 0.0, 0.0, 0.0);
}