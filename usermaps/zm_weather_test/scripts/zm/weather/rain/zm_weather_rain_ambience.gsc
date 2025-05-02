#using scripts\shared\array_shared; 
#using scripts\shared\callbacks_shared; 
#using scripts\shared\clientfield_shared; 
#using scripts\shared\flag_shared; 
#using scripts\shared\util_shared; 

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\weather\zm_weather_shared.gsh;
#insert scripts\zm\weather\zm_weather_rain.gsh;
#insert scripts\zm\weather\rain\zm_weather_rain_ambience.gsh;

#namespace zm_weather_rain_ambience;

class RainAmbience {
    var paused;

    var interior_triggers;
    var liminal_triggers;
}

function init() {
    clientfield::register("toplayer", RAIN_INTERIOR_TYPE_SFX, VERSION_SHIP, 2, "int");
    clientfield::register("toplayer", RAIN_LIMINAL_TYPE_SFX, VERSION_SHIP, 2, "int");
    clientfield::register("toplayer", RAIN_EXTERIOR_TYPE_SFX, VERSION_SHIP, 2, "int");

    level.weather.rain.ambience = new RainAmbience();
    level.weather.rain.ambience.paused = true;
    level.weather.rain.ambience.interior_triggers = GetEntArray(RAIN_TRIGGER_INTERIOR, "targetname");
    level.weather.rain.ambience.liminal_triggers = GetEntArray(RAIN_TRIGGER_LIMINAL, "targetname");

	callback::on_spawned(&on_player_spawned);
}

function run() 
{
    level endon("entityshutdown");

    if (!level.weather.rain.ambience.paused)
    {
        WEATHER_PRINT_DEBUG("rain ambience already running");
        return;
    }

    foreach (player in GetPlayers())
    {
        player clientfield::set_to_player(RAIN_INTERIOR_TYPE_SFX, RAIN_INTENSITY_DISABLE);
        player clientfield::set_to_player(RAIN_LIMINAL_TYPE_SFX, RAIN_INTENSITY_DISABLE);
        player clientfield::set_to_player(RAIN_EXTERIOR_TYPE_SFX, level.weather.rain.intensity);
    }

    array::thread_all(level.weather.rain.ambience.interior_triggers, &rain_interior_trigger_think);
    array::thread_all(level.weather.rain.ambience.liminal_triggers, &rain_liminal_trigger_think);
    
    level.weather.rain.ambience.paused = false;
}

function pause()
{
    if (level.weather.rain.ambience.paused)
    {
        WEATHER_PRINT_DEBUG("already paused rain ambience");
        return;
    }

    // First, stop trigger thinking
    foreach (trigger in level.weather.rain.ambience.interior_triggers)
    {
        trigger notify("trigger_stop_rain_interior");
    }
    foreach (trigger in level.weather.rain.ambience.liminal_triggers)
    {
        trigger notify("trigger_stop_rain_liminal");
    }

    foreach (player in GetPlayers())
    {
        // Second, stop any sound being updated
        player notify("stop_interior_rain_sound_update");
        player notify("stop_liminal_rain_sound_update");
        player notify("stop_exterior_rain_sound_update");

        // Third, stop current triggers waiting to not be touched
        player notify("enter_rain_interior_sound_trigger");
        player notify("enter_rain_liminal_sound_trigger");

        // Finally, turn off client fields
        player clientfield::set_to_player(RAIN_INTERIOR_TYPE_SFX, RAIN_INTENSITY_DISABLE);
        player clientfield::set_to_player(RAIN_LIMINAL_TYPE_SFX, RAIN_INTENSITY_DISABLE);
        player clientfield::set_to_player(RAIN_EXTERIOR_TYPE_SFX, RAIN_INTENSITY_DISABLE);
    }
    
    level.weather.rain.ambience.paused = true;
}

function private on_player_spawned()
{
    // self == player
    self clientfield::set_to_player(RAIN_INTERIOR_TYPE_SFX, RAIN_INTENSITY_DISABLE);
    self clientfield::set_to_player(RAIN_LIMINAL_TYPE_SFX, RAIN_INTENSITY_DISABLE);
    self clientfield::set_to_player(RAIN_EXTERIOR_TYPE_SFX, level.weather.rain.intensity);
}

function private rain_interior_trigger_think()
{
    // self == trigger_multiple
    self notify("trigger_stop_rain_interior");
    self endon("trigger_stop_rain_interior");
    self endon("death");
    
    while(true)
    {
        self waittill("trigger", player);

        if (IsPlayer(player))
        {
            // Need to thread here (and not pause) in case other players enter the trigger on server.
            player thread rain_interior_sound(self);
        }
    }
}

function private rain_interior_sound(trigger)
{
    // self == player
	self notify("enter_rain_interior_sound_trigger");
	self endon("disconnect");
	self endon("enter_rain_interior_sound_trigger");

    self notify("stop_exterior_rain_sound_update");
    self clientfield::set_to_player(RAIN_EXTERIOR_TYPE_SFX, RAIN_INTENSITY_DISABLE);
    self thread play_and_update_interior_rain_sound();
    util::wait_till_not_touching(trigger, self);
    self notify("stop_interior_rain_sound_update");
    self thread play_and_update_exterior_rain_sound();
    self clientfield::set_to_player(RAIN_INTERIOR_TYPE_SFX, RAIN_INTENSITY_DISABLE);
}

function private rain_liminal_trigger_think()
{
    // self == trigger_multiple
    self notify("trigger_stop_rain_liminal");
    self endon("trigger_stop_rain_liminal");
    self endon("death");
    
    while(true)
    {
        self waittill("trigger", player);

        if (IsPlayer(player))
        {
            // Need to thread here (and not pause) in case other players enter the trigger on server.
            player thread rain_liminal_sound(self);
        }
    }
}

function private rain_liminal_sound(trigger)
{
    // self == player
	self notify("enter_rain_liminal_sound_trigger");
	self endon("disconnect");
	self endon("enter_rain_liminal_sound_trigger");

    self notify("stop_exterior_rain_sound_update");
    self clientfield::set_to_player(RAIN_EXTERIOR_TYPE_SFX, RAIN_INTENSITY_DISABLE);
    self thread play_and_update_liminal_rain_sound();
    util::wait_till_not_touching(trigger, self);
    self notify("stop_liminal_rain_sound_update");
    self thread play_and_update_exterior_rain_sound();
    self clientfield::set_to_player(RAIN_LIMINAL_TYPE_SFX, RAIN_INTENSITY_DISABLE);
}


// TODO: doesn't work.

function private play_and_update_interior_rain_sound()
{
    // self == player
    self endon("stop_interior_rain_sound_update");
	self endon("disconnect");

    while(true)
    {
        self clientfield::set_to_player(RAIN_INTERIOR_TYPE_SFX, level.weather.rain.intensity);
        WAIT_SERVER_FRAME;
    }
}

function private play_and_update_liminal_rain_sound()
{
    // self == player
    self endon("stop_liminal_rain_sound_update");
	self endon("disconnect");

    while(true)
    {
        self clientfield::set_to_player(RAIN_LIMINAL_TYPE_SFX, level.weather.rain.intensity);
        WAIT_SERVER_FRAME;
    }
}

function private play_and_update_exterior_rain_sound()
{
    // self == player
    self endon("stop_exterior_rain_sound_update");
	self endon("disconnect");

    while(true)
    {
        self clientfield::set_to_player(RAIN_EXTERIOR_TYPE_SFX, level.weather.rain.intensity);
        WAIT_SERVER_FRAME;
    }
}