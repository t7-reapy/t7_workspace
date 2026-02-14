#using scripts\zm\_zm_zonemgr; 
#using scripts\codescripts\struct;
#using scripts\shared\aat_shared;
#using scripts\shared\ai\archetype_locomotion_utility;
#using scripts\shared\ai\archetype_mocomps_utility;
#using scripts\shared\ai\archetype_utility;
#using scripts\shared\ai\systems\ai_blackboard;
#using scripts\shared\ai\systems\ai_interface;
#using scripts\shared\ai\systems\animation_state_machine_mocomp;
#using scripts\shared\ai\systems\animation_state_machine_notetracks;
#using scripts\shared\ai\systems\animation_state_machine_utility;
#using scripts\shared\ai\systems\behavior_tree_utility;
#using scripts\shared\ai\systems\blackboard;
#using scripts\shared\ai\systems\debug;
#using scripts\shared\ai\systems\gib;
#using scripts\shared\ai\zombie;
#using scripts\shared\ai\zombie_death;
#using scripts\shared\ai\zombie_shared;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\ai_shared;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\flagsys_shared;
#using scripts\shared\fx_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_behavior;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_portals;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#precache( "fx", "zombie/fx_portal_keeper_spawn_os_zod_zmb" );
#precache( "xmodel", "c_zom_dlc4_keeper_hooded_dissolve" );
#precache( "xmodel", "c_zom_dlc4_keeper_dissolve" );

#namespace zm_ai_keeper;

REGISTER_SYSTEM_EX( "zm_ai_keeper", &__init__, &__main__, undefined )

function __init__()
{
	function_cf48298e();
	if(ai::shouldregisterclientfieldforarchetype("keeper"))
	{
		clientfield::register("actor", "keeper_death", 15000, 2, "int");
	}

	level._effect["keeper_spawn"] = "zombie/fx_portal_keeper_spawn_os_zod_zmb";
}

function __main__()
{
	spawner::add_archetype_spawn_function("keeper", &function_cb6b3469);
	spawner::add_archetype_spawn_function("keeper", &function_6ded398b);
	spawner::add_archetype_spawn_function("keeper", &function_e5e94978);
	spawner::add_archetype_spawn_function("keeper", &function_1dcdd145);
	level thread aat::register_immunity("zm_aat_turned", "keeper", 1, 1, 1);
}

function function_cb6b3469()
{
	blackboard::createblackboardforentity(self);
	self aiutility::registerutilityblackboardattributes();
	ai::createinterfaceforentity(self);
	blackboard::registerblackboardattribute(self, "_arms_position", "arms_up", &bb_getarmsposition);
	blackboard::registerblackboardattribute(self, "_locomotion_speed", "locomotion_speed_walk", &bb_getlocomotionspeedtype);
	blackboard::registerblackboardattribute(self, "_has_legs", "has_legs_yes", &bb_gethaslegsstatus);
	blackboard::registerblackboardattribute(self, "_variant_type", 0, &bb_getvarianttype);
	blackboard::registerblackboardattribute(self, "_which_board_pull", undefined, undefined);
	blackboard::registerblackboardattribute(self, "_board_attack_spot", undefined, undefined);
	blackboard::registerblackboardattribute(self, "_grapple_direction", undefined, undefined);
	blackboard::registerblackboardattribute(self, "_locomotion_should_turn", "should_not_turn", &bb_getshouldturn);
	blackboard::registerblackboardattribute(self, "_idgun_damage_direction", "back", &bb_idgungetdamagedirection);
	blackboard::registerblackboardattribute(self, "_low_gravity_variant", 0, &bb_getlowgravityvariant);
	blackboard::registerblackboardattribute(self, "_knockdown_direction", undefined, undefined);
	blackboard::registerblackboardattribute(self, "_knockdown_type", undefined, undefined);
	self.___archetypeonanimscriptedcallback = &archetypezombieonanimscriptedcallback;
}

function private function_cf48298e()
{
	behaviortreenetworkutility::registerbehaviortreescriptapi("genesisKeeperDeathStart", &function_9d655978);
}

function function_9d655978(entity)
{
	if(entity.model == "c_zom_dlc4_keeper_hooded_body")
	{
		entity setmodel("c_zom_dlc4_keeper_hooded_dissolve");
	}
	else
	{
		entity setmodel("c_zom_dlc4_keeper_dissolve");
	}
	entity clientfield::set("keeper_death", 2);
	entity notsolid();
}

function function_f8c7a969(inflictor, attacker, damage, meansofdeath, weapon, dir, hitloc, offsettimes)
{
	self clientfield::set("keeper_death", 1);
	self notsolid();
	return damage;
}

function keeper_death()
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

function private function_e361808()
{
	queryresult = positionquery_source_navigation(level.players[0].origin, 128, 256, 128, 20);
	if(isdefined(queryresult) && queryresult.data.size > 0)
	{
		origin = queryresult.data[0].origin;
		angles = level.players[0].angles;
		entity = spawnactor("spawner_zm_genesis_keeper", origin, level.players[0].angles, undefined, 1, 1);
		if(isdefined(entity))
		{
			entity thread keeper_spawn();
		}
	}
}

