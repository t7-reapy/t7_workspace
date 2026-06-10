#using scripts\shared\callbacks_shared; 
#using scripts\shared\system_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\array_shared;
#using scripts\shared\util_shared;

#using scripts\zm\_zm_xcdylan93_utils; 
#using scripts\zm\_zm_weapons; 
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_utility;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\hellround\zm_hellround_shared;

#insert scripts\zm\hellround\zm_hellround_shared.gsh;
#insert scripts\zm\hellround\zm_hellround_players.gsh;
#namespace zm_hellround_players;

REGISTER_SYSTEM_EX("zm_hellround_players", &init, &main, undefined)

function private init()
{
    callback::on_spawned(&sync_hellround_players);
}

function private main()
{
    thread _power_encounter_vo();
    thread _pap_encounter_vo();
    thread _meteor_encounter_vo();
    thread _wolf_heads_encounter_vo();
}

function private sync_hellround_players() // self == player
{
    self toggle_hellround_for_player(zm_hellround_shared::is_hellround_running());
}

function private toggle_hellround_for_player(b_enable) // self == player
{
    wait HRPLR_TIME_BEFORE_TOGGLE;

    if (IS_TRUE(b_enable))
    {
        self bodystyle_for_hellround();
        self update_weapons_camo_for_hellround(true);
    }
    else
    {
        self bodystyle_back_to_normal();
        self update_weapons_camo_for_hellround(false);
    }
}

function toggle_hellround_for_players(b_enable)
{
    foreach (player in GetPlayers())
    {
        player thread toggle_hellround_for_player(b_enable);
    }
}

function private bodystyle_for_hellround() // self == player
{
    PRINT_HR_DEBUG("bodystyle_for_hellround");
    self SetCharacterBodyStyle(HRPLR_BODYSTYLE_ON);
}

function private bodystyle_back_to_normal() // self == player
{
    PRINT_HR_DEBUG("bodystyle_back_to_normal");
    self SetCharacterBodyStyle(HRPLR_BODYSTYLE_OFF);
}

function private update_weapons_camo_for_hellround(enable) // self == player
{
    if (!HRPLR_HELLROUND_CAMO_ENABLE)
    {
        return;
    }

    foreach (weapon in self GetWeaponsListPrimaries())
    {
        self update_weapon_camo_for_hellround(enable, weapon);
    }
}

function private update_weapon_camo_for_hellround(enable, weapon) // self == player
{
    if (!(self HasWeapon(weapon, true)))
    {
        return;
    }

    // Initial state of weapon if missing
    weapon = zm_weapons::get_nonalternate_weapon(weapon);
    if (!isdefined(weapon.original_hellround_camo))
    {
        weapon.original_hellround_camo = array(undefined, undefined, undefined, undefined);
    }

    // Update camo
    client_number = self GetEntityNumber();
    camo_index = 0;
    if (enable)
    {
        camo_index = HRPLR_HELLROUND_CAMO_INDEX;
        if (!isdefined(weapon.original_hellround_camo[client_number]))
        {
            weapon.original_hellround_camo[client_number] = (isdefined(weapon.pap_camo_to_use) ? weapon.pap_camo_to_use : (isdefined(weapon.pap_manual_camo_index) ? weapon.pap_manual_camo_index : 0));
        }
    }
    else
    {
        camo_index = weapon.original_hellround_camo[client_number];
        weapon.original_hellround_camo[client_number] = undefined;
    }

    if (isdefined(camo_index))
    {
        self zm_xcdylan93_utils::update_weapon_camo(camo_index, weapon, weapon.altWeapon, 0);
    }
}

/* region vox */

function private _can_player_speak(category, subcategory) // self == player
{
    if(IS_TRUE(self.isSpeaking))
    {
        return false;
    }

    if(IS_TRUE(self.dontspeak))
    {
        return false;
    }
    
    if(zm_audio::isVoxOnCooldown(self, category, subcategory))
    {
        return false;
    }

    return true;
}

