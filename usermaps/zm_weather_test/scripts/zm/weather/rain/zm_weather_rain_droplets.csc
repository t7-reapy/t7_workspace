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
#define SHADER_VECTOR_NAME "scriptVector0"

function init()
{
    // Clientfields
    clientfield::register("allplayers", RAIN_VM_CF_NAME, VERSION_DLC3, 1, "int", &splash_rain_cf, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);

    // Dupe render definitions
    /* 
        /!\ This exceeds the indexed material limits of 64. 
        Meaning that all materials at the begining of the array will be discarded after a few iterations in rain_splash_on_player.
    */
    duplicate_render::set_dr_filter_framebuffer_duplicate("vmr_0",  98, "vm_rain_0",  undefined, DR_TYPE_FRAMEBUFFER_DUPLICATE, "mc/ltr_rain_droplets_scripted_01", DR_CULL_NEVER);
    duplicate_render::set_dr_filter_framebuffer_duplicate("vmr_1",  98, "vm_rain_1",  undefined, DR_TYPE_FRAMEBUFFER_DUPLICATE, "mc/ltr_rain_droplets_scripted_02", DR_CULL_NEVER);
    duplicate_render::set_dr_filter_framebuffer_duplicate("vmr_2",  98, "vm_rain_2",  undefined, DR_TYPE_FRAMEBUFFER_DUPLICATE, "mc/ltr_rain_droplets_scripted_03", DR_CULL_NEVER);
    duplicate_render::set_dr_filter_framebuffer_duplicate("vmr_3",  98, "vm_rain_3",  undefined, DR_TYPE_FRAMEBUFFER_DUPLICATE, "mc/ltr_rain_droplets_scripted_04", DR_CULL_NEVER);
    duplicate_render::set_dr_filter_framebuffer_duplicate("vmr_4",  98, "vm_rain_4",  undefined, DR_TYPE_FRAMEBUFFER_DUPLICATE, "mc/ltr_rain_droplets_scripted_05", DR_CULL_NEVER);
    duplicate_render::set_dr_filter_framebuffer_duplicate("vmr_5",  98, "vm_rain_5",  undefined, DR_TYPE_FRAMEBUFFER_DUPLICATE, "mc/ltr_rain_droplets_scripted_06", DR_CULL_NEVER);
    duplicate_render::set_dr_filter_framebuffer_duplicate("vmr_6",  98, "vm_rain_6",  undefined, DR_TYPE_FRAMEBUFFER_DUPLICATE, "mc/ltr_rain_droplets_scripted_07", DR_CULL_NEVER);
    duplicate_render::set_dr_filter_framebuffer_duplicate("vmr_7",  98, "vm_rain_7",  undefined, DR_TYPE_FRAMEBUFFER_DUPLICATE, "mc/ltr_rain_droplets_scripted_08", DR_CULL_NEVER);
    duplicate_render::set_dr_filter_framebuffer_duplicate("vmr_8",  98, "vm_rain_8",  undefined, DR_TYPE_FRAMEBUFFER_DUPLICATE, "mc/ltr_rain_droplets_scripted_09", DR_CULL_NEVER);
    duplicate_render::set_dr_filter_framebuffer_duplicate("vmr_9",  98, "vm_rain_9",  undefined, DR_TYPE_FRAMEBUFFER_DUPLICATE, "mc/ltr_rain_droplets_scripted_10", DR_CULL_NEVER);
    duplicate_render::set_dr_filter_framebuffer_duplicate("vmr_10", 98, "vm_rain_10", undefined, DR_TYPE_FRAMEBUFFER_DUPLICATE, "mc/ltr_rain_droplets_scripted_11", DR_CULL_NEVER);
    duplicate_render::set_dr_filter_framebuffer_duplicate("vmr_11", 98, "vm_rain_11", undefined, DR_TYPE_FRAMEBUFFER_DUPLICATE, "mc/ltr_rain_droplets_scripted_12", DR_CULL_NEVER);
    duplicate_render::set_dr_filter_framebuffer_duplicate("vmr_12", 98, "vm_rain_12", undefined, DR_TYPE_FRAMEBUFFER_DUPLICATE, "mc/ltr_rain_droplets_scripted_13", DR_CULL_NEVER);
    duplicate_render::set_dr_filter_framebuffer_duplicate("vmr_13", 98, "vm_rain_13", undefined, DR_TYPE_FRAMEBUFFER_DUPLICATE, "mc/ltr_rain_droplets_scripted_14", DR_CULL_NEVER);
    duplicate_render::set_dr_filter_framebuffer_duplicate("vmr_14", 98, "vm_rain_14", undefined, DR_TYPE_FRAMEBUFFER_DUPLICATE, "mc/ltr_rain_droplets_scripted_15", DR_CULL_NEVER);
    duplicate_render::set_dr_filter_framebuffer_duplicate("vmr_15", 98, "vm_rain_15", undefined, DR_TYPE_FRAMEBUFFER_DUPLICATE, "mc/ltr_rain_droplets_scripted_16", DR_CULL_NEVER);
    duplicate_render::set_dr_filter_framebuffer_duplicate("vmr_16", 98, "vm_rain_16", undefined, DR_TYPE_FRAMEBUFFER_DUPLICATE, "mc/ltr_rain_droplets_scripted_17", DR_CULL_NEVER);
    duplicate_render::set_dr_filter_framebuffer_duplicate("vmr_17", 98, "vm_rain_17", undefined, DR_TYPE_FRAMEBUFFER_DUPLICATE, "mc/ltr_rain_droplets_scripted_18", DR_CULL_NEVER);
    duplicate_render::set_dr_filter_framebuffer_duplicate("vmr_18", 98, "vm_rain_18", undefined, DR_TYPE_FRAMEBUFFER_DUPLICATE, "mc/ltr_rain_droplets_scripted_19", DR_CULL_NEVER);
    duplicate_render::set_dr_filter_framebuffer_duplicate("vmr_19", 98, "vm_rain_19", undefined, DR_TYPE_FRAMEBUFFER_DUPLICATE, "mc/ltr_rain_droplets_scripted_20", DR_CULL_NEVER);
    duplicate_render::set_dr_filter_framebuffer_duplicate("vmr_20", 98, "vm_rain_20", undefined, DR_TYPE_FRAMEBUFFER_DUPLICATE, "mc/ltr_rain_droplets_scripted_21", DR_CULL_NEVER);
    duplicate_render::set_dr_filter_framebuffer_duplicate("vmr_21", 98, "vm_rain_21", undefined, DR_TYPE_FRAMEBUFFER_DUPLICATE, "mc/ltr_rain_droplets_scripted_22", DR_CULL_NEVER);
    duplicate_render::set_dr_filter_framebuffer_duplicate("vmr_22", 98, "vm_rain_22", undefined, DR_TYPE_FRAMEBUFFER_DUPLICATE, "mc/ltr_rain_droplets_scripted_23", DR_CULL_NEVER);
    duplicate_render::set_dr_filter_framebuffer_duplicate("vmr_23", 98, "vm_rain_23", undefined, DR_TYPE_FRAMEBUFFER_DUPLICATE, "mc/ltr_rain_droplets_scripted_24", DR_CULL_NEVER);
    duplicate_render::set_dr_filter_framebuffer_duplicate("vmr_24", 98, "vm_rain_24", undefined, DR_TYPE_FRAMEBUFFER_DUPLICATE, "mc/ltr_rain_droplets_scripted_25", DR_CULL_NEVER);
    duplicate_render::set_dr_filter_framebuffer_duplicate("vmr_25", 98, "vm_rain_25", undefined, DR_TYPE_FRAMEBUFFER_DUPLICATE, "mc/ltr_rain_droplets_scripted_26", DR_CULL_NEVER);
    duplicate_render::set_dr_filter_framebuffer_duplicate("vmr_26", 98, "vm_rain_26", undefined, DR_TYPE_FRAMEBUFFER_DUPLICATE, "mc/ltr_rain_droplets_scripted_27", DR_CULL_NEVER);
    duplicate_render::set_dr_filter_framebuffer_duplicate("vmr_27", 98, "vm_rain_27", undefined, DR_TYPE_FRAMEBUFFER_DUPLICATE, "mc/ltr_rain_droplets_scripted_28", DR_CULL_NEVER);
    duplicate_render::set_dr_filter_framebuffer_duplicate("vmr_28", 98, "vm_rain_28", undefined, DR_TYPE_FRAMEBUFFER_DUPLICATE, "mc/ltr_rain_droplets_scripted_29", DR_CULL_NEVER);
    duplicate_render::set_dr_filter_framebuffer_duplicate("vmr_29", 98, "vm_rain_29", undefined, DR_TYPE_FRAMEBUFFER_DUPLICATE, "mc/ltr_rain_droplets_scripted_30", DR_CULL_NEVER);
    duplicate_render::set_dr_filter_framebuffer_duplicate("vmr_30", 98, "vm_rain_30", undefined, DR_TYPE_FRAMEBUFFER_DUPLICATE, "mc/ltr_rain_droplets_scripted_31", DR_CULL_NEVER);
    duplicate_render::set_dr_filter_framebuffer_duplicate("vmr_31", 98, "vm_rain_31", undefined, DR_TYPE_FRAMEBUFFER_DUPLICATE, "mc/ltr_rain_droplets_scripted_32", DR_CULL_NEVER);
    duplicate_render::set_dr_filter_framebuffer_duplicate("vmr_32", 98, "vm_rain_32", undefined, DR_TYPE_FRAMEBUFFER_DUPLICATE, "mc/ltr_rain_droplets_scripted_33", DR_CULL_NEVER);
    duplicate_render::set_dr_filter_framebuffer_duplicate("vmr_33", 98, "vm_rain_33", undefined, DR_TYPE_FRAMEBUFFER_DUPLICATE, "mc/ltr_rain_droplets_scripted_34", DR_CULL_NEVER);
    duplicate_render::set_dr_filter_framebuffer_duplicate("vmr_34", 98, "vm_rain_34", undefined, DR_TYPE_FRAMEBUFFER_DUPLICATE, "mc/ltr_rain_droplets_scripted_35", DR_CULL_NEVER);
    duplicate_render::set_dr_filter_framebuffer_duplicate("vmr_35", 98, "vm_rain_35", undefined, DR_TYPE_FRAMEBUFFER_DUPLICATE, "mc/ltr_rain_droplets_scripted_36", DR_CULL_NEVER);
    duplicate_render::set_dr_filter_framebuffer_duplicate("vmr_36", 98, "vm_rain_36", undefined, DR_TYPE_FRAMEBUFFER_DUPLICATE, "mc/ltr_rain_droplets_scripted_37", DR_CULL_NEVER);
    duplicate_render::set_dr_filter_framebuffer_duplicate("vmr_37", 98, "vm_rain_37", undefined, DR_TYPE_FRAMEBUFFER_DUPLICATE, "mc/ltr_rain_droplets_scripted_38", DR_CULL_NEVER);
    duplicate_render::set_dr_filter_framebuffer_duplicate("vmr_38", 98, "vm_rain_38", undefined, DR_TYPE_FRAMEBUFFER_DUPLICATE, "mc/ltr_rain_droplets_scripted_39", DR_CULL_NEVER);
    duplicate_render::set_dr_filter_framebuffer_duplicate("vmr_39", 98, "vm_rain_39", undefined, DR_TYPE_FRAMEBUFFER_DUPLICATE, "mc/ltr_rain_droplets_scripted_40", DR_CULL_NEVER);

    callback::on_localclient_connect(&on_connect);
}

