#using scripts\shared\ai\zombie; 
#using scripts\shared\ai\zombie_utility; 
#using scripts\codescripts\struct;
#using scripts\shared\ai\zombie_death;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\hud_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_laststand;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_unitrigger;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_zonemgr;
#using scripts\shared\ai\systems\animation_state_machine_mocomp;
#using scripts\shared\ai\systems\animation_state_machine_notetracks;
#using scripts\shared\ai\systems\animation_state_machine_utility;
#using scripts\shared\ai\systems\behavior_tree_utility;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

//#precache( "fx", "zombie/fx_quest_portal_trail_zod_zmb" );
//#precache( "fx", "zombie/fx_bmode_attack_grapple_zod_zmb" );
//#precache( "fx", "zombie/fx_quest_portal_closed_zod_zmb" );

#using_animtree("generic");

#namespace zm_portals;

REGISTER_SYSTEM_EX( "zm_portal", &__init__, &__main__, undefined )

function __init__()
{
	level._effect["portal_3p"] = "zombie/fx_quest_portal_trail_zod_zmb";
	level._effect["beast_return_aoe_kill"] = "zombie/fx_bmode_attack_grapple_zod_zmb";
	level._effect["portal_shortcut_closed_base"] = "zombie/fx_quest_portal_closed_zod_zmb";
	n_bits = getminbitcountfornum(3);
	clientfield::register("toplayer", "player_stargate_fx", 1, 1, "int");
	clientfield::register("world", "portal_state_startzone", 1, n_bits, "int");
	clientfield::register("world", "portal_state_zone02", 1, n_bits, "int");
	clientfield::register("world", "portal_state_zone03", 1, n_bits, "int");
	clientfield::register("world", "portal_state_ending", 1, 1, "int");
	clientfield::register("world", "pulse_startzone_portal_top", 1, 1, "counter");
	clientfield::register("world", "pulse_startzone_portal_bottom", 1, 1, "counter");
	clientfield::register("world", "pulse_zone02_portal_top", 1, 1, "counter");
	clientfield::register("world", "pulse_zone02_portal_bottom", 1, 1, "counter");
	clientfield::register("world", "pulse_zone03_portal_top", 1, 1, "counter");
	clientfield::register("world", "pulse_zone03_portal_bottom", 1, 1, "counter");
	visionset_mgr::register_info("overlay", "zm_zod_transported", 1, 20, 15, 1, &visionset_mgr::duration_lerp_thread_per_player, 0);
}

function __main__()
{
	initzmzodbehaviorsandasm();
	level.zombie_init_done = &zod_zombie_init_done;
	setdvar("scr_zm_use_code_enemy_selection", 0);
	setdvar("tu5_zmPathDistanceCheckTolarance", 20);
	level.closest_player_override = &zod_closest_player;
	level thread update_closest_player();
	level.move_valid_poi_to_navmesh = 1;
	level.pathdist_type = 2;

	level thread spawn_portal("startzone");
	util::wait_network_frame();
	level thread spawn_portal("zone02");
	util::wait_network_frame();
	level thread spawn_portal("zone03");
}

function private initzmzodbehaviorsandasm()
{
	animationstatenetwork::registeranimationmocomp("mocomp_teleport_traversal@zombie", &teleporttraversalmocompstart, undefined, undefined);
	behaviortreenetworkutility::registerbehaviortreescriptapi("zodShouldMove", &zodshouldmove);
}

function spawn_portal(str_id)
{
	width = 192;
	height = 128;
	length = 192;
	str_areaname = return_district_name_from_string(str_id);
	s_loc = function_42ed55f2(str_areaname);
	var_1693bd2 = getnodearray(str_areaname + "_portal_node", "script_noteworthy");
	foreach(var_9110bac3 in var_1693bd2)
	{
		setenablenode(var_9110bac3, 0);
	}
	s_loc.unitrigger_stub = spawnstruct();
	s_loc.unitrigger_stub.origin = s_loc.origin;
	s_loc.unitrigger_stub.angles = s_loc.angles;
	s_loc.unitrigger_stub.script_unitrigger_type = "unitrigger_box_use";
	s_loc.unitrigger_stub.cursor_hint = "HINT_NOICON";
	s_loc.unitrigger_stub.script_width = width;
	s_loc.unitrigger_stub.script_height = height;
	s_loc.unitrigger_stub.script_length = length;
	s_loc.unitrigger_stub.require_look_at = 0;
	s_loc.unitrigger_stub.str_areaname = str_areaname;
	s_loc.unitrigger_stub.prompt_and_visibility_func = &function_16fca6d;
	zm_unitrigger::register_static_unitrigger(s_loc.unitrigger_stub, &function_a90ab0d7);
}

