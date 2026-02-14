#using scripts\zm\_zm_zonemgr; 
#using scripts\codescripts\struct;
#using scripts\shared\ai\mechz;
#using scripts\shared\ai\systems\animation_state_machine_mocomp;
#using scripts\shared\ai\systems\behavior_tree_utility;
#using scripts\shared\ai\systems\blackboard;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\ai_shared;
#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\zm\_zm;
#using scripts\zm\_zm_ai_mechz;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weap_idgun;
#using scripts\zm\_zm_portals;

#namespace template_mechz;

function autoexec init()
{
	function_24ed806f();
	level flag::init("can_spawn_mechz", 1);
	spawner::add_archetype_spawn_function("mechz", &function_d8d01032);
	spawner::add_archetype_spawn_function("mechz", &function_b7e11612);
	level thread function_76e7495b();
	level.mechz_should_stun_override = &function_f517cdd6;
	level.var_7f2a926d = &mechz_health_increases;
	level.mechz_damage_override = &mechz_damage_override;
	level.mechz_faceplate_damage_override = &function_bddef31c;
	level.var_7d2a391d = &spawn_effect;
	if(ai::shouldregisterclientfieldforarchetype("mechz"))
	{
		clientfield::register("actor", "death_ray_shock_fx", 15000, 1, "int");
	}
	clientfield::register("actor", "mechz_fx_spawn", 15000, 1, "counter");
}

function private function_24ed806f()
{
	behaviortreenetworkutility::registerbehaviortreescriptapi("castleMechzTrapService", &function_b25360f);
	behaviortreenetworkutility::registerbehaviortreescriptapi("genesisVortexService", &function_8746ceea);
	behaviortreenetworkutility::registerbehaviortreescriptapi("genesisMechzOctobombService", &function_2ffb7337);
	behaviortreenetworkutility::registerbehaviortreescriptapi("castleMechzShouldMoveToTrap", &function_beb13c4b);
	behaviortreenetworkutility::registerbehaviortreescriptapi("castleMechzIsAtTrap", &function_fc277828);
	behaviortreenetworkutility::registerbehaviortreescriptapi("castleMechzShouldAttackTrap", &function_d1cb5cbc);
	behaviortreenetworkutility::registerbehaviortreescriptapi("genesisMechzShouldOctobombAttack", &function_4e06a982);
	behaviortreenetworkutility::registerbehaviortreescriptapi("casteMechzTrapMoveTerminate", &function_4210ca29);
	behaviortreenetworkutility::registerbehaviortreescriptapi("casteMechzTrapAttackTerminate", &function_910e57ee);
	behaviortreenetworkutility::registerbehaviortreescriptapi("genesisMechzDestoryOctobomb", &function_78198ba2);
	animationstatenetwork::registeranimationmocomp("mocomp_trap_attack@mechz", &function_45f397ee, undefined, &function_9da58a6f);
	animationstatenetwork::registeranimationmocomp("mocomp_teleport_traversal@mechz", &teleporttraversalmocompstart, undefined, undefined);
}

function private function_76e7495b()
{
	wait(0.5);
	var_85129cef = getentarray("zombie_trap", "targetname");
	foreach(e_trap in var_85129cef)
	{
		if(e_trap.script_noteworthy == "electric")
		{
			level.electric_trap = e_trap;
		}
	}
}

function private function_b25360f(entity)
{
	if(isdefined(entity.var_d77404f7) && entity.var_d77404f7 || (isdefined(entity.var_72308ff2) && entity.var_72308ff2))
	{
		return true;
	}
	if(level flag::get("masher_on"))
	{
		if(entity function_d8f5da34("masher_trap_switch"))
		{
			return true;
		}
	}
	if(isdefined(level.electric_trap))
	{
		if(isdefined(level.electric_trap._trap_in_use) && level.electric_trap._trap_in_use && (!(isdefined(level.electric_trap._trap_cooling_down) && level.electric_trap._trap_cooling_down)))
		{
			if(entity function_d8f5da34("elec_trap_switch"))
			{
				return true;
			}
		}
	}
	return false;
}

