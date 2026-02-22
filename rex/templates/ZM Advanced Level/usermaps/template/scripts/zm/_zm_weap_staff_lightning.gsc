#using scripts\codescripts\struct;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\util_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\system_shared;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\ai\systems\blackboard;
#using scripts\shared\ai\systems\behavior_tree_utility;
#using scripts\zm\_zm;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weap_staff_common;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\shared\ai\systems\blackboard.gsh;
#insert scripts\shared\ai\systems\behavior_tree.gsh;
#insert scripts\zm\_zm_utility.gsh;

#precache( "model", "wpn_t7_zmb_hd_staff_lightning_world" );
#precache( "model", "wpn_t7_zmb_hd_staff_lightning_upgraded_world" );
#precache( "fx", "dlc5/tomb/fx_tomb_elem_reveal_elec_glow" );
#precache( "fx", "dlc5/zmb_weapon/fx_staff_elec_trail_bolt_cheap" );

#namespace zm_weap_staff_lightning; 

REGISTER_SYSTEM_EX( "zm_weap_staff_lightning", &__init__, &__main__, undefined )

function __init__()
{	

	behaviortreenetworkutility::registerbehaviortreescriptapi( "waskilledbylightningstaff", &is_staff_lightning_damage );
	behaviortreenetworkutility::registerbehaviortreescriptapi( "wasstunnedbylightningstaff", &was_stunned_by_lightning_staff );
	behaviortreenetworkutility::registerbehaviortreescriptapi( "zombiestunlightningactionend", &zombie_stun_lightning_action_end );
	
	level.a_staff_lightning_weaponfiles = [];

	staff_lightning_register_weapon_for_level( "staff_bolt", undefined, &staff_lightning_fired );
	staff_lightning_register_weapon_for_level( "staff_bolt_upgraded", undefined, &staff_lightning_fired );
	staff_lightning_register_weapon_for_level( "staff_bolt_upgraded2", undefined, &staff_lightning_upgrade_fired );
	staff_lightning_register_weapon_for_level( "staff_bolt_upgraded3", undefined, &staff_lightning_upgrade_fired );
	
	clientfield::register( "scriptmover", "staff_lightning_ball_fx", VERSION_SHIP, 1, "int" );
	clientfield::register( "actor", "staff_lightning_impact_fx",VERSION_SHIP, 1, "counter" );
	clientfield::register( "vehicle", "staff_lightning_impact_fx_veh", VERSION_SHIP, 1, "counter" );
	clientfield::register( "actor", "staff_lightning_shock_eyes_fx", VERSION_SHIP, 1, "counter"	);
	clientfield::register( "vehicle", "staff_lightning_shock_eyes_fx_veh", VERSION_SHIP, 1, "counter" );

	zm::register_actor_damage_callback( &staff_lightning_zombie_actor_damage );
	zm::register_vehicle_damage_callback( &staff_lightning_vehicle_damage );
	zm_spawner::register_zombie_damage_callback( &staff_lightning_zombie_damage );
	zm_spawner::register_zombie_death_event_callback( &staff_lightning_death_event );
	
	level.staff_lightning_zombie_shockd_fx = &staff_lightning_zombie_shocked_fx;
	level.staff_lightning_stun_zombie = &staff_lightning_stun_zombie;

	spawner::add_archetype_spawn_function( "parasite", &staff_lightning_parasite_init, undefined, undefined, undefined, undefined, undefined );
	spawner::add_archetype_spawn_function( "zombie_dog", &staff_lightning_dog_init, undefined, undefined, undefined, undefined, undefined );
}

function __main__()
{
}

