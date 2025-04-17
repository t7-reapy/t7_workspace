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
    level thread watch_power_state();
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
        self flag::wait_till(PERK_EXPLODES_FLAG_NAME);
        self exploders();
        self flag::wait_till_clear(PERK_EXPLODES_FLAG_NAME);
        self stop_exploders();
    }
}

function private exploders()
{
    self.perk_fix_exploding = true;
    for (i = 0; i < self.perk_fix_exploders.size; i++)
    {
        exploder::exploder(self.perk_fix_exploders[i]);
    }
}

function private stop_exploders()
{
    self.perk_fix_exploding = false;
    for (i = 0; i < self.perk_fix_exploders.size; i++)
    {
        exploder::exploder_stop(self.perk_fix_exploders[i]);
    }
}