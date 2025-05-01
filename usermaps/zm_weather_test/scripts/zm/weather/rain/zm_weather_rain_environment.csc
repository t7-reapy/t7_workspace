#using scripts\shared\clientfield_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\weather\zm_weather_shared.gsh;
#insert scripts\zm\weather\zm_weather_rain.gsh;
#insert scripts\zm\weather\rain\zm_weather_rain_environment.gsh;

#namespace zm_weather_rain_environment;

class RainEnvironment {
    var volume_decals;
}

function init() 
{
    level.weather.rain.environment = new RainEnvironment();
    level.weather.rain.environment.volume_decals = FindVolumeDecalIndexArray("decalrain");
    clientfield::register("world", DECAL_RAIN_TOGGLE, VERSION_SHIP, 1, "int", &decal_rain_toggle, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);
}

function run() 
{
}

function private decal_rain_toggle(_localClientNum, _oldVal, shouldRain, _bNewEnt, _bInitialSnap, _fieldName, _bWasTimeJump)
{
    volume_decals = level.weather.rain.environment.volume_decals;

    if(isdefined(shouldRain) && shouldRain)
    {
        for(i=0; i < volume_decals.size; i++)
        {
            UnhideVolumeDecal(volume_decals[i]);
        }
    } else {
        for(i=0; i < volume_decals.size; i++)
        {
            HideVolumeDecal(volume_decals[i]);
        }
    }
}
