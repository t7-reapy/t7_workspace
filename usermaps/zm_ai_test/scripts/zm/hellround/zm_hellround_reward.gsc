
#using scripts\shared\system_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\hellround\zm_hellround_shared.gsh;
#insert scripts\zm\hellround\zm_hellround_reward.gsh;
#namespace zm_hellround_reward;

REGISTER_SYSTEM("zm_hellround_reward", &init, undefined)

function init() { }

function give_reward()
{
    if (IS_TRUE(level.hellround.abolished)) {
        PRINT_HR_DEBUG("Hellrounds abolished. Giving high-tier reward.");
        //TODO
    } else {
        PRINT_HR_DEBUG("Hellrounds not abolished. Giving normal reward.");
        //TODO
    }
}