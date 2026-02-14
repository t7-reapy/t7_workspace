#using scripts\codescripts\struct;
#using scripts\shared\aat_shared;
#using scripts\shared\ai\systems\animation_state_machine_mocomp;
#using scripts\shared\ai\systems\animation_state_machine_notetracks;
#using scripts\shared\ai\systems\animation_state_machine_utility;
#using scripts\shared\ai\systems\ai_interface; 
#using scripts\shared\ai\archetype_utility; 
#using scripts\shared\ai\systems\behavior_tree_utility;
#using scripts\shared\ai\systems\blackboard;
#using scripts\shared\ai\archetype_notetracks; 
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\array_shared;
#using scripts\shared\audio_shared;
#using scripts\shared\demo_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\exploder_shared;
#using scripts\zm\_zm;
#using scripts\zm\_zm_net;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_utility;
#using scripts\shared\math_shared; 
#using scripts\shared\flag_shared;
#using scripts\zm\_zm_weapons;
#using scripts\shared\ai\zombie_quad;

#namespace zm_ai_quad;

#precache( "fx", "dlc5/zmhd/fx_zombie_quad_gas_nova6" );
#precache( "fx", "dlc5/zmhd/fx_zombie_quad_trail" );
#precache( "fx", "dlc5/zmhd/fx_quad_teleport_in" );
#precache( "fx", "dlc5/zmhd/fx_quad_teleport_out" );
#precache( "fx", "dlc5/moon/fx_zombie_phasing" );

function autoexec __init__sytem__()
{
	system::register("zm_ai_quad", &__init__, undefined, undefined);
}

function __init__()
{
	init_quad_zombie_fx();
	if(!isdefined(level.ai_quad_register_overlay_override) || level.ai_quad_register_overlay_override)
	{
		register_overlay();
	}
	animationstatenetwork::registernotetrackhandlerfunction("quad_melee", &quadnotetrackmeleefire);
	behaviortreenetworkutility::registerbehaviortreescriptapi("quadDeathAction", &quaddeathaction);
	behaviortreenetworkutility::registerbehaviortreeaction("traverseWallCrawlAction", &traversewallcrawlaction, &function_7d285db1, undefined);
	behaviortreenetworkutility::registerbehaviortreescriptapi("shouldWallTraverse", &shouldwalltraverse);
	behaviortreenetworkutility::registerbehaviortreescriptapi("shouldWallCrawl", &shouldwallcrawl);
	behaviortreenetworkutility::registerbehaviortreescriptapi("traverseWallIntro", &traversewallintro);
	behaviortreenetworkutility::registerbehaviortreescriptapi("traverseWallJumpOff", &traversewalljumpoff);
	behaviortreenetworkutility::registerbehaviortreescriptapi("quadCollisionService", &quadcollisionservice);
	behaviortreenetworkutility::registerbehaviortreescriptapi("quadPhasingService", &quadphasingservice);
	behaviortreenetworkutility::registerbehaviortreescriptapi("shouldPhase", &shouldphase);
	behaviortreenetworkutility::registerbehaviortreescriptapi("phaseActionStart", &phaseactionstart);
	behaviortreenetworkutility::registerbehaviortreescriptapi("phaseActionTerminate", &phaseactionterminate);
	behaviortreenetworkutility::registerbehaviortreescriptapi("moonQuadKilledByMicrowaveGunDw", &killedbymicrowavegundw);
	behaviortreenetworkutility::registerbehaviortreescriptapi("moonQuadKilledByMicrowaveGun", &killedbymicrowavegun);
	animationstatenetwork::registeranimationmocomp("quad_wall_traversal", &quad_wall_traversal, undefined, undefined);
	animationstatenetwork::registeranimationmocomp("quad_wall_jump_off", &quad_wall_jump_off, undefined, &function_18650281);
	animationstatenetwork::registeranimationmocomp("quad_move_strict_traversal", &quad_move_strict_traversal, undefined, &function_2433815e);
	animationstatenetwork::registernotetrackhandlerfunction("phase_start", &function_51ab54f7);
	animationstatenetwork::registernotetrackhandlerfunction("phase_end", &function_428f351c);
	animationstatenetwork::registeranimationmocomp("quad_phase", &function_4e0a671e, undefined, undefined);

	level thread aat::register_immunity("zm_aat_dead_wire", "zombie_quad", 1, 1, 1);
	level thread aat::register_immunity("zm_aat_turned", "zombie_quad", 1, 1, 1);

	level._effect[ "quad_phasing" ] = "dlc5/moon/fx_zombie_phasing";
	level._effect[ "quad_phasing_in" ] 	= "dlc5/zmhd/fx_quad_teleport_in";
	level._effect[ "quad_phasing_out" ] = "dlc5/zmhd/fx_quad_teleport_out";
	level._effect[ "quad_explo_gas" ] = "dlc5/zmhd/fx_zombie_quad_gas_nova6";
	level._effect[ "quad_trail" ] = "dlc5/zmhd/fx_zombie_quad_trail";

	level flag::init("special_quad_round");
	level.quad_move_speed = 35;
	level.quad_traverse_death_fx = &quad_traverse_death_fx;
	level.quad_explode = 1;

	level thread quads_per_player();
}