function function_16fca6d(player)
{
	level endon("end_game");
	str_areaname = self.stub.str_areaname;
	var_8f5050e8 = level clientfield::get("portal_state_" + str_areaname);
	if(var_8f5050e8 !== 1 && (!(isdefined(player.beastmode) && player.beastmode)))
	{
		self sethintstring(&"ZM_ZOD_PORTAL_OPEN");
		b_is_invis = 0;
		level.var_ccae6720 = 1;
	}
	else
	{
		b_is_invis = 1;
		level.var_ccae6720 = 0;
	}
	self setinvisibletoplayer(player, b_is_invis);
	return !b_is_invis;
}

function function_a90ab0d7()
{
	level endon("end_game");
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
		level thread function_e0c93f92(self.stub.str_areaname);
		break;
	}
}


function function_42ed55f2(str_areaname)
{
	a_s_portal_locs = struct::get_array("teleport_effect_origin", "targetname");
	s_return_loc = undefined;
	foreach(s_portal_loc in a_s_portal_locs)
	{
		if(s_portal_loc.script_noteworthy === (str_areaname + "_portal_top"))
		{
			s_return_loc = s_portal_loc;
		}
	}
	return s_return_loc;
}

function function_e0c93f92(str_areaname)
{
	level clientfield::set("portal_state_" + str_areaname, 1);
	portal_open(str_areaname);
}

function portal_open(str_areaname, var_14429fc9 = 0)
{
	if(var_14429fc9)
	{
		level clientfield::set("portal_state_" + str_areaname, 2);
	}
	var_1693bd2 = getnodearray(str_areaname + "_portal_node", "script_noteworthy");
	foreach(var_9110bac3 in var_1693bd2)
	{
		setenablenode(var_9110bac3, 1);
	}
	a_t_portal_top = getentarray(str_areaname + "_portal_top", "script_noteworthy");
	var_ebfa395 = getentarrayfromarray(a_t_portal_top, "teleport_trigger", "targetname");
	a_t_portal_bottom = getentarray(str_areaname + "_portal_bottom", "script_noteworthy");
	var_50fc4fb = getentarrayfromarray(a_t_portal_bottom, "teleport_trigger", "targetname");
	var_ebfa395[0].e_dest = var_50fc4fb[0];
	var_50fc4fb[0].e_dest = var_ebfa395[0];
	foreach(var_9110bac3 in var_1693bd2)
	{
		var_e8b9ac31 = distancesquared(var_9110bac3.origin, var_ebfa395[0].origin);
		var_6d6d9e09 = distancesquared(var_9110bac3.origin, var_50fc4fb[0].origin);
		if(var_e8b9ac31 < var_6d6d9e09)
		{
			var_9110bac3.portal_trig = var_ebfa395[0];
			continue;
		}
		var_9110bac3.portal_trig = var_50fc4fb[0];
	}
	wait(2.5);
	var_ebfa395[0] thread portal_think();
	var_50fc4fb[0] thread portal_think();
	//IPrintLnBold("portal_think_" + str_areaname);
	//level flag::set("activate_underground"); //this is a zone
}

function return_district_name_from_string(str_input)
{
	a_str_names = array("startzone", "zone02", "zone03");
	foreach(str_name in a_str_names)
	{
		if(issubstr(str_input, str_name))
		{
			return str_name;
		}
	}
}

