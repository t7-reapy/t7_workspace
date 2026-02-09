#using scripts\codescripts\struct;
#using scripts\shared\ai_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_hb21_zm_weap_staff_utility;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_hb21_zm_weap_staff_lightning.gsh;
#insert scripts\zm\_hb21_zm_weap_staff_utility.gsh;

#namespace hb21_zm_weap_staff_lightning; 

#precache("client_fx", LIGHTNINGSTAFF_IMPACT_FX);
#precache("client_fx", LIGHTNINGSTAFF_IMPACT_EYE_FX);
#precache("client_fx", LIGHTNINGSTAFF_BALL_FX);
#precache("client_fx", LIGHTNINGSTAFF_CHARGE_LIGHT_FX);

REGISTER_SYSTEM_EX("hb21_zm_weap_staff_lightning", &__init__, &__main__, undefined)

// ============================== DEVELOPER OVERRIDES AND CALLBACKS ==============================

// ai.str_staff_lightning_impact_fx_tag - STRING - set a tag name here to specfify the tag the fx for impact with an ai will play on, will default to "j_spineupper" otherwise. Use this if your ai does NOT have this tag

// ============================== DEVELOPER OVERRIDES AND CALLBACKS ==============================

function __init__()
{
    level.a_staff_lightning_weaponfiles = [];
    
    staff_lightning_register_weapon_for_level("t9_1911_ldw_up_up");
    staff_lightning_register_weapon_for_level("iw8_m4a1_up_up");
    
    clientfield::register("scriptmover", LIGHTNINGSTAFF_BALL_CF, VERSION_SHIP, 1, "int", &staff_lightning_ball_fx_cb, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);
    clientfield::register("actor", LIGHTNINGSTAFF_IMPACT_FX_CF, VERSION_SHIP, 1, "counter", &staff_lightning_impact_play_fx_cb, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);
    clientfield::register("vehicle", LIGHTNINGSTAFF_IMPACT_FX_VEH_CF, VERSION_SHIP, 1, "counter", &staff_lightning_impact_play_fx_cb, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);
    clientfield::register("actor", LIGHTNINGSTAFF_SHOCK_EYES_FX_CF, VERSION_SHIP, 1, "counter", &staff_lightning_shock_eyes_fx_cb, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);
    clientfield::register("vehicle", LIGHTNINGSTAFF_SHOCK_EYES_FX_VEH_CF, VERSION_SHIP, 1, "counter", &staff_lightning_shock_eyes_fx_cb, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);
    
    ai::add_archetype_spawn_function("parasite", &staff_lightning_parasite_init_cb);
}

/* 
MAIN 
Description : This function starts the script and will setup everything required - POST-load
Notes : None  
*/
function __main__()
{
}

/* 
STAFF LIGHTNING REGISTER WEAPON FOR LEVEL
Description : This function handles registering this weapon file as a staff of lightning variant and sets up some required properties
Notes : None
*/
function staff_lightning_register_weapon_for_level(str_weapon, ptr_weapon_fired_cb = undefined)
{
    DEFAULT(level.a_staff_lightning_weaponfiles, []);
    
    a_weapon_data = tableLookupRow(STAFF_LIGHTNING_TABLE_FILE, tableLookupRowNum(STAFF_LIGHTNING_TABLE_FILE, STAFF_TABLE_COLUMN_WEAPONFILE, str_weapon));
    if (!isDefined(a_weapon_data))
	{
        a_weapon_data = tableLookupRow(STAFF_LIGHTNING_TABLE_FILE, tableLookupRowNum(STAFF_LIGHTNING_TABLE_FILE, STAFF_TABLE_COLUMN_WEAPONFILE, "default"));
	}
    if (!isDefined(a_weapon_data))
	{
        return;
	}
        
    w_weapon = GetWeapon(str_weapon);
    w_weapon.b_is_upgrade = (toLower(a_weapon_data[STAFF_TABLE_COLUMN_IS_UPGRADE]) == "true");
    w_weapon.n_damage = int(a_weapon_data[STAFF_TABLE_COLUMN_DAMAGE]);
    w_weapon.n_min_damage = int(a_weapon_data[STAFF_LIGHTNING_TABLE_COLUMN_MIN_DAMAGE]);
    w_weapon.n_ball_move_distance = int(a_weapon_data[STAFF_LIGHTNING_TABLE_COLUMN_BALL_MOVE_DISTANCE]);
    w_weapon.n_ball_damage_per_second = int(a_weapon_data[STAFF_LIGHTNING_TABLE_COLUMN_BALL_DAMAGE_PER_SECOND]);
    w_weapon.n_ball_range = int(a_weapon_data[STAFF_LIGHTNING_TABLE_COLUMN_BALL_RADIUS]);
    
    hb21_zm_weap_staff_utility::register_staff_weapon_for_level(w_weapon, undefined, undefined, undefined, undefined, undefined, undefined, undefined, &staff_lightning_charge_up_effects_cb, undefined, LIGHTNINGSTAFF_CHARGE_LIGHT_FX);
    
    ARRAY_ADD(level.a_staff_lightning_weaponfiles, w_weapon);
}

