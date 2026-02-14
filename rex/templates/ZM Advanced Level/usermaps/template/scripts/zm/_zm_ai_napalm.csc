#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\math_shared;
#using scripts\shared\postfx_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

//#precache( "client_fx", "dlc5/temple/fx_ztem_napalm_zombie_forearm" );
//#precache( "client_fx", "dlc5/temple/fx_ztem_napalm_zombie_torso" );
//#precache( "client_fx", "dlc5/temple/fx_ztem_napalm_zombie_heat" );
//#precache( "client_fx", "dlc5/temple/fx_ztem_napalm_zombie_forearm_end" );
//#precache( "client_fx", "dlc5/temple/fx_ztem_napalm_zombie_torso_end" );
//#precache( "client_fx", "dlc5/temple/fx_ztem_zombie_torso_steam_runner" );
//#precache( "client_fx", "dlc5/temple/fx_ztem_napalm_zombie_ground2" );

#namespace zm_ai_napalm;

REGISTER_SYSTEM_EX( "zm_ai_napalm", &__init__, undefined, undefined )

function __init__()
{
	init_clientfields();
	init_napalm_zombie();
}

function init_clientfields()
{
	clientfield::register( "actor", "napalmwet", VERSION_SHIP, 1, "int", &napalm_zombie_wet_callback, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "actor", "napalmexplode", VERSION_SHIP, 1, "int", &napalm_zombie_explode_callback, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "actor", "isnapalm", VERSION_SHIP, 1, "int", &napalm_zombie_spawn, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "toplayer", "napalm_pstfx_burn", VERSION_SHIP, 1, "int", &napalm_pstfx_burn, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
}

function init_napalm_zombie()
{
	level.napalmplayerwarningradiussqr = 400;
	level.napalmplayerwarningradiussqr = level.napalmplayerwarningradiussqr * level.napalmplayerwarningradiussqr;
	napalm_fx();
}

function napalm_fx()
{
	level._effect[ "napalm_fire_forearm" ] = "dlc5/temple/fx_ztem_napalm_zombie_forearm";
	level._effect[ "napalm_fire_torso" ] = "dlc5/temple/fx_ztem_napalm_zombie_torso";
	level._effect[ "napalm_distortion" ] = "dlc5/temple/fx_ztem_napalm_zombie_heat";
	level._effect[ "napalm_fire_forearm_end" ] = "dlc5/temple/fx_ztem_napalm_zombie_forearm_end";
	level._effect[ "napalm_fire_torso_end" ] = "dlc5/temple/fx_ztem_napalm_zombie_torso_end";
	level._effect[ "napalm_steam" ] = "dlc5/temple/fx_ztem_zombie_torso_steam_runner";
	level._effect[ "napalm_feet_steam" ] = "dlc5/temple/fx_ztem_zombie_torso_steam_runner";
	level._effect[ "napalm_zombie_footstep" ] = "dlc5/temple/fx_ztem_napalm_zombie_ground2";
}

function napalm_zombie_spawn( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
	if ( newval )
	{
		level.napalm_zombie = self;
		self.is_napalm = 1;
		self thread set_footstep_override_for_napalm_zombie( 1 );
		self thread napalm_glow_normal( localclientnum );
		self thread _napalm_zombie_runeffects( localclientnum );
		self thread _napalm_zombie_runsteameffects( localclientnum );
		self thread napalm_setup_glow( localclientnum );
	}
	else
	{
		self notify( "stop_fx" );
		self notify( "napalm_killed" );
		if ( isDefined( self.steam_fx ) )
			self.steam_fx delete();
		
		level.napalm_zombie = undefined;
	}
}

function napalm_setup_glow( localclientnum )
{
	self endon( "napalm_killed" );
	while ( isDefined( self ) )
	{
		self mapShaderConstant( localclientnum, 0, "scriptVector2", 1, 0, 0 );
		wait .05;
	}
}

function _napalm_zombie_runsteameffects( client_num )
{
	self endon( "napalm_killed" );
	self endon( "death" );
	self endon( "entityshutdown" );
	while ( 1 )
	{
		waterheight = -15000;
		underwater = waterheight > self.origin[ 2 ];
		if ( underwater )
		{
			if ( !isDefined( self.steam_fx ) )
			{
				effectent = spawn( client_num, self.origin, "script_model" );
				effectent setModel( "tag_origin" );
				playFxOnTag( client_num, level._effect[ "napalm_feet_steam" ], effectent, "tag_origin" );
				self.steam_fx = effectent;
			}
			origin = ( self.origin[ 0 ], self.origin[ 1 ], waterheight );
			self.steam_fx.origin = origin;
		}
		else if ( isDefined( self.steam_fx ) )
		{
			self.steam_fx delete();
			self.steam_fx = undefined;
		}
		wait .1;
	}
}

function _napalm_zombie_runeffects( localclientnum )
{
	self.a_runfx = [];
	wait 1;
	arm1 = playFxOnTag( localclientnum, level._effect[ "napalm_fire_forearm" ], self, "j_wrist_ri" );
	array::add( self.a_runfx, arm1, 0 );
	arm2 = playFxOnTag( localclientnum, level._effect[ "napalm_fire_forearm" ], self, "j_wrist_le" );
	array::add( self.a_runfx, arm2, 0 );
	torso = playFxOnTag( localclientnum, level._effect[ "napalm_fire_torso" ], self, "j_spinelower" );
	array::add( self.a_runfx, torso, 0 );
	head = playFxOnTag( localclientnum, level._effect[ "napalm_fire_forearm" ], self, "j_head" );
	array::add( self.a_runfx, head, 0 );
	distort = playFxOnTag( localclientnum, level._effect[ "napalm_distortion" ], self, "tag_origin" );
	array::add( self.a_runfx, distort, 0 );
	self playLoopSound( "evt_napalm_zombie_loop", 2 );
	self util::waittill_any( "stop_fx", "entityshutdown" );
	if ( isDefined(self ) )
	{
		self stopAllLoopSounds( .25 );
		for ( i = 0; i < self.a_runfx.size; i++ )
			stopFx( localclientnum, self.a_runfx[ i ] );
		
		self.a_runfx = undefined;
	}
}

function napalm_zombie_explode_callback( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
	self thread napalm_glow_explode( localclientnum );
	self thread _zombie_runexplosionwindupeffects( localclientnum );
}

function napalm_pstfx_burn( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
	if ( newval )
		self thread postfx::playpostfxbundle( "pstfx_burn_loop" );
	else
		self thread postfx::exitpostfxbundle();
	
}

function _zombie_runexplosionwindupeffects(localclientnum)
{
	self.a_wind_fx = [];
	wind_arm1 = playFxOnTag( localclientnum, level._effect[ "napalm_fire_forearm_end" ], self, "j_elbow_le" );
	array::add( self.a_wind_fx, wind_arm1, 0 );
	wind_arm2 = playFxOnTag( localclientnum, level._effect[ "napalm_fire_forearm_end" ], self, "j_elbow_ri" );
	array::add( self.a_wind_fx, wind_arm2, 0 );
	wind_arm3 = playFxOnTag( localclientnum, level._effect[ "napalm_fire_forearm_end" ], self, "j_clavicle_le" );
	array::add( self.a_wind_fx, wind_arm3, 0 );
	wind_arm4 = playFxOnTag( localclientnum, level._effect[ "napalm_fire_forearm_end" ], self, "j_clavicle_ri" );
	array::add( self.a_wind_fx, wind_arm4, 0 );
	wind_torso = playFxOnTag( localclientnum, level._effect[ "napalm_fire_torso_end" ], self, "j_spinelower" );
	array::add( self.a_wind_fx, wind_torso, 0 );
	self util::waittill_any( "stop_fx", "entityshutdown" );
	if ( isDefined( self ) )
	{
		for ( i = 0; i < self.a_wind_fx.size; i++ )
			stopFx( localclientnum, self.a_wind_fx[ i ] );
		
		self.a_wind_fx = undefined;
	}
}

function _napalm_zombie_runweteffects( localclientnum )
{
	a_fx = playFxOnTag( localclientnum, level._effect[ "napalm_steam" ], self, "j_spinelower" );
	self util::waittill_any( "stop_fx", "entityshutdown" );
	if ( isDefined( self ) )
		stopFx( localclientnum, a_fx );
	
}

function set_footstep_override_for_napalm_zombie( set )
{
	if ( set )
	{
		level._footstepcbfuncs[ self.archetype ] = &napalm_footsteps;
		self.step_sound = "zmb_napalm_step";
	}
	else
	{
		level._footstepcbfuncs[ self.archetype ] = undefined;
		self.step_sound = "zmb_napalm_step";
	}
}

function napalm_footsteps( localclientnum, pos, surface, notetrack, bone )
{
	if ( IS_TRUE( self.is_napalm ) )
		playFxOnTag( localclientnum, level._effect[ "napalm_zombie_footstep" ], self, bone );
	
}

function player_napalm_radius_overlay_fade()
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "entityshutdown" );
	prevfrac = 0;
	while ( 1 )
	{
		frac = 0;
		if ( !isDefined( level.napalm_zombie ) || IS_TRUE( level.napalm_zombie.wet ) || player_can_see_napalm( level.napalm_zombie ) )
			frac = 0;
		else
		{
			dist_to_napalm = distanceSquared( self.origin, level.napalm_zombie.origin );
			if ( dist_to_napalm < level.napalmplayerwarningradiussqr )
			{
				frac = ( level.napalmplayerwarningradiussqr - dist_to_napalm ) / level.napalmplayerwarningradiussqr;
				frac = frac * 1.1;
				if ( frac > 1 )
					frac = 1;
				
			}
		}
		delta = math::clamp( frac - prevfrac, -.1, .1 );
		frac = prevfrac + delta;
		prevfrac = frac;
		setSavedDvar( "r_flameScaler", frac );
		wait .1;
	}
}