function portal_think()
{
	self.a_s_port_locs = struct::get_array(self.target, "targetname");
	while(true)
	{
		self waittill("trigger", e_portee);
		level clientfield::increment("pulse_" + self.script_noteworthy);
		if(isdefined(e_portee.teleporting) && e_portee.teleporting)
		{
			continue;
		}
		if(isplayer(e_portee))
		{
			if(e_portee getstance() != "prone")
			{
				playfx(level._effect["portal_3p"], e_portee.origin);
				e_portee playlocalsound("zmb_teleporter_teleport_2d");
				playsoundatposition("zmb_teleporter_teleport_out", e_portee.origin);
				self thread portal_teleport_player(e_portee);
			}
		}
	}
}

function portal_teleport_player(player, show_fx = 1)
{
	player endon("disconnect");
	player.teleporting = 1;
	player.teleport_location = player.origin;
	if(show_fx)
	{
		player clientfield::set_to_player("player_stargate_fx", 1);
	}
	n_pos = player.characterindex;
	prone_offset = vectorscale((0, 0, 1), 49);
	crouch_offset = vectorscale((0, 0, 1), 20);
	stand_offset = (0, 0, 0);
	a_ai_enemies = getaiteamarray("axis");
	a_ai_enemies = arraysort(a_ai_enemies, self.origin, 1, 99, 768);
	array::thread_all(a_ai_enemies, &ai_delay_cleanup);
	level.n_cleanup_manager_restart_time = 2 + 15;
	level.n_cleanup_manager_restart_time = level.n_cleanup_manager_restart_time + (gettime() / 1000);
	image_room = struct::get("teleport_room_" + n_pos, "targetname");
	player disableoffhandweapons();
	player disableweapons();
	player freezecontrols(1);
	util::wait_network_frame();
	if(player getstance() == "prone")
	{
		desired_origin = image_room.origin + prone_offset;
	}
	else
	{
		if(player getstance() == "crouch")
		{
			desired_origin = image_room.origin + crouch_offset;
		}
		else
		{
			desired_origin = image_room.origin + stand_offset;
		}
	}
	player.teleport_origin = spawn("script_model", player.origin);
	player.teleport_origin setmodel("tag_origin");
	player.teleport_origin.angles = player.angles;
	player playerlinktoabsolute(player.teleport_origin, "tag_origin");
	player.teleport_origin.origin = desired_origin;
	player.teleport_origin.angles = image_room.angles;
	util::wait_network_frame();
	player.teleport_origin.angles = image_room.angles;
	wait(2);
	if(show_fx)
	{
		player clientfield::set_to_player("player_stargate_fx", 0);
	}
	a_players = getplayers();
	arrayremovevalue(a_players, player);
	s_pos = array::random(self.a_s_port_locs);
	if(a_players.size > 0)
	{
		var_cefa4b63 = 0;
		while(!var_cefa4b63)
		{
			var_cefa4b63 = 1;
			s_pos = array::random(self.a_s_port_locs);
			foreach(var_3bc10d31 in a_players)
			{
				var_f2c93934 = distance(var_3bc10d31.origin, s_pos.origin);
				if(var_f2c93934 < 32)
				{
					var_cefa4b63 = 0;
				}
			}
			wait(0.05);
		}
	}
	playfx(level._effect["portal_3p"], s_pos.origin);
	player unlink();
	playsoundatposition("zmb_teleporter_teleport_in", s_pos.origin);
	if(isdefined(player.teleport_origin))
	{
		player.teleport_origin delete();
		player.teleport_origin = undefined;
	}
	player setorigin(s_pos.origin);
	player setplayerangles(s_pos.angles);
	level clientfield::increment("pulse_" + self.e_dest.script_noteworthy);

	a_ai = getaiarray();
	a_aoe_ai = arraysortclosest(a_ai, s_pos.origin, a_ai.size, 0, 260);
	foreach(ai in a_aoe_ai)
	{
		if(isactor(ai) && (!isdefined(level.ai_companion) || ai != level.ai_companion))
		{
			if(ai.archetype === "zombie")
			{
				playfx(level._effect["beast_return_aoe_kill"], ai gettagorigin("j_spineupper"));
			}
			else
			{
				playfx(level._effect["beast_return_aoe_kill"], ai.origin);
			}
			ai.has_been_damaged_by_player = 0;
			ai.deathpoints_already_given = 1;
			ai.no_powerups = 1;
			if(!(isdefined(ai.exclude_cleanup_adding_to_total) && ai.exclude_cleanup_adding_to_total))
			{
				level.zombie_total++;
				level.zombie_respawns++;
				ai.var_4d11bb60 = 1;
				if(isdefined(ai.maxhealth) && ai.health < ai.maxhealth)
				{
					if(!isdefined(level.a_zombie_respawn_health[ai.archetype]))
					{
						level.a_zombie_respawn_health[ai.archetype] = [];
					}
					if(!isdefined(level.a_zombie_respawn_health[ai.archetype]))
					{
						level.a_zombie_respawn_health[ai.archetype] = [];
					}
					else if(!isarray(level.a_zombie_respawn_health[ai.archetype]))
					{
						level.a_zombie_respawn_health[ai.archetype] = array(level.a_zombie_respawn_health[ai.archetype]);
					}
					level.a_zombie_respawn_health[ai.archetype][level.a_zombie_respawn_health[ai.archetype].size] = ai.health;
				}
				ai zombie_utility::reset_attack_spot();
			}
			switch(ai.archetype)
			{
				case "margwa":
				{
					if(isdefined(ai.canstun) && ai.canstun)
					{
						ai.reactstun = 1;
					}
					break;
				}
				case "mechz":
				{
					if(!(isdefined(ai.stun) && ai.stun) && ai.stumble_stun_cooldown_time < gettime())
					{
						ai.stun = 1;
					}
					break;
				}
				default:
				{
					ai kill();
					break;
				}
			}
		}
	}

	player enableweapons();
	player enableoffhandweapons();
	player freezecontrols(level.intermission);
	player.teleporting = 0;
	player thread zm_audio::create_and_play_dialog("portal", "travel");
}


