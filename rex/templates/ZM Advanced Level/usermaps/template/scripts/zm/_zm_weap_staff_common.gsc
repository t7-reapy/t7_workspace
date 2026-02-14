#using scripts\codescripts\struct;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\util_shared;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\system_shared;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_unitrigger;
#using scripts\zm\_zm_utility;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_utility.gsh;

#namespace zm_weap_staff_common; 

REGISTER_SYSTEM_EX( "zm_weap_staff_common", &__init__, &__main__, undefined )

function __init__()
{
	clientfield::register( "clientuimodel", "hudItems.showDpadLeft_Staff", VERSION_SHIP, 1, "int" );
	clientfield::register( "toplayer", 	"staff_charge_sounds", VERSION_SHIP, 3, "int" );
	level.a_staff_weaponfiles = [];
	level.a_staff_upgrade_pedestals = [];
	level.n_active_ragdolls = 0;
	setDvar( "bg_chargeShotExponentialAmmoPerChargeLevel", "1" );
	callback::on_spawned( &on_player_spawned );
	level.ragdoll_limit_check = &staff_ragdoll_attempt;
	level.is_staff_weapon = &is_staff_weapon;
}

function __main__()
{
}

function register_staff_weapon_for_level( t7_weapon, staff_weapon_fired = undefined, staff_weapon_missile_fired = undefined, staff_weapon_grenade_fired = undefined, staff_weapon_obtained = &staff_upgraded_weapon_obtained, staff_weapon_lost = &staff_upgraded_weapon_lost, staff_weapon_reloaded = undefined, staff_weapon_pullout = &staff_upgraded_weapon_pullout, staff_weapon_putaway = &staff_upgraded_weapon_putaway, staff_weapon_first_raise = undefined, staff_weapon_charge = undefined )
{	
	w_weapon = ( !isWeapon( t7_weapon ) ? getWeapon( t7_weapon ) : t7_weapon );

	w_weapon.staff_weapon_fired			= staff_weapon_fired;
	w_weapon.staff_weapon_missile_fired	= staff_weapon_missile_fired;
	w_weapon.staff_weapon_grenade_fired = staff_weapon_grenade_fired;
	w_weapon.staff_weapon_pullout 		= staff_weapon_pullout;
	w_weapon.staff_weapon_putaway 		= staff_weapon_putaway;
	w_weapon.staff_weapon_first_raise 	= staff_weapon_first_raise;
	w_weapon.staff_weapon_obtained		= staff_weapon_obtained;
	w_weapon.staff_weapon_lost 			= staff_weapon_lost;
	w_weapon.staff_weapon_reloaded 		= staff_weapon_reloaded;
	w_weapon.staff_weapon_charge 		= staff_weapon_charge;

	zombie_utility::add_zombie_gib_weapon_callback( w_weapon.name, undefined, &staff_head_gib_nullify );
	register_weapon_exclude_for_explode_death_anims( w_weapon );
	ARRAY_ADD( level.a_staff_weaponfiles, w_weapon );
}

function register_weapon_exclude_for_explode_death_anims( w_weapon )
{
	DEFAULT( level.a_explode_death_excluded_weapons, [] );
	ARRAY_ADD( level.a_explode_death_excluded_weapons, w_weapon );
}

function on_player_spawned()
{
	self thread staff_watch_charge_level();
	self thread staff_watch_weapon_fired();
	self thread staff_watch_weapon_missile_fired();
	self thread staff_watch_weapon_grenade_fired();
	self thread staff_watch_weapon_projectile_impact();
}

function staff_watch_weapon_fired()
{
	self endon( "death_or_disconnect" );
	self notify( "monitor_weapon_fired" );
	self endon( "monitor_weapon_fired" );
	
	while ( isDefined( self ) )
	{
		self waittill( "weapon_fired", w_weapon );
		
		if ( isDefined( w_weapon.staff_weapon_fired ) )
			self thread [ [ w_weapon.staff_weapon_fired ] ]( w_weapon );
			
	}
}

