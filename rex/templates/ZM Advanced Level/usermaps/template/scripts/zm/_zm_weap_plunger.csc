#using scripts\codescripts\struct;
#using scripts\shared\audio_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;

//#precache( "client_fx", "dlc1/zmb_weapon/fx_ee_plunger_trail_1p");
//#precache( "client_fx", "dlc1/zmb_weapon/fx_ee_plunger_trail_3p");
//#precache( "client_fx", "dlc1/zmb_weapon/fx_ee_plunger_teleport_impact");

#namespace zm_weap_plunger;

function autoexec __init__sytem__()
{
	system::register("zm_weap_plunger", &__init__, undefined, undefined);
}

function __init__()
{
	level._effect["plunger_charge_1p"] = "dlc1/zmb_weapon/fx_ee_plunger_trail_1p";
	level._effect["plunger_charge_3p"] = "dlc1/zmb_weapon/fx_ee_plunger_trail_3p";
	level._effect["exploding_death"] = "dlc1/zmb_weapon/fx_ee_plunger_teleport_impact";
	//clientfield::register("actor", "plunger_exploding_ai", 5000, 1, "int", &callback_exploding_death_fx, 0, 0);
	//clientfield::register("toplayer", "plunger_charged_strike", 5000, 1, "counter", &plunger_charged_strike, 0, 0);
}

function callback_exploding_death_fx(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
	if(newval == 1)
	{
		v_pos = self gettagorigin("j_spine4");
		v_angles = self gettagangles("j_spine4");
		var_e6ddb5de = util::spawn_model(localclientnum, "tag_origin", v_pos, v_angles);
		playfxontag(localclientnum, level._effect["exploding_death"], var_e6ddb5de, "tag_origin");
		var_e6ddb5de playsound(localclientnum, "evt_ai_explode");
		waitrealtime(6);
		var_e6ddb5de delete();
	}
}

function plunger_charged_strike(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
	playviewmodelfx(localclientnum, level._effect["plunger_charge_1p"], "tag_fx");
	playfxontag(localclientnum, level._effect["plunger_charge_3p"], self, "tag_fx");
}

