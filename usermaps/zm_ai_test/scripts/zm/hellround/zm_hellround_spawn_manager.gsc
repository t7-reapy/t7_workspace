#using scripts\zm\_zm;
#using scripts\zm\_zm_powerups; 
#using scripts\zm\_typewriter;
#using scripts\shared\array_shared; 
#using scripts\shared\flag_shared; 
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;

// AIs involved in hell rounds
#using scripts\shared\ai\zombie_utility;
#using scripts\zm\_zm_ai_dogs;
#using scripts\zm\_zm_ai_wasp;
#using scripts\zm\_zm_ai_napalm;
#using scripts\zm\zm_genesis_apothicon_fury;
#using scripts\zm\zm_cellbreaker;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\hellround\zm_hellround_music;
#using scripts\zm\hellround\zm_hellround_shared;
#insert scripts\zm\hellround\zm_hellround_shared.gsh;
#insert scripts\zm\hellround\zm_hellround_spawn_manager.gsh;
#namespace zm_hellround_spawn_manager;

REGISTER_SYSTEM_EX("zm_hellround_spawn_manager", &init, &main, undefined)

function private void(){}

class HellRoundSpawnManager
{
    var current_iteration;
    var iterations_completed;

    var hellround_callback;
    var ai_spawn_callbacks;
    var bad_iteration_callbacks;
    var reward_callback;

    var collection_start_timestamp;
    var time_before_max_spawn_rate;
}

function private init()
{
    // Disable all custom rounds
    level.dog_rounds_allowed = 0;
    level.apothicon_fury_rounds_enabled = 0;
    level.apothicon_fury_round_track_override = &void;

    // For pausing round logic during hellround
    level flag::init("world_is_paused");

    level.hellround_spawn_manager = new HellRoundSpawnManager();
    level.hellround_spawn_manager.current_iteration = 0;
    level.hellround_spawn_manager.iterations_completed = false;
    level.hellround_spawn_manager.hellround_callback = undefined;
    level.hellround_spawn_manager.ai_spawn_callbacks = [];
    level.hellround_spawn_manager.bad_iteration_callbacks = [];
    level.hellround_spawn_manager.reward_callback = undefined;
    level.hellround_spawn_manager.collection_start_timestamp = undefined;
    level.hellround_spawn_manager.time_before_max_spawn_rate = undefined;

    level.napalm_should_spawn_fire = &napalm_should_spawn_fire;

    // If hellround ends, ai shouldn't persists, and shall be killed.
    add_ai_spawn_callback(&watch_if_ai_persists_outside_of_hellrounds);
    add_ai_spawn_callback(&disable_point_during_hellrounds);
    add_ai_spawn_callback(&disable_actor_push_during_hellrounds);
}

function private main()
{
    level.initial_zombie_ai_limit = level.zombie_ai_limit;
    level.initial_zombie_actor_limit = level.zombie_actor_limit;

    level thread hellround_bad_iteration_watcher();
    level thread hellround_iteration_watcher();

    if (DEBUG_HELLROUNDS)
    {
        thread modvar_debug_start_stop_hellround();
    }
}

/* region watchers */

function private hellround_bad_iteration_watcher() 
{
    level endon(KILL_HELLROUND_BAD_ITERATION_WATCHER_NOTIFICATION);
    level endon("end_game");

    level flag::wait_till(HELLROUND_BAD_FLAG_TRIGGER);

    bad_iteration_callbacks();
    hellround_stop_spawns();
    hellround_update_iteration(true);
    iteration_time_management_update();
    hellround_starts();
    wait_for_hellround_max_delay();
    abolish_hellrounds();
    give_players_bad_iteration_reward();

    thread cellbreaker_visits();
}

function private cellbreaker_visits()
{
    level endon("end_game");

    interval = HRSPAWN_CELLBREAK_VISIT_ROUND_INTERVAL;
    round_number = zm::get_round_number();
    next_round = round_number + interval;

    while (true)
    {
        level waittill("between_round_over");
        round_number = zm::get_round_number();

        if (round_number < next_round)
        {
            PRINT_HR_DEBUG("Not yet a round for cellbreakers");
            continue;
        }

        PRINT_HR_DEBUG("Cellbreakers are coming");
        next_round = round_number + interval;
        iteration_time_management_update();
        hellround_starts();
        level waittill("cellbreakers_killed");
        _end_current_round();
        hellround_stops();
    }
}

