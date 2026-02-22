#using scripts\codescripts\struct;
#using scripts\shared\ai_shared;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\duplicaterender_mgr;
#using scripts\shared\spawner_shared;
#using scripts\shared\system_shared;
#using scripts\shared\vehicle_shared;
#using scripts\shared\vehicle_ai_shared;
#using scripts\shared\ai\systems\behavior_tree_utility;
#using scripts\shared\util_shared;
#using scripts\zm\_util;
#using scripts\zm\_zm;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_weap_staff_common;

#insert scripts\shared\duplicaterender.gsh;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_utility.gsh;

#namespace zm_weap_staff_water; 

#precache( "model", "wpn_t7_zmb_hd_staff_water_world" );
#precache( "model", "wpn_t7_zmb_hd_staff_water_upgraded_world" );
#precache( "fx", "dlc5/tomb/fx_tomb_elem_reveal_ice_glow" );
#precache( "fx", "dlc5/zmb_weapon/fx_staff_ice_exp" );

REGISTER_SYSTEM_EX( "zm_weap_staff_water", &__init__, &__main__, undefined )

function __init__()
{	

	behaviortreenetworkutility::registerbehaviortreescriptapi( "waskilledbywaterstaff", &is_staff_water_damage );

	level.a_staff_water_weaponfiles = [];
	
	staff_water_register_weapon_for_level( "staff_water", undefined, &staff_water_fired );
	staff_water_register_weapon_for_level( "staff_water_upgraded", undefined, &staff_water_fired );
	staff_water_register_weapon_for_level( "staff_water_upgraded2", undefined, &staff_water_upgrade_fired );
	staff_water_register_weapon_for_level( "staff_water_upgraded3", undefined, &staff_water_upgrade_fired );

	clientfield::register( "scriptmover", "staff_water_blizzard_fx", VERSION_SHIP, 1, "int" );
	clientfield::register( "actor", "staff_water_freeze_zombie", VERSION_SHIP, 	1, "int" );
	clientfield::register( "vehicle", "staff_water_freeze_zombie", VERSION_SHIP, 1, "int" );
	clientfield::register( "actor", "staff_water_freeze_fx", VERSION_SHIP, 1, "int" );
	clientfield::register( "vehicle", "staff_water_freeze_fx", VERSION_SHIP, 1, "int" );

	zm::register_actor_damage_callback( &staff_water_actor_damage );
	zm::register_vehicle_damage_callback( &staff_water_vehicle_damage );

	zm_spawner::register_zombie_damage_callback( &staff_water_zombie_damage );
	zm_spawner::register_zombie_death_event_callback( &staff_water_death_event );
	
	level.staff_water_freeze_zombie = &staff_water_freeze_zombie;

	spawner::add_archetype_spawn_function( "parasite", &staff_water_parasite_init );
	spawner::add_archetype_spawn_function( "zombie_dog", &staff_water_dog_init );
}

function __main__()
{
}

function staff_water_register_weapon_for_level( str_weapon, staff_weapon_fired = undefined, staff_weapon_missile_fired = undefined, staff_weapon_grenade_fired = undefined, staff_weapon_obtained = undefined, staff_weapon_lost = undefined, staff_weapon_reloaded = undefined, staff_weapon_pullout = undefined, staff_weapon_putaway = undefined )
{
	DEFAULT( level.a_staff_water_weaponfiles, [] );
	
	a_weapon_data = tableLookupRow( "gamedata/weapons/zm/staff_water_settings.csv", tableLookupRowNum( "gamedata/weapons/zm/staff_water_settings.csv", 0, str_weapon ) );
	if ( !isDefined( a_weapon_data ) )
		a_weapon_data = tableLookupRow( "gamedata/weapons/zm/staff_water_settings.csv", tableLookupRowNum( "gamedata/weapons/zm/staff_water_settings.csv", 0, "default" ) );
	if ( !isDefined( a_weapon_data ) )	
		return;
		
	w_weapon 						= getWeapon( str_weapon );
	w_weapon.b_is_upgrade			= ( toLower( a_weapon_data[ true ] ) == "true" );
	w_weapon.n_damage				= int( a_weapon_data[ 2 ] );
	w_weapon.n_cone_fov				= int( a_weapon_data[ 3 ] );
	w_weapon.n_cone_range			= int( a_weapon_data[ 4 ] );
	w_weapon.n_blizzard_lifetime	= float( a_weapon_data[ 5 ] );
	w_weapon.n_blizzard_range		= int( a_weapon_data[ 6 ] );
	
	zm_weap_staff_common::register_staff_weapon_for_level( w_weapon, staff_weapon_fired, staff_weapon_missile_fired, staff_weapon_grenade_fired, staff_weapon_obtained, staff_weapon_lost, staff_weapon_reloaded, staff_weapon_pullout, staff_weapon_putaway );
	
	ARRAY_ADD( level.a_staff_water_weaponfiles, w_weapon );
}

