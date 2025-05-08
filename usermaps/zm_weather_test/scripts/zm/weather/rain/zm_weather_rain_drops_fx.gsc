#using scripts\shared\callbacks_shared; 
#using scripts\shared\clientfield_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\weather\zm_weather_shared.gsh;
#insert scripts\zm\weather\zm_weather_rain.gsh;
#insert scripts\zm\weather\rain\zm_weather_rain_drops_fx.gsh;

#precache ("fx", FX_RAIN_LIGHT);
#precache ("fx", FX_RAIN_REGULAR);
#precache ("fx", FX_RAIN_HEAVY);

#namespace zm_weather_rain_drops_fx;

class RainDropsFx {
    var paused;
}

function init() 
{
    clientfield::register("world", FX_RAIN_CF_NAME, VERSION_SHIP, 2, "int");
    
    level.weather.rain.drops_fx = new RainDropsFx();
    level.weather.rain.drops_fx.paused = true;
    
    level define_rain_amount();
}

function play() 
{
    level endon("level_stop_rain_fx");
    level endon("entityshutdown");
    
    if (!level.weather.rain.drops_fx.paused)
    {
        WEATHER_PRINT_DEBUG("already running rain fx");
        return;
    }

    level.weather.rain.drops_fx.paused = false;

    while(true)
    {
        level update_rain();
        WAIT_SERVER_FRAME;
    }
}

function pause()
{
    if (level.weather.rain.drops_fx.paused)
    {
        WEATHER_PRINT_DEBUG("already paused rain fx");
        return;
    }

    level notify("level_stop_rain_fx");
    level clientfield::set(FX_RAIN_CF_NAME, RAIN_INTENSITY_OFF);

    level.weather.rain.drops_fx.paused = true;
}

function private update_rain()
{
    // self == level
    self define_rain_amount();
    self clientfield::set(FX_RAIN_CF_NAME, self.weather.rain.intensity);
}

function private define_rain_amount()
{
    // self == level
    if(self.weather.rain.intensity != RAIN_INTENSITY_OFF)
    {
        self._effect[FX_RAIN_LEVEL_NAME] = FX_RAIN_LEVELS[self.weather.rain.intensity];
    }
}

