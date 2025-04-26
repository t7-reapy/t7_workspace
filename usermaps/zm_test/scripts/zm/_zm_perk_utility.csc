#using scripts\codescripts\struct;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\duplicaterender_mgr;
#using scripts\shared\system_shared;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\shared\duplicaterender.gsh;

#namespace zm_perk_utility;

REGISTER_SYSTEM( "zm_perk_utility", &__init__, undefined )

function __init__()
{		
	luiLoad( "ui.uieditor.widgets.HUD.ZM_Perks.hb21zmperkscontainerfactory" );
}

function is_stock_map()
{
	script = toLower( getDvarString( "mapname" ) );
	switch ( script )
	{
		case "zm_factory":
		case "zm_zod":
		case "zm_castle":
		case "zm_island":
		case "zm_stalingrad":
		case "zm_genesis":
		case "zm_prototype":
		case "zm_asylum":
		case "zm_sumpf":
		case "zm_theater":
		case "zm_cosmodrome":
		case "zm_temple":
		case "zm_moon":
		case "zm_tomb":
			return 1;
		default:
			return 0;
			
	}
}

function vulture_aid_get_perk_from_model( str_model )
{
	a_perk_names = getArrayKeys( level.a_vulture_perks );
	for ( i = 0; i < a_perk_names.size; i++ )
	{
		if ( level.a_vulture_perks[ a_perk_names[ i ] ].str_model == str_model || level.a_vulture_perks[ a_perk_names[ i ] ].str_on_model == str_model )
				return a_perk_names[ i ];
		
	}
	return undefined;
}

function vulture_aid_register_perk_fx( str_perk_specialty, str_disabled_model, str_active_model, str_fx )
{
	DEFAULT( level.a_vulture_perks, [] );
	
	s_struct = spawnStruct();
	s_struct.str_model = str_disabled_model;
	s_struct.str_on_model = str_active_model;
	s_struct.str_vulture_aid_waypoint_fx_name = str_fx;
	level.a_vulture_perks[ str_perk_specialty ] = s_struct;
}