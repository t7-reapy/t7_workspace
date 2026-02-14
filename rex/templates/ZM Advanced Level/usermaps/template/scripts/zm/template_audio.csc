#using scripts\codescripts\struct;
#using scripts\shared\audio_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\postfx_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_load;
#using scripts\zm\_zm_utility;
#using scripts\shared\array_shared;

#insert scripts\shared\shared.gsh;

#define DEFAULT_MUSIC "mus_template_underscore_default"
#define TENSION_COOLDOWN 1000*60
#define TENSION_CHANCE 10

function init()
{
	level thread location_underscores();
	level thread tension_trigs();
}

function tension_trigs()
{
	trigs = GetEntArray(0, "trig_snd_tension", "targetname");
	level.last_tension_time = GetTime();
	foreach(trig in trigs)
	trig thread tension_trig_logic();
}

function location_underscores()
{
	level thread location_music();
	trigs = GetEntArray(0, "sndMusicTrig", "targetname");

	foreach(trig in trigs)
		trig thread location_trigger_logic(trigs);
}

function location_trigger_logic(trigs)
{
	while(1)
	{
		self waittill("trigger", trigPlayer);
		if(trigPlayer IsLocalPlayer())
		{

		if(level.location_mus != self.script_sound)
		level notify("play_location_music", self.script_sound);
	
		while(isdefined(trigPlayer) && trigPlayer IsTouching(self))
		{
			wait(0.01);
		}

		if(!trigPlayer isTouchingAnotherTrig(trigs, self))
			level notify("play_location_music", "default");
		}
		else
		{		
			wait(0.016);
		}
	}
}

function isTouchingAnotherTrig(trigs, ignoreTrig)
{
	foreach(trig in trigs)
		if(trig != ignoreTrig && self IsTouching(trig))
			return 1;
	return 0;
}

function location_trigger_logic1()
{
while(1)
	{
	self waittill("trigger", trigPlayer);
	if(trigPlayer IsLocalPlayer())
		{
		wait 0.3;
		if(level.location_mus != self.script_sound)
			level notify("play_location_music", self.script_sound);
		
		while(isdefined(trigPlayer) && trigPlayer IsTouching(self))
		{
		if(level.location_mus == DEFAULT_MUSIC)
			level notify("play_location_music", self.script_sound);
		wait(0.01);
		}
	
		level notify("play_location_music", "default");
		}
		else
		{		
		wait(0.1);
		}
	}
}

function location_music()
{
	level.current_mus = DEFAULT_MUSIC;
	level.location_mus = DEFAULT_MUSIC;
	level.mus_origin = Spawn(0, (0, 0, 0), "script_origin");
	level.mus_func = level.mus_origin PlayLoopSound(level.current_mus, 2);

	while(1)
	{
		level waittill("play_location_music", location);
		level.location_mus = "mus_template_underscore_" + location;
		if(level.location_mus != level.current_mus)
		{
			wait 0.05;
			level thread play_music(level.location_mus);
			level.current_mus = level.location_mus;
		}
	}
}

function play_music(location_mus)
{
	level endon("play_location_music");
	level.mus_origin StopAllLoopSounds(2);
	wait(1);
	level.mus_func = level.mus_origin PlayLoopSound(location_mus, 2);
}

function tension_trig_logic()
{
	while(1)
	{
		wait 0.05;
		self waittill( "trigger", player );
		if( !player IsLocalPlayer() )
			continue;

		if(GetTime() < level.last_tension_time+ TENSION_COOLDOWN )
			continue;

		if(RandomInt(100) >= TENSION_CHANCE )
			continue;

		level.last_tension_time = GetTime();
		player PlaySound(0, "stinger_eventgroup"+ RandomIntRange(1,5));
	}
}


