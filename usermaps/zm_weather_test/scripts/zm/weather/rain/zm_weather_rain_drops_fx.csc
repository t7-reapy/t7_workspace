#using scripts\shared\callbacks_shared; 
#using scripts\shared\util_shared;
#using scripts\shared\clientfield_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\weather\zm_weather_shared.gsh;
#insert scripts\zm\weather\zm_weather_rain.gsh;
#insert scripts\zm\weather\rain\zm_weather_rain_drops_fx.gsh;

#precache ("client_fx", FX_RAIN_LIGHT);
#precache ("client_fx", FX_RAIN_REGULAR);
#precache ("client_fx", FX_RAIN_HEAVY);

#namespace zm_weather_rain_drops_fx;

class RainDropsFx {
    var raining;
    var intensity;
}

function init() 
{
    clientfield::register("world", FX_RAIN_CF_NAME, VERSION_SHIP, 2, "int", &fx_rain, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT);

    level.weather.rain.drops_fx = new RainDropsFx();
    level.weather.rain.drops_fx.raining = false;
    level.weather.rain.drops_fx.intensity = RAIN_INTENSITY_OFF;
}

function private ensure_players_fx_state()
{
    util::waitforallclients();
    players = GetLocalPlayers();

    for(i = 0; i < players.size; i++)
    {
        if (!isdefined(players[i].rain_fx_tag))
        {
            players[i].rain_fx_tag = Spawn(i, players[i].origin, "script_model");
            players[i].rain_fx_tag SetModel("tag_origin");

            players[i] thread rain_player(i);
        }
    }
}

function private fx_rain(local_client_number, old_intensity, new_intensity, _bNewEnt, _bInitialSnap, _fieldName, _bWasTimeJump)
{
    // self == world
    if(new_intensity != RAIN_INTENSITY_OFF)
    {
        level._effect[FX_RAIN_LEVEL_NAME] = FX_RAIN_LEVELS[new_intensity];
    }
    level.weather.rain.drops_fx.intensity = new_intensity;

    ensure_players_fx_state();
}

function private rain_player(local_client_number)
{
    // self == player
    self endon("disconnect");
    self endon("entityshutdown");

    intensity = level.weather.rain.drops_fx.intensity;
    while(true)
    {
        old_intensity = intensity;
        intensity = level.weather.rain.drops_fx.intensity;

        WAIT_CLIENT_FRAME;
        if(intensity == RAIN_INTENSITY_OFF)
        {
            if(!isdefined(self.rain_fx))
            {
                continue;
            }

            DeleteFX(local_client_number, self.rain_fx);
            self.rain_fx = undefined;
            continue;
        }

        if(!isdefined(self.rain_fx) || intensity != old_intensity)
        {
            old_fx = self.rain_fx;
            self.rain_fx = PlayFxOnTag(local_client_number, level._effect[FX_RAIN_LEVEL_NAME], self.rain_fx_tag, "tag_origin");

            SetFXIgnorePause(local_client_number, self.rain_fx, true);
            SetFXOutdoor(local_client_number , self.rain_fx);

            if (isdefined(old_fx))
            {
                wait 1; // Rain fading transition
                DeleteFX(local_client_number, old_fx);
            }
        }

        self.rain_fx_tag.origin = self.origin;
    }
}
