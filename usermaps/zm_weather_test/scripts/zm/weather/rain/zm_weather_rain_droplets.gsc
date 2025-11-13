#using scripts\shared\util_shared; 
#using scripts\shared\array_shared; 
#using scripts\shared\callbacks_shared; 
#using scripts\shared\clientfield_shared;
#using scripts\zm\_zm;

#insert scripts\shared\duplicaterender.gsh;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\weather\zm_weather_shared.gsh;
#insert scripts\zm\weather\zm_weather_rain.gsh;
#insert scripts\zm\weather\rain\zm_weather_rain_droplets.gsh;

#namespace zm_weather_rain_droplets;

class RainDroplets
{
    var paused;
    var triggers;
}

function init()
{
    // Clientfields
    clientfield::register("allplayers", RAIN_VM_CF_NAME, VERSION_DLC3, 1, "int");
    
    level.weather.rain.droplets = new RainDroplets();
    level.weather.rain.droplets.paused = true;
    level.weather.rain.droplets.triggers = GetEntArray(RAIN_VM_TRIGGER_NAME, "targetname");
    
    callback::on_spawned(&on_player_spawned);
}

function on_player_spawned() // self == player
{
    self update_raindrops(level.weather.rain.intensity);
}

function update_raindrops(intensity) // self == player
{
    self.rain_on_viewmodel = (intensity != WEATHER_INTENSITY_OFF);
    self clientfield::set(RAIN_VM_CF_NAME, self.rain_on_viewmodel);
}

function play()
{
    level endon("entityshutdown");

    if (!level.weather.rain.droplets.paused)
    {
        WEATHER_PRINT_DEBUG("already running rain droplets");
        return;
    }

    foreach (player in GetPlayers())
    {
        // Resume player viewmodel raindrops, triggers will clear if necessary.
        player update_raindrops(level.weather.rain.intensity);
    }
    
    array::thread_all(level.weather.rain.droplets.triggers, &rain_trigger_think);
    level.weather.rain.droplets.paused = false;
}

function pause()
{
    if (level.weather.rain.droplets.paused)
    {
        WEATHER_PRINT_DEBUG("already paused rain droplets");
        return;
    }

    // First, stop trigger thinking
    foreach (trigger in level.weather.rain.droplets.triggers)
    {
        trigger notify("trigger_stop_rain_droplets");
    }

    foreach (player in GetPlayers())
    {
        // Second, stop current triggers waiting to not be touched
        player notify("enter_rain_droplets_trigger");

        // Finally, turn off client fields
        player update_raindrops(WEATHER_INTENSITY_OFF);
    }
    
    level.weather.rain.droplets.paused = true;
}

function rain_trigger_think() // self == trigger_multiple
{
    self endon("trigger_stop_rain_droplets");
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

function rain_trigger_toggle(e_trigger) // self == player
{
    self notify("enter_rain_droplets_trigger");
    self endon("disconnect");
    self endon("enter_rain_droplets_trigger");

    self update_raindrops(WEATHER_INTENSITY_OFF);
    util::wait_till_not_touching(e_trigger, self);
    self update_raindrops(level.weather.rain.intensity);
    
    self notify("exit_rain_droplets_trigger");
}
