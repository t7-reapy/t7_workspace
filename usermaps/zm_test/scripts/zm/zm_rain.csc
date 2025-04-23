#using scripts\shared\util_shared;
#using scripts\shared\system_shared;

#using scripts\shared\clientfield_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

////////////////////////////////////
//              RAIN              //
////////////////////////////////////

#using scripts\zm\_zm_postfx_rain_drops;

#namespace zm_rain;

#insert scripts\zm\zm_rain.gsh;
#precache ("client_fx", FX_RAIN_LIGHT);
#precache ("client_fx", FX_RAIN_REGULAR);
#precache ("client_fx", FX_RAIN_HEAVY);

REGISTER_SYSTEM_EX("zm_rain", &init, &main, undefined)

function init() 
{
    level.rain_enabled = SHOULD_START_WITH_RAIN;
    level.vdIndexArray = FindVolumeDecalIndexArray("decalrain");

    clientfield::register("world", FX_RAIN_TOGGLE, VERSION_SHIP, 1, "int", &fx_rain_toggle, !CF_HOST_ONLY, !SHOULD_START_WITH_RAIN);
    clientfield::register("world", DECAL_RAIN_TOGGLE, VERSION_SHIP, 1, "int", &decal_rain_toggle, !CF_HOST_ONLY, !SHOULD_START_WITH_RAIN);

    define_rain_amount();
}

function main() 
{
    thread apply_rain_on_all_players();
}

function private fx_rain_toggle(_localClientNum, _oldVal, shouldRain, _bNewEnt, _bInitialSnap, _fieldName, _bWasTimeJump)
{
    level.rain_enabled = shouldRain;
}

function private decal_rain_toggle(_localClientNum, _oldVal, shouldRain, _bNewEnt, _bInitialSnap, _fieldName, _bWasTimeJump)
{
    if(isdefined(shouldRain) && shouldRain)
    {
        for(i=0; i < level.vdIndexArray.size; i++)
        {
            UnhideVolumeDecal(level.vdIndexArray[i]);
        }
    } else {
        for(i=0; i < level.vdIndexArray.size; i++)
        {
            HideVolumeDecal(level.vdIndexArray[i]);
        }
    }
}

function define_rain_amount()
{
    //level._effect["player_rain"] = FX_RAIN_LIGHT;
    //level._effect["player_rain"] = FX_RAIN_REGULAR;
    level._effect["player_rain"] = FX_RAIN_HEAVY;
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

    self.rain_fx_tag = Spawn(localClientNum, self.origin, "script_model");
    self.rain_fx_tag setModel("tag_origin");

    self.rain_fx = PlayFxOnTag(localClientNum, level._effect["player_rain"], self.rain_fx_tag, "tag_origin");

    SetFXIgnorePause(localClientNum, self.rain_fx, true);
    SetFXOutdoor(localClientNum , self.rain_fx);

    while(1)
    {
        waitrealtime(0.1);
        if(level.rain_enabled)
        {
            if(!isdefined(self.rain_fx))
            {
                self.rain_fx = PlayFxOnTag(localClientNum, level._effect["player_rain"], self.rain_fx_tag, "tag_origin");

                SetFXIgnorePause(localClientNum, self.rain_fx, true);
                SetFXOutdoor(localClientNum , self.rain_fx);
            }
            self.rain_fx_tag.origin = self.origin;
        } else {
            if(isdefined(self.rain_fx))
            {
                DeleteFX(localclientnum, self.rain_fx);
                self.rain_fx = undefined;
            }
        }
        
    }
}
