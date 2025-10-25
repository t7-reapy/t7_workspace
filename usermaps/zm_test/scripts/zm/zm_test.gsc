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

#using scripts\zm\_load;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_zonemgr;
#using scripts\zm\_zm_equipment;

#using scripts\shared\ai\zombie_utility;

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

//Powerups
#using scripts\zm\_zm_powerup_double_points;
#using scripts\zm\_zm_powerup_carpenter;
#using scripts\zm\_zm_powerup_fire_sale;
#using scripts\zm\_zm_powerup_free_perk;
#using scripts\zm\_zm_powerup_full_ammo;
#using scripts\zm\_zm_powerup_insta_kill;
#using scripts\zm\_zm_powerup_nuke;
//#using scripts\zm\_zm_powerup_weapon_minigun;

// CNG
#using scripts\zm\_hb21_madgaz_zm_weap_cng;

//Traps
#using scripts\zm\_zm_trap_electric;

// Weather
#using scripts\zm\weather\zm_weather;

//Hell rounds
#using scripts\zm\hellround\zm_hellround;

//Room of thanks
#using scripts\zm\room_of_thanks\zm_room_of_thanks;

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

function main()
{
    configure_weapon_inspection();
    bind_hellround_and_weather();
    
    zm_usermap::main();
    level thread zm_animated_switch::MasterSwitchInit();
    zm_weather::play();
    
    thread setup_playable_zones();
    thread remove_players_names();
    thread setup_weapons();
    thread setup_players_vox();
    thread watch_power_state();
    thread change_powerups_color();
    
    callback::on_connect(&disable_hitmarkers);
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

function private custom_add_weapons()
{
    zm_weapons::load_weapon_spec_from_table("gamedata/weapons/zm/zm_test_weapons.csv", 1);
}

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

function private remove_players_names()
{
    SetDvar("cg_disableplayernames", "1");
}

function private setup_weapons()
{
    // PaP Camo
    level.pack_a_punch_camo_index = 3;
    level.pack_a_punch_camo_index_number_variants = 34;

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

function private setup_players_vox()
{
    zm_audio::loadPlayerVoiceCategories("gamedata/audio/zm/zm_usmc_vox.csv");
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

function private watch_power_state()
{
    level.power_on_lightstate = undefined;
    
    level flag::wait_till("power_on");
    
    level.power_on_lightstate = 1;
    util::set_lighting_state(level.power_on_lightstate);
    zm_weather::update_default_lightstate();
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
                Earthquake(0.15, 0.1, self.origin, 32);
                wait 0.1;
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

function private change_powerups_color()
{
    level._effect["powerup_on"] = FX_POWERUP_BLUE;
    level._effect["powerup_grabbed"] = "zombie/fx_powerup_grab_solo_zmb";
}

function private configure_weapon_inspection()
{
    // T9
    inspectable::add_inspectable_weapon(GetWeapon("t9_me_knife_russian"), 4.18);
    inspectable::add_inspectable_weapon(GetWeapon("t9_me_knife_russian_up"), 4.18);
    
    inspectable::add_inspectable_weapon(GetWeapon("t9_1911"), 3.33);
    inspectable::add_inspectable_weapon(GetWeapon("t9_1911_rdw_up"), 5);
    inspectable::add_inspectable_weapon(GetWeapon("t9_1911_ldw_up"), 5);

    inspectable::add_inspectable_weapon(GetWeapon("t9_diamatti"), 6.23);
    inspectable::add_inspectable_weapon(GetWeapon("t9_diamatti_up"), 6.23);

    inspectable::add_inspectable_weapon(GetWeapon("t9_rpk"), 5.83);
    inspectable::add_inspectable_weapon(GetWeapon("t9_rpk_up"), 5.83);

    inspectable::add_inspectable_weapon(GetWeapon("t9_ffar1"), 4.83);
    inspectable::add_inspectable_weapon(GetWeapon("t9_ffar1_up"), 4.83);
    
    inspectable::add_inspectable_weapon(GetWeapon("t9_groza"), 6.13);
    inspectable::add_inspectable_weapon(GetWeapon("t9_groza_up"), 6.13);

    inspectable::add_inspectable_weapon(GetWeapon("t9_m60"), 10);
    inspectable::add_inspectable_weapon(GetWeapon("t9_m60_up"), 10);

    inspectable::add_inspectable_weapon(GetWeapon("t9_streetsweeper"), 5.6);
    inspectable::add_inspectable_weapon(GetWeapon("t9_streetsweeper_up"), 5.6);

    inspectable::add_inspectable_weapon(GetWeapon("t9_semiauto_cosplay"), 4.33);
    inspectable::add_inspectable_weapon(GetWeapon("t9_semiauto_cosplay_up"), 4.33);

    // IW8
    inspectable::add_inspectable_weapon(GetWeapon("iw8_asval"), 5.76);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_asval_up"), 5.76);
    
    inspectable::add_inspectable_weapon(GetWeapon("iw8_50gs"), 4.66);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_50gs_rdw_up"), 4.66);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_50gs_ldw_up"), 4.66);

    inspectable::add_inspectable_weapon(GetWeapon("iw8_ak47"), 5.13);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_ak47_up"), 5.13);
    
    inspectable::add_inspectable_weapon(GetWeapon("iw8_iso"), 5.13);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_iso_up"), 5.13);
        
    inspectable::add_inspectable_weapon(GetWeapon("iw8_m4a1"), 5.13);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_m4a1_up"), 5.13);

    inspectable::add_inspectable_weapon(GetWeapon("iw8_minigun"), 5.26);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_minigun_up"), 5.26);
    
    inspectable::add_inspectable_weapon(GetWeapon("iw8_spr208_irons"), 5.26);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_spr208_irons_up"), 5.26);

    inspectable::add_inspectable_weapon(GetWeapon("iw8_vlkrogue"), 5.33);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_vlkrogue_up"), 5.33);
    
    inspectable::add_inspectable_weapon(GetWeapon("iw8_mp5k"), 5.16);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_mp5sd_up"), 5.16);
    
    inspectable::add_inspectable_weapon(GetWeapon("iw8_model680"), 5.16);
    inspectable::add_inspectable_weapon(GetWeapon("iw8_model680_up"), 5.16);

    // SW2
    inspectable::add_inspectable_weapon(GetWeapon("s2_vmg1927"), 5);
    inspectable::add_inspectable_weapon(GetWeapon("s2_vmg1927_up"), 5);
}
