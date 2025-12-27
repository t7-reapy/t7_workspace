/*
    Utilities provided by XcDylan93 via MT discord scripting channel.
    All credits to XcDylan93.

    Downloaded version: 2025 05 26
    Latest update: 2025 05 26

    2025 05 26 -- Initial installation.
    2025 05 26 -- Removed instant switch to alt weapons.
*/

#using scripts\zm\_zm_weapons; 

#namespace zm_xcdylan93_utils;

function update_weapon_camo(camo, weapon, altweapon, aat)
{
    if(!isdefined(weapon)) 
    {
        weapon = self GetCurrentWeapon();
        altweapon = self GetCurrentWeaponAltWeapon();
    }

    if(IsSubStr(weapon.name, "glaive_apothicon_")) 
    {
        self UpdateWeaponOptions(weapon, self CalcWeaponOptions(camo, 0, 0));
        return;
    }

    if(IsSubStr(weapon.name, "+dualoptic")) 
    {
        // create_hud_command("Dualoptic Detected", 0, 50, (1, 0, 0), 3, 1);
        return 0;
    }

    weapon_options = self get_weapon_options(camo, weapon);
    if(isdefined(altweapon) && altweapon.name != "none")
    {
        update_altweapon_camo(camo, weapon, altweapon, weapon_options);
    }
    else
    {
        self UpdateWeaponOptions(weapon, weapon_options);
    }
    
    if(!isdefined(aat))
    {
        self.papcamo_index = camo;
    }

    return 1;
}

function get_weapon_options(camo, weapon)
{
    upgraded = false;
    base_weapon = weapon;

    if(zm_weapons::is_weapon_upgraded(weapon)) 
    {
        upgraded = true;
        base_weapon = zm_weapons::get_base_weapon(weapon);
    }

    force_attachments = zm_weapons::get_force_attachments(base_weapon.rootweapon);
    if(isdefined(force_attachments) && force_attachments.size)
    {
        return self CalcWeaponOptions(camo, 0, 0);
    }
    else
    {
        weapon = self GetBuildKitWeapon(weapon, upgraded);
        return self GetBuildKitWeaponOptions(weapon, camo);
    }
}

function update_altweapon_camo(camo, weapon, altweapon, options)
{
    self DisableOffhandWeapons();
    self DisableWeaponCycling();

    // Save weapons states
    weap1 = GetWeapon(weapon.name);
    weap1dw = GetWeapon(weapon.dualwieldweapon.name);
    weap2 = GetWeapon(altweapon.name);
    weap2dw = GetWeapon(altweapon.dualwieldweapon.name);
    weap1_c = self GetWeaponAmmoClip(weap1);
    weap1_s = self GetWeaponAmmoStock(weap1);
    weap1dw_c = self GetWeaponAmmoClip(weap1dw);
    weap2_c = self GetWeaponAmmoClip(weap2);
    weap2_s = self GetWeaponAmmoStock(weap2);
    weap2dw_c = self GetWeaponAmmoClip(weap2dw);

    // Take & Give weapon back with the new options and camo
    current_weapon_name = self GetCurrentWeapon().name;
    self TakeWeapon(weap1);
    if(weapon.name == "microwavegun" || weapon.name == "microwavegun_upgraded") 
    {
        self GiveWeapon(weap2, options, 0);
        self SwitchToWeaponImmediate(weap2);
        self SwitchToWeaponImmediate(weap1);
    }
    else 
    {
        self GiveWeapon(weap1, options, 0);
        self ShouldDoInitialWeaponRaise(weap1, 0);
    }

    // Restore weapons states
    self SetWeaponAmmoClip(weap1, weap1_c);
    self SetWeaponAmmoStock(weap1, weap1_s);
    self SetWeaponAmmoClip(weap2, weap2_c);
    self SetWeaponAmmoStock(weap2, weap2_s);
    if(weapon.dualwieldweapon.name != "none")
    {
        self SetWeaponAmmoClip(weap1dw, weap1dw_c);
    }
    else if(altweapon.dualwieldweapon.name != "none")
    {
        self SetWeaponAmmoClip(weap2dw, weap2dw_c);
    }
    
    self EnableWeaponCycling();
    self EnableOffhandWeapons();
}

function save_weapon_ammo_state(player, weapon, altweapon)
{
    if (!IsPlayer(player))
    {
        return;
    }

    if (IsWeapon(weapon))
    {
        weapon.save_clip = player GetWeaponAmmoClip(weapon);
        weapon.save_stock = player GetWeaponAmmoStock(weapon);

        if (IsWeapon(weapon.dualwieldweapon) && weapon.dualwieldweapon.name != "none")
        {
            weapon.dualwieldweapon.save_clip = player GetWeaponAmmoClip(weapon.dualwieldweapon);
        }
    }

    if (IsWeapon(altweapon))
    {
        altweapon.save_clip = player GetWeaponAmmoClip(altweapon);
        altweapon.save_stock = player GetWeaponAmmoStock(altweapon);

        if (IsWeapon(altweapon.dualwieldweapon) && altweapon.dualwieldweapon.name != "none")
        {
            altweapon.dualwieldweapon.save_clip = player GetWeaponAmmoClip(altweapon.dualwieldweapon);
        }
    }
}

function restore_weapon_ammo_state(player, weapon, altweapon)
{
    if (!IsPlayer(player))
    {
        return;
    }

    if (IsWeapon(weapon))
    {
        player SetWeaponAmmoClip(weapon, weapon.save_clip);
        player SetWeaponAmmoStock(weapon, weapon.save_stock);

        if (IsWeapon(weapon.dualwieldweapon) && weapon.dualwieldweapon.name != "none")
        {
            player SetWeaponAmmoClip(weapon.dualwieldweapon, weapon.dualwieldweapon.save_clip);
        }
    }

    if (IsWeapon(altweapon))
    {
        player SetWeaponAmmoClip(altweapon, altweapon.save_clip);
        player SetWeaponAmmoStock(altweapon, altweapon.save_stock);

        if (IsWeapon(altweapon.dualwieldweapon) && altweapon.dualwieldweapon.name != "none")
        {
            player SetWeaponAmmoClip(altweapon.dualwieldweapon, altweapon.dualwieldweapon.save_clip);
        }
    }
}