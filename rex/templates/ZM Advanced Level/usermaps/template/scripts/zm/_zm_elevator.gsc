#using scripts\zm\_zm_unitrigger; 
#using scripts\shared\system_shared; 
#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\compass;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\_zm_utility.gsh;

#using scripts\zm\_load;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_zonemgr;

#using scripts\shared\ai\zombie_utility;
#using scripts\shared\animation_shared;
#using scripts\shared\ai\systems\blackboard;
#using scripts\shared\ai\blackboard_vehicle;
#using scripts\shared\vehicle_shared;
#using scripts\zm\_zm_blockers;
#using scripts\zm\_zm_score;

#precache( "triggerstring", "ELEVATOR_RECHARGING");
#precache( "triggerstring", "USE_ELEVATOR");
#precache( "triggerstring", "ELEVATOR_IN_USE");
#precache( "triggerstring", "CALL_ELEVATOR");

#using_animtree( "generic" );

#namespace zm_elevator;

REGISTER_SYSTEM_EX("zm_elevator", &elevator_init, &elevator_main, undefined)

function elevator_init()
{
	level flag::init("elevator_in_use");
	level flag::init("elevator_at_bottom");
	level flag::init("elevator_cooldown");
	level flag::init("elevator_door_closed");
	level flag::set("elevator_door_closed");
}

function elevator_main()
{

	n_width = 64;
	n_height = 128;
	n_length = 64;
	z_elevator = struct::get_array("s_elevator_trigger", "targetname");
	foreach(s_org in z_elevator)
	{
		s_org.script_unitrigger_type = "unitrigger_box_use";
		s_org.cursor_hint = "HINT_NOICON";
		s_org.script_width = n_width;
		s_org.script_height = n_height;
		s_org.script_length = n_length;
		s_org.require_look_at = 1;
		s_org.prompt_and_visibility_func = &elevator_playertrigger;
		zm_unitrigger::register_static_unitrigger(s_org, &elevator_trigger);
	}
	z_elevator = struct::get_array("s_elevator_call_trigger", "targetname");
	foreach(s_org in z_elevator)
	{
		s_org.script_unitrigger_type = "unitrigger_box_use";
		s_org.cursor_hint = "HINT_NOICON";
		s_org.script_width = n_width;
		s_org.script_height = n_height;
		s_org.script_length = n_length;
		s_org.require_look_at = 1;
		if(s_org.script_noteworthy == "bottom")
		{
			s_org.elevator_at_bottom = 1;
		}
		else
		{
			s_org.elevator_at_bottom = 0;
		}
		s_org.prompt_and_visibility_func = &elevator_playercalltrigger;
		zm_unitrigger::register_static_unitrigger(s_org, &elevator_calltrigger);
	}
	e_elevator = getent("zombie_elevator", "targetname");
	e_elevator setmovingplatformenabled(1);
	elevator_lights = getentarray("elevator_panel_lights", "script_noteworthy");
	foreach(e_light in elevator_lights)
	{
		e_light linkto(e_elevator);
	}
	exploder::exploder("ex_elevator_panel_green");
	exploder::exploder("ex_elevator_switch_top_red");
	exploder::exploder("ex_elevator_switch_bottom_green");
	exploder::exploder("ex_elevator_overlight");
	exploder::exploder("ex_elevator_repaired");
	elevator_door();
}

function elevator_playertrigger(player)
{
	if(level flag::get("elevator_in_use"))
	{
		self sethintstring("");
		return false;
	}
	if(level flag::get("elevator_cooldown"))
	{
		self sethintstring(&"ZM_ELEVATOR_RECHARGING");
		return true;
	}
	self sethintstring(&"ZM_USE_ELEVATOR");
	return true;
}

