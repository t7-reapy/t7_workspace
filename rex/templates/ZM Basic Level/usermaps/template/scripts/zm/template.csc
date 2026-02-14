#using scripts\shared\clientfield_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_weapons;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\zm_usermap;

function main()
{
	level._zombie_custom_add_weapons =&custom_add_weapons;

	zm_usermap::main();
	
	util::waitforclient( 0 );

    luiload( "ui.uieditor.menus.hud.T7Hud_template" );
}

function custom_add_weapons()
{
	zm_weapons::load_weapon_spec_from_table("gamedata/weapons/zm/template.csv", 1);
}
