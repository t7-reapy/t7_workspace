#using scripts\zm\_zm; 
#using scripts\zm\_util;
#using scripts\zm\_zm_utility;

#using scripts\shared\array_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\spawner_shared; 
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

// Involved in Hell rounds
#using scripts\zm\_hb21_zm_behavior;
#using scripts\zm\_zm_bloodsplatter;
#using scripts\zm\zm_wolf_soul_collectors;
#using scripts\zm\hellround\zm_hellround_announcer;
#using scripts\zm\hellround\zm_hellround_collectors;
#using scripts\zm\hellround\zm_hellround_environment;
#using scripts\zm\hellround\zm_hellround_mysterybox;
#using scripts\zm\hellround\zm_hellround_meteor;
#using scripts\zm\hellround\zm_hellround_music;
#using scripts\zm\hellround\zm_hellround_players;
#using scripts\zm\hellround\zm_hellround_powerup;
#using scripts\zm\hellround\zm_hellround_reward;
#using scripts\zm\hellround\zm_hellround_shared;
#using scripts\zm\hellround\zm_hellround_spawn_manager;
#using scripts\zm\hellround\zm_hellround_zombies;
#using scripts\zm\hellround\zm_hellround_vision;

// AIs involved in hell rounds
#using scripts\shared\ai\zombie_utility;
#using scripts\zm\_zm_ai_dogs;
#using scripts\zm\_zm_ai_wasp;
#using scripts\zm\_zm_ai_napalm;
#using scripts\zm\zm_genesis_apothicon_fury;
#using scripts\zm\zm_cellbreaker;

#insert scripts\zm\hellround\zm_hellround_shared.gsh;
#insert scripts\zm\hellround\zm_hellround.gsh;

#precache("fx", HELLROUND_DOG_EYE_GLOW_FX);

#namespace zm_hellround;
REGISTER_SYSTEM_EX("zm_hellround", &init, &main, undefined)

class hellround
{
    var ending;
    var progress_stopped;
    var toggle_callbacks;
}

function private init()
{
    // Blood splatter happens only during hellrounds
    level.bloodsplatter_disabled = true;

    level.hellround = new hellround();
    level.hellround.ending = NEUTRAL_ENDING;
    level.hellround.progress_stopped = false;
    level.hellround.toggle_callbacks = [];

    // Init hellround iteration flags
    level flag::init(HELLROUND_FLAGS[0]);
    level flag::init(HELLROUND_FLAGS[1]);
    level flag::init(HELLROUND_FLAGS[2]);
    level flag::init(HELLROUND_FLAGS[3]);
    level flag::init(HELLROUND_FLAGS[HELLROUND_BAD_FLAG_INDEX]);

    bind_callbacks();

    // Some AI needs to be initiated explicitly
    zm_ai_wasp::init();
}

function private main()
{
    level._effect["dog_eye_glow"] = HELLROUND_DOG_EYE_GLOW_FX; 
}

function is_hellround_running()
{
    return zm_hellround_shared::is_hellround_running();
}

/* region callbacks */

function add_toggle_callback(func) {
    if (IsFunctionPtr(func)) {
        array::add(level.hellround.toggle_callbacks, func);
    }
}

function private call_toggle_callbacks(b_enabled)
{
    foreach (callback in level.hellround.toggle_callbacks)
    {
        level thread [[ callback ]](b_enabled);
    }
}

function add_start_collector_callback(func) 
{
    zm_hellround_collectors::add_start_collection_callback(func);
}

function add_stop_collector_callback(func)
{
    zm_hellround_collectors::add_stop_collection_callback(func);
}

function add_meteor_trigger_callback(func_ptr)
{
    zm_hellround_meteor::add_meteor_trigger_callback(func_ptr);
}

function game_finished_with_success()
{
    zm_hellround_reward::game_finished_with_success();
}

function private enable_good_ending()
{
    level.hellround.ending = GOOD_ENDING;
}

function private enable_bad_ending()
{
    level.hellround.ending = BAD_ENDING;
}

function get_ending_associated_color()
{
    return ENDING_COLORS[level.hellround.ending];
}

