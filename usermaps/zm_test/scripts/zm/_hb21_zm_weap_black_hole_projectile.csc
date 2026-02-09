#using scripts\codescripts\struct;
#using scripts\shared\ai\zombie_vortex;
#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\zm\_zm;
#using scripts\zm\_zm_weapons;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_hb21_zm_weap_black_hole_projectile.gsh;

#namespace hb21_zm_weap_black_hole_projectile;

#precache("client_fx", BLACK_HOLE_BOMB_PORTAL_FX);
#precache("client_fx", BLACK_HOLE_BOMB_EVENT_HORIZON_FX);
#precache("client_fx", BLACK_HOLE_BOMB_MARKER_FLARE_FX);
#precache("client_fx", BLACK_HOLE_BOMB_ZOMBIE_PULL_FX);

REGISTER_SYSTEM_EX("hb21_zm_weap_black_hole_projectile", &__init__, undefined, undefined)

// ============================== INITIALIZE ==============================

function __init__()
{
    // # CLIENTFIELD REGISTRATION
    clientfield::register("toplayer", BHB_TOGGLE_LIGHTS_CF, VERSION_SHIP, 2, "int", &bhb_viewlights, 0, 0);
    clientfield::register("scriptmover", BHB_TOGGLE_DEPLOYED_CF, VERSION_SHIP, 1, "int", &black_hole_deployed, 0, 0);
    clientfield::register("actor", BHB_TOGGLE_BEING_PULLED_CF, VERSION_SHIP, 1, "int", &black_hole_zombie_being_pulled, 0, 1);
    // # CLIENTFIELD REGISTRATION
    
    // # VISION REGISTRATION
    visionset_mgr::register_visionset_info(BHB_VISION, VERSION_SHIP, 30, undefined, BHB_VISION);
    // # VISION REGISTRATION
    
    // # VARIABLES AND SETTINGS
    level._current_black_hole_bombs = [];
    level._visionset_black_hole_bomb = BHB_VISION;
    level._visionset_black_hole_bomb_transition_time_in = 2;
    level._visionset_black_hole_bomb_transition_time_out = 1;
    level._visionset_black_hole_bomb_priority = 10;
    // # VARIABLES AND SETTINGS
    
    // # REGISTER FX
    level._effect["black_hole_bomb_portal"] = BLACK_HOLE_BOMB_PORTAL_FX;
    level._effect["black_hole_bomb_event_horizon"] = BLACK_HOLE_BOMB_EVENT_HORIZON_FX;
    level._effect["black_hole_bomb_marker_flare"] = BLACK_HOLE_BOMB_MARKER_FLARE_FX;
    level._effect["black_hole_bomb_zombie_pull"] = BLACK_HOLE_BOMB_ZOMBIE_PULL_FX;
    // # REGISTER FX
}

// ============================== INITIALIZE ==============================

// ============================== FUNCTIONALITY ==============================

function bhb_viewlights(n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump)
{
    if (n_new_value)
        self mapShaderConstant(n_local_client_num, 0, "scriptVector2", 0, 100, n_new_value, 0);
    else
        self mapShaderConstant(n_local_client_num, 0, "scriptVector2", 0, 0, 0, 0);
    
}

function black_hole_deployed(n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump)
{
    if (n_local_client_num != 0)
        return;
    
    a_players = getLocalPlayers();
    for (i = 0; i < a_players.size; i++)
        level thread black_hole_fx_start(i, self);
    
}

function black_hole_fx_start(n_local_client_num, e_bomb)
{
    e_bomb_fx_spot = spawn(n_local_client_num, e_bomb.origin, "script_model");
    e_bomb_fx_spot setModel("tag_origin");
    playSound(0, BHB_PORTAL_START_SND, e_bomb_fx_spot.origin);
    e_bomb_fx_spot.e_sound = e_bomb_fx_spot playLoopSound(BHB_PORTAL_LOOP_SND);
    playFXOnTag(n_local_client_num, level._effect["black_hole_bomb_portal"], e_bomb_fx_spot, "tag_origin");
    playFXOnTag(n_local_client_num, level._effect["black_hole_bomb_marker_flare"], e_bomb_fx_spot, "tag_origin");
    e_bomb waittill("entityshutdown");
    if (isDefined(e_bomb_fx_spot.e_sound))
        e_bomb_fx_spot stopLoopSound(e_bomb_fx_spot.e_sound);
    
    e_event_horizon_spot = spawn(n_local_client_num, e_bomb_fx_spot.origin, "script_model");
    e_event_horizon_spot setModel("tag_origin");
    e_bomb_fx_spot delete();
    playFXOnTag(n_local_client_num, level._effect["black_hole_bomb_event_horizon"], e_event_horizon_spot, "tag_origin");
    wait .2;
    e_event_horizon_spot delete();
}

function black_hole_activated(e_model, n_local_client_num)
{
    s_new_black_hole_struct = spawnStruct();
    s_new_black_hole_struct.origin = e_model.origin;
    s_new_black_hole_struct._black_hole_active = 1;
    array::add(level._current_black_hole_bombs, s_new_black_hole_struct);
    e_model waittill("entityshutdown");
    s_new_black_hole_struct._black_hole_active = 0;
    wait .2;
}

function black_hole_zombie_being_pulled(n_local_client_num, n_old_value, n_new_value, b_new_ent, b_initial_snap, str_field, b_was_time_jump)
{
    self endon("death");
    self endon("entityshutdown");
    if (n_local_client_num != 0)
        return;
    
    if (n_new_value)
    {
        self._bhb_pulled_in_fx = spawn(n_local_client_num, self.origin, "script_model");
        self._bhb_pulled_in_fx.angles = self.angles;
        self._bhb_pulled_in_fx linkTo(self, "tag_origin");
        self._bhb_pulled_in_fx setModel("tag_origin");
        level thread black_hole_bomb_pulled_in_fx_clean(self, self._bhb_pulled_in_fx);
        a_players = getLocalPlayers();
        for (i = 0; i < a_players.size; i++)
            playFXOnTag(i, level._effect["black_hole_bomb_zombie_pull"], self._bhb_pulled_in_fx, "tag_origin");
        
    }
    else if (isDefined(self._bhb_pulled_in_fx))
    {
        self._bhb_pulled_in_fx notify("no_clean_up_needed");
        self._bhb_pulled_in_fx unLink();
        self._bhb_pulled_in_fx delete();
    }
}

function black_hole_bomb_pulled_in_fx_clean(e_zombie, e_fx_origin)
{
    e_fx_origin endon("no_clean_up_needed");
    if (!isDefined(e_zombie))
        return;
    
    e_zombie waittill("entityshutdown");
    if (isDefined(e_fx_origin))
        e_fx_origin delete();
    
}

// ============================== FUNCTIONALITY ==============================