#using scripts\shared\util_shared; 
#using scripts\shared\clientfield_shared; 
#using scripts\shared\system_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_hb21_zm_magicbox;
#using scripts\zm\_hb21_zm_magicbox_botd;

#insert scripts\zm\hellround\zm_hellround_mysterybox.gsh;
#insert scripts\zm\hellround\zm_hellround_shared.gsh;

#namespace zm_hellround_mysterybox;

REGISTER_SYSTEM_EX("zm_hellround_mysterybox", &init, &main, undefined)

function private init() 
{
    clientfield::register("world", "add_extra_weapons_to_box", VERSION_SHIP, 1, "int", &add_extra_weapons_to_box, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT);
}

function private main()
{
}

function private add_extra_weapons_to_box(n_client_num, oldVal, should_add_extra_weapons, bNewEnt, bInitialSnap, fieldName, bWasTimeJump)
{
    util::waitforclient(n_client_num);

    thread _add_extra_weapons_to_box(should_add_extra_weapons);
}

function private _add_extra_weapons_to_box(include_extra_weapons)
{
    ResetZombieBoxWeapons();
    include_extra_weapons = IS_TRUE(include_extra_weapons);
    foreach (weapon_name in HRMB_EXTRA_WEAPONS)
    {
        add_weapon_to_box(include_extra_weapons, weapon_name);
    }

    foreach (weapon_name in HRMB_REGULAR_WEAPONS)
    {
        add_weapon_to_box(!include_extra_weapons, weapon_name);
    }
}

function private add_weapon_to_box(should_add_weapon, weapon_name)
{
    weapon = GetWeapon(weapon_name);
    if (!isdefined(weapon))
    {
        PRINT_HR_DEBUG("Regular weapon of name " + weapon_name + " undefined.");
        return;
    }

    if (IS_TRUE(should_add_weapon))
    {
        AddZombieBoxWeapon(weapon, weapon.worldmodel, weapon.isDualWield);
        PRINT_HR_DEBUG("Added " + weapon_name + " to box.");
    }
    else
    {
        RemoveZombieBoxWeapon(weapon);
        PRINT_HR_DEBUG("Removed " + weapon_name + " from box.");
    }
}
