#using scripts\codescripts\struct;
#using scripts\shared\aat_shared;
#using scripts\shared\ai\margwa;
#using scripts\shared\ai\systems\animation_state_machine_utility;
#using scripts\shared\ai\systems\behavior_tree_utility;
#using scripts\shared\ai\systems\blackboard;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\flagsys_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scoreevents_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm;
#using scripts\zm\_zm_ai_wasp;
#using scripts\zm\_zm_behavior;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weap_idgun;

#namespace zm_ai_margwa;

function autoexec init()
{
	function_e84ffe9c();
	level.var_785a0d1e = &function_785a0d1e;
	level flag::init("can_spawn_margwa", 1);
	level.margwa_spawners = getentarray("zombie_margwa_spawner", "script_noteworthy");
	level.margwa_locations = struct::get_array("margwa_location", "script_noteworthy");
	level thread aat::register_immunity("zm_aat_blast_furnace", "margwa", 0, 1, 1);
	level thread aat::register_immunity("zm_aat_dead_wire", "margwa", 1, 1, 1);
	level thread aat::register_immunity("zm_aat_fire_works", "margwa", 1, 1, 1);
	level thread aat::register_immunity("zm_aat_thunder_wall", "margwa", 0, 1, 1);
	level thread aat::register_immunity("zm_aat_turned", "margwa", 1, 1, 1);
	spawner::add_archetype_spawn_function("margwa", &function_17627e34);
}

function function_4092fa4d()
{
	wait(20);
	for(i = 0; i < 1; i++)
	{
		margwa_location = arraygetclosest(level.players[0].origin, level.margwa_locations);
		margwa = function_8a0708c2(margwa_location);
		wait(0.5);
	}
}

function private function_e84ffe9c()
{
	behaviortreenetworkutility::registerbehaviortreescriptapi("zmMargwaTargetService", &function_c0fb414e);
	behaviortreenetworkutility::registerbehaviortreescriptapi("zmMargwaTeleportService", &function_5d11b2dc);
	behaviortreenetworkutility::registerbehaviortreescriptapi("zmMargwaZoneService", &function_6cc20647);
	behaviortreenetworkutility::registerbehaviortreescriptapi("zmMargwaPushService", &function_fa29651d);
	behaviortreenetworkutility::registerbehaviortreescriptapi("zmMargwaOctobombService", &function_d59056ec);
	behaviortreenetworkutility::registerbehaviortreescriptapi("zmMargwaVortexService", &function_6312be59);
	behaviortreenetworkutility::registerbehaviortreescriptapi("zmMargwaShouldSmashAttack", &function_cbdc3798);
	behaviortreenetworkutility::registerbehaviortreescriptapi("zmMargwaShouldSwipeAttack", &function_ec97fb1e);
	behaviortreenetworkutility::registerbehaviortreescriptapi("zmMargwaShouldOctobombAttack", &function_f0e8cb2d);
	behaviortreenetworkutility::registerbehaviortreescriptapi("zmMargwaShouldMove", &function_1c88d468);
	behaviortreenetworkutility::registerbehaviortreeaction("zmMargwaSwipeAttackAction", &function_cd380e61, &function_edd2fa77, undefined);
	behaviortreenetworkutility::registerbehaviortreeaction("zmMargwaOctobombAttackAction", &function_9fab0124, &function_c5832338, &function_7b2a3a90);
	behaviortreenetworkutility::registerbehaviortreescriptapi("zmMargwaSmashAttackTerminate", &function_7137a16);
	behaviortreenetworkutility::registerbehaviortreescriptapi("zmMargwaSwipeAttackTerminate", &function_137093c0);
	behaviortreenetworkutility::registerbehaviortreescriptapi("zmMargwaTeleportInTerminate", &function_743b10d2);
}

