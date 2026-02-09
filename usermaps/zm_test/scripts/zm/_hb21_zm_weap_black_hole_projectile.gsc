#using scripts\codescripts\struct;
#using scripts\shared\callbacks_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\ai\zombie_vortex;
#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\sound_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\shared\weapons_shared;
#using scripts\zm\_util;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_behavior;
#using scripts\zm\_zm_laststand;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_zonemgr;
#using scripts\zm\_hb21_zm_weap_utility;
#insert scripts\shared\ai\zombie_vortex.gsh;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_hb21_zm_weap_black_hole_projectile.gsh;

#namespace hb21_zm_weap_black_hole_projectile;

#precache("model", "wpn_t7_zmb_hd_gersch_device_world");
#precache("fx", BLACK_HOLE_BOMB_PORTAL_FX);
#precache("fx", BLACK_HOLE_BOMB_PORTAL_EXIT_FX);
#precache("fx", BLACK_HOLE_BOMB_ZOMBIE_SOUL_FX);
#precache("fx", BLACK_HOLE_BOMB_ZOMBIE_GIB_FX);
#precache("fx", BLACK_HOLE_BOMB_EVENT_HORIZON_FX);
#precache("fx", BLACK_HOLE_SAMANTHA_STEAL_FX);
#precache("fx", BLACK_HOLE_BOMB_ZOMBIE_PULL_FX);
#precache("fx", BLACK_HOLE_BOMB_MARKER_FLARE_FX);

REGISTER_SYSTEM_EX("hb21_zm_weap_black_hole_projectile", &__init__, undefined, undefined)

function __init__()
{
    // # CLIENTFIELD REGISTRATION
    clientfield::register("toplayer", BHB_TOGGLE_LIGHTS_CF, VERSION_SHIP, 2, "int");
    clientfield::register("scriptmover", BHB_TOGGLE_DEPLOYED_CF, VERSION_SHIP, 1, "int");
    clientfield::register("actor", BHB_TOGGLE_BEING_PULLED_CF, VERSION_SHIP, 1, "int");
    // # CLIENTFIELD REGISTRATION
    
    // # VISION REGISTRATION
    visionset_mgr::register_info("visionset", BHB_VISION, VERSION_SHIP, level.vsmgr_prio_visionset_zombie_vortex + 1, 30, 1, &blackhole_bomb_player_vision_control, 1);
    // # VISION REGISTRATION
    
    // # VARIABLES AND SETTINGS
    // zm_utility::register_tactical_grenade_for_level(BHB_WEAPON);
    level.w_black_hole_bomb = getWeapon("iw8_vlkrogue_up_up");
    // hb21_zm_weap_utility::grenade_register_weapon_for_level(BHB_WEAPON, &player_handle_black_hole_bomb, &blackhole_bomb_viewlights);
    register_black_hole_weapon_for_level("iw8_vlkrogue_up_up", undefined, &weapon_fired);
    // # VARIABLES AND SETTINGS
    
    // # REGISTER FX
    level._effect["black_hole_bomb_portal"] = BLACK_HOLE_BOMB_PORTAL_FX;
    level._effect["black_hole_bomb_portal_exit"] = BLACK_HOLE_BOMB_PORTAL_EXIT_FX;
    level._effect["black_hole_bomb_zombie_soul"] = BLACK_HOLE_BOMB_ZOMBIE_SOUL_FX;
    level._effect["black_hole_bomb_zombie_gib"] = BLACK_HOLE_BOMB_ZOMBIE_GIB_FX;
    level._effect["black_hole_bomb_event_horizon"] = BLACK_HOLE_BOMB_EVENT_HORIZON_FX;
    level._effect["black_hole_samantha_steal"] = BLACK_HOLE_SAMANTHA_STEAL_FX;
    level._effect["black_hole_bomb_zombie_pull"] = BLACK_HOLE_BOMB_ZOMBIE_PULL_FX;
    level._effect["black_hole_bomb_marker_flare"] = BLACK_HOLE_BOMB_MARKER_FLARE_FX;
    // # REGISTER FX
    
    // # REGISTER CALLBACKS
    level.black_hole_bomb_death_start_func = &black_hole_bomb_event_horizon_death;
    level.vortexResetCondition = &zm_behavior::zombieKilledByBlackHoleBombCondition;
    level.black_hole_bomb_ai_fx = &black_hole_bomb_being_pulled_fx;
    // # REGISTER CALLBACKS
}

