#using scripts\codescripts\struct;

#using scripts\shared\system_shared;

#insert scripts\shared\shared.gsh;

#using scripts\zm\_zm_powerups;

#insert scripts\zm\_zm_powerups.gsh;
#insert scripts\zm\_zm_utility.gsh;

#insert scripts\zm\hellround\zm_hellround_shared.gsh;
#insert scripts\zm\hellround\zm_hellround_powerup.gsh;

#namespace zm_hellround_powerup;

REGISTER_SYSTEM("zm_hellround_powerup", &init, undefined)
	
function private init()
{
	zm_powerups::include_zombie_powerup(HRPWRUP_NAME);
	if(ToLower(GetDvarString("g_gametype")) != "zcleansed")
	{
		zm_powerups::add_zombie_powerup(HRPWRUP_NAME, HRPWRUP_CLIENTFIELD);
	}
}
