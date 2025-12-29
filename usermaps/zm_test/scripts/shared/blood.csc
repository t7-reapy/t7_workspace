#using scripts\codescripts\struct;

#using scripts\shared\callbacks_shared;
#using scripts\shared\math_shared; 
#using scripts\shared\util_shared;
#using scripts\shared\system_shared;
#using scripts\shared\filter_shared;

#insert scripts\shared\shared.gsh;

#namespace blood;

#define BLOOD_SPRITE_LIGHT_PASS 0
#define BLOOD_SPRITE_HEAVY_PASS 1
#define BLOOD_FRAME_PASS 2

#define BLOOD_FADE_TIME 3 // in second
	
REGISTER_SYSTEM("blood", &init, undefined)
	
function private init()
{
	callback::on_localplayer_spawned(&localplayer_spawned);
}

function private localplayer_spawned(localClientNum)
{
	if(self != GetLocalPlayer(localClientNum))
		return;

	self thread player_watch_blood_shutdown(localClientNum);
}

function private player_watch_blood_shutdown(localClientNum)
{
	self util::waittill_any("entityshutdown", "death");
	self disable_blood(localClientNum);
}

function private enable_blood(localClientNum)
{
	filter::init_filter_feedback_blood(localClientNum, false);
	filter::enable_filter_feedback_blood(localClientNum, FILTER_INDEX_BLOOD, BLOOD_FRAME_PASS, false);
	filter::set_filter_feedback_blood_sundir(localClientNum, FILTER_INDEX_BLOOD, BLOOD_FRAME_PASS, 65, 32);
}

function private disable_blood(localClientNum)
{
	filter::disable_filter_feedback_blood(localClientNum, FILTER_INDEX_BLOOD, BLOOD_FRAME_PASS);
}

function private lerp( start_time, end_time )
{
	if((end_time - start_time) <= 0)
		return 0;
	
	now = self GetClientTime();
	frac = float(end_time - now) / float(end_time - start_time);

	return math::clamp(frac, 0, 1);
}

function player_apply_blood(localClientNum) // self == player client
{
	self notify("blood_sprite_splash");
	self endon("blood_sprite_splash");
	self endon("disconnect");
	self endon("entityshutdown");
	self endon("death");
	self endon("killBloodOverlay");

	// renderHealthOverlay(localClientNum);
	// renderhealthoverlayhealth(localClientNum);

	self enable_blood(localClientNum);
	filter::set_filter_feedback_blood_vignette(localClientNum, FILTER_INDEX_BLOOD, BLOOD_FRAME_PASS, 1);
	filter::set_filter_feedback_blood_opacity(localClientNum, FILTER_INDEX_BLOOD, BLOOD_FRAME_PASS, 1);

	// Let the blood sit for a bit >:)
	waitrealtime(2);

	start_time = self GetClientTime();
	end_time = start_time + int(BLOOD_FADE_TIME * 1000);
	val = 1.0;

	while (val > 0)
	{
		filter::set_filter_feedback_blood_vignette(localClientNum, FILTER_INDEX_BLOOD, BLOOD_FRAME_PASS, val);
		filter::set_filter_feedback_blood_opacity(localClientNum, FILTER_INDEX_BLOOD, BLOOD_FRAME_PASS, val);
		val = self lerp(start_time, end_time);
		WAIT_CLIENT_FRAME;
	}
    
	filter::set_filter_feedback_blood_vignette(localClientNum, FILTER_INDEX_BLOOD, BLOOD_FRAME_PASS, 0);
	filter::set_filter_feedback_blood_opacity(localClientNum, FILTER_INDEX_BLOOD, BLOOD_FRAME_PASS, 0);
	self disable_blood(localClientNum);
}