function quads_per_player()
{
	players = level.players;
	level.quads_per_round = 4 * players.size;
}

function quad_wave_init()
{
	level thread time_for_quad_wave();
	level waittill("end_of_round");
	level flag::clear("special_quad_round");
}


function time_for_quad_wave()
{
	level waittill("between_round_over");
	if(level.next_dog_round === level.round_number)
	{
		level thread time_for_quad_wave();
		return;
	}
	max = level.zombie_vars["zombie_max_ai"];
	multiplier = level.round_number / 5;
	if(multiplier < 1)
	{
		multiplier = 1;
	}
	if(level.round_number >= 10)
	{
		multiplier = multiplier * (level.round_number * 0.15);
	}
	player_num = level.players.size;
	if(player_num == 1)
	{
		max = max + (int((0.5 * level.zombie_vars["zombie_ai_per_player"]) * multiplier));
	}
	else
	{
		max = max + (int(((player_num - 1) * level.zombie_vars["zombie_ai_per_player"]) * multiplier));
	}
	chance = 100;
	max_zombies = [[level.max_zombie_func]](max, level.round_number);
	current_round = level.round_number;
	if((level.round_number % 3) == 0 && chance >= randomint(100))
	{
		level flag::set("special_quad_round");
		while(level.zombie_total < (max_zombies / 2) && current_round == level.round_number)
		{
			wait(0.1);
		}
		level flag::clear("special_quad_round");
	}
	level thread time_for_quad_wave();
}


function traversewallcrawlaction(entity, asmstatename)
{
	animationstatenetworkutility::requeststate(entity, asmstatename);
	return 5;
}

function quad_traverse_death_fx()
{
	self endon("traverse_anim");
	self waittill("death");
	playfx(level._effect["quad_grnd_dust_spwnr"], self.origin);
}

function quadnotetrackmeleefire(entity)
{
	entity melee();
}

function function_7d285db1(entity, asmstatename)
{
	if(!shouldwallcrawl(entity))
	{
		return 4;
	}
	return 5;
}

function private function_428f351c(entity)
{
	entity thread quad_post_teleport();
	entity playSound( "zmb_quad_phase_in" );
	entity thread moon_quad_phase_fx( "quad_phasing_in" );
	entity show();
}

function private function_51ab54f7(entity)
{
	entity thread quad_pre_teleport();
	entity playSound( "zmb_quad_phase_out" );
	entity thread moon_quad_phase_fx("quad_phasing_out");
	entity ghost();
}

function shouldwalltraverse(entity)
{
	if(isdefined(entity.traversestartnode))
	{
		if(issubstr(entity.traversestartnode.animscript, "zm_wall_crawl_drop"))
		{
			return true;
		}
	}
	return false;
}

function traversewallintro(entity)
{
	entity allowpitchangle(0);
	entity.clamptonavmesh = 0;
	if(isdefined(entity.traversestartnode))
	{
		entity.var_1bb3c5d0 = entity.traversestartnode;
		entity.var_7531a5e3 = entity.traverseendnode;
		if(entity.traversestartnode.animscript == "zm_wall_crawl_drop")
		{
			blackboard::setblackboardattribute(self, "_quad_wall_crawl", "quad_wall_crawl_theater");
		}
		else
		{
			blackboard::setblackboardattribute(self, "_quad_wall_crawl", "quad_wall_crawl_start");
		}
	}
}