function staff_lightning_register_weapon_for_level( str_weapon, staff_weapon_fired = undefined, staff_weapon_missile_fired = undefined, staff_weapon_grenade_fired = undefined, staff_weapon_obtained = undefined, staff_weapon_lost = undefined, staff_weapon_reloaded = undefined, staff_weapon_pullout = undefined, staff_weapon_putaway = undefined )
{
	DEFAULT( level.a_staff_lightning_weaponfiles, [] );
	
	a_weapon_data = tableLookupRow( "gamedata/weapons/zm/staff_bolt_settings.csv", tableLookupRowNum( "gamedata/weapons/zm/staff_bolt_settings.csv", 0, str_weapon ));
	if ( !isDefined( a_weapon_data ) )
		a_weapon_data = tableLookupRow( "gamedata/weapons/zm/staff_bolt_settings.csv", tableLookupRowNum( "gamedata/weapons/zm/staff_bolt_settings.csv", 0, "default" ));
	if ( !isDefined( a_weapon_data ) )	
		return;
		
	w_weapon = getWeapon( str_weapon );
	w_weapon.b_is_upgrade = ( toLower( a_weapon_data[ true ] ) == "true" );
	w_weapon.n_damage = int( a_weapon_data[ 2 ] );
	w_weapon.n_min_damage = int( a_weapon_data[ 3 ] );
	w_weapon.n_ball_move_distance = int( a_weapon_data[ 4 ] );
	w_weapon.n_ball_damage_per_second = int( a_weapon_data[ 5 ] );
	w_weapon.n_ball_range = int( a_weapon_data[ 6 ] );
	
	zm_weap_staff_common::register_staff_weapon_for_level( 	w_weapon, staff_weapon_fired, staff_weapon_missile_fired, staff_weapon_grenade_fired, staff_weapon_obtained, staff_weapon_lost, staff_weapon_reloaded, staff_weapon_pullout, staff_weapon_putaway );
	
	ARRAY_ADD( level.a_staff_lightning_weaponfiles, w_weapon );
}

function staff_lightning_zombie_actor_damage( e_inflictor, e_attacker, n_damage, f_flags, str_means_of_death, w_weapon, v_point, v_direction, str_hit_loc, n_offset_time, n_bone_index, str_surface_type )
{
	if ( !isDefined( e_attacker ) || !isPlayer( e_attacker ) )
		return -1;
	
	if ( !zm_weap_staff_common::is_staff_weapon( w_weapon, level.a_staff_lightning_weaponfiles ) )
		return -1;
	
	if ( zm_weap_staff_common::is_upgraded_staff_weapon( w_weapon ) && IS_TRUE( self.b_staff_lightning_upgraded_immune ) )
		return 0;
	else if ( !zm_weap_staff_common::is_upgraded_staff_weapon( w_weapon ) && IS_TRUE( self.b_staff_lightning_immune ) )
		return 0;
	
	if ( str_means_of_death == "MOD_MELEE" )
		return -1;
	
	if ( str_means_of_death != "MOD_RIFLE_BULLET" )
	{		
		b_instakill_active = ( isDefined( e_attacker ) && isPlayer( e_attacker ) && e_attacker zm_powerups::is_insta_kill_active() );
		if ( IS_TRUE( b_instakill_active ) )
			n_damage = self.health + 666;
		else
		{
			n_min_damage = w_weapon.n_min_damage;
			n_max_damage = w_weapon.n_damage;
			n_difference = n_max_damage - n_min_damage;
			
			n_pct_from_center = ( n_damage - 1 ) / 10;
			n_new_damage = int( n_pct_from_center * n_difference );
			
			n_damage = int( n_min_damage + n_new_damage );
		}
		
		if ( isDefined( self.staff_lightning_actor_damage ) )
			return [ [ self.staff_lightning_actor_damage ] ]( e_inflictor, e_attacker, n_damage, f_flags, str_means_of_death, w_weapon, v_point, v_direction, str_hit_loc, n_offset_time, n_bone_index, str_surface_type );

		return n_damage;
	}
	return -1;
}

