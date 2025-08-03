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
#using scripts\zm\hellround\zm_hellround_shared;
#using scripts\zm\hellround\zm_hellround_collectors;
#using scripts\zm\hellround\zm_hellround_environment;
#using scripts\zm\hellround\zm_hellround_music;
#using scripts\zm\hellround\zm_hellround_players;
#using scripts\zm\hellround\zm_hellround_powerup;
#using scripts\zm\hellround\zm_hellround_reward;
#using scripts\zm\hellround\zm_hellround_spawn_manager;
#using scripts\zm\hellround\zm_hellround_zombies;

// AIs involved in hell rounds
#using scripts\shared\ai\zombie_utility;
#using scripts\zm\_zm_ai_dogs;
#using scripts\zm\_zm_ai_wasp;
#using scripts\zm\_zm_ai_napalm;
#using scripts\zm\zm_genesis_apothicon_fury;

#insert scripts\zm\hellround\zm_hellround_shared.gsh;
#insert scripts\zm\hellround\zm_hellround.gsh;

#namespace zm_hellround;
REGISTER_SYSTEM_EX("zm_hellround", &init, &main, undefined)

class hellround
{
    var abolished; // TODO: still needed?

    // Callbacks for hellrounds
    var toggle_callbacks;
}

function private init()
{
    // Blood splatter happens only during hellrounds
    level.bloodsplatter_disabled = true;

    level.hellround = new hellround();
    level.hellround.abolished = false;
    level.hellround.toggle_callbacks = [];
    level.hellround.end_callbacks = [];

    // Init custom flags
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
}

// #region callbacks

function add_toggle_callback(func) {
    if (IsFunctionPtr(func)) {
        array::add(level.hellround.toggle_callbacks, func);
    }
}

function private bind_callbacks()
{
    add_toggle_callback(&zm_hellround_zombies::toggle_hellround_zombies);
    add_toggle_callback(&zm_hellround_players::toggle_hellround_for_players);
    add_toggle_callback(&zm_hellround_environment::toggle_hellround_environment);
    add_toggle_callback(&zm_bloodsplatter::toggle_blood_splatter);

    // TODO : add some custom fx for hellround start like the following one ?
    // zm_ai_wasp::parasite_round_fx();

    level.wolf_heads_become_active_callback = &hellround_cerberus_enable;
    level.wolf_heads_become_inactive_callback = &hellround_cerberus_disable;
    level.soul_catchers_charged_callback = &hellround_cerberus_fed;
}

function private hellround_cerberus_enable()
{
    thread zm_hellround_spawn_manager::hellround_starts();
}

function private hellround_cerberus_disable()
{
    thread zm_hellround_spawn_manager::hellround_stops();
}

function private hellround_cerberus_fed()
{
    // TODO : reward management
    thread zm_hellround_reward::give_reward();
}

// #endregion callbacks