function private quad_move_strict_traversal(entity, mocompanim, mocompanimblendouttime, mocompanimflag, mocompduration)
{
	entity.blockingpain = 1;
	entity.usegoalanimweight = 1;
	entity animmode("noclip", 0);
	entity forceteleport(entity.traversestartnode.origin, entity.traversestartnode.angles, 0);
	entity orientmode("face angle", entity.traversestartnode.angles[1]);
}

function quadcollisionservice(behaviortreeentity)
{
	if(isdefined(behaviortreeentity.dontpushtime))
	{
		if(gettime() < behaviortreeentity.dontpushtime)
		{
			return true;
		}
	}
	zombies = getaiteamarray(level.zombie_team);
	foreach(zombie in zombies)
	{
		if(zombie == behaviortreeentity)
		{
			continue;
		}
		if(isdefined(zombie.missinglegs) && zombie.missinglegs || (isdefined(zombie.knockdown) && zombie.knockdown))
		{
			continue;
		}
		dist_sq = distancesquared(behaviortreeentity.origin, zombie.origin);
		if(dist_sq < 14400)
		{
			behaviortreeentity pushactors(0);
			behaviortreeentity.dontpushtime = gettime() + 3000;
			zombie thread function_77876867();
			return true;
		}
	}
	behaviortreeentity pushactors(1);
	return false;
}

function quad_wall_traversal(entity, mocompanim, mocompanimblendouttime, mocompanimflag, mocompduration)
{
	animdist = abs(getmovedelta(mocompanim, 0, 1)[2]);
	self.ground_pos = bullettrace(self.var_7531a5e3.origin, self.var_7531a5e3.origin + (vectorscale((0, 0, -1), 100000)), 0, self)["position"];
	physdist = abs((self.origin[2] - self.ground_pos[2]) - 60);
	cycles = physdist / animdist;
	time = cycles * getanimlength(mocompanim);
	self.var_2826ab5d = gettime() + (time * 1000);
}

function private function_2433815e(entity, mocompanim, mocompanimblendouttime, mocompanimflag, mocompduration)
{
	entity finishtraversal();
	entity.usegoalanimweight = 0;
	entity.blockingpain = 0;
}

function private function_18650281(entity, mocompanim, mocompanimblendouttime, mocompanimflag, mocompduration)
{
	entity allowpitchangle(1);
	entity.clamptonavmesh = 1;
}

function private quad_wall_jump_off(entity, mocompanim, mocompanimblendouttime, mocompanimflag, mocompduration)
{
	entity animmode("noclip", 0);
}

function moon_quad_phase_fx(var_99a8589b)
{
	self endon("death");
	if(isdefined(level._effect[var_99a8589b]))
	{
		playfxontag(level._effect[var_99a8589b], self, "j_spine4");
	}
}

function private function_4e0a671e(entity, mocompanim, mocompanimblendouttime, mocompanimflag, mocompduration)
{
	entity animmode("gravity", 0);
}

function function_77876867()
{
	self endon("death");
	self setavoidancemask("avoid all");
	wait(3);
	self setavoidancemask("avoid none");
}

function traversewalljumpoff(entity)
{
	self.var_2826ab5d = undefined;
}

function shouldwallcrawl(entity)
{
	if(isdefined(self.var_2826ab5d))
	{
		if(gettime() >= self.var_2826ab5d)
		{
			return false;
		}
	}
	return true;
}

function private quadphasingservice(entity)
{
	if(isdefined(entity.is_phasing) && entity.is_phasing)
	{
		return false;
	}
	entity.var_662afd11 = 0;
	if(entity.var_20535e44 == 0)
	{
		if(math::cointoss())
		{
			entity.var_3b07930a = "quad_phase_right";
		}
		else
		{
			entity.var_3b07930a = "quad_phase_left";
		}
	}
	else
	{
		if(entity.var_20535e44 == -1)
		{
			entity.var_3b07930a = "quad_phase_right";
		}
		else
		{
			entity.var_3b07930a = "quad_phase_left";
		}
	}
	if(entity.var_3b07930a == "quad_phase_left")
	{
		if(isplayer(entity.enemy) && entity.enemy islookingat(entity))
		{
			if(entity maymovefrompointtopoint(entity.origin, zombie_utility::getanimendpos(level.var_9fcbbc83["phase_left_long"])))
			{
				entity.var_662afd11 = 1;
			}
		}
	}
	else if(isplayer(entity.enemy) && entity.enemy islookingat(entity))
	{
		if(entity maymovefrompointtopoint(entity.origin, zombie_utility::getanimendpos(level.var_9fcbbc83["phase_right_long"])))
		{
			entity.var_662afd11 = 1;
		}
	}
	if(!(isdefined(entity.var_662afd11) && entity.var_662afd11))
	{
		if(entity maymovefrompointtopoint(entity.origin, zombie_utility::getanimendpos(level.var_9fcbbc83["phase_forward"])))
		{
			entity.var_662afd11 = 1;
			entity.var_3b07930a = "quad_phase_forward";
		}
	}
	if(isdefined(entity.var_662afd11) && entity.var_662afd11)
	{
		blackboard::setblackboardattribute(entity, "_quad_phase_direction", entity.var_3b07930a);
		if(math::cointoss())
		{
			blackboard::setblackboardattribute(entity, "_quad_phase_distance", "quad_phase_short");
		}
		else
		{
			blackboard::setblackboardattribute(entity, "_quad_phase_distance", "quad_phase_long");
		}
		return true;
	}
	return false;
}

