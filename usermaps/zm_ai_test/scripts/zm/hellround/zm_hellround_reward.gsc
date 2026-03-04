#using scripts\zm\_zm_xcdylan93_utils; 
#using scripts\zm\_zm_weapons; 
#using scripts\zm\_zm_perks; 
#using scripts\zm\_zm_utility; 
#using scripts\zm\_zm_score; 
#using scripts\zm\_zm; 
#using scripts\shared\laststand_shared; 
#using scripts\shared\callbacks_shared; 
#using scripts\zm\_zm_powerups; 

#using scripts\shared\system_shared;
#using scripts\zm\hellround\zm_hellround_shared;

// Persist game data over games
#using scripts\zm\zm_save_data;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\hellround\zm_hellround_shared.gsh;
#insert scripts\zm\hellround\zm_hellround_reward.gsh;
#namespace zm_hellround_reward;

REGISTER_SYSTEM_EX("zm_hellround_reward", &init, &main, undefined)

/* region classes */

class HellroundReward
{
    var index;
    var rewards;
    var high_rewards_callbacks;
}

class HellroundProgressReward
{
    // persisted data
    var consecutive_losses;
    var did_survive_bad_path;
    var did_finish_game;
    var data_restored;

    // current game data
    var did_finish_game_this_game;
    var did_survive_bad_path_this_game;
    var initial_rewards_given;
}

/* endregion */
/* region init */

function init() {
    level.hellround_reward = new HellroundReward();
    level.hellround_reward.index = 0;
    level.hellround_reward.rewards = HELLROUND_REWARDS;
    level.hellround_reward.high_rewards_callbacks = [];

    callback::on_connect(&_restore_player_progress);
    callback::on_spawned(&_give_player_rewards_and_bonuses);

    add_high_tier_reward_callback(&bad_path_survived);
}

function main()
{
    if (!DEBUG_HELLROUNDS)
    {
        return;
    }

    thread modvar_debug_hellround_rewards();

    while (!IS_TRUE(self.hellround_progress_reward.data_restored))
    {
        WAIT_SERVER_FRAME;
    }

    foreach(player in GetPlayers())
    {
        PRINT_HR_DEBUG("Restored progress.");
        PRINT_HR_DEBUG("consecutive_losses = " + player.hellround_progress_reward.consecutive_losses);
        PRINT_HR_DEBUG("did_finish_game = " + player.hellround_progress_reward.did_finish_game);
        PRINT_HR_DEBUG("did_survive_bad_path = " + player.hellround_progress_reward.did_survive_bad_path);
    }
}

function private _restore_player_progress() // self == player
{
    self _init_hellround_progress();
    self thread _watch_end_of_game_for_player(); 
}

function private _init_hellround_progress() // self == player
{
    self.hellround_progress_reward = new HellroundProgressReward();
    self.hellround_progress_reward.did_finish_game_this_game = false;
    self.hellround_progress_reward.did_survive_bad_path_this_game = false;
    self.hellround_progress_reward.initial_rewards_given = false;

    self.hellround_progress_reward.data_restored = false;
    self _checksum_data_and_set_progress_values();
}

/* endregion */
/* region progress updates */

function game_finished_with_success()
{
    foreach(player in GetPlayers())
    {
        player.hellround_progress_reward.did_finish_game = true;
        player.hellround_progress_reward.did_finish_game_this_game = true;
        player.hellround_progress_reward.consecutive_losses = 0;
    }
}

function bad_path_survived()
{
    foreach(player in GetPlayers())
    {
        player.hellround_progress_reward.did_survive_bad_path = true;
        player.hellround_progress_reward.did_survive_bad_path_this_game = true;
        player.hellround_progress_reward.consecutive_losses = 0;
    }
}

function private _watch_end_of_game_for_player() // self == player
{
    self endon("disconnect");

    level waittill("end_game");
    if (!self.hellround_progress_reward.did_finish_game_this_game
        && !self.hellround_progress_reward.did_survive_bad_path_this_game
        && self.hellround_progress_reward.consecutive_losses < HRRWRD_DATA_LOSESTREAK_MASK)
    {
        self.hellround_progress_reward.consecutive_losses++;
    }
    
    self _save_progress();
}

/* endregion */

