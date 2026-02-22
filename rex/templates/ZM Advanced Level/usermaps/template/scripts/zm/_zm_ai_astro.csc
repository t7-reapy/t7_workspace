#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace zm_ai_astro;

REGISTER_SYSTEM_EX( "zm_ai_astro", &init, undefined, undefined )

function init()
{
	register_clientfields();
}

function register_clientfields()
{
	astro_name = tablelookuprowcount("gamedata/tables/zm/zm_astro_names.csv");
	if(isdefined(astro_name) && astro_name > 0)
	{
		clientfield::register("actor", "astro_name_index", 21000, getminbitcountfornum(astro_name + 1), "int", &function_ff7d3b7, 0, 0);
	}
}

function function_ff7d3b7(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump)
{
	var_28a1ce70 = tablelookup("gamedata/tables/zm/zm_astro_names.csv", 0, newval - 1, 1);
	self setdrawname(var_28a1ce70);
}