/* 
STAFF LIGHTNING UPDATE CHARGE EFFECTS
Description : This function handles the effects and sounds when the charge level changes
Notes : None
*/
function staff_lightning_charge_up_effects_cb(n_local_client_num, w_weapon, n_charge_level = 0)
{
    self hb21_zm_weap_staff_utility::play_staff_charge_up_sounds(n_local_client_num, w_weapon, n_charge_level, LIGHTNINGSTAFF_CHARGE_SOUND + n_charge_level, (n_charge_level == 1 ? LIGHTNINGSTAFF_CHARGE_LOOP_SOUND : undefined));
}

/* 
STAFF LIGHTNING BALL FX 
Description : This function creates or destroys the Staff of Lightning BALL effect on an entity
Notes : None 
*/
function staff_lightning_ball_fx_cb(n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump)
{
    if (IS_TRUE(n_new_value))
    {
        self.fx_lightning_staff_ball = playFxOnTag(n_local_client_num, LIGHTNINGSTAFF_BALL_FX, self, "tag_origin");
        self playRumbleOnEntity(n_local_client_num, LIGHTNINGSTAFF_RUMBLE);
        self thread hb21_zm_weap_staff_utility::staff_shake_and_rumble(n_local_client_num, LIGHTNINGSTAFF_RUMBLE_SCALE, LIGHTNINGSTAFF_RUMBLE_DURATION, LIGHTNINGSTAFF_RUMBLE_RADIUS, LIGHTNINGSTAFF_RUMBLE);
        self thread hb21_zm_weap_staff_utility::staff_aoe_looping_sound(n_local_client_num, LIGHTNINGSTAFF_BALL_SOUND, undefined, undefined, 0);
    }
    else
    {
        self notify("staff_shake_and_rumble");
        self notify("staff_aoe_looping_sound_end");
        stopFx(n_local_client_num, self.fx_lightning_staff_ball);
        self.fx_lightning_staff_ball = undefined;
    }
}

/* 
STAFF LIGHTNING IMPACT PLAY FX CALLBACK
Description : This function handles the electrocuted torso fx on zombies
Notes : None 
*/
function staff_lightning_impact_play_fx_cb(n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump)
{
    self notify("staff_lightning_impact_play_fx");
    self endon("staff_lightning_impact_play_fx");
    self endon("entityshutdown");
    
    if (isDefined(self.fx_staff_lightning_impact_torso))
        stopFx(n_local_client_num, self.fx_staff_lightning_impact_torso);
        self.fx_staff_lightning_impact_torso = undefined;
    
    // if (n_new_value > (n_old_value + 1))
    //     return;
    
    str_tag = (isDefined(self.str_staff_lightning_impact_fx_tag) ? self.str_staff_lightning_impact_fx_tag : LIGHTNINGSTAFF_IMPACT_FX_TAG);
        
    self.fx_staff_lightning_impact_torso = playFxOnTag(n_local_client_num, LIGHTNINGSTAFF_IMPACT_FX, self, str_tag);
    setFxIgnorePause(n_local_client_num, self.fx_staff_lightning_impact_torso, 1);
    self playSound(n_local_client_num, LIGHTNINGSTAFF_IMPACT_SOUND);
    
    wait 2;
    
    if (isDefined(self.fx_staff_lightning_impact_torso))
        stopFx(n_local_client_num, self.fx_staff_lightning_impact_torso);
    
    self.fx_staff_lightning_impact_torso = undefined;
}

/* 
STAFF LIGHTNING SHOCK EYES FX CALLBACK
Description : This function handles the electrocuted eyes fx on zombies
Notes : None 
*/
function staff_lightning_shock_eyes_fx_cb(n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump)
{
    self notify("staff_lightning_shock_eyes_fx_callback");
    self endon("staff_lightning_shock_eyes_fx_callback");
    self endon("entityshutdown");
    
    if (isDefined(self.fx_staff_lightning_shock_eyes))
        stopFx(n_local_client_num, self.fx_staff_lightning_shock_eyes);
        self.fx_staff_lightning_shock_eyes = undefined;
    /*
    if (n_new_value > (n_old_value + 1))
    {
        iPrintLnBold("CSC CALL TO STOP EYE FX???");
        return;
    }
    */
    self.fx_staff_lightning_shock_eyes = playFxOnTag(n_local_client_num, LIGHTNINGSTAFF_IMPACT_EYE_FX, self, "j_eyeball_le");
    setFxIgnorePause(n_local_client_num, self.fx_staff_lightning_shock_eyes, 1);
    
    wait 2;
    
    if (isDefined(self.fx_staff_lightning_shock_eyes))
        stopFx(n_local_client_num, self.fx_staff_lightning_shock_eyes);
    
    self.fx_staff_lightning_shock_eyes = undefined;
}

function staff_lightning_parasite_init_cb()
{
    self.str_staff_lightning_impact_fx_tag = "j_spine1";
}
