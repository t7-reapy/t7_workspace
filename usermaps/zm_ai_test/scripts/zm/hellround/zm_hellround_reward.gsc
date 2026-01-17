#using scripts\zm\_zm_powerups; 

#using scripts\shared\system_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\hellround\zm_hellround_shared.gsh;
#insert scripts\zm\hellround\zm_hellround_reward.gsh;
#namespace zm_hellround_reward;

REGISTER_SYSTEM("zm_hellround_reward", &init, undefined)

class HellroundReward
{
    var index;
    var rewards;
    var high_rewards_callbacks;
}

function init() {
    level.hellround_reward = new HellroundReward();
    level.hellround_reward.index = 0;
    level.hellround_reward.rewards = HELLROUND_REWARDS;
    level.hellround_reward.high_rewards_callbacks = [];
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

function bind_high_tier_reward_callback(func_ptr)
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
