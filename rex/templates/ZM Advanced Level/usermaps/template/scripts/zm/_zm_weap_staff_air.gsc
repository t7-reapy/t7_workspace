#using scripts\codescripts\struct;
#using scripts\shared\ai_shared;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\math_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\vehicle_ai_shared;
#using scripts\shared\ai\systems\blackboard;
#using scripts\shared\ai\systems\behavior_tree_utility;
#using scripts\shared\ai\zombie_utility;
#using scripts\zm\_zm;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_weap_staff_common;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\shared\ai\systems\blackboard.gsh;
#insert scripts\zm\_zm_utility.gsh;

#precache( "model", 		"wpn_t7_zmb_hd_staff_air_world" );
#precache( "model", 		"wpn_t7_zmb_hd_staff_air_upgraded_world" );
#precache( "fx", 			"dlc5/tomb/fx_tomb_elem_reveal_air_glow" );

#namespace zm_weap_staff_air; 

REGISTER_SYSTEM_EX( "zm_weap_staff_air", &__init__, &__main__, undefined )

function __init__()
{

	behaviortreenetworkutility::registerbehaviortreescriptapi( "zombieshouldwhirlwind", &zombie_should_whirlwind );
	
	level.a_staff_air_weaponfiles = [];

	staff_air_register_weapon_for_level( "staff_air", undefined, &staff_air_fired );
	staff_air_register_weapon_for_level( "staff_air_upgraded", undefined, &staff_air_fired, undefined );
	staff_air_register_weapon_for_level( "staff_air_upgraded2", undefined, &staff_air_upgrade_fired );
	staff_air_register_weapon_for_level( "staff_air_upgraded3", undefined, &staff_air_upgrade_fired );

	clientfield::register( "scriptmover", "staff_air_aoe_fx", VERSION_SHIP, 1, "int" );
	clientfield::register( "actor", "staff_air_launch_zombie", VERSION_SHIP, 1, "int" );
	clientfield::register( "scriptmover", "staff_air_set_launch_source", VERSION_SHIP, 1, "int" );
	clientfield::register( "actor", "staff_air_ragdoll_impact_watch", VERSION_SHIP, 1, "int" );
	clientfield::register( "vehicle", "staff_air_ragdoll_impact_watch", VERSION_SHIP, 1, "int" );
	
	zm::register_actor_damage_callback( &staff_air_actor_damage );
	zm::register_vehicle_damage_callback( &staff_air_vehicle_damage );
	zm_spawner::register_zombie_damage_callback( &staff_air_zombie_damage );
	zm_spawner::register_zombie_death_event_callback( &staff_air_death_event );
	spawner::add_archetype_spawn_function( "parasite", &staff_air_parasite_init, undefined, undefined, undefined, undefined, undefined );
	spawner::add_archetype_spawn_function( "zombie_dog", &staff_air_dog_init, undefined, undefined, undefined, undefined, undefined );
}

function __main__()
{
}

function staff_air_register_weapon_for_level( str_weapon, staff_weapon_fired = undefined, staff_weapon_missile_fired = undefined, staff_weapon_grenade_fired = undefined, staff_weapon_obtained = undefined, staff_weapon_lost = undefined, staff_weapon_reloaded = undefined, staff_weapon_pullout = undefined, staff_weapon_putaway = undefined )
{
	DEFAULT( level.a_staff_air_weaponfiles, [] );
	
	a_weapon_data = tableLookupRow( "gamedata/weapons/zm/staff_air_settings.csv", tableLookupRowNum( "gamedata/weapons/zm/staff_air_settings.csv", 0, str_weapon ) );
	if ( !isDefined( a_weapon_data ) )
		a_weapon_data = tableLookupRow( "gamedata/weapons/zm/staff_air_settings.csv", tableLookupRowNum( "gamedata/weapons/zm/staff_air_settings.csv", 0, "default" ) );
	if ( !isDefined( a_weapon_data ) )	
		return;
	
	w_weapon = getWeapon( str_weapon );
	w_weapon.b_is_upgrade = ( toLower( 	a_weapon_data[ true ] ) == "true" );
	w_weapon.n_damage = int(a_weapon_data[ 2 ] );
	w_weapon.n_cone_fov	= int( a_weapon_data[ 3 ]	);
	w_weapon.n_cone_range = int( a_weapon_data[ 4 ] );
	w_weapon.b_whirlwind_supercharged =	( toLower( 	a_weapon_data[ 5 ] ) == "true");
	w_weapon.n_whirlwind_lifetime = float( a_weapon_data[ 6 ] );
	w_weapon.n_whirlwind_range	= int( a_weapon_data[ 7 ] );
	
	zm_weap_staff_common::register_staff_weapon_for_level( 	w_weapon, staff_weapon_fired, staff_weapon_missile_fired, staff_weapon_grenade_fired, staff_weapon_obtained, staff_weapon_lost, staff_weapon_reloaded, staff_weapon_pullout, staff_weapon_putaway );
	
	ARRAY_ADD( level.a_staff_air_weaponfiles, w_weapon );
}