function private function_604404(entity)
{
	if(isdefined(self.react))
	{
		foreach(react in self.react)
		{
			if(react == entity)
			{
				return true;
			}
		}
	}
	return false;
}

function private function_e92d3bb1(entity)
{
	if(!isdefined(self.react))
	{
		self.react = [];
	}
	self.react[self.react.size] = entity;
}

function private function_8746ceea(entity)
{
	if(!entity zm_ai_mechz::function_58655f2a())
	{
		return false;
	}
	if(isdefined(level.vortex_manager) && isdefined(level.vortex_manager.a_active_vorticies))
	{
		foreach(vortex in level.vortex_manager.a_active_vorticies)
		{
			if(!vortex function_604404(entity))
			{
				dist_sq = distancesquared(vortex.origin, self.origin);
				if(dist_sq < 9216)
				{
					entity.stun = 1;
					entity.vortex = vortex;
					if(isdefined(vortex.weapon) && idgun::function_9b7ac6a9(vortex.weapon))
					{
						blackboard::setblackboardattribute(entity, "_zombie_damageweapon_type", "packed");
					}
					vortex function_e92d3bb1(entity);
					return true;
				}
			}
		}
	}
	return false;
}

function private function_2ffb7337(entity)
{
	if(isdefined(entity.destroy_octobomb))
	{
		entity setgoal(entity.destroy_octobomb.origin);
		return true;
	}
	if(isdefined(level.octobombs))
	{
		foreach(octobomb in level.octobombs)
		{
			if(isdefined(octobomb))
			{
				dist_sq = distancesquared(octobomb.origin, self.origin);
				if(dist_sq < 360000)
				{
					entity.destroy_octobomb = octobomb;
					entity setgoal(octobomb.origin);
					return true;
				}
			}
		}
	}
	return false;
}

function private function_d8f5da34(var_2dba2212)
{
	var_3a067a8d = struct::get_array(var_2dba2212, "script_noteworthy");
	self.s_trap = undefined;
	n_closest_dist_sq = 57600;
	foreach(s_trap in var_3a067a8d)
	{
		n_dist_sq = distancesquared(s_trap.origin, self.origin);
		if(n_dist_sq < n_closest_dist_sq)
		{
			n_closest_dist_sq = n_dist_sq;
			self.s_trap = s_trap;
		}
	}
	if(isdefined(self.s_trap))
	{
		self.var_d77404f7 = 1;
		self.ignoreall = 1;
		self setgoal(self.s_trap.origin);
		self thread function_957c9419();
		return true;
	}
	return false;
}

function function_957c9419()
{
	self endon("death");
	wait(60);
	if(isdefined(self.var_d77404f7) && self.var_d77404f7 || (isdefined(self.var_72308ff2) && self.var_72308ff2) || (isdefined(self.ignoreall) && self.ignoreall))
	{
		self.var_d77404f7 = 0;
		self.var_72308ff2 = 0;
		self.ignoreall = 0;
		mechzbehavior::mechztargetservice(self);
	}
}

function function_beb13c4b(entity)
{
	if(isdefined(entity.var_d77404f7) && entity.var_d77404f7)
	{
		return true;
	}
	return false;
}

function function_fc277828(entity)
{
	if(entity isatgoal())
	{
		return true;
	}
	return false;
}

function function_d1cb5cbc(entity)
{
	if(isdefined(entity.var_72308ff2) && entity.var_72308ff2)
	{
		return true;
	}
	return false;
}

function private function_4e06a982(entity)
{
	if(!isdefined(entity.destroy_octobomb))
	{
		return false;
	}
	if(distancesquared(entity.origin, entity.destroy_octobomb.origin) > 16384)
	{
		return false;
	}
	yaw = abs(zombie_utility::getyawtospot(entity.destroy_octobomb.origin));
	if(yaw > 45)
	{
		return false;
	}
	return true;
}

