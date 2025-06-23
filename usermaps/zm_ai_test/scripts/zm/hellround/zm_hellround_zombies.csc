#using scripts\shared\util_shared; 
#using scripts\shared\clientfield_shared; 
#using scripts\shared\system_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\hellround\zm_hellround_zombies.gsh;

#namespace zm_hellround_zombies;

REGISTER_SYSTEM("zm_hellround_zombies", &init, undefined)

function init() 
{
    level.original_zombie_bodies = ORIGINAL_ZOMBIE_BODY_MODELS;
    level.original_zombie_hats = ORIGINAL_ZOMBIE_HAT_MODELS;
    level.original_zombie_heads = ORIGINAL_ZOMBIE_HEAD_MODELS;
    clientfield::register("actor", HELLROUND_ZOMBIE_MODEL_CF_NAME, VERSION_DLC4, 1, "int", &zombieSwitchModel, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);        
}

function private zombieSwitchModel(localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump)
{
    self endon("entityshutdown");

    self util::waittill_dobj(localClientNum);
    
    if (!IsDefined(self))
        return;

    if(newVal)
    {
        self set_zombie_model_to_hellround();
    }
    else
    {
        self set_back_to_default_zombie();
    }
}

// #region original zombie models

function private set_back_to_default_zombie() // self == zombie
{
    IPrintLnBold("Restoring zombie model to previous version");

    self.head = self.head_old;

    self.torsodmg1 = self.torsodmg1_old;
    self.torsodmg2 = self.torsodmg2_old;
    self.torsodmg3 = self.torsodmg3_old;
    self.torsodmg4 = self.torsodmg4_old;
    self.torsodmg5 = self.torsodmg5_old;

    self.legdmg1 = self.legdmg1_old;
    self.legdmg2 = self.legdmg2_old;
    self.legdmg3 = self.legdmg3_old;
    self.legdmg4 = self.legdmg4_old;
    
    self.gibdef = self.gibdef_old;
    self.destructibledef = self.destructibledef_old;

    self.gibspawn1 = self.gibspawn1_old;
    self.gibspawn2 = self.gibspawn2_old;
    self.gibspawn3 = self.gibspawn3_old;
    self.gibspawn4 = self.gibspawn4_old;
    self.gibspawntag1 = self.gibspawntag1_old;
    self.gibspawntag2 = self.gibspawntag2_old;
    self.gibspawntag3 = self.gibspawntag3_old;
    self.gibspawntag4 = self.gibspawntag4_old;
    
    self._gib_def = self._gib_def_old;

    self fix_gibs();
}

function private dlchd_origins_zombie_gib_pieces() // self == zombie
{
}

function private dlchd_origins_zombie_damage_model_1() // self == zombie
{
    self.torsodmg1 = self.torsodmg1_old;
}

// #endregion

// #region charred zombies

function private set_zombie_model_to_hellround() // self == zombie
{
    IPrintLnBold("Setting zombie model to Hellround version");

    self.head_old = self.head;
    self.head     = "c_zom_dlc4_zombie_charred_head";

    self.torsodmg1_old = self.torsodmg1;
    self.torsodmg2_old = self.torsodmg2;
    self.torsodmg3_old = self.torsodmg3;
    self.torsodmg4_old = self.torsodmg4;
    self.torsodmg5_old = self.torsodmg5;
    self.torsodmg1     = "c_zom_dlc3_zombie_sentinel_g_upclean";
    self.torsodmg2     = "c_zom_dlc3_zombie_sentinel_g_rarmoff";
    self.torsodmg3     = "c_zom_dlc3_zombie_sentinel_g_larmoff";
    self.torsodmg4     = "c_zom_dlc3_zombie_sentinel_g_upclean";
    self.torsodmg5     = "c_zom_dlc3_zombie_sentinel_g_behead";

    self.legdmg1_old = self.legdmg1;
    self.legdmg2_old = self.legdmg2;
    self.legdmg3_old = self.legdmg3;
    self.legdmg4_old = self.legdmg4;
    self.legdmg1     = "c_zom_dlc3_zombie_sentinel_g_lowclean";
    self.legdmg2     = "c_zom_dlc3_zombie_sentinel_g_rlegoff";
    self.legdmg3     = "c_zom_dlc3_zombie_sentinel_g_llegoff";
    self.legdmg4     = "c_zom_dlc3_zombie_sentinel_g_blegsoff";
    
    self.gibdef_old = self.gibdef; 
    self.gibdef     = "c_zom_charred_zombie_gib_def";

    self.destructibledef_old = self.destructibledef;
    self.destructibledef     = "c_zom_dlc3_zombie_sentinel_destructibledef";

    self.gibspawn1_old = self.gibspawn1;
    self.gibspawn2_old = self.gibspawn2;
    self.gibspawn3_old = self.gibspawn3;
    self.gibspawn4_old = self.gibspawn4;
    self.gibspawn1     = "c_zom_dlc3_zombie_sentinel_s_rarmspawn";
    self.gibspawn2     = "c_zom_dlc3_zombie_sentinel_s_larmspawn";
    self.gibspawn3     = "c_zom_dlc3_zombie_sentinel_s_rlegspawn";
    self.gibspawn4     = "c_zom_dlc3_zombie_sentinel_s_llegspawn";

    self.gibspawntag1_old = self.gibspawntag1;
    self.gibspawntag2_old = self.gibspawntag2;
    self.gibspawntag3_old = self.gibspawntag3;
    self.gibspawntag4_old = self.gibspawntag4;
    self.gibspawntag1     = "j_elbow_ri";
    self.gibspawntag2     = "j_elbow_le";
    self.gibspawntag3     = "j_knee_ri";
    self.gibspawntag4     = "j_knee_le";
    
    self._gib_def_old = self._gib_def;
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