function staff_water_actor_damage( e_inflictor, e_attacker, n_damage, f_flags, str_means_of_death, w_weapon, v_point, v_direction, str_hit_loc, n_offset_time, n_bone_index, str_surface_type )
{
	if ( !isDefined( e_attacker ) || !isPlayer( e_attacker ) )
		return -1;
	
	if ( !zm_weap_staff_common::is_staff_weapon( w_weapon, level.a_staff_water_weaponfiles ) )
		return -1;
	
	if ( zm_weap_staff_common::is_upgraded_staff_weapon( w_weapon ) && IS_TRUE( self.b_staff_water_upgraded_immune ) )
		return 0;
	else if ( !zm_weap_staff_common::is_upgraded_staff_weapon( w_weapon ) && IS_TRUE( self.b_staff_water_immune ) )
		return 0;
	
	if ( str_means_of_death == "MOD_MELEE" )
		return -1;
	
	if ( str_means_of_death != "MOD_RIFLE_BULLET" )
		return 0;
	
	if ( isDefined( self.staff_water_actor_damage ) )
		return [ [ self.staff_water_actor_damage ] ]( e_inflictor, e_attacker, n_damage, f_flags, str_means_of_death, w_weapon, v_point, v_direction, str_hit_loc, n_offset_time, n_bone_index, str_surface_type );
	
	return -1;
}

function staff_water_vehicle_damage( e_inflictor, e_attacker, n_damage, str_flags, str_means_of_death, w_weapon, v_point, v_direction, str_hit_loc, v_damage_origin, n_offset_time, b_damage_drom_underneath, n_model_index, str_part_name, str_surface_type )
{
	if ( !isDefined( e_attacker ) || !isPlayer( e_attacker ) )
		return n_damage;
	
	if ( !isDefined( self.damageweapon ) || self.damageweapon != w_weapon )
		self.damageweapon = w_weapon;
	if ( !isDefined( self.damagemod ) || self.damagemod != str_means_of_death )
		self.damagemod = str_means_of_death;
	
	if ( !zm_weap_staff_common::is_staff_weapon( w_weapon, level.a_staff_water_weaponfiles ) )
		return n_damage;
	
	if ( zm_weap_staff_common::is_upgraded_staff_weapon( w_weapon ) && IS_TRUE( self.b_staff_water_upgraded_immune ) )
		return 0;
	else if ( !zm_weap_staff_common::is_upgraded_staff_weapon( w_weapon ) && IS_TRUE( self.b_staff_water_immune ) )
		return 0;
	
	if ( str_means_of_death == "MOD_MELEE" )
		return -1;
	
	if ( str_means_of_death != "MOD_RIFLE_BULLET" )
		return 0;
	
	if ( isDefined( self.staff_water_vehicle_damage ) )
		return [ [ self.staff_water_vehicle_damage ] ]( e_inflictor, e_attacker, n_damage, str_flags, str_means_of_death, w_weapon, v_point, v_direction, str_hit_loc, v_damage_origin, n_offset_time, b_damage_drom_underneath, n_model_index, str_part_name, str_surface_type );
	
	return n_damage;
}

