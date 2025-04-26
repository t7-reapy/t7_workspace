#using scripts\codescripts\struct;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\damagefeedback_shared;
#using scripts\shared\system_shared;
#using scripts\zm\gametypes\_globallogic_score;
#using scripts\zm\_zm;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_perk_utility;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_perk_elemental_pop.gsh;

#precache( "string", "HB21_ZM_PERKS_ELEMENTAL_POP" );
#precache( "triggerstring", "HB21_ZM_PERKS_ELEMENTAL_POP", ELEMENTAL_POP_PERK_COST_STRING );
#precache( "fx", ELEMENTAL_POP_MACHINE_LIGHT_FX );

#namespace zm_perk_elemental_pop;

REGISTER_SYSTEM_EX( "zm_perk_elemental_pop", &__init__, &__main__, undefined )

// CALLBACKS AND OVERRIDES
// 
// NONE

//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------
function __init__()
{
	if ( IS_TRUE( ELEMENTAL_POP_LEVEL_USE_PERK ) )
		enable_elemental_pop_perk_for_level();
	
}

function __main__()
{
	if ( IS_TRUE( ELEMENTAL_POP_LEVEL_USE_PERK ) )
		elemental_pop_main();
	
}

function enable_elemental_pop_perk_for_level()
{	
	zm_perks::register_perk_basic_info( ELEMENTAL_POP_PERK, ELEMENTAL_POP_ALIAS, ELEMENTAL_POP_PERK_COST, &"HB21_ZM_PERKS_ELEMENTAL_POP", getWeapon( ELEMENTAL_POP_PERK_BOTTLE_WEAPON ) );
	zm_perks::register_perk_precache_func( ELEMENTAL_POP_PERK, &elemental_pop_precache );
	zm_perks::register_perk_clientfields( ELEMENTAL_POP_PERK, &elemental_pop_register_clientfield, &elemental_pop_set_clientfield );
	zm_perks::register_perk_machine( ELEMENTAL_POP_PERK, &elemental_pop_perk_machine_setup );
	zm_perks::register_perk_threads( ELEMENTAL_POP_PERK, &elemental_pop_give_perk, &elemental_pop_take_perk );
	zm_perks::register_perk_host_migration_params( ELEMENTAL_POP_PERK, ELEMENTAL_POP_RADIANT_MACHINE_NAME, ELEMENTAL_POP_PERK );
	if ( zm_perk_utility::is_stock_map() && ( level.script == "zm_zod" || level.script == "zm_genesis" ) )
		zm_perks::register_perk_machine_power_override( ELEMENTAL_POP_PERK, &elemental_pop_power_override );
		
}

function elemental_pop_precache()
{
	level._effect[ ELEMENTAL_POP_PERK ] = ELEMENTAL_POP_MACHINE_LIGHT_FX;
	
	level.machine_assets[ ELEMENTAL_POP_PERK ] = spawnStruct();
	level.machine_assets[ ELEMENTAL_POP_PERK ].weapon = getWeapon( ELEMENTAL_POP_PERK_BOTTLE_WEAPON );
	level.machine_assets[ ELEMENTAL_POP_PERK ].off_model = ELEMENTAL_POP_MACHINE_DISABLED_MODEL;
	level.machine_assets[ ELEMENTAL_POP_PERK ].on_model = ELEMENTAL_POP_MACHINE_ACTIVE_MODEL;	
}

function elemental_pop_register_clientfield() 
{
	clientfield::register( "clientuimodel", ELEMENTAL_POP_CLIENTFIELD, VERSION_SHIP, 2, "int" );
	clientfield::register( "clientuimodel", ELEMENTAL_POP_UI_GLOW_CLIENTFIELD, VERSION_SHIP, 1, "int" );
}

function elemental_pop_set_clientfield( n_state ) 
{
	if ( n_state != 0 && ( level zm_perk_utility::is_perk_paused( ELEMENTAL_POP_PERK ) || self zm_perk_utility::is_perk_paused( ELEMENTAL_POP_PERK ) ) )
		n_state = 2;
	
	self clientfield::set_player_uimodel( ELEMENTAL_POP_CLIENTFIELD, n_state );
}