function private shouldphase(entity)
{
	if(!(isdefined(entity.var_662afd11) && entity.var_662afd11))
	{
		return false;
	}
	if(isdefined(entity.is_phasing) && entity.is_phasing)
	{
		return false;
	}
	if((gettime() - entity.var_b7d765b3) < 2000)
	{
		return false;
	}
	if(!isdefined(entity.enemy))
	{
		return false;
	}
	dist_sq = distancesquared(entity.origin, entity.enemy.origin);
	min_dist_sq = 4096;
	max_dist_sq = 1000000;
	if(entity.var_3b07930a == "quad_phase_forward")
	{
		min_dist_sq = 14400;
		max_dist_sq = 5760000;
	}
	if(dist_sq < min_dist_sq)
	{
		return false;
	}
	if(dist_sq > max_dist_sq)
	{
		return false;
	}
	if(!isdefined(entity.pathgoalpos) || distancesquared(entity.origin, entity.pathgoalpos) < min_dist_sq)
	{
		return false;
	}
	if(abs(entity getmotionangle()) > 15)
	{
		return false;
	}
	yaw = zombie_utility::getyawtoorigin(entity.enemy.origin);
	if(abs(yaw) > 45)
	{
		return false;
	}
	return true;
}

function private phaseactionstart(entity)
{
	entity.is_phasing = 1;
	if(entity.var_3b07930a == "quad_phase_left")
	{
		entity.var_20535e44--;
	}
	else if(entity.var_3b07930a == "quad_phase_right")
	{
		entity.var_20535e44++;
	}
}

function private phaseactionterminate(entity)
{
	entity.var_b7d765b3 = gettime();
	entity.is_phasing = 0;
}

function private killedbymicrowavegundw(entity)
{
	return isdefined(entity.microwavegun_dw_death) && entity.microwavegun_dw_death;
}

function private killedbymicrowavegun(entity)
{
	return isdefined(entity.microwavegun_death) && entity.microwavegun_death;
}



function quaddeathaction(entity)
{
	if(isdefined(entity.fx_quad_trail))
	{
		entity.fx_quad_trail unlink();
		entity.fx_quad_trail delete();
	}
	if(entity.can_explode && (!(isdefined(entity.guts_explosion) && entity.guts_explosion)))
	{
		entity thread quad_gas_explo_death();
	}
	entity startragdoll();
}

function nova_crawlers_init()
{
	level.quad_spawners = getentarray("quad_zombie_spawner", "script_noteworthy");
	array::thread_all(level.quad_spawners, &spawner::add_spawn_function, &quad_prespawn);
	zm::register_custom_ai_spawn_check("quads", &quad_spawn_check, &get_quad_spawners);
}

function register_overlay()
{
	if(!isdefined(level.vsmgr_prio_overlay_zm_ai_quad_blur))
	{
		level.vsmgr_prio_overlay_zm_ai_quad_blur = 50;
	}
	visionset_mgr::register_info("overlay", "zm_ai_quad_blur", 1, level.vsmgr_prio_overlay_zm_ai_quad_blur, 1, 1);
}

function quad_spawn_check()
{
	return isdefined(level.zm_loc_types["quad_location"]) && level.zm_loc_types["quad_location"].size > 0;
}

function get_quad_spawners()
{
	return level.quad_spawners;
}