function staff_water_zombie_damage( str_means_of_death, str_hit_loc, v_point, e_attacker, n_damage, w_weapon, v_direction, str_tag_name, str_model_name, str_part_name, f_flags, e_inflictor, n_charge_level )
{
	if ( !isDefined( e_attacker ) || !isPlayer( e_attacker ) )
		return 0;
	
	if ( !zm_weap_staff_common::is_staff_weapon( w_weapon, level.a_staff_water_weaponfiles ) || str_means_of_death == "MOD_MELEE" )
		return 0;
	
	if ( isDefined( self.staff_water_zombie_damage ) )
		return [ [ self.staff_water_zombie_damage ] ]( str_means_of_death, str_hit_loc, v_point, e_attacker, n_damage, w_weapon, v_direction, str_tag_name, str_model_name, str_part_name, f_flags, e_inflictor, n_charge_level );
	else if ( isDefined( level.staff_water_freeze_zombie ) )
		self thread [ [ level.staff_water_freeze_zombie ] ]();
	else
		self thread staff_water_freeze_zombie();
	
	return 1;
}

function staff_water_death_event( e_attacker )
{
	if ( !isDefined( e_attacker ) || !isPlayer( e_attacker ) )
		return;
	
	if ( !isDefined( self ) || !zm_weap_staff_common::is_staff_weapon( self.damageweapon, level.a_staff_water_weaponfiles ) || self.damagemod == "MOD_MELEE" )
		return;
	
	self setCanDamage( 0 );
	if ( isDefined( self.staff_water_death ) )
		self [ [ self.staff_water_death ] ]( e_attacker, self.damagemod );	
	else
		self staff_water_kill_zombie();
	
}

function staff_water_fired( e_projectile, w_weapon, n_charge_level )
{
	self thread staff_water_damage_cone( w_weapon );
}

function staff_water_upgrade_fired( e_projectile, w_weapon, n_charge_level )
{
	e_projectile thread staff_water_find_source( self, w_weapon, n_charge_level );
}

function staff_water_damage_cone( w_weapon )
{
	v_origin = self.origin;
	v_fire_origin = self getPlayerCameraPos();
	v_fire_angles = self getPlayerAngles();
	for ( i = 0; i < 3; i++ )
		self staff_water_icicle_locate_target( w_weapon, v_origin, v_fire_origin, v_fire_angles );
		util::wait_network_frame();
	
}

function staff_water_icicle_locate_target( w_weapon, v_origin, v_fire_origin, v_fire_angles )
{
	a_targets = util::get_array_of_closest( v_origin, getAITeamArray( level.zombie_team ), undefined, undefined, w_weapon.n_cone_range);
	a_targets = array::clamp_size( array::filter( a_targets, 1, &staff_water_check_zombie_hit_valid, self, w_weapon, v_fire_origin, v_fire_angles), 100);
	array::run_all( a_targets, &staff_water_damage_ai_response, self, w_weapon);
}

function staff_water_check_zombie_hit_valid( e_ai_zombie, e_player, w_weapon )
{
	b_fov_passed = ( util::within_fov( e_player getPlayerCameraPos(), e_player getPlayerAngles(), e_ai_zombie getTagOrigin( ( isDefined( e_ai_zombie.str_staff_water_cone_tag_check_override ) ? e_ai_zombie.str_staff_water_cone_tag_check_override : "j_spine4" ) ), cos( w_weapon.n_cone_fov ) ) );
	str_tag_trace = array::random( ( isDefined( e_ai_zombie.a_staff_water_cone_impact_tag_checks_array_override ) ? e_ai_zombie.a_staff_water_cone_impact_tag_checks_array_override : array( "j_hip_le", "j_hip_ri", "j_spine4", "j_elbow_le", "j_elbow_ri", "j_clavicle_le", "j_clavicle_ri" ) ) );
	v_tag_origin = e_ai_zombie getTagOrigin( str_tag_trace );
	if ( !isDefined( v_tag_origin ) )
		v_tag_origin = e_ai_zombie.origin + ( 0, 0, 64 );
	
	return ( !IS_TRUE( e_ai_zombie.b_staff_water_cone_effect_immune ) && !IS_TRUE( e_ai_zombie.b_is_on_ice ) && b_fov_passed && bulletTracePassed( e_player getPlayerCameraPos(), v_tag_origin, 0, e_ai_zombie ) );
}

