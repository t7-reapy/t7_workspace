#using scripts\codescripts\struct;

#using scripts\shared\aat_shared;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;

#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_bgb;
#using scripts\zm\_zm_equipment;
#using scripts\zm\_zm_magicbox;
#using scripts\zm\_zm_pack_a_punch_util;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\zm.gsh;

#precache( "triggerstring", "ZOMBIE_PERK_PACKAPUNCH", "5000" );
#precache( "triggerstring", "ZOMBIE_PERK_PACKAPUNCH_AAT", "2500" );
#precache( "triggerstring", "ZOMBIE_GET_UPGRADED_FILL" );

REGISTER_SYSTEM_EX( "zm_s2_pack_a_punch", &__init__, &__main__, undefined )

function __init__()
{
	pack_a_punch_structs = struct::get_array( "zm_s2_pack_a_punch", "targetname" );

	if( pack_a_punch_structs.size < 1 )
		return;

	DEFAULT( level.s2_pack_a_punch_triggers, [] );
	
	array::run_all( pack_a_punch_structs, &pack_a_punch_spawn_init );
}

function __main__()
{
	if( !isdefined( level.s2_pack_a_punch_triggers ) )
		return;

	array::run_all( level.s2_pack_a_punch_triggers, &flag::init, "pack_machine_in_use" );
	array::run_all( level.s2_pack_a_punch_triggers, &flag::init, "pap_offering_gun" );
	array::thread_all( level.s2_pack_a_punch_triggers, &pack_a_punch_set_cost );
	array::thread_all( level.s2_pack_a_punch_triggers, &pack_a_punch_hint_string );
	array::thread_all( level.s2_pack_a_punch_triggers, &pack_a_punch_weapon_upgrade );
	array::thread_all( level.s2_pack_a_punch_triggers, &pack_a_punch_machine_trigger_think );
}

function pack_a_punch_spawn_init()
{
	if( !isdefined( self.model ) )
		return;

	self.machine = Spawn( "script_model", self.origin );
	self.machine.angles = self.angles;
	self.machine SetModel( self.model );
	self.machine.targetname = "fxanim_zmb_pack_a_punch_01";

	self.use_trigger = Spawn( "trigger_box_use", self.origin, 0, 64, 64, 64 );
	self.use_trigger TriggerIgnoreTeam();
	self.use_trigger SetHintString( &"ZOMBIE_NEED_POWER" );
	self.use_trigger SetCursorHint( "HINT_NOICON" );
	self.use_trigger.owner = self;

	level.s2_pack_a_punch_triggers[level.s2_pack_a_punch_triggers.size] = self.use_trigger;
}

function pack_a_punch_set_cost()
{
	level endon( "end_game" );

	while( true )
	{
		self.cost = 5000;
		self.aat_cost = 2500;

		level waittill( "powerup bonfire sale" );

		self.cost = 1000;
		self.aat_cost = 500;

		level waittill( "bonfire_sale_off" );
	}
}

function pack_a_punch_hint_string()
{
	level endon( "end_game" );

	level flag::wait_till( "power_on" );
	
	while( true )
	{
		foreach( player in GetPlayers() )
		{
			if( player IsTouching( self ) )
		    {
				self zm_pap_util::update_hint_string( player );
			}
		}
		
		WAIT_SERVER_FRAME;
	}
}

