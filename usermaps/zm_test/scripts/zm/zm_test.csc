#using scripts\shared\duplicaterender_mgr; 
#using scripts\codescripts\struct;
#using scripts\shared\audio_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_load;
#using scripts\zm\_rotating_object;
#using scripts\zm\_zm_weapons;

// Weapon extensions
#using scripts\zm\_hb21_zm_weap_staff_fire;
#using scripts\zm\_hb21_zm_weap_staff_lightning;
#using scripts\zm\_hb21_zm_weap_black_hole_projectile;
#using scripts\zm\_hb21_zm_weap_magmagat;

// Custom UI
#using scripts\zm\_zm_h1_hud;

//Perks
#using scripts\zm\_zm_pack_a_punch;
#using scripts\zm\_zm_perk_additionalprimaryweapon;
#using scripts\zm\_zm_perk_doubletap2;
#using scripts\zm\_zm_perk_deadshot;
#using scripts\zm\_zm_perk_juggernaut;
#using scripts\zm\_zm_perk_quick_revive;
#using scripts\zm\_zm_perk_sleight_of_hand;
#using scripts\zm\_zm_perk_staminup;
#using scripts\zm\_zm_perk_electric_cherry;
#using scripts\zm\_zm_perk_phdflopper;
#using scripts\zm\_zm_perk_widows_wine; 

// Powerups
#using scripts\zm\_zm_powerup_double_points;
#using scripts\zm\_zm_powerup_carpenter;
#using scripts\zm\_zm_powerup_fire_sale;
#using scripts\zm\_zm_powerup_free_perk;
#using scripts\zm\_zm_powerup_full_ammo;
#using scripts\zm\_zm_powerup_insta_kill;
#using scripts\zm\_zm_powerup_nuke;

// Traps
#using scripts\zm\_zm_trap_electric;

// Easter Eggs
#using scripts\zm\zm_teddy_easter_egg;

// Ambient sounds
#using scripts\zm\_ambient_room;

// Mirrors
#using scripts\shared\mirror;

// Weather
#using scripts\zm\weather\zm_weather;

// Hell rounds
#using scripts\zm\hellround\zm_hellround;

// Room of thanks
#using scripts\zm\room_of_thanks\zm_room_of_thanks;

// Weapon dynamic swing
#using scripts\zm\weapon_mod;

#using scripts\zm\zm_usermap;

// TODO: remove
// Sphynx's Console Commands
#using scripts\Sphynx\commands\_zm_commands;

// Custom powerups FX
#define FX_POWERUP_BLUE "_reapy/fx_powerup_blue"
#precache("client_fx", FX_POWERUP_BLUE);

function autoexec init() {}

function main()
{    
    zm_usermap::main();

    callback::on_localclient_connect(&on_connect);
    callback::on_localplayer_spawned(&on_spawned);

    change_powerups_color();
    include_weapons();
}

function include_weapons()
{
    zm_weapons::load_weapon_spec_from_table("gamedata/weapons/zm/zm_test_weapons.csv", 1);
}

function private on_connect(n_local_client_num)
{
    self thread disable_players_outline(n_local_client_num);
}

function private on_spawned(n_local_client_num)
{
    self thread disable_players_outline(n_local_client_num);
}

function private disable_players_outline(n_local_client_num)
{
    self notify("disable_players_outline");
    self endon("disable_players_outline");

    // We have to keep it in a loop because once player dies and re-spawns, we have to remove its keyline again...
    while(true)
    {
        wait 4;

        players = GetPlayers(n_local_client_num);

        if (!IsArray(players))
        {
            continue;
        }

        foreach (player in players)
        {
            // player here is the target, and we update player's keyline for n_local_client_num
            player duplicate_render::update_dr_flag(n_local_client_num, "keyline_active", false);
            WAIT_CLIENT_FRAME;
        }
    }
}

function private change_powerups_color()
{
    level._effect["powerup_on"] = FX_POWERUP_BLUE;
    level._effect["powerup_grabbed"] = "zombie/fx_powerup_grab_solo_zmb";
}
