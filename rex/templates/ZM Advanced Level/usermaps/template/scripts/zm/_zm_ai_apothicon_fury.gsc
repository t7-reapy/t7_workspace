#using scripts\zm\_zm_zonemgr; 
#using scripts\codescripts\struct;
#using scripts\shared\aat_shared;
#using scripts\shared\ai\archetype_apothicon_fury;
#using scripts\shared\ai\systems\blackboard;
#using scripts\shared\ai\zombie;
#using scripts\shared\ai\zombie_death;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\ai_shared;
#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\flagsys_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_bgb;
#using scripts\zm\_zm_laststand;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_unitrigger;
#using scripts\zm\_zm_utility;

#namespace zm_apothicon_fury;

function autoexec __init__sytem__()
{
	system::register("zm_apothicon_fury", &__init__, &__main__, undefined);
}

function __init__()
{
	spawner::add_archetype_spawn_function("apothicon_fury", &function_2c871f46);
	spawner::add_archetype_spawn_function("apothicon_fury", &function_e5e94978);
	spawner::add_archetype_spawn_function("apothicon_fury", &function_1dcdd145);
	if(ai::shouldRegisterClientFieldForArchetype("apothicon_fury"))
	{
		clientfield::register("scriptmover", "apothicon_fury_spawn_meteor", 15000, 2, "int");
	}
}

function __main__()
{
	level thread AAT::register_immunity("zm_aat_turned", "apothicon_fury", 1, 1, 1);
	level thread AAT::register_immunity("zm_aat_thunder_wall", "apothicon_fury", 1, 1, 1);
}

function function_d7808406()
{
	self waittill("death", e_attacker);
	if(isdefined(e_attacker) && isdefined(e_attacker.var_4d307aef))
	{
		e_attacker.var_4d307aef++;
	}
	if(isdefined(e_attacker) && isdefined(e_attacker.var_8b5008fe))
	{
		e_attacker.var_8b5008fe++;
	}
}

function apothicon_fury_spawner(v_origin, v_angles, var_8d71b2b8)
{
	var_33504256 = SpawnActor("spawner_zm_genesis_apothicon_fury", v_origin, v_angles, undefined, 1, 1);
	if(isdefined(var_33504256))
	{
		var_33504256 endon("death");
		var_33504256.spawn_time = GetTime();
		var_33504256.var_1cba9ac3 = 1;
		var_33504256.heroweapon_kill_power = 2;
		var_33504256.completed_emerging_into_playable_area = 1;
		var_33504256 thread function_d7808406();
		var_33504256 thread zm::update_zone_name();
		level thread zm_spawner::zombie_death_event(var_33504256);
		var_33504256 thread zm_spawner::enemy_death_detection();
		var_33504256 thread function_7ba80ea7();
		var_33504256 thread function_1be68e3f();
		var_33504256.voicePrefix = "fury";
		var_33504256.animName = "fury";
		var_33504256 thread zm_spawner::play_ambient_zombie_vocals();
		var_33504256 thread zm_audio::zmbAIVox_NotifyConvert();
		var_33504256 playsound("zmb_vocals_fury_spawn");

		if(isdefined(var_8d71b2b8) && var_8d71b2b8)
		{
			wait(1);
			var_33504256.zombie_think_done = 1;
		}
		return var_33504256;
	}
	return undefined;
}

function private function_7ba80ea7()
{
	self.is_zombie = 1;
	zombiehealth = level.zombie_health;
	if(!isdefined(zombiehealth))
	{
		zombiehealth = level.zombie_vars["zombie_health_start"];
	}
	if(level.round_number <= 20)
	{
		self.maxhealth = zombiehealth * 1.2;
	}
	else if(level.round_number <= 50)
	{
		self.maxhealth = zombiehealth * 1.5;
	}
	else
	{
		self.maxhealth = zombiehealth * 1.7;
	}
	if(!isdefined(self.maxhealth) || self.maxhealth <= 0 || self.maxhealth > 2147483647 || self.maxhealth != self.maxhealth)
	{
		self.maxhealth = zombiehealth;
	}
	self.health = Int(self.maxhealth);
}