function private hellround_iteration_watcher() 
{
    level endon(KILL_HELLROUND_WATCHERS_NOTIFICATION);
    level endon(HELLROUND_BAD_FLAG);
    level endon("end_game");

    // Cerberus (iteration 0) is not a real iteration, so we don't wait for it
    // It is managed through callbacks in zm_hellround.gsc

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
    level.hellround_spawn_manager.iterations_completed = true;
}

function private watch_if_ai_persists_outside_of_hellrounds() // self == ai actor
{
    self endon("death");

    if (!isdefined(self))
    {
        return;
    }

    while(zm_hellround_shared::is_hellround_running())
    {
        WAIT_SERVER_FRAME;
    }

    if (IsAlive(self))
    {
        wait 1.0;
        self util::stop_magic_bullet_shield();
        self Kill();
    }
}

function disable_point_during_hellrounds() // self == ai actor
{
    self endon("death");

    while(1)
    {
        if (zm_hellround_shared::is_hellround_running())
        {
            self.deathpoints_already_given = true;
        }
        else
        {
            self.deathpoints_already_given = false;
        }
        WAIT_SERVER_FRAME;
    }
}

function disable_actor_push_during_hellrounds() // self == ai actor
{
    self endon("death");

    while(1)
    {
        wait 2; // It seems a delay needs to be added before updating PushActors

        if (!IsActor(self))
        {
            continue;
        }

        if (zm_hellround_shared::is_hellround_running())
        {
            self PushActors(false);
        }
        else
        {
            self PushActors(true);
        }
    }
}

/* endregion */
/* region hellrounds round start/stop */

function private _end_current_round()
{
    foreach(zombie in zombie_utility::get_round_enemy_array())
    {
        zombie Kill();
    }
    level.zombie_total = 0;
    level notify("end_of_round");
}

function abolish_hellrounds()
{
    PRINT_HR_DEBUG("Abolishing hellrounds...");

    // If hellround currently running, end it
    level hellround_stops();

    level.hellround.progress_stopped = true;

    // Kill other watchers first
    level notify(KILL_HELLROUND_WATCHERS_NOTIFICATION);
}

function abolish_bad_hellround()
{
    level notify(KILL_HELLROUND_BAD_ITERATION_WATCHER_NOTIFICATION);
}

function hellround_starts()
{
    if (zm_hellround_shared::is_hellround_running()) {
        PRINT_HR_DEBUG("Hellrounds already running. Not starting again.");
        return;
    }
    PRINT_HR_DEBUG("Starting hellrounds...");

    thread hellround_pause_round_logic();
    thread hellround_increase_ai_limit();
    thread hellround_start_spawns();
    thread hellround_typewriter();
    thread call_toggle_callbacks(true);
}

function hellround_stops() 
{
    if (!zm_hellround_shared::is_hellround_running()) {
        PRINT_HR_DEBUG("Hellrounds not running. Not stopping.");
        return;
    }
    PRINT_HR_DEBUG("Stopping hellrounds ...");
    
    thread hellround_stop_spawns();
    thread hellround_restore_ai_limit();
    thread hellround_restore_round_logic();
    thread call_toggle_callbacks(false);
}

function hellround_progress()
{
    PRINT_HR_DEBUG("Progressing hellrounds ...");
    hellround_update_iteration();
}

function private hellround_pause_round_logic()
{
    // Disable normal zombie spawn
    level flag::set("world_is_paused");

    // Disable round display from HUD
    level.noRoundNumber = true;
    SetRoundsPlayed(0);
    
    // Block round sounds during hellrounds (if we have cleared last zombies)
    zm_hellround_music::disable_round_sounds();
    
    // Finally, disable scoring to prevent player from farming during hellround
    level.player_score_override = &zero_score;
    level.team_score_override = &zero_score;
    foreach(player in GetPlayers())
    {
        player.ready_for_score_events = false;
    }

    // Between round, the round display change in "round_think" (if all zombie died for example)
    // The following prevent the round number to be displayed.
    level endon("stop_hellround_pause_round_logic");
    level waittill("between_round_over");
    SetRoundsPlayed(0);
}

