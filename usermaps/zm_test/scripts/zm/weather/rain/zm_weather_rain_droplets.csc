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

#define SHADER_VECTOR_NAME "scriptVector2"
#define SHADER_STATE 0

function init()
{
    // Clientfields
    clientfield::register("allplayers", RAIN_VM_CF_NAME, VERSION_DLC3, 1, "int", &splash_rain_cf, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);

    // Dupe render definitions
    duplicate_render::set_dr_filter_framebuffer_duplicate("vmr_0",  98, "vm_rain",  undefined, DR_TYPE_FRAMEBUFFER_DUPLICATE, "mc/ltr_rain_droplets_flipbook_scripted", DR_CULL_NEVER);
}

function private splash_rain_cf(n_local_client, n_old, shouldRainOnPlayer, b_new_ent, b_initial_snap, str_field, b_was_time_jump)
{
    util::waitforclient(n_local_client);

    if (shouldRainOnPlayer)
    {
        self thread rain_splash_fade_in(n_local_client);
    }
    else
    {
        self thread rain_splash_fade_out(n_local_client);
    }
}

function private clear_rain_filter(n_local_client) // self == player
{
    self duplicate_render::set_dr_flag("vm_rain", false);
    self duplicate_render::update_dr_filters(n_local_client);
}

function private apply_rain_filter(n_local_client) // self == player
{
    self duplicate_render::set_dr_flag("vm_rain", true);
    self duplicate_render::update_dr_filters(n_local_client);
}

function private rain_splash_fade_in(n_local_client)
{
    self notify("rain_splash_fade_out");
    self notify("rain_splash_fade_in");
    self endon("rain_splash_fade_in");
    self endon("entity_shutdown");

    self apply_rain_filter(n_local_client);
    self MapShaderConstant(n_local_client, 0, SHADER_VECTOR_NAME, 0, 1.0, SHADER_STATE);
    start_time = self GetClientTime();
    end_time = start_time + int(RAIN_VM_SPLASH_FADE_TIME * 1000);
    
    val = 0.0;
    while (isdefined(self) && val < 1)
    {
        self MapShaderConstant(n_local_client, 0, SHADER_VECTOR_NAME, 0, val, SHADER_STATE);
        val = self lerp(start_time, end_time, true);
        WAIT_CLIENT_FRAME;
    }
    self MapShaderConstant(n_local_client, 0, SHADER_VECTOR_NAME, 0, 1.0, SHADER_STATE);
}

function private rain_splash_fade_out(n_local_client)
{
    self notify("rain_splash_fade_in");
    self notify("rain_splash_fade_out");
    self endon("rain_splash_fade_out");
    self endon("entity_shutdown");

    start_time = self GetClientTime();
    end_time = start_time + int(RAIN_VM_SPLASH_FADE_TIME * 1000);
    
    val = 1.0;
    while (isdefined(self) && val > 0)
    {
        self MapShaderConstant(n_local_client, 0, SHADER_VECTOR_NAME, 0, val, SHADER_STATE);
        val = self lerp(start_time, end_time, false);
        WAIT_CLIENT_FRAME;
    }

    self MapShaderConstant(n_local_client, 0, SHADER_VECTOR_NAME, 0, 0.0, SHADER_STATE);
    self clear_rain_filter(n_local_client);
}

function private lerp(start_time, end_time, reverse)
{
    if((end_time - start_time) <= 0)
        return 0;
    
    now = self GetClientTime();

    frac = float(end_time - now) / float(end_time - start_time);
    clamp_frac = math::clamp(frac, 0.0, 1.0);

    if (reverse) clamp_frac = 1.0 - clamp_frac;

    return clamp_frac;
}
