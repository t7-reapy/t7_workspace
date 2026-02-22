#using scripts\codescripts\struct;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\challenges_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\scoreevents_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\weapons\_weaponobjects;
#using scripts\zm\_zm;
#using scripts\zm\_zm_elemental_zombies;

#namespace electroball_grenade;

function autoexec __init__sytem__()
{
	system::register("electroball_grenade", &__init__, undefined, undefined);
}

function __init__()
{
	level.proximityGrenadeDetectionRadius = GetDvarInt("scr_proximityGrenadeDetectionRadius", 180);
	level.proximityGrenadeGracePeriod = GetDvarFloat("scr_proximityGrenadeGracePeriod", 0.05);
	level.proximityGrenadeDOTDamageAmount = GetDvarInt("scr_proximityGrenadeDOTDamageAmount", 1);
	level.proximityGrenadeDOTDamageAmountHardcore = GetDvarInt("scr_proximityGrenadeDOTDamageAmountHardcore", 1);
	level.proximityGrenadeDOTDamageTime = GetDvarFloat("scr_proximityGrenadeDOTDamageTime", 0.2);
	level.proximityGrenadeDOTDamageInstances = GetDvarInt("scr_proximityGrenadeDOTDamageInstances", 4);
	level.proximityGrenadeActivationTime = GetDvarFloat("scr_proximityGrenadeActivationTime", 0.1);
	level.proximityGrenadeProtectedTime = GetDvarFloat("scr_proximityGrenadeProtectedTime", 0.45);
	level thread register();
	if(!isdefined(level.spawnProtectionTimeMS))
	{
		level.spawnProtectionTimeMS = 0;
	}
	callback::on_spawned(&on_player_spawned);
	callback::on_ai_spawned(&on_ai_spawned);
	zm::register_actor_damage_callback(&electroball_actor_damage_callback);
}

function register()
{
	clientfield::register("toplayer", "tazered", 1, 1, "int");
	//clientfield::register("actor", "electroball_make_sparky", 1, 1, "int");
	clientfield::register("missile", "electroball_stop_trail", 1, 1, "int");
	clientfield::register("missile", "electroball_play_landed_fx", 1, 1, "int");
	clientfield::register("allplayers", "electroball_shock", 1, 1, "int");
}

function setup_nade_watcher()
{
	if(isPlayer(self))
	{
		watcher = self weaponobjects::createProximityWeaponObjectWatcher("electroball_grenade", self.team);
	}
	else
	{
		watcher = self weaponobjects::createProximityWeaponObjectWatcher("electroball_grenade", level.zombie_team);
	}
	watcher.watchForFire = 1;
	watcher.hackable = 0;
	watcher.hackerToolRadius = level.equipmentHackerToolRadius;
	watcher.hackerToolTimeMs = level.equipmentHackerToolTimeMs;
	watcher.headicon = 0;
	watcher.activateFx = 1;
	watcher.ownerGetsAssist = 1;
	watcher.ignoreDirection = 1;
	watcher.immediateDetonation = 1;
	watcher.detectionGracePeriod = 0.05;
	watcher.detonateRadius = 64;
	watcher.onStun = &weaponobjects::weaponStun;
	watcher.stunTime = 1;
	watcher.onDetonateCallback = &proximityDetonate;
	watcher.activationDelay = 0.05;
	watcher.activateSound = "wpn_claymore_alert";
	watcher.immunespecialty = "specialty_immunetriggershock";
	watcher.onSpawn = &electroball_grenade_onspawn;
}

function electroball_grenade_onspawn(watcher, owner) //self = watcher?
{
	self thread setupKillCamEnt();
	if(isPlayer(owner))
	{
		owner addweaponstat(self.weapon, "used", 1);
	}
	if(isdefined(self.weapon) && self.weapon.proximityDetonation > 0)
	{
		watcher.detonateRadius = self.weapon.proximityDetonation;
	}
	weaponobjects::onSpawnProximityWeaponObject(watcher, owner);
	self thread watch_grenade_bounce();
	self thread electroball_grenade_count();
}

function setupKillCamEnt()
{
	self endon("death");
	self util::waitTillNotMoving();
	self.killCamEnt = spawn("script_model", self.origin + VectorScale((0, 0, 1), 8));
	self thread cleanupKillCamEntOnDeath();
}

function cleanupKillCamEntOnDeath()
{
	self waittill("death");
	self.killCamEnt util::deleteAfterTime(4 + level.proximityGrenadeDOTDamageTime * level.proximityGrenadeDOTDamageInstances);
}

function proximityDetonate(attacker, weapon, target)
{

	weaponobjects::weaponDetonate(attacker, weapon);
}

