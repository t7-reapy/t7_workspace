// ======================================================================= //
// The zm_weather_rain_droplets script and namespace was strongly inspired //
// from Scobalula's bloodsplatter script, credits to him:                  //
// -----------  https://github.com/Scobalula/Bo3Bloodsplatter ------------ //
// ======================================================================= //

// -------------------------------------------------------------------------------
// Player Bloodsplatter for Black Ops III - Bloc Edition
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

#using scripts\shared\clientfield_shared;
#using scripts\zm\_zm;

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
    clientfield::register("allplayers", "rain_droplets_toggle", VERSION_DLC3, 1, "int");
}

function play()
{
    // TODO
}

function pause()
{
    // TODO
}

/@
"Name: splash_rain_on_player(b_enabled)"
"Summary: Splashers rain onto the player's viewmodel and body.
"Module: Raindroplets"
"Example: player zm_weather_rain_droplets::splash_rain_on_player(b_enabled);"
"SPMP: both"
@/
function splash_rain_on_player(b_enabled)
{
    WEATHER_PRINT_DEBUG("splash_rain_on_player callback");
    self clientfield::set("rain_droplets_toggle", b_enabled);
}
