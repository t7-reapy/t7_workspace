#using scripts\shared\lui_shared; 
#using scripts\codescripts\struct;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\compass;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\_zm_utility.gsh;

// Weapon inspection
#using scripts\lilrobot\_inspectable_weapons;

// Weapon extensions
#using scripts\zm\_hb21_zm_weap_staff_fire;
#using scripts\zm\_hb21_zm_weap_staff_lightning;
#using scripts\zm\_hb21_zm_weap_black_hole_projectile;
#using scripts\zm\_hb21_zm_weap_magmagat;

#using scripts\zm\_load;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_zonemgr;
#using scripts\zm\_zm_equipment;

#using scripts\shared\ai\zombie_utility;

// Custom UI
#using scripts\zm\_zm_h1_hud;
#using scripts\zm\_typewriter;

//Perks
#using scripts\zm\_zm_pack_a_punch;
#using scripts\zm\_zm_pack_a_punch_util;
#using scripts\zm\_zm_perk_additionalprimaryweapon;
#using scripts\zm\_zm_perk_doubletap2;
#using scripts\zm\_zm_perk_deadshot;
#using scripts\zm\_zm_perk_juggernaut;
#using scripts\zm\_zm_perk_quick_revive;
#using scripts\zm\_zm_perk_sleight_of_hand;
#using scripts\zm\_zm_perk_staminup;
#using scripts\zm\_zm_perk_light_fix;

// Harrybo21 additional perks
#using scripts\zm\_zm_perk_widows_wine;
#using scripts\zm\_zm_perk_electric_cherry;
#using scripts\zm\_zm_perk_phdflopper;

// WW2 Pack a punch
#using scripts\zm\_zm_s2_pack_a_punch;

//Powerups
#using scripts\zm\_zm_powerup_double_points;
#using scripts\zm\_zm_powerup_carpenter;
#using scripts\zm\_zm_powerup_fire_sale;
#using scripts\zm\_zm_powerup_free_perk;
#using scripts\zm\_zm_powerup_full_ammo;
#using scripts\zm\_zm_powerup_insta_kill;
#using scripts\zm\_zm_powerup_nuke;
//#using scripts\zm\_zm_powerup_weapon_minigun;

//Traps
#using scripts\zm\_zm_trap_electric;

// Weather
#using scripts\zm\weather\zm_weather;

//Hell rounds
#using scripts\zm\hellround\zm_hellround;

//Room of thanks
#using scripts\zm\room_of_thanks\zm_room_of_thanks;
#using scripts\zm\_auto_closable_door;
#define DELAY_BEFORE_ROT_CALLBACK_APPLY 12.0

// End game camera
#using scripts\zm\_zm_gameover_camera;

#using scripts\zm\zm_usermap;
#using scripts\zm\_zm_animated_switch;

// Player last stand sounds taken from MystifiedTulips scripts
#define PLAYER_DOWNED_SOUND "zc_player_down"
#define PLAYER_REVIVED_SOUND "zc_player_revive"
#define BLEEDOUT_LOOP_SOUND "cw_laststand_loop"
#define PLAYER_NEAR_DEATH_SOUND "zc_player_near_death"

// TODO: remove
// Sphynx's Console Commands
#using scripts\Sphynx\commands\_zm_commands;
#using scripts\Sphynx\commands\_zm_name_checker;

// Custom powerups FX
#define FX_POWERUP_BLUE "_reapy/fx_powerup_blue"
#precache("fx", FX_POWERUP_BLUE);
#precache( "string", "ZOMBIE_POWERUP_NUKE" );

function main()
{
    configure_weapon_inspection();
    bind_hellround_and_weather();
    bind_hellround_meteor_to_enter_room_of_thanks();
    bind_room_of_thanks_callbacks();
    
    zm_usermap::main();
    level thread zm_animated_switch::MasterSwitchInit();
    zm_weather::play();
    
    thread player_knuckle_crack_on_start();
    thread setup_playable_zones();
    thread remove_players_names();
    thread setup_weapons();
    thread setup_players_vox();
    thread watch_power_state();
    thread power_on_sfx_override();
    thread change_powerups_color();
    thread mission_briefing();
    thread prepare_end_game();
    
    callback::on_connect(&disable_hitmarkers);
    callback::on_connect(&notify_ui_for_nuke_powerup);
    callback::on_spawned(&on_player_spawned);
    callback::on_laststand(&onlaststand);
    
    thread end_game();

    level.player_starting_points = 500000;
}