function private _give_player_rewards_and_bonuses() // self == player
{
    self endon("disconnect");

    while (!IS_TRUE(self.hellround_progress_reward.data_restored))
    {
        WAIT_SERVER_FRAME;
    }

    if (self.hellround_progress_reward.initial_rewards_given)
    {
        PRINT_HR_DEBUG("Initial rewards already given.");
        return;
    }
    self.hellround_progress_reward.initial_rewards_given = true;

    // Rewards
    weapon = self GetCurrentWeapon();
    if (self.hellround_progress_reward.did_finish_game && self.hellround_progress_reward.did_survive_bad_path)
    {
        reward_weapon = GetWeapon(HRRWRD_FINISHED_MAP_AND_SURVIVED_BAD_PATH_WEAPON);
        reward_weapon = self zm_weapons::weapon_give(reward_weapon, false, false, true, true);
        self zm_xcdylan93_utils::update_weapon_camo(HRRWRD_FINISHED_MAP_AND_SURVIVED_BAD_PATH_WEAPON_CAMO_INDEX, reward_weapon, reward_weapon.altWeapon, false);
        waittillframeend;
        self TakeWeapon(weapon);
        PRINT_HR_DEBUG("Given weapon for overall success.");
    }
    else if (self.hellround_progress_reward.did_finish_game)
    {
        self zm_xcdylan93_utils::update_weapon_camo(HRRWRD_FINISH_MAP_WEAPON_CAMO_INDEX, weapon, weapon.altWeapon, false);
        PRINT_HR_DEBUG("Given weapon camo for finish success.");
    }
    else if (self.hellround_progress_reward.did_survive_bad_path)
    {
        self zm_xcdylan93_utils::update_weapon_camo(HRRWRD_SURVIVE_BAD_PATH_WEAPON_CAMO_INDEX, weapon, weapon.altWeapon, false);
        PRINT_HR_DEBUG("Given weapon camo for survive success.");
    }

    // Helpers        
    if (self.hellround_progress_reward.consecutive_losses >= HRRWRD_LOSESTREAK_THRESHOLDS[0])
    {
        self zm_score::add_to_player_score(HRRWRD_LOSESTREAK_1_REWARD);
        zm_utility::play_sound_at_pos("purchase", self.origin);
    }

    if (self.hellround_progress_reward.consecutive_losses >= HRRWRD_LOSESTREAK_THRESHOLDS[1])
    {
        helper_weapon = GetWeapon(HRRWRD_LOSESTREAK_2_REWARD);
        self zm_weapons::weapon_give(helper_weapon, false, false, true, true);
        // self SwitchToWeapon(helper_weapon);
        PRINT_HR_DEBUG("Given weapon for loss streak.");
    }

    if (self.hellround_progress_reward.consecutive_losses >= HRRWRD_LOSESTREAK_THRESHOLDS[2])
    {
        self zm_perks::give_perk(HRRWRD_LOSESTREAK_3_REWARD, false);
        PRINT_HR_DEBUG("Given perk for loss streak.");
    }
}

function give_reward(location)
{
    if (IS_TRUE(level.hellround.abolished)) {
        call_high_tier_rewards();
        PRINT_HR_DEBUG("Gave high-tier reward.");
    } else {
        reward = level.hellround_reward.rewards[level.hellround_reward.index];
        level.hellround_reward.index++;
        PRINT_HR_DEBUG("Spawning: " + reward + " at " + location);
        level thread zm_powerups::specific_powerup_drop(reward, GetClosestPointOnNavMesh(location, 50));
    }
}

/* region callbacks */

function add_high_tier_reward_callback(func_ptr)
{
    if (IsFunctionPtr(func_ptr))
    {
        level.hellround_reward.high_rewards_callbacks[level.hellround_reward.high_rewards_callbacks.size] = func_ptr;
    }
}

function private call_high_tier_rewards()
{
    foreach (reward_callback in level.hellround_reward.high_rewards_callbacks)
    {
        thread [[reward_callback]]();
    }
}

/* endregion */
/* region progress utilities */

function private _checksum_data_and_set_progress_values() // self == player
{
    /* 
        Data is stored as bx00000000
                            ||||||||
            checksum bits _// || \\\\_ round lost count (up to 15)
            for data          | \_ tells if map was finished once
            corruption         \_ tells if bad path was survived
    */

    zm_hellround_shared::wait_for_map_load();
    data = self save_data::get_save_data(HRRWRD_DATA_INDEX);

    // Checksum bits for data corruption is computing the value of the lowest 6 bits 
    // Starting from bit 0 up to 5 and make the result modulo 4, this gives a result from 0 to 3.
    is_data_valid = ((data & 63) % 4) == ((data >> 6) & 3);
    if (!is_data_valid)
    {
        // Player's data is corrupted, reset it.
        PRINT_HR_DEBUG("Player data corrupted. Reseting it.");
        data = 0;
        self save_data::set_save_data(HRRWRD_DATA_INDEX, data);
    }

    self.hellround_progress_reward.consecutive_losses = data & HRRWRD_DATA_LOSESTREAK_MASK;
    self.hellround_progress_reward.did_finish_game = data & HRRWRD_DATA_HAS_FINISHED_MAP_MASK;
    self.hellround_progress_reward.did_survive_bad_path = data & HRRWRD_DATA_HAS_SURVIVED_BAD_PATH_MASK;

    self.hellround_progress_reward.data_restored = true;

    PRINT_HR_DEBUG("Restored progress. consecutive_losses = " + self.hellround_progress_reward.consecutive_losses);
    PRINT_HR_DEBUG("Restored progress. did_finish_game = " + self.hellround_progress_reward.did_finish_game);
    PRINT_HR_DEBUG("Restored progress. did_survive_bad_path = " + self.hellround_progress_reward.did_survive_bad_path);
}