function function_4210ca29(entity)
{
	entity.var_d77404f7 = 0;
	entity.var_72308ff2 = 1;
}

function function_910e57ee(entity)
{
	entity.var_72308ff2 = 0;
	entity.ignoreall = 0;
	if(isdefined(entity.s_trap))
	{
		if(entity.s_trap.script_noteworthy == "masher_trap_switch")
		{
			level flag::clear("masher_on");
		}
		else
		{
			level.electric_trap notify("trap_deactivate");
		}
	}
	mechzbehavior::mechztargetservice(entity);
}

function function_78198ba2(entity)
{
	if(isdefined(entity.destroy_octobomb))
	{
		entity.destroy_octobomb detonate();
		entity.destroy_octobomb = undefined;
	}
	mechzbehavior::mechzstopflame(entity);
}

function function_45f397ee(entity, mocompanim, mocompanimblendouttime, mocompanimflag, mocompduration)
{
	entity orientmode("face angle", entity.s_trap.angles[1]);
	entity animmode("normal");
}

function function_9da58a6f(entity, mocompanim, mocompanimblendouttime, mocompanimflag, mocompduration)
{
	entity orientmode("face default");
}

function mechz_health_increases()
{
	if(!isdefined(level.mechz_last_spawn_round) || level.round_number > level.mechz_last_spawn_round)
	{
		a_players = getplayers();
		n_player_modifier = 1;
		switch(a_players.size)
		{
			case 0:
			case 1:
			{
				n_player_modifier = 1;
				break;
			}
			case 2:
			{
				n_player_modifier = 1.33;
				break;
			}
			case 3:
			{
				n_player_modifier = 1.66;
				break;
			}
			case 4:
			{
				n_player_modifier = 2;
				break;
			}
		}
		var_485a2c2c = level.zombie_health / level.zombie_vars["zombie_health_start"];
		level.mechz_health = int(n_player_modifier * (level.mechz_base_health + (level.mechz_health_increase * var_485a2c2c)));
		level.mechz_faceplate_health = int(n_player_modifier * (level.var_fa14536d + (level.var_1a5bb9d8 * var_485a2c2c)));
		level.mechz_powercap_cover_health = int(n_player_modifier * (level.mechz_powercap_cover_health + (level.var_a1943286 * var_485a2c2c)));
		level.mechz_powercap_health = int(n_player_modifier * (level.mechz_powercap_health + (level.var_9684c99e * var_485a2c2c)));
		level.var_2cbc5b59 = int(n_player_modifier * (level.var_3f1bf221 + (level.var_158234c * var_485a2c2c)));
		level.mechz_health = function_26beb37e(level.mechz_health, 17500, n_player_modifier);
		level.mechz_faceplate_health = function_26beb37e(level.mechz_faceplate_health, 16000, n_player_modifier);
		level.mechz_powercap_cover_health = function_26beb37e(level.mechz_powercap_cover_health, 7500, n_player_modifier);
		level.mechz_powercap_health = function_26beb37e(level.mechz_powercap_health, 5000, n_player_modifier);
		level.var_2cbc5b59 = function_26beb37e(level.var_2cbc5b59, 3500, n_player_modifier);
		level.mechz_last_spawn_round = level.round_number;
	}
}

function function_26beb37e(n_value, n_limit, n_player_modifier)
{
	if(n_value >= (n_limit * n_player_modifier))
	{
		n_value = int(n_limit * n_player_modifier);
	}
	return n_value;
}

function function_d8d01032()
{
	self.idgun_damage_cb = &function_5f2149bb;
	self.var_c732138b = &function_1df1ec14;
	self.traversalspeedboost = &function_40ef38f8;
	self thread function_a2a11991();
	self thread function_b2a1b297();
	self thread function_2a26e636();
	self thread zm::update_zone_name();
	self waittill("death");
	self thread function_2a2bfc25();
	if(isdefined(self.var_9b31a70d) && self.var_9b31a70d)
	{
		level.var_638dde56--;
	}
	level notify("hash_8f65ad3d");
}