function private end_game()
{
    level waittill("end_game");

    foreach(player in GetPlayers())
    {
        player StopLocalSound(PLAYER_NEAR_DEATH_SOUND);
    }
    
    if (!zm_hellround::is_hellround_running())
    {
        zm_weather::play();
        zm_weather::pause_player_features();
        zm_weather::greater_intensity();
        zm_weather::greater_intensity();
    }
}

function private player_knuckle_crack_on_start()
{
    level flag::wait_till("all_players_connected");
    while (!AreTexturesLoaded())
    {
        WAIT_SERVER_FRAME;
    }
    wait 5.0;

    knuckle_crack_players();
}

function private notify_ui_for_nuke_powerup()
{
    level endon("end_game");

    while(true)
    {
        self waittill("nuke_triggered");
        LUINotifyEvent( &"zombie_notification", 1, &"ZOMBIE_POWERUP_NUKE" );
    }
}

function private knuckle_crack_players()
{
    foreach(player in GetPlayers())
    {
        player thread knuckle_crack();
    }
}

function private knuckle_crack() // self == player
{
    while(self.sessionstate != "playing")
    {
        WAIT_SERVER_FRAME;
    }

    hands = GetWeapon("zombie_knuckle_crack");

    self DisableWeaponCycling();
    self GiveWeapon(hands);
    self SwitchToWeapon(hands);

    wait(2.2);

    self takeWeapon(hands);
    self EnableWeaponCycling();
}

function private watch_power_state()
{
    level.power_on_lightstate = undefined;
    
    level flag::wait_till("power_on");
    
    level.power_on_lightstate = 1;
    zm_weather::update_default_lightstate();
    if (!zm_hellround::is_hellround_running())
    {
        util::set_lighting_state(level.power_on_lightstate);
    }
}

function private power_on_sfx_override()
{
    master_switch = GetEnt("use_master_switch", "targetname");
    master_switch waittill("trigger");
    foreach (player in GetPlayers())
    {
        player PlaySound("power_on_event");
    }
}

function private mission_briefing()
{
    level flag::wait_till("initial_blackscreen_passed");

    // A bit of delay before typing
    wait 5;

    typewriter::type(
        "Date: December 20th, 2025",
        "Location: Grenoble - France",
        "Mission Objective: ^1Survive",
        "Secondary Objective: Turn on power");
}

/* region callbacks */

function private on_player_spawned() // self == player
{
    self thread watch_blastomatic_acquisition();
    self thread on_player_damage();
}

function private watch_blastomatic_acquisition() // self == player
{
    level endon("end_game");
    self endon("disconnect");
    self endon("bled_out");

    while(true)
    {
        self waittill("weapon_give", weapon);

        if(weapon.name == "t9_semiauto_cosplay")
        {
            PlaySoundAtPosition("mus_raygun_stinger", (0, 0, 0));
        }
    }
}

function private on_player_damage() // self == player
{
    level endon("end_game");
    self endon("disconnect");
    self endon("spawned_player");

    while(isdefined(self))
    {
        self util::waittill_any("damage", "death", "bled_out");

        if(!isdefined(self))
        {
            return;
        }

        if (IsPlayer(self) && IsAlive(self) && self.health <= 30)
        {
            self PlayLocalSound(PLAYER_NEAR_DEATH_SOUND);
            while(self.health <= 30 && IsAlive(self) && !self laststand::player_is_in_laststand())
            {
                ScreenShake(self.origin, 3, 3, 3, 2, 1, 1, 25000, 1, 1, 1, 1, self);
                wait 1.0;
            }
        }
    }
}

function private onlaststand() //callback on player laststand
{
    level endon("end_game");
    self endon("death");
    self endon("bled_out");
    self endon("disconnect");
    
    self StopLocalSound(PLAYER_NEAR_DEATH_SOUND);
    self PlayLocalSound(PLAYER_DOWNED_SOUND);
    self thread play_bleedout_sound();
    self waittill("player_revived");
    self StopSound(BLEEDOUT_LOOP_SOUND);
    self PlayLocalSound(PLAYER_REVIVED_SOUND);
}

function private prepare_end_game()
{
    level.custom_game_over_hud_elem_color_function = &zm_hellround::get_ending_associated_color;
}

