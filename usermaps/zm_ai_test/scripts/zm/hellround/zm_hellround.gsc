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
#using scripts\zm\hellround\zm_hellround_environment;
#using scripts\zm\hellround\zm_hellround_zombies;
#using scripts\zm\hellround\zm_hellround_music;

// AIs involved in hell rounds
#using scripts\shared\ai\zombie_utility;
#using scripts\zm\_zm_ai_dogs;
#using scripts\zm\_zm_ai_wasp;
#using scripts\zm\_zm_ai_napalm;
#using scripts\zm\zm_genesis_apothicon_fury;

#insert scripts\zm\hellround\zm_hellround.gsh;

#namespace zm_hellround;
REGISTER_SYSTEM_EX("zm_hellround", &init, &main, undefined)

class hellround
{
    var abolished;

    // Callbacks for hellrounds
    var begin_callbacks;
    var end_callbacks;

    // Iterations of hellrounds
    var current_iteration;
}

function private void(){}

function private init()
{
    // First, disable all custom rounds
    level.dog_rounds_allowed = 0;
    level.apothicon_fury_rounds_enabled = 0;
    level.apothicon_fury_round_track_override = &void;

    // Blood splatter happens only during hell rounds enabled
    level.bloodsplatter_disabled = true;

    level.hellround = new hellround();
    level.hellround.abolished = false;
    level.hellround.current_iteration = 0;
    level.hellround.begin_callbacks = [];
    level.hellround.end_callbacks = [];

    // Init custom flags
    level flag::init(HELLROUND_FLAGS[0]);
    level flag::init(HELLROUND_FLAGS[1]);
    level flag::init(HELLROUND_FLAGS[2]);
    level flag::init(HELLROUND_FLAGS[3]);
    level flag::init(HELLROUND_FLAGS[HELLROUND_BAD_FLAG_INDEX]);

    configure_callbacks();

    // Some AI needs to be initiated explicitly
    zm_ai_wasp::init();
}

function private main()
{
    level.initial_zombie_ai_limit = level.zombie_ai_limit;
    level.initial_zombie_actor_limit = level.zombie_actor_limit;

    level thread hellround_bad_iteration_watcher();
    level thread hellround_iteration_watcher();
}

// #region utility

function is_hellround_running()
{
    return !level.hellround.abolished
        && level flag::get(HELLROUND_FLAGS[0]) 
        || level flag::get(HELLROUND_FLAGS[1]) 
        || level flag::get(HELLROUND_FLAGS[2]) 
        || level flag::get(HELLROUND_FLAGS[3])
        || level flag::get(HELLROUND_BAD_FLAG);
}

function private is_normal_zombie() // self == actor
{
    if (IsDefined(self.animname) && self.animname !== "zombie")
        return false;

    if (IsDefined(self.archetype) && self.archetype == "zombie")
        return true;

    return false;
}

// #endregion
// #region hellround logic

function private abolish_hellrounds()
{
    PRINT_DEBUG_HR("Abolishing hellrounds...");
    level.hellround.abolished = true;

    // Kill other watchers first
    level notify(KILL_HELLROUND_WATCHERS_NOTIFICATION);

    // If hellround currently running, end it
    level hellround_stops();
}

function private hellround_cerberus_enable()
{
    thread hellround_starts();
}

function private hellround_cerberus_disable()
{
    thread hellround_stops(false);
}

function private hellround_cerberus_fed()
{
    thread hellround_stops();
}

function private hellround_starts()
{
    if (is_hellround_running()) {
        PRINT_DEBUG_HR("Hellrounds already running. Not starting again.");
        return;
    }
    PRINT_DEBUG_HR("Starting hellrounds...");

    level flag::set(HELLROUND_FLAGS[level.hellround.current_iteration]);
    thread call_begin_callbacks();
    thread hellround_start_spawns();
}

function private hellround_stops(should_progress = true) 
{
    if (!is_hellround_running()) {
        PRINT_DEBUG_HR("Hellrounds not running. Not stopping.");
        return;
    }
    PRINT_DEBUG_HR("Ending hellrounds...");
    
    hellround_clear_and_update_iteration_index(should_progress);
    thread call_end_callbacks();
    thread hellround_stop_spawns();
    
}

function private hellround_clear_and_update_iteration_index(should_progress = true, is_bad_version = false)
{
    if (level.hellround.abolished) {
        PRINT_DEBUG_HR("Hellrounds abolished. Not progressing.");
        return;
    }

    level flag::clear(HELLROUND_FLAGS[level.hellround.current_iteration]);
    level.hellround.current_iteration = (is_bad_version 
        ? HELLROUND_BAD_FLAG_INDEX 
        : (should_progress 
            ? level.hellround.current_iteration + 1 
            : level.hellround.current_iteration));
}

// #endregion
// #region callbacks

function add_begin_callback(func) {
    if (IsFunctionPtr(func)) {
        array::add(level.hellround.begin_callbacks, func);
    }
}

function add_end_callback(func) {
    if (IsFunctionPtr(func)) {
        array::add(level.hellround.end_callbacks, func);
    }
}

