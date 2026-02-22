#using scripts\codescripts\struct;
#using scripts\shared\system_shared;
#using scripts\shared\clientfield_shared;
#using scripts\zm\_zm;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_spawner; 
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\callbacks_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_melee_weapon;
#using scripts\zm\_zm_weapons;

#namespace zm_weap_plunger;

function autoexec __init__sytem__()
{
	system::register("plunger_knife", &__init__, &__main__, undefined);
}

function private __init__()
{
	//clientfield::register("actor", "plunger_exploding_ai", 5000, 1, "int");
	//clientfield::register("toplayer", "plunger_charged_strike", 5000, 1, "counter");
	zm::register_actor_damage_callback(&function_f10f1879);
	zm_spawner::register_zombie_death_event_callback(&function_8d95ec46);
	level thread give_plunger();
}

function private __main__()
{
	cost = 3000;
	zm_melee_weapon::init("knife_plunger", "zombie_plunger_flourish", undefined, undefined, cost, "bowie_upgrade", &"ZMWEAPON_NONE", "plunger", undefined);
	zm_melee_weapon::set_fallback_weapon("knife_plunger", "zombie_fists_plunger");
}

function give_plunger()
{
	players = level.activeplayers;
	foreach(player in level.activeplayers)
	{
		if(isdefined(player) && isalive(player))
		{
			player thread function_45b9eba4();
		}
	}
	callback::on_spawned(&function_45b9eba4);
} 

function function_45b9eba4()
{
	self.widows_wine_knife_override = &function_9ce92341;
	//self zm_melee_weapon::award_melee_weapon("knife_plunger");
	self thread function_9daec9e3();
	self thread function_1fcb04d7();
}

function function_9daec9e3()
{
	self endon("disconnect");
	var_7c4fe278 = getweapon("knife_plunger");
	while(true)
	{
		self waittill("weapon_melee", weapon);
		if(weapon == var_7c4fe278 && isdefined(self.var_ea5424ae) && self.var_ea5424ae > 0)
		{
			//self clientfield::increment_to_player("plunger_charged_strike");
		}
	}
}

function function_8d95ec46(e_attacker)
{
	var_7c4fe278 = getweapon("knife_plunger");
	if(var_7c4fe278 == self.damageweapon)
	{
		self zombie_utility::zombie_head_gib();
		return true;
	}
	return false;
}

function function_1fcb04d7()
{
	self endon("disconnect");
	self waittill("bled_out");
	self.widows_wine_knife_override = undefined;
}

function function_f10f1879(inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex, surfacetype)
{
	var_7c4fe278 = getweapon("knife_plunger");
	if(weapon == var_7c4fe278 && isdefined(attacker) && isplayer(attacker) && isdefined(attacker.var_ea5424ae) && attacker.var_ea5424ae > 0)
	{
		damage = 777 * self.health;
		if(isdefined(self))
		{
			self thread function_beeeab78();
		}
		level.var_91b525ed++;
		if(level.var_91b525ed >= 16)
		{
			function_79e1bd74(2);
		}
		else if(level.var_91b525ed >= 4)
		{
			function_79e1bd74(1);
		}
		return damage;
	}
	return -1;
}

function function_beeeab78()
{
	//self clientfield::set("plunger_exploding_ai", 1);
	self zombie_utility::zombie_eye_glow_stop();
	wait(0.15);
	self ghost();
	self util::delay(0.15, undefined, &zm_utility::self_delete);
}

function function_79e1bd74(n_level)
{
	var_5824233 = array("p7_zm_ctl_newspaper_01_parade", "p7_zm_ctl_newspaper_01_attacks", "p7_zm_ctl_newspaper_01_outbreak");
	str_model = var_5824233[n_level];
	if(!isdefined(level.var_31e6a027))
	{
		var_21231084 = struct::get("ee_newspaper");
		level.var_31e6a027 = util::spawn_model(str_model, var_21231084.origin, var_21231084.angles);
	}
	else
	{
		level.var_31e6a027 setmodel(str_model);
	}
}

function function_9ce92341()
{

}
