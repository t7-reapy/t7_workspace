#using scripts\zm\_zm_utility; 
#using scripts\shared\ai\zombie_utility; 
#using scripts\shared\spawner_shared; 
#using scripts\shared\array_shared;
#using scripts\shared\system_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\hellround\zm_hellround_shared;
#insert scripts\zm\hellround\zm_hellround_shared.gsh;
#insert scripts\zm\hellround\zm_hellround_zombies.gsh;

#namespace zm_hellround_zombies;

#precache("model", "c_zom_dlc3_zombie_sentinel_body");
#precache("model", "c_zom_dlc4_zombie_charred_head");

REGISTER_SYSTEM_EX("zm_hellround_zombies", &init, &main, undefined)

function init() 
{
    level.original_zombie_bodies = ORIGINAL_ZOMBIE_BODY_MODELS;
    level.original_zombie_hats = ORIGINAL_ZOMBIE_HAT_MODELS;
    level.original_zombie_heads = ORIGINAL_ZOMBIE_HEAD_MODELS;
}

function private main()
{
    array::run_all(GetSpawnerArray(), &spawner::add_spawn_function, &zombie_spawn_hellround_logic);
}

function is_normal_zombie() // self == actor
{
    if (IsDefined(self.animname) && self.animname !== "zombie")
        return false;

    if (IsDefined(self.archetype) && self.archetype == "zombie")
        return true;

    return false;
}

function private zombie_spawn_hellround_logic() // self == zombie spawned
{
    if (zm_hellround_shared::is_hellround_running() && self is_normal_zombie()) {
        waittillframeend;
        self thread set_zombie_model_to_hellround();
        self thread zombie_utility::set_zombie_run_cycle(HRZM_ZOMBIE_RUN_STATE);
    }
}

function toggle_hellround_zombies(b_enable)
{
    if (IS_TRUE(b_enable)) {
        enable_hellround_zombies();
    } else {
        disable_hellround_zombies();
    }
}

function enable_hellround_zombies()
{
    zombies = GetAiSpeciesArray(level.zombie_team, "all");
    foreach (zombie in zombies)
    {
        if (zombie is_normal_zombie())
        {
            zombie thread set_zombie_model_to_hellround();
            zombie thread zombie_utility::set_zombie_run_cycle(HRZM_ZOMBIE_RUN_STATE);
        }
    }
}

function disable_hellround_zombies()
{
    zombies = GetAiSpeciesArray(level.zombie_team, "all");
    foreach (zombie in zombies)
    {
        if (!zombie is_normal_zombie())
        {
            continue;
        }

        zombie thread set_back_to_default_zombie();
        zombie thread zm_utility::init_zombie_run_cycle();
    }
}

// #region original zombie models

function set_back_to_default_zombie() // self == zombie
{
    body_style = level.original_zombie_bodies[RandomInt(level.original_zombie_bodies.size)];
    head_model = level.original_zombie_heads[RandomInt(level.original_zombie_heads.size)];
    hat_model = level.original_zombie_hats[RandomInt(level.original_zombie_hats.size)];

    self.skeleton = "base";
    self.voice = "american";

    self DetachAll();
    if (hat_model != "")
    {
        self.hatmodel = hat_model;
        self Attach(self.hatmodel, "", true);
    }
    self.head = head_model;
    self Attach(self.head, "", true);
    self SetModel(body_style);

    self dlchd_origins_zombie_damage_models_from_body_style(body_style);
    self dlchd_origins_zombie_gib_pieces();
    self.gibdef = self dlchd_origins_zombie_gib_def_from_hatmodel(hat_model);
    self.destructibledef = self.destructibledef_old; //"c_zm_dlchd_origins_soldier_destructible_def" was not exported AFAIK
    self fix_gibs();
}