function staff_air_actor_damage( e_inflictor, e_attacker, n_damage, f_flags, str_means_of_death, w_weapon, v_point, v_direction, str_hit_loc, n_offset_time, n_bone_index, str_surface_type )
{
	if ( !isDefined( e_attacker ) || !isPlayer( e_attacker ) )
		return -1;
	
	if ( !zm_weap_staff_common::is_staff_weapon( w_weapon, level.a_staff_air_weaponfiles ) )
		return -1;
	
	if ( zm_weap_staff_common::is_upgraded_staff_weapon( w_weapon ) && IS_TRUE( self.b_staff_air_upgraded_immune ) )
		return 0;
	else if ( !zm_weap_staff_common::is_upgraded_staff_weapon( w_weapon ) && IS_TRUE( self.b_staff_air_immune ) )
		return 0;
	
	if ( str_means_of_death == "MOD_MELEE" )
		return -1;
	
	playSoundAtPosition( "wpn_airstaff_tornado_imp", v_point );
	if ( isDefined( self.staff_air_actor_damage ) )
		return [ [ self.staff_air_actor_damage ] ]( e_inflictor, e_attacker, n_damage, f_flags, str_means_of_death, w_weapon, v_point, v_direction, str_hit_loc, n_offset_time, n_bone_index, str_surface_type );
	
	return -1;
}

function staff_air_vehicle_damage( e_inflictor, e_attacker, n_damage, str_flags, str_means_of_death, w_weapon, v_point, v_direction, str_hit_loc, v_damage_origin, n_offset_time, b_damage_drom_underneath, n_model_index, str_part_name, str_surface_type )
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
	
	if ( !zm_weap_staff_common::is_staff_weapon( w_weapon, level.a_staff_air_weaponfiles ) )
		return n_damage;
	
	if ( zm_weap_staff_common::is_upgraded_staff_weapon( w_weapon ) && IS_TRUE( self.b_staff_air_upgraded_immune ) )
		return 0;
	else if ( !zm_weap_staff_common::is_upgraded_staff_weapon( w_weapon ) && IS_TRUE( self.b_staff_air_immune ) )
		return 0;
	
	if ( str_means_of_death == "MOD_MELEE" )
		return n_damage;
	
	playSoundAtPosition( "wpn_airstaff_tornado_imp", v_point );
	if ( isDefined( self.staff_air_vehicle_damage ) )
		return [ [ self.staff_air_vehicle_damage ] ]( e_inflictor, e_attacker, n_damage, str_flags, str_means_of_death, w_weapon, v_point, v_direction, str_hit_loc, v_damage_origin, n_offset_time, b_damage_drom_underneath, n_model_index, str_part_name, str_surface_type );
	
	return n_damage;
}