function staff_watch_weapon_missile_fired()
{
	self endon( "death_or_disconnect" );
	self notify( "monitor_weapon_missile_fired" );
	self endon( "monitor_weapon_missile_fired" );
	
	while ( isDefined( self ) )
	{
		self waittill( "missile_fire", e_projectile, w_weapon );
		
		if ( isDefined( e_projectile ) && IS_TRUE( e_projectile.b_additional_shot ) )
			continue;
		
		if ( isDefined( w_weapon.staff_weapon_missile_fired ) )
			self thread [ [ w_weapon.staff_weapon_missile_fired ] ]( e_projectile, w_weapon, self.chargeshotlevel );
			
	}
}

function staff_watch_weapon_projectile_impact()
{
	self endon( "death_or_disconnect" );
	self notify( "monitor_weapon_projectile_impact" );
	self endon( "monitor_weapon_projectile_impact" );
	
	while ( isDefined( self ) )
	{
		self waittill( "projectile_impact", w_weapon, v_position, n_radius, attacker, v_normal );
		
		if ( isDefined( w_weapon.staff_weapon_projectile_impact ) )
			self thread [ [ w_weapon.staff_weapon_projectile_impact ] ]( w_weapon, v_position, n_radius, attacker, v_normal );
			
	}
}

function staff_watch_weapon_grenade_fired()
{
	self endon( "death_or_disconnect" );
	self notify( "monitor_weapon_grenade_fired" );
	self endon( "monitor_weapon_grenade_fired" );
	
	while ( isDefined( self ) )
	{
		self waittill( "grenade_fire", e_projectile, w_weapon );
		
		if ( isDefined( e_projectile ) && IS_TRUE( e_projectile.b_additional_shot ) )
			continue;
		
		if ( isDefined( w_weapon.staff_weapon_grenade_fired ) )
			self thread [ [ w_weapon.staff_weapon_grenade_fired ] ]( e_projectile, w_weapon, self.chargeshotlevel );
			
	}
}

function staff_ragdoll_attempt()
{
	DEFAULT( level.n_active_ragdolls, 0 );
	
	if ( level.n_active_ragdolls >= 64 )
		return 0;
	
	level thread staff_add_ragdoll();
	return 1;
}

function is_staff_weapon( w_weapon, a_array = level.a_staff_weaponfiles )
{
	return ( isDefined( a_array ) && isArray( a_array ) && isInArray( a_array, w_weapon ) );
}

function staff_upgraded_weapon_pullout( w_previous_weapon, w_new_weapon )
{
	if ( !is_upgraded_staff_weapon( w_new_weapon ) )
		return;
		
	self setActionSlot( 3, "weapon", getWeapon( "staff_revive" ) );
	self clientfield::set_player_uimodel("hudItems.showDpadLeft_Staff", 1);
	self.attachment_ammo_weapon = getWeapon( "staff_revive" );
}

function staff_upgraded_weapon_obtained( w_weapon )
{
	if ( is_upgraded_staff_weapon( w_weapon ) )
	{
		if ( !self hasWeapon( getWeapon( "staff_revive" ) ) )
			self giveWeapon( getWeapon( "staff_revive" ) );
		if ( isDefined( w_weapon.n_revive_ammo_clip ) && IS_TRUE( 1 ) )
			self setWeaponAmmoClip( getWeapon( "staff_revive" ), w_weapon.n_revive_ammo_clip );
		if ( isDefined( w_weapon.n_revive_ammo_stock ) && IS_TRUE( 1 ))
			self setWeaponAmmoStock( getWeapon( "staff_revive" ), w_weapon.n_revive_ammo_stock );
	}
	
	if ( isDefined( w_weapon.n_ammo_clip ) && IS_TRUE( 1 ))
		self setWeaponAmmoClip( w_weapon, w_weapon.n_ammo_clip );
	if ( isDefined( w_weapon.n_ammo_stock ) && IS_TRUE( 1 ))
		self setWeaponAmmoStock( w_weapon, w_weapon.n_ammo_stock );
	
	self thread staff_ammo_recorder( w_weapon );
}

function staff_upgraded_weapon_lost( w_weapon )
{	
	if ( !self has_upgraded_staff() && self hasWeapon( getWeapon( "staff_revive" ) ) )
		self takeWeapon( getWeapon( "staff_revive" ) );
}

