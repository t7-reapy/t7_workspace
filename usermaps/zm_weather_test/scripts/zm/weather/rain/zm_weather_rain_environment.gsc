#using scripts\shared\clientfield_shared; 

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\weather\zm_weather_shared.gsh;
#insert scripts\zm\weather\zm_weather_rain.gsh;
#insert scripts\zm\weather\rain\zm_weather_rain_environment.gsh;

#namespace zm_weather_rain_environment;

function init() 
{
    clientfield::register("world", DECAL_RAIN_TOGGLE, VERSION_SHIP, 1, "int");
}

function run() 
{
    while(true)
    {
        update();
        WAIT_SERVER_FRAME;
    }
}

function pause()
{
    
}

function update()
{
    decal_enabled = (level.weather.rain.intensity != RAIN_INTENSITY_DISABLE);
    level clientfield::set(DECAL_RAIN_TOGGLE, decal_enabled);
}