function private zero_score(arg0 = undefined, arg1 = undefined)
{
    return 0;
}

function private hellround_restore_round_logic()
{
    level notify("stop_hellround_pause_round_logic");
    
    // Restore zombie spawning
    level flag::clear("world_is_paused");

    // Restore round display in HUD
    level.noRoundNumber = false;
    SetRoundsPlayed(level.round_number);
    
    zm_hellround_music::restore_round_sounds();
    
    // Finally, enable back scoring
    level.player_score_override = undefined;
    level.team_score_override = undefined;
    foreach(player in GetPlayers())
    {
        player.ready_for_score_events = true;
    }
}

/* endregion */
/* region iteration management */

function private hellround_typewriter()
{
    spawn_flag = HELLROUND_FLAGS[level.hellround_spawn_manager.current_iteration];
    level flag::set(spawn_flag);

    switch (level.hellround_spawn_manager.current_iteration)
    {
        case 0:
            typewriter::type("New secondary objective:", "> Feed the ^1cerberus^7 head");
            break;
        case 1:
            typewriter::type("New secondary objective:", "> Find the ^1altar^7 and ^1close it^7");
            break;
        case 2:
            typewriter::type("New secondary objective:", "> Find the ^1altar^7 and ^1close it^7 again");
            break;
        case 3:
            typewriter::type("New secondary objective:", "> One last time.");
            break;
        case HELLROUND_BAD_ITERATION:
            typewriter::type("Mission failed", "New Mission: Survive ^1hell");
            break;
        default:
            PRINT_HR_DEBUG("Hellrounds: no typewriter for iteration " + level.hellround_spawn_manager.current_iteration + " defined.");
            return;
    }
}

function private hellround_start_spawns()
{
    spawn_flag = HELLROUND_FLAGS[level.hellround_spawn_manager.current_iteration];
    level flag::set(spawn_flag);

    switch (level.hellround_spawn_manager.current_iteration)
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
        case HELLROUND_BAD_ITERATION:
            thread iteration_bad_spawns();
            break;
        default:
            PRINT_HR_DEBUG("Hellrounds: no spawns for iteration " + level.hellround_spawn_manager.current_iteration + " defined.");
            return;
    }
}

function iteration_time_management_update()
{
    if (isdefined(level.hellround_spawn_manager.collection_start_timestamp))
    {
        // If a collection was already started, we just extend the amount of time before maximum spawn rate is reached.
        level.hellround_spawn_manager.time_before_max_spawn_rate += HRSPAWN_TIME_BEFORE_MIN_SPAWN_DELAY;
        PRINT_HR_DEBUG("time_before_max_spawn_rate increased to: " + level.hellround_spawn_manager.time_before_max_spawn_rate);
    }
    else
    {
        level.hellround_spawn_manager.collection_start_timestamp = GetTime();
        level.hellround_spawn_manager.time_before_max_spawn_rate = HRSPAWN_TIME_BEFORE_MIN_SPAWN_DELAY;
        PRINT_HR_DEBUG("time_before_max_spawn_rate defined to: " + level.hellround_spawn_manager.time_before_max_spawn_rate);
    }
}

function private wait_for_hellround_max_delay()
{
    wait HRSPAWN_TIME_BEFORE_MIN_SPAWN_DELAY / 1000;
    PRINT_HR_DEBUG("Reached minimum spawn delay. Exiting.");
}

function private napalm_should_spawn_fire()
{
    // No fire outside of hellround (when hellround ends for example)
    // Neither during bad iteration (it saves the player from potential overwhelming situations)
    return zm_hellround_shared::is_hellround_running() && !level flag::get(HELLROUND_BAD_FLAG);
}

function private hellround_increase_ai_limit()
{
    // Initial values are 24 & 31, no real justification here.
    level.zombie_ai_limit = 54;
    level.zombie_actor_limit = 61;
}