function private function_1be68e3f()
{
	self endon("death");
	while(1)
	{
		if(isdefined(self.zone_name))
		{
			if(self.zone_name == "dark_arena_zone" || self.zone_name == "dark_arena2_zone")
			{
				if(!IsPointOnNavMesh(self.origin))
				{
					point = GetClosestPointOnNavMesh(self.origin, 256, 30);
					self ForceTeleport(point);
				}
			}
		}
		wait(0.25);
	}
}

function function_ab27e73a()
{
	self endon("death");
	if(isdefined(level.var_31c836af) && level.var_31c836af > 0)
	{
		self.health = level.var_31c836af;
	}
	while(1)
	{
		if(isdefined(level.var_2db0d4e8) && level.var_2db0d4e8)
		{

		}
		wait(0.05);
	}
}

function function_16beb600(var_8cc26a7f, var_7ab4c34a, var_535f5919, var_13d4cd83, var_3988ba7b, var_8d71b2b8)
{
	if(!isdefined(var_8d71b2b8))
	{
		var_8d71b2b8 = 0;
	}
	function_b55fb314(var_8cc26a7f, var_7ab4c34a, var_535f5919, var_13d4cd83, var_3988ba7b);
	var_165d8ccd = apothicon_fury_spawner(var_13d4cd83, var_3988ba7b, var_8d71b2b8);
	if(isdefined(var_165d8ccd))
	{
		return var_165d8ccd;
	}
}

function function_b55fb314(var_8cc26a7f, var_7ab4c34a, var_535f5919, var_13d4cd83, var_3988ba7b)
{
	var_7ae4bfa0 = var_535f5919;
	var_8a1358c0 = var_7ab4c34a[2] + var_7ae4bfa0 - var_13d4cd83[2];
	var_dfcea895 = (var_13d4cd83[0] - var_7ab4c34a[0], var_13d4cd83[1] - var_7ab4c34a[1], 0);
	var_30280c29 = var_7ab4c34a + var_dfcea895 * 0.5 + (0, 0, var_535f5919);
	var_be9b92b3 = spawn("script_model", var_7ab4c34a);
	var_be9b92b3 SetModel("tag_origin");
	var_be9b92b3 clientfield::set("apothicon_fury_spawn_meteor", 1);
	var_22077f2a = var_7ab4c34a + (0, 0, var_7ae4bfa0 * 0.5);
	var_be9b92b3.angles = VectorToAngles(var_22077f2a - var_be9b92b3.origin);
	var_be9b92b3 moveto(var_22077f2a, var_8cc26a7f / 6);
	var_be9b92b3 waittill("movedone");
	var_22077f2a = var_be9b92b3.origin + (0, 0, var_7ae4bfa0 * 0.25) + var_dfcea895 * 0.25;
	var_be9b92b3.angles = VectorToAngles(var_22077f2a - var_be9b92b3.origin);
	var_be9b92b3 moveto(var_22077f2a, var_8cc26a7f / 6);
	var_be9b92b3 waittill("movedone");
	var_22077f2a = var_30280c29;
	var_be9b92b3.angles = VectorToAngles(var_22077f2a - var_be9b92b3.origin);
	var_be9b92b3 moveto(var_30280c29, var_8cc26a7f / 6);
	var_be9b92b3 waittill("movedone");
	var_22077f2a = var_be9b92b3.origin - (0, 0, var_8a1358c0 * 0.25) + var_dfcea895 * 0.25;
	var_be9b92b3.angles = VectorToAngles(var_22077f2a - var_be9b92b3.origin);
	var_be9b92b3 moveto(var_22077f2a, var_8cc26a7f / 6);
	var_be9b92b3 waittill("movedone");
	var_22077f2a = var_13d4cd83 - (0, 0, var_8a1358c0 * 0.5);
	var_be9b92b3.angles = VectorToAngles(var_22077f2a - var_be9b92b3.origin);
	var_be9b92b3 moveto(var_22077f2a, var_8cc26a7f / 6);
	var_be9b92b3 waittill("movedone");
	var_22077f2a = var_13d4cd83;
	var_be9b92b3.angles = VectorToAngles(var_22077f2a - var_be9b92b3.origin);
	var_be9b92b3 moveto(var_13d4cd83, var_8cc26a7f / 6);
	var_be9b92b3 waittill("movedone");
	var_be9b92b3 clientfield::set("apothicon_fury_spawn_meteor", 2);
	var_be9b92b3 delete();
}