function quad_prespawn()
{
	self.animname = "quad_zombie";
	self.no_gib = 1;
	self.no_eye_glow = 1;
	self.no_widows_wine = 1;
	self.canbetargetedbyturnedzombies = 1;
	self.custom_location = &quad_location;
	self zm_spawner::zombie_spawn_init(1);
	self.zombie_can_sidestep = 0;
	self.maxhealth = int(self.maxhealth * 0.75);
	self.health = self.maxhealth;
	self.freezegun_damage = 0;
	self.meleedamage = 45;
	self playsound("zmb_quad_spawn");
	self.death_explo_radius_zomb = 96;
	self.death_explo_radius_plr = 96;
	self.death_explo_damage_zomb = 1.05;
	self.death_gas_radius = 125;
	self.death_gas_time = 7;
	if(isdefined(level.quad_explode) && level.quad_explode)
	{
		self.deathfunction = &quad_post_death;
		self.actor_killed_override = &quad_killed_override;
	}
	self set_default_attack_properties();
	self.thundergun_knockdown_func = &quad_thundergun_knockdown;
	self.pre_teleport_func = &quad_pre_teleport;
	self.post_teleport_func = &quad_post_teleport;
	self.can_explode = 0;
	self.exploded = 0;
	self thread quad_trail();
	self allowpitchangle(1);
	self setphysparams(15, 0, 24);
	if(isdefined(level.quad_prespawn))
	{
		self thread [[level.quad_prespawn]]();
	}
}

function init_quad_zombie_fx()
{
	level._effect["quad_explo_gas"] = "dlc5/zmhd/fx_zombie_quad_gas_nova6";
	level._effect["quad_trail"] = "dlc5/zmhd/fx_zombie_quad_trail";
}

function quad_location()
{
	self endon("death");
	if(level.zm_loc_types["quad_location"].size <= 0)
	{
		self dodamage(self.health * 2, self.origin);
		return;
	}
	spot = array::random(level.zm_loc_types["quad_location"]);
	if(isdefined(spot.target))
	{
		self.target = spot.target;
	}
	if(isdefined(spot.zone_name))
	{
		self.zone_name = spot.zone_name;
	}
	self.anchor = spawn("script_origin", self.origin);
	self.anchor.angles = self.angles;
	self linkto(self.anchor);
	if(!isdefined(spot.angles))
	{
		spot.angles = (0, 0, 0);
	}
	self ghost();
	self.anchor moveto(spot.origin, 0.05);
	self.anchor waittill("movedone");
	target_org = zombie_utility::get_desired_origin();
	if(isdefined(target_org))
	{
		anim_ang = vectortoangles(target_org - self.origin);
		self.anchor rotateto((0, anim_ang[1], 0), 0.05);
		self.anchor waittill("rotatedone");
	}
	if(isdefined(level.zombie_spawn_fx))
	{
		playfx(level.zombie_spawn_fx, spot.origin);
	}
	self unlink();
	if(isdefined(self.anchor))
	{
		self.anchor delete();
	}
	self show();
	self notify("risen", spot.script_string);
}

function quad_vox()
{
	self endon("death");
	wait(5);
	quad_wait = 5;
	while(true)
	{
		players = getplayers();
		for(i = 0; i < players.size; i++)
		{
			if(distancesquared(self.origin, players[i].origin) > 1440000)
			{
				self playsound("zmb_quad_amb");
				quad_wait = 7;
				continue;
			}
			if(distancesquared(self.origin, players[i].origin) > 40000)
			{
				self playsound("zmb_quad_vox");
				quad_wait = 5;
				continue;
			}
			if(distancesquared(self.origin, players[i].origin) < 22500)
			{
				wait(0.05);
			}
		}
		wait(randomfloatrange(1, quad_wait));
	}
}

function set_default_attack_properties()
{
	self.goalradius = 16;
	self.maxsightdistsqrd = 16384;
	self.can_leap = 0;
}

function quad_thundergun_knockdown(player, gib)
{
	self endon("death");
	damage = int(self.maxhealth * 0.5);
	self dodamage(damage, player.origin, player);
}

function quad_gas_explo_death()
{
	death_vars = [];
	death_vars["explo_radius_zomb"] = self.death_explo_radius_zomb;
	death_vars["explo_radius_plr"] = self.death_explo_radius_plr;
	death_vars["explo_damage_zomb"] = self.death_explo_damage_zomb;
	death_vars["gas_radius"] = self.death_gas_radius;
	death_vars["gas_time"] = self.death_gas_time;
	self thread quad_death_explo(self.origin, death_vars);
	level thread quad_gas_area_of_effect(self.origin, death_vars);
}

