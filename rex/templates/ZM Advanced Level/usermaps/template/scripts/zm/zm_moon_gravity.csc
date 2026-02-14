#using scripts\codescripts\struct;
#using scripts\shared\array_shared;
#using scripts\shared\audio_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\zm\_load;
#using scripts\zm\_zm;

#namespace zm_moon_gravity;

function init()
{
}

function zombie_low_gravity(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump)
{
	self endon("death");
	self endon("entityshutdown");
	if(newval)
	{
		self.in_low_g = 1;
	}
	else
	{
		self.in_low_g = 0;
	}
}


function function_20286238(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump)
{
	self endon("death");
	self endon("entityshutdown");
	if(newval)
	{
		if(!isdefined(self.var_9f5aac3e))
		{
			self.var_9f5aac3e = self playloopsound("zmb_moon_bg_airless");
		}
	}
	else if(isdefined(self.var_9f5aac3e))
	{
		self stoploopsound(self.var_9f5aac3e);
		self.var_9f5aac3e = undefined;
	}
}