function function_2c871f46()
{
	self AAT::aat_cooldown_init();
}

function function_e5e94978()
{
	self endon("death");
	while(isalive(self))
	{
		self waittill("damage");
		if(isPlayer(self.attacker))
		{
			if(zm_spawner::player_using_hi_score_weapon(self.attacker))
			{
				str_notify = "damage";
			}
			else
			{
				str_notify = "damage_light";
			}
			if(!(isdefined(self.deathpoints_already_given) && self.deathpoints_already_given))
			{
				self.attacker zm_score::player_add_points(str_notify, self.damageMod, self.damagelocation, undefined, self.team, self.damageWeapon);
			}
			if(isdefined(level.hero_power_update))
			{
				[[level.hero_power_update]](self.attacker, self);
			}
		}
		util::wait_network_frame();
	}
}

function function_1dcdd145()
{
	self waittill("death");
	if(isPlayer(self.attacker))
	{
		if(!(isdefined(self.deathpoints_already_given) && self.deathpoints_already_given))
		{
			self.attacker zm_score::player_add_points("death", self.damageMod, self.damagelocation, undefined, self.team, self.damageWeapon);
		}
		if(isdefined(level.hero_power_update))
		{
			[[level.hero_power_update]](self.attacker, self);
		}
	}
}

function apothicon_fury_spawn()
{
	a_players = getplayers();
	e_player = get_all_valid_players();
	queryresult = positionquery_source_navigation(e_player.origin, 600, 800, 128, 20);
	if(isdefined(queryresult) && queryresult.data.size > 0)
	{
		a_spots = array::randomize(queryresult.data);
		for(i = 0; i < a_spots.size; i++)
		{
			v_origin = a_spots[i].origin;
			v_angles = get_lookat_angles(v_origin, e_player.origin);
			str_zone = zm_zonemgr::get_zone_from_position(v_origin, 1);
			if(isdefined(str_zone) && level.zones[str_zone].is_active)
			{
				apothicon_fury_spawn_meteor(v_origin);
				var_ecb2c615 = zm_apothicon_fury::apothicon_fury_spawner(v_origin, v_angles, 0);
				if(isdefined(var_ecb2c615))
				{
					level.zombie_total--;
					level.var_c4336559["apothicon_fury"]--;
					var_ecb2c615 endon("death");
					var_ecb2c615.health = level.zombie_health;
					wait(1);
					var_ecb2c615.zombie_think_done = 1;
					var_ecb2c615.heroweapon_kill_power = 2;
					var_ecb2c615 ai::set_behavior_attribute("move_speed", "run");
					var_ecb2c615 thread zombie_utility::round_spawn_failsafe();
					return var_ecb2c615;
				}
			}
		}
	}
	return undefined;
}

function get_all_valid_players()
{
	a_players = getplayers();
	var_b474403b = 9999999;
	var_6c9f55e = a_players[0];
	for(i = 0; i < a_players.size; i++)
	{
		e_player = a_players[i];
		if(!isdefined(e_player.var_ddcf1ca1))
		{
			e_player.var_ddcf1ca1 = 0;
		}
		if(e_player.var_ddcf1ca1 < var_b474403b)
		{
			var_6c9f55e = e_player;
			var_b474403b = e_player.var_ddcf1ca1;
		}
	}
	var_6c9f55e.var_ddcf1ca1++;
	return var_6c9f55e;
}


function apothicon_fury_spawn_meteor(v_spawn_pos)
{
	v_start_pos = (v_spawn_pos[0], v_spawn_pos[1], v_spawn_pos[2] + 1000);
	var_2c69e810 = spawn("script_model", v_spawn_pos);
	var_2c69e810 setmodel("tag_origin");
	playfxontag(level._effect["fury_ground_tell_fx"], var_2c69e810, "tag_origin");
	var_3dd66385 = spawn("script_model", v_start_pos);
	var_3dd66385 setmodel("tag_origin");
	util::wait_network_frame();
	var_3dd66385 clientfield::set("apothicon_fury_spawn_meteor", 1);
	var_3dd66385 moveto(v_spawn_pos, 1.5);
	var_3dd66385 waittill("movedone");
	var_3dd66385 delete();
	var_2c69e810 delete();
}

