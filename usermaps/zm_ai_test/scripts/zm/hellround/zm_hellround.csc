#using scripts\shared\system_shared;
#insert scripts\shared\shared.gsh;

// Involved in Hell rounds
#using scripts\zm\_zm_bloodsplatter;
#using scripts\zm\hellround\zm_hellround_environment;
#using scripts\zm\_zm_ai_wasp;
#using scripts\zm\_zm_ai_napalm;
#using scripts\zm\zm_genesis_apothicon_fury;

#namespace zm_hellround;

REGISTER_SYSTEM_EX("zm_hellround", &init, &main, undefined)

function init() 
{
    // We need client side for other dependencies to be taken in account.
    // For now, nothing else on client side ...
}

function main() 
{
    // We need client side for other dependencies to be taken in account.
    // For now, nothing else on client side ...
}