function staff_lightning_vehicle_damage( e_inflictor, e_attacker, n_damage, str_flags, str_means_of_death, w_weapon, v_point, v_direction, str_hit_loc, v_damage_origin, n_offset_time, b_damage_drom_underneath, n_model_index, str_part_name, str_surface_type )
{
	if ( !isDefined( e_attacker ) || !isPlayer( e_attacker ) )
		return n_damage;
	
	if ( !isDefined( self.damageweapon ) || self.damageweapon != w_weapon )
		self.damageweapon = w_weapon;
	if ( !isDefined( self.damagemod ) || self.damagemod != str_means_of_death )
		self.damagemod = str_means_of_death;
	
	if ( !zm_weap_staff_common::is_staff_weapon( w_weapon, level.a_staff_lightning_weaponfiles ) )
		return n_damage;
	
	if ( zm_weap_staff_common::is_upgraded_staff_weapon( w_weapon ) && IS_TRUE( self.b_staff_lightning_upgraded_immune ) )
		return 0;
	else if ( !zm_weap_staff_common::is_upgraded_staff_weapon( w_weapon ) && IS_TRUE( self.b_staff_lightning_immune ) )
		return 0;
	
	if ( str_means_of_death == "MOD_MELEE" )
		return n_damage;
	
	if ( str_means_of_death != "MOD_RIFLE_BULLET" )
	{	
		b_instakill_active = ( isDefined( e_attacker ) && isPlayer( e_attacker ) && e_attacker zm_powerups::is_insta_kill_active() );
		if ( IS_TRUE( b_instakill_active ) )
			n_damage = self.health + 666;
		else
		{
			n_min_damage = w_weapon.n_min_damage;
			n_max_damage = w_weapon.n_damage;
			n_difference = n_max_damage - n_min_damage;
			
			n_pct_from_center = ( n_damage - 1 ) / 10;
			n_new_damage = int( n_pct_from_center * n_difference );
			
			n_damage = int( n_min_damage + n_new_damage );
		}
		
		if ( isDefined( self.staff_lightning_vehicle_damage ) )
			return [ [ self.staff_lightning_vehicle_damage ] ]( e_inflictor, e_attacker, n_damage, str_flags, str_means_of_death, w_weapon, v_point, v_direction, str_hit_loc, v_damage_origin, n_offset_time, b_damage_drom_underneath, n_model_index, str_part_name, str_surface_type );

		return n_damage;
	}
	return n_damage;
}

function staff_lightning_zombie_damage( str_means_of_death, str_hit_loc, v_point, e_attacker, n_damage, w_weapon, v_direction, str_tag_name, str_model_name, str_part_name, f_flags, e_inflictor, n_charge_level )
{
	if ( !isDefined( e_attacker ) || !isPlayer( e_attacker ) )
		return 0;
	
	if ( !zm_weap_staff_common::is_staff_weapon( w_weapon, level.a_staff_lightning_weaponfiles ) || str_means_of_death == "MOD_MELEE" )
		return 0;
	
	if ( isDefined( self.staff_lightning_zombie_damage ) )
		return [ [ self.staff_lightning_zombie_damage ] ]( str_means_of_death, str_hit_loc, v_point, e_attacker, n_damage, w_weapon, v_direction, str_tag_name, str_model_name, str_part_name, f_flags, e_inflictor, n_charge_level );
	
	self thread staff_lightning_stun_zombie();
	
	return 1;
}

function staff_lightning_death_event( e_attacker )
{
	if ( !isDefined( e_attacker ) || !isPlayer( e_attacker ) )
		return;
	
	if ( !isDefined( self ) || !zm_weap_staff_common::is_staff_weapon( self.damageweapon, level.a_staff_lightning_weaponfiles ) || self.damagemod == "MOD_MELEE" )
		return;
	
	self setCanDamage( 0 );
	if ( isDefined( self.staff_lightning_death ) )
		self [ [ self.staff_lightning_death ] ]( e_attacker, self.damagemod );	
	else
	{
		self clientfield::increment( ( isVehicle( self ) ? "staff_lightning_impact_fx_veh" : "staff_lightning_impact_fx" ), 1 );
		self clientfield::increment( ( isVehicle( self ) ? "staff_lightning_shock_eyes_fx_veh" : "staff_lightning_shock_eyes_fx" ), 2 );
		
		self thread staff_lightning_stun_zombie();
		self thread zombie_utility::zombie_eye_glow_stop();
	}
}