function staff_water_damage_ai_response( e_player, w_weapon, b_will_die = 0, str_means_of_death = "MOD_RIFLE_BULLET" )
{
	if ( !isDefined( self ) || !isAlive( self ) )
		return;
	
	if ( isDefined( self.staff_water_damage ) )
		self [ [ self.staff_water_damage ] ]( e_player, w_weapon );
	else
	{
		b_instakill_active = ( isDefined( e_player ) && isPlayer( e_player ) && e_player zm_powerups::is_insta_kill_active() );
		if ( IS_TRUE( b_instakill_active ) )
			b_will_die = 1;

		self zm_weap_staff_common::staff_do_damage( ( IS_TRUE( b_will_die ) ? self.health + 666 : w_weapon.n_damage ), self.origin, e_player, e_player, undefined, str_means_of_death, 0, w_weapon, undefined, undefined );
	}
}

function staff_water_kill_zombie()
{
	self clientfield::set( "staff_water_freeze_zombie", 1 );
	self clientfield::set( "staff_water_freeze_fx", 1 );
	self asmSetAnimationRate( 1 );
	playSoundAtPosition( "wpn_waterstaff_collapse_zombie", self.origin );
	self thread staff_water_death_anim_timeout();
	self util::waittill_any_array( array( "shatter", "start_ragdoll" ) );
	
	if ( isDefined( self ) )
	{
		playFx( "dlc5/zmb_weapon/fx_staff_ice_exp", self getTagOrigin( ( isDefined( self.str_staff_water_gib_tag_override ) ? self.str_staff_water_gib_tag_override : "j_spinelower" ) ), anglesToForward( ( 0, randomInt( 360 ), 0 ) ) );
		self clientfield::set( "staff_water_freeze_fx", 0 );
		self thread zm_weap_staff_common::zombie_gib_all( ( isDefined( self.str_staff_water_gib_tag_override ) ? self.str_staff_water_gib_tag_override : undefined ) );
	}
}

function staff_water_death_anim_timeout()
{
	self util::waittill_any_timeout( 1.5, "shatter", "start_ragdoll" );
	if ( isDefined( self ) )
		self notify( "shatter" );
	
}

function staff_water_freeze_zombie( b_attach_model = 0, b_skip_unfreeze = 0 )
{
	self endon( "death" );
	
	if ( isDefined( self.staff_water_damage ) )
	{
		self [ [ self.staff_water_freeze_zombie ] ]();
		return;
	}
	
	if ( !isDefined( self ) )
		return;
	if ( IS_TRUE( self.b_is_on_ice ) )
		return;
	if ( IS_TRUE( self.b_staff_hit ) )
		return;
	
	self.b_staff_hit = 1;
	self.b_is_on_ice = 1;
	
	self clientfield::set( "staff_water_freeze_zombie", 1 );
	self clientfield::set( "staff_water_freeze_fx", 1 );
	
	self zm_weap_staff_common::disable_pain_and_reaction();
	self zm_weap_staff_common::disable_find_flesh( 1 );
	
	i = 1;
	while ( i > .3 )
	{
		if ( !isDefined( self ) )
			return;
		
		i -= .1;
		self asmSetAnimationRate( i );
		wait .1;
	}
	self asmSetAnimationRate( 0 );
	
	wait randomFloatRange( 1.8, 2.3 );
	
	if ( !isDefined( self ) )
		return;
	
	if ( IS_TRUE( b_skip_unfreeze ) )
		return;
	
	self clientfield::set( "staff_water_freeze_zombie", 0 );
	self clientfield::set( "staff_water_freeze_fx", 0 );
	
	i = 0;
	while ( i < 1 )
	{
		if ( !isDefined( self ) )
			return;
	
		i += .1;
		self asmSetAnimationRate( i );
		wait .1;
	}
	
	self asmSetAnimationRate( 1 );
		
	self.b_is_on_ice = undefined;			
	self.b_staff_hit = undefined;
	
	self zm_weap_staff_common::enable_pain_and_reaction();
	self zm_weap_staff_common::enable_find_flesh();
}