function private function_c0fb414e(entity)
{
	if(isdefined(entity.ignoreall) && entity.ignoreall)
	{
		return 0;
	}
	if(isdefined(entity.isteleporting) && entity.isteleporting)
	{
		return 0;
	}
	if(isdefined(entity.destroy_octobomb))
	{
		return 0;
	}
	entity zombie_utility::run_ignore_player_handler();
	player = zm_utility::get_closest_valid_player(entity.origin, entity.ignore_player);
	entity.favoriteenemy = player;
	if(!isdefined(player) || zm_behavior::zombieshouldmoveawaycondition(entity))
	{
		zone = zm_utility::get_current_zone();
		if(isdefined(zone))
		{
			wait_locations = level.zones[zone].a_loc_types["wait_location"];
			if(isdefined(wait_locations) && wait_locations.size > 0)
			{
				return entity margwaserverutils::margwasetgoal(wait_locations[0].origin, 64, 30);
			}
		}
		entity setgoal(entity.origin);
		return 0;
	}
	return entity margwaserverutils::margwasetgoal(entity.favoriteenemy.origin, 64, 30);
}

function private function_5d11b2dc(entity)
{
	if(isdefined(entity.favoriteenemy))
	{
		if(isdefined(entity.favoriteenemy.on_train) && entity.favoriteenemy.on_train)
		{
			var_d3443466 = [[ level.o_zod_train ]]->function_3e62f527();
			if(isdefined(entity.locked_in_train) && entity.locked_in_train && (!(isdefined(var_d3443466) && var_d3443466)))
			{
				return false;
			}
		}
	}
	if(!(isdefined(entity.needteleportout) && entity.needteleportout) && (!(isdefined(entity.isteleporting) && entity.isteleporting)) && isdefined(entity.favoriteenemy))
	{
		var_1dd5ad4d = 0;
		dist_sq = distancesquared(self.favoriteenemy.origin, entity.origin);
		var_9c921a96 = 2250000;
		if(dist_sq > var_9c921a96)
		{
			if(isdefined(entity.destroy_octobomb))
			{
				var_1dd5ad4d = 0;
			}
			else
			{
				var_1dd5ad4d = 1;
			}
		}
		else if(isdefined(level.var_785a0d1e))
		{
			if(entity [[level.var_785a0d1e]]())
			{
				var_1dd5ad4d = 1;
			}
		}
		if(var_1dd5ad4d)
		{
			if(isdefined(self.favoriteenemy.zone_name))
			{
				wait_locations = level.zones[self.favoriteenemy.zone_name].a_loc_types["wait_location"];
				if(isdefined(wait_locations) && wait_locations.size > 0)
				{
					wait_locations = array::randomize(wait_locations);
					entity.needteleportout = 1;
					entity.teleportpos = wait_locations[0].origin;
					return true;
				}
			}
		}
	}
	return false;
}

function private function_6cc20647(entity)
{
	if(isdefined(entity.isteleporting) && entity.isteleporting)
	{
		return false;
	}
	if(!isdefined(entity.zone_name))
	{
		entity.zone_name = zm_utility::get_current_zone();
	}
	else
	{
		entity.previous_zone_name = entity.zone_name;
		entity.zone_name = zm_utility::get_current_zone();
	}
	return true;
}

function private function_fa29651d(entity)
{
	if(entity.zombie_move_speed == "walk")
	{
		return false;
	}
	zombies = zombie_utility::get_round_enemy_array();
	foreach(zombie in zombies)
	{
		distsq = distancesquared(entity.origin, zombie.origin);
		if(distsq < 2304)
		{
			zombie.pushed = 1;
			var_16ce8ab3 = self.origin - zombie.origin;
			var_e1fcfc7c = vectornormalize((var_16ce8ab3[0], var_16ce8ab3[1], 0));
			zombie_right = anglestoright(zombie.angles);
			zombie_right_2d = vectornormalize((zombie_right[0], zombie_right[1], 0));
			dot = vectordot(var_e1fcfc7c, zombie_right_2d);
			if(dot > 0)
			{
				zombie.push_direction = "left";
				continue;
			}
			zombie.push_direction = "right";
		}
	}
}

function private function_d59056ec(entity)
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