function staff_lightning_fired( e_projectile, w_weapon, n_charge_level )
{
}

function staff_lightning_upgrade_fired( e_projectile, w_weapon, n_charge_level )
{
	e_projectile thread staff_lightning_position_ball( self, w_weapon, n_charge_level );
}

function staff_lightning_position_ball( e_player, w_weapon, n_charge_level )
{
	v_fire_angles = vectorToAngles( e_player getWeaponForwardDir() );
	v_fire_origin = e_player getWeaponMuzzlePoint();
	v_fire_origin = v_fire_origin + anglesToForward( v_fire_angles ) * 100;
	
	e_fx_model = util::spawn_model( "tag_origin", v_fire_origin );
	e_fx_model clientfield::set( "staff_lightning_ball_fx", 1 );
	e_fx_model.b_staff_lightning_ball_active = 1;
	
	n_shot_range = w_weapon.n_ball_move_distance;
	v_end = v_fire_origin + anglesToForward( v_fire_angles ) * n_shot_range;
		
	v_trace = bulletTrace( v_fire_origin, v_end, 0, undefined );
	if ( v_trace[ "fraction" ] != 1 )
		v_end = v_trace[ "position" ];
	
	n_staff_lightning_ball_speed = n_shot_range / 8;
	n_dist = distance( e_fx_model.origin, v_end );
	
	n_max_movetime_s = n_shot_range / n_staff_lightning_ball_speed;
	n_movetime_s = n_dist / n_staff_lightning_ball_speed;
	
	n_leftover_time = n_max_movetime_s - n_movetime_s;
	
	e_fx_model thread staff_lightning_ball_kill_zombies( e_player, w_weapon );
	e_fx_model moveTo( v_end, n_movetime_s );
	b_finished_playing = e_fx_model staff_lightning_ball_wait( n_leftover_time );
	
	e_fx_model notify( "staff_lightning_ball_stop_killing" );
	e_fx_model clientfield::set( "staff_lightning_ball_fx", 0 );
	e_fx_model.b_staff_lightning_ball_active = 0;
	
	wait 4;
	if ( isDefined( e_fx_model ) )
		e_fx_model delete();
	
}

function staff_lightning_ball_wait( n_lifetime_after_move )
{
	self endon( "death" );
	self waittill( "movedone" );
	wait n_lifetime_after_move;
	return 1;
}

function staff_lightning_ball_kill_zombies( e_attacker, w_weapon )
{
	self endon( "death" );
	self endon( "staff_lightning_ball_stop_killing" );
	while ( isDefined( self ) )
	{
		a_zombies = self staff_lightning_ball_get_valid_targets( w_weapon.n_ball_range );
		array::run_all( a_zombies, &staff_lightning_ball_effect_zombie, self, w_weapon, e_attacker );
		if ( !isDefined( a_zombies ) || !isArray( a_zombies ) || a_zombies.size < 1 )
			WAIT_SERVER_FRAME;
		
	}
}

function staff_lightning_ball_get_valid_targets( n_ball_range )
{
	return self array::filter( util::get_array_of_closest( self.origin, getAITeamArray( level.zombie_team ) ), 1, &staff_lightning_ball_effect_zombie_valid, n_ball_range );
}

