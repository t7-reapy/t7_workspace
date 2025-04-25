#using scripts\zm\_util;
#using scripts\zm\_zm_utility;

#using scripts\shared\array_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

// Involved in Hell rounds
#using scripts\zm\_hb21_zm_behavior;
#using scripts\zm\_zm_bloodsplatter;
#using scripts\zm\zm_bloody_environment;
#using scripts\zm\zm_wolf_soul_collectors;

// AIs involved in hell rounds
#using scripts\shared\ai\zombie_utility;
#using scripts\zm\_zm_ai_dogs;
#using scripts\zm\_zm_ai_wasp;
#using scripts\zm\_zm_ai_napalm;
#using scripts\zm\zm_genesis_apothicon_fury;
#define APOTHICAN_FURY_DEBUG 0                   // Force disabling fury debug to not have it when not wanted
#define APOTHICAN_FURY_USE_SPECIAL_FURY_ROUNDS 0 // Force disabling fury rounds to have them when wanted

#insert scripts\zm\zm_hell_round.gsh;

#namespace zm_hell_round;
REGISTER_SYSTEM_EX("zm_hell_round", &init, &main, undefined)

function void(){}

function init()
{
    // First, disable all custom rounds (can be repetitive with above defines ...)
    level.dog_rounds_allowed = 0;
    level.apothicon_fury_rounds_enabled = 0;
    level.apothicon_fury_round_track_override = &void;

    // Blood splatter happens only during hell rounds enabled
    level.bloodsplatter_disabled = true;

    // Init custom flags
    level flag::init(HELL_ROUND_FLAG);

    level.hell_rounds_abolished = false;
    level.hell_rounds_begin_callbacks = [];
    level.hell_rounds_end_callbacks = [];
    configure_callbacks();

    // Some AI needs to be initiated explicitly
    zm_ai_wasp::init();
}

function main()
{
    level.initial_zombie_ai_limit = level.zombie_ai_limit;
    level.initial_zombie_actor_limit = level.zombie_actor_limit;

    level thread power_state_watcher();
    level thread hell_round_watcher();
    level thread hell_round_minor_watcher();
    level thread hell_round_killer_watcher();
}

function configure_callbacks()
{
    level.hell_round_begin_callback_called = false;

    add_begin_callback(&zm_bloody_environment::toggle_bloody_environment);
    add_end_callback(&zm_bloody_environment::toggle_bloody_environment);

    add_begin_callback(&zm_bloodsplatter::toggle_blood_splatter);
    add_end_callback(&zm_bloodsplatter::toggle_blood_splatter);

    // If the cerberus is fed, we should abolish the hellround
    level.soul_catchers_charged_callback = &abolish_hell_rounds;
    // Enable "minor" hellround during cerberus feeding time
    level.wolf_heads_become_active_callback = &hell_round_minor_begin_request;
    level.wolf_heads_become_inactive_callback = &hell_round_minor_end_request;
}

function add_begin_callback(func) {
    if (IsFunctionPtr(func)) {
        array::add(level.hell_rounds_begin_callbacks, func);
    }
}

function add_end_callback(func) {
    if (IsFunctionPtr(func)) {
        array::add(level.hell_rounds_end_callbacks, func);
    }
}

function call_begin_callbacks()
{
    // If end callback not yet called, don't do anything
    if (level.hell_round_begin_callback_called) {
        return;
    }
    level.hell_round_begin_callback_called = true;

    for (i = 0; i < level.hell_rounds_begin_callbacks.size; i++)
    {
        level thread [[ level.hell_rounds_begin_callbacks[i] ]]();
    }
}

function call_end_callbacks()
{
    hellround_running = flag::get(HELL_ROUND_FLAG) || flag::get(HELL_ROUND_MINOR_FLAG);
    if (!level.hell_round_begin_callback_called || hellround_running) {
        return;
    }
    level.hell_round_begin_callback_called = false;

    for (i = 0; i < level.hell_rounds_end_callbacks.size; i++)
    {
        level thread [[ level.hell_rounds_end_callbacks[i] ]]();
    }
}

function abolish_hell_rounds()
{
    PRINT_DEBUG_HR("Abolishing hellrounds ...");
    level.hell_rounds_abolished = true;
    // Used to notify hell_round_killer_watcher()
    level notify(HELL_ROUND_ABOLISHED_FLAG);
}

// self = level
function hell_round_plays()
{
    call_begin_callbacks();
    
    // Based on initial values, no real justification here.
    self.zombie_ai_limit = 120;
    self.zombie_actor_limit = 127;

    // TODO : add some custom fx for round start like the following one ?
    // zm_ai_wasp::parasite_round_fx();
    // TODO: clear old zombies
    // TODO: disable round logic
    // TODO: give DEATHMACHINE!!!
    self thread spawn_dogs_loop(HELL_ROUND_FLAG);
    self thread spawn_apothicon_furies_loop(HELL_ROUND_FLAG);
    self thread spawn_wasps_loop(HELL_ROUND_FLAG);
    self thread spawn_napalm_zombies_loop(HELL_ROUND_FLAG);
    // TODO: add infinite running zombies (with different model than original)
}

// self = level
function hell_round_ends()
{
    call_end_callbacks();

    self.zombie_ai_limit = self.initial_zombie_ai_limit;
    self.zombie_actor_limit = self.initial_zombie_actor_limit;
}