function ai_delay_cleanup()
{
	if(!(isdefined(self.b_ignore_cleanup) && self.b_ignore_cleanup))
	{
		self notify("delay_cleanup");
		self endon("death");
		self endon("delay_cleanup");
		self.b_ignore_cleanup = 1;
		wait(10);
		self.b_ignore_cleanup = undefined;
	}
}

function portal_teleport_ai(e_portee)
{
	e_portee endon("death");
	e_portee.teleporting = 1;
	e_portee pathmode("dont move");
	playfx(level._effect["portal_3p"], e_portee.origin);
	playsoundatposition("zmb_teleporter_teleport_out", e_portee.origin);
	util::wait_network_frame();
	image_room = struct::get("teleport_room_zombies", "targetname");
	if(isactor(e_portee))
	{
		e_portee DontInterpolate();
		e_portee forceteleport(image_room.origin, image_room.angles);
	}
	else
	{
		e_portee.origin = image_room.origin;
		e_portee.angles = image_room.angles;
	}
	wait(2);
	s_port_loc = array::random(self.a_s_port_locs);
	if(IsActor(e_portee))
	{
		e_portee DontInterpolate();
		e_portee forceteleport(s_port_loc.origin, s_port_loc.angles);
	}
	else
	{
		e_portee.origin = s_port_loc.origin;
		e_portee.angles = s_port_loc.angles;
	}
	level clientfield::increment("pulse_" + self.e_dest.script_noteworthy);
	playsoundatposition("zmb_teleporter_teleport_in", s_port_loc.origin);
	playfx(level._effect["portal_3p"], s_port_loc.origin);
	wait(1);
	e_portee pathmode("move allowed");
	e_portee.teleporting = 0;
}

function teleporttraversalmocompstart(entity, mocompanim, mocompanimblendouttime, mocompanimflag, mocompduration)
{
	entity.is_teleporting = 1;
	entity orientmode("face angle", entity.angles[1]);
	entity animmode("normal");
	if(isdefined(entity.traversestartnode))
	{
		portal_trig = entity.traversestartnode.portal_trig;
		level clientfield::increment("pulse_" + portal_trig.script_noteworthy);
		portal_trig thread portal_teleport_ai(entity);
	}
}