function private play_bleedout_sound()
{
    level endon("end_game");
    self endon("death");
    self endon("bled_out");
    self endon("disconnect");

    // We need to a bit for self.laststand to be updated.
    wait 0.5;
    
    //check if bleedout_loop_sound exists to advoid a potential fast loop.
    while(self laststand::player_is_in_laststand() && isdefined(BLEEDOUT_LOOP_SOUND) && SoundExists(BLEEDOUT_LOOP_SOUND))
    {
        self PlaySoundWithNotify(BLEEDOUT_LOOP_SOUND, "bleedout_sound");
        self waittill("bleedout_sound");
        WAIT_SERVER_FRAME;                                 
    }
}

function private bind_hellround_and_weather()
{
    zm_hellround::add_toggle_callback(&toggle_weather);
}

function private toggle_weather(b_enable_hellround)
{
    if (IS_TRUE(b_enable_hellround))
    {
        zm_weather::pause();
    }
    else
    {
        zm_weather::play();
    }
}

function private bind_hellround_meteor_to_enter_room_of_thanks()
{
    zm_hellround::add_meteor_trigger_callback(&zm_room_of_thanks::teleport_players_and_start_elevator);
    zm_hellround::add_meteor_trigger_callback(&pause_game);
    zm_hellround::add_meteor_trigger_callback(&clear_zombies);
    zm_hellround::add_meteor_trigger_callback(&stop_round_sounds);
}

function private pause_game()
{
    level flag::set("world_is_paused");
    level waittill("between_round_over");
    SetRoundsPlayed(0);
}

function private clear_zombies()
{
    wait 0.2; // Give a bit of time.
    zombies = GetAiTeamArray(level.zombie_team);
    array::thread_all(zombies, &kill_zombie);
}

function private kill_zombie()
{
    if (isdefined(self) && IsActor(self))
    {
        self Kill();
    }
}

function private stop_round_sounds()
{
    // It's certainly a hard way of doing it, but unfortunatelly I didn't find an easier way.
    // And we don't want to restore it afterwards. 
    level.musicSystem.states["round_start"].musArray = [];
    level.musicSystem.states["round_start_short"].musArray = [];
    level.musicSystem.states["round_start_first"].musArray = [];
    level.musicSystem.states["round_end"].musArray = [];
}

function private bind_room_of_thanks_callbacks()
{
    // Enter room of thanks
    zm_room_of_thanks::add_enter_room_of_thanks_callback(&weather_pause_with_delay);
    zm_room_of_thanks::add_enter_room_of_thanks_callback(&set_lighting_state_clear);
    zm_room_of_thanks::add_enter_room_of_thanks_callback(&remove_ui);
    zm_room_of_thanks::add_enter_room_of_thanks_callback(&player_invulnerability);
    zm_room_of_thanks::add_enter_room_of_thanks_callback(&change_player_skins);
    zm_room_of_thanks::add_enter_room_of_thanks_callback(&type_room_of_thanks_briefing);

    // Exit room of thanks
    zm_room_of_thanks::add_exit_room_of_thanks_callback(&knuckle_crack_players);
    zm_room_of_thanks::add_exit_room_of_thanks_callback(&transition_screen);
    zm_room_of_thanks::add_exit_room_of_thanks_callback(&set_lighting_state_normal);
    zm_room_of_thanks::add_exit_room_of_thanks_callback(&restore_ui);
    zm_room_of_thanks::add_exit_room_of_thanks_callback(&end_the_game);
}

function private set_lighting_state_clear()
{
    util::set_lighting_state(2);
}

function private set_lighting_state_normal()
{
    wait DELAY_BEFORE_ROT_CALLBACK_APPLY;
    util::set_lighting_state(VAL(level.power_on_lightstate, 0));
}

function private remove_ui()
{
    foreach(player in GetPlayers())
    {
        player setClientUIVisibilityFlag("weapon_hud_visible", 0);
    }
}

function private restore_ui()
{
    wait DELAY_BEFORE_ROT_CALLBACK_APPLY;
    foreach(player in GetPlayers())
    {
        player setClientUIVisibilityFlag("weapon_hud_visible", 1);
    }
}

function private player_invulnerability()
{
    foreach(player in GetPlayers())
    {
        player EnableInvulnerability();
    }
}

function private change_player_skins()
{
    foreach (player in GetPlayers())
    {
        // Here index 2 is for DevRaw skins
        player SetCharacterBodyStyle(2);
    }
}

function private type_room_of_thanks_briefing()
{
    typewriter::type(
        "Date: ?? ??, ????",
        "Location: ?? - ??",
        "Mission Objective: Find an exit",
        "Secondary Objective: Check the area");
}

