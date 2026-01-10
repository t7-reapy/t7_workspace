#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_magicbox;
#using scripts\zm\_hb21_zm_magicbox_chaos;
#using scripts\zm\_hb21_zm_magicbox_botd;
#using scripts\zm\_hb21_zm_magicbox_tomb;
#using scripts\zm\_hb21_zm_magicbox_soe;
#using scripts\zm\_hb21_zm_magicbox_genesis;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace hb21_zm_magicbox;

REGISTER_SYSTEM_EX( "hb21_zm_magicbox", &__init__, &__main__, undefined )

function __init__()
{
	clientfield::register( "zbarrier", "default_zbarrier_show_sounds", 	VERSION_SHIP, 1, "counter", &magicbox_show_sounds_callback, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "zbarrier", "default_zbarrier_leave_sounds", 	VERSION_SHIP, 1, "counter", &magicbox_leave_sounds_callback, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
}

function __main__()
{
}

function magicbox_show_sounds_callback( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	playSound( n_local_client_num, "zmb_box_poof_land2", self.origin );
	playSound( n_local_client_num, "zmb_couch_slam2", self.origin );
	playSound( n_local_client_num, "zmb_box_poof2", self.origin );
}

function magicbox_leave_sounds_callback( n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
	playSound( n_local_client_num, "zmb_box_move2", self.origin );
	playSound( n_local_client_num, "zmb_whoosh2", self.origin );
}