function private zod_closest_player(origin, players)
{
	if(players.size == 0)
	{
		return undefined;
	}
	if(isdefined(self.zombie_poi))
	{
		return undefined;
	}
	if(players.size == 1)
	{
		self.last_closest_player = players[0];
		self zod_validate_last_closest_player(players);
		return self.last_closest_player;
	}
	if(!isdefined(self.last_closest_player))
	{
		self.last_closest_player = players[0];
	}
	if(!isdefined(self.need_closest_player))
	{
		self.need_closest_player = 1;
	}
	if(isdefined(level.last_closest_time) && level.last_closest_time >= level.time)
	{
		self zod_validate_last_closest_player(players);
		return self.last_closest_player;
	}
	if(isdefined(self.need_closest_player) && self.need_closest_player)
	{
		level.last_closest_time = level.time;
		self.need_closest_player = 0;
		closest = players[0];
		closest_dist = self zm_utility::approximate_path_dist(closest);
		if(!isdefined(closest_dist))
		{
			closest = undefined;
		}
		for(index = 1; index < players.size; index++)
		{
			dist = self zm_utility::approximate_path_dist(players[index]);
			if(isdefined(dist))
			{
				if(isdefined(closest_dist))
				{
					if(dist < closest_dist)
					{
						closest = players[index];
						closest_dist = dist;
					}
					continue;
				}
				closest = players[index];
				closest_dist = dist;
			}
		}
		self.last_closest_player = closest;
	}
	if(players.size > 1 && isdefined(closest))
	{
		self zm_utility::approximate_path_dist(closest);
	}
	self zod_validate_last_closest_player(players);
	return self.last_closest_player;
}

function private zod_validate_last_closest_player(players)
{
	if(isdefined(self.last_closest_player) && (isdefined(self.last_closest_player.am_i_valid) && self.last_closest_player.am_i_valid))
	{
		return;
	}
	self.need_closest_player = 1;
	foreach(player in players)
	{
		if(isdefined(player.am_i_valid) && player.am_i_valid)
		{
			self.last_closest_player = player;
			return;
		}
	}
	self.last_closest_player = undefined;
}


function zodshouldmove(entity)
{
	if(isdefined(entity.zombie_tesla_hit) && entity.zombie_tesla_hit && (!(isdefined(entity.tesla_death) && entity.tesla_death)))
	{
		return false;
	}
	if(isdefined(entity.pushed) && entity.pushed)
	{
		return false;
	}
	if(isdefined(entity.knockdown) && entity.knockdown)
	{
		return false;
	}
	if(isdefined(entity.grapple_is_fatal) && entity.grapple_is_fatal)
	{
		return false;
	}
	if(level.wait_and_revive)
	{
		return false;
	}
	if(isdefined(entity.stumble))
	{
		return false;
	}
	if(zombiebehavior::zombieshouldmeleecondition(entity))
	{
		return false;
	}
	if(isdefined(entity.interdimensional_gun_kill) && !isdefined(entity.killby_interdimensional_gun_hole))
	{
		return false;
	}
	if(entity haspath())
	{
		return true;
	}
	if(isdefined(entity.keep_moving) && entity.keep_moving)
	{
		return true;
	}
	return false;
}


function private update_closest_player()
{
	level waittill("start_of_round");
	while(true)
	{
		reset_closest_player = 1;
		zombies = zombie_utility::get_round_enemy_array();
		margwa = getaiarchetypearray("all", level.zombie_team);
		if(margwa.size)
		{
			zombies = arraycombine(zombies, margwa, 0, 0);
		}
		foreach(zombie in zombies)
		{
			if(isdefined(zombie.need_closest_player) && zombie.need_closest_player)
			{
				reset_closest_player = 0;
				break;
			}
		}
		if(reset_closest_player)
		{
			foreach(zombie in zombies)
			{
				if(isdefined(zombie.need_closest_player))
				{
					zombie.need_closest_player = 1;
				}
			}
		}
		wait(0.05);
	}
}


function zod_zombie_init_done()
{
	self pushactors(0);
}