function register_black_hole_weapon_for_level(str_weapon, ptr_weapon_fired_cb = undefined, ptr_weapon_missile_fired_cb = undefined, ptr_weapon_grenade_fired_cb = undefined, ptr_weapon_obtained_cb = undefined, ptr_weapon_lost_cb = undefined, ptr_weapon_reloaded_cb = undefined, ptr_weapon_pullout_cb = undefined, ptr_weapon_putaway_cb = undefined)
{
    DEFAULT(level.a_black_hole_weaponfiles, []);
            
    w_weapon = getWeapon(str_weapon);
    
    w_weapon.ptr_weapon_fired_cb = ptr_weapon_fired_cb;
    w_weapon.ptr_weapon_missile_fired_cb = ptr_weapon_missile_fired_cb;
    w_weapon.ptr_weapon_grenade_fired_cb = ptr_weapon_grenade_fired_cb;
    w_weapon.ptr_weapon_obtained_cb = ptr_weapon_obtained_cb;
    w_weapon.ptr_weapon_lost_cb = ptr_weapon_lost_cb;
    w_weapon.ptr_weapon_reloaded_cb = ptr_weapon_reloaded_cb;
    w_weapon.ptr_weapon_pullout_cb = ptr_weapon_pullout_cb;
    w_weapon.ptr_weapon_putaway_cb = ptr_weapon_putaway_cb;
    w_weapon.ptr_weapon_first_raise_cb = undefined;
    w_weapon.ptr_weapon_charge_cb = undefined;
    
    ARRAY_ADD(level.a_black_hole_weaponfiles, w_weapon);
}

function weapon_fired(e_projectile, w_weapon, n_charge_level)
{
    self thread player_handle_black_hole_bomb(e_projectile, w_weapon, n_charge_level);
    self thread blackhole_bomb_viewlights(w_weapon);
}

function black_hole_bomb_event_horizon_death(v_damage_origin, e_interdimensional_gun_projectile)
{
    self zombie_utility::zombie_eye_glow_stop();
    self playSound(BHB_ZOMBIE_EXPLODE_SND);
    // self black_hole_bomb_corpse_hide();
    return 1;
}

function black_hole_bomb_being_pulled_fx(e_behavior_tree_entity, b_on)
{
    e_behavior_tree_entity endon("death");
    util::wait_network_frame();
    e_behavior_tree_entity clientfield::set(BHB_TOGGLE_BEING_PULLED_CF, b_on);
}

