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

class RainDropsFx {}

function init() 
{
    level.weather.rain.drops_fx = new RainDropsFx();
    
    level define_rain_amount();
    clientfield::register("world", FX_RAIN_CF_NAME, VERSION_SHIP, 2, "int");
}

function run() 
{
    while(true)
    {
        update_rain();
        WAIT_SERVER_FRAME;
    }
}

function pause()
{
    
}

function update_rain()
{
    define_rain_amount();
    level clientfield::set(FX_RAIN_CF_NAME, level.weather.rain.intensity);
}

function private define_rain_amount()
{
    self._effect[FX_RAIN_LEVEL_NAME] = FX_RAIN_LEVELS[level.weather.rain.intensity];
}