function pack_a_punch_weapon_upgrade()
{
	level endon( "end_game" );

	level flag::wait_till( "power_on" );

	while( true )
	{
		self.pack_player = undefined;

		self waittill( "trigger", player );

		if(	!player pack_a_punch_player_can_use_trigger( self ) )
		{
			continue;
		}
			
		current_weapon = player zm_weapons::switch_from_alt_weapon( player GetCurrentWeapon() );

 		if( !zm_weapons::is_weapon_or_base_included( current_weapon ) )
		{
			continue;
		}

 		current_cost = self.cost;
 		player.restore_ammo = undefined;
 		player.restore_clip = undefined;
 		player.restore_stock = undefined;
		player_restore_clip_size = undefined;
 		player.restore_max = undefined;
 		
 		weapon_supports_aat = zm_weapons::weapon_supports_aat( current_weapon );

 		if( weapon_supports_aat )
 		{
	 		current_cost = self.aat_cost;
	 		player.restore_ammo = true;
	 		player.restore_clip = player GetWeaponAmmoClip( current_weapon );
	 		player.restore_clip_size = current_weapon.clipSize;
	 		player.restore_stock = player GetWeaponAmmoStock( current_weapon );
	 		player.restore_max = current_weapon.maxAmmo;
 		}

		if( !player zm_score::can_player_purchase( current_cost ) )
		{
			self playsound( "zmb_perks_packa_deny" );

			if( isdefined( level.pack_a_punch.custom_deny_func ) )
			{
				player [[level.pack_a_punch.custom_deny_func]]();
			}
			else
			{
				player zm_audio::create_and_play_dialog( "general", "outofmoney", 0 );
			}

			continue;
		}
		
		self.pack_player = player;
		self flag::set( "pack_machine_in_use" );
		player zm_score::minus_to_player_score( current_cost );
		player zm_audio::create_and_play_dialog( "general", "pap_wait" );
		self TriggerEnable( false );

		upgrade_weapon = zm_weapons::get_upgrade_weapon( current_weapon, weapon_supports_aat );
		upgrade_weapon.pap_camo_to_use = zm_weapons::get_pack_a_punch_camo_index( upgrade_weapon.pap_camo_to_use );
		self.upgrade_weapon = upgrade_weapon;

		self pack_a_punch_spawn_weapon_model( player, current_weapon, upgrade_weapon );
		
		self TriggerEnable( true );
		self SetCursorHint( "HINT_WEAPON", upgrade_weapon );
		self flag::set( "pap_offering_gun" );

		if( isdefined( player ) )
		{
			self SetInvisibleToAll();
			self SetVisibleToPlayer( player );
		
			self thread pack_a_punch_wait_for_take( player, self.upgrade_weapon, weapon_supports_aat );
			self thread pack_a_punch_wait_for_timeout( player );
			
			self util::waittill_any( "pap_timeout", "pap_taken", "pap_player_disconnected" );
		}
		else
		{
			self pack_a_punch_wait_for_timeout( player );
		}
		
		self SetCursorHint( "HINT_NOICON" );
		self.upgrade_weapon = level.weaponNone;
		self pack_a_punch_delete_weapon_model();
		self flag::clear( "pap_offering_gun" );
		self thread pack_a_punch_machine_trigger_think();
		self.pack_player = undefined;
		self flag::clear( "pack_machine_in_use" );
	}
}

function pack_a_punch_machine_trigger_think()
{
	level endon( "end_game" );
	self notify( "pack_a_punch_trigger_think" );
	self endon( "pack_a_punch_trigger_think" );
	
	while( true )
	{
		players = GetPlayers();
		
		for( i = 0; i < players.size; i++ )
		{
			if( ( isdefined( self.pack_player ) && self.pack_player != players[i] ) || !players[i] pack_a_punch_player_can_use_trigger( self ) || players[i] bgb::is_active( "zm_bgb_ephemeral_enhancement" ) )
			{
				self SetInvisibleToPlayer( players[i], true );
			}
			else
			{
				self SetInvisibleToPlayer( players[i], false );
			}		
		}
		
		wait( 0.1 );
	}
}

function pack_a_punch_player_can_use_trigger( trigger )
{
	if( self laststand::player_is_in_laststand() || IS_TRUE( self.intermission ) || self IsThrowingGrenade() || self IsSwitchingWeapons() )
	{
		return false;
	}

	if( !self zm_magicbox::can_buy_weapon() || self bgb::is_enabled( "zm_bgb_disorderly_combat" ) )
	{
		return false;
	}

	if( self zm_equipment::hacker_active() )
	{
		return false;
	}

	current_weapon = self GetCurrentWeapon();
	if( !self pack_a_punch_player_can_pack_weapon( current_weapon, trigger ) && !zm_weapons::weapon_supports_aat( current_weapon ) )
	{
		return false;
	}

	return true;
}

function pack_a_punch_player_can_pack_weapon( weapon, trigger )
{
	if( weapon.isriotshield )
	{
		return false;
	}

	if( trigger flag::get( "pack_machine_in_use" ) )
	{
		return true;
	}

	weapon = self zm_weapons::get_nonalternate_weapon( weapon );
	if( !zm_weapons::is_weapon_or_base_included( weapon ) )
	{
		return false;
	}

	if( !self zm_weapons::can_upgrade_weapon( weapon ) )
	{
		return false;
	}

	return true;
}

function pack_a_punch_spawn_weapon_model( player, current_weapon, upgrade_weapon )
{
	level endon( "end_game" );
	self endon( "pap_player_disconnected" );

	weapon_model_origin = self.owner.machine GetTagOrigin( "lathe_02" );
	weapon_model_angles = self.owner.machine GetTagAngles( "lathe_02" ) + ( 0, 180, 0 );

	player zm_weapons::weapon_take( current_weapon );
	self.owner.machine playsound( "zmb_buildable_piece_add" );

	self.weapon_model = zm_utility::spawn_buildkit_weapon_model( player, current_weapon, undefined, weapon_model_origin, weapon_model_angles );

	dweapon = undefined;

	if( current_weapon.isDualWield || upgrade_weapon.isDualWield )
	{
		dweapon = current_weapon;
		
		if( isdefined( current_weapon.dualwieldweapon ) && current_weapon.dualwieldweapon != level.weaponNone )
		{
			dweapon = current_weapon.dualwieldweapon;
		}

		self.weapon_model_dw = zm_utility::spawn_buildkit_weapon_model( player, dweapon, undefined, self.weapon_model.origin - ( 3, 3, 3 ), self.weapon_model.angles );
	}

	self thread pack_a_punch_change_weapon_model( player, current_weapon, upgrade_weapon, dweapon );

	self.owner.machine scene::play( "zmb_pack_a_punch_01_bundle" );
}