function staff_water_find_source( e_player, w_weapon, n_charge_level )
{
	e_player endon( "death_or_disconnect" );
	
	e_projectile = undefined;
	while ( !isDefined( e_projectile ) || e_projectile != self )
		e_player waittill( "projectile_impact", w_weapon, v_impact_origin, n_radius, e_projectile, v_normal );
		
	e_player thread staff_water_position_source( v_impact_origin, w_weapon, n_charge_level );
}

function staff_water_position_source( v_impact_origin, w_weapon, n_charge_level )
{
	e_fx_model = util::spawn_model( "tag_origin", v_impact_origin );
	e_fx_model endon( "death" );
	v_impact_origin = e_fx_model zm_utility::groundpos_ignore_water_new( v_impact_origin );
	e_fx_model moveTo( v_impact_origin, .05 );
	e_fx_model waittill( "movedone" );
	e_fx_model clientfield::set( "staff_water_blizzard_fx", 1 );
	e_fx_model thread staff_water_blizzard_kill_zombies( w_weapon, self, n_charge_level );
	wait w_weapon.n_blizzard_lifetime;
	e_fx_model notify( "staff_water_blizzard_over" );
	e_fx_model clientfield::set( "staff_water_blizzard_fx", 0 );
	wait 4;
	e_fx_model delete();
}

function staff_water_blizzard_kill_zombies( w_weapon, e_player, n_charge_level )
{
	e_player endon( "death_or_disconnect" );
	self endon( "death" );
	self endon( "staff_water_blizzard_over" );
	WAIT_SERVER_FRAME;
	while ( isDefined( self ) )
	{
		a_zombies = self staff_water_blizzard_effected_zombies( w_weapon.n_blizzard_range );
		array::thread_all( a_zombies, &staff_water_blizzard_damage_zombie, w_weapon, e_player );
		WAIT_SERVER_FRAME;
	}
}

function staff_water_blizzard_effected_zombies( n_blizzard_range )
{
	return array::filter( util::get_array_of_closest( self.origin, getAITeamArray( level.zombie_team ) ), 1, &staff_water_blizzard_effect_zombie_valid, self, n_blizzard_range );
}

function staff_water_blizzard_effect_zombie_valid( e_ai_zombie, e_blizzard, n_blizzard_range )
{
	b_trace_pass = bulletTracePassed( e_blizzard.origin, e_ai_zombie getTagOrigin( ( isDefined( e_ai_zombie.str_staff_water_blizzard_tag_check_override ) ? e_ai_zombie.str_staff_water_blizzard_tag_check_override : "j_spine4" ) ), 0, e_ai_zombie );
	return ( !( IS_TRUE( e_ai_zombie.b_immune_to_staff_water_blizzard ) ) && !( IS_TRUE( e_ai_zombie.b_is_on_ice ) ) && staff_water_distance_passed( e_blizzard.origin, e_ai_zombie.origin, n_blizzard_range, e_ai_zombie.n_staff_water_blizzard_range_check_multiplier ) && b_trace_pass );
}

function staff_water_blizzard_damage_zombie( w_weapon, e_attacker )
{
	if ( !isDefined( self ) )
		return;
	
	if ( isDefined( self.staff_water_blizzard_damage ) )
		self [ [ self.staff_water_blizzard_damage ] ]( e_attacker, w_weapon );
	else
	{
		if ( IS_TRUE( self.b_is_on_ice ) )
			return;
	
		self setCanDamage( 0 );
		self staff_water_freeze_zombie( 1, 1 );
		
		if ( !isDefined( self ) )
			return;
			
		self setCanDamage( 1 );
		self staff_water_damage_ai_response( ( ( isDefined( e_attacker ) && isPlayer( e_attacker ) && isAlive( e_attacker ) ) ? e_attacker : level ), w_weapon, 1, "MOD_RIFLE_BULLET" );
	}
}