function private configure_callbacks()
{
    level.hellround_callback_should_be_begin = true;
    
    array::run_all(GetSpawnerArray(), &spawner::add_spawn_function, &zombie_spawn_hellround_logic);

    add_begin_callback(&enable_hellround_zombies);
    add_end_callback(&disable_hellround_zombies);

    add_begin_callback(&zm_hellround_environment::toggle_bloody_environment);
    add_end_callback(&zm_hellround_environment::toggle_bloody_environment);

    add_begin_callback(&zm_bloodsplatter::toggle_blood_splatter);
    add_end_callback(&zm_bloodsplatter::toggle_blood_splatter);

    level.wolf_heads_become_active_callback = &hellround_cerberus_enable;
    level.wolf_heads_become_inactive_callback = &hellround_cerberus_disable;
    level.soul_catchers_charged_callback = &hellround_cerberus_fed;
}

function private call_begin_callbacks()
{
    if (!level.hellround_callback_should_be_begin) {
        return;
    }
    level.hellround_callback_should_be_begin = false;

    foreach (callback in level.hellround.begin_callbacks)
    {
        level thread [[ callback ]]();
    }
}

function private call_end_callbacks()
{
    if (level.hellround_callback_should_be_begin) {
        return;
    }
    level.hellround_callback_should_be_begin = true;

    foreach (callback in level.hellround.end_callbacks)
    {
        level thread [[ callback ]]();
    }
}

// #endregion callbacks
// #region watchers

function private hellround_bad_iteration_watcher() 
{
    level endon(KILL_HELLROUND_WATCHERS_NOTIFICATION);

    level flag::wait_till(HELLROUND_BAD_FLAG_TRIGGER);
    level thread zm_wolf_soul_collectors::force_completion(); // turns off cerberus
    
    hellround_clear_and_update_iteration_index(false, true);
    hellround_starts();
}

function private hellround_iteration_watcher() 
{
    level endon(KILL_HELLROUND_WATCHERS_NOTIFICATION);
    level endon(HELLROUND_BAD_FLAG);

    level flag::wait_till(HELLROUND_FLAGS[0]); // First cerb started
    level flag::wait_till(HELLROUND_FLAGS[0]); // Second cerb started
    level flag::wait_till(HELLROUND_FLAGS[0]); // Third cerb started

    level flag::wait_till(HELLROUND_FLAGS[1]);
    level flag::wait_till(HELLROUND_FLAGS[2]);
    level flag::wait_till(HELLROUND_FLAGS[3]);
}

// #endregion
// #region spawners

function private hellround_start_spawns()
{
    spawn_flag = HELLROUND_FLAGS[level.hellround.current_iteration];
    switch (level.hellround.current_iteration)
    {
        case 0:
            thread iteration_0_spawns(spawn_flag);
            break;
        case 1:
            thread iteration_1_spawns(spawn_flag);
            break;
        case 2:
            thread iteration_2_spawns(spawn_flag);
            break;
        case 3:
            thread iteration_3_spawns(spawn_flag);
            break;
        case HELLROUND_BAD_FLAG_INDEX:
            thread iteration_bad_spawns();
            break;
        default:
            PRINT_DEBUG_HR("Hellrounds: no spawns for iteration " + level.hellround.current_iteration + " defined.");
            return;
    }
    
    // Based on initial values, no real justification here.
    level.zombie_ai_limit = 120;
    level.zombie_actor_limit = 127;
}

function private hellround_stop_spawns()
{
    level.zombie_ai_limit = level.initial_zombie_ai_limit;
    level.zombie_actor_limit = level.initial_zombie_actor_limit;

    level thread disable_hellround_zombies();
}

function private iteration_0_spawns(spawn_listen_flag) 
{
    // TODO : add some custom fx for round start like the following one ?
    // zm_ai_wasp::parasite_round_fx();
    // TODO: clear old zombies
    // TODO: disable round logic
    // TODO: give blundergate
    level thread spawn_dogs_loop(spawn_listen_flag);
    // level thread spawn_apothicon_furies_loop(spawn_listen_flag);
    // level thread spawn_wasps_loop(spawn_listen_flag);
    // level thread spawn_napalm_zombies_loop(spawn_listen_flag);
    // TODO: add infinite running zombies (with different model than original)
}

function private iteration_1_spawns(spawn_listen_flag) 
{
    // TODO : add some custom fx for round start like the following one ?
    // zm_ai_wasp::parasite_round_fx();
    // TODO: clear old zombies
    // TODO: disable round logic
    // TODO: give blundergate
    // level thread spawn_dogs_loop(spawn_listen_flag);
    level thread spawn_napalm_zombies_loop(spawn_listen_flag);
    // level thread spawn_apothicon_furies_loop(spawn_listen_flag);
    // level thread spawn_wasps_loop(spawn_listen_flag);
    // TODO: add infinite running zombies (with different model than original)
}

