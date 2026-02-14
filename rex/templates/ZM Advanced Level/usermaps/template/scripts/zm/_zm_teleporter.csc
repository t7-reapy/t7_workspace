#using scripts\shared\array_shared; 
#using scripts\shared\audio_shared; 
#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;

//#precache( "client_fx", "dlc5/theater/fx_teleport_flashback_kino_beam_move" );
//#precache( "client_fx", "dlc5/theater/fx_teleport_flashback_kino_beam_move_lg");
//#precache( "client_fx", "dlc5/theater/fx_teleport_initiate" );
//#precache( "client_fx", "dlc5/theater/fx_teleport_flashback_kino_cover");
//#precache( "client_fx", "dlc5/theater/fx_teleport_initiate_top");
//#precache( "client_fx", "dlc5/theater/fx_teleport_cooldown");
//#precache( "client_fx", "dlc5/theater/fx_teleport_player_flash");


#namespace zm_teleporter;

function autoexec __init__sytem__()
{
	system::register("zm_teleporter", &__init__, undefined, undefined);
}


function __init__()
{
	visionset_mgr::register_overlay_info_style_postfx_bundle("zm_theater_teleport", 21000, 1, "pstfx_zm_kino_teleport");
	clientfield::register("scriptmover", "extra_screen", 21000, 1, "int", &function_667aa0b4, 0, 0);
	clientfield::register("scriptmover", "teleporter_fx", 21000, 1, "counter", &function_a8255fab, 0, 0);
	clientfield::register("allplayers", "player_teleport_fx", 21000, 1, "counter", &function_2b23adc9, 0, 0);
	clientfield::register("world", "teleporter_initiate_fx", 21000, 1, "counter", &function_6776dea9, 0, 0);
	clientfield::register("scriptmover", "teleporter_link_cable_mtl", 21000, 1, "int", &teleporter_link_cable_mtl, 0, 0);
	level._effect["teleport_player_kino"] = "dlc5/theater/fx_teleport_flashback_kino_beam_move";
	level._effect["teleport_player_kino_lg"] = "dlc5/theater/fx_teleport_flashback_kino_beam_move_lg";
	level._effect["teleport_initiate"] = "dlc5/theater/fx_teleport_initiate";
	//level._effect["teleport_player_kino_cover"] = "dlc5/theater/fx_teleport_flashback_kino_cover";
	level._effect["teleport_initiate_top"] = "dlc5/theater/fx_teleport_initiate_top";
	level._effect["teleport_cooldown"] = "dlc5/theater/fx_teleport_cooldown";
	level._effect["teleport_player_flash"] = "dlc5/theater/fx_teleport_player_flash";
}


function main()
{
	level thread setup_teleporter_screen();
	level thread pack_clock_init();
	level thread teleporter_sounds();
}

function teleporter_sounds()
{
	thread telepad_loop();
	thread teleport_2d();
	thread teleport_2d_nopad();
	thread teleport_beam_fx_2d();
	thread teleport_specialroom_start();
	thread teleport_specialroom_go();
	thread function_24ac75e();
}


function telepad_loop()
{
	telepad = struct::get_array("telepad", "targetname");
	array::thread_all(telepad, &teleportation_audio);
}

function teleportation_audio()
{
	teleport_delay = 2;
	while(true)
	{
		level waittill("tpa");
		if(isdefined(self.script_sound))
		{
			playsound(0, ("evt_" + self.script_sound) + "_warmup", self.origin);
			wait(teleport_delay);
			playsound(0, ("evt_" + self.script_sound) + "_cooldown", self.origin);
		}
	}
}

function teleport_2d()
{
	while(true)
	{
		level waittill("t2d");
		playsound(0, "evt_teleport_2d_fnt", (0, 0, 0));
		playsound(0, "evt_teleport_2d_rear", (0, 0, 0));
	}
}

function teleport_2d_nopad()
{
	while(true)
	{
		level waittill("t2dn");
		playsound(0, "evt_pad_warmup_2d", (0, 0, 0));
		wait(1.3);
		playsound(0, "evt_teleport_2d_fnt", (0, 0, 0));
		playsound(0, "evt_teleport_2d_rear", (0, 0, 0));
	}
}

function teleport_beam_fx_2d()
{
	while(true)
	{
		level waittill("t2bfx");
		playsound(0, "evt_beam_fx_2d", (0, 0, 0));
	}
}

function teleport_specialroom_start()
{
	while(true)
	{
		level waittill("tss");
		playsound(0, "evt_pad_warmup_2d", (0, 0, 0));
	}
}

function teleport_specialroom_go()
{
	while(true)
	{
		level waittill("tsg");
		playsound(0, "evt_teleport_2d_fnt", (0, 0, 0));
		playsound(0, "evt_teleport_2d_rear", (0, 0, 0));
	}
}


function setup_teleporter_screen()
{
	level waittill("power_on");
	for(i = 0; i < level.localplayers.size; i++)
	{
		level.extracamactive[i] = 0;
	}
}

function function_24ac75e()
{
	audio::playloopat("amb_kino_movie", (-1, 1185, 474));
}