function private dlchd_origins_zombie_damage_models_from_body_style(body_style) // self == zombie
{
    switch (body_style)
    {
        case "c_t7_zm_dlchd_origins_soldiers_body1":
            self dlchd_origins_zombie_damage_model_1();
            break;
        case "c_t7_zm_dlchd_origins_soldiers_body2":
            self dlchd_origins_zombie_damage_model_2();
            break;
        case "c_t7_zm_dlchd_origins_soldiers_body2a":
            self dlchd_origins_zombie_damage_model_2a();
            break;
        case "c_t7_zm_dlchd_origins_soldiers_body3":
            self dlchd_origins_zombie_damage_model_3();
            break;
        case "c_t7_zm_dlchd_origins_soldiers_body3a":
            self dlchd_origins_zombie_damage_model_3a();
            break;
            
    }
}

function private dlchd_origins_zombie_gib_pieces() // self == zombie
{
    self.gibspawn1 = "c_t7_zm_dlchd_origins_soldiers_s_rarmoff";
    self.gibspawntag1 = "j_elbow_ri";
    self.gibspawn2 = "c_t7_zm_dlchd_origins_soldiers_s_larmoff";
    self.gibspawntag2 = "j_elbow_le";
    self.gibspawn3 = "c_t7_zm_dlchd_origins_soldiers_s_rlegoff";
    self.gibspawntag3 = "j_knee_ri";
    self.gibspawn4 = "c_t7_zm_dlchd_origins_soldiers_s_llegoff";
    self.gibspawntag4 = "j_knee_le";
    
    self._gib_def = SpawnStruct();
    self._gib_def.gibspawn1 = "c_t7_zm_dlchd_origins_soldiers_s_rarmoff";
    self._gib_def.gibspawntag1 = "j_elbow_ri";
    self._gib_def.gibspawn2 = "c_t7_zm_dlchd_origins_soldiers_s_larmoff";
    self._gib_def.gibspawntag2 = "j_elbow_le";
    self._gib_def.gibspawn3 = "c_t7_zm_dlchd_origins_soldiers_s_rlegoff";
    self._gib_def.gibspawntag3 = "j_knee_ri";
    self._gib_def.gibspawn4 = "c_t7_zm_dlchd_origins_soldiers_s_llegoff";
    self._gib_def.gibspawntag4 = "j_knee_le";
}

function private dlchd_origins_zombie_gib_def_from_hatmodel(hatmodel) // self == zombie
{
    switch (hatmodel)
    {
        case "c_t7_zm_dlchd_origins_soldiers_helmet":
            return "c_zom_dlchd_origins_zombie_helmet_gib_def";
        case "c_t7_zm_dlchd_origins_soldiers_officer_cap":
            return "c_zom_dlchd_origins_zombie_officer_gib_def";
        case "c_t7_zm_dlchd_origins_soldiers_spiked_helmet":
            return "c_zom_dlchd_origins_zombie_spiked_helmet_gib_def";
        default: // no hatmodel (empty string)
            return "c_zom_dlchd_origins_zombie_none_gib_def";
    }
}

function private dlchd_origins_zombie_damage_model_1() // self == zombie
{
    self.torsodmg1 = "c_t7_zm_dlchd_origins_soldiers_body1_upperclean";
    self.torsodmg2 = "c_t7_zm_dlchd_origins_soldiers_body1_rarmoff";
    self.torsodmg3 = "c_t7_zm_dlchd_origins_soldiers_body1_larmoff";
    self.torsodmg4 = "c_t7_zm_dlchd_origins_soldiers_body1_upperclean";
    self.torsodmg5 = "c_t7_zm_dlchd_origins_soldiers_body1_beheaded";

    self.legdmg1 = "c_t7_zm_dlchd_origins_soldiers_body1_lowclean";
    self.legdmg2 = "c_t7_zm_dlchd_origins_soldiers_body1_rlegoff";
    self.legdmg3 = "c_t7_zm_dlchd_origins_soldiers_body1_llegoff";
    self.legdmg4 = "c_t7_zm_dlchd_origins_soldiers_body1_blegsoff";
}