function private hellround_restore_ai_limit()
{
    level.zombie_ai_limit = level.initial_zombie_ai_limit;
    level.zombie_actor_limit = level.initial_zombie_actor_limit;
}

function private hellround_stop_spawns()
{
    // Clearing the flags stop the next coming spawns
    level flag::clear(HELLROUND_FLAGS[level.hellround_spawn_manager.current_iteration]);

    // Clearing collection_start_timestamp will reset it at next collection
    level.hellround_spawn_manager.collection_start_timestamp = undefined;
}

function private hellround_update_iteration(is_bad_version = false)
{
    if (level.hellround.progress_stopped) {
        PRINT_HR_DEBUG("Hellrounds progress_stopped. Not progressing.");
        return;
    }

    current_iteration = level.hellround_spawn_manager.current_iteration;
    if ((current_iteration + 1) == HELLROUND_BAD_ITERATION && !is_bad_version)
    {
        PRINT_HR_DEBUG("Can not progress to bad iteration without explicitely asking for it");
        return;
    }
    
    level.hellround_spawn_manager.current_iteration = (is_bad_version ? HELLROUND_BAD_ITERATION : current_iteration + 1);
}

function private iteration_0_spawns(spawn_listen_flag) 
{
    PRINT_HR_DEBUG("ITERATION 0 SPAWNS");
    
    level thread spawn_zombies_loop(spawn_listen_flag);
    level thread spawn_dogs_loop(spawn_listen_flag);
}

function private iteration_1_spawns(spawn_listen_flag) 
{
    PRINT_HR_DEBUG("ITERATION 1 SPAWNS");
    
    level thread spawn_zombies_loop(spawn_listen_flag);
    level thread spawn_napalm_zombies_loop(spawn_listen_flag);
}

function private iteration_2_spawns(spawn_listen_flag)
{
    PRINT_HR_DEBUG("ITERATION 2 SPAWNS");
    
    level thread spawn_zombies_loop(spawn_listen_flag);
    level thread spawn_napalm_zombies_loop(spawn_listen_flag);
    level thread spawn_apothicon_furies_loop(spawn_listen_flag);
}

function private iteration_3_spawns(spawn_listen_flag)
{
    PRINT_HR_DEBUG("ITERATION 3 SPAWNS");
    
    level thread spawn_zombies_loop(spawn_listen_flag);
    level thread spawn_napalm_zombies_loop(spawn_listen_flag);
    level thread spawn_apothicon_furies_loop(spawn_listen_flag);
    level thread spawn_wasps_loop(spawn_listen_flag);
}

function private iteration_bad_spawns(spawn_listen_flag = HELLROUND_BAD_FLAG)
{
    PRINT_HR_DEBUG("ITERATION BAD SPAWNS");

    if (IS_TRUE(level.hellround.progress_stopped))
    {
        // In case bad iteration was already finished, we spawn cellbreakers
        iteration_post_bad_spawns(spawn_listen_flag);
        return;
    }
    
    level thread spawn_zombies_loop(spawn_listen_flag);
    level thread spawn_dogs_loop(spawn_listen_flag);
    level thread spawn_apothicon_furies_loop(spawn_listen_flag);
    level thread spawn_wasps_loop(spawn_listen_flag);
    level thread spawn_napalm_zombies_loop(spawn_listen_flag);
}

function private iteration_post_bad_spawns(spawn_listen_flag = HELLROUND_BAD_FLAG)
{
    PRINT_HR_DEBUG("ITERATION POST BAD SPAWNS");

    level thread spawn_zombies_loop(spawn_listen_flag);
    level thread spawn_cellbreakers(spawn_listen_flag);
}

/* endregion */
/* region spawners */

function private is_special_spawn_enable()
{
    return HRSPAWN_ENABLE_SPAWNS && !GetDvarInt("ai_disablespawn", 0);
}

/* region spawn ditribution */

function private get_spawn_delay(min_delay_spawn, max_delay_spawn)
{
    ratio = get_time_elapsed_ratio();
    distribution = get_spawn_ratio_distributed(ratio);
    spawn_delay = get_delay_internal(distribution, min_delay_spawn, max_delay_spawn);

    return spawn_delay;
}

