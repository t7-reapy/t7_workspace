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
    var interior_triggers;
    var liminal_triggers;
}

function init() {
    clientfield::register("toplayer", RAIN_INTERIOR_TYPE_SFX, VERSION_SHIP, 2, "int");
    clientfield::register("toplayer", RAIN_LIMINAL_TYPE_SFX, VERSION_SHIP, 2, "int");
    clientfield::register("toplayer", RAIN_EXTERIOR_TYPE_SFX, VERSION_SHIP, 2, "int");
	callback::on_spawned(&on_player_spawned);

    level.weather.rain.ambience = new RainAmbience();
    level.weather.rain.ambience.interior_triggers = GetEntArray(RAIN_TRIGGER_INTERIOR, "targetname");
    level.weather.rain.ambience.liminal_triggers = GetEntArray(RAIN_TRIGGER_LIMINAL, "targetname");

    array::thread_all(level.weather.rain.ambience.interior_triggers, &rain_interior_trigger_think);
    array::thread_all(level.weather.rain.ambience.liminal_triggers, &rain_liminal_trigger_think);
}

function run() 
{
    foreach (player in GetPlayers())
    {
        player clientfield::set_to_player(RAIN_INTERIOR_TYPE_SFX, RAIN_INTENSITY_DISABLE);
        player clientfield::set_to_player(RAIN_LIMINAL_TYPE_SFX, RAIN_INTENSITY_DISABLE);
        player clientfield::set_to_player(RAIN_EXTERIOR_TYPE_SFX, level.weather.rain.intensity);
    }
}

function pause()
{
    // TODO
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

    self clientfield::set_to_player(RAIN_EXTERIOR_TYPE_SFX, RAIN_INTENSITY_DISABLE);
    self clientfield::set_to_player(RAIN_INTERIOR_TYPE_SFX, level.weather.rain.intensity);
    util::wait_till_not_touching(trigger, self);
    self clientfield::set_to_player(RAIN_INTERIOR_TYPE_SFX, RAIN_INTENSITY_DISABLE);
    self clientfield::set_to_player(RAIN_EXTERIOR_TYPE_SFX, level.weather.rain.intensity);
}

function private rain_liminal_trigger_think()
{
    // self == trigger_multiple
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

    self clientfield::set_to_player(RAIN_EXTERIOR_TYPE_SFX, RAIN_INTENSITY_DISABLE);
    self clientfield::set_to_player(RAIN_LIMINAL_TYPE_SFX, level.weather.rain.intensity);
    util::wait_till_not_touching(trigger, self);
    self clientfield::set_to_player(RAIN_LIMINAL_TYPE_SFX, RAIN_INTENSITY_DISABLE);
    self clientfield::set_to_player(RAIN_EXTERIOR_TYPE_SFX, level.weather.rain.intensity);
}