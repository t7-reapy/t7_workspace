
#using scripts\codescripts\struct;

#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\shared\postfx_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_ai_wasp.gsh;

#using scripts\zm\_util;
#using scripts\zm\_zm_equipment;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_utility;

#using scripts\shared\ai_shared;
#insert scripts\zm\zm_cellbreaker.gsh;

#namespace zm_cellbreaker;

#precache("client_fx", "custom/AI/cellbreaker_helmet");
#precache("client_fx", "custom/AI/cellbreaker_lamp");

#precache("client_fx", "custom/AI/cellbreaker_spawn");
#precache("client_fx", "custom/AI/cellbreaker_death");

#precache("client_fx", "custom/AI/cellbreaker_footstep");
#precache("client_fx", "custom/AI/cellbreaker_teleport");

#precache("client_model", "c_zom_cellbreaker_helmet");

REGISTER_SYSTEM("zm_cellbreaker", &__init__, undefined)

function __init__()
{
    clientfield::register("actor", "brutus_fx", VERSION_SHIP, 2, "int", &brutus_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);
    clientfield::register("actor", "brutus_lamp_fx", VERSION_SHIP, 1, "int", &brutus_lamp_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);
    clientfield::register("scriptmover", "brutus_tp_fx", VERSION_SHIP, 1, "int", &brutus_tp_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);

    ai::add_archetype_spawn_function("cellbreaker", &brutus_spawn);
}


function private brutus_spawn(localClientNum)
{
    level._footstepCBFuncs[ self.archetype ] = &brutusFootstep;
    PlayFX(localClientNum, "custom/AI/cellbreaker_spawn", self.origin, AnglesToForward(self.angles));
}

function private brutus_fx(n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump) //self = brutus
{
    if(n_new_value == 1 && !isdefined(self.helmetfx)) //helmet
    {
        pos = self GetTagOrigin("j_head");
        ang = self GetTagAngles("j_head");
        helmet = CreateDynEntAndLaunch(n_local_client_num, "c_zom_cellbreaker_helmet", pos, ang, pos, (0,0,1));
        self.helmetfx = playFxOnTag(n_local_client_num, "custom/AI/cellbreaker_helmet", self, "j_head");
    }

    if(n_new_value == 2) //death
    {
        deathfx = PlayFXOnTag(n_local_client_num, "custom/AI/cellbreaker_death", self, "j_spineupper");
        self playsound(0, "zmb_ai_cellbreaker_vox_death");
    }

    if(n_new_value == 3) //tp in
    {
        deathfx = PlayFXOnTag(n_local_client_num, "custom/AI/cellbreaker_death", self, "j_spineupper");
    }
}

function private brutus_tp_fx(n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump) //self = brutus
{
    if(n_new_value == 1) 
    {
        self.travelerfx = PlayFXOnTag(n_local_client_num, "custom/AI/cellbreaker_teleport", self, "tag_origin");
    }

    if(n_new_value == 0) 
    {
        self.travelerfx Delete();
    }
}

function brutus_lamp_fx(n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field_name, b_was_time_jump) //self = brutus
{
    //IPrintLnBold("lamp");
    if(n_new_value == 1)
    {
        self.flashlightfx = playFxOnTag(n_local_client_num, "custom/AI/cellbreaker_lamp", self, "j_spineupper");
    }
    else if(n_new_value == 0 && isdefined(self.flashlightfx))
    {
        StopFX(n_local_client_num, self.flashlightfx);
    }

}

function brutusFootstep(localClientNum, pos, surface, notetrack, bone)
{
    e_player = GetLocalPlayer(localClientNum);
    n_dist = DistanceSquared(pos, e_player.origin);
    n_mechz_dist = (500 * 500);
    if(n_mechz_dist>0)
    {
        n_scale = (n_mechz_dist - n_dist) / n_mechz_dist;
    }
    else
    {
        return;
    }
    
    if(n_scale > 1 || n_scale < 0) 
    {
        return;
    }
        
    if(n_scale <= 0.01)
    {
        return;
    }
    
    earthquake_scale = n_scale * 0.1;
    
    if(surface == "water")
    {
        return;
    }

    if(earthquake_scale > 0.01)
    {
        e_player Earthquake(earthquake_scale, 0.1, pos, n_dist);
    }
    
    if(n_scale <= 1 && n_scale > 0.8)
    {
        e_player PlayRumbleOnEntity(localClientNum, "shotgun_fire");
    }
    
    else if(n_scale <= 0.8 && n_scale > 0.4)
    {
        e_player PlayRumbleOnEntity(localClientNum, "damage_heavy");
    }
    else
    {
        e_player PlayRumbleOnEntity(localClientNum, "reload_small");
    }
    
    fx = PlayFXOnTag(localClientNum, "custom/AI/cellbreaker_footstep", self, bone);
}