function staff_air_zombie_damage( str_means_of_death, str_hit_loc, v_point, e_attacker, n_damage, w_weapon, v_direction, str_tag_name, str_model_name, str_part_name, f_flags, e_inflictor, n_charge_level )
{
	if ( !isDefined( e_attacker ) || !isPlayer( e_attacker ) )
		return 0;
	
	if ( !zm_weap_staff_common::is_staff_weapon( w_weapon, level.a_staff_air_weaponfiles ) || str_means_of_death == "MOD_MELEE" )
		return 0;
	
	if ( isDefined( self.staff_air_zombie_damage ) )
		return [ [ self.staff_air_zombie_damage ] ]( str_means_of_death, str_hit_loc, v_point, e_attacker, n_damage, w_weapon, v_direction, str_tag_name, str_model_name, str_part_name, f_flags, e_inflictor, n_charge_level );
	else
		self thread zombie_utility::setup_zombie_knockdown( e_inflictor );
	
	return 1;
}

function staff_air_death_event( e_attacker )
{
	if ( !isDefined( e_attacker ) || !isPlayer( e_attacker ) )
		return;
	
	if ( !isDefined( self ) || !zm_weap_staff_common::is_staff_weapon( self.damageweapon, level.a_staff_air_weaponfiles ) || self.damagemod == "MOD_MELEE" )
		return;
	
	self setCanDamage( 0 );
	self [ [ ( isDefined( self.staff_air_death ) ? self.staff_air_death : &staff_air_fling_zombie_death ) ] ]( e_attacker, self.damagemod );	
}

function staff_air_do_damage( e_player, w_weapon, n_damage_override = undefined, str_means_of_death = "MOD_IMPACT" )
{
	if ( IS_TRUE( self.missingLegs ) && ( isDefined( n_damage_override ) ? n_damage_override : w_weapon.n_damage ) < self.health )
		n_damage_override = self.health + 666;
	
	self zm_weap_staff_common::staff_do_damage( n_damage_override, undefined, e_player, undefined, undefined, str_means_of_death, undefined, w_weapon, undefined, undefined );
}

function staff_air_fired( e_projectile, w_weapon, n_charge_level )
{
	staff_air_update_source_origin( self.origin );
	e_projectile thread zm_weap_staff_common::projectile_delete( .75 );
	self staff_air_damage_cone( w_weapon );
}

function staff_air_upgrade_fired( e_projectile, w_weapon, n_charge_level )
{
	e_projectile thread staff_air_whirlwind_find_source( self, w_weapon );
}

function staff_air_damage_cone( w_weapon )
{
	a_targets = util::get_array_of_closest( self.origin, getAITeamArray( level.zombie_team ), undefined, undefined, w_weapon.n_cone_range );
	a_targets = array::clamp_size( self array::filter( a_targets, 1, &staff_air_check_zombie_hit_valid, self, w_weapon ), 12 );
	array::run_all(a_targets, &staff_air_do_damage, self, w_weapon );

}

function staff_air_check_zombie_hit_valid( e_ai_zombie, e_player, w_weapon )
{
	return ( staff_air_trace_passed( e_player.origin, e_ai_zombie.origin ) && !IS_TRUE( e_ai_zombie.b_staff_air_cone_immune ) && util::within_fov( self getPlayerCameraPos(), self getPlayerAngles(), e_ai_zombie getTagOrigin( ( isDefined( e_ai_zombie.str_staff_air_fling_tag_check_override ) ? e_ai_zombie.str_staff_air_fling_tag_check_override : "j_spine4" ) ), cos( w_weapon.n_cone_fov ) ) );
}

function staff_air_fling_zombie_death( e_attacker, str_means_of_death = "MOD_IMPACT" )
{
	if ( str_means_of_death == "MOD_MELEE" )
		return;
	
	if ( IS_TRUE( self.in_the_ceiling ) || IS_TRUE( self.in_the_ground ) || str_means_of_death == "MOD_UNKNOWN" || IS_TRUE( self.b_staff_air_whirlwind_source ) || ( !math::cointoss() && !math::cointoss() ) )
		self [ [ ( math::cointoss() ? &zm_weap_staff_common::zombie_gib_all : &zm_weap_staff_common::zombie_gib_guts ) ] ]( ( isDefined( self.str_staff_air_gib_fx_tag ) ? self.str_staff_air_gib_fx_tag : "j_spine4" ) );
	else
		self thread staff_air_launch_zombie();
		
}

