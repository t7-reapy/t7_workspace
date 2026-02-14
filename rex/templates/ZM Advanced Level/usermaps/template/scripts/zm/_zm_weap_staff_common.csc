#using scripts\codescripts\struct;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\system_shared;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace zm_weap_staff_common;

REGISTER_SYSTEM_EX( "zm_weap_staff_common", &__init__, &__main__, undefined )

function __init__() 
{	
	clientfield::register( "clientuimodel", "hudItems.showDpadLeft_Staff", VERSION_SHIP, 1, "int", undefined, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );	
	clientfield::register( "toplayer", 	"staff_charge_sounds", VERSION_SHIP, 3, "int", &staff_charge_sounds, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	level.a_staff_weaponfiles = [];
	callback::on_localplayer_spawned( &on_local_player_spawned );
}

function __main__()
{
}

function register_staff_weapon_for_level( t7_weapon, staff_weapon_fired = undefined, staff_weapon_obtained = undefined, staff_weapon_lost = undefined, staff_weapon_reloaded = undefined, staff_weapon_pullout = undefined, staff_weapon_putaway = undefined, staff_weapon_first_raise = undefined, staff_weapon_charge = undefined, staff_weapon_charge_reset = undefined, str_weapon_charge_fx = "" )
{	
	w_weapon = ( !isWeapon( t7_weapon ) ? getWeapon( t7_weapon ) : t7_weapon );
	
	w_weapon.staff_weapon_fired			= staff_weapon_fired;
	w_weapon.staff_weapon_obtained 		= staff_weapon_obtained;
	w_weapon.staff_weapon_lost 			= staff_weapon_lost;
	w_weapon.staff_weapon_reloaded 		= staff_weapon_reloaded;
	w_weapon.staff_weapon_pullout 		= staff_weapon_pullout;
	w_weapon.staff_weapon_putaway 		= staff_weapon_putaway;
	w_weapon.staff_weapon_first_raise 	= staff_weapon_first_raise;
	w_weapon.staff_weapon_charge 		= staff_weapon_charge;
	w_weapon.staff_weapon_charge_reset	= staff_weapon_charge_reset;
	w_weapon.str_weapon_charge_fx		= str_weapon_charge_fx;
	
	ARRAY_ADD( level.a_staff_weaponfiles, w_weapon );
}

function on_local_player_spawned( n_local_client_num ) 
{
	self thread staff_watch_change_weapon( n_local_client_num );
}

function staff_charge_sounds( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump )
{
	w_weapon = getCurrentWeapon( n_local_client_num );
	if ( !is_staff_weapon( w_weapon ) )
		return;
	
	if ( isDefined( w_weapon.staff_weapon_charge ) )
		self [ [ w_weapon.staff_weapon_charge ] ]( n_local_client_num, w_weapon, n_new_value );
	else
		self play_staff_charge_up_sounds( n_local_client_num, w_weapon, n_new_value );
}

function play_staff_charge_up_sounds( n_local_client_num, w_weapon, n_charge_level = 0, str_one_shot_sound = undefined, str_looping_sound = undefined )
{
	if ( n_charge_level > 0 )
	{
		if ( isDefined( str_one_shot_sound ) )
			self playSound( n_local_client_num, str_one_shot_sound );
	
		if ( !isDefined( self.snd_str_staff_charge_loop_sound ) )
			self.snd_str_staff_charge_loop_sound = self playLoopSound( str_looping_sound, .5 );
		
	}
	else
	{
		if ( !isDefined( self.snd_str_staff_charge_loop_sound ) )
			return;
	
		self stopLoopSound( self.snd_str_staff_charge_loop_sound, .5 );
		self.snd_str_staff_charge_loop_sound = undefined;
	}
}

function is_staff_weapon( w_weapon )
{
	return ( isDefined( level.a_staff_weaponfiles ) && isArray( level.a_staff_weaponfiles ) && isInArray( level.a_staff_weaponfiles, w_weapon ) );
}

function is_upgraded_staff_weapon( w_weapon )
{
	return ( is_staff_weapon( w_weapon ) && IS_TRUE( w_weapon.b_is_upgrade ) );
}

function staff_aoe_looping_sound( n_local_client_num, str_loop_sound, str_start_sound = undefined, str_end_sound = undefined, n_loop_sound_fade_in_time = 0, n_loop_sound_fade_out_time = 0 )
{
	e_ent = spawn( n_local_client_num, self.origin, "script_origin" );
	e_ent linkTo( self );
	
	e_ent endon( "death" );
	e_ent endon( "entity_shutdown" );
	
	if ( isDefined( str_start_sound ) )
		e_ent playSound( n_local_client_num, str_start_sound );
	
	e_ent.e_staff_sndent = e_ent playLoopSound( str_loop_sound, n_loop_sound_fade_in_time );
	self waittill( "staff_aoe_looping_sound_end" );
	e_ent stopLoopSound( e_ent.e_staff_sndent, n_loop_sound_fade_out_time );
	
	if ( isDefined( str_end_sound ) )
		e_ent playSound( n_local_client_num, str_end_sound );
	
	wait n_loop_sound_fade_out_time;
	if ( isDefined( e_ent ) )
		e_ent delete();

}

function staff_shake_and_rumble( n_local_client_num, n_scale = .3, n_duration = 1, n_radius = 100, str_rumble_name = "artillery_rumble" )
{
	self notify( "staff_shake_and_rumble" );
	self endon( "staff_shake_and_rumble" );
	self endon( "entity_shutdown" );
	
	while ( isDefined( self ) )
	{
		self earthquake( n_scale, n_duration, self.origin, n_radius );
		self playRumbleOnEntity( n_local_client_num, str_rumble_name );
		WAIT_CLIENT_FRAME;
	}
}

function staff_watch_change_weapon( n_local_client_num )
{
	self endon( "death_or_disconnect" );
	self notify( "staff_watch_change_weapon" );
	self endon( "staff_watch_change_weapon" );
	
	while ( isDefined( self ) )
	{
		self waittill( "weapon_change", w_weapon, w_old_weapon );
		
		if ( !isDefined( w_weapon ) || w_weapon == level.weaponNone )
			continue;
		
		if ( is_staff_weapon( w_weapon ) )
		{
			self notify( "staff_weapon_equipped" );
			// self staff_watch_charge_level( n_local_client_num );
			if ( isDefined( w_weapon.str_weapon_charge_fx ) )
				self thread staff_watch_charge_level( n_local_client_num, w_weapon.str_weapon_charge_fx );
				
		}
	}
}

function staff_watch_charge_level( n_local_client_num, str_fx )
{
	self endon( "staff_weapon_equipped" );
	while ( isDefined( self ) )
	{
		n_charge = getWeaponChargeLevel( n_local_client_num );
		if ( n_charge > 0 )
		{
			if ( !isDefined( self.fx_staff_light ) )
				self.fx_staff_light = playViewmodelFx( n_local_client_num, str_fx, "tag_fx_upg_1" );
			
		}
		else
		{
			if ( isDefined( self.fx_staff_light ) )
			{
				stopFx( n_local_client_num, self.fx_staff_light );
				self.fx_staff_light = undefined;
			}
		}
		
		WAIT_CLIENT_FRAME;
	}
}
