// -------------------------------------------------------------------------------
// On-Screen Raindrops for Black Ops III - Harry's Downfall Edition
// Copyright (c) 2022 Philip/Scobalula
// -------------------------------------------------------------------------------
// Licensed under the "Do whatever you want thx hun bun" license.
// -------------------------------------------------------------------------------
#using scripts\shared\callbacks_shared;
#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\weather\zm_weather_shared.gsh;
#insert scripts\zm\weather\zm_weather_rain.gsh;
#insert scripts\zm\weather\rain\zm_weather_rain_drops_postfx.gsh;

#namespace zm_weather_rain_drops_postfx;

class RainDropsPostFx
{
    var triggers;
    var paused;
}

// Init
function init()
{
    level.weather.rain.drops_postfx = new RainDropsPostFx();
    level.weather.rain.drops_postfx.paused = true;
    level.weather.rain.drops_postfx.triggers = GetEntArray(ZM_POSTFX_RAIN_DROPS_TRIGGER_NAME, "targetname");
    
    clientfield::register("toplayer", ZM_POSTFX_RAIN_DROPS_CF_NAME, VERSION_SHIP, 2, "int");
    
    callback::on_spawned(&on_player_spawned);
}

function play()
{
    level endon("entityshutdown");

    if (!level.weather.rain.drops_postfx.paused)
    {
        WEATHER_PRINT_DEBUG("already running rain postfx");
        return;
    }
    
    array::thread_all(level.weather.rain.drops_postfx.triggers, &rain_trigger_think);
    level.weather.rain.drops_postfx.paused = false;
    
    while(true)
    {
        wait 1;

        foreach (player in level.players)
        {
            player update_raindrops(level.weather.rain.intensity);
        }
    }
}

function pause()
{
    if (level.weather.rain.drops_postfx.paused)
    {
        WEATHER_PRINT_DEBUG("already paused rain postfx");
        return;
    }

    // First, stop trigger thinking
    foreach (trigger in level.weather.rain.drops_postfx.triggers)
    {
        trigger notify("trigger_stop_rain_postfx");
    }

    foreach (player in GetPlayers())
    {
        // Second, stop current triggers waiting to not be touched
        player notify("enter_rain_trigger");

        // Finally, turn off client fields
        player clientfield::set_to_player(ZM_POSTFX_RAIN_DROPS_CF_NAME, RAIN_INTENSITY_OFF);
    }
    
    level.weather.rain.drops_postfx.paused = true;
}

function on_player_spawned()
{
    // self == player
    self update_raindrops(level.weather.rain.intensity);
}

function update_raindrops(intensity)
{
    // self == player
    self.rain_on_screen = (intensity != RAIN_INTENSITY_OFF);
    self clientfield::set_to_player(ZM_POSTFX_RAIN_DROPS_CF_NAME, intensity);
}

// Runs rain trigger logic.
function rain_trigger_think()
{
    // self == trigger_multiple
    self endon("trigger_stop_rain_postfx");
    self endon("death");

    while(1)
    {
        self waittill("trigger", e_who);

        if(IsPlayer(e_who))
        {
            e_who thread rain_trigger_toggle(self);
        }
    }
}

// Runs rain trigger on enter and exit.
function rain_trigger_toggle(e_trigger)
{
    // self == player
    self notify("enter_rain_trigger");
    self endon("disconnect");
    self endon("enter_rain_trigger");

    self update_raindrops(RAIN_INTENSITY_OFF);
    util::wait_till_not_touching(e_trigger, self);
    
    self notify("exit_rain_trigger");
}