function player_can_see_napalm( ent_napalm )
{
	trace = undefined;
	if ( isDefined( level.napalm_zombie ) )
	{
		trace = bulletTrace( self getEye(), level.napalm_zombie.origin, 0, self );
		if ( isDefined( trace ) && trace[ "fraction" ] < .85 )
			return 1;
		
	}
	return 0;
}

function napalm_zombie_wet_callback( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
	if ( newval )
		self napalm_start_wet_fx( localclientnum );
	else
		self napalm_end_wet_fx( localclientnum );
	
}

function napalm_start_wet_fx( client_num )
{
	self notify( "stop_fx" );
	self thread _napalm_zombie_runweteffects( client_num );
	self.wet = 1;
	self thread napalm_glow_wet( client_num );
	self thread set_footstep_override_for_napalm_zombie( 0 );
}

function napalm_end_wet_fx( client_num )
{
	self notify( "stop_fx" );
	self thread _napalm_zombie_runeffects( client_num );
	self.wet = 0;
	self thread napalm_glow_normal( client_num );
	self thread set_footstep_override_for_napalm_zombie( 1 );
}

function napalm_set_glow( client_num, glowval )
{
	self.glow_val = glowval;
	self setShaderConstant( client_num, 0, 0, 0, 0, glowval );
}

function napalm_glow_normal( client_num )
{
	self thread napalm_glow_lerp( client_num, 2.5 );
}

function napalm_glow_explode( client_num )
{
	self thread napalm_glow_lerp( client_num, 10 );
}

function napalm_glow_wet( client_num )
{
	self thread napalm_glow_lerp( client_num, .5 );
}

function napalm_glow_lerp( client_num, glowval )
{
	self notify( "glow_lerp" );
	self endon( "glow_lerp" );
	self endon( "death" );
	self endon( "entityshutdown" );
	startval = self.glow_val;
	endval = glowval;
	if ( isDefined( startval ) )
	{
		delta = glowval - self.glow_val;
		lerptime = 1000;
		starttime = getRealTime();
		while ( ( starttime + lerptime ) > getRealTime() )
		{
			s = ( getRealTime() - starttime ) / lerptime;
			newval = startval + ( ( endval - startval ) * s );
			self napalm_set_glow( client_num, newval );
			waitRealTime .05;
		}
	}
	self napalm_set_glow( client_num, endval );
}