function private splash_rain_cf(n_local_client, n_old, shouldRainOnPlayer, b_new_ent, b_initial_snap, str_field, b_was_time_jump)
{
    util::waitforclient(n_local_client);
    self thread rain_splash_on_player(n_local_client);

    if (shouldRainOnPlayer)
    {
        self thread rain_splash_fade_in(n_local_client);
    }
    else
    {
        self thread rain_splash_fade_out(n_local_client);
    }
}

function private on_connect(n_local_client)
{
    player = GetLocalPlayer(n_local_client);
    player.vm_rain_on_player = false;
}

function private rain_splash_on_player(n_local_client)
{
    if (IS_TRUE(self.vm_rain_on_player))
    {
        return;
    }
    self.vm_rain_on_player = true;

    self notify("rain_splash");
    self endon("rain_splash");
    self endon("entity_shutdown");

    self MapShaderConstant(n_local_client, 0, SHADER_VECTOR_NAME, 0.0); 

    rain_index = 0;
    while(self.vm_rain_on_player)
    {
        wait 1.0 / RAIN_VM_FRAMES_PER_SECONDS;

        // Check for people respawning, and end game
        if(!isdefined(self))
        {
            continue;
        }

        self clear_rain_filter(n_local_client, rain_index);
        rain_index = (rain_index + 1) % 40;
        self apply_rain_filter(n_local_client, rain_index);
        self duplicate_render::update_dr_filters(n_local_client);
    }
}

