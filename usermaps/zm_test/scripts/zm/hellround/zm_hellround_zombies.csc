#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\hellround\zm_hellround_shared.gsh;
#insert scripts\zm\hellround\zm_hellround_zombies.gsh;

#namespace zm_hellround_zombies;

#precache("client_fx", HRZM_ZOMBIE_EYE_GLOW_HELLROUND);
#precache("client_fx", HRZM_ZOMBIE_EYE_GLOW_NORMAL);

REGISTER_SYSTEM_EX("zm_hellround_zombies", &init, &main, undefined)

function private init() 
{
    clientfield::register("world", HRZM_ZOMBIE_EYE_GLOW_CF, VERSION_SHIP, 1, "int", &update_eye_glow, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);
}

function private main()
{
    // Default to non-hellround version
    level._effect["eye_glow"] = HRZM_ZOMBIE_EYE_GLOW_NORMAL;
}

function private update_eye_glow(n_client_num, _oldVal, should_be_hellroung_eye_glow, _bNewEnt, _bInitialSnap, _fieldName, _bWasTimeJump)
{
    if (should_be_hellroung_eye_glow)
    {
        level._effect["eye_glow"] = HRZM_ZOMBIE_EYE_GLOW_HELLROUND;
    }
    else
    {
        level._effect["eye_glow"] = HRZM_ZOMBIE_EYE_GLOW_NORMAL;
    }
}