function elevator_playercalltrigger(player)
{
	if(level flag::get("elevator_in_use"))
	{
		self sethintstring(&"ZM_ELEVATOR_IN_USE");
		return false;
	}
	if(level flag::get("elevator_cooldown"))
	{
		self sethintstring(&"ZM_ELEVATOR_RECHARGING");
		return true;
	}
	if(self.stub.elevator_at_bottom != level flag::get("elevator_at_bottom"))
	{
		self sethintstring(&"ZM_CALL_ELEVATOR");
		return true;
	}
	self sethintstring("");
	return false;
}

function elevator_trigger()
{
	while(true)
	{
		self waittill("trigger", player);
		if(player zm_utility::in_revive_trigger())
		{
			continue;
		}
		if(player.is_drinking > 0)
		{
			continue;
		}
		if(!zm_utility::is_player_valid(player))
		{
			continue;
		}
		if(level flag::get("elevator_in_use") || level flag::get("elevator_cooldown"))
		{
			continue;
		}
		if(self.stub.elevator_at_bottom != level flag::get("elevator_at_bottom"))
		{
			level thread elevator_start(self, player);
		}
	}
}

function elevator_calltrigger()
{
	while(true)
	{
		self waittill("trigger", player);
		if(player zm_utility::in_revive_trigger())
		{
			continue;
		}
		if(player.is_drinking > 0)
		{
			continue;
		}
		if(!zm_utility::is_player_valid(player))
		{
			continue;
		}
		if(level flag::get("elevator_in_use") || level flag::get("elevator_cooldown"))
		{
			continue;
		}
		if(self.stub.elevator_at_bottom != level flag::get("elevator_at_bottom"))
		{
			level thread elevator_start(self, player);
		}
	}
}

function elevator_door(b_open = 1)
{
	if(level flag::get("elevator_at_bottom"))
	{
		e_door_left = getent("zombie_elevator_door_bottom_left", "targetname");
		e_door_right = getent("zombie_elevator_door_bottom_right", "targetname"); 
		b_door_left = getent("zombie_elevator_door_inner_top_left", "targetname");
		b_door_right = getent("zombie_elevator_door_inner_top_right", "targetname");
		elevator_node = getnodearray("elevator_bottom_begin_node", "targetname");
	}
	else
	{
		e_door_left = getent("zombie_elevator_door_top_left", "targetname");
		e_door_right = getent("zombie_elevator_door_top_right", "targetname");
		b_door_left = getent("zombie_elevator_door_inner_top_left", "targetname");
		b_door_right = getent("zombie_elevator_door_inner_top_right", "targetname");
		elevator_node = getnodearray("elevator_top_begin_node", "targetname");
	}
	if(isdefined(b_open) && b_open)
	{
		e_door_left notsolid();
		e_door_right notsolid();
		b_door_left notsolid();
		b_door_right notsolid();
		e_door_left connectpaths();
		e_door_right connectpaths();
		b_door_left connectpaths();
		b_door_right connectpaths();
		foreach(elevator_traversal in elevator_node)
		{
			linktraversal(elevator_traversal);
		}
		e_door_left movey(-40, 1);
		e_door_right movey(40, 1);
		b_door_left movey(-40, 1);
		b_door_right movey(40, 1);
		b_door_left playsound("zmb_elevator_door_open");
		level flag::clear("elevator_door_closed");
	}
	else
	{
		foreach(elevator_traversal in elevator_node)
		{
			unlinktraversal(elevator_traversal);
		}
		e_door_left solid();
		e_door_right solid();
		b_door_left solid();
		b_door_right solid();
		e_door_left disconnectpaths();
		e_door_right disconnectpaths();
		b_door_left disconnectpaths();
		b_door_right disconnectpaths();
		e_door_left movey(40, 1);
		e_door_right movey(-40, 1);
		b_door_left movey(40, 1);
		b_door_right movey(-40, 1);
		b_door_left playsound("zmb_elevator_door_close");
		level flag::set("elevator_door_closed");
	}
	e_door_left waittill("movedone");
}