function private clear_rain_filter(n_local_client, index)
{
    dr_flag = "vm_rain_" + index;
    self duplicate_render::set_dr_flag(dr_flag, 0);
}

function private apply_rain_filter(n_local_client, index)
{
    dr_flag = "vm_rain_" + index;
    self duplicate_render::set_dr_flag(dr_flag, 1);
}

function private rain_splash_fade_in(n_local_client)
{
    self notify("rain_splash_fade_out");
    self notify("rain_splash_fade_in");
    self endon("rain_splash_fade_in");
    self endon("entity_shutdown");

    self MapShaderConstant(n_local_client, 0, SHADER_VECTOR_NAME, 0.0); 

    start_time = self GetClientTime();
    end_time = start_time + int(RAIN_VM_SPLASH_FADE_TIME * 1000);
    
    val = 0.0;
    while (isdefined(self) && val < 1)
    {
        self MapShaderConstant(n_local_client, 0, SHADER_VECTOR_NAME, val);
        val = self lerp(start_time, end_time, true);
        WAIT_CLIENT_FRAME;
    }
    self MapShaderConstant(n_local_client, 0, SHADER_VECTOR_NAME, 1.0);
}

function private rain_splash_fade_out(n_local_client)
{
    self notify("rain_splash_fade_in");
    self notify("rain_splash_fade_out");
    self endon("rain_splash_fade_out");
    self endon("entity_shutdown");

    self MapShaderConstant(n_local_client, 0, SHADER_VECTOR_NAME, 1.0); 

    start_time = self GetClientTime();
    end_time = start_time + int(RAIN_VM_SPLASH_FADE_TIME * 1000);
    
    val = 1.0;
    while (isdefined(self) && val > 0)
    {
        self MapShaderConstant(n_local_client, 0, SHADER_VECTOR_NAME, val);
        val = self lerp(start_time, end_time, false);
        WAIT_CLIENT_FRAME;
    }

    self MapShaderConstant(n_local_client, 0, SHADER_VECTOR_NAME, 0.0);
    self.vm_rain_on_player = false;
}

function private lerp(start_time, end_time, reverse)
{
    if((end_time - start_time) <= 0)
        return 0;
    
    now = self GetClientTime();

    // Here we use values contained in [0; 0.5] because scriptVector0 reveal
    // isn't really fading before ~0.25. It is mostly due to reveal map used
    frac = float(end_time - now) / (1.0 / 0.5 * float(end_time - start_time));
    clamp_frac = math::clamp(frac, 0.0, 0.5);

    if (reverse) clamp_frac = 0.5 - clamp_frac;

    // f(x) = x²/0.25 
    // is good function to make y go down faster in value while x is higher, for x € [0; 0.5]
    result = clamp_frac * clamp_frac / 0.25;

    return result;
}