function keeper_spawn()
{
	a_players = getplayers();
	e_player = function_25a4a7d4();
	queryresult = positionquery_source_navigation(e_player.origin, 600, 900, 128, 20);
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
				var_d88e6f5f = spawnactor("spawner_zm_genesis_keeper", v_origin, v_angles, undefined, 1, 1);
				if(isdefined(var_d88e6f5f))
				{
					level.zombie_total--;
					level.var_c4336559["keeper"]--;
					var_d88e6f5f endon("death");
					var_d88e6f5f.spawn_time = gettime();
					var_d88e6f5f.var_b8385ee5 = 1;
					var_d88e6f5f.health = level.zombie_health;
					var_d88e6f5f.heroweapon_kill_power = 2;
					level thread zm_spawner::zombie_death_event(var_d88e6f5f);
					level thread function_6cc52664(var_d88e6f5f.origin);
					var_d88e6f5f.voiceprefix = "keeper";
					var_d88e6f5f.animname = "keeper";
					var_d88e6f5f thread zm_spawner::play_ambient_zombie_vocals();
					var_d88e6f5f thread zm_audio::zmbaivox_notifyconvert();
					wait(1.3);
					var_d88e6f5f.zombie_think_done = 1;
					var_d88e6f5f thread zombie_utility::round_spawn_failsafe();
					var_d88e6f5f thread function_77d3a18d();
					return var_d88e6f5f;
				}
			}
		}
	}
	return undefined;
}

function function_77d3a18d()
{
	self.ignore_nuke = 1;
	self endon("death");
	util::wait_network_frame();
	self.ignore_nuke = undefined;
}

function function_25a4a7d4()
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

function function_6cc52664(v_origin)
{
	var_986156a0 = util::spawn_model("tag_origin", v_origin, (0, 0, 0));
	playfxontag(level._effect["keeper_spawn"], var_986156a0, "tag_origin");
	var_986156a0 playsound("evt_keeper_portal_start");
	wait(1.5);
	var_986156a0 delete();
}

function get_lookat_angles(v_start, v_end)
{
	v_dir = v_end - v_start;
	v_dir = vectornormalize(v_dir);
	v_angles = vectortoangles(v_dir);
	return v_angles;
}

function function_6ded398b()
{
	aiutility::addaioverridedamagecallback(self, &function_7085a2e4);
	self thread zm::update_zone_name();
	self aat::aat_cooldown_init();
	self thread zm_spawner::enemy_death_detection();
	self.completed_emerging_into_playable_area = 1;
	self.is_zombie = 1;
}

function function_e5e94978()
{
	self endon("death");
	while(isalive(self))
	{
		self waittill("damage");
		if(isplayer(self.attacker))
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
				self.attacker zm_score::player_add_points(str_notify, self.damagemod, self.damagelocation, undefined, self.team, self.damageweapon);
			}
			if(isdefined(level.hero_power_update))
			{
				[[level.hero_power_update]](self.attacker, self);
			}
			self.attacker.use_weapon_type = self.damagemod;
			self thread zm_powerups::check_for_instakill(self.attacker, self.damagemod, self.damagelocation);
		}
		util::wait_network_frame();
	}
}

function function_1dcdd145()
{
	self waittill("death");
	self zm_spawner::check_zombie_death_event_callbacks(self.attacker);
	if(isplayer(self.attacker))
	{
		if(!(isdefined(self.deathpoints_already_given) && self.deathpoints_already_given))
		{
			self.attacker zm_score::player_add_points("death", self.damagemod, self.damagelocation, undefined, self.team, self.damageweapon);
		}
		if(isdefined(level.hero_power_update))
		{
			[[level.hero_power_update]](self.attacker, self);
		}
	}
}

function function_7085a2e4(einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex, modelindex)
{
	if(isplayer(eattacker) && (isdefined(eattacker.var_74fe492b) && eattacker.var_74fe492b))
	{
		idamage = int(idamage * 1.33);
	}
	if(isplayer(eattacker) && (isdefined(eattacker.var_e8e8daad) && eattacker.var_e8e8daad))
	{
		idamage = int(idamage * 1.5);
	}
	return idamage;
}

function bb_getarmsposition()
{
	if(isdefined(self.zombie_arms_position))
	{
		if(self.zombie_arms_position == "up")
		{
			return "arms_up";
		}
		return "arms_down";
	}
	return "arms_up";
}

function bb_getlocomotionspeedtype()
{
	if(isdefined(self.zombie_move_speed))
	{
		if(self.zombie_move_speed == "walk")
		{
			return "locomotion_speed_walk";
		}
		if(self.zombie_move_speed == "run")
		{
			return "locomotion_speed_run";
		}
		if(self.zombie_move_speed == "sprint")
		{
			return "locomotion_speed_sprint";
		}
		if(self.zombie_move_speed == "super_sprint")
		{
			return "locomotion_speed_super_sprint";
		}
	}
	return "locomotion_speed_walk";
}

function bb_getvarianttype()
{
	if(isdefined(self.variant_type))
	{
		return self.variant_type;
	}
	return 0;
}

function bb_gethaslegsstatus()
{
	if(self.missinglegs)
	{
		return "has_legs_no";
	}
	return "has_legs_yes";
}

function bb_getshouldturn()
{
	if(isdefined(self.should_turn) && self.should_turn)
	{
		return "should_turn";
	}
	return "should_not_turn";
}

function bb_idgungetdamagedirection()
{
	if(isdefined(self.damage_direction))
	{
		return self.damage_direction;
	}
	return self aiutility::bb_getdamagedirection();
}

function bb_getlowgravityvariant()
{
	if(isdefined(self.low_gravity_variant))
	{
		return self.low_gravity_variant;
	}
	return 0;
}

function private archetypezombieonanimscriptedcallback(entity)
{
	entity.__blackboard = undefined;
	entity function_cb6b3469();
}

