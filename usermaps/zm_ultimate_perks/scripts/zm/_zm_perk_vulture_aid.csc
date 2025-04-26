#using scripts\codescripts\struct;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\filter_shared;
#using scripts\shared\util_shared;
#using scripts\shared\system_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\shared\duplicaterender_mgr;
#using scripts\shared\duplicaterenderbundle;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_perk_utility;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\shared\duplicaterender.gsh;
#insert scripts\zm\_zm_perk_vulture_aid.gsh;

#precache( "client_fx", VULTUREAID_MACHINE_LIGHT_FX );
#precache( "client_fx", VULTUREAID_GREEN_POWERUP_GLOW );
#precache( "client_fx", VULTUREAID_BLUE_POWERUP_GLOW );
#precache( "client_fx", VULTUREAID_RED_POWERUP_GLOW );
#precache( "client_fx", VULTUREAID_YELLOW_POWERUP_GLOW );
#precache( "client_fx", VULTUREAID_GREEN_MIST_FX );
#precache( "client_fx", VULTUREAID_VULTUREAID_WAYPOINT );
#precache( "client_fx", VULTUREAID_WONDERFIZZ_WAYPOINT );
#precache( "client_fx", VULTUREAID_PAP_WAYPOINT );
#precache( "client_fx", VULTUREAID_RIFLE_WAYPOINT );
#precache( "client_fx", VULTUREAID_SKULL_WAYPOINT );
#precache( "client_fx", VULTUREAID_MAGIC_BOX_WAYPOINT );
#precache( "client_fx", VULTUREAID_BGB_WAYPOINT );

#namespace zm_perk_vulture_aid;

REGISTER_SYSTEM_EX( "zm_perk_vulture_aid", &__init__, &__main__, undefined )

//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------
function __init__()
{
	script = toLower( getDvarString( "mapname" ) );
	if ( script == "zm_castle" )
		return;
		
	if ( IS_TRUE( VULTUREAID_LEVEL_USE_PERK ) )
		enable_vulture_aid_perk_for_level();
	
}

function __main__()
{
	script = toLower( getDvarString( "mapname" ) );
	if ( script == "zm_castle" )
		return;
		
	if ( IS_TRUE( VULTUREAID_LEVEL_USE_PERK ) )
		vulture_aid_main();
	
}

function enable_vulture_aid_perk_for_level()
{
	zm_perks::register_perk_clientfields( VULTUREAID_PERK, &vulture_aid_client_field_func, &vulture_aid_callback_func );
	zm_perks::register_perk_effects( VULTUREAID_PERK, VULTUREAID_PERK );
	zm_perks::register_perk_init_thread( VULTUREAID_PERK, &vulture_aid_init );
	zm_perk_utility::vulture_aid_register_perk_fx( VULTUREAID_PERK, VULTUREAID_MACHINE_DISABLED_MODEL, VULTUREAID_MACHINE_ACTIVE_MODEL, VULTUREAID_VULTUREAID_WAYPOINT );
	zm_perk_utility::vulture_aid_register_perk_fx( "wallbuy", "wallbuy", "wallbuy", VULTUREAID_SKULL_WAYPOINT );
	zm_perk_utility::vulture_aid_register_perk_fx( "mysterybox", "mysterybox", "mysterybox", VULTUREAID_MAGIC_BOX_WAYPOINT );
	zm_perk_utility::vulture_aid_register_perk_fx( "wonderfizz", "wonderfizz", "wonderfizz", VULTUREAID_WONDERFIZZ_WAYPOINT );
	zm_perk_utility::vulture_aid_register_perk_fx( "packapunch", "packapunch", "packapunch", VULTUREAID_PAP_WAYPOINT );
	zm_perk_utility::vulture_aid_register_perk_fx( "gobblegum", "gobblegum", "gobblegum", VULTUREAID_BGB_WAYPOINT );
}

function vulture_aid_init()
{
	level._effect[ VULTUREAID_PERK ] = VULTUREAID_MACHINE_LIGHT_FX;
}

