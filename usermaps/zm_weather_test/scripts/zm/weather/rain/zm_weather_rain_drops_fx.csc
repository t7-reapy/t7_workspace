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
    var intensity;
}

function init() 
{
    clientfield::register("world", FX_RAIN_CF_NAME, VERSION_SHIP, 2, "int", &fx_rain, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);

    callback::on_localclient_connect(&on_connect);
}

function run() 
{
    thread apply_rain_on_all_players();
}

function on_connect(local_client_number)
{
    // self == player
    level.weather.rain.drops_fx = new RainDropsFx();
    level.weather.rain.drops_fx.intensity = RAIN_DEFAULT_INTENSITY;

    define_rain_amount(level.weather.rain.drops_fx.intensity);

    self thread rain_player(local_client_number);
}

function private fx_rain(_localClientNum, old_intensity, new_intensity, _bNewEnt, _bInitialSnap, _fieldName, _bWasTimeJump)
{
    if(new_intensity != RAIN_INTENSITY_DISABLE)
    {
        level._effect[FX_RAIN_LEVEL_NAME] = FX_RAIN_LEVELS[new_intensity];
    }
    level.weather.rain.drops_fx.intensity = new_intensity;
}

function define_rain_amount(intensity)
{
    if(level.weather.rain.drops_fx.intensity != RAIN_INTENSITY_DISABLE)
    {
        level._effect[FX_RAIN_LEVEL_NAME] = FX_RAIN_LEVELS[level.weather.rain.drops_fx.intensity];
    }
}

function private apply_rain_on_all_players() {
    util::waitforallclients();
    players = GetLocalPlayers();

    for(i = 0; i < players.size; i++)
    {
        players[i] thread rain_player(i);
    }
}

function private rain_player(localclientnum)
{
    self endon("disconnect");
    self endon("entityshutdown");
    
    intensity = level.weather.rain.drops_fx.intensity;
    self.rain_fx_tag = Spawn(localClientNum, self.origin, "script_model");
    self.rain_fx_tag setModel("tag_origin");

    while(true)
    {
        old_intensity = intensity;
        intensity = level.weather.rain.drops_fx.intensity;

        WAIT_CLIENT_FRAME;
        if(intensity == RAIN_INTENSITY_DISABLE)
        {
            if(!isdefined(self.rain_fx))
            {
                continue;
            }

            DeleteFX(localclientnum, self.rain_fx);
            self.rain_fx = undefined;
        }

        if(!isdefined(self.rain_fx) || intensity != old_intensity)
        {
            old_fx = self.rain_fx;
            self.rain_fx = PlayFxOnTag(localClientNum, level._effect[FX_RAIN_LEVEL_NAME], self.rain_fx_tag, "tag_origin");

            SetFXIgnorePause(localClientNum, self.rain_fx, true);
            SetFXOutdoor(localClientNum , self.rain_fx);

            if (isdefined(old_fx))
            {
                wait 1;
                DeleteFX(localclientnum, old_fx);
            }
        }

        self.rain_fx_tag.origin = self.origin;
    }
}