function private dlchd_origins_zombie_damage_model_2() // self == zombie
{
    self.torsodmg1 = "c_t7_zm_dlchd_origins_soldiers_body2_upperclean";
    self.torsodmg2 = "c_t7_zm_dlchd_origins_soldiers_body2_rarmoff";
    self.torsodmg3 = "c_t7_zm_dlchd_origins_soldiers_body2_larmoff";
    self.torsodmg4 = "c_t7_zm_dlchd_origins_soldiers_body2_upperclean";
    self.torsodmg5 = "c_t7_zm_dlchd_origins_soldiers_body1_beheaded";

    self.legdmg1 = "c_t7_zm_dlchd_origins_soldiers_body2_lowclean";
    self.legdmg2 = "c_t7_zm_dlchd_origins_soldiers_body2_rlegoff";
    self.legdmg3 = "c_t7_zm_dlchd_origins_soldiers_body2_llegoff";
    self.legdmg4 = "c_t7_zm_dlchd_origins_soldiers_body1_blegsoff";
}

function private dlchd_origins_zombie_damage_model_2a() // self == zombie
{
    self.torsodmg1 = "c_t7_zm_dlchd_origins_soldiers_body2a_upperclean";
    self.torsodmg2 = "c_t7_zm_dlchd_origins_soldiers_body2a_rarmoff";
    self.torsodmg3 = "c_t7_zm_dlchd_origins_soldiers_body2a_larmoff";
    self.torsodmg4 = "c_t7_zm_dlchd_origins_soldiers_body2a_upperclean";
    self.torsodmg5 = "c_t7_zm_dlchd_origins_soldiers_body1_beheaded";

    self.legdmg1 = "c_t7_zm_dlchd_origins_soldiers_body2a_lowclean";
    self.legdmg2 = "c_t7_zm_dlchd_origins_soldiers_body2a_rlegoff";
    self.legdmg3 = "c_t7_zm_dlchd_origins_soldiers_body2a_llegoff";
    self.legdmg4 = "c_t7_zm_dlchd_origins_soldiers_body2a_blegsoff";
}

function private dlchd_origins_zombie_damage_model_3() // self == zombie
{
    self.torsodmg1 = "c_t7_zm_dlchd_origins_soldiers_body3_upperclean";
    self.torsodmg2 = "c_t7_zm_dlchd_origins_soldiers_body3_rarmoff";
    self.torsodmg3 = "c_t7_zm_dlchd_origins_soldiers_body3_larmoff";
    self.torsodmg4 = "c_t7_zm_dlchd_origins_soldiers_body3_upperclean";
    self.torsodmg5 = "c_t7_zm_dlchd_origins_soldiers_body1_beheaded";

    self.legdmg1 = "c_t7_zm_dlchd_origins_soldiers_body2_lowclean";
    self.legdmg2 = "c_t7_zm_dlchd_origins_soldiers_body2_rlegoff";
    self.legdmg3 = "c_t7_zm_dlchd_origins_soldiers_body2_llegoff";
    self.legdmg4 = "c_t7_zm_dlchd_origins_soldiers_body1_blegsoff";
}

function private dlchd_origins_zombie_damage_model_3a() // self == zombie
{
    self.torsodmg1 = "c_t7_zm_dlchd_origins_soldiers_body3_upperclean";
    self.torsodmg2 = "c_t7_zm_dlchd_origins_soldiers_body3_rarmoff";
    self.torsodmg3 = "c_t7_zm_dlchd_origins_soldiers_body3_larmoff";
    self.torsodmg4 = "c_t7_zm_dlchd_origins_soldiers_body3_upperclean";
    self.torsodmg5 = "c_t7_zm_dlchd_origins_soldiers_body1_beheaded";

    self.legdmg1 = "c_t7_zm_dlchd_origins_soldiers_body2a_lowclean";
    self.legdmg2 = "c_t7_zm_dlchd_origins_soldiers_body2a_rlegoff";
    self.legdmg3 = "c_t7_zm_dlchd_origins_soldiers_body2a_llegoff";
    self.legdmg4 = "c_t7_zm_dlchd_origins_soldiers_body2a_blegsoff";
}

