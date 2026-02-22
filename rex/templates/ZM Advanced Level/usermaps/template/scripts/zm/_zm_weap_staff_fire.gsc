#using scripts\codescripts\struct;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\math_shared;
#using scripts\shared\system_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\util_shared;
#using scripts\shared\ai\systems\gib;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\ai\zombie_death;
#using scripts\zm\_zm;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weap_staff_common;
#using scripts\shared\ai\systems\behavior_tree_utility;
#insert scripts\shared\ai\systems\behavior_tree.gsh;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_utility.gsh;

#precache( "model", "wpn_t7_zmb_hd_staff_fire_world" );
#precache( "model", "wpn_t7_zmb_hd_staff_fire_upgraded_world" );
#precache( "fx", "dlc5/tomb/fx_tomb_elem_reveal_fire_glow" );

#namespace zm_weap_staff_fire; 

REGISTER_SYSTEM_EX( "zm_weap_staff_fire", &__init__, &__main__, undefined )

function __init__()
{	
	behaviortreenetworkutility::registerbehaviortreescriptapi( "wasstunnedbyfirestaff", &was_stunned_by_fire_staff );
	behaviortreenetworkutility::registerbehaviortreescriptapi( "zombiestunfireactionend", &zombie_stun_fire_action_end );
	behaviortreenetworkutility::registerbehaviortreescriptapi( "waskilledbyfirestaff", 	&is_staff_fire_damage );

	level.a_staff_fire_weaponfiles = [];

	staff_fire_register_weapon_for_level( "staff_fire", undefined, &staff_fire_fired );
	staff_fire_register_weapon_for_level( "staff_fire_upgraded", undefined, &staff_fire_fired );
	staff_fire_register_weapon_for_level( "staff_fire_upgraded2", undefined, undefined, &staff_fire_upgrade_fired );
	staff_fire_register_weapon_for_level( "staff_fire_upgraded3", undefined, undefined, &staff_fire_upgrade_fired );

	clientfield::register( "scriptmover", "staff_fire_volcano_fx",	VERSION_SHIP, 1, "int" );
	clientfield::register( "actor", "staff_fire_burn_zombie", VERSION_SHIP,  1, "int" );
	clientfield::register( "vehicle", "staff_fire_burn_zombie", VERSION_SHIP, 1, "int" );

	zm::register_actor_damage_callback( &staff_fire_zombie_actor_damagestaff_weapon );
	zm::register_vehicle_damage_callback( &staff_fire_vehicle_damagestaff_weapon );

	zm_spawner::register_zombie_damage_callback( &staff_fire_zombie_damagestaff_weapon );
	zm_spawner::register_zombie_death_event_callback( &staff_fire_death_eventstaff_weapon );

	level.staff_fire_zombie_set_and_restore_flame_state = &staff_fire_zombie_set_and_restore_flame_state;

	spawner::add_archetype_spawn_function( "parasite", &staff_fire_parasite_initstaff_weapon, undefined, undefined, undefined, undefined, undefined );
	spawner::add_archetype_spawn_function( "zombie_dog", &staff_fire_dog_initstaff_weapon, undefined, undefined, undefined, undefined, undefined );
}

function __main__()
{
	
}

