#using scripts\shared\exploder_shared; 
#using scripts\shared\callbacks_shared; 
#using scripts\shared\clientfield_shared; 

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\weather\zm_weather_shared.gsh;
#insert scripts\zm\weather\zm_weather_thunder.gsh;

#namespace zm_weather_thunder;

class Thunder {
    var sounds;
    var exploders;
}

function init() 
{
    clientfield::register("world", THUNDER_EXPLODER_CF_NAME, VERSION_SHIP, 1, "int", &thunder_strike, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);

    callback::on_localclient_connect(&on_connect);
}

function private on_connect(local_client_number)
{
    // self == player
    level.weather.thunder = new Thunder();
    level.weather.thunder.sounds = THUNDER_SOUNDS;
    level.weather.thunder.exploders = THUNDER_EXPLODERS;
}

function private thunder_strike(localClientNum, _oldVal, shouldStrike, bNewEnt, bInitialSnap, _fieldName, _bWasTimeJump)
{
    // self == world
    if (isdefined(shouldStrike) && shouldStrike)
    {
        player = GetLocalPlayer(localClientNum);
        player thunder_strikes();
    }

}

function thunder_strikes()
{
    // self == player
    thunder = level.weather.thunder;
    thunder_sound = thunder.sounds[RandomIntRange(0, thunder.sounds.size)];
    thunder_exploder = thunder.exploders[RandomIntRange(0, thunder.exploders.size)];

    self PlaySound(self GetLocalClientNumber(), thunder_sound);
    exploder::exploder(thunder_exploder);
}
