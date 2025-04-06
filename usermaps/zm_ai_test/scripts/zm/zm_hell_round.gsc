#using scripts\zm\_util;
#using scripts\zm\_zm_utility;
#using scripts\shared\flag_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

// AIs involved in hell rounds
#using scripts\shared\ai\zombie_utility;
#using scripts\zm\_zm_ai_dogs;
#using scripts\zm\zm_genesis_apothicon_fury;
#define APOTHICAN_FURY_DEBUG 0                   // Force disabling fury debug to not have it when not wanted
#define APOTHICAN_FURY_USE_SPECIAL_FURY_ROUNDS 0 // Force disabling fury rounds to have them when wanted

#define HELL_ROUND_TRIGGER_FLAG "power_on"
#define HELL_ROUND_FLAG "hell_round"
#define KILL_HELL_ROUND_WATCHERS_NOTIFICATION "kill_hell_round_watchers"

#namespace zm_hell_round;

REGISTER_SYSTEM_EX("zm_hell_round", &init, &main, undefined)

function init()
{
    // Init custom flags
    level flag::init(HELL_ROUND_FLAG);

    level.hell_rounds_abolished = false;
}

function main()
{
    // First, disable all custom rounds (can be repetitive with above defines ...)
    level.dog_rounds_allowed = 0;
    level.apothicon_fury_rounds_enabled = 0;

    level.initial_zombie_ai_limit = level.zombie_ai_limit;
    level.initial_zombie_actor_limit = level.zombie_actor_limit;

    level thread power_state_watcher();
    level thread hell_round_watcher();
    level thread hell_round_killer_watcher();
}

// self = level
function hell_round_plays()
{
    self.zombie_ai_limit = 120;
    self.zombie_actor_limit = 127;

    self thread spawn_dogs_loop();
    self thread spawn_apothicon_furies_loop();
}

// self = level
function hell_round_ends()
{
    // Custom logic goes here.
    IPrintLnBold("Hell round ending...");

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
        if (shouldAbolishHellRounds())
        {
            self flag::clear(HELL_ROUND_FLAG);
            self notify(KILL_HELL_ROUND_WATCHERS_NOTIFICATION);
        }
        WAIT_SERVER_FRAME;
    }
}

function private shouldAbolishHellRounds()
{
    return !level.hell_rounds_abolished;
}

function spawn_dogs_loop()
{
    while (1)
    {
        wait randomIntRange(1, 4);

        custom_special_dog_spawn();

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
        wait randomIntRange(1, 4);

        zm_genesis_apothicon_fury::apothicon_fury_spawn_on_location();

        // Don't use endon because it will bug the entities currently spawning
        if (!flag::get(HELL_ROUND_FLAG))
        {
            return;
        }
    }
}

function custom_special_dog_spawn()
{    
    players = GetPlayers();
    favorite_enemy = zm_ai_dogs::get_favorite_enemy();

    spawn_point = zm_ai_dogs::dog_spawn_factory_logic(favorite_enemy);
    ai = zombie_utility::spawn_zombie(level.dog_spawners[0]);

    if (isdefined(ai))
    {
        ai.favoriteenemy = favorite_enemy;
        spawn_point thread zm_ai_dogs::dog_spawn_fx(ai, spawn_point);
        level flag::set("dog_clips");
    }    
}