function staff_fire_register_weapon_for_level( str_weapon, staff_weapon_fired = undefined, staff_weapon_missile_fired = undefined, staff_weapon_grenade_fired = undefined, staff_weapon_obtained = undefined, staff_weapon_lost = undefined, staff_weapon_reloaded = undefined, staff_weapon_pullout = undefined, staff_weapon_putaway = undefined )
{
	DEFAULT( level.a_staff_fire_weaponfiles,[]);
	
	a_weapon_data = tableLookupRow( "gamedata/weapons/zm/staff_fire_settings.csv", tableLookupRowNum( "gamedata/weapons/zm/staff_fire_settings.csv", 0, str_weapon ));
	if ( !isDefined( a_weapon_data ) )
		a_weapon_data = tableLookupRow( "gamedata/weapons/zm/staff_fire_settings.csv", tableLookupRowNum( "gamedata/weapons/zm/staff_fire_settings.csv", 0, "default" ));
	if ( !isDefined( a_weapon_data ) )	
		return;
		
	w_weapon = getWeapon( str_weapon );
	w_weapon.b_is_upgrade = ( toLower( a_weapon_data[ true ] ) == "true" );
	w_weapon.n_damage = int( a_weapon_data[ 2 ]	);
	w_weapon.n_burn_damage = int( a_weapon_data[ 3 ] );
	w_weapon.n_burn_duration = float( a_weapon_data[ 4 ] );
	w_weapon.n_volcano_range = int( a_weapon_data[ 5 ] );
	w_weapon.n_volcano_lifetime	= float( a_weapon_data[ 6 ] );
	
	zm_weap_staff_common::register_staff_weapon_for_level( w_weapon, staff_weapon_fired, staff_weapon_missile_fired, staff_weapon_grenade_fired, staff_weapon_obtained, staff_weapon_lost, staff_weapon_reloaded, staff_weapon_pullout, staff_weapon_putaway);
	
	ARRAY_ADD( level.a_staff_fire_weaponfiles, w_weapon	);
}

function staff_fire_zombie_actor_damagestaff_weapon( e_inflictor, e_attacker, n_damage, f_flags, str_means_of_death, w_weapon, v_point, v_direction, str_hit_loc, n_offset_time, n_bone_index, str_surface_type )
{
	if ( !isDefined( e_attacker ) || !isPlayer( e_attacker ) )
		return -1;
	
	if ( !zm_weap_staff_common::is_staff_weapon( w_weapon, level.a_staff_fire_weaponfiles ) )
		return -1;
	
	if ( zm_weap_staff_common::is_upgraded_staff_weapon( w_weapon ) && IS_TRUE( self.b_staff_fire_upgraded_immune ) )
		return 0;
	else if ( !zm_weap_staff_common::is_upgraded_staff_weapon( w_weapon ) && IS_TRUE( self.b_staff_fire_immune ) )
		return 0;
	
	if ( str_means_of_death == "MOD_MELEE" )
		return -1;
	
	if ( str_means_of_death != "MOD_BURNED" )
	{
		n_pct_from_center = ( n_damage - 1 ) / 10;
		n_pct_damage = .5 + ( .5 * n_pct_from_center );
		
		n_damage = ( ( isDefined( e_attacker ) && isPlayer( e_attacker ) && e_attacker zm_powerups::is_insta_kill_active() ) ? self.health + 666 : int( n_pct_damage * w_weapon.n_damage ) );
				
		if ( isDefined( self.staff_fire_actor_damagestaff_weapon ) )
			n_damage = [ [ self.staff_fire_actor_damagestaff_weapon ] ]( e_inflictor, e_attacker, n_damage, f_flags, str_means_of_death, w_weapon, v_point, v_direction, str_hit_loc, n_offset_time, n_bone_index, str_surface_type );
		
		if ( ( IS_TRUE( self.in_the_ground ) || IS_TRUE( self.in_the_ceiling ) ) || ( isDefined( w_weapon ) && IS_TRUE( w_weapon.b_is_upgrade ) && n_pct_from_center > .5 && n_damage > self.health && math::cointoss() ) )
			self.b_staff_fire_death_will_gib = 1;
			
		return n_damage;
	}
	return -1;
}