function private get_time_elapsed_ratio()
{
    if (!isdefined(level.hellround_spawn_manager.collection_start_timestamp))
    {
        PRINT_HR_DEBUG("Something is wrong: collection_start_timestamp is undefined");
        return 0;
    }

    time_elapsed = GetTime() - level.hellround_spawn_manager.collection_start_timestamp;
    time_before_max_spawn_rate = level.hellround_spawn_manager.time_before_max_spawn_rate;

    if (time_elapsed > time_before_max_spawn_rate)
    {
        time_elapsed = time_before_max_spawn_rate;
    }

    time_elapsed_ratio = time_elapsed / time_before_max_spawn_rate;
    return time_elapsed_ratio;
}

// Get a distribution, between 0 and 1, ratio must be between 0 and 1.
function private get_spawn_ratio_distributed(ratio)
{
    // Here, we use f(x) = x^2
    return ratio * ratio;
}

function private get_delay_internal(distribution, min_delay_spawn, max_delay_spawn)
{
    delay = max_delay_spawn - (max_delay_spawn - min_delay_spawn) * distribution;
    player_ratio = (1 + HRSPAWN_PLAYER_NUMBER_FACTOR) - level.players.size * HRSPAWN_PLAYER_NUMBER_FACTOR;
    return delay * player_ratio;
}

/* endregion */
/* region zombie spawn specific */

function private spawn_zombie_internal()
{
    if(!isdefined(level.zombie_spawners))
    {
        PRINT_HR_DEBUG("No spawners for zombies found in map. No AI created.");
        return undefined;
    }

    // Check for custom zombie spawner selection
    if (isdefined(level.fn_custom_zombie_spawner_selection))
    {
        spawner = [[ level.fn_custom_zombie_spawner_selection ]]();
    }

    // Default zombie spawner selection
    else
    {
        if(IS_TRUE(level.use_multiple_spawns))
        {
            if(isdefined(level.spawner_int) && IS_TRUE(level.zombie_spawn[level.spawner_int].size))
            {
                spawner = array::random(level.zombie_spawn[level.spawner_int]);
            }
            else
            {
                spawner = array::random(level.zombie_spawners);
            }
        }
        else
        {
            spawner = array::random(level.zombie_spawners);
        }
    }

    ai = zombie_utility::spawn_zombie(spawner, spawner.targetname);
    
    return ai;
}

/* endregion */

function private spawn_zombies_loop(spawn_flag)
{
    level endon("end_game");
    level notify("spawn_zombies_loop");
    level endon("spawn_zombies_loop");

    while (1)
    {
        delay = get_spawn_delay(HRSPAWN_MIN_DELAY_ZOMBIE, HRSPAWN_MAX_DELAY_ZOMBIE);

        PRINT_HR_DEBUG("Spawning zombie in " + delay);
        wait delay;

        // Don't use endon because it will bug the entities currently spawning
        if (!flag::get(spawn_flag) || !is_special_spawn_enable())
        {
            PRINT_HR_DEBUG("Spawning zombie ... canceled.");
            return;
        }

        if (GetAiSpeciesArray(level.zombie_team, "all").size >= level.zombie_ai_limit)
        {
            continue;
        }

        ai = spawn_zombie_internal();
        if (!isdefined(ai))
        {
            PRINT_HR_DEBUG("Ai zombie was created but is undefined");
            continue;
        }
        ai ai_spawn_callbacks();
    }
}

function private spawn_dogs_loop(spawn_flag)
{
    level endon("end_game");
    level notify("spawn_dogs_loop");
    level endon("spawn_dogs_loop");

    while (1)
    {
        delay = get_spawn_delay(HRSPAWN_MIN_DELAY_DOG, HRSPAWN_MAX_DELAY_DOG);

        PRINT_HR_DEBUG("Spawning wolf in " + delay);
        wait delay;

        // Don't use endon because it will bug the entities currently spawning
        if (!flag::get(spawn_flag) || !is_special_spawn_enable())
        {
            PRINT_HR_DEBUG("Spawning wolf ... canceled.");
            return;
        }

        if (GetAiSpeciesArray(level.zombie_team, "all").size >= level.zombie_ai_limit)
        {
            continue;
        }

        ai = zm_ai_dogs::custom_special_dog_spawn();
        if (!isdefined(ai))
        {
            PRINT_HR_DEBUG("Ai wolf was created but is undefined");
            continue;
        }
        ai ai_spawn_callbacks();
    }
}