function staff_upgraded_weapon_putaway( w_previous_weapon, w_new_weapon )
{
	if ( !is_upgraded_staff_weapon( w_previous_weapon ) )
		return;
		
	self setActionSlot( 3, "" );
	self clientfield::set_player_uimodel("hudItems.showDpadLeft_Staff", 0);
	self.attachment_ammo_weapon = undefined;
}

function staff_head_gib_nullify( str_damage_location )
{
	return 0;
}

function staff_ammo_recorder( w_staff_weapon )
{
	self endon( "death_or_disconnect" );
	while ( isDefined( self ) )
	{
		if ( !self hasWeapon( w_staff_weapon ) )
			break;
		
		foreach( w_weapon in self getWeaponsList( 1 ) )
		{
			if ( w_weapon == w_staff_weapon )
			{
				w_weapon.n_ammo_clip = self getWeaponAmmoClip( w_weapon );
				w_weapon.n_ammo_stock = self getWeaponAmmoStock( w_weapon );
				if ( self hasWeapon( getWeapon( "staff_revive" ) ) )
				{
					w_weapon.n_revive_ammo_clip = self getWeaponAmmoClip( getWeapon( "staff_revive" ) );
					w_weapon.n_revive_ammo_stock = self getWeaponAmmoStock( getWeapon( "staff_revive" ) );
				}
			}
		}
		WAIT_SERVER_FRAME;
	}
}

function staff_distance_2d_squared_passed( v_start_origin, v_end_origin, n_range, n_range_multiplier = 1 )
{
	return ( distance2dSquared( v_start_origin, v_end_origin ) < SQR( n_range  )  );
}

function staff_trace_passed( v_start_origin, v_end_origin, b_hit_characters = 0, e_ignore_ent = undefined, e_ignore_ent_2 = undefined, b_fx_visibility = 0, b_ignore_water = 1, extra_function_run_after_check = undefined )
{
	b_trace_result = ( bulletTracePassed( v_start_origin + ( 10, 10, 32 ), v_end_origin + ( 10, 10, 32 ), b_hit_characters, e_ignore_ent, e_ignore_ent_2, b_fx_visibility, b_ignore_water ) || bulletTracePassed( v_start_origin + ( -10, -10, 64 ), v_end_origin + ( -10, -10, 64 ), b_hit_characters, e_ignore_ent, e_ignore_ent_2, b_fx_visibility, b_ignore_water ) );
	if ( IS_TRUE( b_trace_result ) && isDefined( extra_function_run_after_check ) )
		b_trace_result = [ [ extra_function_run_after_check ] ]();
	
	return b_trace_result;
}

function staff_do_damage( n_amount = undefined, v_source_origin = self.origin, e_attacker = level, e_inflictor = undefined, str_hit_location = undefined, str_means_of_death = "MOD_UNKNOWN", n_id_flag = 0, w_weapon = level.weaponNone, n_destructable_piece_index = undefined, b_force_pain = 0 )
{
	n_amount = ( ( isDefined( e_attacker ) && isPlayer( e_attacker ) && e_attacker zm_powerups::is_insta_kill_active() ) ? self.health + 666 : n_amount );
	self doDamage( ( isDefined( n_amount ) ? ( ( isDefined( n_amount ) && n_amount == -1 ) ? self.health + 666 : n_amount ) : ( isDefined( w_weapon.n_damage ) ? w_weapon.n_damage : 0 ) ), v_source_origin, e_attacker, e_inflictor, str_hit_location, str_means_of_death, n_id_flag, w_weapon, n_destructable_piece_index, b_force_pain );
}

function staff_add_ragdoll()
{
	DEFAULT( level.n_active_ragdolls, 0 );
	
	level.n_active_ragdolls++;
	wait 1;
	if ( level.n_active_ragdolls > 0 )
		level.n_active_ragdolls--;
	
}

