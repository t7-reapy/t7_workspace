#using scripts\codescripts\struct;
#using scripts\shared\system_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_hb21_zm_weap_magmagat.gsh;

#namespace hb21_zm_weap_magmagat; 

#precache("client_fx", MAGMAGAT_AOE_FX);
#precache("client_fx", MAGMAGAT_IMPACT_FX);

REGISTER_SYSTEM_EX("hb21_zm_weap_magmagat", &__init__, &__main__, undefined)

function __init__()
{
    clientfield::register("missile", "magmagat_missile", VERSION_SHIP, 1, "int", &magmagat_missile, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);
    
    level._effect["magmagat_aoe"] = MAGMAGAT_AOE_FX;
    level._effect["magmagat_impact"] = MAGMAGAT_IMPACT_FX;
}

function __main__()
{
}

function magmagat_missile(n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump)
{
    if (!IS_TRUE(n_new_value))
        return;
    
    playFxOnTag(n_local_client_num, level._effect["magmagat_aoe"], self, "tag_origin");
    playFx(n_local_client_num, level._effect["magmagat_impact"], self.origin, anglesToUp(self.angles));
}