// self = level
function hell_round_minor_plays()
{
    call_begin_callbacks();
    
    // Based on initial values, no real justification here.
    self.zombie_ai_limit = 120;
    self.zombie_actor_limit = 127;

    // TODO : add some custom fx for round start like the following one ?
    // zm_ai_wasp::parasite_round_fx();
    // TODO: clear old zombies
    // TODO: disable round logic
    // TODO: give blundergate
    // self thread spawn_dogs_loop(HELL_ROUND_MINOR_FLAG);
    // self thread spawn_apothicon_furies_loop(HELL_ROUND_MINOR_FLAG);
    self thread spawn_wasps_loop(HELL_ROUND_MINOR_FLAG);
    // self thread spawn_napalm_zombies_loop(HELL_ROUND_MINOR_FLAG);
    // TODO: add infinite running zombies (with different model than original)
}

// self = level
function hell_round_minor_ends()
{
    call_end_callbacks();

    self.zombie_ai_limit = self.initial_zombie_ai_limit;
    self.zombie_actor_limit = self.initial_zombie_actor_limit;
}

// self = level
function power_state_watcher()
{
    self endon(KILL_HELL_ROUND_WATCHERS_NOTIFICATION);

    while (1)
    {
        self flag::wait_till(HELL_ROUND_TRIGGER_FLAG);
        self flag::set(HELL_ROUND_FLAG);

        self flag::wait_till_clear(HELL_ROUND_TRIGGER_FLAG);
        self flag::clear(HELL_ROUND_FLAG);

        WAIT_SERVER_FRAME;
    }
}

// self = level
function hell_round_watcher()
{
    self endon(KILL_HELL_ROUND_WATCHERS_NOTIFICATION);

    while (1)
    {
        self flag::wait_till(HELL_ROUND_FLAG);
        // Hell round overwrites minor one with wolfheads
        self thread zm_wolf_soul_collectors::force_completion(); //abolish_wolf_heads();
        self flag::clear(HELL_ROUND_MINOR_FLAG);
        self hell_round_plays();

        self flag::wait_till_clear(HELL_ROUND_FLAG);
        self thread zm_wolf_soul_collectors::force_completion();
        self hell_round_ends();

        WAIT_SERVER_FRAME;
    }
}

function hell_round_minor_begin_request()
{
    level flag::set(HELL_ROUND_MINOR_FLAG);
}

function hell_round_minor_end_request()
{
    level flag::clear(HELL_ROUND_MINOR_FLAG);
}

// self = level
function hell_round_minor_watcher()
{
    self endon(KILL_HELL_ROUND_WATCHERS_NOTIFICATION);

    while (1)
    {
        self flag::wait_till(HELL_ROUND_MINOR_FLAG);
        PRINT_DEBUG_HR("Hellround minor's flag raised");
        self hell_round_minor_plays();

        self flag::wait_till_clear(HELL_ROUND_MINOR_FLAG);
        PRINT_DEBUG_HR("Hellround minor's flag lowered");
        self hell_round_minor_ends();

        WAIT_SERVER_FRAME;
    }
}

// self = level
function hell_round_killer_watcher()
{
    self waittill(HELL_ROUND_ABOLISHED_FLAG);
    PRINT_DEBUG_HR("Stopping/Killing hellrounds ...");

    // Kill other watchers first
    self notify(KILL_HELL_ROUND_WATCHERS_NOTIFICATION);

    // If hellround currently running, end it
    if (self flag::get(HELL_ROUND_FLAG)) {
        self flag::clear(HELL_ROUND_FLAG);
        self hell_round_ends();
    }

    if (self flag::get(HELL_ROUND_MINOR_FLAG)) {
        self flag::clear(HELL_ROUND_MINOR_FLAG);
        self hell_round_minor_ends();
    }
}

function spawn_dogs_loop(flag_str)
{
    while (1)
    {
        wait randomIntRange(4, 8);
        PRINT_DEBUG_HR("Spawning wolf ...");

        // Don't use endon because it will bug the entities currently spawning
        if (!flag::get(flag_str))
        {
            PRINT_DEBUG_HR("Spawning wolf ... canceled.");
            return;
        }

        ai = zm_ai_dogs::custom_special_dog_spawn();
        ai thread zm_bloodsplatter::watch_actor();
    }
}

function spawn_apothicon_furies_loop(flag_str)
{
    while (1)
    {
        wait randomIntRange(4, 8);
        PRINT_DEBUG_HR("Spawning apothicon ...");

        // Don't use endon because it will bug the entities currently spawning
        if (!flag::get(flag_str))
        {
            PRINT_DEBUG_HR("Spawning apothicon ... canceled.");
            return;
        }

        ai = zm_genesis_apothicon_fury::apothicon_fury_spawn_on_location();
        ai thread zm_bloodsplatter::watch_actor();
    }
}

function spawn_wasps_loop(flag_str)
{
    while (1)
    {
        wait randomIntRange(8, 16);
        PRINT_DEBUG_HR("Spawning wasp ...");

        // Don't use endon because it will bug the entities currently spawning
        if (!flag::get(flag_str))
        {
            PRINT_DEBUG_HR("Spawning wasp ... canceled.");
            return;
        }

        ai = zm_ai_wasp::special_wasp_spawn();
        ai thread zm_bloodsplatter::watch_actor();
    }
}

function spawn_napalm_zombies_loop(flag_str)
{
    while (1)
    {
        wait 30;
        PRINT_DEBUG_HR("Spawning napalm ...");

        // Don't use endon because it will bug the entities currently spawning
        if (!flag::get(flag_str))
        {
            PRINT_DEBUG_HR("Spawning napalm ... canceled.");
            return;
        }

        ai = zm_ai_napalm::napalm_zombie_spawning();
        ai thread zm_bloodsplatter::watch_actor();
    }
}