function pack_clock_init()
{
	level waittill("pack_clock_start", clientnum);
	curr_time = getsystemtime();
	hours = curr_time[0];
	if(hours > 12)
	{
		hours = hours - 12;
	}
	if(hours == 0)
	{
		hours = 12;
	}
	minutes = curr_time[1];
	seconds = curr_time[2];
	hour_hand = getent(clientnum, "zom_clock_hour_hand", "targetname");
	hour_values = [];
	hour_values["hand_time"] = hours;
	hour_values["rotate"] = 30;
	hour_values["rotate_bit"] = 0.008333334;
	hour_values["first_rotate"] = ((minutes * 60) + seconds) * hour_values["rotate_bit"];
	minute_hand = getent(clientnum, "zom_clock_minute_hand", "targetname");
	minute_values = [];
	minute_values["hand_time"] = minutes;
	minute_values["rotate"] = 6;
	minute_values["rotate_bit"] = 0.1;
	minute_values["first_rotate"] = seconds * minute_values["rotate_bit"];
	if(isdefined(hour_hand))
	{
		hour_hand thread pack_clock_run(hour_values);
	}
	if(isdefined(minute_hand))
	{
		minute_hand thread pack_clock_run(minute_values);
	}
}


function pack_clock_run(time_values)
{
	self endon("entityshutdown");
	self rotatepitch((time_values["hand_time"] * time_values["rotate"]) * -1, 0.05);
	self waittill("rotatedone");
	if(isdefined(time_values["first_rotate"]))
	{
		self rotatepitch(time_values["first_rotate"] * -1, 0.05);
		self waittill("rotatedone");
	}
	prev_time = getsystemtime();
	while(true)
	{
		curr_time = getsystemtime();
		if(prev_time != curr_time)
		{
			self rotatepitch(time_values["rotate_bit"] * -1, 0.05);
			prev_time = curr_time;
		}
		wait(1);
	}
}

function function_667aa0b4(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
	if(newval)
	{
		level.cameraent = getent(localclientnum, "theater_extracam_eye", "targetname");
		level.cam_corona = util::spawn_model(localclientnum, "tag_origin", level.cameraent.origin, level.cameraent.angles);
		level.cam_corona.var_e39fd443 = playfxontag(localclientnum, level._effect["fx_mp_light_lamp"], level.cam_corona, "tag_origin");
		if(level.extracamactive[localclientnum] == 0 && level.localplayers.size < 3)
		{
			if(isdefined(level.var_3cb13a71[localclientnum]))
			{
				killfx(localclientnum, level.var_3cb13a71[localclientnum]);
			}
			level.extracamactive[localclientnum] = 1;
			level.cameraent setextracam(0, 320, 240);
		}
	}
	else
	{
		if(isdefined(level.cam_corona))
		{
			stopfx(localclientnum, level.cam_corona.var_e39fd443);
			level.cam_corona delete();
		}
		if(level.extracamactive[localclientnum] == 1 && isdefined(level.cameraent))
		{
			level.extracamactive[localclientnum] = 0;
			level.cameraent clearextracam();
			var_78113405 = struct::get("struct_theater_projector_beam", "targetname");
			if(isdefined(level.var_3cb13a71[localclientnum]) && isdefined(var_78113405.vid[localclientnum]))
			{
				level.var_3cb13a71[localclientnum] = playfxontag(localclientnum, level._effect[level.var_bcdc3660[localclientnum]], var_78113405.vid[localclientnum], "tag_origin");
			}
		}
	}
}


function function_a8255fab(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump)
{
	self endon("entityshutdown");
	if(newval)
	{
		n_fx_id = playfxontag(localclientnum, level._effect["teleport_player_kino"], self, "tag_fx_wormhole");
		setfxignorepause(localclientnum, n_fx_id, 1);
		//var_3d144b40 = playfxontag(localclientnum, level._effect["teleport_player_kino_lg"], self, "tag_fx_wormhole");
		//setfxignorepause(localclientnum, var_3d144b40, 1);
	}
}


function function_2b23adc9(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
	a_e_players = getlocalplayers();
	foreach(e_player in a_e_players)
	{
		e_player.var_5c4ad807 = playfxontag(e_player.localclientnum, level._effect["teleport_player_flash"], self, "j_spinelower");
		setfxignorepause(e_player.localclientnum, e_player.var_5c4ad807, 1);
	}
}

function function_6776dea9(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
	var_33e4acb6 = (-306.684, 1116.25, 117.056);
	var_a1844610 = (0, 0, 0);
	v_origin = (-306.75, 1116.25, 0.0660095);
	v_angles = vectorscale((1, 0, 0), 270);
	a_e_players = getlocalplayers();
	foreach(e_player in a_e_players)
	{
		e_player.var_a0a2d27 = playfx(e_player.localclientnum, level._effect["teleport_initiate"], v_origin, anglestoforward(v_angles), anglestoup(v_angles));
		setfxignorepause(e_player.localclientnum, e_player.var_a0a2d27, 1);
		e_player.var_d4770e93 = playfx(e_player.localclientnum, level._effect["teleport_initiate_top"], var_33e4acb6, anglestoforward(var_a1844610), anglestoup(var_a1844610));
		setfxignorepause(e_player.localclientnum, e_player.var_d4770e93, 1);
	}
}

function teleporter_link_cable_mtl(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
	if(newval)
	{
		self mapshaderconstant(localclientnum, 0, "scriptVector2", 1, 0, 0, 0);
	}
	else
	{
		self mapshaderconstant(localclientnum, 0, "scriptVector2", 0, 0, 0, 0);
	}
}