function staff_air_launch_zombie()
{
	self endon( "entityshutdown" );
	
	if ( isVehicle( self ) )
		return;
	
	self startRagDoll();
	if ( IS_TRUE( 1 ) )
	{
		v_direction = vectorNormalize( self.origin - level.e_staff_air_launch_source.origin );
		v_launch = vectorScale( ( v_direction[ 0 ], v_direction[ 1 ], randomFloatRange( .05, .35 ) ), ( length( v_direction ) * 300 ) );
		WAIT_SERVER_FRAME;
		self launchRagdoll( v_launch );
		self clientfield::set( "staff_air_ragdoll_impact_watch", 1 );
	}
	else
		self clientfield::set( "staff_air_launch_zombie", 1 );
	
}

function staff_air_whirlwind_find_source( e_player, w_weapon )
{
	e_player endon( "death_or_disconnect" );
	
	v_initial_origin = e_player.origin;
	e_projectile = undefined;
	while ( !isDefined( e_projectile ) || e_projectile != self )
		e_player waittill( "projectile_impact", w_weapon, v_impact_origin, n_radius, e_projectile, v_normal );
		
	e_ai_zombie_impacted = staff_air_whirlwind_impact_ai_check( v_impact_origin );
	if ( isDefined( e_ai_zombie_impacted ) )
	{
		staff_air_update_source_origin( v_initial_origin );
		v_impact_origin = e_ai_zombie_impacted.origin;
		v_origin = e_ai_zombie_impacted getTagOrigin( ( isDefined( e_ai_zombie_impacted.str_staff_air_whirlwind_tag_check ) ? e_ai_zombie_impacted.str_staff_air_whirlwind_tag_check : "j_spineupper" ) );
		e_ai_zombie_impacted staff_air_do_damage( e_player, w_weapon, -1, "MOD_UNKNOWN" );
		e_player staff_air_whirlwind_proximity_kill( v_origin, w_weapon );
	}
	e_player thread staff_air_position_whirlwind( v_impact_origin, w_weapon );
}

function staff_air_whirlwind_impact_ai_check( v_impact_origin )
{
	a_zombies = staff_air_whirlwind_proximity_impacted_zombies( v_impact_origin );
	if ( !isDefined( a_zombies ) || !isArray( a_zombies ) || a_zombies.size < 1 )
		return undefined;
	
	a_zombies[ 0 ].b_staff_air_whirlwind_source = 1;
	return a_zombies[ 0 ];
}

function staff_air_whirlwind_proximity_impacted_zombies( v_impact_origin )
{
	return array::filter( util::get_array_of_closest( v_impact_origin, getAITeamArray( level.zombie_team ) ), 1, &staff_air_whirlwind_proximity_impact_zombie_valid, v_impact_origin );	
}

function staff_air_whirlwind_proximity_impact_zombie_valid( e_ai_zombie, v_impact_origin )
{
	return ( distance2dSquared( v_impact_origin, e_ai_zombie.origin ) < SQR( 100 ) );
}

function staff_air_whirlwind_proximity_kill( v_whirlwind_origin, w_weapon )
{
	self endon( "death_or_disconnect" );
	a_zombies = staff_air_whirlwind_impact_effected_zombies( v_whirlwind_origin, SQR( w_weapon.n_whirlwind_range ) );
	array::run_all( a_zombies, &staff_air_do_damage, self, w_weapon, -1 );	
}

function staff_air_whirlwind_impact_effected_zombies( v_whirlwind_origin, n_whirlwind_range_sq )
{
	return array::filter( util::get_array_of_closest( v_whirlwind_origin, getAITeamArray( level.zombie_team ) ), 1, &staff_air_whirlwind_impact_zombie_valid, v_whirlwind_origin, n_whirlwind_range_sq );
}