function staff_fire_vehicle_damagestaff_weapon( e_inflictor, e_attacker, n_damage, str_flags, str_means_of_death, w_weapon, v_point, v_direction, str_hit_loc, v_damage_origin, n_offset_time, b_damage_drom_underneath, n_model_index, str_part_name, str_surface_type )
{
	if ( !isDefined( e_attacker ) || !isPlayer( e_attacker ) )
		return n_damage;
	
	if ( !isDefined( self.damageweapon ) || self.damageweapon != w_weapon )
		self.damageweapon = w_weapon;
	if ( !isDefined( self.damagemod ) || self.damagemod != str_means_of_death )
		self.damagemod = str_means_of_death;
	if ( !isDefined( self.damagehit_origin ) || self.damagehit_origin != v_point )
		self.damagehit_origin = v_point;
	if ( !isDefined( self.damagelocation ) || self.damagelocation != str_hit_loc )
		self.damagelocation = str_hit_loc;
		
	if ( !zm_weap_staff_common::is_staff_weapon( w_weapon, level.a_staff_fire_weaponfiles ) )
		return n_damage;
	if ( zm_weap_staff_common::is_upgraded_staff_weapon( w_weapon ) && IS_TRUE( self.b_staff_fire_upgraded_immune ) )
		return 0;
	else if ( !zm_weap_staff_common::is_upgraded_staff_weapon( w_weapon ) && IS_TRUE( self.b_staff_fire_immune ) )
		return 0;
	
	if ( str_means_of_death == "MOD_MELEE" )
		return n_damage;
	
	if ( str_means_of_death != "MOD_BURNED" )
	{
		n_pct_from_center = ( n_damage - 1 ) / 10;
		n_pct_damage = .5 + ( .5 * n_pct_from_center );
		
		n_damage = ( ( isDefined( e_attacker ) && isPlayer( e_attacker ) && e_attacker zm_powerups::is_insta_kill_active() ) ? self.health + 666 : int( n_pct_damage * w_weapon.n_damage ) );
		
		if ( isDefined( self.staff_fire_vehicle_damagestaff_weapon ) )
			n_damage = [ [ self.staff_fire_vehicle_damagestaff_weapon ] ]( e_inflictor, e_attacker, n_damage, str_flags, str_means_of_death, w_weapon, v_point, v_direction, str_hit_loc, v_damage_origin, n_offset_time, b_damage_drom_underneath, n_model_index, str_part_name, str_surface_type );
		
		if ( isDefined( w_weapon ) && IS_TRUE( w_weapon.b_is_upgrade ) && n_pct_from_center > .5 && n_damage > self.health && math::cointoss() )
			self.b_staff_fire_death_will_gib = 1;
		
	}
	return n_damage;
}

function staff_fire_zombie_damagestaff_weapon( str_means_of_death, str_hit_loc, v_point, e_attacker, n_damage, w_weapon, v_direction, str_tag_name, str_model_name, str_part_name, f_flags, e_inflictor, n_charge_level )
{
	if ( !isDefined( e_attacker ) || !isPlayer( e_attacker ) )
		return 0;
	
	if ( !zm_weap_staff_common::is_staff_weapon( w_weapon, level.a_staff_fire_weaponfiles ) || str_means_of_death == "MOD_MELEE" )
		return 0;
	
	if ( isDefined( self.staff_fire_zombie_damagestaff_weapon ) )
		return [ [ self.staff_fire_zombie_damagestaff_weapon ] ]( str_means_of_death, str_hit_loc, v_point, e_attacker, n_damage, w_weapon, v_direction, str_tag_name, str_model_name, str_part_name, f_flags, e_inflictor, n_charge_level );
	else
		self thread staff_fire_flame_damage_fx( w_weapon, e_attacker, float( n_damage / w_weapon.n_damage ) );
	
	return 1;
}

function staff_fire_death_eventstaff_weapon( e_attacker )
{
	if ( !isDefined( e_attacker ) || !isPlayer( e_attacker ) )
		return;
	
	if ( !isDefined( self ) || !zm_weap_staff_common::is_staff_weapon( self.damageweapon, level.a_staff_fire_weaponfiles ) || self.damagemod == "MOD_MELEE" )
		return;
	
	self setCanDamage( 0 );
	
	if ( isDefined( self.staff_fire_deathstaff_weapon ) )
		self [ [ self.staff_fire_deathstaff_weapon ] ]( e_attacker );
	else
	{
		self clientfield::set( "staff_fire_burn_zombie", 1 );
		self thread zombie_utility::zombie_eye_glow_stop();		
	}
}