function private _save_progress() // self == player
{
    /* 
        Data is stored as bx00000000
                            ||||||||
            checksum bits _// || \\\\_ game lost count (up to 15)
            for data          | \_ tells if map was finished once
            corruption         \_ tells if bad path was survived
    */

    loses = self.hellround_progress_reward.consecutive_losses & HRRWRD_DATA_LOSESTREAK_MASK;
    finished = (self.hellround_progress_reward.did_finish_game << HRRWRD_DATA_HAS_FINISHED_MAP_SHIFT) & HRRWRD_DATA_HAS_FINISHED_MAP_MASK;
    survived = (self.hellround_progress_reward.did_survive_bad_path << HRRWRD_DATA_HAS_SURVIVED_BAD_PATH_SHIFT) & HRRWRD_DATA_HAS_SURVIVED_BAD_PATH_MASK;

    progress = survived | finished | loses; 
    checksum = (progress % 4) << 6;

    self save_data::set_save_data(HRRWRD_DATA_INDEX, checksum | progress);

    PRINT_HR_DEBUG("Saved progress. Survived = " + survived);
    PRINT_HR_DEBUG("Saved progress. Finished = " + finished);
    PRINT_HR_DEBUG("Saved progress. Loses = " + loses);
    PRINT_HR_DEBUG("Saved progress. Checksum = " + checksum);
}

/* endregion */
/* region debug */

function private modvar_debug_hellround_rewards()
{
    ModVar("hrreward", "");

    while(true)
    {
        WAIT_SERVER_FRAME;

        dvar_value = GetDvarString("hrreward", "");

        if(!isdefined(dvar_value) || dvar_value == "")
        {
            continue;
        }
        ModVar("hrreward", "");
        
        switch(Int(dvar_value))
        {
            case 0:
                _reset_players_progress();
                break;
            case 1:
                _unlock_finish_progress();
                break;
            case 2:
                _unlock_survive_progress();
                break;
            case 3:
                _unlock_full_progress();
                break;
            case 4:
                _apply_camo_index_to_current_weapon(4);
                break;
            case 5:
                _apply_camo_index_to_current_weapon(5);
                break;
            case 6:
                _apply_camo_index_to_current_weapon(6);
                break;
            default:
                PRINT_HR_DEBUG("Unknown command");
                break;
        }
    }
}

function private _reset_players_progress()
{
    foreach(player in GetPlayers())
    {
        player.hellround_progress_reward.consecutive_losses = 0;
        player.hellround_progress_reward.did_finish_game = 0;
        player.hellround_progress_reward.did_survive_bad_path = 0;
        player _save_progress();
    }
    
    PRINT_HR_DEBUG("Players data force reset done.");
}

function private _unlock_finish_progress()
{
    foreach(player in GetPlayers())
    {
        player.hellround_progress_reward.consecutive_losses = 0;
        player.hellround_progress_reward.did_finish_game = 1;
        player.hellround_progress_reward.did_survive_bad_path = 0;
        player _save_progress();
    }
    
    PRINT_HR_DEBUG("Players finish reward unlocked for next game.");
}

function private _unlock_survive_progress()
{
    foreach(player in GetPlayers())
    {
        player.hellround_progress_reward.consecutive_losses = 0;
        player.hellround_progress_reward.did_finish_game = 0;
        player.hellround_progress_reward.did_survive_bad_path = 1;
        player _save_progress();
    }
    
    PRINT_HR_DEBUG("Players survive reward unlocked for next game.");
}

function private _unlock_full_progress()
{
    foreach(player in GetPlayers())
    {
        player.hellround_progress_reward.consecutive_losses = 0;
        player.hellround_progress_reward.did_finish_game = 1;
        player.hellround_progress_reward.did_survive_bad_path = 1;
        player _save_progress();
    }
    
    PRINT_HR_DEBUG("Players rewards unlocked for next game.");
}

function private _apply_camo_index_to_current_weapon(camo)
{
    foreach(player in GetPlayers())
    {
        weapon = player GetCurrentWeapon();
        player zm_xcdylan93_utils::update_weapon_camo(camo, weapon, weapon.altWeapon, false);
    }
}

/* endregion */