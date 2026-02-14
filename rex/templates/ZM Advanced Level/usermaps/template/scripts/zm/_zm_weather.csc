#using scripts\codescripts\struct;
#using scripts\shared\audio_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;
#using scripts\shared\system_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#precache ("client_fx", "weather/fx_rain_player_z_heavy");
#precache ("client_fx", "dlc0/factory/fx_snow_player_os_factory");

#define WEATHER			false //"rain" "snow" false

#define RAIN_FX "weather/fx_rain_player_z_heavy"
#define SNOW_FX "dlc0/factory/fx_snow_player_os_factory"    

#namespace zm_weather;

REGISTER_SYSTEM_EX("zm_weather", &__init__, undefined, undefined)

function __init__()
{
    callback::on_spawned(&on_player_spawned);
    level._effect["player_snow"] = SNOW_FX;
    level._effect["player_rain"] = RAIN_FX;
}

function on_player_spawned(localclientnum)
{
	if(IsInt(WEATHER)){}
    else if(isdefined(WEATHER == "rain"))
	{
		self thread player_rain_thread(localclientnum);
	}
	else if(isdefined(WEATHER == "snow"))
	{
		self thread player_snow_thread(localclientnum);
	}
}

function player_rain_thread(localclientnum)
{
	self endon("disconnect");
	self endon("entityshutdown");
    
	if(!self islocalplayer() || !isdefined(self getlocalclientnumber()) || localclientnum != self getlocalclientnumber())
	{
		return;
	}
	while(true)
	{
		if(!isdefined(self))
		{
			return;
		}
		fxid = playfx(localclientnum, level._effect["player_rain"], self.origin);
		setfxoutdoor(localclientnum, fxid);
		wait(0.25);
	}
}

function player_snow_thread(localclientnum)
{
	self endon("disconnect");
	self endon("entityshutdown");
    
	if(!self islocalplayer() || !isdefined(self getlocalclientnumber()) || localclientnum != self getlocalclientnumber())
	{
		return;
	}
	while(true)
	{
		if(!isdefined(self))
		{
			return;
		}
		fxid = playfx(localclientnum, level._effect["player_snow"], self.origin);
		setfxoutdoor(localclientnum, fxid);
		wait(0.25);
	}
}