function private bind_callbacks()
{
    add_toggle_callback(&respawn_players);
    add_toggle_callback(&temporary_invulnerability);
    add_toggle_callback(&zm_hellround_powerup::lose_minigun_callback);
    add_toggle_callback(&zm_hellround_zombies::toggle_hellround_zombies);
    add_toggle_callback(&zm_hellround_players::toggle_hellround_for_players);
    add_toggle_callback(&zm_hellround_environment::toggle_hellround_environment);
    add_toggle_callback(&zm_hellround_mysterybox::toggle_hellround_mysteryboxes);
    add_toggle_callback(&zm_bloodsplatter::toggle_blood_splatter);
    add_toggle_callback(&zm_hellround_music::toggle_hellround_music);
    add_toggle_callback(&zm_hellround_announcer::toggle_hellround_announce);
    add_toggle_callback(&zm_hellround_vision::toggle_hellround_vision);

    zm_hellround_spawn_manager::bind_toggle_hellround_callback(&call_toggle_callbacks);
    zm_hellround_spawn_manager::add_ai_spawn_callback(&zm_bloodsplatter::watch_actor);
    zm_hellround_spawn_manager::add_ai_spawn_callback(&zm_hellround_announcer::watch_ai_kill);
    zm_hellround_spawn_manager::bind_reward_callback(&zm_hellround_reward::give_reward);
    
    zm_hellround_reward::add_high_tier_reward_callback(&zm_hellround_mysterybox::permanent_unlock);
    zm_hellround_reward::add_high_tier_reward_callback(&zm_hellround_announcer::bad_path_survived);

    // Hellround powerup and collector should never be canceled because bad iteration is no more available after feeding cerberus heads.
    // I'm not fond of that, but we still bind this logic because its part of the hellround overall logic.
    zm_hellround_spawn_manager::add_bad_iteration_callback(&zm_hellround_collectors::cancel_collection_logic);
    zm_hellround_spawn_manager::add_bad_iteration_callback(&zm_wolf_soul_collectors::force_completion);
    zm_hellround_spawn_manager::add_bad_iteration_callback(&zm_hellround_powerup::lose_minigun_callback);
    zm_hellround_spawn_manager::add_bad_iteration_callback(&enable_bad_ending);
    zm_hellround_spawn_manager::add_bad_iteration_callback(&zm_hellround_music::enable_bad_ending);
    zm_hellround_spawn_manager::add_bad_iteration_callback(&zm_hellround_announcer::bad_path_started);

    zm_hellround_collectors::add_start_collection_callback(&zm_hellround_spawn_manager::iteration_time_management_update);
    zm_hellround_collectors::add_stop_collection_callback(&zm_hellround_spawn_manager::hellround_stops);
    zm_hellround_collectors::bind_reward_callback(&zm_hellround_reward::give_reward);
    zm_hellround_collectors::add_completion_callbacks(&zm_hellround_meteor::hellround_meteor_logic);
    zm_hellround_collectors::add_completion_callbacks(&zm_hellround_announcer::finished_good_path);

    zm_hellround_meteor::add_meteor_trigger_callback(&enable_good_ending);
    zm_hellround_meteor::add_meteor_trigger_callback(&zm_hellround_music::enable_good_ending);

    zm_hellround_powerup::add_minigun_callback(&zm_hellround_spawn_manager::hellround_starts);
    zm_hellround_powerup::add_minigun_callback(&zm_hellround_collectors::start_collection_logic);

    level.wolf_head_become_active_callback = &hellround_cerberus_enable;
    level.wolf_head_become_inactive_callback = &hellround_cerberus_disable;
    level.soul_catchers_charged_callback = &hellround_cerberus_fed;

    level.hellround_zombie_callback = &zm_hellround_spawn_manager::disable_point_during_hellrounds;
}

function private respawn_players(b_enable)
{
    foreach (player in GetPlayers())
    {
        player zm::spectator_respawn_player();
    }
}

function private temporary_invulnerability(b_enable)
{
    foreach(player in GetPlayers())
    {
        player EnableInvulnerability();
    }

    wait 2;

    foreach(player in GetPlayers())
    {
        player DisableInvulnerability();
    }
}

function private hellround_cerberus_enable(is_one_head_already_active)
{
    thread zm_hellround_announcer::cerberus_feeding_started();
    zm_hellround_spawn_manager::iteration_time_management_update();
    if (!is_one_head_already_active)
    {
        thread zm_hellround_spawn_manager::hellround_starts();
    }
}

function private hellround_cerberus_disable(is_one_head_still_active, location)
{
    if (!is_one_head_still_active)
    {
        thread zm_hellround_spawn_manager::hellround_stops();
    }

    thread zm_hellround_announcer::iteration_complete();
    thread zm_hellround_reward::give_reward(location);
}

function private hellround_cerberus_fed()
{
    thread zm_hellround_spawn_manager::abolish_bad_hellround();
    thread zm_hellround_announcer::wait_for_hellround_bad_flag_when_abolished();
    thread zm_hellround_spawn_manager::hellround_stops();
    thread zm_hellround_spawn_manager::hellround_progress();
}

/* endregion */