function private spawn_apothicon_furies_loop(spawn_flag)
{
    level endon("end_game");
    level notify("spawn_apothicon_furies_loop");
    level endon("spawn_apothicon_furies_loop");
    
    while (1)
    {
        delay = get_spawn_delay(HRSPAWN_MIN_DELAY_FURY, HRSPAWN_MAX_DELAY_FURY);

        PRINT_HR_DEBUG("Spawning apothicon in " + delay);
        wait delay;

        // Don't use endon because it will bug the entities currently spawning
        if (!flag::get(spawn_flag) || !is_special_spawn_enable())
        {
            PRINT_HR_DEBUG("Spawning apothicon ... canceled.");
            return;
        }

        if (GetAiSpeciesArray(level.zombie_team, "all").size >= level.zombie_ai_limit)
        {
            continue;
        }

        ai = zm_genesis_apothicon_fury::apothicon_fury_spawn_on_location();
        if (!isdefined(ai))
        {
            PRINT_HR_DEBUG("Ai Fury was created but is undefined");
            continue;
        }
        ai ai_spawn_callbacks();
    }
}

function private spawn_wasps_loop(spawn_flag)
{
    level endon("end_game");
    level notify("spawn_wasps_loop");
    level endon("spawn_wasps_loop");
    
    while (1)
    {
        delay = get_spawn_delay(HRSPAWN_MIN_DELAY_WASP, HRSPAWN_MAX_DELAY_WASP);

        PRINT_HR_DEBUG("Spawning wasp in " + delay);
        wait delay;

        // Don't use endon because it will bug the entities currently spawning
        if (!flag::get(spawn_flag) || !is_special_spawn_enable())
        {
            PRINT_HR_DEBUG("Spawning wasp ... canceled.");
            return;
        }

        if (GetAiSpeciesArray(level.zombie_team, "all").size >= level.zombie_ai_limit)
        {
            continue;
        }

        // No open wasp location (zone closed): special_wasp_spawn() would block forever waiting
        // for one and park this loop past the hellround. Skip so the flag check above can exit it.
        if (!isdefined(level.zm_loc_types["wasp_location"]) || level.zm_loc_types["wasp_location"].size == 0)
        {
            PRINT_HR_DEBUG("No open wasp location (zone closed). Skipping wasp spawn this cycle.");
            continue;
        }

        ai = zm_ai_wasp::special_wasp_spawn();
        if (!isdefined(ai))
        {
            PRINT_HR_DEBUG("Ai wasp was created but is undefined");
            continue;
        }
        ai ai_spawn_callbacks();
    }
}

function private spawn_napalm_zombies_loop(spawn_flag)
{
    level endon("end_game");
    level notify("spawn_napalm_zombies_loop");
    level endon("spawn_napalm_zombies_loop");
    
    while (1)
    {
        delay = get_spawn_delay(HRSPAWN_MIN_DELAY_NAPALM, HRSPAWN_MAX_DELAY_NAPALM);

        PRINT_HR_DEBUG("Spawning napalm in " + delay);
        wait delay;

        // Don't use endon because it will bug the entities currently spawning
        if (!flag::get(spawn_flag) || !is_special_spawn_enable())
        {
            PRINT_HR_DEBUG("Spawning napalm ... canceled.");
            return;
        }

        if (GetAiSpeciesArray(level.zombie_team, "all").size >= level.zombie_ai_limit)
        {
            continue;
        }

        ai = zm_ai_napalm::napalm_zombie_spawning();
        if (!isdefined(ai))
        {
            PRINT_HR_DEBUG("Ai napalm was created but is undefined");
            continue;
        }
        ai ai_spawn_callbacks();
    }
}