function vulture_aid_client_field_func() 
{
	clientfield::register( "clientuimodel", VULTUREAID_CLIENTFIELD, VERSION_SHIP, 2, "int", undefined, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "clientuimodel", VULTUREAID_DISEASE_METER_CF, VERSION_SHIP, 5, "float", undefined, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "scriptmover", VULTUREAID_REGISTER_PERK_CF, VERSION_SHIP, 1, "int", &vulture_aid_register_perk, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "scriptmover", VULTUREAID_KEYLINE_WAYPOINTS_CF, VERSION_SHIP, 1, "int", &vulture_aid_keyline_watcher, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "scriptmover", VULTUREAID_REGISTER_POWERUP_CF, VERSION_SHIP, getMinBitCountForNum( 4 ), "int", &vulture_aid_register_powerup, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "scriptmover", VULTUREAID_REGISTER_STINK_CF, VERSION_SHIP, 1, "int", &vulture_aid_register_stink, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "zbarrier", VULTUREAID_REGISTER_BOX_CF, VERSION_SHIP, 2, "int", &vulture_aid_register_mystery_box, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "zbarrier", VULTUREAID_REGISTER_FIZZ_CF, VERSION_SHIP, 2, "int", &vulture_aid_register_wonderfizz, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "zbarrier", VULTUREAID_REGISTER_PAP_CF, VERSION_SHIP, 2, "int", &vulture_aid_register_pap, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "zbarrier", VULTUREAID_REGISTER_BGB_CF, VERSION_SHIP, 1, "int", &vulture_aid_register_gobble_gum, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "toplayer", VULTUREAID_PERK_UPDATE_CF, VERSION_SHIP, 1, "counter", &vulture_aid_update_waypoints, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "toplayer", VULTUREAID_STINK_CF, VERSION_SHIP, 1, "int", &vulture_aid_stink, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "toplayer", VULTUREAID_PERK_TOPLAYER_CF, VERSION_SHIP, 1, "int", &vulture_callback_toplayer, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
}

function vulture_aid_callback_func() {}

//-----------------------------------------------------------------------------------
// FUNCTIONALITY
//-----------------------------------------------------------------------------------
function vulture_aid_main()
{	
	level.a_vulture_aid_waypoints = struct::get_array( "weapon_upgrade", "targetname" );
	level.a_vulture_aid_waypoints = arrayCombine( level.a_vulture_aid_waypoints, struct::get_array( "bowie_upgrade", 		"targetname" ), true, false );
	level.a_vulture_aid_waypoints = arrayCombine( level.a_vulture_aid_waypoints, struct::get_array( "sickle_upgrade", 		"targetname" ), true, false );
	level.a_vulture_aid_waypoints = arrayCombine( level.a_vulture_aid_waypoints, struct::get_array( "tazer_upgrade", 		"targetname" ), true, false );
	level.a_vulture_aid_waypoints = arrayCombine( level.a_vulture_aid_waypoints, struct::get_array( "buildable_wallbuy", 	"targetname" ), true, false );
	level.a_vulture_aid_waypoints = arrayCombine( level.a_vulture_aid_waypoints, struct::get_array( "claymore_purchase", 	"targetname" ), true, false );
	
	for ( i = 0; i < level.a_vulture_aid_waypoints.size; i++ )
		level.a_vulture_aid_waypoints[ i ].str_perk_specialty = "wallbuy";
	
	duplicate_render::set_dr_filter_offscreen( "vulture_keyline", 25, "vulture_keyline_active", undefined, DR_TYPE_OFFSCREEN, "mc/hud_keyline_vulture_aid", DR_CULL_NEVER );
	callback::on_localplayer_spawned( &on_localplayer_spawned );
}

function on_localplayer_spawned( n_client_num )
{
	if ( !IS_TRUE( VULTUREAID_USE_KEYLINE_ON_WAYPOINT_OBJECTS ) && !IS_TRUE( VULTUREAID_USE_KEYLINE_ON_WAYPOINT_CRAFT_ITEMS ) && !IS_TRUE( VULTUREAID_USE_KEYLINE_ON_DROP_PACKETS ) )
		return;
	
	self thread keyline_modifications( n_client_num );
}

function private keyline_modifications( n_client_num )
{
	self endon( "entityshutdown" );
	self endon( "disconnect" );
	self endon( "death" );
	self endon( "bled_out" );
	self notify( "keyline_modifications" );
	self endon( "keyline_modifications" );

	while ( isDefined( self ) && isAlive( self ) )
	{
		self oED_SitRepScan_Enable( 3 );
		
		if ( isSplitScreen() && !self hasPerk( n_client_num, "specialty_vultureaid" ) )
			self oED_SitRepScan_Enable( 0 );
		else
			self oED_SitRepScan_Enable( 3 );
		
		self oED_SitRepScan_SetOutline( 1 );
		self oED_SitRepScan_SetSolid( 1 );
		self oED_SitRepScan_SetLineWidth( 2 );
		self oED_SitRepScan_SetRadius( 2800 );
		self oED_SitRepScan_SetFalloff( 0.01 );
		self oED_SitRepScan_SetDesat( 1 );
		
		WAIT_CLIENT_FRAME;
	}
}

function vulture_aid_change_active( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	self.b_zbarrier = 1;
	self.b_active = n_new_val;
	self vulture_aid_waypoint_active_callback( n_local_client_num );
}

function vulture_aid_active( n_local_client_num )
{
	for ( i = 0; i < level.a_vulture_aid_waypoints.size; i++ )
		level.a_vulture_aid_waypoints[ i ] vulture_aid_waypoint_active_callback( n_local_client_num );
	
	b_turn_on = getLocalPlayers()[ n_local_client_num ] hasPerk( n_local_client_num, VULTUREAID_PERK );
	level notify( "vulture_aid_active_" + b_turn_on );
}

function vulture_aid_not_valid_perk( str_specialty )
{
	if ( str_specialty == "wallbuy" || str_specialty == "mysterybox" || str_specialty == "wonderfizz" || str_specialty == "packapunch" || str_specialty == "gobblegum" )
		return 1;
	else
		return 0;
	
}

function vulture_aid_waypoint_active_callback( n_local_client_num )
{
	DEFAULT( self.fx_vulture_aid_waypoint, [] );
	b_turn_on = getLocalPlayers()[ n_local_client_num ] hasPerk( n_local_client_num, VULTUREAID_PERK );
	
	b_fx_on_tag = IS_TRUE( self.b_use_tag );
	
	if ( IS_TRUE( b_turn_on ) )
	{
		if ( isDefined( self.b_active ) )
			b_turn_on = self.b_active;
		else if ( isDefined( self.str_perk_specialty ) && !vulture_aid_not_valid_perk( self.str_perk_specialty ) && getLocalPlayers()[ n_local_client_num ] hasPerk( n_local_client_num, self.str_perk_specialty ) && IS_TRUE( VULTUREAID_HIDE_OWNED_WAYPOINTS ) )
			b_turn_on = 0;
		
	}
	str_fx_name = level.a_vulture_perks[ self.str_perk_specialty ].str_vulture_aid_waypoint_fx_name;
	n_fx_offset = ( ( isDefined( self.n_fx_z_offset ) ) ? self.n_fx_z_offset : 0 );
	
	if ( IS_TRUE( b_turn_on ) )
	{
		if ( !isDefined( self.fx_vulture_aid_waypoint[ n_local_client_num ] ) )
		{
			if ( IS_TRUE( b_fx_on_tag ) )
			{
				if ( IS_TRUE( VULTUREAID_USE_KEYLINE_ON_WAYPOINT_OBJECTS ) )
					self duplicate_render::update_dr_flag( n_local_client_num, "vulture_keyline_active", 1 );
				
				self.fx_vulture_aid_waypoint[ n_local_client_num ] = playFXOnTag( n_local_client_num, str_fx_name, self, "tag_origin" );
			}
			else
			{
				if ( isDefined( self.b_zbarrier ) && IS_TRUE( VULTUREAID_USE_KEYLINE_ON_WAYPOINT_OBJECTS ) )
				{
					for ( i = 0; i < self getNumZBarrierPieces(); i++ )
					{
						e_model = self ZBarrierGetPiece( i );
						e_model duplicate_render::update_dr_flag( n_local_client_num, "vulture_keyline_active", 1 );
					}
				}
				self.fx_vulture_aid_waypoint[ n_local_client_num ] = playFx( n_local_client_num, str_fx_name, self.origin + ( 0, 0, n_fx_offset ) );
			}
		}
	}
	else
	{
		if ( isDefined( self.fx_vulture_aid_waypoint[ n_local_client_num ] ) )
		{
			if ( IS_TRUE( b_fx_on_tag ) && IS_TRUE( VULTUREAID_USE_KEYLINE_ON_WAYPOINT_OBJECTS ) )
			{
				self duplicate_render::update_dr_flag( n_local_client_num, "vulture_keyline_active", 0 );
			}
			else if ( isDefined( self.b_zbarrier ) && IS_TRUE( VULTUREAID_USE_KEYLINE_ON_WAYPOINT_OBJECTS ) )
			{
				for ( i = 0; i < self getNumZBarrierPieces(); i++ )
				{
					e_model = self ZBarrierGetPiece( i );
					e_model duplicate_render::update_dr_flag( n_local_client_num, "vulture_keyline_active", 0 );
				}
			}
			DeleteFX( n_local_client_num, self.fx_vulture_aid_waypoint[ n_local_client_num ], 1 );
			self.fx_vulture_aid_waypoint[ n_local_client_num ] = undefined;
		}
	}
}

function vulture_aid_stink( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	if ( n_new_val == 1 )
		self thread vulture_aid_activate_stink( n_local_client_num );
	else
		self thread vulture_aid_deactivate_stink( n_local_client_num );
	
}

function vulture_aid_activate_stink( n_local_client_num )
{
	if ( !isDefined( self.sndstinkent ) )
	{
		self.sndstinkent = util::spawn_model( n_local_client_num, "tag_origin", self.origin, self.angles );
		self.sndstinkent playLoopSound( "zmb_perks_vulture_stink_loop", .5 );
	}
	playSound( n_local_client_num, "zmb_perks_vulture_stink_start" );
}

function vulture_aid_deactivate_stink( n_local_client_num )
{
	playSound( n_local_client_num, "zmb_perks_vulture_stink_stop" );
	if ( isDefined( self.sndstinkent ) )
	{
		self.sndstinkent stopLoopSound( n_local_client_num, .5 );
		self.sndstinkent delete();
		self.sndstinkent = undefined;
	}
}

function vulture_callback_toplayer( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{	
	vulture_aid_active( n_local_client_num );
	
	if ( n_new_val )
		getLocalPlayers()[ n_local_client_num ] notify( "vulture_aid_active_1" );
	else
		getLocalPlayers()[ n_local_client_num ] notify( "vulture_aid_active_0" );
}

function vulture_perk_disease_meter( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	ui_model = createUIModel( getUIModelForController( n_local_client_num ), VULTUREAID_DISEASE_METER_CF );
	setUIModelValue( ui_model, n_new_val );
}

function vulture_aid_register_stink( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	self vulture_aid_stink_callback( n_local_client_num, getLocalPlayers()[ n_local_client_num ] hasPerk( n_local_client_num, VULTUREAID_PERK ) );
	self thread vulture_aid_stink_watcher( n_local_client_num );
}

function vulture_aid_stink_watcher( n_local_client_num )
{
	self endon( "entityshutdown" );
	self endon( "death" );
	while ( isDefined( self ) )
	{
		str_notify_recieved = getLocalPlayers()[ n_local_client_num ] util::waittill_any_return( "vulture_aid_active_0", "vulture_aid_active_1" );
		b_val = ( ( isDefined( str_notify_recieved ) && str_notify_recieved == "vulture_aid_active_1" ) ? 1 : 0 );
		
		if ( !isDefined( self ) )
			break;
		
		self vulture_aid_stink_callback( n_local_client_num, b_val );
	}
}

function vulture_aid_stink_callback( n_local_client_num, b_turn_on )
{
	if ( IS_TRUE( b_turn_on ) && isDefined( self ) )
	{
		if ( !isDefined( self.fx_vulture_aid_stink ) )
			self.fx_vulture_aid_stink = playFXOnTag( n_local_client_num, VULTUREAID_GREEN_MIST_FX, self, "tag_origin" );
		
	}
	else
	{
		if ( isDefined( self.fx_vulture_aid_stink ) )
		{
			stopFx( n_local_client_num, self.fx_vulture_aid_stink );
			self.fx_vulture_aid_stink = undefined;
		}
	}
}

function vulture_aid_register_powerup( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	if ( n_new_val == 2 )
		self.str_vulture_aid_waypoint_fx_name = VULTUREAID_BLUE_POWERUP_GLOW;
	else if ( n_new_val == 3 )
		self.str_vulture_aid_waypoint_fx_name = VULTUREAID_RED_POWERUP_GLOW;
	else if ( n_new_val == 4 )
		self.str_vulture_aid_waypoint_fx_name = VULTUREAID_YELLOW_POWERUP_GLOW;
	else
		self.str_vulture_aid_waypoint_fx_name = VULTUREAID_GREEN_POWERUP_GLOW;
	
	self vutlure_aid_powerup_fx_callback( n_local_client_num, getLocalPlayers()[ n_local_client_num ] hasPerk( n_local_client_num, VULTUREAID_PERK ) );
	self thread vulture_aid_powerup_watcher( n_local_client_num );
}

function vulture_aid_powerup_watcher( n_local_client_num )
{
	self endon( "entityshutdown" );
	self endon( "death" );
	while ( isDefined( self ) )
	{
		str_notify_recieved = getLocalPlayers()[ n_local_client_num ] util::waittill_any_return( "vulture_aid_active_0", "vulture_aid_active_1" );
		b_val = ( ( isDefined( str_notify_recieved ) && str_notify_recieved == "vulture_aid_active_1" ) ? 1 : 0 );
		
		if ( !isDefined( self ) )
			break;
		
		self vutlure_aid_powerup_fx_callback( n_local_client_num, b_val );
	}
}

function vutlure_aid_powerup_fx_callback( n_local_client_num, b_turn_on )
{
	DEFAULT( self.fx_vulture_aid_powerup, [] );
	if ( IS_TRUE( b_turn_on ) && isDefined( self ) )
	{
		if ( !isDefined( self.fx_vulture_aid_powerup[ n_local_client_num ] ) )
		{
			self.fx_vulture_aid_powerup[ n_local_client_num ] = playFXOnTag( n_local_client_num, self.str_vulture_aid_waypoint_fx_name, self, "tag_origin" );
			self duplicate_render::update_dr_flag( n_local_client_num, "vulture_keyline_active", 1 );
		}
	}
	else
	{
		if ( isDefined( self.fx_vulture_aid_powerup[ n_local_client_num ] ) )
		{
			stopFx( n_local_client_num, self.fx_vulture_aid_powerup[ n_local_client_num ] );
			self.fx_vulture_aid_powerup[ n_local_client_num ] = undefined;
			self duplicate_render::update_dr_flag( n_local_client_num, "vulture_keyline_active", 0 );
		}
	}
}

function vulture_aid_keyline_watcher( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	if ( IS_TRUE( n_new_val ) )
		self thread vulture_aid_keyline_watcher_cb( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump );
	else
	{
		self notify( "vulture_aid_keyline_watcher_cb" );
		self duplicate_render::update_dr_flag( n_local_client_num, "vulture_keyline_active", 0 );
	}
}

function vulture_aid_keyline_watcher_cb( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	self endon( "entityshutdown" );
	self endon( "death" );
	self notify( "vulture_aid_keyline_watcher_cb" );
	self endon( "vulture_aid_keyline_watcher_cb" );
	
	if ( !IS_TRUE( VULTUREAID_USE_KEYLINE_ON_WAYPOINT_OBJECTS ) )
		return;
	
	e_player = getLocalPlayers()[ n_local_client_num ];
	while ( isDefined( self ) )
	{
		while ( isDefined( self ) && !e_player hasPerk( n_local_client_num, VULTUREAID_PERK ) && isAlive( e_player ) )
			WAIT_CLIENT_FRAME;
		
		if ( !isDefined( self ) )
			break;
		
		self duplicate_render::update_dr_flag( n_local_client_num, "vulture_keyline_active", 1 );
		
		while ( isDefined( self ) && e_player hasPerk( n_local_client_num, VULTUREAID_PERK ) && isAlive( e_player ) )
			WAIT_CLIENT_FRAME;
		
		if ( !isDefined( self ) )
			break;
		
		self duplicate_render::update_dr_flag( n_local_client_num, "vulture_keyline_active", 0 );
	}
}

function vulture_aid_keyline_watcher_zbarrier( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	if ( IS_TRUE( n_new_val ) )
		self thread vulture_aid_keyline_watcher_zbarrier_cb( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump );
	else
	{
		self notify( "vulture_aid_keyline_watcher_zbarrier_cb" );
		for ( i = 0; i < self getNumZBarrierPieces(); i++ )
		{
			e_model = self zBarrierGetPiece( i );
			e_model duplicate_render::update_dr_flag( n_local_client_num, "vulture_keyline_active", 0 );
		}
	}
}

function vulture_aid_keyline_watcher_zbarrier_cb( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	self endon( "entityshutdown" );
	self endon( "death" );
	self notify( "vulture_aid_keyline_watcher_zbarrier_cb" );
	self endon( "vulture_aid_keyline_watcher_zbarrier_cb" );
	
	if ( !IS_TRUE( VULTUREAID_USE_KEYLINE_ON_WAYPOINT_OBJECTS ) )
		return;
	
	e_player = getLocalPlayers()[ n_local_client_num ];
	while ( isDefined( self ) )
	{
		while ( isDefined( self ) && !e_player hasPerk( n_local_client_num, VULTUREAID_PERK ) && isAlive( e_player ) )
			WAIT_CLIENT_FRAME;
		
		if ( !isDefined( self ) )
			break;
		
		for ( i = 0; i < self getNumZBarrierPieces(); i++ )
		{
			e_model = self zBarrierGetPiece( i );
			e_model duplicate_render::update_dr_flag( n_local_client_num, "vulture_keyline_active", 1 );
		}
		
		while ( isAlive( e_player ) && e_player hasPerk( n_local_client_num, VULTUREAID_PERK ) )
			WAIT_CLIENT_FRAME;
		
		if ( !isDefined( self ) )
			break;
		
		for ( i = 0; i < self getNumZBarrierPieces(); i++ )
		{
			e_model = self zBarrierGetPiece( i );
			e_model duplicate_render::update_dr_flag( n_local_client_num, "vulture_keyline_active", 0 );
		}
	}
}

function vulture_aid_register_perk( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	str_perk_specialty = zm_perk_utility::vulture_aid_get_perk_from_model( self.model );
	if ( !isDefined( str_perk_specialty ) )
		return;
	
	DEFAULT( self.fx_vulture_aid_waypoint, [] );
	self.b_use_tag = 1;
	self.str_perk_specialty = str_perk_specialty;
	ARRAY_ADD( level.a_vulture_aid_waypoints, self );
}

function vulture_aid_register_gobble_gum( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	DEFAULT( self.fx_vulture_aid_waypoint, [] );
	self.b_zbarrier = 1;
	self.str_perk_specialty = "gobblegum";
	self.n_fx_z_offset = 50;
	ARRAY_ADD( level.a_vulture_aid_waypoints, self );
}

function vulture_aid_register_wonderfizz( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	DEFAULT( self.fx_vulture_aid_waypoint, [] );
	self.b_zbarrier = 1;
	self.str_perk_specialty = "wonderfizz";
	self.b_active = n_new_val == 2;
	self.n_fx_z_offset = 50;
	ARRAY_ADD( level.a_vulture_aid_waypoints, self );
}

function vulture_aid_register_pap( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	DEFAULT( self.fx_vulture_aid_waypoint, [] );
	self.b_zbarrier = 1;
	self.str_perk_specialty = "packapunch";
	self.b_active = n_new_val == 2;
	self.n_fx_z_offset = 50;
	ARRAY_ADD( level.a_vulture_aid_waypoints, self );
}

function vulture_aid_register_mystery_box( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	DEFAULT( self.fx_vulture_aid_waypoint, [] );
	self.b_zbarrier = 1;
	self.str_perk_specialty = "mysterybox";
	self.b_active = n_new_val == 2;
	self.n_fx_z_offset = 50;
	ARRAY_ADD( level.a_vulture_aid_waypoints, self );
}

function vulture_aid_update_waypoints( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	self vulture_aid_active( n_local_client_num );
}