function watchProximityGrenadeHitPlayer(owner)
{
	self endon("death");
	self SetTeam(owner.team);
	return;
	while(1)
	{
		self waittill("grenade_bounce", pos, normal, ent, surface);

		if(isdefined(ent) && isPlayer(ent) && surface != "riotshield")
		{
			if(level.teambased && ent.team == self.owner.team)
			{
				continue;
			}
			self proximityDetonate(self.owner, self.weapon);
			return;
		}
	}
}

function performHudEffects(position, distanceToGrenade)
{
	forwardVec = VectorNormalize(AnglesToForward(self.angles));
	rightVec = VectorNormalize(AnglesToRight(self.angles));
	explosionVec = VectorNormalize(position - self.origin);
	fDot = VectorDot(explosionVec, forwardVec);
	rDot = VectorDot(explosionVec, rightVec);
	fAngle = ACos(fDot);
	rAngle = ACos(rDot);
}

function watch_player_damage()
{
	self endon("death");
	self endon("disconnect");
	while(1)
	{
		self waittill("damage", damage, eAttacker, dir, point, type, model, tag, part, weapon, flags);
		if(weapon.name == "electroball_grenade")
		{
			self damagePlayerInRadius(eAttacker);
		}
		wait(0.05);
	}
}


function damagePlayerInRadius(eAttacker)
{
	self notify("proximityGrenadeDamageStart");
	self endon("proximityGrenadeDamageStart");
	self endon("disconnect");
	self endon("death");
	eAttacker endon("disconnect");
	self clientfield::set("electroball_shock", 1);
	g_time = GetTime();
	if(self util::mayApplyScreenEffect())
	{
		self.lastShockedBy = eAttacker;
		self.shockEndTime = GetTime() + 100;
		self shellshock("electrocution", 0.1);
		self clientfield::set_to_player("tazered", 1);
	}
	self PlayRumbleOnEntity("proximity_grenade");
	self playsound("wpn_taser_mine_zap");
	if(!self hasPerk("specialty_proximityprotection"))
	{
		self thread watch_death();
		//self util::show_hud(0);
		if(GetTime() - g_time < 100)
		{
			wait(GetTime() - g_time / 1000);
		}
		self util::show_hud(1);
	}
	else
	{
		wait(level.proximityGrenadeProtectedTime);
	}
	self clientfield::set_to_player("tazered", 0);
}

function proximityDeathWait(owner)
{
	self waittill("death");
	self notify("deleteSound");
}

function deleteEntOnOwnerDeath(owner)
{
	self thread deleteEntOnTimeout();
	self thread deleteEntAfterTime();
	self endon("delete");
	owner waittill("death");
	self notify("deleteSound");
}

function deleteEntAfterTime()
{
	self endon("delete");
	wait(10);
	self notify("deleteSound");
}

function deleteEntOnTimeout()
{
	self endon("delete");
	self waittill("deleteSound");
	self delete();
}

function watch_death()
{
	self endon("disconnect");
	self notify("proximity_cleanup");
	self endon("proximity_cleanup");
	self waittill("death");
	self StopRumble("proximity_grenade");
	self setblur(0, 0);
	self util::show_hud(1);
	self clientfield::set_to_player("tazered", 0);
}

function on_player_spawned()
{
	if(isPlayer(self))
	{
		self thread setup_nade_watcher();
		self thread begin_other_grenade_tracking();
		self thread watch_player_damage();
	}
}

function on_ai_spawned()
{
	if(self.archetype === "mechz")
	{
		self thread setup_nade_watcher();
		self thread begin_other_grenade_tracking();
	}
}
function begin_other_grenade_tracking()
{
	self endon("death");
	self endon("disconnect");
	self notify("proximityTrackingStart");
	self endon("proximityTrackingStart");
	for(;;)
	{
		self waittill("grenade_fire", grenade, weapon, cookTime);
		if(weapon.rootweapon.name == "electroball_grenade")
		{
			grenade thread watchProximityGrenadeHitPlayer(self);
		}
	}
}

function watch_grenade_bounce()
{
	self endon("death");
	self endon("disconnect");
	self endon("delete");
	self waittill("grenade_bounce");
	return;
}

function electroball_grenade_count()
{
	self endon("death");
	self endon("disconnect");
	self endon("delete");

	self waittill("grenade_bounce");
	self clientfield::set("electroball_stop_trail", 1);
	self clientfield::set("electroball_play_landed_fx", 1);
	

	if(!isdefined(level.a_electroball_grenades))
	{
		level.a_electroball_grenades = [];
	}
	Array::add(level.a_electroball_grenades, self);
}

function electroball_actor_damage_callback(inflictor, attacker, damage, flags, meansOfDeath, weapon, vPoint, vDir, sHitLoc, psOffsetTime, boneIndex, surfaceType)
{
	if(isdefined(weapon) && weapon.rootweapon.name === "electroball_grenade")
	{
		if(isdefined(attacker) && self.team === attacker.team)
		{
			return 0;
		}
		if(self.var_3531cf2b === 1)
		{
			return 0;
		}
	}
	return -1;
}

