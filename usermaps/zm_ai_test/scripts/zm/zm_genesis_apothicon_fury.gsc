#using scripts\codescripts\struct;
#using scripts\shared\ai_shared;
#using scripts\shared\aat_shared;
#using scripts\shared\ai\archetype_apothicon_fury;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_zonemgr;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\zm_genesis_apothicon_fury.gsh;

#precache( "fx", APOTHICON_FURY_GROUND_TELL_FX );

#namespace zm_genesis_apothicon_fury;

REGISTER_SYSTEM_EX( "zm_genesis_apothicon_fury", &__init__, &__main__, undefined )

// ============================== INITIALIZE ==============================

function __init__()
{    
    // SETUP
    spawner::add_archetype_spawn_function( "apothicon_fury", &apothicon_fury_init );
    spawner::add_archetype_spawn_function( "apothicon_fury", &apothicon_fury_damage_event );
    spawner::add_archetype_spawn_function( "apothicon_fury", &apothicon_fury_death_event );
    // SETUP
    
    // # CLIENTFIELD REGISTRATION
    if ( ai::shouldRegisterClientFieldForArchetype( "apothicon_fury" ) )
        clientfield::register( "scriptmover", "apothicon_fury_spawn_meteor", VERSION_SHIP, 2, "int" );
    // # CLIENTFIELD REGISTRATION
    
    // # FLAG REGISTRATION
    level flag::init( "apothicon_fury_clips" );
    level flag::init( "apothicon_fury_round" );
    // # FLAG REGISTRATION
}

function __main__()
{
    // # REGISTER FX
    level._effect[ "fury_ground_tell_fx" ] = APOTHICON_FURY_GROUND_TELL_FX;
    // # REGISTER FX
    
    // SETUP
    apothicon_fury_register_aat_immunity();
    setDvar( "tu13_ai_useModifiedPushActors", 1 );
    // SETUP
    
    if ( !IS_TRUE( APOTHICAN_FURY_USE_SPECIAL_FURY_ROUNDS ) )
        return;
    
    enable_apothicon_fury_rounds();
    zm_audio::musicState_Create( "dog_start", 3, "dogstart1"  );
    zm_audio::musicState_Create( "dog_end", 3, "dogend1"  );
}

// ============================== INITIALIZE ==============================

// ============================== EVENT OVERRIDES ==============================

// ============================== EVENT OVERRIDES ==============================

// ============================== FUNCTIONALITY ==============================

function apothicon_fury_init()
{
    self AAT::aat_cooldown_init();
}

function apothicon_fury_register_aat_immunity()
{
    level thread aat::register_immunity( "zm_aat_turned", "apothicon_fury", 1, 1, 1 );
    level thread aat::register_immunity( "zm_aat_thunder_wall", "apothicon_fury", 1, 1, 1 );
}

function apothicon_fury_spawn( v_origin, v_angles = ( 0, 0, 0 ), b_find_flesh = 0 )
{
    e_ai_apothicon_fury = spawnActor( "spawner_zm_genesis_apothicon_fury", v_origin, v_angles, undefined, 1, 1 );
    if ( isDefined( e_ai_apothicon_fury ) )
    {
        e_ai_apothicon_fury endon( "death" );
        e_ai_apothicon_fury.spawn_time = getTime();
        e_ai_apothicon_fury.b_is_apothicon_fury = 1;
        e_ai_apothicon_fury.heroweapon_kill_power = 2;
        e_ai_apothicon_fury.completed_emerging_into_playable_area = 1;
        level thread zm_spawner::zombie_death_event( e_ai_apothicon_fury );
        e_ai_apothicon_fury thread zm_spawner::enemy_death_detection();
        e_ai_apothicon_fury thread apothicon_fury_health_init();
        e_ai_apothicon_fury.voicePrefix = "fury";
        e_ai_apothicon_fury.animName = "fury";
        e_ai_apothicon_fury thread zm_spawner::play_ambient_zombie_vocals();
        e_ai_apothicon_fury thread zm_audio::zmbAIVox_NotifyConvert();
        e_ai_apothicon_fury playsound( "zmb_vocals_fury_spawn" );
        
        if ( IS_TRUE( b_find_flesh) )
        {
            wait 1;
            e_ai_apothicon_fury.zombie_think_done = 1;
        }
        return e_ai_apothicon_fury;
    }
    return undefined;
}