function private spawn_cellbreakers(spawn_flag)
{
    level endon("end_game");
    level notify("spawn_cellbreakers");
    level endon("spawn_cellbreakers");
    
    level.cellbreakers_killed = 0;
    level.cellbreakers_spawned = 0;
    while (level.cellbreakers_spawned < HRSPAWN_CELLBREAK_VISIT_ROUND_QUANTITY)
    {
        delay = HRSPAWN_CELLBREAK_SPAWN_INTERVAL;

        PRINT_HR_DEBUG("Spawning cellbreaker in " + delay);
        wait delay;

        // Don't use endon because it will bug the entities currently spawning
        if (!flag::get(spawn_flag) || !is_special_spawn_enable())
        {
            PRINT_HR_DEBUG("Spawning cellbreaker ... canceled.");
            return;
        }

        while (GetAiSpeciesArray(level.zombie_team, "all").size >= level.zombie_ai_limit)
        {
            wait 1.0;
        }

        do
        {
            ai = zm_cellbreaker::spawn_brutus();

            if (!isdefined(ai))
            {
                PRINT_HR_DEBUG("Ai cellbreaker was created but is undefined");
                wait 1.0;
            }
        } 
        while (!isdefined(ai));
        level.cellbreakers_spawned++;

        ai ai_spawn_callbacks();
        ai thread cellbreaker_death_count();
    }
}

function private cellbreaker_death_count() // self == ai actor
{
    level endon("end_game");

    self waittill("death");
    level.cellbreakers_killed++;

    if (level.cellbreakers_killed == HRSPAWN_CELLBREAK_VISIT_ROUND_QUANTITY)
    {
        origin = self.origin;
        if (!isdefined(origin))
        {
            PRINT_HR_DEBUG("Ai cellbreaker origin undefined. Spawning bonus nearby white player");
            origin = GetClosestPointOnNavMesh(level.players[0].origin + (250, 0, 0), 25000, 128);
        }

        level thread zm_powerups::specific_powerup_drop(HRSPAWN_CELLBREAK_LAST_KILL_BONUS, origin, undefined, undefined, undefined, undefined, false);
        level notify("cellbreakers_killed");
    }
}

/* endregion */
/* region callbacks */

function add_bad_iteration_callback(func_ptr)
{
    if (IsFunctionPtr(func_ptr))
    {
        level.hellround_spawn_manager.bad_iteration_callbacks[level.hellround_spawn_manager.bad_iteration_callbacks.size] = func_ptr;
    }
}

function private bad_iteration_callbacks()
{
    foreach(callback in level.hellround_spawn_manager.bad_iteration_callbacks)
    {
        level thread [[ callback ]]();
    }
}

function add_ai_spawn_callback(func_ptr)
{
    if (IsFunctionPtr(func_ptr))
    {
        level.hellround_spawn_manager.ai_spawn_callbacks[level.hellround_spawn_manager.ai_spawn_callbacks.size] = func_ptr;
    }
}

function private ai_spawn_callbacks() // self == ai actor
{
    if (!isdefined(self))
    {
        return;
    }

    foreach(callback in level.hellround_spawn_manager.ai_spawn_callbacks)
    {
        self thread [[ callback ]]();
    }
}

function bind_toggle_hellround_callback(func_ptr)
{
    if (IsFunctionPtr(func_ptr))
    {
        level.hellround_spawn_manager.hellround_callback = func_ptr;
    }
}

function private call_toggle_callbacks(b_enabled)
{
    if (isdefined(level.hellround_spawn_manager.hellround_callback))
    {
        [[ level.hellround_spawn_manager.hellround_callback ]](b_enabled);
    }
}

function bind_reward_callback(func_ptr)
{
    if (IsFunctionPtr(func_ptr))
    {
        level.hellround_spawn_manager.reward_callback = func_ptr;
    }
}

function private give_players_bad_iteration_reward()
{
    if (isdefined(level.hellround_spawn_manager.reward_callback))
    {
        [[ level.hellround_spawn_manager.reward_callback ]](undefined);
    }
}

/* endregion */
/* region debug */

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
        
        PRINT_HR_DEBUG("current hellround iteration: " + level.hellround_spawn_manager.current_iteration);

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

/* endregion */
