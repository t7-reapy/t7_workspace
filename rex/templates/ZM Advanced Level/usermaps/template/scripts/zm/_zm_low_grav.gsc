#using scripts\shared\spawner_shared; 
#using scripts\shared\trigger_shared; 
#using scripts\zm\_zm_spawner; 
#using scripts\shared\callbacks_shared;
#using scripts\codescripts\struct;
#using scripts\shared\ai\systems\gib;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\ai_shared;
#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\flagsys_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\zm\_util;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_devgui;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_timer;
#using scripts\zm\_zm_unitrigger;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_zonemgr;

#precache( "fx", "dlc1/castle/fx_plyr_screen_115_liquid" );

#namespace zm_low_grav;

function autoexec __init__sytem__()
{
	system::register("zm_low_grav", &__init__, &__main__, undefined);
}

function __init__()
{
	clientfield::register("toplayer", "player_screen_fx", 5000, 1, "int");
	clientfield::register("toplayer", "player_postfx", 5000, 1, "int");
	clientfield::register("scriptmover", "undercroft_emissives", 5000, 1, "int");
	clientfield::register("world", "snd_low_gravity_state", 5000, 2, "int");
	level._effect["low_grav_player_jump"] = "dlc1/castle/fx_plyr_115_liquid_trail";
	spawner::add_archetype_spawn_function("zombie", &zombieLowgTracker);
}

function __main__()
{
	level flag::init("low_grav_countdown");
	level flag::init("low_grav_on");

	level flag::wait_till("start_zombie_round_logic");
	level flag::init("grav_off_for_ee");
	var_4603701d = getentarray("undercroft_floater_scene", "targetname");
	level thread function_554db684();
}


function function_554db684()
{
	setdvar("wallrun_enabled", 1);
	setdvar("doublejump_enabled", 1);
	setdvar("playerEnergy_enabled", 1);
	setdvar("bg_lowGravity", 300);
	setdvar("wallRun_maxTimeMs_zm", 10000);
	setdvar("playerEnergy_maxReserve_zm", 200);
	setdvar("wallRun_peakTest_zm", 0);
	level.low_grav_trig = getent("trig_low_gravity_zone", "targetname");
	level thread function_fceff7eb();
}

function function_fceff7eb(n_duration = 50)
{
	while(true)
	{
		level flag::set("low_grav_on");
		level thread function_2f712e07();
		exploder::exploder("lgt_low_gravity_on");
		if(!(isdefined(level.var_513683a6) && level.var_513683a6))
		{
			exploder::exploder("fxexp_117");
		}
		level clientfield::set("snd_low_gravity_state", 1);
		wait(n_duration - 10);
		level function_e1998cb5();
		level flag::clear("low_grav_on");
		exploder::stop_exploder("lgt_low_gravity_on");
		level clientfield::set("snd_low_gravity_state", 0);
		level flag::wait_till_clear("grav_off_for_ee");
		wait(60);
	}
}

function function_e1998cb5()
{
	level clientfield::set("snd_low_gravity_state", 2);
	level flag::set("low_grav_countdown");
	exploder::exploder("lgt_low_gravity_flash");
	wait(7);
	exploder::stop_exploder("lgt_low_gravity_flash");
	exploder::stop_exploder("fxexp_117");
	exploder::exploder("lgt_low_gravity_flash_fast");
	wait(3);
	exploder::stop_exploder("lgt_low_gravity_flash_fast");
	level flag::clear("low_grav_countdown");
}


function lowgravity_playerhandle()
{
	self endon("death");
	self endon("disconnect");
	level flag::wait_till("low_grav_on");
	self.var_7dd18a0 = 0;
	while(true)
	{
		while(self istouching(level.low_grav_trig))
		{
			while(level flag::get("low_grav_on") && self istouching(level.low_grav_trig))
			{
				if(self.var_7dd18a0 == 0)
				{
					self allowwallrun(1);
					self allowdoublejump(1);
					self setperk("specialty_lowgravity");
					self.var_7dd18a0 = 1;
					self clientfield::set_to_player("player_screen_fx", 1);
					self thread function_573a448e();
					self clientfield::set_to_player("player_postfx", 1);
					self thread function_e997f73a();
				}
				wait(0.1);
			}
			if(self.var_7dd18a0 == 1)
			{
				self allowdoublejump(0);
				self allowwallrun(0);
				self unsetperk("specialty_lowgravity");
				self clientfield::set_to_player("player_screen_fx", 0);
				self clientfield::set_to_player("player_postfx", 0);
				self notify("hash_eb16fe00");
				self.var_7dd18a0 = 0;
			}
			wait(0.1);
		}
		wait(0.1);
	}
}

function function_e997f73a()
{
	self endon("death");
	self endon("disconnect");
	self endon("hash_eb16fe00");
	while(true)
	{
		if(self isonground() || self iswallrunning())
		{
			self setdoublejumpenergy(200);
		}
		wait(0.05);
	}
}

