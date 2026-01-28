#using scripts\codescripts\struct;
#using scripts\shared\ai_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\duplicaterender_mgr;
#using scripts\shared\duplicaterenderbundle;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_hb21_zm_weap_staff_utility;

#insert scripts\shared\duplicaterender.gsh;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_hb21_zm_weap_staff_fire.gsh;
#insert scripts\zm\_hb21_zm_weap_staff_utility.gsh;

#namespace hb21_zm_weap_staff_fire; 

#precache("client_fx", FIRESTAFF_CHARGE_LIGHT_FX);
#precache("client_fx", FIRESTAFF_VOLCANO_FX);

REGISTER_SYSTEM_EX("hb21_zm_weap_staff_fire", &__init__, &__main__, undefined)

function __init__()
{
    level.a_staff_fire_weaponfiles = [];
    
    staff_fire_register_weapon_for_level("t9_1911_rdw_up_up");
    staff_fire_register_weapon_for_level("iw8_ak47_up_up");
    
    clientfield::register("scriptmover", FIRESTAFF_VOLCANO_CF, VERSION_SHIP, 1, "int", &staff_fire_volcano_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);
    clientfield::register("actor", FIRESTAFF_ZOMBIE_BURN_CF, VERSION_SHIP, 1, "int", &staff_fire_burn_zombie, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);
    clientfield::register("vehicle", FIRESTAFF_ZOMBIE_BURN_CF, VERSION_SHIP, 1, "int", &staff_fire_burn_zombie, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);
    
    ai::add_archetype_spawn_function("parasite", &staff_fire_parasite_init_cb);
    ai::add_archetype_spawn_function("zombie_dog", &staff_fire_dog_init_cb);	
    
    duplicate_render::set_dr_filter_framebuffer_duplicate("wab", 98, "world_actor_burn", undefined, DR_TYPE_FRAMEBUFFER_DUPLICATE, FIRESTAFF_BURN_MATERIAL, DR_CULL_NEVER);
}

function __main__()
{
}

/* 
STAFF FIRE REGISTER WEAPON FOR LEVEL
Description : This function handles registering this weapon file as a staff of fire variant and sets up some required properties
Notes : None
*/
function staff_fire_register_weapon_for_level(str_weapon)
{
    DEFAULT(level.a_staff_fire_weaponfiles, []);
    
    a_weapon_data = tableLookupRow(STAFF_FIRE_TABLE_FILE, tableLookupRowNum(STAFF_FIRE_TABLE_FILE, STAFF_TABLE_COLUMN_WEAPONFILE, str_weapon));
    if (!isDefined(a_weapon_data))
	{
        a_weapon_data = tableLookupRow(STAFF_FIRE_TABLE_FILE, tableLookupRowNum(STAFF_FIRE_TABLE_FILE, STAFF_TABLE_COLUMN_WEAPONFILE, "default"));
	}
    if (!isDefined(a_weapon_data))
	{
        return;
	}
        
    w_weapon = getWeapon(str_weapon);
    w_weapon.b_is_upgrade = (toLower(a_weapon_data[STAFF_TABLE_COLUMN_IS_UPGRADE]) == "true");
    w_weapon.n_damage = int(a_weapon_data[STAFF_TABLE_COLUMN_DAMAGE]);
    w_weapon.n_burn_damage = int(a_weapon_data[STAFF_FIRE_TABLE_COLUMN_BURN_DAMAGE]);
    w_weapon.n_burn_duration = float(a_weapon_data[STAFF_FIRE_TABLE_COLUMN_BURN_DURATION]);
    w_weapon.n_volcano_range = int(a_weapon_data[STAFF_FIRE_TABLE_COLUMN_VOLCANO_RANGE]);
    w_weapon.n_volcano_lifetime = float(a_weapon_data[STAFF_FIRE_TABLE_COLUMN_VOLCANO_LIFETIME]);
    
    hb21_zm_weap_staff_utility::register_staff_weapon_for_level(w_weapon, undefined, undefined, undefined, undefined, undefined, undefined, undefined, &staff_fire_charge_up_effects_cb, undefined, FIRESTAFF_CHARGE_LIGHT_FX);
    
    ARRAY_ADD(level.a_staff_fire_weaponfiles, w_weapon);
}