function staff_air_whirlwind_impact_zombie_valid( e_ai_zombie, v_whirlwind_origin, n_proximity_range_sq )
{
	return ( !IS_TRUE( e_ai_zombie.b_staff_air_cone_immune ) && !IS_TRUE( e_ai_zombie.b_staff_air_whirlwind_immune ) && distanceSquared( e_ai_zombie.origin, v_whirlwind_origin ) < n_proximity_range_sq && !IS_TRUE( e_ai_zombie.b_staff_air_whirlwind_source ) && staff_air_trace_passed( v_whirlwind_origin, e_ai_zombie.origin ) );
}

function staff_air_position_whirlwind( v_impact_origin, w_weapon )
{
	e_fx_model = util::spawn_model( "tag_origin", v_impact_origin, ( -90, 0, 0 ) );
	e_fx_model endon( "death" );
	v_impact_origin = e_fx_model zm_utility::groundpos_ignore_water_new( v_impact_origin );
	e_fx_model moveTo( v_impact_origin, .05 );
	e_fx_model waittill( "movedone" );
	e_fx_model clientfield::set( "staff_air_aoe_fx", 1 );
	wait .5;
	e_fx_model thread staff_air_whirlwind_kill_zombies( w_weapon, self );
	wait w_weapon.n_whirlwind_lifetime - .5;
	staff_air_update_source_origin( v_impact_origin );
	e_fx_model notify( "staff_air_whirlwind_over" );
	e_fx_model clientfield::set( "staff_air_aoe_fx", 0 );
	wait 1.5;
	e_fx_model delete();
}

function staff_air_whirlwind_kill_zombies( w_weapon, e_player )
{
	e_player endon( "death_or_disconnect" );
	self endon( "death" );
	self endon( "staff_air_whirlwind_over" );
	
	while ( isDefined( self ) )
	{
		array::thread_all( self staff_air_whirlwind_effected_zombies( w_weapon ), &staff_air_whirlwind_drag_zombie, self, w_weapon, e_player );
		wait .1;
	}
}

function staff_air_whirlwind_effected_zombies( w_weapon )
{
	return self array::filter( util::get_array_of_closest( self.origin, getAITeamArray( level.zombie_team ) ), 1, &staff_air_whirlwind_effect_zombie_valid, w_weapon );
}

function staff_air_whirlwind_effect_zombie_valid( e_ai_zombie, w_weapon )
{
	return ( !IS_TRUE( e_ai_zombie.in_the_ground ) && !IS_TRUE( e_ai_zombie.in_the_ceiling ) && !IS_TRUE( e_ai_zombie.b_staff_air_whirlwind_immune ) && !IS_TRUE( e_ai_zombie.b_staff_hit ) && !IS_TRUE( e_ai_zombie.b_staff_air_whirlwind_attract ) && staff_air_whirlwind_range_and_trace_passed( e_ai_zombie, w_weapon ) );
}

function staff_air_whirlwind_range_and_trace_passed( e_ai_zombie, w_weapon )
{
	return ( staff_air_distance_passed( self.origin, e_ai_zombie.origin, w_weapon.n_whirlwind_range, e_ai_zombie.n_staff_air_whirlwind_range_check_multiplier ) && staff_air_trace_passed( self.origin, e_ai_zombie.origin ) );
}

function staff_air_whirlwind_drag_zombie( e_whirlwind, w_weapon, e_player )
{
	self endon( "death" );
	if ( self isPlayingAnimScripted() )
		self stopAnimScripted();
	
	self.b_staff_hit = 1;
	self.b_staff_air_whirlwind_attract = 1;
	
	self zm_weap_staff_common::disable_pain_and_reaction();
	self zm_weap_staff_common::disable_find_flesh();
	
	self zm_weap_staff_common::create_linker_entity( self.origin + ( isDefined( self.v_staff_air_drag_linker_offset ) ? self.v_staff_air_drag_linker_offset : ( 0, 0, 0 ) ), self.angles, "tag_origin", vectorToAngles( self.origin - e_whirlwind.origin ) );
	
	str_means_of_death = undefined;
	str_means_of_death = self staff_air_whirlwind_zombie_drag_logic( e_whirlwind, w_weapon, e_player );
		
	self staff_air_do_damage( e_player, w_weapon, -1, ( isDefined( str_means_of_death ) ? str_means_of_death : "MOD_IMPACT" ) );
}

