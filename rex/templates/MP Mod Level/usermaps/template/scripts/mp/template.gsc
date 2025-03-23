#using scripts\codescripts\struct;
#using scripts\shared\util_shared;
#using scripts\mp\_load;
#using scripts\mp\_util;
#using scripts\mp\template_fx;
#using scripts\mp\template_sound;

#insert scripts\shared\shared.gsh;

function main()
{
	precache();
	
	template_fx::main();
	template_sound::main();
	
	load::main();

	SetDvar( "compassmaxrange", "2100" );	// Set up the default range of the compass
}

function precache()
{
	// DO ALL PRECACHING HERE
}
