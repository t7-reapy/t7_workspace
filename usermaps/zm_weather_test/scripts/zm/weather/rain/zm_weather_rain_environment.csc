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
    clientfield::register("world", DECAL_RAIN_TOGGLE, VERSION_SHIP, 1, "int", &decal_rain_toggle, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);

    level.weather.rain.environment = new RainEnvironment();
    level.weather.rain.environment.volume_decals = FindVolumeDecalIndexArray(DECAL_RAIN_TARGETNAME);
}

function run() 
{
}

function private decal_rain_toggle(_localClientNum, _oldVal, shouldRain, _bNewEnt, _bInitialSnap, _fieldName, _bWasTimeJump)
{
    volume_decals = level.weather.rain.environment.volume_decals;

    foreach (volume_decal in volume_decals)
    {
        if (isdefined(shouldRain) && shouldRain)
        {
            UnhideVolumeDecal(volume_decal);
        }
        else
        {
            HideVolumeDecal(volume_decal);
        }
    }
}