function pack_a_punch_change_weapon_model( player, current_weapon, upgrade_weapon, dweapon )
{
	level endon( "end_game" );
	self endon( "pap_player_disconnected" );

	self.owner.machine waittill( "pack_a_punch_change_weapon_model" );

	self.weapon_model UseBuildKitWeaponModel( player, current_weapon, upgrade_weapon.pap_camo_to_use, true );

	if( isdefined( dweapon ) && isdefined( self.weapon_model_dw ) )
	{
		self.weapon_model_dw UseBuildKitWeaponModel( player, dweapon, upgrade_weapon.pap_camo_to_use, true );
	}
}

function pack_a_punch_delete_weapon_model()
{
	if( isdefined( self.weapon_model ) )
	{
		self.weapon_model Delete();
		self.weapon_model = undefined;
	}

	if( isdefined( self.weapon_model_dw ) )
	{
		self.weapon_model_dw Delete();
		self.weapon_model_dw = undefined;
	}
}

function pack_a_punch_wait_for_timeout( player )
{
	self endon( "pap_taken" );
	self endon( "pap_player_disconnected" );
	
	self thread pack_a_punch_wait_for_disconnect( player );
	
	wait( level.pack_a_punch.timeout );
	
	self notify( "pap_timeout" );
}

function pack_a_punch_wait_for_disconnect( player )
{
	self endon( "pap_taken" );
	self endon( "pap_timeout" );
	
	while( isdefined( player ) )
	{
		wait( 0.1 );
	}
	
	self notify( "pap_player_disconnected" );
}

function pack_a_punch_wait_for_take( player, upgrade_weapon, weapon_supports_aat )
{
	level endon( "end_game" );
	self endon( "pap_timeout" );
	
	while( isdefined( player ) )
	{
		self waittill( "trigger", trigger_player );
		
		if( IS_EQUAL( trigger_player, player ) )
		{
			current_weapon = player GetCurrentWeapon();

			if( pack_a_punch_player_can_take_weapon( player, current_weapon ) )
			{
				self notify( "pap_taken" );
				player notify( "pap_taken" );

				weapon_limit = zm_utility::get_player_weapon_limit( player );

				player zm_weapons::take_fallback_weapon();

				primaries = player GetWeaponsListPrimaries();

				if( isdefined( primaries ) && primaries.size >= weapon_limit )
				{
					upgrade_weapon = player zm_weapons::weapon_give( upgrade_weapon );
				}
				else
				{
					upgrade_weapon = player zm_weapons::give_build_kit_weapon( upgrade_weapon );
					player GiveStartAmmo( upgrade_weapon );
				}

				player notify( "weapon_give", upgrade_weapon );

				if( IS_TRUE( weapon_supports_aat ) )
				{
					player thread aat::acquire( upgrade_weapon );
				}
				else
				{
					player thread aat::remove( upgrade_weapon );
				}
				
				player SwitchToWeapon( upgrade_weapon );

				if( IS_TRUE( player.restore_ammo ) )
				{
					new_clip = player.restore_clip + ( upgrade_weapon.clipSize - player.restore_clip_size );
					new_stock = player.restore_stock + ( upgrade_weapon.maxAmmo - player.restore_max );
					player SetWeaponAmmoStock( upgrade_weapon, new_stock );
					player SetWeaponAmmoClip( upgrade_weapon, new_clip );
				}

		 		player.restore_ammo = undefined;
		 		player.restore_clip = undefined;
		 		player.restore_stock = undefined;
 				player.restore_max = undefined;
		 		player.restore_clip_size = undefined;
		 		
				player zm_weapons::play_weapon_vo( upgrade_weapon );

				return;
			}
		}

		WAIT_SERVER_FRAME;
	}
}

function pack_a_punch_player_can_take_weapon( player, current_weapon )
{
	if( !zm_utility::is_player_valid( player ) )
	{
		return false;
	}
	
	if( IS_DRINKING( player.is_drinking ) )
	{
		return false;
	}

	if( zm_utility::is_placeable_mine( current_weapon ) )
	{
		return false;
	}

	if( zm_equipment::is_equipment( current_weapon ) )
	{
		return false;
	}

	if( player zm_utility::is_player_revive_tool( current_weapon ) )
	{
		return false;
	}

	if( IS_EQUAL( level.weaponNone, current_weapon ) )
	{
		return false;
	}

	if( player zm_equipment::hacker_active() )
	{
		return false;
	}

	return true;
}
