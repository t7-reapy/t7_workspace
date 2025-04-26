#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_perk_utility;
#using scripts\zm\_zm_powerup_ww_grenade;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_perk_widows_wine.gsh;

#precache( "client_fx", WIDOWS_WINE_MACHINE_LIGHT_FX );
#precache( "client_fx", WIDOWS_WINE_VULTUREAID_WAYPOINT );
#precache( "client_fx", WIDOWS_WINE_FX_FILE_WRAP );
#precache( "client_fx", WIDOWS_WINE_1P_EXPLOSION );

#namespace zm_perk_widows_wine;

REGISTER_SYSTEM_EX( "zm_perk_widows_wine", &__init__, &__main__, undefined )

//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------
function __init__()
{
	script = toLower( getDvarString( "mapname" ) );
	if ( script == "zm_factory" )
		return;
		
	if ( IS_TRUE( WIDOWS_WINE_LEVEL_USE_PERK ) )
		enable_widows_wine_perk_for_level();
	
}

function __main__()
{
	script = toLower( getDvarString( "mapname" ) );
	if ( script == "zm_factory" )
		return;
		
	if ( IS_TRUE( WIDOWS_WINE_LEVEL_USE_PERK ) )
		widows_wine_main();
	
}

function enable_widows_wine_perk_for_level()
{
	zm_perks::register_perk_clientfields( WIDOWS_WINE_PERK, &widows_wine_client_field_func, &widows_wine_code_callback_func );
	zm_perks::register_perk_effects( WIDOWS_WINE_PERK, WIDOWS_WINE_PERK );
	zm_perks::register_perk_init_thread( WIDOWS_WINE_PERK, &init_widows_wine );
	zm_perk_utility::vulture_aid_register_perk_fx( WIDOWS_WINE_PERK, WIDOWS_WINE_MACHINE_DISABLED_MODEL, WIDOWS_WINE_MACHINE_ACTIVE_MODEL, WIDOWS_WINE_VULTUREAID_WAYPOINT );
}

function init_widows_wine()
{
	level._effect[ WIDOWS_WINE_PERK ] = WIDOWS_WINE_MACHINE_LIGHT_FX;
}

function widows_wine_client_field_func()
{
	clientfield::register( "clientuimodel", WIDOWS_WINE_CLIENTFIELD, VERSION_SHIP, 2, "int", undefined, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "actor", CF_WIDOWS_WINE_WRAP, VERSION_SHIP, 1, "int", &widows_wine_wrap_cb, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "vehicle", CF_WIDOWS_WINE_WRAP, VERSION_SHIP, 1, "int", &widows_wine_wrap_cb, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );	
	clientfield::register( "toplayer", "widows_wine_1p_contact_explosion", VERSION_SHIP, 1, "counter", &widows_wine_1p_contact_explosion, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
}

function widows_wine_code_callback_func() {}

//-----------------------------------------------------------------------------------
// FUNCTIONALITY
//-----------------------------------------------------------------------------------
function widows_wine_main()
{
	level._effect[ WIDOWS_WINE_FX_WRAP ] = WIDOWS_WINE_FX_FILE_WRAP;
}

function widows_wine_wrap_cb( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump )
{
	if( newVal )
	{
		if ( isDefined( self ) && isAlive( self ) )
		{
			if ( !isDefined( self.fx_widows_wine_wrap ) )
				self.fx_widows_wine_wrap = playFxOnTag( localClientNum, level._effect[WIDOWS_WINE_FX_WRAP], self, "j_spineupper" );
			
			if ( !isDefined( self.sndWidowsWine ) )
			{
				self playsound( 0, "wpn_wwgrenade_cocoon_imp" );
				self.sndWidowsWine = self playloopsound( "wpn_wwgrenade_cocoon_lp", .1 );
			}
		}
	}
	else
	{
		if ( isDefined( self.fx_widows_wine_wrap ) )
		{
			stopFX( localClientNum, self.fx_widows_wine_wrap );
			self.fx_widows_wine_wrap = undefined;
		}
		if( isDefined( self.sndWidowsWine ) )
		{
			self playSound( 0, "wpn_wwgrenade_cocoon_stop" );
			self stopLoopSound( self.sndWidowsWine, .1 );
		}
	}
}

function widows_wine_1p_contact_explosion( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump )
{
	owner = self getOwner( localClientNum );
	if ( isDefined( owner ) && owner == getLocalPlayer( localClientNum ) )
		thread widows_wine_1p_contact_explosion_play( localClientNum );
	
}

function widows_wine_1p_contact_explosion_play( localClientNum )
{
	tag = "tag_flash";

	if ( !viewmodelHasTag( localClientNum, tag ) )
	{
		tag = "tag_weapon";
		if ( !viewmodelHasTag( localClientNum, tag ) )
			return;
		
	}

	fx_contact_explosion = playViewmodelFx( localClientNum, WIDOWS_WINE_1P_EXPLOSION, tag );
	wait 2;
	deleteFx( localClientNum, fx_contact_explosion, 1 );
}

