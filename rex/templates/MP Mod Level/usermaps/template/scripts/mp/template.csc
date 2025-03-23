#using scripts\codescripts\struct;
#using scripts\shared\util_shared;
#using scripts\mp\_load;
#using scripts\mp\_util;
#using scripts\mp\template_fx;
#using scripts\mp\template_sound;

#insert scripts\shared\shared.gsh;

function main()
{
	template_fx::main();
	template_sound::main();
	
	load::main();

	util::waitforclient( 0 );	// This needs to be called after all systems have been registered.
}