function private transition_screen()
{
    screen_flash_fadein = 3.0;
    wait DELAY_BEFORE_ROT_CALLBACK_APPLY - screen_flash_fadein;
    self thread lui::screen_flash(screen_flash_fadein, 5.0, 0.0, 1, "black");
}

function private weather_pause_with_delay()
{
    // It seems that pausing the weather on same server frame as other stuff 
    // creates a weird issue and don't really pause some weather features...
    wait 2;
    zm_weather::pause();
}

function private end_the_game()
{
    wait DELAY_BEFORE_ROT_CALLBACK_APPLY;
    level notify("end_game");
}

/* endregion */
/* region weapons */

function private custom_add_weapons()
{
    zm_weapons::load_weapon_spec_from_table("gamedata/weapons/zm/zm_test_weapons.csv", 1);
}

function private setup_weapons()
{
    // PaP Camo
    level.pack_a_punch_camo_index = 2;
    level.pack_a_punch_camo_index_number_variants = 2;

    level._zombie_custom_add_weapons = &custom_add_weapons;

    // Use CW M1911 as start and laststand pistol
    level.start_weapon = GetWeapon("t9_1911");
    level.laststandpistol = level.start_weapon;
    level.default_laststandpistol = level.start_weapon;
    level.pistol_values[0] = level.default_laststandpistol;

    // For solo games
    level.default_solo_laststandpistol = GetWeapon("t9_1911_rdw_up");
    level.pistol_values[3] = level.default_solo_laststandpistol;

    // Override default melee weapon
    zm_utility::register_melee_weapon_for_level("t8_knife");
    level.weaponbasemelee = getweapon("t8_knife");
}