function player_handle_black_hole_bomb(e_projectile, w_weapon, n_charge_shot_level)
{
    self notify("starting_black_hole_bomb");
    self endon("disconnect");
    self endon("starting_black_hole_bomb");
    
    if (isDefined(e_projectile))
    {
        if (self laststand::player_is_in_laststand() || IS_TRUE(self.intermission))
        {
            e_projectile delete();
            return;
        }
        e_projectile hide();
        e_model = util::spawn_model(e_projectile.model, e_projectile.origin, e_projectile.angles);
        e_model linkTo(e_projectile);
        s_info = spawnStruct();
        s_info.sound_attractors = [];
        e_projectile thread monitor_zombie_groans(s_info);
        n_velocity_sq = 100000000;
        v_old_pos = e_projectile.origin;
        while (n_velocity_sq != 0)
        {
            WAIT_SERVER_FRAME;
            if (!isDefined(e_projectile))
                break;
            
            n_velocity_sq = distanceSquared(e_projectile.origin, v_old_pos);
            v_old_pos = e_projectile.origin;
        }
        if (isDefined(e_projectile))
        {
            self thread black_hole_bomb_kill_counter(e_projectile);
            e_model unlink();
            e_model.origin = e_projectile.origin;
            e_model.angles = e_projectile.angles;
            e_model._black_hole_bomb_player = self;
            e_model.targetname = "zm_bhb";
            e_model._new_ground_trace = 1;
            e_projectile resetMissileDetonationTime();
            if (isDefined(level.black_hole_bomb_loc_check_func))
            {
                if ([[level.black_hole_bomb_loc_check_func]](e_projectile, e_model, s_info))
                    return;
                
            }
            if (isDefined(level._blackhole_bomb_valid_area_check))
            {
                if ([[level._blackhole_bomb_valid_area_check]](e_projectile, e_model, self))
                    return;
                
            }
            b_valid_poi = zm_utility::is_point_inside_enabled_zone(e_projectile.origin);
            BLACKHOLE_PRINT_DEBUG("b_valid_poi first IS_TRUE: " + IS_TRUE(b_valid_poi));
            b_valid_poi = b_valid_poi && e_projectile move_valid_poi_to_navmesh(b_valid_poi);
            BLACKHOLE_PRINT_DEBUG("b_valid_poi second IS_TRUE: " + IS_TRUE(b_valid_poi));
            if (b_valid_poi)
            {
                n_duration = e_projectile.weapon.fusetime / 1000;

                level thread black_hole_bomb_cleanup(e_model, n_duration);
                if (isDefined(level._black_hole_bomb_poi_override))
                    e_model thread [[level._black_hole_bomb_poi_override]]();
                
                self thread zombie_vortex::start_timed_vortex(e_projectile.origin, 4227136, n_duration, undefined, undefined, self, level.w_black_hole_bomb, 0, undefined, 0, 0, true, e_projectile);
                e_model clientfield::set(BHB_TOGGLE_DEPLOYED_CF, 1);
                e_projectile thread blackhole_bomb_player_vision(n_duration);
                level thread black_hole_bomb_teleport_init(e_projectile, n_duration);
                e_projectile.is_valid = 1;
            }
            else
            {
                BLACKHOLE_PRINT_DEBUG("b_valid_poi undefined. Stolen by SAM");
                self.script_noteworthy = undefined;
                level thread black_hole_bomb_stolen_by_sam(self, e_model);
            }
        }
        else
        {
            BLACKHOLE_PRINT_DEBUG("e_projectile undefined. Stolen by SAM");
            self.script_noteworthy = undefined;
            level thread black_hole_bomb_stolen_by_sam(self, e_model);
        }
    }
}

function blackhole_bomb_viewlights(w_weapon)
{
    self notify("blackhole_bomb_viewlights");
    self endon("disconnect");
    self endon("blackhole_bomb_viewlights");
    
    wait .75;
    self clientfield::set_to_player(BHB_TOGGLE_LIGHTS_CF, 1);
    wait 3;
    self clientfield::set_to_player(BHB_TOGGLE_LIGHTS_CF, 0);
}

function blackhole_bomb_player_vision(n_duration)
{
    DEFAULT(level.active_bhb, []);
    array::add(level.active_bhb, self);
    foreach (e_player in level.players)
        visionset_mgr::activate("visionset", BHB_VISION, e_player);
    
    wait n_duration;
    
    arrayRemoveValue(level.active_bhb, self);
    foreach (e_player in level.players)
        visionset_mgr::deactivate("visionset", BHB_VISION, e_player);
    
}

function blackhole_bomb_player_vision_control(e_player)
{
    DEFAULT(level.active_bhb, []);
    while (level.active_bhb.size > 0)
    {
        n_dist = 2147483647;
        foreach (e_bhb in level.active_bhb)
        {
            n_curr_dist = distanceSquared(e_player.origin, e_bhb.origin);
            if (n_curr_dist < n_dist)
                n_dist = n_curr_dist;
            
        }
        if (n_dist < 262144)
            visionset_mgr::set_state_active(e_player, 1 - n_dist / 262144);
        
        WAIT_SERVER_FRAME;
    }
}

