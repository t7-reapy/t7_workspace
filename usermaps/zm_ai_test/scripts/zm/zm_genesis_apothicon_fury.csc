#using scripts\codescripts\struct;
#using scripts\shared\ai\archetype_apothicon_fury;
#using scripts\shared\ai_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\zm_genesis_apothicon_fury.gsh;

#precache( "client_fx", APOTHICON_FURY_SPAWN_IN_FX );
#precache( "client_fx", APOTHICON_FURY_SPAWN_IN_EXP_FX );

#namespace zm_genesis_apothicon_fury;

REGISTER_SYSTEM_EX( "zm_genesis_apothicon_fury", &__init__, &__main__, undefined )

// ============================== INITIALIZE ==============================

function __init__()
{
    if ( ai::shouldRegisterClientFieldForArchetype( "apothicon_fury" ) )
        clientfield::register( "scriptmover", "apothicon_fury_spawn_meteor", VERSION_SHIP, 2, "int", &apothicon_fury_spawn_meteor, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
    
}

function __main__()
{
    level._effect[ "apothicon_fury_meteor_fx" ] = APOTHICON_FURY_SPAWN_IN_FX;
    level._effect[ "apothicon_fury_meteor_exp" ] = APOTHICON_FURY_SPAWN_IN_EXP_FX;
    level thread apothicon_fury_start_monitor();
    level thread apothicon_fury_stop_monitor();
}

// ============================== INITIALIZE ==============================

// ============================== EVENT OVERRIDES ==============================

// ============================== EVENT OVERRIDES ==============================

// ============================== FUNCTIONALITY ==============================

function apothicon_fury_spawn_meteor( n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump )
{
    if ( n_new_value === 0 )
    {
        if ( isDefined( self.fx_apothicon_fury_meteor ) )
            stopFx( n_local_client_num, self.fx_apothicon_fury_meteor );
        
    }
    else if ( n_new_value === 1 )
        self.fx_apothicon_fury_meteor = playFXOnTag( n_local_client_num, level._effect[ "apothicon_fury_meteor_fx" ], self, "tag_origin" );
    else if ( n_new_value == 2 )
    {
        playFXOnTag( n_local_client_num, level._effect[ "apothicon_fury_meteor_exp" ], self, "tag_origin" );
        self earthquake( .1, 1, self.origin, 100 );
        self playRumbleOnEntity( n_local_client_num, "damage_heavy" );
    }
}

function apothicon_fury_ramp_fog_in_out()
{
    for ( n_local_client_num = 0; n_local_client_num < level.localPlayers.size; n_local_client_num++ )
    {
        setLitFogBank( n_local_client_num, -1, 1, -1 );
        setWorldFogActiveBank( n_local_client_num, 2 );
    }
    wait 2.5;
    for ( n_local_client_num = 0; n_local_client_num < level.localPlayers.size; n_local_client_num++ )
    {
        setLitFogBank( n_local_client_num, -1, 0, -1 );
        setWorldFogActiveBank( n_local_client_num, 1 );
    }
}

function apothicon_fury_start_monitor()
{
    while ( 1 )
    {
        level waittill( "apothicon_fury_start" );
        level thread apothicon_fury_ramp_fog_in_out();
    }
}

function apothicon_fury_stop_monitor()
{
    while ( 1 )
    {
        level waittill( "apothicon_fury_stop" );
        level thread apothicon_fury_ramp_fog_in_out();
    }
}

// ============================== FUNCTIONALITY ==============================