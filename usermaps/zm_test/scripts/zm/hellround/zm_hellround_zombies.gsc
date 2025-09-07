#using scripts\shared\clientfield_shared; 
#using scripts\shared\ai\systems\gib; 
#using scripts\shared\ai\systems\destructible_character; 
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

#precache("fx", HRZM_ZOMBIE_EYE_GLOW_HELLROUND);
#precache("fx", HRZM_ZOMBIE_EYE_GLOW_NORMAL);
#precache("model", "c_zom_dlc3_zombie_sentinel_body");
#precache("model", "c_zom_dlc4_zombie_charred_head");

REGISTER_SYSTEM_EX("zm_hellround_zombies", &init, &main, undefined)

function init() 
{
    level.original_zombie_bodies = ORIGINAL_ZOMBIE_BODY_MODELS;
    level.hellround_zombie_callback = undefined;
}

function private main()
{
    clientfield::register("world", HRZM_ZOMBIE_EYE_GLOW_CF, VERSION_SHIP, 1, "int");
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
        // Removing the below line will cause the zombie model to not be updated after it spawned.
        waittillframeend;

        self thread apply_hellround_events_to_zombie();
    }
}

function toggle_hellround_zombies(b_enable)
{
    wait HRZM_ZOMBIE_TIME_BEFORE_TOGGLE;
    
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
            zombie thread apply_hellround_events_to_zombie();
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

        zombie set_back_to_default_eye_glow();
        zombie thread set_back_to_default_zombie();
        zombie thread zm_utility::init_zombie_run_cycle();
    }
}

function private apply_hellround_events_to_zombie() // self == zombie actor
{
    self set_eye_glow_to_hellround();
    self thread set_zombie_model_to_hellround();

    if (HRZM_ZOMBIE_RUN_STATE_ENABLE)
    {
        self thread zombie_utility::set_zombie_run_cycle(HRZM_ZOMBIE_RUN_STATE);
    }

    if (isdefined(level.hellround_zombie_callback))
    {
        self [[ level.hellround_zombie_callback ]]();
    }
}

/* region original zombie models */

function set_back_to_default_eye_glow() // self == zombie
{
    if (!isdefined(self) || !IsAlive(self))
    {
        return;
    }
    self clientfield::set("zombie_has_eyes", 0);

    WAIT_SERVER_FRAME;
    level._effect["eye_glow"] = HRZM_ZOMBIE_EYE_GLOW_NORMAL;
    level clientfield::set(HRZM_ZOMBIE_EYE_GLOW_CF, 0);
    WAIT_SERVER_FRAME;
    
    if (!isdefined(self) || !IsAlive(self))
    {
        return;
    }
    self clientfield::set("zombie_has_eyes", 1);
}

function set_back_to_default_zombie() // self == zombie
{
    if (!isdefined(self) || !IsAlive(self))
    {
        return;
    }

    body_style = level.original_zombie_bodies[RandomInt(level.original_zombie_bodies.size)];

    self DetachAll();
    if (isdefined(self.hatmodel_old) && self.hatmodel_old != "")
    {
        self.hatmodel = self.hatmodel_old;
        self Attach(self.hatmodel, "", true);
    }
    // Seems like self.head_old isn't defined everytime...
    self.head = (isdefined(self.head_old) ? self.head_old : array::random(ORIGINAL_ZOMBIE_HEAD_MODELS));
    self Attach(self.head, "", true);
    self SetModel(body_style);

    self.destructibledef = self.destructibledef_old;
    
    self dlchd_origins_zombie_damage_models_from_body_style(body_style);

    GibServerUtils::ToggleSpawnGibs(self, true);
    DestructServerUtils::ToggleSpawnGibs(self, true);
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

/* endregion */
/* region charred zombies */

function set_eye_glow_to_hellround() // self == zombie
{
    if (!isdefined(self) || !IsAlive(self))
    {
        return;
    }
    self clientfield::set("zombie_has_eyes", 0);

    WAIT_SERVER_FRAME;
    level._effect["eye_glow"] = HRZM_ZOMBIE_EYE_GLOW_HELLROUND;
    level clientfield::set(HRZM_ZOMBIE_EYE_GLOW_CF, 1);
    WAIT_SERVER_FRAME;
    
    if (!isdefined(self) || !IsAlive(self))
    {
        return;
    }
    self clientfield::set("zombie_has_eyes", 1);
}

function set_zombie_model_to_hellround() // self == zombie
{
    if (!isdefined(self) || !IsAlive(self))
    {
        return;
    }

    self.hatmodel_old = self.hatmodel;
    self.hatmodel = undefined;

    self.head_old = self.head;
    self.head = "c_zom_dlc4_zombie_charred_head";

    self DetachAll();
    self Attach(self.head, "", true);
    self SetModel("c_zom_dlc3_zombie_sentinel_body");

    self.destructibledef_old = self.destructibledef;
    self.destructibledef = undefined;

    self.torsodmg1 = "c_zom_dlc3_zombie_sentinel_g_upclean";
    self.torsodmg2 = "c_zom_dlc3_zombie_sentinel_g_rarmoff";
    self.torsodmg3 = "c_zom_dlc3_zombie_sentinel_g_larmoff";
    self.torsodmg4 = "c_zom_dlc3_zombie_sentinel_g_upclean";
    self.torsodmg5 = "c_zom_dlc3_zombie_sentinel_g_behead";

    self.legdmg1 = "c_zom_dlc3_zombie_sentinel_g_lowclean";
    self.legdmg2 = "c_zom_dlc3_zombie_sentinel_g_rlegoff";
    self.legdmg3 = "c_zom_dlc3_zombie_sentinel_g_llegoff";
    self.legdmg4 = "c_zom_dlc3_zombie_sentinel_g_blegsoff";

    GibServerUtils::ToggleSpawnGibs(self, false);
    DestructServerUtils::ToggleSpawnGibs(self, false);
}

/* endregion */