function private apothicon_fury_health_init()
{
    self.is_zombie = 1;
    n_zombie_health = level.zombie_health;
    if ( !isDefined( n_zombie_health ) )
        n_zombie_health = level.zombie_vars[ "zombie_health_start" ];
    
    if ( level.round_number <= 20 )
        self.maxhealth = n_zombie_health * APOTHICAN_FURY_HEALTH_MAX_START;
    else if ( level.round_number <= 50 )
        self.maxhealth = n_zombie_health * APOTHICAN_FURY_HEALTH_MAX_2;
    else
        self.maxhealth = n_zombie_health * APOTHICAN_FURY_HEALTH_MAX_3;
    
    if ( !isDefined( self.maxhealth ) || self.maxhealth <= 0 || self.maxhealth > APOTHICAN_FURY_HEALTH_CAP || self.maxhealth != self.maxhealth )
        self.maxhealth = n_zombie_health;
    
    self.health = int( self.maxhealth );
}

function apothicon_fury_get_valid_player()
{
    a_players = getPlayers();
    n_current_count = 9999999;
    e_valid_player = a_players[ 0 ];
    for ( i = 0; i < a_players.size; i++ )
    {
        e_player = a_players[ i ];
        if ( !isDefined( e_player.n_apothicon_fury_count ) )
            e_player.n_apothicon_fury_count = 0;
        
        if ( e_player.n_apothicon_fury_count < n_current_count )
        {
            e_valid_player = e_player;
            n_current_count = e_player.n_apothicon_fury_count;
        }
    }
    e_valid_player.n_apothicon_fury_count++;
    return e_valid_player;
}

function return_facing_target_angles( v_start, v_end )
{
    v_dir = v_end - v_start;
    v_dir = vectorNormalize( v_dir );
    v_angles = vectorToAngles( v_dir );
    return v_angles;
}

function apothicon_fury_special_spawn()
{
    a_players = getPlayers();
    e_player = apothicon_fury_get_valid_player();
    a_query_result = positionQuery_Source_Navigation( e_player.origin, 600, 800, 128, 20 );
    if ( isDefined( a_query_result ) && a_query_result.data.size > 0 )
    {
        a_spots = array::randomize( a_query_result.data );
        for ( i = 0; i < a_spots.size; i++ )
        {
            v_origin = a_spots[ i ].origin;
            v_angles = return_facing_target_angles( v_origin, e_player.origin );
            if ( zm_utility::check_point_in_enabled_zone( v_origin, 1 ) )
            {
                apothicon_fury_meteor_fx( v_origin );
                e_ai_apoticon_fury = apothicon_fury_spawn( v_origin, v_angles, 0 );
                if ( isDefined( e_ai_apoticon_fury ) )
                {
                    e_ai_apoticon_fury endon( "death" );
                    e_ai_apoticon_fury.health = level.zombie_health;
                    wait 1;
                    e_ai_apoticon_fury.zombie_think_done = 1;
                    e_ai_apoticon_fury.heroweapon_kill_power = 2;
                    e_ai_apoticon_fury ai::set_behavior_attribute( "move_speed", "run" );
                    e_ai_apoticon_fury thread zombie_utility::round_spawn_failsafe();
                    return e_ai_apoticon_fury;
                }
            }
        }
    }
    return undefined;
}

function apothicon_fury_spawn_on_location()
{
    a_players = getPlayers();
    e_player = apothicon_fury_get_valid_player();
	furies_locs = array::randomize(level.zm_loc_types["fury_location"]);

    if (isDefined(furies_locs) && furies_locs.size > 0)
    {
        a_spots = array::randomize(furies_locs);
        for (i = 0; i < a_spots.size; i++)
        {
            v_origin = a_spots[i].origin;
            v_angles = return_facing_target_angles(v_origin, e_player.origin);
            
            apothicon_fury_meteor_fx(v_origin);
            e_ai_apoticon_fury = apothicon_fury_spawn(v_origin, v_angles, 0);
            
            if (isDefined(e_ai_apoticon_fury))
            {
                e_ai_apoticon_fury endon("death");
                e_ai_apoticon_fury.health = level.zombie_health;
                wait 1;
                e_ai_apoticon_fury.zombie_think_done = 1;
                e_ai_apoticon_fury.heroweapon_kill_power = 2;
                e_ai_apoticon_fury ai::set_behavior_attribute("move_speed", "run");
                e_ai_apoticon_fury thread zombie_utility::round_spawn_failsafe();
                return e_ai_apoticon_fury;
            }
        }
    }

    return undefined;
}

