#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace zm_weap_shrink_ray;

REGISTER_SYSTEM_EX( "zm_weap_shrink_ray", &__init__, &__main__, undefined )

function __init__()
{
	clientfield::register( "actor", "fun_size", VERSION_SHIP, 1, "int", &fun_size, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
}

function __main__()
{
}

function fun_size( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump )
{
	self suppressRagdollSelfCollision( n_new_value );
	self.b_shrunken = n_new_value;
}
