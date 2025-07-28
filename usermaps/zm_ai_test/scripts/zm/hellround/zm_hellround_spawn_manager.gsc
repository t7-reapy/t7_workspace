
#using scripts\shared\flag_shared; 
#using scripts\shared\system_shared;

// For callbacks
#using scripts\zm\_zm_bloodsplatter;
#using scripts\zm\hellround\zm_hellround_collectors;
#using scripts\zm\zm_wolf_soul_collectors;

// AIs involved in hell rounds
#using scripts\shared\ai\zombie_utility;
#using scripts\zm\_zm_ai_dogs;
#using scripts\zm\_zm_ai_wasp;
#using scripts\zm\_zm_ai_napalm;
#using scripts\zm\zm_genesis_apothicon_fury;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\hellround\zm_hellround_shared;
#insert scripts\zm\hellround\zm_hellround_shared.gsh;
#insert scripts\zm\hellround\zm_hellround_spawn_manager.gsh;
#namespace zm_hellround_spawn_manager;

REGISTER_SYSTEM_EX("zm_hellround_spawn_manager", &init, &main, undefined)

function private void(){}

function private init()
{
    // Disable all custom rounds
    level.dog_rounds_allowed = 0;
    level.apothicon_fury_rounds_enabled = 0;
    level.apothicon_fury_round_track_override = &void;

    level.hellround_current_iteration = 0;
    level.hellround_callback_should_be_begin = true;
}

function private main()
{
    level.initial_zombie_ai_limit = level.zombie_ai_limit;
    level.initial_zombie_actor_limit = level.zombie_actor_limit;

    zm_hellround_collectors::bind_completion_callback(&hellround_stops);
    level thread hellround_bad_iteration_watcher();
    level thread hellround_iteration_watcher();

    if (DEBUG_HELLROUNDS)
    {
        thread modvar_debug_start_stop_hellround();
    }
}

// #region watchers

function private hellround_bad_iteration_watcher() 
{
    level endon(KILL_HELLROUND_WATCHERS_NOTIFICATION);

    level flag::wait_till(HELLROUND_BAD_FLAG_TRIGGER);
    level thread zm_wolf_soul_collectors::force_completion(); // turns off cerberus
    
    hellround_stop_spawns();
    hellround_update_iteration(true);
    hellround_starts();
}

function private hellround_iteration_watcher() 
{
    level endon(KILL_HELLROUND_WATCHERS_NOTIFICATION);
    level endon(HELLROUND_BAD_FLAG);

    level flag::wait_till(HELLROUND_FLAGS[0]);
    PRINT_HR_DEBUG("Cerberus feeding started");
    level flag::wait_till_clear(HELLROUND_FLAGS[0]);
    level flag::wait_till_clear(HELLROUND_FLAGS[0]);
    level flag::wait_till_clear(HELLROUND_FLAGS[0]);
    PRINT_HR_DEBUG("Final cerb filled");
    hellround_progress();

    level flag::wait_till(HELLROUND_FLAGS[1]);
    PRINT_HR_DEBUG("First soul started");
    level flag::wait_till_clear(HELLROUND_FLAGS[1]);
    PRINT_HR_DEBUG("First soul filled");
    hellround_progress();

    level flag::wait_till(HELLROUND_FLAGS[2]);
    PRINT_HR_DEBUG("Second soul started");
    level flag::wait_till_clear(HELLROUND_FLAGS[2]);
    PRINT_HR_DEBUG("Second soul filled");
    hellround_progress();

    level flag::wait_till(HELLROUND_FLAGS[3]);
    PRINT_HR_DEBUG("Final filling started");
    level flag::wait_till_clear(HELLROUND_FLAGS[3]);
    PRINT_HR_DEBUG("Finished filling souls");
    hellround_progress();
}

// #endregion
// #region hellrounds round start/stop

// TODO: remove?
function abolish_hellrounds()
{
    PRINT_HR_DEBUG("Abolishing hellrounds...");
    level.hellround.abolished = true;

    // Kill other watchers first
    level notify(KILL_HELLROUND_WATCHERS_NOTIFICATION);

    // If hellround currently running, end it
    level hellround_stops();
}

function hellround_starts()
{
    if (zm_hellround_shared::is_hellround_running()) {
        PRINT_HR_DEBUG("Hellrounds already running. Not starting again.");
        return;
    }
    PRINT_HR_DEBUG("Starting hellrounds...");

    thread hellround_start_spawns();
    thread call_toggle_callbacks(true);
}

function hellround_stops() 
{
    if (!zm_hellround_shared::is_hellround_running()) {
        PRINT_HR_DEBUG("Hellrounds not running. Not stopping.");
        return;
    }
    PRINT_HR_DEBUG("Stopping hellrounds ...");
    
    hellround_stop_spawns();
    thread hellround_restore_ai_limit();
    thread call_toggle_callbacks(false);
}

function hellround_progress()
{
    PRINT_HR_DEBUG("Progressing hellrounds ...");
    hellround_update_iteration();
}

// #endregion
// #region iteration management