function spawn_effect()
{
	self function_1faf1646();
	util::wait_network_frame();
	self clientfield::increment("mechz_fx_spawn");
	wait(1);
	self function_ee090a93();
}

function function_b7e11612()
{
	self waittill("death");
}

function function_b2a1b297()
{
	self waittill("actor_corpse", mechz);
	wait(60);
	if(isdefined(mechz))
	{
		mechz delete();
	}
}

function function_2a26e636()
{
	self endon("death");
	while(true)
	{
		if(!isdefined(self.zone_name))
		{
			wait(0.1);
			continue;
		}
		var_225b5e15 = 1;
		var_e01c8f74 = 1;
		players = getplayers();
		foreach(player in players)
		{
			if(isdefined(player.var_5aef0317) && player.var_5aef0317 || (isdefined(player.var_a393601c) && player.var_a393601c))
			{
				var_225b5e15 = 0;
				var_e01c8f74 = 0;
				break;
				continue;
			}
			if(isdefined(player.am_i_valid) && player.am_i_valid)
			{
				if(!isdefined(player.zone_name))
				{
					var_225b5e15 = 0;
					var_e01c8f74 = 0;
					break;
				}
				if(isdefined(player.zone_name))
				{
					if(player.zone_name == "apothicon_interior_zone")
					{
						var_e01c8f74 = 0;
						continue;
					}
					var_225b5e15 = 0;
				}
			}
		}
		var_9626d5b6 = 0;
		if(self.zone_name == "apothicon_interior_zone")
		{
			var_9626d5b6 = 1;
		}
		if(var_225b5e15 && !var_9626d5b6 || (var_e01c8f74 && var_9626d5b6))
		{
			break;
		}
		wait(0.5);
	}
	self thread function_17da3db2();
}

function function_17da3db2()
{
	wait(0.05);
	if(isdefined(self))
	{
		self delete();
	}
	wait(1.1);
	//level thread spawn_boss("mechz");
}

function function_a2a11991()
{
	self endon("death");
	while(!isdefined(self.zombie_lift_override))
	{
		wait(0.05);
	}
	self.zombie_lift_override = &function_2d571578;
}

function function_2a2bfc25()
{
	self waittill("death");
	if(level flag::get("zombie_drop_powerups") && (!(isdefined(self.no_powerups) && self.no_powerups)))
	{
		a_bonus_types = array("double_points", "insta_kill", "full_ammo", "nuke");
		str_type = array::random(a_bonus_types);
		zm_powerups::specific_powerup_drop(str_type, self.origin);
	}
}

function function_f517cdd6(inflictor, attacker, damage, dflags, mod, weapon, point, dir, hitloc, offsettime, boneindex, modelindex)
{
	switch(weapon.name)
	{
		case "elemental_bow_demongate4":
		case "elemental_bow_rune_prison4":
		case "elemental_bow_wolf_howl4":
		{
			if(!(isdefined(self.var_98056717) && self.var_98056717))
			{
				self.stun = 1;
			}
			break;
		}
		case "elemental_bow_demongate":
		{
			if(isdefined(inflictor) && inflictor.classname != "rocket")
			{
				self.stun = 1;
			}
			break;
		}
	}
}

function teleporttraversalmocompstart(entity, mocompanim, mocompanimblendouttime, mocompanimflag, mocompduration)
{
	entity.is_teleporting = 1;
	entity orientmode("face angle", entity.angles[1]);
	entity animmode("normal");
	if(isdefined(entity.traversestartnode))
	{
		portal_trig = entity.traversestartnode.portal_trig;
		portal_trig thread zm_portals::portal_teleport_ai(entity);
	}
}

