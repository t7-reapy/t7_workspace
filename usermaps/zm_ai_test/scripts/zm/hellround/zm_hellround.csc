#using scripts\shared\system_shared;
#insert scripts\shared\shared.gsh;

// Involved in Hell rounds
#using scripts\zm\_zm_bloodsplatter;
#using scripts\zm\hellround\zm_hellround_collectors;
#using scripts\zm\hellround\zm_hellround_environment;
#using scripts\zm\_zm_ai_wasp;
#using scripts\zm\_zm_ai_napalm;
#using scripts\zm\zm_genesis_apothicon_fury;

#insert scripts\zm\hellround\zm_hellround_shared.gsh;
#namespace zm_hellround;

REGISTER_SYSTEM("zm_hellround", &init, undefined)

function init() 
{
    // We need client side for other dependencies to be taken in account.
    // For now, nothing additional on client side ...
}