function private hellround_start_spawns()
{
    spawn_flag = HELLROUND_FLAGS[level.hellround_current_iteration];
    level flag::set(spawn_flag);

    switch (level.hellround_current_iteration)
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
            PRINT_HR_DEBUG("Hellrounds: no spawns for iteration " + level.hellround_current_iteration + " defined.");
            return;
    }
    
    // Based on initial values, no real justification here.
    level.zombie_ai_limit = 120;
    level.zombie_actor_limit = 127;
}

function private hellround_restore_ai_limit()
{
    level.zombie_ai_limit = level.initial_zombie_ai_limit;
    level.zombie_actor_limit = level.initial_zombie_actor_limit;
}

function private hellround_stop_spawns()
{
    if (level.hellround.abolished) {
        PRINT_HR_DEBUG("Hellrounds abolished. Not stopping spawns.");
        return;
    }

    // Clearing the flags stop the next coming spawns
    level flag::clear(HELLROUND_FLAGS[level.hellround_current_iteration]);
}

function private hellround_update_iteration(is_bad_version = false)
{
    if (level.hellround.abolished) {
        PRINT_HR_DEBUG("Hellrounds abolished. Not progressing.");
        return;
    }
    
    level.hellround_current_iteration = (is_bad_version ? HELLROUND_BAD_FLAG_INDEX : level.hellround_current_iteration + 1);
}

function private iteration_0_spawns(spawn_listen_flag) 
{
    PRINT_HR_DEBUG("ITERATION 0 SPAWNS");
        
    level thread spawn_dogs_loop(spawn_listen_flag);
}

function private iteration_1_spawns(spawn_listen_flag) 
{
    PRINT_HR_DEBUG("ITERATION 1 SPAWNS");
    
    level thread spawn_napalm_zombies_loop(spawn_listen_flag);
}

function private iteration_2_spawns(spawn_listen_flag)
{
    PRINT_HR_DEBUG("ITERATION 2 SPAWNS");
    
    level thread spawn_napalm_zombies_loop(spawn_listen_flag);
    level thread spawn_apothicon_furies_loop(spawn_listen_flag);
}

function private iteration_3_spawns(spawn_listen_flag)
{
    PRINT_HR_DEBUG("ITERATION 3 SPAWNS");
    
    level thread spawn_napalm_zombies_loop(spawn_listen_flag);
    level thread spawn_apothicon_furies_loop(spawn_listen_flag);
    level thread spawn_wasps_loop(spawn_listen_flag);
}

function private iteration_bad_spawns(spawn_listen_flag = HELLROUND_BAD_FLAG)
{
    PRINT_HR_DEBUG("ITERATION BAD SPAWNS");
    
    level thread spawn_dogs_loop(spawn_listen_flag);
    level thread spawn_apothicon_furies_loop(spawn_listen_flag);
    level thread spawn_wasps_loop(spawn_listen_flag);
    level thread spawn_napalm_zombies_loop(spawn_listen_flag);
}

// #endregion
// #region spawners

function private spawn_dogs_loop(spawn_flag)
{
    while (1)
    {
        wait randomIntRange(4, 8);
        PRINT_HR_DEBUG("Spawning wolf ...");

        // Don't use endon because it will bug the entities currently spawning
        if (!flag::get(spawn_flag))
        {
            PRINT_HR_DEBUG("Spawning wolf ... canceled.");
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
        PRINT_HR_DEBUG("Spawning apothicon ...");

        // Don't use endon because it will bug the entities currently spawning
        if (!flag::get(spawn_flag))
        {
            PRINT_HR_DEBUG("Spawning apothicon ... canceled.");
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
        PRINT_HR_DEBUG("Spawning wasp ...");

        // Don't use endon because it will bug the entities currently spawning
        if (!flag::get(spawn_flag))
        {
            PRINT_HR_DEBUG("Spawning wasp ... canceled.");
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
        PRINT_HR_DEBUG("Spawning napalm ...");

        // Don't use endon because it will bug the entities currently spawning
        if (!flag::get(spawn_flag))
        {
            PRINT_HR_DEBUG("Spawning napalm ... canceled.");
            return;
        }

        ai = zm_ai_napalm::napalm_zombie_spawning();
        ai thread zm_bloodsplatter::watch_actor();
    }
}

// #endregion
// #region callbacks

function private call_toggle_callbacks(b_enabled)
{
    foreach (callback in level.hellround.toggle_callbacks)
    {
        level thread [[ callback ]](b_enabled);
    }
}

// #endregion
// #region debug

function private modvar_debug_start_stop_hellround()
{
    ModVar("hrspawn", "");

    while(true)
    {
        WAIT_SERVER_FRAME;

        dvar_value = GetDvarString("hrspawn", "");

        if(!isdefined(dvar_value) || dvar_value == "")
        {
            continue;
        }
        ModVar("hrspawn", "");
        
        PRINT_HR_DEBUG("current hellround iteration: " + level.hellround_current_iteration);

        switch(Int(dvar_value))
        {
            case 1:
                hellround_starts();
                break;
            default:
                hellround_stops();
                break;
        }
    }
}

// #endregion