function function_2d571578(e_player, v_attack_source, n_push_away, n_lift_height, v_lift_offset, n_lift_speed)
{
	self endon("death");
	if(isdefined(self.in_gravity_trap) && self.in_gravity_trap && e_player.gravityspikes_state === 3)
	{
		if(isdefined(self.var_1f5fe943) && self.var_1f5fe943)
		{
			return;
		}
		self.var_bcecff1d = 1;
		self.var_1f5fe943 = 1;
		self dodamage(10, self.origin);
		self.var_ab0efcf6 = self.origin;
		self thread scene::play("cin_zm_dlc1_mechz_dth_deathray_01", self);
		self clientfield::set("sparky_beam_fx", 1);
		self clientfield::set("death_ray_shock_fx", 1);
		self playsound("zmb_talon_electrocute");
		n_start_time = gettime();
		n_total_time = 0;
		while(10 > n_total_time && e_player.gravityspikes_state === 3)
		{
			util::wait_network_frame();
			n_total_time = (gettime() - n_start_time) / 1000;
		}
		self scene::stop("cin_zm_dlc1_mechz_dth_deathray_01");
		self thread function_a0b6d6b9(self);
		self clientfield::set("sparky_beam_fx", 0);
		self clientfield::set("death_ray_shock_fx", 0);
		self.var_bcecff1d = undefined;
		while(e_player.gravityspikes_state === 3)
		{
			util::wait_network_frame();
		}
		self.var_1f5fe943 = undefined;
		self.in_gravity_trap = undefined;
	}
	else
	{
		self dodamage(10, self.origin);
		if(!(isdefined(self.stun) && self.stun))
		{
			self.stun = 1;
		}
	}
}

function function_a0b6d6b9(mechz)
{
	mechz endon("death");
	if(isdefined(mechz))
	{
		mechz scene::play("cin_zm_dlc1_mechz_dth_deathray_02", mechz);
	}
	if(isdefined(mechz) && isalive(mechz) && isdefined(mechz.var_ab0efcf6))
	{
		v_eye_pos = mechz gettagorigin("tag_eye");
		trace = bullettrace(v_eye_pos, mechz.origin, 0, mechz);
		if(trace["position"] !== mechz.origin)
		{
			point = getclosestpointonnavmesh(trace["position"], 64, 30);
			if(!isdefined(point))
			{
				point = mechz.var_ab0efcf6;
			}
			mechz forceteleport(point);
		}
	}
}

function function_5f2149bb(inflictor, attacker)
{
	var_3bb42832 = level.mechz_health;
	n_damage = (var_3bb42832 * 0.25) / 0.2;
	self dodamage(n_damage, self getcentroid(), inflictor, attacker, undefined, "MOD_PROJECTILE_SPLASH", 0, getweapon("none"));
}

function private function_1df1ec14()
{
	if(self zm_ai_mechz::function_58655f2a())
	{
		self.stun = 1;
		return true;
	}
	return false;
}

function private function_40ef38f8()
{
	traversal = self.traversal;
	speedboost = 0;
	if(traversal.abslengthtoend > 200)
	{
		speedboost = 48;
	}
	else
	{
		if(traversal.abslengthtoend > 120)
		{
			speedboost = 24;
		}
		else if(traversal.abslengthtoend > 80 || traversal.absheighttoend > 80)
		{
			speedboost = 12;
		}
	}
	return speedboost;
}

function mechz_damage_override(attacker, damage)
{
	if(isdefined(attacker.var_bbd3efb8))
	{
		damage = damage * attacker.var_bbd3efb8;
	}
	return damage;
}


function private function_1faf1646()
{
	self.candamage = 0;
	self.isfrozen = 1;
	self ghost();
	self notsolid();
	self pathmode("dont move");
}

function private function_ee090a93()
{
	self.isfrozen = 0;
	self show();
	self solid();
	wait(0.5);
	self pathmode("move allowed");
	self.candamage = 1;
}