function staff_lightning_ball_effect_zombie_valid( e_ai_zombie, n_ball_range )
{
	b_distance_passed = staff_lightning_distance_passed( self.origin, e_ai_zombie.origin, n_ball_range, e_ai_zombie.n_staff_lightning_ball_range_check_multiplier );
	b_trace_passed = staff_lightning_trace_passed( self.origin, e_ai_zombie.origin );
	return ( b_trace_passed && b_distance_passed && !IS_TRUE( e_ai_zombie.in_the_ground ) && !IS_TRUE( e_ai_zombie.in_the_ceiling ) && !IS_TRUE( e_ai_zombie.b_staff_lightning_ball_immune ) && !IS_TRUE( e_ai_zombie.b_staff_hit ) && !IS_TRUE( e_ai_zombie.b_is_staff_lightning_zapped ) );
}

function staff_lightning_ball_effect_zombie( e_ball, w_weapon, e_attacker )
{
	if ( isDefined( self.staff_lightning_ball_damage ) )
		self [ [ self.staff_lightning_ball_damage ] ]( e_attacker, w_weapon );
	else
		self thread staff_lightning_ball_damage_over_time( e_ball, e_attacker, w_weapon );
	
	wait .2;
}

function staff_lightning_fx_arc_to_zombie( e_ball )
{
	e_fx_model = util::spawn_model( "tag_origin", e_ball.origin );
	e_fx_model linkTo( e_ball );
	self.fx_staff_bolt_arc = e_fx_model;
	
	e_fx_model endon( "death" );
	
	wait randomFloatRange( .1, .5 );
	
	if ( !isDefined( e_ball ) || !isDefined( self ) )
	{
		if ( isDefined( e_fx_model ) )
			e_fx_model delete();
		
		if ( isDefined( self ) )
			self.fx_staff_bolt_arc = undefined;
		
		return;
	}
	e_fx_model unLink();
	playFxOnTag( "dlc5/zmb_weapon/fx_staff_elec_trail_bolt_cheap", e_fx_model, "tag_origin" );
	
	while ( isDefined( e_fx_model ) && isDefined( e_ball ) && isDefined( self ) )
	{
		v_origin = ( isDefined( self.str_staff_lightning_ball_arc_tag_override ) ? ( self getTagOrigin( self.str_staff_lightning_ball_arc_tag_override ) ) : ( self getTagOrigin( "j_spineupper" ) ) );
		e_fx_model moveTo( v_origin, .1 );
		wait .5;
		
		if ( !( isDefined( e_fx_model ) && isDefined( e_ball ) && isDefined( self ) && isAlive( self ) ) )
			break;
		
		e_fx_model moveTo( e_ball.origin, .1 );
		wait .5;
	}
	e_fx_model delete();
	if ( isDefined( self ) )
		self.fx_staff_bolt_arc = undefined;
		
}

function staff_lightning_ball_damage_over_time( e_source, e_attacker, w_weapon )
{
	self endon( "death" );
	e_attacker endon( "disconnect" );
	
	self.b_is_staff_lightning_zapped = 1;
	
	self thread staff_lightning_fx_arc_to_zombie( e_source );
	WAIT_SERVER_FRAME;
	self notify( "bhtn_action_notify", "electrocute" );
	
	while ( isDefined( e_source ) && IS_TRUE( e_source.b_staff_lightning_ball_active ) && isAlive( self ) && distanceSquared( e_source.origin, self.origin ) < SQR( w_weapon.n_ball_range ) )
	{
		while ( IS_TRUE( self.b_staff_lightning_stunned ) )
			WAIT_SERVER_FRAME;
		
		self staff_lightning_zombie_shocked_fx( 1 );
		self zm_weap_staff_common::staff_do_damage( w_weapon.n_ball_damage_per_second, self.origin, e_attacker, e_attacker, undefined, "MOD_RIFLE_BULLET", 0, w_weapon, undefined, undefined );
		wait 1;
	}
	if ( isDefined( self ) )
	{
		self.b_is_staff_lightning_zapped = undefined;
		if ( isDefined( self.fx_staff_bolt_arc ) )
			self.fx_staff_bolt_arc delete();
		
	}
}

