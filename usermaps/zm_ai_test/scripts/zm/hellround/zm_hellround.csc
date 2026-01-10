#using scripts\shared\system_shared;
#insert scripts\shared\shared.gsh;

// Involved in Hell rounds
#using scripts\zm\_zm_bloodsplatter;
#using scripts\zm\hellround\zm_hellround_collectors;
#using scripts\zm\hellround\zm_hellround_environment;
#using scripts\zm\hellround\zm_hellround_meteor;
#using scripts\zm\hellround\zm_hellround_music;
#using scripts\zm\hellround\zm_hellround_powerup;
#using scripts\zm\hellround\zm_hellround_zombies;
#using scripts\zm\_zm_ai_wasp;
#using scripts\zm\_zm_ai_napalm;
#using scripts\zm\zm_genesis_apothicon_fury;
#using scripts\zm\_hb21_zm_magicbox;

#insert scripts\zm\hellround\zm_hellround.gsh;
#insert scripts\zm\hellround\zm_hellround_shared.gsh;

#precache("client_fx", HELLROUND_DOG_EYE_GLOW_FX);

#namespace zm_hellround;

REGISTER_SYSTEM_EX("zm_hellround", &init, &main, undefined)

function init() 
{
}

function main()
{
    level._effect["dog_eye_glow"] = HELLROUND_DOG_EYE_GLOW_FX; 
}