function move_valid_poi_to_navmesh(b_valid_poi)
{
    if (!IS_TRUE(b_valid_poi))
        return 0;
    
    if (isPointOnNavMesh(self.origin))
        return 1;
    
    v_orig = self.origin;
    s_query_result = positionQuery_Source_Navigation(self.origin, 0, 200, 100, 2, 15);
    if (isdefined(s_query_result.data.size))
    {
        foreach (s_point in s_query_result.data)
        {
            n_height_offset = abs(self.origin[2] - s_point.origin[2]);
            if (n_height_offset > 36)
            {
                BLACKHOLE_PRINT_DEBUG("n_height_offset above 36: " + n_height_offset);
                continue;
            }
            
            if (bulletTracePassed(s_point.origin + vectorScale((0, 0, 1), 20), v_orig + vectorScale((0, 0, 1), 20), 0, self, undefined, 0, 0))
            {
                self.origin = s_point.origin;
                return 1;
            }
            else
            {
                BLACKHOLE_PRINT_DEBUG("bulletTracePassed returned false");
            }
        }
    }
    return 0;
}

function wait_for_attractor_positions_complete()
{
    self waittill("attractor_positions_generated");
    self.attract_to_origin = 0;
}

function black_hole_bomb_cleanup(e_model, n_duration)
{
    e_model endon("sam_stole_it");
    v_grenade_org = e_model.origin;
    wait n_duration;
    if (isDefined(e_model))
    {
        e_model delete();
    }
    level thread black_hole_bomb_corpse_collect(v_grenade_org);
}

function black_hole_bomb_corpse_collect(v_origin)
{
    wait .1;
    a_corpse_array = getCorpseArray();
    for (i = 0; i < a_corpse_array.size; i++)
    {
        if (distanceSquared(a_corpse_array[i].origin, v_origin) < 36864)
            a_corpse_array[i] thread black_hole_bomb_corpse_delete();
        
    }
}

function black_hole_bomb_corpse_delete()
{
    self delete();
}

function monitor_zombie_groans(s_info)
{
    self endon("explode");
    while (1)
    {
        if (!isDefined(self))
            return;
        
        if (!isDefined(self.attractor_array))
        {
            WAIT_SERVER_FRAME;
            continue;
        }
        for (i = 0; i < self.attractor_array.size; i++)
        {
            if (!isInArray(s_info.sound_attractors, self.attractor_array[i]))
            {
                if (isDefined(self.origin) && isDefined(self.attractor_array[i].origin))
                {
                    if (distanceSquared(self.origin, self.attractor_array[i].origin) < 250000)
                    {
                        if (!isDefined(s_info.sound_attractors))
                            s_info.sound_attractors = [];
                        else if (!isArray(s_info.sound_attractors))
                            s_info.sound_attractors = array(s_info.sound_attractors);
                        
                        s_info.sound_attractors[s_info.sound_attractors.size] = self.attractor_array[i];
                        self.attractor_array[i] thread play_zombie_groans();
                    }
                }
            }
        }
        WAIT_SERVER_FRAME;
    }
}

function play_zombie_groans()
{
    self endon("death");
    self endon("black_hole_bomb_blown_up");
    while (1)
    {
        if (isDefined(self))
        {
            self playSound("zmb_vox_zombie_groan");
            wait randomFloatRange(2, 3);
        }
        else
            return;
        
    }
}

function black_hole_bomb_exists()
{
    return isDefined(level.zombie_weapons[BHB_WEAPON]);
}

function black_hole_bomb_corpse_hide()
{
    if (IS_TRUE(self._black_hole_bomb_collapse_death))
    {
        playFX(level._effect["black_hole_bomb_zombie_gib"], self getTagOrigin("tag_origin"));
        self hide();
    }
}

