#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_weapons;

#using scripts\zm\_zm_utility;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

REGISTER_SYSTEM_EX("_zm_t6_deathanim", &_init, &_main, undefined)

function private _init()
{
    callback::on_spawned(&_set_latest_death);
}

function private _main()
{
    level waittill("end_game");
    
    player = level.latest_player_downed_for_death_anim;

    if(isdefined(player))
    {
        player EnableWeaponCycling();
        player FreezeControls(false);
        player EnableWeapons();

        foreach(weapon in player GetWeaponsList(true))
        {
            player TakeWeapon(weapon);
        }

        weapon = GetWeapon("t6_deathanim");
        weapon = player GetBuildKitWeapon(weapon, false);
        options = player GetBuildKitWeaponOptions(weapon, 0);
        player GiveWeapon(weapon, options, 0);
        player SwitchToWeaponImmediate(weapon);
    }
}

function private _set_latest_death()
{
    self endon("player_spawned");
    self endon("bled_out");

    level.latest_player_downed_for_death_anim = self;

    while(isdefined(self))
    {
        self waittill("entering_last_stand");

        level.latest_player_downed_for_death_anim = self;
    }
}