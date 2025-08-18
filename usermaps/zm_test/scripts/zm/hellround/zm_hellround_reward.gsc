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
}

function init() {
    level.hellround_reward = new HellroundReward();
    level.hellround_reward.index = 0;
    level.hellround_reward.rewards = HELLROUND_REWARDS;
}

function give_reward(location)
{
    if (IS_TRUE(level.hellround.abolished)) {
        PRINT_HR_DEBUG("Hellrounds abolished. Giving high-tier reward.");

        //TODO : HELLROUND_HIGHTIER_REWARD
    } else {
        reward = level.hellround_reward.rewards[level.hellround_reward.index];
        level.hellround_reward.index++;
        PRINT_HR_DEBUG("Spawning: " + reward + " at " + location);
        level thread zm_powerups::specific_powerup_drop(reward, GetClosestPointOnNavMesh(location, 50));
    }
}
