#using scripts\codescripts\struct;
#using scripts\shared\callbacks_shared; 
#using scripts\shared\ai\zombie_vortex;
#using scripts\shared\system_shared;
#using scripts\zm\_zm;
#using scripts\zm\_zm_weapons;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace idgun;

REGISTER_SYSTEM_EX( "idgun", &__init__, &__main__, undefined )

function __init__()
{
	callback::on_connect(&function_2bd571b9);
	zm::register_player_damage_callback(&function_b618ee82);

	level.b_allow_idgun_pap = 1;
    level.idgun_weapons[ 0 ] = getWeapon( "idgun" );
    level.idgun_weapons[ 1 ] = getWeapon( "idgun_0" );
    level.idgun_weapons[ 2 ] = getWeapon( "idgun_1" );
    level.idgun_weapons[ 3 ] = getWeapon( "idgun_2" );
    level.idgun_weapons[ 4 ] = getWeapon( "idgun_3" );
	level.idgun_weapons[ 5 ] = getWeapon( "idgun_upgraded" );
    level.idgun_weapons[ 6 ] = getWeapon( "idgun_upgraded_0" );
    level.idgun_weapons[ 7 ] = getWeapon( "idgun_upgraded_1" );
    level.idgun_weapons[ 8 ] = getWeapon( "idgun_upgraded_2" );
    level.idgun_weapons[ 9 ] = getWeapon( "idgun_upgraded_3" );
}


function __main__()
{
	if(!isdefined(level.idgun_weapons))
	{
		if(!isdefined(level.idgun_weapons))
		{
			level.idgun_weapons = [];
		}
		else if(!isarray(level.idgun_weapons))
		{
			level.idgun_weapons = array(level.idgun_weapons);
		}
		level.idgun_weapons[level.idgun_weapons.size] = getweapon("idgun");
	}
	level zm::register_vehicle_damage_callback(&idgun_apply_vehicle_damage);
}

function is_idgun_damage(weapon)
{
	if(isdefined(level.idgun_weapons))
	{
		if(isinarray(level.idgun_weapons, weapon))
		{
			return true;
		}
	}
	return false;
}

function function_9b7ac6a9(weapon)
{
	if(is_idgun_damage(weapon) && zm_weapons::is_weapon_upgraded(weapon))
	{
		return true;
	}
	return false;
}

function function_6fbe2b2c(v_vortex_origin)
{
	v_nearest_navmesh_point = getclosestpointonnavmesh(v_vortex_origin, 36, 15);
	if(isdefined(v_nearest_navmesh_point))
	{
		f_distance = distance(v_vortex_origin, v_nearest_navmesh_point);
		if(f_distance < 41)
		{
			v_vortex_origin = v_vortex_origin + vectorscale((0, 0, 1), 36);
		}
	}
	return v_vortex_origin;
}

function function_2bd571b9()
{
	self endon("disconnect");
	while(true)
	{
		self waittill("projectile_impact", weapon, position, radius, attacker, normal);
		position = function_6fbe2b2c(position + (normal * 20));
		if(is_idgun_damage(weapon))
		{
			var_12edbbc6 = radius * 1.8;
			if(function_9b7ac6a9(weapon))
			{
				thread zombie_vortex::start_timed_vortex(position, radius, 9, 10, var_12edbbc6, self, weapon, 1, undefined, 0, 2);
			}
			else
			{
				thread zombie_vortex::start_timed_vortex(position, radius, 4, 5, var_12edbbc6, self, weapon, 1, undefined, 0, 1);
			}
			level notify("hash_2751215d", position, weapon, self);
		}
		wait(0.05);
	}
}


function function_b618ee82(einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime)
{
	if(is_idgun_damage(sweapon))
	{
		return 0;
	}
	return -1;
}

function idgun_apply_vehicle_damage(einflictor, eattacker, idamage, idflags, smeansofdeath, weapon, vpoint, vdir, shitloc, vdamageorigin, psoffsettime, damagefromunderneath, modelindex, partname, vsurfacenormal)
{
	if(isdefined(weapon))
	{
		if(is_idgun_damage(weapon) && (!(isdefined(self.veh_idgun_allow_damage) && self.veh_idgun_allow_damage)))
		{
			idamage = 0;
		}
	}
	return idamage;
}
