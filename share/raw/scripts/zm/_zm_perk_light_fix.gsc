#using scripts\shared\array_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\system_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\callbacks_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace zm_perk_light_fix;

#define PERK_EXPLODES_FLAG_NAME "power_on"

#define PERK_EXPLODER_NAME_QUICK_REVIVE "perk_revive"
#define PERK_EXPLODER_NAME_SLEIGHT "perk_sleight"
#define PERK_EXPLODER_NAME_MULEKICK "perk_mulekick"
#define PERK_EXPLODER_NAME_JUGGERNAUT "perk_juggernaut"
#define PERK_EXPLODER_NAME_DOUBLETAP "perk_doubletap"
#define PERK_EXPLODER_NAME_MARATHON "perk_marathon"
#define PACK_A_PUNCH_EXPLODER_NAME "pack_a_punch"

REGISTER_SYSTEM_EX("zm_perk_light_fix", &init, &main, undefined)

function init() 
{
    level.perk_fix_exploding = false;
    level.perk_fix_exploders = [];
    array::add(level.perk_fix_exploders, PERK_EXPLODER_NAME_QUICK_REVIVE, false);
    array::add(level.perk_fix_exploders, PERK_EXPLODER_NAME_SLEIGHT, false);
    array::add(level.perk_fix_exploders, PERK_EXPLODER_NAME_MULEKICK, false);
    array::add(level.perk_fix_exploders, PERK_EXPLODER_NAME_JUGGERNAUT, false);
    array::add(level.perk_fix_exploders, PERK_EXPLODER_NAME_DOUBLETAP, false);
    array::add(level.perk_fix_exploders, PERK_EXPLODER_NAME_MARATHON, false);
    array::add(level.perk_fix_exploders, PACK_A_PUNCH_EXPLODER_NAME, false);

    // In case players connect late, we need to sync perk light state
    callback::on_connect(&sync_exploders);
}

function main() 
{
    level flag::wait_till("initial_blackscreen_passed");
    thread watch_power_state();
    thread watch_revive_solo();
}

function private sync_exploders()
{
    if (level.perk_fix_exploding)
    {
        level exploders();
    } 
    else 
    {
        level stop_exploders();
    }
}

function private watch_power_state()
{
    while(1)
    {
        level flag::wait_till(PERK_EXPLODES_FLAG_NAME);
        level exploders();
        level flag::wait_till_clear(PERK_EXPLODES_FLAG_NAME);
        level stop_exploders();
    }
}

function private exploders()
{
    level.perk_fix_exploding = true;
    for (i = 0; i < level.perk_fix_exploders.size; i++)
    {
        if (level.perk_fix_exploders[i] == PERK_EXPLODER_NAME_QUICK_REVIVE && solo_lives_gone())
        {
            continue;
        }

        exploder::exploder(level.perk_fix_exploders[i]);
    }
}

function private stop_exploders()
{
    level.perk_fix_exploding = false;
    for (i = 0; i < level.perk_fix_exploders.size; i++)
    {
        exploder::exploder_stop(level.perk_fix_exploders[i]);
    }
}

function private watch_revive_solo()
{
    while(true)
    {
        if (solo_lives_gone())
        {
            exploder::exploder_stop(level.perk_fix_exploders[0]); // PERK_EXPLODER_NAME_QUICK_REVIVE
            break;
        }

        wait 1;
    }
}

function private solo_lives_gone()
{
    return level flag::exists("solo_game") 
        && level flag::get("solo_game")
        && level flag::exists("solo_revive")
        && level flag::get("solo_revive"); // solo_revive is set when perk is gone
}