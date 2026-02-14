#using scripts\shared\audio_shared; 
#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\postfx_shared;
#using scripts\shared\util_shared;

#namespace zm_minecart;

function main()
{
	clientfield::register("toplayer", "minecart_rumble", 21000, 1, "int", &function_425904c0, 0, 0);
	clientfield::register("allplayers", "player_legs_hide", 21000, 1, "int", &player_legs_hide, 0, 0);
}


function player_legs_hide(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump)
{
	if(newval)
	{
		self hideviewlegs();
	}
	else
	{
		self showviewlegs();
	}
}


function function_425904c0(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
	if(newval)
	{
		player = getlocalplayer(localclientnum);
		if(self == player)
		{
			self playrumblelooponentity(localclientnum, "tank_rumble");
		}
	}
	else
	{
		player = getlocalplayer(localclientnum);
		if(self == player)
		{
			self stoprumble(localclientnum, "tank_rumble");
		}
	}
}