#using scripts\shared\callbacks_shared; 
#using scripts\shared\system_shared;

#using scripts\zm\_zm_xcdylan93_utils; 
#using scripts\zm\_zm_weapons; 

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\hellround\zm_hellround_shared;

#insert scripts\zm\hellround\zm_hellround_shared.gsh;
#insert scripts\zm\hellround\zm_hellround_players.gsh;
#namespace zm_hellround_players;

REGISTER_SYSTEM("zm_hellround_players", &init, undefined)

function private init()
{
    callback::on_spawned(&sync_hellround_players);
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
        weapon.original_hellround_camo[client_number] = (zm_weapons::is_weapon_upgraded(weapon) ? weapon.pap_camo_to_use : 0);
    }
    else
    {
        camo_index = weapon.original_hellround_camo[client_number];
        weapon.original_hellround_camo[client_number] = undefined;
    }

    if (isdefined(camo_index))
    {
        zm_xcdylan93_utils::update_weapon_camo(camo_index, weapon, weapon.altWeapon, 0);
    }
}
