#using scripts\_NSZ\nsz_powerup_empty_bottle;

// Sword powerup
#using scripts\zm\sword_powerup;
#using scripts\zm\_glaive;

#using scripts\shared\system_shared;
#insert scripts\shared\shared.gsh;

#insert scripts\zm\hellround\zm_hellround_shared.gsh;
#insert scripts\zm\hellround\zm_hellround_powerup.gsh;

#precache("client_fx", HRPWRUP_FX);
#precache("client_fx", HRPWRUP_GRAB_FX);

#namespace zm_hellround_powerup;

REGISTER_SYSTEM_EX("zm_hellround_powerup", &init, &main, undefined)
	
function private init()
{
}

function private main()
{
    change_powerup_solo_fx(HRPWRUP_FX, HRPWRUP_GRAB_FX);
}

function private change_powerup_solo_fx(solo_fx, solo_grab_fx)
{
    level._effect["powerup_on_solo"] = solo_fx;
    level._effect["powerup_grabbed_solo"] = solo_grab_fx;
}