function apothicon_fury_meteor_fx( v_spawn_pos )
{
    v_start_pos = ( v_spawn_pos[ 0 ], v_spawn_pos[ 1 ], v_spawn_pos[ 2 ] + 1000 );
    e_ground_fx_model = util::spawn_model( "tag_origin", v_start_pos, ( 0, 0, 0 ) );
    playFXOnTag(level._effect[ "fury_ground_tell_fx" ], e_ground_fx_model, "tag_origin" );
    e_fx_model = util::spawn_model( "tag_origin", v_start_pos, ( 0, 0, 0 ) );
    util::wait_network_frame();
    e_fx_model clientfield::set( "apothicon_fury_spawn_meteor", 1 );
    e_fx_model moveto( v_spawn_pos, 1.5 );
    e_fx_model waittill( "movedone" );
    e_fx_model clientfield::set( "apothicon_fury_spawn_meteor", 2 );
    e_fx_model delete();
    e_ground_fx_model delete();
}

function apothicon_fury_damage_event()
{
    self endon( "death" );
    while ( isAlive( self ) )
    {
        self waittill( "damage" );
        if ( isPlayer( self.attacker ) )
        {
            if (zm_spawner::player_using_hi_score_weapon( self.attacker ) )
                str_notify = "damage";
            else
                str_notify = "damage_light";
            
            if ( !IS_TRUE( self.deathpoints_already_given ) )
                self.attacker zm_score::player_add_points( str_notify, self.damagemod, self.damagelocation, undefined, self.team, self.damageweapon );
            
            if ( isDefined( level.hero_power_update ) )
                [ [ level.hero_power_update ] ]( self.attacker, self );
            
        }
        util::wait_network_frame();
    }
}

function apothicon_fury_death_event()
{
    self waittill( "death" );
    
    if( zombie_utility::get_current_zombie_count() == 0 && level.zombie_total == 0 )
    {

        level.v_last_apothicon_fury_origin = self.origin;
        level notify( "last_ai_down", self );

    }
    
    if ( isPlayer( self.attacker ) )
    {
        if ( !IS_TRUE( self.deathpoints_already_given ) )
            self.attacker zm_score::player_add_points( "death", self.damagemod, self.damagelocation, undefined, self.team, self.damageweapon );
        
        if ( isDefined( level.hero_power_update ) )
            [ [ level.hero_power_update ] ]( self.attacker, self );
        
    }
}

function enable_apothicon_fury_rounds()
{
    level.apothicon_fury_rounds_enabled = 1;

    if ( !isDefined( level.apothicon_fury_round_track_override ) )
        level.apothicon_fury_round_track_override =&apothicon_fury_round_tracker;

    level thread [ [ level.apothicon_fury_round_track_override ] ]();
}

function apothicon_fury_round_tracker()
{    
    level.n_apothicon_fury_round_count = 1;
    
    level.next_apothicon_fury_round = level.round_number + randomintrange( 4, 7 );    
    
    if ( IS_TRUE( APOTHICAN_FURY_DEBUG ) )
        level.next_apothicon_fury_round = 2;
    
    ptr_old_spawn_func = level.round_spawn_func;
    ptr_old_wait_func  = level.round_wait_func;

    while ( 1 )
    {
        level waittill ( "between_round_over" );

        if ( level.round_number == level.next_apothicon_fury_round )
        {
            level.sndMusicSpecialRound = 1;
            ptr_old_spawn_func = level.round_spawn_func;
            ptr_old_wait_func  = level.round_wait_func;
            apothicon_fury_round_start();
            level.round_spawn_func = &apothicon_fury_round_spawning;
            level.round_wait_func = &apothicon_fury_round_wait_func;

            level.next_apothicon_fury_round = level.round_number + randomintrange( 4, 6 );
            
            if ( IS_TRUE( APOTHICAN_FURY_DEBUG ) )
                level.next_apothicon_fury_round = level.round_number + 1;
            
        }
        else if ( level flag::get( "apothicon_fury_round" ) )
        {
            apothicon_fury_round_stop();
            level.round_spawn_func = ptr_old_spawn_func;
            level.round_wait_func  = ptr_old_wait_func;
            level.n_apothicon_fury_round_count += 1;
        }
    }    
}