function enable_mechz_rounds()
{
	level.var_76df55d3 = 1;
	level.var_28066209 = 0;
	level.var_f4dc2834 = 3062.5;
	level.var_c1f907b2 = 1750;
	level.var_42fd61f0 = 3500;
	level.var_42ee1b54 = level.var_42fd61f0 - level.var_c1f907b2;
	level thread mechz_round_tracker();
}

function mechz_round_tracker()
{
	level.special_mechz_round = randomintrange(2, 3);
	level.var_2f0a5661 = 0;
	while(true)
	{
		while(level.round_number < level.special_mechz_round)
		{
			level waittill("between_round_over");
		}
		if(level flag::get("dog_round") && level.dog_round_count == 1)
		{
			level.special_mechz_round++;
		}
		else if(level.special_mechz_round >= level.round_number)
		{
			function_6592b947();
		}
		level waittill("start_of_round");
	}
}

function function_6592b947()
{
	var_b29defde = function_c7730c11();
	wait(5);
	while(var_b29defde > 0)
	{
		while(!function_b1a145c4())
		{
			wait(1);
		}
		ai_mechz = function_314d744b(1);
		if(isdefined(ai_mechz))
		{
			var_b29defde--;
		}
		if(var_b29defde > 0)
		{
			wait(randomfloatrange(5, 10));
		}
	}
	level.special_mechz_round = level.round_number + randomintrange(5, 7);
	level.mechz_round_count++;
}

function function_b1a145c4()
{
	var_f52ee0b1 = zombie_utility::get_current_zombie_count() >= level.zombie_ai_limit;
	if(var_f52ee0b1 || !level flag::get("spawn_zombies") || !level flag::get("can_spawn_mechz"))
	{
		return false;
	}
	return true;
}

function function_314d744b(var_2533389a, s_loc, var_4211ee1f = 1)
{
	if(!isdefined(s_loc))
	{
		if(level.zm_loc_types["mechz_location"].size == 0)
		{
			var_79ed5347 = struct::get_array("mechz_location", "script_noteworthy");
			foreach(var_6000fab5 in var_79ed5347)
			{
				if(var_6000fab5.targetname == "zone_start_spawners")
				{
					s_loc = var_6000fab5;
				}
			}
		}
		else
		{
			s_loc = array::random(level.zm_loc_types["mechz_location"]);
		}
	}
	mechz_health_increases();
	ai_mechz = zm_ai_mechz::spawn_mechz(s_loc, var_4211ee1f);
	level.var_9618f5be = ai_mechz;
	level notify("hash_b4c3cb33");
	if(isdefined(ai_mechz))
	{
		ai_mechz.b_ignore_cleanup = 1;
	}
	if(!(isdefined(var_2533389a) && var_2533389a))
	{
		level.special_mechz_round = level.round_number + randomintrange(4, 6);
	}
	return ai_mechz;
}

function function_c7730c11()
{
	level.var_28066209++;
	if(level.players.size == 1)
	{
		if(level.var_28066209 == 1 || level.var_28066209 == 2)
		{
			return 1;
		}
		return 1;
	}
	if(level.var_28066209 == 1 || level.var_28066209 == 2)
	{
		return 1;
	}
	if(level.var_28066209 == 3 || level.var_28066209 == 4)
	{
		return 2;
	}
	return 3;
}

function function_bddef31c(inflictor, attacker, damage, dflags, mod, weapon, point, dir, hitloc, offsettime, boneindex, modelindex)
{
	if(issubstr(weapon.name, "elemental_bow"))
	{
		var_45d7f4c0 = self.health - (damage * 0.2);
		var_be912ff6 = var_45d7f4c0 / level.mechz_health;
		if(self.has_faceplate == 1 && var_be912ff6 < 0.5)
		{
			self mechzserverutils::mechz_track_faceplate_damage(self.faceplate_health + 100);
		}
	}
}