function private iteration_2_spawns(spawn_listen_flag)
{
    // TODO : add some custom fx for round start like the following one ?
    // zm_ai_wasp::parasite_round_fx();
    // TODO: clear old zombies
    // TODO: disable round logic
    // TODO: give DEATHMACHINE!!!
    // level thread spawn_dogs_loop(spawn_listen_flag);
    level thread spawn_napalm_zombies_loop(spawn_listen_flag);
    level thread spawn_apothicon_furies_loop(spawn_listen_flag);
    // level thread spawn_wasps_loop(spawn_listen_flag);
    // TODO: add infinite running zombies (with different model than original)
}

function private iteration_3_spawns(spawn_listen_flag)
{
    // TODO : add some custom fx for round start like the following one ?
    // zm_ai_wasp::parasite_round_fx();
    // TODO: clear old zombies
    // TODO: disable round logic
    // TODO: give DEATHMACHINE!!!
    // level thread spawn_dogs_loop(spawn_listen_flag);
    level thread spawn_napalm_zombies_loop(spawn_listen_flag);
    level thread spawn_apothicon_furies_loop(spawn_listen_flag);
    level thread spawn_wasps_loop(spawn_listen_flag);
    // TODO: add infinite running zombies (with different model than original)
}

function private iteration_bad_spawns(spawn_listen_flag = HELLROUND_BAD_FLAG)
{
    // TODO : add some custom fx for round start like the following one ?
    // zm_ai_wasp::parasite_round_fx();
    // TODO: clear old zombies
    // TODO: disable round logic
    // TODO: give DEATHMACHINE!!!
    level thread spawn_dogs_loop(spawn_listen_flag);
    level thread spawn_apothicon_furies_loop(spawn_listen_flag);
    level thread spawn_wasps_loop(spawn_listen_flag);
    level thread spawn_napalm_zombies_loop(spawn_listen_flag);
    // TODO: add infinite running zombies (with different model than original)
}

function private spawn_dogs_loop(spawn_flag)
{
    while (1)
    {
        wait randomIntRange(4, 8);
        PRINT_DEBUG_HR("Spawning wolf ...");

        // Don't use endon because it will bug the entities currently spawning
        if (!flag::get(spawn_flag))
        {
            PRINT_DEBUG_HR("Spawning wolf ... canceled.");
            return;
        }

        ai = zm_ai_dogs::custom_special_dog_spawn();
        ai thread zm_bloodsplatter::watch_actor();
    }
}

function private spawn_apothicon_furies_loop(spawn_flag)
{
    while (1)
    {
        wait randomIntRange(4, 8);
        PRINT_DEBUG_HR("Spawning apothicon ...");

        // Don't use endon because it will bug the entities currently spawning
        if (!flag::get(spawn_flag))
        {
            PRINT_DEBUG_HR("Spawning apothicon ... canceled.");
            return;
        }

        ai = zm_genesis_apothicon_fury::apothicon_fury_spawn_on_location();
        ai thread zm_bloodsplatter::watch_actor();
    }
}

function private spawn_wasps_loop(spawn_flag)
{
    while (1)
    {
        wait randomIntRange(8, 16);
        PRINT_DEBUG_HR("Spawning wasp ...");

        // Don't use endon because it will bug the entities currently spawning
        if (!flag::get(spawn_flag))
        {
            PRINT_DEBUG_HR("Spawning wasp ... canceled.");
            return;
        }

        ai = zm_ai_wasp::special_wasp_spawn();
        ai thread zm_bloodsplatter::watch_actor();
    }
}

function private spawn_napalm_zombies_loop(spawn_flag)
{
    while (1)
    {
        wait 15;
        PRINT_DEBUG_HR("Spawning napalm ...");

        // Don't use endon because it will bug the entities currently spawning
        if (!flag::get(spawn_flag))
        {
            PRINT_DEBUG_HR("Spawning napalm ... canceled.");
            return;
        }

        ai = zm_ai_napalm::napalm_zombie_spawning();
        ai thread zm_bloodsplatter::watch_actor();
    }
}

// #endregion
// #region zombie 

function private zombie_spawn_hellround_logic() // self == zombie spawned
{
    if (is_hellround_running() && self is_normal_zombie()) {
        waittillframeend;
        self thread zm_hellround_zombies::set_zombie_model_to_hellround();
        self thread zombie_utility::set_zombie_run_cycle("sprint");
    }
}

function private enable_hellround_zombies()
{
    zombies = GetAiSpeciesArray(level.zombie_team, "all");
    foreach (zombie in zombies)
    {
        if (zombie is_normal_zombie())
        {
            zombie thread zm_hellround_zombies::set_zombie_model_to_hellround();
            zombie thread zombie_utility::set_zombie_run_cycle("sprint");
        }
    }
}

function private disable_hellround_zombies()
{
    zombies = GetAiSpeciesArray(level.zombie_team, "all");
    foreach (zombie in zombies)
    {
        if (!zombie is_normal_zombie())
        {
            continue;
        }

        zombie thread zm_hellround_zombies::set_back_to_default_zombie();
        zombie thread zm_utility::init_zombie_run_cycle();
    }
}

// #endregion