function apothicon_fury_round_start()
{
    level flag::set( "apothicon_fury_round" );
    level flag::set( "special_round" );
    level flag::set( "apothicon_fury_clips" );
    
    level notify( "apothicon_fury_round_starting" );
    level thread zm_audio::sndMusicSystem_PlayState( "dog_start" );
    util::clientNotify( "apothicon_fury_start" );
}


function apothicon_fury_round_stop()
{
    level flag::clear( "apothicon_fury_round" );
    level flag::clear( "special_round" );
    level flag::clear( "apothicon_fury_clips" );
    
    level notify( "apothicon_fury_round_ending" );
    util::clientNotify( "apothicon_fury_stop" );
}

function apothicon_fury_round_wait_func()
{
    if ( level flag::get( "apothicon_fury_round" ) )
    {
        wait 7;
        while ( level.b_apothicon_fury_intermission )
            wait .5;
            
    }
    
    level.sndMusicSpecialRound = 0;
}

function apothicon_fury_round_spawning()
{
    level endon( "intermission" );
    level endon( "end_of_round" );
    level endon( "restart_round" );
    level endon( "kill_round" );

    if ( level.intermission )
        return;

    level.b_apothicon_fury_intermission = 1;
    level thread apothicon_fury_round_aftermath();
    a_players = getPlayers();
    array::thread_all( a_players,&play_apothicon_fury_round );    
    wait 1;
    level thread zm_audio::sndAnnouncerPlayVox( "dogstart" );
    wait 6;
    
    n_max = a_players.size * APOTHICAN_FURY_PER_ROUND;
    level.zombie_total = n_max;
    
    n_count = 0; 
    while ( 1 )
    {
        level flag::wait_till( "spawn_zombies" );
        
        while ( zombie_utility::get_current_zombie_count() >= level.zombie_ai_limit || level.zombie_total <= 0 )
            wait .1;

        n_num_player_valid = zm_utility::get_number_of_valid_players();
    
        while ( zombie_utility::get_current_zombie_count() >= n_num_player_valid * 4 )
        {
            wait 2;
            n_num_player_valid = zm_utility::get_number_of_valid_players();
        }

        if ( isDefined( level.apothicon_fury_spawn_func ) )
        {
            e_ai = [[ level.apothicon_fury_spawn_func ]]();
            if ( isDefined( e_ai ) )     
            {
                level.zombie_total--;
                n_count++;
                level flag::set( "apothicon_fury_clips" );
            }
        }
        else
        {
            e_ai = apothicon_fury_special_spawn();
            if ( isDefined( e_ai ) )     
            {
                level.zombie_total--;
                n_count++;
                level flag::set( "apothicon_fury_clips" );
            }
        }

        
        waiting_for_next_apothicon_fury_spawn( n_count, n_max );
    }
}

function waiting_for_next_apothicon_fury_spawn( n_count, n_max )
{
    n_default_wait = 1.5;

    if ( level.n_apothicon_fury_round_count == 1 )
        n_default_wait = 3;
    else if ( level.n_apothicon_fury_round_count == 2 )
        n_default_wait = 2.5;
    else if ( level.n_apothicon_fury_round_count == 3 )
        n_default_wait = 2;
    else 
        n_default_wait = 1.5;

    n_default_wait = n_default_wait - ( n_count / n_max );
    
    n_default_wait = max( n_default_wait, .05 ); 

    wait n_default_wait / 2;
}

function play_apothicon_fury_round()
{
    self playLocalSound( "zmb_dog_round_start" );
    
    wait 4.5;

    a_players = getPlayers();
    n_num = randomIntRange( 0, a_players.size );
    a_players[ n_num ] zm_audio::create_and_play_dialog( "general", "dog_spawn" );
}


function apothicon_fury_round_aftermath()
{
    level waittill( "last_ai_down", e_last );

    level thread zm_audio::sndMusicSystem_PlayState( "dog_end" );
    
    v_power_up_origin = level.v_last_apothicon_fury_origin;
    if ( isDefined( e_last ) )
        v_power_up_origin = e_last.origin;

    if( isDefined( v_power_up_origin ) )
        level thread zm_powerups::specific_powerup_drop( APOTHICAN_FURY_END_POWERUP, v_power_up_origin );
    
    wait 2;
    util::clientNotify( "apothicon_fury_stop" );
    wait 6;
    level.b_apothicon_fury_intermission = 0;
}

// ============================== FUNCTIONALITY ==============================