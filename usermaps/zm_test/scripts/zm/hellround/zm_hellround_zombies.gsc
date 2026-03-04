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
	clientfield::register("actor", HRZM_ZOMBIE_BLOODBATH_CF, VERSION_SHIP, 1, "int");
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
        zombie enable_zombie_bloodbath(false);
    }
}

function private apply_hellround_events_to_zombie() // self == zombie actor
{
    self set_eye_glow_to_hellround();
    self thread set_zombie_model_to_hellround();
    self enable_zombie_bloodbath(true);

    if (HRZM_ZOMBIE_RUN_STATE_ENABLE)
    {
        self thread zombie_utility::set_zombie_run_cycle(HRZM_ZOMBIE_RUN_STATE);
    }

    if (isdefined(level.hellround_zombie_callback))
    {
        self [[ level.hellround_zombie_callback ]]();
    }
}

function private enable_zombie_bloodbath(is_enabled) // self == zombie actor
{
    is_enabled = IS_TRUE(is_enabled);
    level._effect["zombie_guts_explosion"] = (is_enabled ? HRZM_ZOMBIE_BLOODBATH_FX : HRZM_ZOMBIE_BLOODBATH_DEFAULT_FX);
    self clientfield::set(HRZM_ZOMBIE_BLOODBATH_CF, is_enabled);

    if (!is_enabled)
    {
        self notify(HRZM_BLOODBATH_NOTIFY);
    }
    else
    {
        self thread bloodbath_on_death();
    }
}

function private bloodbath_on_death()
{
    self endon(HRZM_BLOODBATH_NOTIFY);
    self waittill("death");
    if (isdefined(self))
    {
        self thread zombie_utility::zombie_gut_explosion();
	    self clientfield::set("zombie_gut_explosion", 1);
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
        case "bf3_helmet01":
            self bf3_helmet01();
            break;
        case "bf3_medic02":
            self bf3_medic02();
            break;
        case "bf3_medic03":
            self bf3_medic03();
            break;
        case "bf3_medic04":
            self bf3_medic04();
            break;            
    }
}

function private bf3_helmet01() // self == zombie
{
    self.torsodmg1 = "bf3_helmet01_upperclean";
    self.torsodmg2 = "bf3_helmet01_upper_arm_ri";
    self.torsodmg3 = "bf3_helmet01_upper_arm_le";
    self.torsodmg4 = "bf3_helmet01_upperclean";
    self.torsodmg5 = undefined;

    self.legdmg1 = "bf3_helmet01_legsclean";
    self.legdmg2 = "bf3_helmet01_legs_le";
    self.legdmg3 = "bf3_helmet01_legs_le";
    self.legdmg4 = "bf3_helmet01_legs_2";
}

function private bf3_medic02() // self == zombie
{
    self.torsodmg1 = "bf3_medic02_upperclean";
    self.torsodmg2 = "bf3_medic02_upper_ri";
    self.torsodmg3 = "bf3_medic02_upper_le";
    self.torsodmg4 = "bf3_medic02_upperclean";
    self.torsodmg5 = undefined;

    self.legdmg1 = "bf3_medic02_legsclean";
    self.legdmg2 = "bf3_medic02_legs_le";
    self.legdmg3 = "bf3_medic02_legs_le";
    self.legdmg4 = "bf3_medic02_legs_2";
}

function private bf3_medic03() // self == zombie
{
    self.torsodmg1 = "bf3_medic03_upperclean";
    self.torsodmg2 = "bf3_medic03_upper_ri";
    self.torsodmg3 = "bf3_medic03_upper_le";
    self.torsodmg4 = "bf3_medic03_upperclean";
    self.torsodmg5 = undefined;

    self.legdmg1 = "bf3_medic03_legsclean";
    self.legdmg2 = "bf3_medic03_legs_le";
    self.legdmg3 = "bf3_medic03_legs_le";
    self.legdmg4 = "bf3_medic03_legs_2";
}

function private bf3_medic04() // self == zombie
{
    self.torsodmg1 = "bf3_medic04_upperclean";
    self.torsodmg2 = "bf3_medic04_upper_ri";
    self.torsodmg3 = "bf3_medic04_upper_le";
    self.torsodmg4 = "bf3_medic04_upperclean";
    self.torsodmg5 = undefined;

    self.legdmg1 = "bf3_medic04_legsclean";
    self.legdmg2 = "bf3_medic04_legs_le";
    self.legdmg3 = "bf3_medic04_legs_le";
    self.legdmg4 = "bf3_medic04_legs_2";
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