function staff_fire_fired( e_projectile, w_weapon, n_charge_level )
{
	self thread staff_fire_spread_shots( w_weapon );
}

function staff_fire_upgrade_fired( e_projectile, w_weapon, n_charge_level )
{
	e_projectile thread staff_fire_find_source( self, w_weapon, n_charge_level );
	self thread staff_fire_additional_shots( w_weapon, n_charge_level );
}

function staff_fire_spread_shots( w_weapon )
{
	util::wait_network_frame();
	util::wait_network_frame();
	
	v_fwd = self getWeaponForwardDir();
	v_fire_angles = vectorToAngles( v_fwd );
	v_fire_origin = self getWeaponMuzzlePoint();
	
	n_trace = bulletTrace( v_fire_origin, v_fire_origin + v_fwd * 100, 0, undefined );
	if ( n_trace[ "fraction" ] != 1 )
		return;
	
	v_left_angles = ( v_fire_angles[ 0 ], v_fire_angles[ 1 ] - 15, v_fire_angles[ 2 ] );
	v_left = anglesToForward( v_left_angles );
	e_proj = magicBullet( w_weapon, v_fire_origin + v_fwd * 50, v_fire_origin + v_left * 100, self );
	e_proj.b_additional_shot = 1;
	
	util::wait_network_frame();
	util::wait_network_frame();
	
	v_fwd = self getWeaponForwardDir();
	v_fire_angles = vectorToAngles( v_fwd );
	v_fire_origin = self getWeaponMuzzlePoint();
	
	n_trace = bulletTrace( v_fire_origin, v_fire_origin + v_fwd * 100, 0, undefined );
	if ( n_trace[ "fraction" ] != 1 )
		return;
	
	v_right_angles = ( v_fire_angles[ 0 ], v_fire_angles[ 1 ] + 15, v_fire_angles[ 2 ] );
	v_right = anglesToForward( v_right_angles );
	e_proj = magicBullet( w_weapon, v_fire_origin + v_fwd * 50, v_fire_origin + v_right * 100, self );
	e_proj.b_additional_shot = 1;
}

function staff_fire_flame_damage_fx( w_weapon, e_attacker, n_pct_damage = 1 )
{
	self endon( "death" );
	if ( IS_TRUE( self.is_on_fire ) )
		return;
	
	self.is_on_fire = 1;
	self thread staff_fire_zombie_set_and_restore_flame_state();
	wait .5;
	self thread staff_fire_flame_damage_over_time( e_attacker, w_weapon, n_pct_damage );
}

function staff_fire_flame_damage_over_time( e_attacker, w_weapon, n_pct_damage )
{
	e_attacker endon( "disconnect" );
	self endon( "death" );
	self endon( "stop_flame_damage" );
	
	self thread staff_fire_on_fire_timeout( w_weapon.n_burn_duration );
	while ( isDefined( self ) )
	{
		if ( isDefined( e_attacker ) && isPlayer( e_attacker ) )
			self zm_weap_staff_common::staff_do_damage( int( w_weapon.n_burn_damage * n_pct_damage ), self.origin, e_attacker, e_attacker, undefined, "MOD_BURNED", 0, w_weapon, undefined, undefined );
			
		wait 1;
	}
}