function staff_watch_charge_level()
{
	self endon( "death_or_disconnect" );
	self notify( "staff_watch_charge_level" );
	self endon( "staff_watch_charge_level" );
	
	while ( isDefined( self ) )
	{
		n_charge_level = 0;
		self clientfield::set_to_player( "staff_charge_sounds", 0 );
		
		while ( !self attackButtonPressed() )
			WAIT_SERVER_FRAME;
		
		while ( !self isSwitchingWeapons() && !self isFiring() && !self isReloading() && self attackButtonPressed() )
		{
			if ( n_charge_level != self.chargeshotlevel && self.chargeshotlevel > 0 )
			{
				n_charge_level = self.chargeshotlevel;
				self clientfield::set_to_player( "staff_charge_sounds", n_charge_level );
			}
			WAIT_SERVER_FRAME;
		}
		WAIT_SERVER_FRAME;
	}
}

function is_upgraded_staff_weapon( w_weapon )
{
	return ( is_staff_weapon( w_weapon ) && IS_TRUE( w_weapon.b_is_upgrade ) );
}

function has_upgraded_staff()
{
	foreach( w_weapon in self getWeaponsListPrimaries() )
		if ( is_upgraded_staff_weapon( w_weapon ) )
			return 1;
	
	return 0;
}

function disable_pain_and_reaction( b_store_previous_state = 1, b_bypass_if_state_already_stored = 1 )
{
	if ( IS_TRUE( b_store_previous_state ) )
	{
		self.olddisablepain = ( !isDefined( self.olddisablepain ) ? self.a.disablepain : ( IS_TRUE( b_bypass_if_state_already_stored ) ? self.olddisablepain : self.a.disablepain ) );
		self.oldallowpain = ( !isDefined( self.oldallowpain ) ? self.allowpain : ( IS_TRUE( b_bypass_if_state_already_stored ) ? self.oldallowpain : self.allowpain ) );
		self.olddisableReact = ( !isDefined( self.olddisableReact ) ? self.a.disableReact : ( IS_TRUE( b_bypass_if_state_already_stored ) ? self.olddisableReact : self.a.disableReact ) );
		self.oldallowReact = ( !isDefined( self.oldallowReact ) ? self.allowReact : ( IS_TRUE( b_bypass_if_state_already_stored ) ? self.oldallowReact : self.allowReact ) );
	}	
	
	self.olddisablepain = self.a.disablepain;
	self.oldallowpain = self.allowpain;	
	self.olddisableReact = self.disableReact;	
	self.oldallowReact = self.allowReact;	
	self.a.disablepain = 1;
	self.allowpain = 0;
	self.a.disableReact = 1;
	self.allowReact = 0;
}

function enable_pain_and_reaction( b_restore_previous_state = 1 )
{
	if ( IS_TRUE( b_restore_previous_state ) )
	{
		self.a.disablepain = ( isDefined( self.olddisablepain ) ? self.olddisablepain : 0 );
		self.allowpain = ( isDefined( self.oldallowpain ) ? self.oldallowpain : 1 );
		self.a.disableReact = ( isDefined( self.olddisableReact ) ? self.olddisableReact : 0 );
		self.allowReact = ( isDefined( self.oldallowReact ) ? self.oldallowReact : 1 );
	}
	else
	{
		self.a.disablepain = 0;
		self.allowpain = 1;
		self.a.disableReact = 0;
		self.allowReact = 1;
		self.olddisablepain = undefined;
		self.oldallowpain = undefined;	
		self.olddisableReact = undefined;	
		self.oldallowReact = undefined;	
	}
}

function disable_find_flesh( b_keep_goal = 0 )
{
	v_origin = undefined;
	if ( IS_TRUE( b_keep_goal ) )
	{
		if ( isDefined( self.v_zombie_custom_goal_pos ) )
			v_origin = self.v_zombie_custom_goal_pos;
		else if ( isDefined( self.favoriteenemy ) && isDefined( self.favoriteenemy.origin ) )
			v_origin = self.favoriteenemy.origin;
		else if ( isDefined( self.attackable ) && isDefined( self.attackable.origin ) )
			v_origin = self.attackable.origin;
		else if ( isDefined( self.attackable_slot ) && isDefined( self.attackable_slot.origin ) )
			v_origin = self.attackable_slot.origin;
		else
			v_origin = self.origin + ( anglesToForward( self.angles ) * 40 );
	}
	
	self.b_previous_ignore_find_flesh = self.ignore_find_flesh;
	self.b_previous_ignore_all = self.ignoreall;
	self.ignore_find_flesh = 1;
	self notify( "stop_find_flesh" );
	self.ignoreall = 1;
	
	if ( isDefined( v_origin ) )
		self setGoal( v_origin );
	
}

