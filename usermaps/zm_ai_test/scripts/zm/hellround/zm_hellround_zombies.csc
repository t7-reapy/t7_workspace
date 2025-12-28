#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\hellround\zm_hellround_shared.gsh;
#insert scripts\zm\hellround\zm_hellround_zombies.gsh;

#namespace zm_hellround_zombies;

#precache("client_fx", HRZM_ZOMBIE_EYE_GLOW_HELLROUND);
#precache("client_fx", HRZM_ZOMBIE_EYE_GLOW_NORMAL);
#precache("client_fx", "player/fx_ai_corvus_arm_left_loop");
#precache("client_fx", "player/fx_ai_corvus_arm_right_loop");
#precache("client_fx", "player/fx_ai_corvus_head_loop");
#precache("client_fx", "player/fx_ai_corvus_hip_left_loop");
#precache("client_fx", "player/fx_ai_corvus_hip_right_loop");
#precache("client_fx", "player/fx_ai_corvus_leg_left_loop");
#precache("client_fx", "player/fx_ai_corvus_leg_right_loop");
#precache("client_fx", "player/fx_ai_corvus_torso_loop");
#precache("client_fx", "player/fx_ai_corvus_waist_loop");
#precache("client_fx", "zombie/fx_keeper_ambient_torso_zod_zmb");

REGISTER_SYSTEM_EX("zm_hellround_zombies", &init, &main, undefined)

function private init() 
{	
    level._effect["corvus_fx_arm_le"] = "player/fx_ai_corvus_arm_left_loop";
	level._effect["corvus_fx_arm_ri"] = "player/fx_ai_corvus_arm_right_loop";
	level._effect["corvus_fx_head"] = "player/fx_ai_corvus_head_loop";
	level._effect["corvus_fx_hip_le"] = "player/fx_ai_corvus_hip_left_loop";
	level._effect["corvus_fx_hip_ri"] = "player/fx_ai_corvus_hip_right_loop";
	level._effect["corvus_fx_leg_le"] = "player/fx_ai_corvus_leg_left_loop";
	level._effect["corvus_fx_leg_ri"] = "player/fx_ai_corvus_leg_right_loop";
	level._effect["corvus_fx_torso"] = "player/fx_ai_corvus_torso_loop";
	level._effect["corvus_fx_torso_2"] = "zombie/fx_keeper_ambient_torso_zod_zmb";
	level._effect["corvus_fx_waist"] = "player/fx_ai_corvus_waist_loop";

    clientfield::register("world", HRZM_ZOMBIE_EYE_GLOW_CF, VERSION_SHIP, 1, "int", &update_eye_glow, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);
    clientfield::register("actor", "corvus_body_fx", 1, 1, "int", &play_corvus_fire_fx, 0, 0);
}

function private main()
{
    // Default to non-hellround version
    level._effect["eye_glow"] = HRZM_ZOMBIE_EYE_GLOW_NORMAL;
}

function private update_eye_glow(n_client_num, _oldVal, should_be_hellroung_eye_glow, _bNewEnt, _bInitialSnap, _fieldName, _bWasTimeJump)
{
    if (should_be_hellroung_eye_glow)
    {
        level._effect["eye_glow"] = HRZM_ZOMBIE_EYE_GLOW_HELLROUND;
    }
    else
    {
        level._effect["eye_glow"] = HRZM_ZOMBIE_EYE_GLOW_NORMAL;
    }
}

function play_corvus_fire_fx(n_client_num, _oldVal, should_be_playing_fx, _bNewEnt, _bInitialSnap, _fieldName, _bWasTimeJump)
{
    if(should_be_playing_fx)
	{
		self.corvus_fx_id = [];
		fx_elbow_left     = playfxontag(n_client_num, level._effect["corvus_fx_arm_le"],  self, "j_elbow_le");
		fx_shoulder_left  = playfxontag(n_client_num, level._effect["corvus_fx_arm_le"],  self, "j_shoulder_le");
		fx_elbow_right    = playfxontag(n_client_num, level._effect["corvus_fx_arm_ri"],  self, "j_elbow_ri");
		fx_shoulder_right = playfxontag(n_client_num, level._effect["corvus_fx_arm_ri"],  self, "j_shoulder_ri");
		fx_head           = playfxontag(n_client_num, level._effect["corvus_fx_head"],    self, "j_head");
		fx_hip_left       = playfxontag(n_client_num, level._effect["corvus_fx_hip_le"],  self, "j_hip_le");
		fx_hip_right      = playfxontag(n_client_num, level._effect["corvus_fx_hip_ri"],  self, "j_hip_ri");
		fx_knee_left      = playfxontag(n_client_num, level._effect["corvus_fx_leg_le"],  self, "j_knee_le");
		fx_knee_right     = playfxontag(n_client_num, level._effect["corvus_fx_leg_ri"],  self, "j_knee_ri");
		fx_spine          = playfxontag(n_client_num, level._effect["corvus_fx_torso"],   self, "j_spine4");
		fx_spine_2        = playfxontag(n_client_num, level._effect["corvus_fx_torso_2"], self, "j_spine4");
		fx_spinelower     = playfxontag(n_client_num, level._effect["corvus_fx_waist"],   self, "j_spinelower");
		self.corvus_fx_id = array(fx_elbow_left, fx_shoulder_left, fx_elbow_right, fx_shoulder_right, fx_head, fx_hip_left, fx_hip_right, fx_knee_left, fx_knee_right, fx_spine, fx_spine_2, fx_spinelower);
	}
	else if(isdefined(self.corvus_fx_id))
	{
		for(i = 0; i < self.corvus_fx_id.size; i++)
		{
			deletefx(n_client_num, self.corvus_fx_id[i], 0);
		}
		self.corvus_fx_id = undefined;
	}
}