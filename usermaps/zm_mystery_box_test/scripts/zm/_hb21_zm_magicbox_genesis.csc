#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_magicbox;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace hb21_zm_magicbox_genesis;

#precache( "client_fx", "zombie/fx_weapon_box_closed_glow_genesis" );
#precache( "client_fx", "zombie/fx_weapon_box_open_glow_genesis" );

REGISTER_SYSTEM_EX( "hb21_zm_magicbox_genesis", &__init__, &__main__, undefined )

function __init__()
{
	clientfield::register( "zbarrier", "genesis_magicbox_open_glow", 	VERSION_SHIP, 1, "int", &genesis_magicbox_open_glow_callback, 	!CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "zbarrier", "genesis_magicbox_closed_glow", 	VERSION_SHIP, 1, "int", &genesis_magicbox_closed_glow_callback, 	!CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	
	level._effect[ "genesis_chest_light" ] 				= "zombie/fx_weapon_box_open_glow_genesis";
	level._effect[ "genesis_chest_light_closed" ] 	= "zombie/fx_weapon_box_closed_glow_genesis";
}

function __main__()
{
}

function genesis_magicbox_closed_glow_callback( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	self thread zm_magicbox::magicbox_glow_callback( n_local_client_num, n_new_val, level._effect[ "genesis_chest_light_closed" ] );
}

function genesis_magicbox_open_glow_callback( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	self thread zm_magicbox::magicbox_glow_callback( n_local_client_num, n_new_val, level._effect[ "genesis_chest_light" ] );
}