function private _debug_vox(category, subcategory)
{
    PRINT_HR_DEBUG("VOX DEBUG: level.sndPlayerVox: " + isdefined(level.sndPlayerVox));
    PRINT_HR_DEBUG("VOX DEBUG: level.sndPlayerVox.size: " + (isdefined(level.sndPlayerVox) ? level.sndPlayerVox.size : -1));
    PRINT_HR_DEBUG("VOX DEBUG: level.sndPlayerVox[" + category + "]: " + isdefined(level.sndPlayerVox[category]));
    PRINT_HR_DEBUG("VOX DEBUG: level.sndPlayerVox[" + category + "][" + subcategory + "]: " + isdefined(level.sndPlayerVox[category][subcategory]));
}

function private _pap_encounter_vo()
{
    level endon("end_game");
    level flag::wait_till("initial_blackscreen_passed");

    pap_locations = GetEntArray("pap_location", "targetname");
    while (true)
    {
        WAIT_SERVER_FRAME;
        foreach (pap_location in pap_locations)
        {
            WAIT_SERVER_FRAME;
            foreach (player in GetPlayers())
            {
                WAIT_SERVER_FRAME;
                if (!player _can_player_speak("general", "pap_encounter"))
                {
                    continue;
                }

                distance = Distance(player.origin, pap_location.origin);
                if (distance < 150)
                {
                    _debug_vox("general", "pap_encounter");
                    player zm_audio::create_and_play_dialog("general", "pap_encounter");
                    return;
                }
            }
        }
    }
}

function private _power_encounter_vo()
{
    level endon("end_game");
    level flag::wait_till("initial_blackscreen_passed");

    power_switch = GetEnt("use_master_switch", "targetname");
    if (!isdefined(power_switch))
    {
        return; // no power switch on this map — nothing to encounter
    }
    // Cache the origin now: the switch trigger is Delete()'d when power is turned on
    // (_zm_animated_switch), which would otherwise turn power_switch undefined mid-loop.
    switch_origin = power_switch.origin;
    while (true)
    {
        WAIT_SERVER_FRAME;

        foreach (player in GetPlayers())
        {
            if (!player _can_player_speak("encounter", "power"))
            {
                WAIT_SERVER_FRAME;
                continue;
            }

            distance = Distance(player.origin, switch_origin);
            if (distance < 150)
            {
                _debug_vox("encounter", "power");
                player zm_audio::create_and_play_dialog("encounter", "power");
                return;
            }
        }
    }
}

function collector_challenge_start_vo()
{
    wait 2;
    players = GetPlayers();
    players = array::randomize(players);
    while(true)
    {
        WAIT_SERVER_FRAME;

        foreach (player in players)
        {
            if (!player _can_player_speak("general", "collector_challenge"))
            {
                WAIT_SERVER_FRAME;
                continue;
            }

            _debug_vox("general", "collector_challenge");
            player zm_audio::create_and_play_dialog("general", "collector_challenge");
            return;
        }
    }
}

function collector_first_completion_vo()
{
    if (zm_hellround_shared::get_current_iteration() != 1)
    {
        return;
    }

    wait 3;
    players = GetPlayers();
    players = array::randomize(players);
    while(true)
    {
        WAIT_SERVER_FRAME;

        foreach (player in players)
        {
            if (!player _can_player_speak("general", "collector_first_completion"))
            {
                WAIT_SERVER_FRAME;
                continue;
            }

            _debug_vox("general", "collector_first_completion");
            player zm_audio::create_and_play_dialog("general", "collector_first_completion");
            return;
        }
    }
}

function collector_last_completion_vo()
{
    if (zm_hellround_shared::get_current_iteration() != 3)
    {
        return;
    }

    wait 3;
    players = GetPlayers();
    players = array::randomize(players);
    while(true)
    {
        WAIT_SERVER_FRAME;

        foreach (player in players)
        {
            if (!player _can_player_speak("general", "collector_last_completion"))
            {
                WAIT_SERVER_FRAME;
                continue;
            }

            _debug_vox("general", "collector_last_completion");
            player zm_audio::create_and_play_dialog("general", "collector_last_completion");
            return;
        }
    }
}

function bad_path_vo()
{
    wait 5;
    players = GetPlayers();
    players = array::randomize(players);
    while(true)
    {
        WAIT_SERVER_FRAME;

        foreach (player in players)
        {
            if (!player _can_player_speak("general", "hellround_bad_path"))
            {
                WAIT_SERVER_FRAME;
                continue;
            }

            _debug_vox("general", "hellround_bad_path");
            player zm_audio::create_and_play_dialog("general", "hellround_bad_path");
            return;
        }
    }
}

