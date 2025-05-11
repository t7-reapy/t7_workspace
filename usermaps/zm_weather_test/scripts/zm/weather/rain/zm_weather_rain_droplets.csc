// ======================================================================= //
// The zm_weather_rain_droplets script and namespace was strongly inspired //
// from Scobalula's bloodsplatter script, credits to him:                  //
// -----------  https://github.com/Scobalula/Bo3Bloodsplatter ------------ //
// ======================================================================= //

// -------------------------------------------------------------------------------
// Flashlight Script for Black Ops III - Bloc Edition
// Copyright (c) 2022 Philip/Scobalula
// -------------------------------------------------------------------------------
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// -------------------------------------------------------------------------------
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// -------------------------------------------------------------------------------
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// -------------------------------------------------------------------------------

#using scripts\codescripts\struct;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\duplicaterender_mgr;
#using scripts\shared\fx_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\math_shared;

#insert scripts\shared\duplicaterender.gsh;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\weather\zm_weather_shared.gsh;
#insert scripts\zm\weather\zm_weather_rain.gsh;
#insert scripts\zm\weather\rain\zm_weather_rain_droplets.gsh;

#namespace zm_weather_rain_droplets;

function init()
{
    // Clientfields
    clientfield::register("allplayers", "rain_droplets_toggle", VERSION_DLC3, 1, "int", &splash_rain_cf, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);
    // Dupe render definitions
    rain_materials = RAIN_MATERIALS;
    duplicate_render::set_dr_filter_framebuffer_duplicate("vmr_0", 98, "vm_rain_0", undefined, DR_TYPE_FRAMEBUFFER_DUPLICATE, rain_materials[0], DR_CULL_NEVER);
    duplicate_render::set_dr_filter_framebuffer_duplicate("vmr_1", 98, "vm_rain_1", undefined, DR_TYPE_FRAMEBUFFER_DUPLICATE, rain_materials[1], DR_CULL_NEVER);
    duplicate_render::set_dr_filter_framebuffer_duplicate("vmr_2", 98, "vm_rain_2", undefined, DR_TYPE_FRAMEBUFFER_DUPLICATE, rain_materials[2], DR_CULL_NEVER);
    duplicate_render::set_dr_filter_framebuffer_duplicate("vmr_3", 98, "vm_rain_3", undefined, DR_TYPE_FRAMEBUFFER_DUPLICATE, rain_materials[3], DR_CULL_NEVER);

    callback::on_localclient_connect(&on_connect);
}

function private on_connect(n_local_client)
{
    level.rain_on_player = false;
    player = GetLocalPlayer(n_local_client);
    // player.rain_render = array(player, player, player, player);
    player thread rain_splash_on_player(n_local_client);
}

function private splash_rain_cf(n_local_client, n_old, n_new, b_new_ent, b_initial_snap, str_field, b_was_time_jump)
{
    WEATHER_PRINT_DEBUG("splash_rain_cf = " + n_new);
    level.rain_on_player = !level.rain_on_player;
    WEATHER_PRINT_DEBUG("level.rain_on_player = " + level.rain_on_player);
}

function private rain_splash_on_player(n_local_client)
{
    self notify("rain_splash");
    self endon("rain_splash");
    self endon("entity_shutdown");

    while(true)
    {
        WAIT_SERVER_FRAME;    
        
        // Check for spectators, people respawning, and end game
        if(!isdefined(self))
            continue;

        if (!level.rain_on_player)
        {
            continue;
        }

        rain_index = RandomInt(4);
        self thread apply_rain_shader(n_local_client, rain_index);
        waitrealtime(RAIN_SPLASH_TIME / 3);
    }
}

function private apply_rain_shader(n_local_client, index)
{
    dr_flag = "vm_rain_" + index;
    script_vector = "scriptVector0";

    self duplicate_render::set_dr_flag(dr_flag, 1);
    self duplicate_render::update_dr_filters(n_local_client);
    self MapShaderConstant(n_local_client, index, script_vector, 1.0); 

    // Let the droplets stay a bit ...
    waitrealtime(RAIN_SPLASH_TIME);

    start_time = self GetClientTime();
    end_time = start_time + int(RAIN_SPLASH_FADE_TIME * 1000);
    val = 1.0;

    while (isdefined(self) && val > 0)
    {
        self MapShaderConstant(n_local_client, index, script_vector, val);
        val = self lerp(start_time, end_time);
        WAIT_CLIENT_FRAME;
    }
    
    if(isdefined(self))
    {
        self duplicate_render::set_dr_flag(dr_flag, 0);
        self duplicate_render::update_dr_filters(n_local_client);
        self MapShaderConstant(n_local_client, index, script_vector, 0.0);
    }
}

function private lerp( start_time, end_time )
{
    if((end_time - start_time) <= 0)
        return 0;
    
    now = self GetClientTime();

    // Here we use values contained in [0; 0.5] because scriptVector0 reveal
    // isn't really fading before ~0.25. It is mostly due to reveal map used
    frac = float(end_time - now) / (1.0 / 0.5 * float(end_time - start_time));
    clamp_frac = math::clamp(frac, 0.0, 0.5);

    // f(x) = x²/0.25 
    // is good function to make y go down faster in value while x is higher, for x € [0; 0.5]
    result = clamp_frac * clamp_frac / 0.25;

    return result;
}