function get_lookat_angles(v_start, v_end)
{
	v_dir = v_end - v_start;
	v_dir = vectornormalize(v_dir);
	v_angles = vectortoangles(v_dir);
	return v_angles;
}

function private function_744725d0(cmd)
{
	if(cmd == "apothicon_fury_spawn")
	{
		queryResult = PositionQuery_Source_Navigation(level.players[0].origin, 128, 256, 128, 20);
		if(isdefined(queryResult) && queryResult.data.size > 0)
		{
			origin = queryResult.data[0].origin;
			angles = level.players[0].angles;
			level thread apothicon_fury_spawner(origin, angles, 1);
		}
	}
	else if(cmd == "apothicon_fury_walk")
	{
		ais = GetAIArchetypeArray("apothicon_fury");
		foreach(ai in ais)
		{
			ai ai::set_behavior_attribute("move_speed", "walk");
		}
	}
	else if(cmd == "apothicon_fury_sprint")
	{
		ais = GetAIArchetypeArray("apothicon_fury");
		foreach(ai in ais)
		{
			ai ai::set_behavior_attribute("move_speed", "sprint");
		}
	}
	else if(cmd == "apothicon_fury_run")
	{
		ais = GetAIArchetypeArray("apothicon_fury");
		foreach(ai in ais)
		{
			ai ai::set_behavior_attribute("move_speed", "run");
		}
	}
	else if(cmd == "apothicon_fury_disable_bamf")
	{
		ais = GetAIArchetypeArray("apothicon_fury");
		foreach(ai in ais)
		{
			ai ai::set_behavior_attribute("can_bamf", 0);
			ai ai::set_behavior_attribute("can_juke", 0);
		}
	}
	else if(cmd == "apothicon_fury_force_furious")
	{
		ais = GetAIArchetypeArray("apothicon_fury");
		foreach(ai in ais)
		{
			if(!(isdefined(ai.isFurious) && ai.isFurious))
			{
				apothiconFuryBehavior::apothiconFuriousModeInit(ai);
			}
		}
	}
	else if(cmd == "apothicon_fury_debug_health")
	{
		if(isdefined(level.var_2db0d4e8) && level.var_2db0d4e8)
		{
			level.var_2db0d4e8 = 0;
		}
		else
		{
			level.var_2db0d4e8 = 1;
		}
	}
	if(GetDvarInt("zombie_apothicon_health") > 0)
	{
		level.var_31c836af = GetDvarInt("zombie_apothicon_health");
	}
	else
	{
		level.var_31c836af = 0;
	}
	if(GetDvarInt("zombie_apothicon_juke_min") > 0)
	{
		level.nextjukeMeleeTimeMin = GetDvarFloat("zombie_apothicon_juke_min") * 1000;
	}
	else
	{
		level.nextjukeMeleeTimeMin = undefined;
	}
	if(GetDvarInt("zombie_apothicon_juke_max") > 0)
	{
		level.nextjukeMeleeTimeMax = GetDvarFloat("zombie_apothicon_juke_max") * 1000;
	}
	else
	{
		level.nextjukeMeleeTimeMax = undefined;
	}
	if(GetDvarInt("zombie_apothicon_bamf_min") > 0)
	{
		level.nextBamfMeleeTimeMin = GetDvarFloat("zombie_apothicon_bamf_min") * 1000;
	}
	else
	{
		level.nextBamfMeleeTimeMin = undefined;
	}
	if(GetDvarInt("zombie_apothicon_bamf_max") > 0)
	{
		level.nextBamfMeleeTimeMax = GetDvarFloat("zombie_apothicon_bamf_max") * 1000;
	}
	else
	{
		level.nextBamfMeleeTimeMax = undefined;
	}
}