function enable_find_flesh()
{
	self.ignore_find_flesh = ( isDefined( self.b_previous_ignore_find_flesh ) ? self.b_previous_ignore_find_flesh : 0 );
	self.b_previous_ignore_find_flesh = undefined;
	self.ignoreall = ( isDefined( self.b_previous_ignore_all ) ? self.b_previous_ignore_all : 0 );
	
	if ( !IS_TRUE( self.ignore_find_flesh ) )
		self notify( "zombie_acquire_enemy" );
	
}

function zombie_gib_all( str_fx_tag = "j_spinelower" )
{
	if ( !isDefined( self ) )
		return;
		
	v_origin = self getTagOrigin( str_fx_tag );
	if ( isDefined( v_origin ) )
	{
		v_forward = anglesToForward( ( 0, randomInt( 360 ), 0 ) );
		playFx( level._effect[ "zombie_guts_explosion" ], v_origin, v_forward );
		playSoundAtPosition( "zmb_death_gibs", self.origin + ( 0, 0, 64 ) );
		playSoundAtPosition( "zmb_zombie_head_gib", self.origin + ( 0, 0, 64 ) );
	}
	
	a_gib_ref = [];
	a_gib_ref[ 0 ] = level._zombie_gib_piece_index_all;
	self gib( "normal", a_gib_ref );
	self ghost();
	wait .4;
	if ( isDefined( self ) )
		self delete();
	
}

function zombie_gib_guts( str_fx_tag = "j_spinelower" )
{
	if ( !isDefined( self ) )
		return;
	
	v_origin = self getTagOrigin( str_fx_tag );
	if ( isDefined( v_origin ) )
	{
		v_forward = anglesToForward( ( 0, randomint( 360 ), 0 ) );
		playFx( level._effect[ "zombie_guts_explosion" ], v_origin, v_forward );
		playSoundAtPosition( "zmb_death_gibs", self.origin + ( 0, 0, 64 ) );
		playSoundAtPosition( "zmb_zombie_head_gib", self.origin + ( 0, 0, 64 ) );
	}
	
	self ghost();
	wait randomFloatRange( .4, 1.1 );
	if ( isDefined( self ) )
		self delete();
		
}

function projectile_delete( n_lifetime = .75 )
{
	self endon( "death" );
	wait n_lifetime;
	self delete();
}

function take_all_staff_weapons()
{
	foreach ( w_weapon in self getWeaponsList( 1 ) )
	{
		if ( isInArray( level.a_staff_weaponfiles, w_weapon ) )
			self zm_weapons::weapon_take( w_weapon );
		
	}
}

function attach_staff_glow_fx( str_staff_name )
{
	n_elem = 0;
	if ( isSubStr( str_staff_name, "fire" ) )
		n_elem = 1;
	else if ( isSubStr( str_staff_name, "air" ) )
		n_elem = 2;
	else if ( isSubStr( str_staff_name, "bolt" ) )
		n_elem = 3;
	else if ( isSubStr( str_staff_name, "water" ) )
		n_elem = 4;
		
	self clientfield::set( "staff_element_glow_fx", n_elem );
}

function create_linker_entity( v_origin, v_angles, str_model = "tag_origin", v_rotate_to_angle = undefined )
{
	if ( isDefined( self.e_linker ) )
		return;
	
	self.e_linker = util::spawn_model( str_model, v_origin, v_angles );
	self linkTo( self.e_linker );
	
	if ( isDefined( v_rotate_to_angle ) )
		self.e_linker.angles = v_rotate_to_angle;

	self thread linker_remove_failsafe();
}

function linker_remove_failsafe()
{
	self.e_linker endon( "linker_delete" );
	self waittill( "death" );
	self delete_linker_entity(); 
}

function delete_linker_entity()
{
	if ( !isDefined( self.e_linker ) )
		return;
	
	self.e_linker notify( "linker_delete" );
	self.e_linker unLink();
	self.e_linker delete();
}