function staff_lightning_stun_zombie()
{
	self endon( "death" );
	self.b_staff_lightning_stunned = 2;
	self staff_lightning_zombie_shocked_fx( 1 );
	self notify( "bhtn_action_notify", "electrocute" );
}

function staff_lightning_zombie_shocked_fx( b_play )
{
	self endon( "death" );
	
	if ( !IS_TRUE( b_play ) )
	{
		self clientfield::increment( ( isVehicle( self ) ? "staff_lightning_shock_eyes_fx_veh" : "staff_lightning_shock_eyes_fx" ), 2 );
		self clientfield::increment( ( isVehicle( self ) ? "staff_lightning_impact_fx_veh" : "staff_lightning_impact_fx" ), 2 );
		return;
	}
	
	self playSound( "wpn_lightningstaff_sizzle" );
	self playSound( "wpn_lightningstaff_zmb_fx" );
	
	self clientfield::increment( ( isVehicle( self ) ? "staff_lightning_shock_eyes_fx_veh" : "staff_lightning_shock_eyes_fx" ), ( IS_TRUE( self.head_gibbed ) ? 2 : 1 ) );
	self clientfield::increment( ( isVehicle( self ) ? "staff_lightning_impact_fx_veh" : "staff_lightning_impact_fx" ), 1 );
}

function staff_lightning_distance_passed( v_start_origin, v_end_origin, n_range, n_range_multiplier = 1 )
{
	return ( distance2dSquared( v_start_origin, v_end_origin ) < SQR( n_range ) * n_range_multiplier );
}

function staff_lightning_trace_passed( v_start_origin, v_end_origin, b_hit_characters = 0, e_ignore_ent = undefined, e_ignore_ent_2 = undefined, b_fx_visibility = 0, b_ignore_water = 1 )
{
	return ( bulletTracePassed( v_start_origin + ( 10, 10, 32 ), v_end_origin + ( 10, 10, 32 ), b_hit_characters, e_ignore_ent, e_ignore_ent_2, b_fx_visibility, b_ignore_water ) || bulletTracePassed( v_start_origin + ( -10, -10, 64 ), v_end_origin + ( -10, -10, 64 ), b_hit_characters, e_ignore_ent, e_ignore_ent_2, b_fx_visibility, b_ignore_water ) );
}	


function staff_lightning_parasite_init()
{
	self.str_staff_lightning_ball_arc_tag_override = "j_spine";
}

function staff_lightning_dog_init()
{
	self.str_staff_lightning_ball_arc_tag_override = "j_spine";
}


function private is_staff_lightning_damage( behavior_tree_entity )
{
	if ( !isDefined( level.is_staff_weapon ) || behavior_tree_entity.damagemod == "MOD_MELEE" )
		return 0;
	
	return [ [ level.is_staff_weapon ] ]( behavior_tree_entity.damageweapon, level.a_staff_lightning_weaponfiles );
}

function private was_stunned_by_lightning_staff( behavior_tree_entity )
{
	return IS_TRUE( behavior_tree_entity.zombie_is_electrocuted );
}

function private zombie_stun_lightning_action_end( behavior_tree_entity )
{
	if ( isDefined( behavior_tree_entity.zombie_is_electrocuted ) && behavior_tree_entity.zombie_is_electrocuted > 1 )
	{
		behavior_tree_entity.zombie_is_electrocuted--;
		if ( isDefined( level.staff_lightning_zombie_shocked_fx ) )
			behavior_tree_entity [ [ level.staff_lightning_zombie_shocked_fx ] ]( 1 );
		
		return BHTN_RUNNING;
	}
	behavior_tree_entity.zombie_is_electrocuted = undefined;
	if ( isAlive( behavior_tree_entity ) && isDefined( level.staff_lightning_zombie_shocked_fx ) )
		behavior_tree_entity [ [ level.staff_lightning_zombie_shocked_fx ] ]( 0 );
	
	return BHTN_SUCCESS;
}