function staff_air_whirlwind_zombie_drag_logic( e_whirlwind, w_weapon, e_player )
{
	self endon( "death" );
	e_whirlwind endon( "staff_air_whirlwind_over" );
		
	while ( distance2dSquared( e_whirlwind.origin, self.origin ) > SQR( 30 ) )
	{
		b_staff_air_whirlwind_supercharged = ( ( IS_TRUE( self.missingLegs ) || IS_TRUE( w_weapon.b_whirlwind_supercharged ) ) ? 1 : 0 );		
		self thread staff_air_whirlwind_drag_along_ground( e_whirlwind.origin, b_staff_air_whirlwind_supercharged );
		
		WAIT_SERVER_FRAME;
	}
	
	return "MOD_UNKNOWN";
}

function staff_air_whirlwind_drag_along_ground( v_position, b_staff_air_whirlwind_supercharged )
{
	Blackboard::SetBlackBoardAttribute( self, WHIRLWIND_SPEED, ( IS_TRUE( b_staff_air_whirlwind_supercharged ) ? WHIRLWIND_FAST : WHIRLWIND_NORMAL ) );
	self.e_linker moveTo( zm_utility::groundpos_ignore_water_new( self.origin + vectorScale( vectorNormalize( v_position - self.origin ), 50 ) ), ( IS_TRUE( b_staff_air_whirlwind_supercharged ) ? .8 : 1 ) );
}

function staff_air_distance_passed( v_start_origin, v_end_origin, n_range, n_range_multiplier = 1 )
{
	return ( distance2dSquared( v_start_origin, v_end_origin ) < SQR( n_range ) * n_range_multiplier );
}

function staff_air_trace_passed( v_start_origin, v_end_origin, b_hit_characters = 0, e_ignore_ent = undefined, e_ignore_ent_2 = undefined, b_fx_visibility = 0, b_ignore_water = 1 )
{
	return ( bulletTracePassed( v_start_origin + ( 10, 10, 32 ), v_end_origin + ( 10, 10, 32 ), b_hit_characters, e_ignore_ent, e_ignore_ent_2, b_fx_visibility, b_ignore_water ) || bulletTracePassed( v_start_origin + ( -10, -10, 64 ), v_end_origin + ( -10, -10, 64 ), b_hit_characters, e_ignore_ent, e_ignore_ent_2, b_fx_visibility, b_ignore_water ) );
}

function staff_air_update_source_origin( v_origin )
{
	if ( !isDefined( level.e_staff_air_launch_source ) )
	{
		level.e_staff_air_launch_source = util::spawn_model( "tag_origin", v_origin, ( 0, 0, 0 ) );
		level.e_staff_air_launch_source clientfield::set( "staff_air_set_launch_source", 1 );
	}
	else
		level.e_staff_air_launch_source.origin = v_origin;
	
}

function staff_air_parasite_init()
{
	self.str_staff_air_gib_fx_tag = "j_spine";
	self.str_staff_air_fling_tag_check_override = "j_spine";
	self.v_staff_air_drag_linker_offset = ( 0, 0, -64 );
	self.staff_air_death = &staff_air_parasite_death;
	self.n_staff_air_whirlwind_range_check_multiplier = 1.8;
}

function staff_air_parasite_death( e_attacker, str_means_of_death = "MOD_IMPACT" )
{
	self thread zm_weap_staff_common::zombie_gib_guts( ( isDefined( self.str_staff_air_gib_fx_tag ) ? self.str_staff_air_gib_fx_tag : "j_spine" ) );
}

function staff_air_dog_init()
{
	self.str_staff_air_gib_fx_tag = "j_spine";
	self.str_staff_air_fling_tag_check_override = "j_spine";
	self.v_staff_air_drag_linker_offset = ( 0, 0, -64 );
}

function private zombie_should_whirlwind( behavior_tree_entity )
{
	return IS_TRUE( behavior_tree_entity.b_staff_air_whirlwind_attract );
}