function black_hole_bomb_teleport_init(e_projectile, n_duration)
{
    if (!isDefined(e_projectile))
        return;
    
    e_teleport_trigger = spawn("trigger_radius", e_projectile.origin, 0, 64, 70);
    e_projectile thread black_hole_bomb_trigger_monitor(e_teleport_trigger);
    wait n_duration;
    e_teleport_trigger notify("black_hole_complete");
    wait .1;
    e_teleport_trigger delete();
}

function black_hole_bomb_trigger_monitor(e_trigger)
{
    e_trigger endon("black_hole_complete");
    while (1)
    {
        e_trigger waittill("trigger", e_player);
        if (isPlayer(e_player) && !e_player isOnGround() && !IS_TRUE(e_player.lander))
            e_trigger thread black_hole_teleport_trigger_thread(e_player, &black_hole_time_before_teleport, &black_hole_teleport_cancel);
        
        wait .1;
    }
}

function black_hole_time_before_teleport(e_player, str_endon)
{
    e_player endon(str_endon);
    if (!bulletTracePassed(e_player getEye(), self.origin + vectorScale((0, 0, 1), 65), 0, e_player))
        return;
    
    a_black_hole_teleport_structs = struct::get_array("struct_black_hole_teleport", "targetname");
    s_chosen_spot = undefined;
    
    if (isDefined(level._special_blackhole_bomb_structs))
        a_black_hole_teleport_structs = [[level._special_blackhole_bomb_structs]]();
    
    if (!isDefined(a_black_hole_teleport_structs) || a_black_hole_teleport_structs.size == 0)
        return;
    
    a_black_hole_teleport_structs = array::randomize(a_black_hole_teleport_structs);
    if (isDefined(level._override_blackhole_destination_logic))
    {
        s_chosen_spot = [[level._override_blackhole_destination_logic]](a_black_hole_teleport_structs, e_player);
    }
    else
    {
        for (i = 0; i < a_black_hole_teleport_structs.size; i++)
        {
            if (!isDefined(a_black_hole_teleport_structs[i].target))
                continue;
            
            if (zm_utility::check_point_in_enabled_zone(a_black_hole_teleport_structs[i].origin))
            {
                if (IS_TRUE(BHB_CAN_TELEPORT_TO_SAME_ZONE) && e_player zm_utility::get_current_zone() != a_black_hole_teleport_structs[i].target)
                {
                    continue;
                }
                
                s_chosen_spot = a_black_hole_teleport_structs[i];
                break;
            }
        }
    }

    if (isDefined(s_chosen_spot))
    {
        self playSound("zmb_gersh_teleporter_out");
        e_player playSoundToPlayer("zmb_gersh_teleporter_out_plr", e_player);
        e_player thread black_hole_teleport(s_chosen_spot);
    }
}

function black_hole_teleport_cancel(e_player)
{
}

function black_hole_teleport(s_dest)
{
    self endon("death");
    if (!isDefined(s_dest))
        return;
    
    n_prone_offset = vectorScale((0, 0, 1), 49);
    n_crouch_offset = vectorScale((0, 0, 1), 20);
    n_stand_offset = (0, 0, 0);
    v_destination = undefined;
    if (self getStance() == "prone")
        v_destination = s_dest.origin + n_prone_offset;
    else if (self getStance() == "crouch")
        v_destination = s_dest.origin + n_crouch_offset;
    else
        v_destination = s_dest.origin + n_stand_offset;
    
    if (isDefined(level._black_hole_teleport_override))
        level [[level._black_hole_teleport_override]](self);
    
    black_hole_bomb_create_exit_portal(s_dest.origin);
    self freezeControls(1);
    self disableOffhandWeapons();
    self disableWeapons();
    self dontInterpolate();
    self setOrigin(v_destination);
    self setPlayerAngles(s_dest.angles);
    self enableOffhandWeapons();
    self enableWeapons();
    self freezeControls(0);
    self thread slightly_delayed_player_response();
}

function slightly_delayed_player_response()
{
    wait 1;
    self zm_audio::create_and_play_dialog("general", "teleport_gersh");
}