function function_573a448e()
{
	self endon("death");
	self endon("disconnect");
	while(self.var_7dd18a0 == 1)
	{
		self waittill("jump_begin");
		var_5ed20759 = spawn("script_model", self.origin);
		var_5ed20759 setmodel("tag_origin");
		var_5ed20759 enablelinkto();
		var_5ed20759 linkto(self, "j_spineupper");
		playfxontag(level._effect["low_grav_player_jump"], var_5ed20759, "tag_origin");
		while(!self isonground() || self iswallrunning() && level flag::get("low_grav_on"))
		{
			wait(0.5);
		}
		var_5ed20759 delete();
		wait(0.5);
	}
}


function function_2f712e07()
{
	var_4603701d = getentarray("undercroft_floater_model", "targetname");
	if(getdvarint("splitscreen_playerCount") > 2)
	{
		array::run_all(var_4603701d, &delete);
		return;
	}
	array::thread_all(var_4603701d, &function_5f2da053);
	level flag::wait_till("low_grav_countdown");
	var_3bebe64c = var_4603701d.size;
	var_d1d3b1 = 5;
	var_29be1256 = 5;
	var_2916f722 = int(var_3bebe64c / var_29be1256);
	var_398a5cc1 = var_d1d3b1 / var_29be1256;
	var_4603701d = array::randomize(var_4603701d);
	while(var_4603701d.size > 0)
	{
		for(i = 0; i < var_2916f722; i++)
		{
			var_4603701d[i] notify("hash_2f498788");
			var_4603701d = array::remove_index(var_4603701d, i);
			if(var_4603701d.size <= 1)
			{
				break;
			}
			n_rand_wait = randomfloatrange(0, 0.5);
			wait(n_rand_wait);
		}
		wait(var_398a5cc1);
	}
}

function function_5f2da053()
{
	wait(randomfloatrange(0, 1));
	switch(self.model)
	{
		case "p7_fxanim_zm_castle_undercroft_floaters_books_mod":
		{
			str_scene_name = "p7_fxanim_zm_castle_undercroft_floaters_books_bundle";
			break;
		}
		case "p7_fxanim_zm_castle_undercroft_floaters_candles_mod":
		{
			str_scene_name = "p7_fxanim_zm_castle_undercroft_floaters_candles_bundle";
			break;
		}
		case "p7_fxanim_zm_castle_undercroft_floaters_rocks_mod":
		{
			str_scene_name = "p7_fxanim_zm_castle_undercroft_floaters_rocks_bundle";
			break;
		}
		case "p7_fxanim_zm_castle_undercroft_floaters_skull_mod":
		{
			str_scene_name = "p7_fxanim_zm_castle_undercroft_floaters_skull_bundle";
			break;
		}
		case "p7_fxanim_zm_castle_undercroft_floaters_toolbox_mod":
		{
			str_scene_name = "p7_fxanim_zm_castle_undercroft_floaters_toolbox_bundle";
			break;
		}
		case "p7_fxanim_zm_castle_undercroft_floaters_urn_mod":
		{
			str_scene_name = "p7_fxanim_zm_castle_undercroft_floaters_urn_bundle";
			break;
		}
	}
	self playloopsound("zmb_low_grav_item_loop");
	self scene::play(str_scene_name + "_up", self);
	self thread scene::play(str_scene_name + "_idle", self);
	self waittill("hash_2f498788");
	self thread scene::play(str_scene_name + "_down", self);
	self stoploopsound();
}

function isEntTouchingLowg()
{
    zombie = self;
    underwaterTrigs = getEntArray("zombie_underwater_trigger", "targetname");
    gravityTrigs = getEntArray("trig_low_gravity_zone", "targetname");

    foreach( waterTrig in underwaterTrigs )
    {
        if(zombie isTouching(waterTrig)) // touching water trigger automatic LOWG
            return true;
    }

    foreach( gravTrig in gravityTrigs )
    {
        if(!(zombie isTouching(gravTrig))) // not touching grav? Skip trigger
            continue;
        // touching trig now
        
        if(level flag::get("low_grav_on") == true) // is low gravity active
            return true;
    }

    return false;
}

function zombieLowgTracker()
{
    zombie = self;
    zombie endon("death");

    while(true)
    {
        wait 0.1;
        if(zombie isEntTouchingLowg())
	        set_gravity("low");
        else
	        set_gravity("normal");
    }
}

function set_gravity(gravity)
{
	if(gravity == "low")
	{
		self.low_gravity = 1;
		if(isdefined(self.missinglegs) && self.missinglegs)
		{
			self.low_gravity_variant = randomint(level.var_4fb25bb9["crawl"]);
		}
		else
		{
			self.low_gravity_variant = randomint(level.var_4fb25bb9[self.zombie_move_speed]);
		}
	}
	else if(gravity == "normal")
	{
		self.low_gravity = 0;
	}
}