function staff_fire_additional_shots( w_weapon, n_charge_level )
{
	self endon( "disconnect" );
	self endon( "death" );
	self endon( "weapon_change" );
	
	for ( i = 1; i < n_charge_level; i++ )
	{
		wait .35;		
		
		v_player_angles = vectorToAngles( self getWeaponForwardDir() );
		n_player_pitch = v_player_angles[ 0 ] + 5 * i;
		n_player_yaw = v_player_angles[ 1 ] + randomFloatRange( -15, 15 );
		v_shot_angles = ( n_player_pitch, n_player_yaw, v_player_angles[ 2 ] );
		
		v_shot_start = self getWeaponMuzzlePoint();
		v_shot_end = v_shot_start + anglesToForward( v_shot_angles );
		
		e_projectile = magicBullet( w_weapon, v_shot_start, v_shot_end, self );
		e_projectile.b_additional_shot = 1;
		
		e_projectile thread staff_fire_find_source( self, w_weapon, n_charge_level );
		util::wait_network_frame();
	}
}

function waittill_not_moving()
{
	self endon( "death" );
	self endon( "explode" );
	self endon( "stationary" );

	prevorigin = self.origin;
	while ( 1 )
	{
		wait .15;
		if ( self.origin == prevorigin )
			break;
	
		prevorigin = self.origin;
	}
	
	self notify( "stationary" );
}


function staff_fire_update_grenade_fuse( e_player )
{
	e_player endon( "disconnect" );
	self endon( "grenade_dud" );
	self thread waittill_not_moving();
	self util::waittill_any( "stationary", "grenade_bounce", "death" );
	if ( isDefined( self ) )
		self resetMissileDetonationTime( 0 );
	
}

function staff_fire_find_source( e_player, w_weapon, n_charge_level )
{
	e_player endon( "disconnect" );
	self thread staff_fire_update_grenade_fuse( e_player );
	self waittill( "explode", v_impact_origin );
	e_player thread staff_fire_position_volcano( v_impact_origin, w_weapon, n_charge_level );
}

function staff_fire_position_volcano( v_impact_origin, w_weapon, n_charge_level )
{
	e_fx_model = util::spawn_model( "tag_origin", v_impact_origin );
	e_fx_model endon( "death" );
	e_fx_model clientfield::set( "staff_fire_volcano_fx", 1 );
	e_fx_model staff_fire_volcano_kill_zombies( w_weapon, self, n_charge_level );
	e_fx_model clientfield::set( "staff_fire_volcano_fx", 0 );
	wait 4;
	e_fx_model delete();
}

function staff_fire_volcano_kill_zombies( w_weapon, e_player, n_charge_level )
{
	e_player endon( "death_or_disconnect" );
	self endon( "death" );
	
	n_alive_time = w_weapon.n_volcano_lifetime;
	while ( n_alive_time > 0 && isDefined( self ) )
	{
		a_zombies = self staff_fire_volcano_effected_zombies( w_weapon, n_alive_time );
		array::thread_all( a_zombies, &staff_fire_volcano_damage_zombie, w_weapon, e_player );
		
		wait .2;
		n_alive_time -= .2;
	}
}

function staff_fire_volcano_effected_zombies( w_weapon, n_alive_time )
{
	return array::filter( util::get_array_of_closest( self.origin, getAITeamArray( level.zombie_team ), undefined, undefined, undefined ), 1, &staff_fire_volcano_effect_zombie_valid, self, ( ( n_alive_time - .2 <= 0 ) ? w_weapon.n_volcano_range * 2 : w_weapon.n_volcano_range ) );
}

function staff_fire_volcano_effect_zombie_valid( e_ai_zombie, e_volcano, n_volcano_range )
{
	return ( !IS_TRUE( e_ai_zombie.b_staff_fire_volcano_immune ) && zm_weap_staff_common::staff_distance_2d_squared_passed( e_volcano.origin, e_ai_zombie.origin, n_volcano_range, e_ai_zombie.n_staff_fire_volcano_range_check_multiplier ) && !IS_TRUE( e_ai_zombie.is_on_fire ) && isAlive( e_ai_zombie ) && zm_weap_staff_common::staff_trace_passed( e_volcano.origin, e_ai_zombie.origin ) );
}

