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
#using scripts\zm\zm_wolf_soul_colletors;

// AIs involved in hell rounds
#using scripts\shared\ai\zombie_utility;
#using scripts\zm\_zm_ai_dogs;
#using scripts\zm\_zm_ai_wasp;
#using scripts\zm\_zm_ai_napalm;
#using scripts\zm\zm_genesis_apothicon_fury;
#define APOTHICAN_FURY_DEBUG 0                   // Force disabling fury debug to not have it when not wanted
#define APOTHICAN_FURY_USE_SPECIAL_FURY_ROUNDS 0 // Force disabling fury rounds to have them when wanted

#define HELL_ROUND_TRIGGER_FLAG "power_on"
#define HELL_ROUND_FLAG "hell_round"
#define KILL_HELL_ROUND_WATCHERS_NOTIFICATION "kill_hell_round_watchers"

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

    // Some AI needs to be initiated explicitly
    zm_ai_wasp::init();
}

function main()
{
    configure_hellrounds_callbacks();

    level.initial_zombie_ai_limit = level.zombie_ai_limit;
    level.initial_zombie_actor_limit = level.zombie_actor_limit;

    level thread power_state_watcher();
    level thread hell_round_watcher();
    level thread hell_round_killer_watcher();
}

function configure_hellrounds_callbacks()
{
    add_begin_callback(&zm_bloody_environment::toggle_bloody_environment);
    add_end_callback(&zm_bloody_environment::toggle_bloody_environment);

    add_begin_callback(&zm_bloodsplatter::toggle_blood_splatter);
    add_end_callback(&zm_bloodsplatter::toggle_blood_splatter);
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

// self = level
function hell_round_plays()
{
    for (i = 0; i < self.hell_rounds_begin_callbacks.size; i++)
    {
        self thread [[ self.hell_rounds_begin_callbacks[i] ]]();
    }
    
    self.zombie_ai_limit = 120;
    self.zombie_actor_limit = 127;

    // TODO : add some custom fx for round start like the following one ?
    // zm_ai_wasp::parasite_round_fx();
    self thread spawn_dogs_loop();
    self thread spawn_apothicon_furies_loop();
    self thread spawn_wasps_loop();
    self thread spawn_napalm_zombies_loop();
}

// self = level
function hell_round_ends()
{
    for (i = 0; i < self.hell_rounds_end_callbacks.size; i++)
    {
        self thread [[ self.hell_rounds_end_callbacks[i] ]]();
    }

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
        self hell_round_plays();

        self flag::wait_till_clear(HELL_ROUND_FLAG);
        self hell_round_ends();

        WAIT_SERVER_FRAME;
    }
}

function hell_round_killer_watcher()
{
    while (1)
    {
        if (level.hell_rounds_abolished)
        {
            self flag::clear(HELL_ROUND_FLAG);
            self notify(KILL_HELL_ROUND_WATCHERS_NOTIFICATION);
        }
        WAIT_SERVER_FRAME;
    }
}

function spawn_dogs_loop()
{
    while (1)
    {
        wait randomIntRange(4, 8);

        ai = zm_ai_dogs::custom_special_dog_spawn();
        ai thread zm_bloodsplatter::watch_actor();

        // Don't use endon because it will bug the entities currently spawning
        if (!flag::get(HELL_ROUND_FLAG))
        {
            return;
        }
    }
}

function spawn_apothicon_furies_loop()
{
    while (1)
    {
        wait randomIntRange(4, 8);

        ai = zm_genesis_apothicon_fury::apothicon_fury_spawn_on_location();
        ai thread zm_bloodsplatter::watch_actor();

        // Don't use endon because it will bug the entities currently spawning
        if (!flag::get(HELL_ROUND_FLAG))
        {
            return;
        }
    }
}

function spawn_wasps_loop()
{
    while (1)
    {
        wait randomIntRange(8, 16);

        ai = zm_ai_wasp::special_wasp_spawn();
        ai thread zm_bloodsplatter::watch_actor();

        // Don't use endon because it will bug the entities currently spawning
        if (!flag::get(HELL_ROUND_FLAG))
        {
            return;
        }
    }
}

function spawn_napalm_zombies_loop()
{
    while (1)
    {
        wait 30;

        ai = zm_ai_napalm::napalm_zombie_spawning();
        ai thread zm_bloodsplatter::watch_actor();

        // Don't use endon because it will bug the entities currently spawning
        if (!flag::get(HELL_ROUND_FLAG))
        {
            return;
        }
    }
}
