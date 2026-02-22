#using scripts\codescripts\struct;
#using scripts\shared\ai\zombie_vortex;
#using scripts\shared\audio_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\zm\_zm_weapons;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace idgun;

REGISTER_SYSTEM_EX( "idgun", &__init__, undefined, undefined )

function __init__()
{
	level.weaponNone = getWeapon( "none" );
	setup_idgun_weapons();
	callback::on_spawned( &on_spawned_idgun );
}

function on_spawned_idgun( n_local_client_num )
{
}

function register_idgun( w_weapon )
{
	if(w_weapon != level.weaponnone)
	{
		if(!isdefined(level.idgun_weapons))
		{
			level.idgun_weapons = [];
		}
		else if(!isarray(level.idgun_weapons))
		{
			level.idgun_weapons = array(level.idgun_weapons);
		}
		level.idgun_weapons[level.idgun_weapons.size] = w_weapon;
	}
}

function setup_idgun_weapons()
{
	level.idgun_weapons = [];
	register_idgun( getWeapon( "idgun" ) );
	register_idgun( getWeapon( "idgun_upgraded" ) );
	register_idgun( getWeapon( "idgun_0" ) );
	register_idgun( getWeapon( "idgun_1" ) );
	register_idgun( getWeapon( "idgun_2" ) );
	register_idgun( getWeapon( "idgun_3" ) );
	register_idgun( getWeapon( "idgun_upgraded_0" ) );
	register_idgun( getWeapon( "idgun_upgraded_1" ) );
	register_idgun( getWeapon( "idgun_upgraded_2" ) );
	register_idgun( getWeapon( "idgun_upgraded_3" ) );
}

function is_upgraded_idgun( w_weapon )
{
	if ( w_weapon === getWeapon( "idgun_upgraded" ) ||w_weapon === getWeapon( "idgun_upgraded_0" ) || w_weapon === getWeapon( "idgun_upgraded_1" ) || w_weapon === getWeapon( "idgun_upgraded_2" ) || w_weapon === getWeapon( "idgun_upgraded_3" ) )
		return 1;
	
	return 0;
}

function is_idgun_damage( w_weapon )
{
	if ( isDefined( level.idgun_weapons ) )
	{
		if ( isInArray( level.idgun_weapons, w_weapon ) )
			return 1;
		
	}
	return 0;
}