function black_hole_teleport_trigger_thread(e_entity, ptr_on_enter_payload, ptr_on_exit_payload)
{
    e_entity endon("death");
    self endon("black_hole_complete");
    if (e_entity black_hole_teleport_ent_already_in_trigger(self))
        return;
    
    self black_hole_teleport_add_trigger_to_ent(e_entity);
    str_endon_condition = "leave_trigger_" + self getEntityNumber();
    if (isDefined(ptr_on_enter_payload))
        self thread [[ptr_on_enter_payload]](e_entity, str_endon_condition);
    
    while(isDefined(e_entity) && e_entity isTouching(self) && isDefined(self))
    {
        wait .05;
    }
    e_entity notify(str_endon_condition);
    if (isDefined(e_entity) && isDefined(ptr_on_exit_payload))
        self thread [[ptr_on_exit_payload]](e_entity);
    
    if (isDefined(e_entity))
        self black_hole_teleport_remove_trigger_from_ent(e_entity);
    
}

function black_hole_teleport_add_trigger_to_ent(e_entity)
{
    if (!isDefined(e_entity._triggers))
        e_entity._triggers = [];
    
    e_entity._triggers[self getEntityNumber()] = 1;
}

function black_hole_teleport_remove_trigger_from_ent(e_entity)
{
    if (!isDefined(e_entity._triggers))
        return;
    
    if (!isDefined(e_entity._triggers[self getEntityNumber()]))
        return;
    
    e_entity._triggers[self getEntityNumber()] = 0;
}

function black_hole_teleport_ent_already_in_trigger(e_trigger)
{
    if (!isDefined(self._triggers))
        return 0;
    
    if (!isDefined(self._triggers[e_trigger getEntityNumber()]))
        return 0;
    
    if (!self._triggers[e_trigger getEntityNumber()])
        return 0;
    
    return 1;
}

function black_hole_bomb_kill_counter(e_projectile)
{
    self endon("death");
    e_projectile endon("death");
    n_kill_count = 0;
    for (; ;)
    {
        e_projectile waittill("black_hole_bomb_kill");
        n_kill_count++;
        if (n_kill_count == 4)
            self zm_audio::create_and_play_dialog("kill", "gersh_device");
        
        if (5 <= n_kill_count)
            self notify("black_hole_kills_achievement");
        
    }
}

function black_hole_bomb_create_exit_portal(v_pos)
{
    e_exit_portal_fx_spot = spawn("script_model", v_pos);
    e_exit_portal_fx_spot setModel("tag_origin");
    playFXOnTag(level._effect["black_hole_bomb_portal_exit"], e_exit_portal_fx_spot, "tag_origin");
    e_exit_portal_fx_spot thread black_hole_bomb_exit_clean_up();
    e_exit_portal_fx_spot playSound("wpn_bhbomb_portal_exit_start");
    e_exit_portal_fx_spot playLoopSound("wpn_bhbomb_portal_exit_loop", .2);
}

function black_hole_bomb_exit_clean_up()
{
    wait 4;
    playSoundAtPosition(BHB_PORTAL_EXIT_POP_SND, self.origin);
    self delete();
}

function black_hole_bomb_stolen_by_sam(e_projectile, e_model)
{
    if (!isDefined(e_model))
        return;
    
    v_direction = e_model.origin;
    v_direction = (v_direction[1], v_direction[0], 0);
    if (v_direction[1] < 0 || (v_direction[0] > 0 && v_direction[1] > 0))
        v_direction = (v_direction[0], v_direction[1] * -1, 0);
    else if (v_direction[0] < 0)
        v_direction = (v_direction[0] * -1, v_direction[1], 0);
    
    a_players = getPlayers();
    for (i = 0; i < a_players.size; i++)
    {
        if (isAlive(a_players[i]))
            a_players[i] playLocalSound(level.zmb_laugh_alias);
        
    }
    playFXOnTag(level._effect["black_hole_samantha_steal"], e_model, "tag_origin");
    e_model moveZ(60, 1, .25, .25);
    e_model vibrate(v_direction, 1.5, 2.5, 1);
    e_model waittill("movedone");
    e_model delete();
}