function staff_fire_volcano_damage_zombie( w_weapon, e_attacker )
{
	self thread staff_fire_flame_damage_fx( w_weapon, e_attacker );
}

function staff_fire_zombie_set_and_restore_flame_state()
{
	self endon( "death" );
	if ( !isAlive( self ) )
		return;
	
	self.b_staff_fire_stunned = 1;
	self zombie_utility::set_zombie_run_cycle_override_value( "burned" );
	self clientfield::set( "staff_fire_burn_zombie", 1 );
	self waittill( "stop_flame_damage" );
	self clientfield::set( "staff_fire_burn_zombie", 0 );
	self zombie_utility::set_zombie_run_cycle_restore_from_override();
}

function staff_fire_on_fire_timeout( n_duration )
{
	self endon( "death" );
	wait n_duration;
	self.is_on_fire = undefined;
	self notify( "stop_flame_damage" );
}

function staff_fire_parasite_initstaff_weapon()
{
	self.n_staff_fire_volcano_range_check_multiplier = 1.8;
	self.staff_fire_vehicle_damagestaff_weapon = &staff_fire_parasite_damagestaff_weapon;
	self.staff_fire_zombie_damagestaff_weapon = &staff_fire_parasite_zombie_damagestaff_weapon;
	self.staff_fire_deathstaff_weapon = &staff_fire_parasite_deathstaff_weapon;
}

function staff_fire_parasite_damagestaff_weapon( e_inflictor, e_attacker, n_damage, str_flags, str_means_of_death, w_weapon, v_point, v_direction, str_hit_loc, v_damage_origin, n_offset_time, b_damage_drom_underneath, n_model_index, str_part_name, str_surface_type )
{
	return self.health + 666;
}

function staff_fire_parasite_zombie_damagestaff_weapon( str_means_of_death, str_hit_loc, v_point, e_attacker, n_damage, w_weapon, v_direction, str_tag_name, str_model_name, str_part_name, f_flags, e_inflictor, n_charge_level )
{
	return 1;
}

function staff_fire_parasite_deathstaff_weapon( e_attacker )
{
	self thread zm_weap_staff_common::zombie_gib_all( "j_spine" );
}

function staff_fire_dog_initstaff_weapon()
{
	self.staff_fire_actor_damagestaff_weapon = &staff_fire_dog_damagestaff_weapon;
	self.staff_fire_zombie_damagestaff_weapon = &staff_fire_dog_zombie_damagestaff_weapon;
	self.staff_fire_deathstaff_weapon = &staff_fire_dog_deathstaff_weapon;
}

function staff_fire_dog_damagestaff_weapon( e_inflictor, e_attacker, n_damage, f_flags, str_means_of_death, w_weapon, v_point, v_direction, str_hit_loc, n_offset_time, n_bone_index, str_surface_type )
{
	return self.health + 666;
}

function staff_fire_dog_zombie_damagestaff_weapon( str_means_of_death, str_hit_loc, v_point, e_attacker, n_damage, w_weapon, v_direction, str_tag_name, str_model_name, str_part_name, f_flags, e_inflictor, n_charge_level )
{
	return 1;
}

function staff_fire_dog_deathstaff_weapon( e_attacker )
{
	self thread zm_weap_staff_common::zombie_gib_all( "j_spine" );
}


function private was_stunned_by_fire_staff( behavior_tree_entity )
{
	return IS_TRUE( behavior_tree_entity.b_staff_fire_stunned );
}

function private zombie_stun_fire_action_end( behavior_tree_entity )
{
	behavior_tree_entity.b_staff_fire_stunned = undefined;
	return BHTN_SUCCESS;
}

function private is_staff_fire_damage( behavior_tree_entity )
{
	if ( !isDefined( level.is_staff_weapon ) || behavior_tree_entity.damagemod == "MOD_MELEE" )
		return 0;
	
	return [ [ level.is_staff_weapon ] ]( behavior_tree_entity.damageweapon, level.a_staff_fire_weaponfiles );
}