function meteor_siren_vo()
{
    level endon("end_game");

    wait 35; // 25 seconds before sirens start ringing
    players = GetPlayers();
    players = array::randomize(players);
    while(true)
    {
        WAIT_SERVER_FRAME;

        foreach (player in players)
        {
            if (!player _can_player_speak("general", "meteor_falldown"))
            {
                WAIT_SERVER_FRAME;
                continue;
            }

            _debug_vox("general", "meteor_falldown");
            player zm_audio::create_and_play_dialog("general", "meteor_falldown");
            return;
        }
    }
}

function meteor_bought_vo()
{
    players = GetPlayers();
    players = array::randomize(players);
    while(true)
    {
        WAIT_SERVER_FRAME;

        foreach (player in players)
        {
            if (!player _can_player_speak("general", "meteor_interaction"))
            {
                WAIT_SERVER_FRAME;
                continue;
            }

            _debug_vox("general", "meteor_interaction");
            player zm_audio::create_and_play_dialog("general", "meteor_interaction");
            return;
        }
    }
}

function private _meteor_encounter_vo()
{
    level endon("end_game");
    level flag::wait_till("initial_blackscreen_passed");

    meteor_trigger = GetEnt("meteor_trigger", "targetname");
    while (!meteor_trigger IsTriggerEnabled())
    {
        wait 0.5;
    }

    players = GetPlayers();
    players = array::randomize(players);
    while (true)
    {
        WAIT_SERVER_FRAME;

        foreach (player in players)
        {
            if (!player _can_player_speak("general", "meteor_event"))
            {
                WAIT_SERVER_FRAME;
                continue;
            }

            distance = Distance(player.origin, meteor_trigger.origin);
            if (distance < 150)
            {
                _debug_vox("general", "meteor_event");
                player zm_audio::create_and_play_dialog("general", "meteor_event");
                return;
            }
        }
    }
}

function wolf_feed_start_vo(location)
{
    if (zm_hellround_shared::get_current_iteration() != 0)
    {
        return;
    }

    wait 5;
    players = GetPlayers();
    closests = util::get_array_of_closest(location, players);

    while (true)
    {
        WAIT_SERVER_FRAME;
        foreach (player in closests)
        {
            if (player _can_player_speak("general", "cerberus_activation"))
            {
                _debug_vox("general", "cerberus_activation");
                player thread zm_utility::do_player_general_vox("general", "cerberus_activation");
                return;
            }
        }
    }
}

function first_wolf_complete_vo(location)
{
    if (zm_hellround_shared::get_current_iteration() != 0)
    {
        return;
    }

    wait 6.5;
    players = GetPlayers();
    closests = util::get_array_of_closest(location, players);

    while (true)
    {
        WAIT_SERVER_FRAME;
        foreach (player in closests)
        {
            if (player _can_player_speak("general", "cerberus_first_completion"))
            {
                _debug_vox("general", "cerberus_first_completion");
                player thread zm_utility::do_player_general_vox("general", "cerberus_first_completion");
                return;
            }
        }
    }
}

function final_wolf_complete_vo(location)
{
    if (zm_hellround_shared::get_current_iteration() != 0)
    {
        return;
    }

    wait 6.5;
    players = GetPlayers();
    closests = util::get_array_of_closest(location, players);

    while (true)
    {
        WAIT_SERVER_FRAME;
        foreach (player in closests)
        {
            if (player _can_player_speak("general", "cerberus_last_completion"))
            {
                _debug_vox("general", "cerberus_last_completion");
                player thread zm_utility::do_player_general_vox("general", "cerberus_last_completion");
                return;
            }
        }
    }
}

function private _wolf_heads_encounter_vo()
{
    foreach (soul_catcher in level.soul_catchers_vol)
    {
        soul_catcher thread _wolf_head_encounter_vo();
    }
}

function private _wolf_head_encounter_vo() // self == soul catcher
{
    level endon("end_game");

    while (true)
    {
        wait 0.25;
        foreach(player in GetPlayers())
        {
            if (player IsTouching(self) && player _can_player_speak("general", "cerberus_encounter"))
            {
                _debug_vox("general", "cerberus_encounter");
                player thread zm_utility::do_player_general_vox("general", "cerberus_encounter");
                return;
            }
        }
    }
}


/* endregion */