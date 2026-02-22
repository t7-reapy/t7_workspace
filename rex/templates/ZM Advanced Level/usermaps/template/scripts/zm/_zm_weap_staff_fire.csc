#using scripts\codescripts\struct;
#using scripts\shared\ai_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\duplicaterender_mgr;
#using scripts\shared\duplicaterenderbundle;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_weap_staff_common;
#insert scripts\shared\duplicaterender.gsh;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace zm_weap_staff_fire; 

#precache( "client_fx", "dlc5/zmb_weapon/fx_staff_charge_fire_lv1" );
#precache( "client_fx", "dlc5/zmb_weapon/fx_staff_fire_impact_ug_exp_loop" );

REGISTER_SYSTEM_EX( "zm_weap_staff_fire", &__init__, &__main__, undefined )

function __init__()
{
	level.a_staff_fire_weaponfiles = [];
	staff_fire_register_weapon_for_level( "staff_fire" );
	staff_fire_register_weapon_for_level( "staff_fire_upgraded"	);
	staff_fire_register_weapon_for_level( "staff_fire_upgraded2" );
	staff_fire_register_weapon_for_level( "staff_fire_upgraded3" );

	clientfield::register( "scriptmover", "staff_fire_volcano_fx", VERSION_SHIP, 1, "int", &staff_fire_volcano_fx,	!CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "actor", "staff_fire_burn_zombie", VERSION_SHIP, 1, "int", &staff_fire_burn_zombie, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "vehicle", "staff_fire_burn_zombie", VERSION_SHIP, 1, "int", &staff_fire_burn_zombie, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
}


function __main__()
{
}

function staff_fire_register_weapon_for_level( str_weapon )
{
	DEFAULT( level.a_staff_fire_weaponfiles, [] );
	a_weapon_data = TableLookupRow( "gamedata/weapons/zm/staff_fire_settings.csv", TableLookupRowNum( "gamedata/weapons/zm/staff_fire_settings.csv", 0, str_weapon ));
	if ( !isDefined( a_weapon_data ) )
		a_weapon_data = TableLookupRow( "gamedata/weapons/zm/staff_fire_settings.csv", TableLookupRowNum( "gamedata/weapons/zm/staff_fire_settings.csv", 0, "default" ));
	if ( !isDefined( a_weapon_data ) )	
		return;
		
	w_weapon = getWeapon( str_weapon );
	w_weapon.b_is_upgrade = ( toLower( a_weapon_data[ true ] ) == "true" );
	w_weapon.n_damage = int( a_weapon_data[ 2 ] );
	w_weapon.n_burn_damage = int( a_weapon_data[ 3 ] );
	w_weapon.n_burn_duration = float( a_weapon_data[ 4 ] );
	w_weapon.n_volcano_range = int( a_weapon_data[ 5 ] );
	w_weapon.n_volcano_lifetime	= float( a_weapon_data[ 6 ] );
	
	zm_weap_staff_common::register_staff_weapon_for_level( w_weapon, undefined, undefined, undefined, undefined, undefined, undefined, undefined, &staff_fire_charge_up_effects, undefined, "dlc5/zmb_weapon/fx_staff_charge_fire_lv1" );
	
	ARRAY_ADD( level.a_staff_fire_weaponfiles, w_weapon );
}

function staff_fire_charge_up_effects( n_local_client_num, w_weapon, n_charge_level = 0 )
{
	self zm_weap_staff_common::play_staff_charge_up_sounds( n_local_client_num, w_weapon, n_charge_level, "wpn_firestaff_charge_" + n_charge_level, ( n_charge_level == 1 ? "wpn_firestaff_charge_loop" : undefined ) );
}

function staff_fire_volcano_fx( n_local_client_num, n_old_value, newval, b_new_ent, b_initial_snap, str_field, b_was_time_jump )
{
	if ( IS_TRUE( newval == 1 ) )
	{
		self.fx_fire_staff_volcano = playFxOnTag( n_local_client_num, "dlc5/zmb_weapon/fx_staff_fire_impact_ug_exp_loop", self, "tag_origin" );
		self playRumbleOnEntity( n_local_client_num, "artillery_rumble" );
		self thread zm_weap_staff_common::staff_shake_and_rumble( n_local_client_num, .3, 1, 100, "artillery_rumble" );
		self thread zm_weap_staff_common::staff_aoe_looping_sound( n_local_client_num, "wpn_firestaff_grenade_loop", undefined, "wpn_firestaff_proj_impact", 0 );
	}
	else
	{
		self notify( "staff_shake_and_rumble" );
		self notify( "staff_aoe_looping_sound_end" );
		stopFx( n_local_client_num, self.fx_fire_staff_volcano );
		self.fx_fire_staff_volcano = undefined;
	}
}


function staff_fire_burn_zombie(localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasDemoJump)
{
	self endon("entityshutdown");
	rate = randomfloatrange(0.01, 0.015);
	if(isdefined(self.torso_fire_fx))
	{
		stopfx(localclientnum, self.torso_fire_fx);
		self.torso_fire_fx = undefined;
	}
	if(isdefined(self.head_fire_fx))
	{
		stopfx(localclientnum, self.head_fire_fx);
		self.head_fire_fx = undefined;
	}
	if(isdefined(self.sndent))
	{
		self.sndent notify("sndDeleting");
		self.sndent delete();
		self.sndent = undefined;
	}
	if(newval == 1)
	{
		self.torso_fire_fx = playfxontag(localclientnum, level._effect["character_fire_death_torso"], self, "j_spinelower");
		self.head_fire_fx = playfxontag(localclientnum, level._effect["character_fire_death_sm"], self, "j_head");
		self.sndent = spawn(0, self.origin, "script_origin");
		self.sndent linkto(self);
		self.sndent playloopsound("zmb_fire_loop", 0.5);
		self.sndent thread staff_fire_delete_sound_ent(self);
		if(!IS_TRUE(self.has_charred))
		{
			self mapshaderconstant(localclientnum, 2, "scriptVector3");
			self.has_charred = 1;
		}
		max_charamount = 1;
		char_amount = 0.6;
		for(i = 0; i < 2; i++)
		{
			for(f = 0.6; f <= 0.85; f += rate)
			{
				util::server_wait(localclientnum, 0.05);
				self setshaderconstant(localclientnum, 2, f, 0, 0, 0);
			}
			for(f = 0.85; f >= 0.6; f -= rate)
			{
				util::server_wait(localclientnum, 0.05);
				self setshaderconstant(localclientnum, 2, f, 0, 0, 0);
			}
		}
		for(f = 0.6; f <= 1; f += rate)
		{
			util::server_wait(localclientnum, 0.05);
			self setshaderconstant(localclientnum, 2, f, 0, 0, 0);
		}
	}
}
function staff_fire_delete_sound_ent( e_zombie )
{
	self endon( "sndDeleting" );
	e_zombie waittill( "entityshutdown" );
	self delete();
}