function quad_death_explo(origin, death_vars)
{
	playsoundatposition("zmb_quad_explo", origin);
	players = getplayers();
	zombies = getaiteamarray(level.zombie_team);
	for(i = 0; i < players.size; i++)
	{
		if(distance(origin, players[i].origin) <= death_vars["explo_radius_plr"])
		{
			is_immune = 0;
			if(isdefined(level.quad_gas_immune_func))
			{
				is_immune = players[i] thread [[level.quad_gas_immune_func]]();
			}
			if(!is_immune)
			{
				players[i] shellshock("explosion", 2.5);
			}
		}
	}
	self.exploded = 1;
	self radiusdamage(origin, death_vars["explo_radius_zomb"], level.zombie_health, level.zombie_health, self, "MOD_EXPLOSIVE");
}

function quad_damage_func(player)
{
	if(self.exploded)
	{
		return 0;
	}
	return self.meleedamage;
}

function quad_gas_area_of_effect(origin, death_vars)
{
	effectarea = spawn("trigger_radius", origin, 0, death_vars["gas_radius"], 100);
	playfx(level._effect["quad_explo_gas"], origin);
	gas_time = 0;
	while(gas_time <= death_vars["gas_time"])
	{
		players = getplayers();
		for(i = 0; i < players.size; i++)
		{
			is_immune = 0;
			if(isdefined(level.quad_gas_immune_func))
			{
				is_immune = players[i] thread [[level.quad_gas_immune_func]]();
			}
			if(players[i] istouching(effectarea) && !is_immune)
			{
				visionset_mgr::activate("overlay", "zm_ai_quad_blur", players[i]);
				continue;
			}
			visionset_mgr::deactivate("overlay", "zm_ai_quad_blur", players[i]);
		}
		wait(1);
		gas_time = gas_time + 1;
	}
	players = getplayers();
	for(i = 0; i < players.size; i++)
	{
		visionset_mgr::deactivate("overlay", "zm_ai_quad_blur", players[i]);
	}
	effectarea delete();
}

function quad_trail()
{
	self endon("death");
	self.fx_quad_trail = spawn("script_model", self gettagorigin("tag_origin"));
	self.fx_quad_trail.angles = self gettagangles("tag_origin");
	self.fx_quad_trail setmodel("tag_origin");
	self.fx_quad_trail linkto(self, "tag_origin");
	zm_net::network_safe_play_fx_on_tag("quad_fx", 2, level._effect["quad_trail"], self.fx_quad_trail, "tag_origin");
}

function quad_post_death(einflictor, attacker, idamage, smeansofdeath, weapon, vdir, shitloc, psoffsettime)
{
	self zm_spawner::zombie_death_animscript();
	return false;
}

function quad_killed_override(einflictor, attacker, idamage, smeansofdeath, weapon, vdir, shitloc, psoffsettime)
{
	if(smeansofdeath == "MOD_PISTOL_BULLET" || smeansofdeath == "MOD_RIFLE_BULLET")
	{
		self.can_explode = 1;
	}
	else
	{
		self.can_explode = 0;
		if(isdefined(self.fx_quad_trail))
		{
			self.fx_quad_trail unlink();
			self.fx_quad_trail delete();
		}
	}
	if(isdefined(level._override_quad_explosion))
	{
		[[level._override_quad_explosion]](self);
	}
}

function quad_pre_teleport()
{
	if(isdefined(self.fx_quad_trail))
	{
		self.fx_quad_trail unlink();
		self.fx_quad_trail delete();
		wait(0.1);
	}
}

function quad_post_teleport()
{
	if(isdefined(self.fx_quad_trail))
	{
		self.fx_quad_trail unlink();
		self.fx_quad_trail delete();
	}
	if(self.health > 0)
	{
		self.fx_quad_trail = spawn("script_model", self gettagorigin("tag_origin"));
		self.fx_quad_trail.angles = self gettagangles("tag_origin");
		self.fx_quad_trail setmodel("tag_origin");
		self.fx_quad_trail linkto(self, "tag_origin");
		zm_net::network_safe_play_fx_on_tag("quad_fx", 2, level._effect["quad_trail"], self.fx_quad_trail, "tag_origin");
	}
}