function function_6312be59(entity)
{
	if(!(isdefined(entity.canstun) && entity.canstun))
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
					entity.reactidgun = 1;
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

function private function_cbdc3798(entity)
{
	if(isdefined(entity.destroy_octobomb))
	{
		return 0;
	}
	if(!isdefined(entity.var_cef86da1) || entity.var_cef86da1 != 1)
	{
		return 0;
	}
	return margwabehavior::margwashouldsmashattack(entity);
}

function private function_ec97fb1e(entity)
{
	if(isdefined(entity.destroy_octobomb))
	{
		return 0;
	}
	if(!isdefined(entity.var_cef86da1) || entity.var_cef86da1 != 2)
	{
		return 0;
	}
	return margwabehavior::margwashouldswipeattack(entity);
}

function private function_f0e8cb2d(entity)
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

function private function_1c88d468(entity)
{
	if(isdefined(entity.needteleportout) && entity.needteleportout)
	{
		return false;
	}
	if(isdefined(entity.destroy_octobomb))
	{
		if(function_f0e8cb2d(entity))
		{
			return false;
		}
	}
	else
	{
		if(function_ec97fb1e(entity))
		{
			return false;
		}
		if(function_cbdc3798(entity))
		{
			return false;
		}
	}
	if(entity haspath())
	{
		return true;
	}
	return false;
}

function private function_9fab0124(entity, asmstatename)
{
	animationstatenetworkutility::requeststate(entity, asmstatename);
	if(!isdefined(entity.var_41294bba))
	{
		entity.var_41294bba = gettime() + randomintrange(3000, 4000);
	}
	return 5;
}

function private function_c5832338(entity, asmstatename)
{
	if(!isdefined(entity.destroy_octobomb))
	{
		return 4;
	}
	if(isdefined(entity.var_41294bba) && gettime() > entity.var_41294bba)
	{
		return 4;
	}
	return 5;
}

function private function_7b2a3a90(entity, asmstatename)
{
	if(isdefined(entity.destroy_octobomb))
	{
		entity.destroy_octobomb detonate();
	}
	entity.var_41294bba = undefined;
	return 4;
}

function private function_cd380e61(entity, asmstatename)
{
	animationstatenetworkutility::requeststate(entity, asmstatename);
	if(!isdefined(entity.swipe_end_time))
	{
		swipeactionast = entity astsearch(istring(asmstatename));
		swipeactionanimation = animationstatenetworkutility::searchanimationmap(entity, swipeactionast["animation"]);
		swipeactiontime = getanimlength(swipeactionanimation) * 1000;
		entity.swipe_end_time = gettime() + swipeactiontime;
	}
	margwabehavior::margwaswipeattackstart(entity);
	return 5;
}

function private function_edd2fa77(entity, asmstatename)
{
	if(isdefined(entity.swipe_end_time) && gettime() > entity.swipe_end_time)
	{
		return 4;
	}
	return 5;
}

function private function_7137a16(entity)
{
	entity.swipe_end_time = undefined;
	entity function_941cbfc5();
	margwabehavior::margwasmashattackterminate(entity);
}

function private function_137093c0(entity)
{
	entity.swipe_end_time = undefined;
	entity function_941cbfc5();
}

function private function_743b10d2(entity)
{
	margwabehavior::margwateleportinterminate(entity);
	entity.previous_zone_name = entity.zone_name;
	entity.zone_name = zm_utility::get_current_zone();
}

function private function_271a21d6()
{
	self endon("death");
	entity.waiting = 1;
	util::wait_network_frame();
	entity.waiting = 0;
}

function private function_17627e34()
{
	self.destroyheadcb = &function_1f53b1a2;
	self.bodyfallcb = &margwa_bodyfall;
	self.chop_actor_cb = &function_89e37c9b;
	self.var_a3b60c68 = &function_dbd9ba44;
	self.var_de36fc8 = &function_2aa0209c;
	self.smashattackcb = &margwa_smash_attack;
	self.lightning_chain_immune = 1;
	self.ignore_game_over_death = 1;
	self.should_turn = 1;
	self.jawanimenabled = 1;
	self.sword_kill_power = 5;
	self function_941cbfc5();
}

function private function_1f53b1a2(modelhit, attacker)
{
	if(isplayer(attacker) && (!(isdefined(self.deathpoints_already_given) && self.deathpoints_already_given)) && (!(isdefined(level.var_1f6ca9c8) && level.var_1f6ca9c8)))
	{
		attacker zm_score::player_add_points("bonus_points_powerup", 500);
	}
	right = anglestoright(self.angles);
	spawn_pos = (self.origin + anglestoright(self.angles)) + vectorscale((0, 0, 1), 128);
	var_df9f2e65 = (self.origin - anglestoright(self.angles)) + vectorscale((0, 0, 1), 128);
	loc = spawnstruct();
	loc.origin = spawn_pos;
	loc.angles = self.angles;
	self margwa_head_explosion();
	spawner_override = undefined;
	if(isdefined(level.var_39c0c115))
	{
		spawner_override = level.var_39c0c115;
	}
	zm_ai_wasp::special_wasp_spawn(1, loc, 32, 32, 1, 0, 0, spawner_override);
	if(isdefined(self.var_26f9f957))
	{
		self thread [[self.var_26f9f957]](modelhit, attacker);
	}
	if(isdefined(level.hero_power_update))
	{
		[[level.hero_power_update]](attacker, self);
	}
	loc struct::delete();
}

function private margwa_bodyfall()
{
	power_up_origin = (self.origin + vectorscale(anglestoforward(self.angles), 32)) + vectorscale((0, 0, 1), 16);
	if(isdefined(power_up_origin) && (!(isdefined(self.no_powerups) && self.no_powerups)))
	{
		var_3bd46762 = [];
		foreach(powerup in level.zombie_powerup_array)
		{
			if(powerup == "carpenter")
			{
				continue;
			}
			if(![[level.zombie_powerups[powerup].func_should_drop_with_regular_powerups]]())
			{
				continue;
			}
			var_3bd46762[var_3bd46762.size] = powerup;
		}
		var_3dc91cb3 = array::random(var_3bd46762);
		level thread zm_powerups::specific_powerup_drop(var_3dc91cb3, power_up_origin);
	}
}

function private margwa_head_explosion()
{
	players = getplayers();
	foreach(player in players)
	{
		distsq = distancesquared(self.origin, player.origin);
		if(distsq < 16384)
		{
			player clientfield::increment_to_player("margwa_head_explosion");
		}
	}
}

function function_8a0708c2(s_location)
{
	if(isdefined(level.margwa_spawners[0]))
	{
		level.margwa_spawners[0].script_forcespawn = 1;
		ai = zombie_utility::spawn_zombie(level.margwa_spawners[0], "margwa", s_location);
		ai disableaimassist();
		ai.actor_damage_func = &margwaserverutils::margwadamage;
		ai.candamage = 0;
		ai.targetname = "margwa";
		ai.holdfire = 1;
		e_player = zm_utility::get_closest_player(s_location.origin);
		v_dir = e_player.origin - s_location.origin;
		v_dir = vectornormalize(v_dir);
		v_angles = vectortoangles(v_dir);
		ai forceteleport(s_location.origin, v_angles);
		ai function_551e32b4();
		if(isdefined(level.var_7cef68dc))
		{
			ai thread function_8d578a58();
		}
		ai.ignore_round_robbin_death = 1;
		ai thread function_3d56f587();
		return ai;
	}
	return undefined;
}

function private function_3d56f587()
{
	util::wait_network_frame();
	self clientfield::increment("margwa_fx_spawn");
	wait(3);
	self function_26c35525();
	self.candamage = 1;
	self.needspawn = 1;
}

function private function_551e32b4()
{
	self.isfrozen = 1;
	self ghost();
	self notsolid();
	self pathmode("dont move");
}


function private function_26c35525()
{
	self.isfrozen = 0;
	self show();
	self solid();
	self pathmode("move allowed");
}

function private function_8d578a58()
{
	self waittill("death", attacker, mod, weapon);
	foreach(player in level.players)
	{
		if(player.am_i_valid && (!(isdefined(level.var_1f6ca9c8) && level.var_1f6ca9c8)) && (!(isdefined(self.var_2d5d7413) && self.var_2d5d7413)))
		{
			scoreevents::processscoreevent("kill_margwa", player, undefined, undefined);
		}
	}
	level notify("hash_1a2d33d7");
	[[level.var_7cef68dc]]();
}

function private function_89e37c9b(entity, inflictor, weapon)
{
	if(!(isdefined(entity.candamage) && entity.candamage))
	{
		return false;
	}
	var_ddc770da = [];
	if(isdefined(entity.head))
	{
		foreach(head in entity.head)
		{
			if(head.health > 0 && head.candamage)
			{
				var_ddc770da[var_ddc770da.size] = head;
			}
		}
	}
	if(var_ddc770da.size > 0)
	{
		view_pos = self getweaponmuzzlepoint();
		forward_view_angles = self getweaponforwarddir();
		var_d8748e76 = undefined;
		foreach(head in var_ddc770da)
		{
			head_pos = entity gettagorigin(head.tag);
			var_b01d89e6 = distancesquared(head_pos, view_pos);
			var_ca049230 = vectornormalize(head_pos - view_pos);
			if(!isdefined(var_d8748e76))
			{
				var_d8748e76 = head;
				var_e4facdff = vectordot(forward_view_angles, var_ca049230);
				continue;
			}
			dot = vectordot(forward_view_angles, var_ca049230);
			if(dot > var_e4facdff)
			{
				var_e4facdff = dot;
				var_d8748e76 = head;
			}
		}
		if(isdefined(var_d8748e76))
		{
			var_d8748e76.health = var_d8748e76.health - 1750;
			entity clientfield::increment(var_d8748e76.impactcf);
			if(var_d8748e76.health <= 0)
			{
				if(entity margwaserverutils::margwakillhead(var_d8748e76.model, self))
				{
					entity kill(self.origin, undefined, undefined, weapon);
					return true;
				}
			}
		}
	}
	return false;
}

function private function_dbd9ba44(entity, weapon)
{
	if(isdefined(entity.canstun) && entity.canstun)
	{
		entity.reactstun = 1;
	}
}

function private function_aea7f2f4()
{
	if(isdefined(self.canstun) && self.canstun)
	{
		self.reactidgun = 1;
	}
}

function private function_2aa0209c(trap)
{
	if(isdefined(self.isteleporting) && self.isteleporting || (isdefined(self.needteleportout) && self.needteleportout))
	{
		return;
	}
	self.needteleportout = 1;
	pos = self.origin + vectorscale(anglestoforward(self.angles), 200);
	var_47870bac = getclosestpointonnavmesh(pos, 64, 30);
	self.teleportpos = var_47870bac;

}


function private margwa_smash_attack()
{
	zombies = zombie_utility::get_round_enemy_array();
	foreach(zombie in zombies)
	{
		smashpos = self.origin + vectorscale(anglestoforward(self.angles), 60);
		distsq = distancesquared(smashpos, zombie.origin);
		if(distsq < 20736)
		{
			zombie.knockdown = 1;
			self function_f1358c65(zombie);
		}
	}
}


function private function_941cbfc5()
{
	r = randomintrange(0, 100);
	if(r < 40)
	{
		self.var_cef86da1 = 2;
	}
	else
	{
		self.var_cef86da1 = 1;
	}
}

function private function_f1358c65(zombie)
{
	var_16ce8ab3 = self.origin - zombie.origin;
	var_e1fcfc7c = vectornormalize((var_16ce8ab3[0], var_16ce8ab3[1], 0));
	zombie_forward = anglestoforward(zombie.angles);
	zombie_forward_2d = vectornormalize((zombie_forward[0], zombie_forward[1], 0));
	zombie_right = anglestoright(zombie.angles);
	zombie_right_2d = vectornormalize((zombie_right[0], zombie_right[1], 0));
	dot = vectordot(var_e1fcfc7c, zombie_forward_2d);
	if(dot >= 0.5)
	{
		zombie.knockdown_direction = "front";
		zombie.getup_direction = "getup_back";
	}
	else
	{
		if(dot < 0.5 && dot > -0.5)
		{
			dot = vectordot(var_e1fcfc7c, zombie_right_2d);
			if(dot > 0)
			{
				zombie.knockdown_direction = "right";
				if(math::cointoss())
				{
					zombie.getup_direction = "getup_back";
				}
				else
				{
					zombie.getup_direction = "getup_belly";
				}
			}
			else
			{
				zombie.knockdown_direction = "left";
				zombie.getup_direction = "getup_belly";
			}
		}
		else
		{
			zombie.knockdown_direction = "back";
			zombie.getup_direction = "getup_belly";
		}
	}
}

function private function_785a0d1e()
{
	if(isdefined(self.favoriteenemy))
	{
		if(!level flag::get("connect_subway_to_junction"))
		{
			if(self.favoriteenemy function_b68ea33d())
			{
				if(!self function_b68ea33d())
				{
					return true;
				}
			}
			else if(self function_b68ea33d())
			{
				return true;
			}
		}
		//if(!self zm_zod::zombie_is_target_reachable(self.favoriteenemy))
		//{
		//	return true;
		//}
	}
	return false;
}

function private function_b68ea33d()
{
	if(isdefined(self.zone_name))
	{
		foreach(zone in level.var_3b3eeb2e)
		{
			if(self.zone_name == zone)
			{
				return true;
			}
		}
	}
	return false;
}

function function_5e93cd08()
{
	level.var_67b254fb = 1;
	level.var_b383deb1 = 0;
	level thread function_4575bd06();
}

function function_4575bd06()
{
	level.var_bf361dc0 = randomintrange(1, 2);
	level.var_6e63e659 = 0;
	while(true)
	{
		while(level.round_number < level.var_bf361dc0)
		{
			level waittill("between_round_over");
		}
		function_c32a6dca();
		if(level.var_bf361dc0 == level.round_number)
		{
			function_aea74ccd();
		}
		level waittill("between_round_over");
	}
}

function function_c32a6dca()
{
	if(level.var_bf361dc0 <= 12)
	{
		if(level.var_bf361dc0 == level.n_next_raps_round)
		{
			level.var_bf361dc0 = level.var_bf361dc0 + 2;
		}
		else if(level.var_bf361dc0 == (level.n_next_raps_round + 1))
		{
			level.var_bf361dc0 = level.var_bf361dc0 + 1;
		}
	}
}

function function_aea74ccd()
{
	var_e0191376 = function_79c1b763();
	wait(5);
	while(var_e0191376 > 0)
	{
		while(!function_8303722e())
		{
			wait(1);
		}
		var_225347e1 = function_8bcb72e9(1);
		if(isdefined(var_225347e1))
		{
			var_e0191376--;
		}
		if(var_e0191376 > 0)
		{
			wait(randomfloatrange(5, 10));
		}
	}
	level.var_bf361dc0 = level.round_number + randomintrange(5, 7);
}

function function_79c1b763()
{
	level.var_b383deb1++;
	if(level.players.size == 1)
	{
		if(level.var_b383deb1 == 1 || level.var_b383deb1 == 2)
		{
			return 1;
		}
		return 1;
	}
	if(level.var_b383deb1 == 1)
	{
		return 1;
	}
	if(level.var_b383deb1 == 2 || level.var_b383deb1 == 3)
	{
		return 2;
	}
	return 3;
}

function function_8303722e()
{
	var_f52ee0b1 = zombie_utility::get_current_zombie_count() >= level.zombie_ai_limit;
	var_73d2bce8 = level.zm_loc_types["margwa_location"].size < 1;
	if(var_f52ee0b1 || var_73d2bce8 || !level flag::get("spawn_zombies") || !level flag::get("can_spawn_margwa"))
	{
		return false;
	}
	return true;
}

function function_8bcb72e9(var_8f401985, s_loc)
{
	if(!isdefined(s_loc))
	{
		if(level.zm_loc_types["margwa_location"].size == 0)
		{
			return undefined;
		}
		s_loc = array::random(level.zm_loc_types["margwa_location"]);
	}
	var_225347e1 = function_8a0708c2(s_loc);
	var_225347e1.var_26f9f957 = &function_26f9f957;
	level.var_95981590 = var_225347e1;
	level notify("hash_c484afcb");
	if(isdefined(var_225347e1))
	{
		var_225347e1.b_ignore_cleanup = 1;
		var_225347e1 thread function_8d578a58();
		n_health = (level.round_number * 100) + 100;
		var_225347e1 margwaserverutils::margwasetheadhealth(n_health);
	}
	if(!(isdefined(var_8f401985) && var_8f401985))
	{
		level.var_bf361dc0 = level.round_number + randomintrange(1, 2);
	}
	return var_225347e1;
}

function function_26f9f957(modelhit, e_attacker)
{
	if(zm_utility::is_player_valid(e_attacker))
	{
		//e_attacker thread zm_zod_vo::function_7e398d3();
	}
}