function elemental_pop_perk_machine_setup( e_use_trigger, e_perk_machine, e_bump_trigger, e_collision )
{
	e_use_trigger.script_sound = ELEMENTAL_POP_JINGLE;
	e_use_trigger.script_string = ELEMENTAL_POP_SCRIPT_STRING;
	e_use_trigger.script_label = ELEMENTAL_POP_STING;
	e_use_trigger.target = ELEMENTAL_POP_RADIANT_MACHINE_NAME;
	e_perk_machine.script_string = ELEMENTAL_POP_SCRIPT_STRING;
	e_perk_machine.targetname = ELEMENTAL_POP_RADIANT_MACHINE_NAME;
	if ( isDefined( e_bump_trigger ) )
		e_bump_trigger.script_string = ELEMENTAL_POP_SCRIPT_STRING;
	
	e_perk_machine thread zm_perk_utility::register_vulture_perk_safe();
}

function elemental_pop_give_perk() 
{
	zm_perk_utility::print_version( ELEMENTAL_POP_PERK, ELEMENTAL_POP_VERSION );
	
	if ( level zm_perk_utility::is_perk_paused( ELEMENTAL_POP_PERK ) )
		self zm_perk_utility::player_pause_perk( ELEMENTAL_POP_PERK );
	
	if ( self zm_perk_utility::is_perk_paused( ELEMENTAL_POP_PERK ) )
		return;
	
	self elemental_pop_enabled( 1 );
}

function elemental_pop_take_perk( b_pause, str_perk, str_result ) 
{
	self elemental_pop_enabled( 0 );
}

function elemental_pop_power_override()
{
	zm_perk_utility::force_power( ELEMENTAL_POP_PERK );
}

//-----------------------------------------------------------------------------------
// FUNCTIONALITY
//-----------------------------------------------------------------------------------
function elemental_pop_main()
{
	if ( IS_TRUE( ELEMENTAL_POP_IN_WONDERFIZZ ) )
		zm_perk_utility::add_perk_to_wunderfizz( ELEMENTAL_POP_PERK );
	
	zm::register_zombie_damage_override_callback( &elemental_pop_damage_modifier );
	zm::register_vehicle_damage_callback( &elemental_pop_vehicle_damage_monitor );
	callback::on_connect( &elemental_pop_register_stat );
}

function elemental_pop_enabled( b_enabled )
{
	if ( IS_TRUE( b_enabled ) )
	{
	}
	else
	{
		self clientfield::set_player_uimodel( ELEMENTAL_POP_UI_GLOW_CLIENTFIELD, 0 );
	}
}

function elemental_pop_vehicle_damage_monitor( e_inflictor, e_attacker, n_damage, n_flags, str_means_of_death, w_weapon, v_point, v_dir, str_hit_loc, v_damage_origin, n_offset_time, b_damage_from_underneath, n_model_index, str_part_name, v_surface_normal )
{
	b_will_be_killed = ( self.health - n_damage ) <= 0;

	if ( IS_TRUE( level.aat_in_use ) )
		self thread elemental_pop_damage_modifier( b_will_be_killed, e_inflictor, e_attacker, n_damage, n_flags, str_means_of_death, w_weapon, v_point, v_dir, str_hit_loc, n_offset_time, b_damage_from_underneath, v_surface_normal );
	
	return n_damage;
}

