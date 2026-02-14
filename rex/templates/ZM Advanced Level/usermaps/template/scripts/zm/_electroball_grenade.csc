#using scripts\codescripts\struct;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\postfx_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\weapons\_weaponobjects;
#using scripts\zm\_zm_elemental_zombies;

#namespace electroball_grenade;

#precache( "client_fx", "dlc1/castle/fx_wpn_115_blob" );
#precache( "client_fx", "dlc1/castle/fx_wpn_115_bul_trail" );
#precache( "client_fx", "dlc1/castle/self_explode" );

function autoexec __init__sytem__()
{
	system::register("electroball_grenade", &__init__, undefined, undefined);
}

function __init__()
{
	clientfield::register("toplayer", "tazered", 1, 1, "int", undefined, 0, 0);
	clientfield::register("allplayers", "electroball_shock", 1, 1, "int", &shock_player_fx, 0, 0);
	//clientfield::register("actor", "electroball_make_sparky", 1, 1, "int", &electroball_make_sparky, 0, 0);
	clientfield::register("missile", "electroball_stop_trail", 1, 1, "int", &on_land, 0, 0);
	clientfield::register("missile", "electroball_play_landed_fx", 1, 1, "int", &electroball_play_landed_fx, 0, 0);
	level._effect["fx_wpn_115_blob"] = "dlc1/castle/fx_wpn_115_blob";
	level._effect["fx_wpn_115_bul_trail"] = "dlc1/castle/fx_wpn_115_bul_trail";
	level._effect["fx_wpn_115_canister"] = "dlc1/castle/fx_wpn_115_canister";
	level._effect["electroball_grenade_player_shock"] = "weapon/fx_prox_grenade_impact_player_spwner";
	level._effect["electroball_grenade_sparky_conversion"] = "weapon/fx_prox_grenade_exp";
	callback::add_weapon_type("electroball_grenade", &proximity_spawned);
	level thread watchForProximityExplosion();
}

function proximity_spawned(localClientNum)
{
	self util::waittill_dobj(localClientNum);
	if(self isGrenadeDud())
	{
		return;
	}
	self.nade_trail = PlayFXOnTag(localClientNum, level._effect["fx_wpn_115_bul_trail"], self, "j_grenade_front");
	self.nade_canister = PlayFXOnTag(localClientNum, level._effect["fx_wpn_115_canister"], self, "j_grenade_back");
}

function watchForProximityExplosion()
{
	if(GetActiveLocalClients() > 1)
	{
		return;
	}
	weapon_proximity = GetWeapon("electroball_grenade");
	while(1)
	{
		level waittill("explode", localClientNum, position, mod, weapon, owner_cent);
		if(weapon.rootweapon != weapon_proximity)
		{
			continue;
		}
		localPlayer = GetLocalPlayer(localClientNum);
		if(!localPlayer util::is_player_view_linked_to_entity(localClientNum))
		{
			explosionRadius = weapon.explosionRadius;
			if(DistanceSquared(localPlayer.origin, position) < explosionRadius * explosionRadius)
			{
				if(isdefined(owner_cent))
				{
					if(owner_cent == localPlayer || !owner_cent util::friend_not_foe(localClientNum, 1))
					{
						localPlayer thread postfx::playPostfxBundle("pstfx_shock_charge");
					}
				}
			}
		}
	}
}

function electroball_make_sparky(localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump)
{
	ai_zombie = self;
	if(isdefined(level.a_electroball_grenades))
	{
		electroball = ArrayGetClosest(ai_zombie.origin, level.a_electroball_grenades);
	}
	a_sparky_tags = Array("J_Spine4", "J_SpineUpper", "J_Spine1");
	tag = Array::random(a_sparky_tags);
	if(isdefined(electroball))
	{
		var_d72ccbc = BeamLaunch(localClientNum, electroball, "tag_origin", ai_zombie, tag, "electric_arc_beam_electroball");
		wait(1);
		if(isdefined(var_d72ccbc))
		{
			BeamKill(localClientNum, var_d72ccbc);
		}
	}
}

function shock_player_fx(localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump)
{
	FX = PlayFXOnTag(localClientNum, level._effect["electroball_grenade_player_shock"], self, "J_SpineUpper");
}

function on_land(localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump)
{
	if(!isdefined(level.a_electroball_grenades))
	{
		level.a_electroball_grenades = [];
	}
	Array::add(level.a_electroball_grenades, self);
	self thread function_1d823abf();
	if(isdefined(self.nade_trail))
	{
		stopfx(localClientNum, self.nade_trail);
	}
	if(isdefined(self.var_626a3201))
	{
		stopfx(localClientNum, self.var_626a3201);
	}
	if(isdefined(self.var_7a731cc6))
	{
		stopfx(localClientNum, self.var_7a731cc6);
	}
	if(isdefined(self.nade_canister))
	{
		stopfx(localClientNum, self.nade_canister);
	}
}

function function_1d823abf()
{
	self waittill("entityshutdown");
	level.a_electroball_grenades = Array::remove_undefined(level.a_electroball_grenades);
}

function electroball_play_landed_fx(localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump)
{
	self.landed_fx = PlayFXOnTag(localClientNum, level._effect["fx_wpn_115_blob"], self, "tag_fx");
	//self.var_3b22ba3c = PlayFXOnTag(localClientNum, level._effect["fx_wpn_115_blob"], self, "tag_origin");
	//dynEnt = CreateDynEntAndLaunch(localClientNum, "p7_zm_ctl_115_grenade_broken", self.origin, self.angles, self.origin, (0, 0, 0));
}