/* 
STAFF FIRE UPDATE CHARGE EFFECTS
Description : This function handles the effects and sounds when the charge level changes
Notes : None
*/
function staff_fire_charge_up_effects_cb(n_local_client_num, w_weapon, n_charge_level = 0)
{
    self hb21_zm_weap_staff_utility::play_staff_charge_up_sounds(n_local_client_num, w_weapon, n_charge_level, FIRESTAFF_CHARGE_SOUND + n_charge_level, (n_charge_level == 1 ? FIRESTAFF_CHARGE_LOOP_SOUND : undefined));
}

/* 
STAFF FIRE VOLCANO FX 
Description : This function creates or destroys the Staff of Fire AOE effect on an entity
Notes : None 
*/
function staff_fire_volcano_fx(n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump)
{
    if (IS_TRUE(n_new_value))
    {
        self.fx_fire_staff_volcano = playFxOnTag(n_local_client_num, FIRESTAFF_VOLCANO_FX, self, "tag_origin");
        self playRumbleOnEntity(n_local_client_num, FIRESTAFF_RUMBLE);
        self thread hb21_zm_weap_staff_utility::staff_shake_and_rumble(n_local_client_num, FIRESTAFF_RUMBLE_SCALE, FIRESTAFF_RUMBLE_DURATION, FIRESTAFF_RUMBLE_RADIUS, FIRESTAFF_RUMBLE);
        self thread hb21_zm_weap_staff_utility::staff_aoe_looping_sound(n_local_client_num, FIRESTAFF_PROJ_LOOP_SOUND, undefined, FIRESTAFF_PROJ_IMPACT_SOUND, 0);
    }
    else
    {
        self notify("staff_shake_and_rumble");
        self notify("staff_aoe_looping_sound_end");
        stopFx(n_local_client_num, self.fx_fire_staff_volcano);
        self.fx_fire_staff_volcano = undefined;
    }
}

/* 
STAFF FIRE BURN ZOMBIE
Description : This function handles setting up the fire fx on zombies that are on fire
Notes : None 
*/
function staff_fire_burn_zombie(localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasDemoJump)
{
    self endon("entityshutdown");
    rate = randomfloatrange(0.01, 0.015);
    if(isdefined(self.torso_fire_fx))
    {
        stopfx(localclientnum, self.torso_fire_fx);
        self.torso_fire_fx = undefined;
    }
    if(isdefined(self.head_fire_fx))
    {
        stopfx(localclientnum, self.head_fire_fx);
        self.head_fire_fx = undefined;
    }
    if(isdefined(self.sndent))
    {
        self.sndent notify("sndDeleting");
        self.sndent delete();
        self.sndent = undefined;
    }
    if(newval == 1)
    {
        self.torso_fire_fx = playfxontag(localclientnum, level._effect["character_fire_death_torso"], self, "j_spinelower");
        self.head_fire_fx = playfxontag(localclientnum, level._effect["character_fire_death_sm"], self, "j_head");
        self.sndent = spawn(0, self.origin, "script_origin");
        self.sndent linkto(self);
        self.sndent playloopsound("zmb_fire_loop", 0.5);
        self.sndent thread staff_fire_delete_sound_ent(self);

        if (IsAlive(self))
        {
        self duplicate_render::set_dr_flag("world_actor_burn", 1);
        self duplicate_render::update_dr_filters(localClientNum);
        if(!IS_TRUE(self.has_charred))
        {
            self mapshaderconstant(localclientnum, 2, "scriptVector3");
            self.has_charred = 1;
        }
        max_charamount = 1;
        char_amount = 0.6;
        for(i = 0; i < 2; i++)
        {
            for(alpha = 0; alpha <= 0.20; alpha += rate)
            {
                util::server_wait(localclientnum, 0.05);
                self setshaderconstant(localclientnum, 2, alpha, FIRESTAFF_BURN_BRIGHTNESS, FIRESTAFF_BURN_STATE, 0);
            }
            for(alpha = 0.20; alpha >= 0.0; alpha -= rate)
            {
                util::server_wait(localclientnum, 0.05);
                self setshaderconstant(localclientnum, 2, alpha, FIRESTAFF_BURN_BRIGHTNESS, FIRESTAFF_BURN_STATE, 0);
            }
        }
		self duplicate_render::set_dr_flag("world_actor_burn", 0);
		self duplicate_render::update_dr_filters(localClientNum);
        }
    }
}

/* 
STAFF FIRE DELETE SOUND ENT
Description : This function handles killing the burning sounds on a zombie
Notes : None 
*/
function staff_fire_delete_sound_ent(e_zombie)
{
    self endon("sndDeleting");
    e_zombie waittill("entityshutdown");
    self delete();
}

function staff_fire_parasite_init_cb()
{
}

function staff_fire_dog_init_cb()
{
}
