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
#using scripts\zm\_zm_weapons;

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
#using scripts\zm\_zm_perk_tombstone;
#using scripts\zm\_zm_perk_phdflopper;

// Needed for harrybo21 perks to work
#using scripts\zm\_zm_perk_widows_wine; 

//Powerups
#using scripts\zm\_zm_powerup_double_points;
#using scripts\zm\_zm_powerup_carpenter;
#using scripts\zm\_zm_powerup_fire_sale;
#using scripts\zm\_zm_powerup_free_perk;
#using scripts\zm\_zm_powerup_full_ammo;
#using scripts\zm\_zm_powerup_insta_kill;
#using scripts\zm\_zm_powerup_nuke;

// CNG
#using scripts\zm\_hb21_madgaz_zm_weap_cng;

//Traps
#using scripts\zm\_zm_trap_electric;

// Ambient sounds
#using scripts\zm\_ambient_room;

// Weather
#using scripts\zm\weather\zm_weather;

#using scripts\zm\zm_usermap;

// TODO: remove
// Sphynx's Console Commands
#using scripts\Sphynx\commands\_zm_commands;

function autoexec init()
{
	level.volumes_show = FindVolumeDecalIndexArray("hellround_volume_show");
	level.volumes_hide = FindVolumeDecalIndexArray("hellround_volume_hide");
	level.models_show = FindStaticModelIndexArray("hellround_model_show");
	level.models_hide = FindStaticModelIndexArray("hellround_model_hide");

    clientfield::register("world", "hellround_debug", VERSION_SHIP, 1, "int", &hellround_debug, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);
}

function private hellround_debug(n_local_client_num, n_old_val, n_new_val, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump)
{
	fog_index = (n_new_val ? 3 : 0);
    fog_bank = 1 << fog_index;
    lit_fog_bank = fog_index;
    foreach (player in GetLocalPlayers())
    {
		client_number = player GetLocalClientNumber();
        SetWorldFogActiveBank(client_number, fog_bank);
        SetLitFogBank(client_number, -1, lit_fog_bank, 0);
    }

    if(n_new_val)
    {
        foreach(volume in level.volumes_show)
        {
            UnhideVolumeDecal(volume);
        }

        foreach(volume in level.volumes_hide)
        {
            HideVolumeDecal(volume);
        }

        foreach(model in level.models_show)
        {
            UnhideStaticModel(model);
        }

        foreach(model in level.models_hide)
        {
            HideStaticModel(model);
        }
    }
    else
    {
        foreach(volume in level.volumes_show)
        {
            HideVolumeDecal(volume);
        }

        foreach(volume in level.volumes_hide)
        {
            UnhideVolumeDecal(volume);
        }

        foreach(model in level.models_show)
        {
            HideStaticModel(model);
        }

        foreach(model in level.models_hide)
        {
            UnhideStaticModel(model);
        }
    }
}

function main()
{    
	luiLoad("ui.uieditor.menus.hud.t7hud_zm_custom");

    zm_usermap::main();

	callback::on_localclient_connect(&on_connect);

    include_weapons();
}

function include_weapons()
{
    zm_weapons::load_weapon_spec_from_table("gamedata/weapons/zm/zm_test_weapons.csv", 1);
}

function private on_connect(n_local_client_num)
{
	self thread disable_player_outline(n_local_client_num);
}

function private disable_player_outline(n_local_client_num)
{
	foreach (player in GetPlayers(n_local_client_num))
	{
		player duplicate_render::set_dr_flag("keyline_active", 0);
	}
	
	self duplicate_render::update_dr_filters(n_local_client_num);
}