function private configure_weapon_inspection()
{
    // T9
    inspectable::add_inspectable_weapon(GetWeapon("t9_me_knife_russian"), 4.18);
    inspectable::add_inspectable_weapon(GetWeapon("t9_me_knife_russian_up"), 4.18);
    inspectable::add_inspectable_weapon(GetWeapon("t9_me_knife_russian_up_up"), 4.18);
    
    inspectable::add_inspectable_weapon(GetWeapon("t9_1911"), 3.33);
    inspectable::add_inspectable_weapon(GetWeapon("t9_1911_rdw_up"), 5);
    inspectable::add_inspectable_weapon(GetWeapon("t9_1911_ldw_up"), 5);
    inspectable::add_inspectable_weapon(GetWeapon("t9_1911_rdw_up_up"), 5);
    inspectable::add_inspectable_weapon(GetWeapon("t9_1911_ldw_up_up"), 5);

    inspectable::add_inspectable_weapon(GetWeapon("t9_diamatti"), 6.23);
    inspectable::add_inspectable_weapon(GetWeapon("t9_diamatti_up"), 6.23);
    inspectable::add_inspectable_weapon(GetWeapon("t9_diamatti_up_up"), 6.23);

    inspectable::add_inspectable_weapon(GetWeapon("t9_rpk"), 5.83);
    inspectable::add_inspectable_weapon(GetWeapon("t9_rpk_up"), 5.83);
    inspectable::add_inspectable_weapon(GetWeapon("t9_rpk_up_up"), 5.83);

    inspectable::add_inspectable_weapon(GetWeapon("t9_ffar1"), 4.83);
    inspectable::add_inspectable_weapon(GetWeapon("t9_ffar1_up"), 4.83);
    inspectable::add_inspectable_weapon(GetWeapon("t9_ffar1_up_up"), 4.83);
    
    inspectable::add_inspectable_weapon(GetWeapon("t9_groza"), 6.13);
    inspectable::add_inspectable_weapon(GetWeapon("t9_groza_up"), 6.13);
    inspectable::add_inspectable_weapon(GetWeapon("t9_groza_up_up"), 6.13);

    inspectable::add_inspectable_weapon(GetWeapon("t9_m60"), 10);
    inspectable::add_inspectable_weapon(GetWeapon("t9_m60_up"), 10);
    inspectable::add_inspectable_weapon(GetWeapon("t9_m60_up_up"), 10);

    inspectable::add_inspectable_weapon(GetWeapon("t9_streetsweeper"), 5.6);
    inspectable::add_inspectable_weapon(GetWeapon("t9_streetsweeper_up"), 5.6);
    inspectable::add_inspectable_weapon(GetWeapon("t9_streetsweeper_up_up"), 5.6);

    inspectable::add_inspectable_weapon(GetWeapon("t9_semiauto_cosplay"), 4.33);
    inspectable::add_inspectable_weapon(GetWeapon("t9_semiauto_cosplay_up"), 4.33);
    inspectable::add_inspectable_weapon(GetWeapon("t9_semiauto_cosplay_up_up"), 4.33);

    // IW8
    inspectable::add_inspectable_weapon(GetWeapon("iw8_asval"), 5.76);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_asval_up"), 5.76);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_asval_up_up"), 5.76);
    
    inspectable::add_inspectable_weapon(GetWeapon("iw8_50gs"), 4.66);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_50gs_rdw_up"), 4.66);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_50gs_ldw_up"), 4.66);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_50gs_rdw_up_up"), 4.66);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_50gs_ldw_up_up"), 4.66);

    inspectable::add_inspectable_weapon(GetWeapon("shredder_rdw_up_up"), 4.66);
    inspectable::add_inspectable_weapon(GetWeapon("shredder_ldw_up_up"), 4.66);

    inspectable::add_inspectable_weapon(GetWeapon("iw8_ak47"), 5.13);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_ak47_up"), 5.13);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_ak47_up_up"), 5.13);
    
    inspectable::add_inspectable_weapon(GetWeapon("iw8_iso"), 5.13);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_iso_up"), 5.13);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_iso_up_up"), 5.13);
        
    inspectable::add_inspectable_weapon(GetWeapon("iw8_m4a1"), 5.13);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_m4a1_up"), 5.13);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_m4a1_up_up"), 5.13);

    inspectable::add_inspectable_weapon(GetWeapon("iw8_minigun"), 5.26);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_minigun_up"), 5.26);
    
    inspectable::add_inspectable_weapon(GetWeapon("iw8_spr208_irons"), 5.26);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_spr208_irons_up"), 5.26);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_spr208_irons_up_up"), 5.26);

    inspectable::add_inspectable_weapon(GetWeapon("iw8_vlkrogue"), 5.33);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_vlkrogue_up"), 5.33);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_vlkrogue_up_up"), 5.33);
    
    inspectable::add_inspectable_weapon(GetWeapon("iw8_mp5k"), 5.16);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_mp5sd_up"), 5.16);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_mp5sd_up_up"), 5.16);
    
    inspectable::add_inspectable_weapon(GetWeapon("iw8_model680"), 5.16);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_model680_up"), 5.16);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_model680_up_up"), 5.16);

    // SW2
    inspectable::add_inspectable_weapon(GetWeapon("s2_vmg1927"), 5);
    inspectable::add_inspectable_weapon(GetWeapon("s2_vmg1927_up"), 5);
    inspectable::add_inspectable_weapon(GetWeapon("s2_vmg1927_up_up"), 5);
}

/* endregion */
/* region zones */

function private setup_playable_zones()
{
    //Setup the levels Zombie Zone Volumes
    level.zones = [];
    level.zone_manager_init_func = &add_adjacent_zones;
    init_zones[0] = "start_zone";
    init_zones[1] = "thanks_zone";
    level thread zm_zonemgr::manage_zones(init_zones);

    // Must be defined for AI pathing
    level.pathdist_type = PATHDIST_ORIGINAL;
}

function private add_adjacent_zones()
{
    zm_zonemgr::add_adjacent_zone("start_zone", "second_zone", "enter_second_zone");
    zm_zonemgr::add_adjacent_zone("second_zone", "third_zone", "enter_third_zone");
    zm_zonemgr::add_adjacent_zone("third_zone", "fourth_zone", "enter_fourth_zone");
} 

/* endregion */
/* region tweakings */

function private remove_players_names()
{
    SetDvar("cg_disableplayernames", "1");
}

function private disable_hitmarkers() // self == player
{
    while(!isdefined(self.hud_damagefeedback) && !isdefined(self.hud_damagefeedback_additional))
    {
        WAIT_SERVER_FRAME;
    }

    self.hud_damagefeedback Destroy();
    self.hud_damagefeedback_additional Destroy();
}

function private setup_players_vox()
{
    zm_audio::loadPlayerVoiceCategories("gamedata/audio/zm/zm_usmc_vox.csv");
}

function private change_powerups_color()
{
    level._effect["powerup_on"] = FX_POWERUP_BLUE;
    level._effect["powerup_grabbed"] = "zombie/fx_powerup_grab_solo_zmb";
}

/* endregion */