function elemental_pop_damage_modifier( b_death, e_inflictor, e_attacker, n_damage, b_flags, str_means_of_death, w_weapon, v_point, v_dir, str_hit_loc, n_ps_offset_time, n_bone_index, str_surface_type )
{	
	if ( !isPlayer( e_attacker ) )
		return;

	if ( !e_attacker hasPerk( ELEMENTAL_POP_PERK ) )
		return;

	if ( str_means_of_death != "MOD_PISTOL_BULLET" && str_means_of_death != "MOD_RIFLE_BULLET" && str_means_of_death != "MOD_GRENADE" && str_means_of_death != "MOD_PROJECTILE" && str_means_of_death != "MOD_EXPLOSIVE" && str_means_of_death != "MOD_IMPACT" )
		return;
	
	w_weapon = zm_weapons::get_nonalternate_weapon( w_weapon );

	str_weapon_aat = e_attacker.aat[ w_weapon ];

	str_random = array::random( getArrayKeys( level.aat ) );
	if ( !isDefined( str_random ) || str_random == "none" || ( isDefined( str_weapon_aat ) && str_weapon_aat == str_random ) )
		return;

	if ( b_death && !level.aat[ str_random ].occurs_on_death )
		return;
	
	if ( !isDefined( self.archetype ) )
		return;
	
	if ( IS_TRUE( level.aat[ str_random ].immune_trigger[ self.archetype ] ) )
		return;

	n_time = getTime() / 1000;
	if ( n_time <= self.aat_cooldown_start[ str_random ] + level.aat[ str_random ].cooldown_time_entity )
		return;

	if ( n_time <= e_attacker.aat_cooldown_start[ str_random ] + level.aat[ str_random ].cooldown_time_attacker )
		return;
	
	if ( n_time <= level.aat[ str_random ].cooldown_time_global_start + level.aat[ str_random ].cooldown_time_global )
		return;

	if ( isDefined( level.aat[ str_random ].validation_func ) )
	{
		if ( !self [ [ level.aat[ str_random ].validation_func ] ]() )
			return;
		
	}
	
	b_success = 0;
	str_reroll_icon = undefined;
	n_percentage = level.aat[ str_random ].percentage;

	if ( n_percentage >= randomFloat( 1 ) )
		b_success = 1;

	if ( !b_success )
	{
		a_keys = array::randomize( getArrayKeys( level.aat_reroll ) );
		foreach ( str_key in a_keys )
		{
			if ( e_attacker [ [ level.aat_reroll[ str_key ].active_func ] ]() )
			{
				for ( i = 0; i < level.aat_reroll[ str_key ].count; i++ )
				{
					if ( n_percentage >= randomFloat( 1 ) )
					{
						b_success = 1;
						str_reroll_icon = level.aat_reroll[ str_key ].damage_feedback_icon;
						break;
					}
				}
			}			
		}
	}

	if ( b_success )
	{
		n_random = randomInt( ELEMENTAL_POP_CHANCE_OF_ACTIVATION );
		if ( n_random != 0 )
			return;
		
		level.aat[ str_random ].cooldown_time_global_start = n_time;
		e_attacker.elemental_pop_aat_cooldown_start[ str_random ] = n_time;

		self thread [ [ level.aat[ str_random ].result_func ] ]( b_death, e_attacker, str_means_of_death, w_weapon );
		e_attacker thread damagefeedback::update_override( level.aat[ str_random ].damage_feedback_icon, level.aat[ str_random ].damage_feedback_sound, str_reroll_icon );
		if ( IS_TRUE( ELEMENTAL_POP_SHOW_UI_GLOW ) )
			e_attacker thread elemental_pop_damage_ui_glow();
	
	}

	return;
}

function elemental_pop_damage_ui_glow()
{
	self notify( "elemental_pop_damage_ui_glow" );
	self endon( "elemental_pop_damage_ui_glow" );
	self clientfield::set_player_uimodel( ELEMENTAL_POP_UI_GLOW_CLIENTFIELD, 1 );
	wait ELEMENTAL_POP_SHOW_UI_GLOW_DURATION;
	self clientfield::set_player_uimodel( ELEMENTAL_POP_UI_GLOW_CLIENTFIELD, 0 );
}

function elemental_pop_register_stat()
{
	globallogic_score::initPersStat( ELEMENTAL_POP_PERK + "_drank", false );	
}