// #endregion
// #region charred zombies

function set_zombie_model_to_hellround() // self == zombie
{
    self.skeleton = "base";
    self.voice = "american";

    self DetachAll();
    self.head = "c_zom_dlc4_zombie_charred_head";
    self Attach(self.head, "", true);
    self SetModel("c_zom_dlc3_zombie_sentinel_body");

    self.torsodmg1 = "c_zom_dlc3_zombie_sentinel_g_upclean";
    self.torsodmg2 = "c_zom_dlc3_zombie_sentinel_g_rarmoff";
    self.torsodmg3 = "c_zom_dlc3_zombie_sentinel_g_larmoff";
    self.torsodmg4 = "c_zom_dlc3_zombie_sentinel_g_upclean";
    self.torsodmg5 = "c_zom_dlc3_zombie_sentinel_g_behead";

    self.legdmg1 = "c_zom_dlc3_zombie_sentinel_g_lowclean";
    self.legdmg2 = "c_zom_dlc3_zombie_sentinel_g_rlegoff";
    self.legdmg3 = "c_zom_dlc3_zombie_sentinel_g_llegoff";
    self.legdmg4 = "c_zom_dlc3_zombie_sentinel_g_blegsoff";

    self.gibdef = "c_zom_charred_zombie_gib_def";
    self.destructibledef_old = self.destructibledef;
    self.destructibledef = "c_zom_dlc3_zombie_sentinel_destructibledef";

    self.gibspawn1 = "c_zom_dlc3_zombie_sentinel_s_rarmspawn";
    self.gibspawntag1 = "j_elbow_ri";
    self.gibspawn2 = "c_zom_dlc3_zombie_sentinel_s_larmspawn";
    self.gibspawntag2 = "j_elbow_le";
    self.gibspawn3 = "c_zom_dlc3_zombie_sentinel_s_rlegspawn";
    self.gibspawntag3 = "j_knee_ri";
    self.gibspawn4 = "c_zom_dlc3_zombie_sentinel_s_llegspawn";
    self.gibspawntag4 = "j_knee_le";
    
    self._gib_def = SpawnStruct();
    self._gib_def.gibspawn1 = "c_zom_dlc3_zombie_sentinel_s_rarmspawn";
    self._gib_def.gibspawntag1 = "j_elbow_ri";
    self._gib_def.gibspawn2 = "c_zom_dlc3_zombie_sentinel_s_larmspawn";
    self._gib_def.gibspawntag2 = "j_elbow_le";
    self._gib_def.gibspawn3 = "c_zom_dlc3_zombie_sentinel_s_rlegspawn";
    self._gib_def.gibspawntag3 = "j_knee_ri";
    self._gib_def.gibspawn4 = "c_zom_dlc3_zombie_sentinel_s_llegspawn";
    self._gib_def.gibspawntag4 = "j_knee_le";

    self fix_gibs();
}

// #endregion

function private fix_gibs() // self == zombie
{
    self.gib_data = SpawnStruct();
    self.gib_data.head = self.head;
    self.gib_data.gibdef = self.gibdef;
    self.gib_data.legdmg1 = self.legdmg1;
    self.gib_data.legdmg2 = self.legdmg2;
    self.gib_data.legdmg3 = self.legdmg3;
    self.gib_data.legdmg4 = self.legdmg4;
    self.gib_data.hatmodel = self.hatmodel;
    self.gib_data.torsodmg1 = self.torsodmg1;
    self.gib_data.torsodmg2 = self.torsodmg2;
    self.gib_data.torsodmg3 = self.torsodmg3;
    self.gib_data.torsodmg4 = self.torsodmg4;
    self.gib_data.torsodmg5 = self.torsodmg5;
    self.gib_data.gearmodel = self.gearmodel;
    self.gib_data.destructibledef = self.destructibledef;
}
