#using scripts\codescripts\struct;
#using scripts\shared\audio_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_load;
#using scripts\zm\_zm_weapons;

//Perks
#using scripts\zm\_zm_pack_a_punch;
#using scripts\zm\_zm_perk_additionalprimaryweapon;
#using scripts\zm\_zm_perk_doubletap2;
#using scripts\zm\_zm_perk_deadshot;
#using scripts\zm\_zm_perk_juggernaut;
#using scripts\zm\_zm_perk_quick_revive;
#using scripts\zm\_zm_perk_sleight_of_hand;
#using scripts\zm\_zm_perk_staminup;

//Powerups
#using scripts\zm\_zm_powerup_double_points;
#using scripts\zm\_zm_powerup_carpenter;
#using scripts\zm\_zm_powerup_fire_sale;
#using scripts\zm\_zm_powerup_free_perk;
#using scripts\zm\_zm_powerup_full_ammo;
#using scripts\zm\_zm_powerup_insta_kill;
#using scripts\zm\_zm_powerup_nuke;

//Traps
#using scripts\zm\_zm_trap_electric;

#using scripts\zm\zm_usermap;

function main()
{
	clientfield::register("toplayer", "lightning_strike", VERSION_SHIP, 1, "counter", &lightning_strike, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);

	zm_usermap::main();

	include_weapons();
	
	util::waitforclient( 0 );
}

function include_weapons()
{
	zm_weapons::load_weapon_spec_from_table("gamedata/weapons/zm/zm_levelcommon_weapons.csv", 1);
}

function lightning_strike(localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump)
{
	SetUkkoScriptIndex(localClientNum, 1, 1);
	playsound(0, "amb_lightning_dist_low", (0, 0, 0));
	wait(0.02);
	SetUkkoScriptIndex(localClientNum, 3, 1);
	wait(0.15);
	SetUkkoScriptIndex(localClientNum, 1, 1);
	wait(0.1);
	SetUkkoScriptIndex(localClientNum, 4, 1);
	wait(0.1);
	SetUkkoScriptIndex(localClientNum, 3, 1);
	wait(0.25);
	SetUkkoScriptIndex(localClientNum, 1, 1);
	wait(0.15);
	SetUkkoScriptIndex(localClientNum, 3, 1);
	wait(0.15);
	SetUkkoScriptIndex(localClientNum, 1, 1);
}