function staff_water_distance_passed( v_start_origin, v_end_origin, n_range, n_range_multiplier = 1 )
{
	return ( distance2dSquared( v_start_origin, v_end_origin ) < SQR( n_range ) * n_range_multiplier );
}

function staff_water_trace_passed( v_start_origin, v_end_origin, b_hit_characters = 0, e_ignore_ent = undefined, e_ignore_ent_2 = undefined, b_fx_visibility = 0, b_ignore_water = 1 )
{
	return ( bulletTracePassed( v_start_origin + ( 10, 10, 32 ), v_end_origin + ( 10, 10, 32 ), b_hit_characters, e_ignore_ent, e_ignore_ent_2, b_fx_visibility, b_ignore_water ) || bulletTracePassed( v_start_origin + ( -10, -10, 64 ), v_end_origin + ( -10, -10, 64 ), b_hit_characters, e_ignore_ent, e_ignore_ent_2, b_fx_visibility, b_ignore_water ) );
}

function staff_water_parasite_init()
{
	self.str_staff_water_gib_tag_override = "j_spine";
	self.str_staff_water_blizzard_tag_check_override = "j_spine";
	self.str_staff_water_cone_tag_check_override = "j_spine";
	self.a_staff_water_cone_impact_tag_checks_array_override = array( "j_spine" );
	self.staff_water_zombie_damage = &staff_water_parasite_damage;
	self.staff_water_blizzard_damage = &staff_water_parasite_damage;
	self.staff_water_death = &staff_water_parasite_death;
	self.n_staff_water_blizzard_range_check_multiplier = 1.8;
}

function staff_water_parasite_death( e_player, str_damage_mod )
{
	playFx( "dlc5/zmb_weapon/fx_staff_ice_exp", self getTagOrigin( "j_spine" ), anglesToForward( ( 0, randomInt( 360 ), 0 ) ) );
	self thread zm_weap_staff_common::zombie_gib_all( "j_spine" );
}

function staff_water_parasite_damage( e_player, w_weapon )
{
	if ( IS_TRUE( self.b_is_on_ice ) )
		return;
	
	self.b_is_on_ice = 1;
	
	self setCanDamage( 1 );
	self staff_water_damage_ai_response( ( ( isDefined( e_player ) && isPlayer( e_player ) && isAlive( e_player ) ) ? e_player : level ), w_weapon, 1, "MOD_RIFLE_BULLET" );
}

function staff_water_dog_init()
{
	self.str_staff_water_gib_tag_override = "j_spine1";
	self.str_staff_water_blizzard_tag_check_override = "j_spine1";
	self.str_staff_water_cone_tag_check_override = "j_spine1";
	self.a_staff_water_cone_impact_tag_checks_array_override = array( "j_spine1" );
	self.staff_water_damage = &staff_water_dog_damage;
	self.staff_water_blizzard_damage = &staff_water_dog_damage;
}

function staff_water_dog_damage( e_player, w_weapon )
{
	self clientfield::set( "staff_water_freeze_zombie", 1 );
	self.health = 1;
	self setEntityPaused( 1 );
	wait randomFloatRange( 1.8, 2.3 );
	self setEntityPaused( 0 );
	self zm_weap_staff_common::staff_do_damage( self.health + 666, self.origin, e_player, e_player, undefined, "MOD_RIFLE_BULLET", 0, w_weapon, undefined, undefined );
}


function private is_staff_water_damage( behavior_tree_entity )
{
	if ( !isDefined( level.is_staff_weapon ) || behavior_tree_entity.damagemod == "MOD_MELEE" )
		return 0;
	
	return [ [ level.is_staff_weapon ] ]( behavior_tree_entity.damageweapon, level.a_staff_water_weaponfiles );
}