function elevator_start(trig_stub, player)
{
	level flag::set("elevator_in_use");
	exploder::exploder_stop("ex_elevator_panel_green");
	exploder::exploder_stop("ex_elevator_switch_top_green");
	exploder::exploder_stop("ex_elevator_switch_bottom_green");
	exploder::exploder("ex_elevator_panel_red");
	exploder::exploder("ex_elevator_switch_top_red");
	exploder::exploder("ex_elevator_switch_bottom_red");
	elevator_door(0);
	elevator_move();
	elevator_door();
	level flag::clear("elevator_in_use");
	level flag::set("elevator_cooldown");
	wait(5);
	level flag::clear("elevator_cooldown");
	exploder::exploder_stop("ex_elevator_panel_red");
	exploder::exploder("ex_elevator_panel_green");
	if(level flag::get("elevator_at_bottom"))
	{
		exploder::exploder_stop("ex_elevator_switch_top_red");
		exploder::exploder("ex_elevator_switch_top_green");
	}
	else
	{
		exploder::exploder_stop("ex_elevator_switch_bottom_red");
		exploder::exploder("ex_elevator_switch_bottom_green");
	}
}

function elevator_move()
{
	d_elevators = getentarray("zombie_elevator", "targetname");
	top_left_door = getent("zombie_elevator_door_inner_top_left", "targetname");
	top_left_door linkto(d_elevators[0]);
	top_right_door = getent("zombie_elevator_door_inner_top_right", "targetname");
	top_right_door linkto(d_elevators[0]);
	bottom_left_door = getent("zombie_elevator_door_inner_bottom_left", "targetname");
	bottom_left_door linkto(d_elevators[0]);
	bottom_right_door = getent("zombie_elevator_door_inner_bottom_right", "targetname");
	bottom_right_door linkto(d_elevators[0]);
	if(level flag::get("elevator_at_bottom"))
	{
		foreach(e_elevator in d_elevators)
		{
			e_elevator movez(534, 6, 2);
		}
	}
	else
	{
		foreach(e_elevator in d_elevators)
		{
			e_elevator movez(-534, 6, 2);
		}
	}
	d_elevators[0].is_moving = 1;
	d_elevators[0] playsound("zmb_elevator_start");
	d_elevators[0] playloopsound("zmb_elevator_loop");
	d_elevators[0] thread player_is_touching();
	d_elevators[0] waittill("movedone");
	d_elevators[0] thread player_is_locked_in();
	d_elevators[0].is_moving = 0;
	d_elevators[0] playsound("zmb_elevator_stop");
	d_elevators[0] stoploopsound(0.5);
	top_left_door = getent("zombie_elevator_door_inner_top_left", "targetname");
	top_left_door unlink();
	top_right_door = getent("zombie_elevator_door_inner_top_right", "targetname");
	top_right_door unlink();
	bottom_left_door = getent("zombie_elevator_door_inner_bottom_left", "targetname");
	bottom_left_door unlink();
	bottom_right_door = getent("zombie_elevator_door_inner_bottom_right", "targetname");
	bottom_right_door unlink();
	if(level flag::get("elevator_at_bottom"))
	{
		level flag::clear("elevator_at_bottom");
	}
	else
	{
		level flag::set("elevator_at_bottom");
	}
}

function player_is_touching()
{
	self endon("movedone");
	while(true)
	{
		foreach(player in level.players)
		{
			if(player istouching(self))
			{
				player.in_elevator = 1;
			}
		}
		wait(0.05);
		foreach(player in level.players)
		{
			if(player.in_elevator === 1 && (player.origin[2] > (self.origin[2] + 60) || player.origin[2] < (self.origin[2] - 20)))
			{
				player setorigin(self.origin + vectorscale((0, 0, 1), 20));
			}
		}
	}
}

function player_is_locked_in()
{
	wait(0.1);
	foreach(player in level.players)
	{
		player.in_elevator = 0;
	}
}