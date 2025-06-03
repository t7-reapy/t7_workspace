#using scripts\codescripts\struct;

#using scripts\shared\system_shared;
#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\demo_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\util_shared;
#using scripts\shared\callbacks_shared;

#using scripts\shared\ai\zombie_death;
#using scripts\shared\ai\zombie_shared;
#using scripts\shared\ai\systems\gib;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\spawner_shared;
#using scripts\shared\scene_shared;

#using scripts\zm\_util;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_behavior;
#using scripts\zm\_zm_behavior_utility;
#using scripts\zm\_zm_blockers;
#using scripts\zm\_zm_bgb;
#using scripts\zm\_zm_equipment;
#using scripts\zm\_zm_laststand;
#using scripts\zm\_zm_net;
#using scripts\zm\_zm_pers_upgrades;
#using scripts\zm\_zm_pers_upgrades_functions;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_puppet;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_zonemgr;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\shared\ai\zombie.gsh;
#insert scripts\shared\archetype_shared\archetype_shared.gsh;
#insert scripts\shared\ai\systems\gib.gsh;
#insert scripts\zm\_zm.gsh;
#insert scripts\zm\_zm_perks.gsh;

#precache("model", "p6_zm_al_dream_catcher");
#precache("model", "p6_zm_al_dream_catcher_on");
#precache("model", "c_zom_zombie_mask_head");
#precache("model", "c_zom_wolf_head");
#precache("model", "c_zom_test_body1");

#precache("fx", "zombie/fx_bgb_burned_out_fire_torso_zmb");
#precache("fx", "lednors_wolfs/soul_charged");
#precache("fx", "lednors_wolfs/hell_portal");
#precache("fx", "lednors_wolfs/wolf_bite_blood");
#precache("script_bundle", "wolf_bundle" );

#using_animtree("generic");  

#namespace zm_wolf_soul_collectors;

REGISTER_SYSTEM_EX("zm_wolf_soul_collectors", &init, &main, undefined)

#define ZOMBIE_EATEN_BEFORE_COMPLETION 3
#define DEBUG_WOLF 0
#define PRINT_DEBUG_WOLF(__str) if(DEBUG_WOLF) IPrintLnBold(__str) // Note: don't use comas in __str
#define KILL_WOLF_HEAD_WATCHERS_NOTIFICATION "kill_wolf_heads_watchers"

function init_cerberus_fx()
{
    level._effect["soul_charge_start"] = "zombie/fx_bgb_burned_out_fire_torso_zmb";
    level._effect["hell_portal_close"] = "zombie/fx_bgb_burned_out_fire_torso_zmb";
    level._effect["soul_charged"] = "lednors_wolfs/soul_charged";
    level._effect["hell_portal"] = "lednors_wolfs/hell_portal";
    level._effect["wolf_bite_blood"] = "lednors_wolfs/wolf_bite_blood";
    level._effect["soul_charge_impact"] = undefined; // Not used because not imported from original files given to me.
}

function create_anim_references_on_server()
{
    root = %root;
    wolfhead_intro_anim = %o_zombie_dreamcatcher_intro;
    wolfhead_outtro_anim = %o_zombie_dreamcatcher_outtro;
    woflhead_idle_anims = [];
    wolfhead_idle_anim[0] = %o_zombie_dreamcatcher_idle;
    wolfhead_idle_anim[1] = %o_zombie_dreamcatcher_idle_twitch_scan;
    wolfhead_body_death = %ai_zombie_dreamcatch_impact;
    wolfhead_body_float = %ai_zombie_dreamcatch_rise;
    wolfhead_body_shrink = %ai_zombie_dreamcatch_shrink_a;
    level.wolfhead_pre_eat_anims = [];
    level.wolfhead_pre_eat_anims["right"] = %o_zombie_dreamcatcher_wallconsume_pre_eat_r;
    level.wolfhead_pre_eat_anims["left"] = %o_zombie_dreamcatcher_wallconsume_pre_eat_l;
    level.wolfhead_pre_eat_anims["front"] = %o_zombie_dreamcatcher_wallconsume_pre_eat_f;
    level.wolfhead_eat_anims["right"] = %o_zombie_dreamcatcher_wallconsume_align_r;
    level.wolfhead_eat_anims["left"] = %o_zombie_dreamcatcher_wallconsume_align_l;
    level.wolfhead_eat_anims["front"] = %o_zombie_dreamcatcher_wallconsume_align_f;
    level.wolfhead_body_anims["right"] = %ai_zombie_dreamcatcher_wallconsume_align_r;
    level.wolfhead_body_anims["left"] = %ai_zombie_dreamcatcher_wallconsume_align_l;
    level.wolfhead_body_anims["front"] = %ai_zombie_dreamcatcher_wallconsume_align_f;
}

function init()
{
    level.soul_catchers_abolished = false;
    init_cerberus_fx();
    create_anim_references_on_server();

    level flag::init("soul_catchers_charged");

    level.wolf_heads = [];
    level.wolf_bodies = [];
    level.wolf_runes = [];
    level.soul_catchers = [];
    level.soul_catchers_charged = 0;
    level.soul_catchers_vol = [];
    level.wolf_heads_active = 0;

    // If GetEntArray returns the script struct in random order, 
    // the tomohawk reward icons can lighten up in random order.
    level.a_wolf_structs = SortWolfStructs(GetEntArray("wolf_position", "targetname"));

    for (i = 0; i < level.a_wolf_structs.size; i++)
    {
        level.soul_catchers[i] = level.a_wolf_structs[i];
        level.soul_catchers_vol[i] = GetEnt(level.soul_catchers[i].target, "targetname");
        level.wolf_heads[i] = GetEnt(level.soul_catchers[i].script_label, "targetname");
        level.wolf_heads[i] UseAnimTree(#animtree);
        level.wolf_heads[i] Hide();
        level.soul_catchers[i].head = level.wolf_heads[i];
        level.soul_catchers[i].wolf_kill_cooldown = 0;
        level.wolf_bodies[i] = GetEnt(level.soul_catchers[i].script_friendname, "targetname");
        level.wolf_bodies[i] UseAnimTree(#animtree);
        level.wolf_bodies[i] SetModel("tag_origin");
        level.wolf_bodies[i] Hide();
        level.soul_catchers[i].body = level.wolf_bodies[i];
        level.wolf_runes[i] = GetEnt(level.soul_catchers[i].script_noteworthy, "targetname");
        level.soul_catchers[i].rune = level.wolf_runes[i];
    }
    level flag::wait_till("all_players_connected");
    level.soul_catcher_clip["rune_2"] = GetEnt("wolf_clip_docks", "targetname");
    level.soul_catcher_clip["rune_3"] = GetEnt("wolf_clip_infirmary", "targetname");
    _a24 = level.soul_catcher_clip;
    _k24 = GetFirstArrayKey(_a24);
    while (isdefined(_k24))
    {
        e_clip = _a24[_k24];
        e_clip SetInvisibleToAll();
        e_clip ConnectPaths();
        _k24 = GetNextArrayKey(_a24, _k24);
    }
}

function main()
{
    for(i = 0; i < level.soul_catchers.size; i++)
    {
        level.soul_catchers[i].souls_received = 0;
        level.soul_catchers[i].is_eating = 0;
        level.soul_catchers[i] thread soul_catcher_check();
        level.soul_catchers[i] thread soul_catcher_state_manager(i);
        level.soul_catchers[i] thread wolf_head_removal("tomahawk_door_sign_" + (i + 1));
        level.soul_catchers_vol[i] = GetEnt(level.soul_catchers[i].target, "targetname");
    }
    level thread soul_catchers_charged();
    level thread get_the_zoms();
}

function abolish_wolf_heads()
{
    if (level.soul_catchers_abolished)
    {
        return; // already abolished.
    }

    level.soul_catchers_abolished = true;
    level notify(KILL_WOLF_HEAD_WATCHERS_NOTIFICATION);
    for(i = 0; i < level.soul_catchers.size; i++)
    {
        level.soul_catchers[i] notify(KILL_WOLF_HEAD_WATCHERS_NOTIFICATION);
        level.soul_catchers[i].head notify(KILL_WOLF_HEAD_WATCHERS_NOTIFICATION);
    }
    level.wolf_heads_active = 0;

    PRINT_DEBUG_WOLF("notify abolished");
}

function force_completion()
{
    if (level.soul_catchers_charged == level.soul_catchers.size)
    {
        return; // already completed.
    }

    abolish_wolf_heads();

    level.soul_catchers_charged = level.soul_catchers.size;
    for(i = 0; i < level.soul_catchers.size; i++)
    {
        if (!level.soul_catchers[i].is_charged) 
        {
            level.wolf_runes[i] Show();
            level.wolf_runes[i] SetModel("p6_zm_al_dream_catcher_on");
            level.wolf_runes[i] rune_glow();
        }

        level.soul_catchers[i].is_charged = true;
        level.soul_catchers[i] notify("fully_charged");
    }

    PRINT_DEBUG_WOLF("wolf heads forcely completed");
}

function SortWolfStructs(struct_array)
{
    result = [];
    result_size = struct_array.size;
    struct_kvp_value_prefix = "rune_";

    for(i = 0; i < result_size; i++)
    {
        struct_found = undefined;
        struct_kvp_value = struct_kvp_value_prefix + (i + 1);
        for(j = 0; j < struct_array.size; j++)
        {
            if (struct_array[j].script_noteworthy == struct_kvp_value)
            {
                struct_found = struct_array[j];
                break;
            }
        }
        result[i] = struct_found;
    }

    return result;
}

function HeadActiveCallbacks()
{
    level endon(KILL_WOLF_HEAD_WATCHERS_NOTIFICATION);

    if (level.soul_catchers_abolished)
        return; // It's possible we missed the notification

    if (level.wolf_heads_active == 0 && IsFunctionPtr(level.wolf_heads_become_active_callback)) 
    {
        level thread [[ level.wolf_heads_become_active_callback ]]();
    }
    level.wolf_heads_active++;
    PRINT_DEBUG_WOLF("wolf head actives: "+level.wolf_heads_active);
}

function HeadGoneCallbacks()
{
    level endon(KILL_WOLF_HEAD_WATCHERS_NOTIFICATION);

    if (level.soul_catchers_abolished)
        return; // It's possible we missed the notification

    level.wolf_heads_active--;
    PRINT_DEBUG_WOLF("wolf head actives: "+level.wolf_heads_active);
    if (level.wolf_heads_active == 0 && IsFunctionPtr(level.wolf_heads_become_inactive_callback)) 
    {
        level thread [[ level.wolf_heads_become_inactive_callback ]]();
    }
}
function hide_wolf_heads() // self == level.wolf_bodies[index]
{
    if (!isdefined(self))
    {
        return;
    }
    self Hide();

    if (!isdefined(self.head))
    {
        return;
    }
    self.head Hide();
    
    if (isdefined(self.head.hat))
    {
        self.head.hat Hide();
    }
}

function soul_catcher_state_manager(index)
{
    thread wolf_state_0(index);
    self waittill("first_zombie_killed_in_zone");
    PRINT_DEBUG_WOLF("first zombie_dead");
    if (level.soul_catchers_abolished)
    {
        return;
    }

    thread HeadActiveCallbacks(); 
    if (isdefined(level.soul_catcher_clip[self.script_noteworthy]))
    {
        level.soul_catcher_clip[self.script_noteworthy] SetVisibleToAll();
        level.soul_catcher_clip[self.script_noteworthy] DisconnectPaths();
    }
    thread wolf_state_1(index);
    anim_length = GetAnimLength(%o_zombie_dreamcatcher_intro);
    wait anim_length;
    self util::waittill_any(KILL_WOLF_HEAD_WATCHERS_NOTIFICATION, "finished_eating");
    
    while (!self.is_charged && !level.soul_catchers_abolished)
    {
        WAIT_SERVER_FRAME;
        thread wolf_state_2(index);
        self util::waittill_any(KILL_WOLF_HEAD_WATCHERS_NOTIFICATION, "finished_eating");
        PRINT_DEBUG_WOLF("finished_eating or fully_charged");
    }
    PRINT_DEBUG_WOLF("filling done");

    thread wolf_state_3(index);
    anim_length = GetAnimLength(%o_zombie_dreamcatcher_outtro);
    wait anim_length;
    if (isdefined(level.soul_catcher_clip[self.script_noteworthy]))
    {
        level.soul_catcher_clip[self.script_noteworthy] Delete();
        level.soul_catcher_clip[self.script_noteworthy] ConnectPaths();
    }

    thread wolf_state_4(index);
    thread HeadGoneCallbacks();

    PRINT_DEBUG_WOLF("state manager finished");
}

function wolf_state_0(index)
{
    level.wolf_heads[index] Hide();
    level.wolf_runes[index] Show();
    level.wolf_bodies[index] hide_wolf_heads();
}

function wolf_state_1(index)
{
    PRINT_DEBUG_WOLF("first zombie_dead");

    level.wolf_heads[index] Show();
    level.wolf_runes[index] Hide();
    level.wolf_bodies[index] hide_wolf_heads();
    thread wolfhead_arrive(index);
}

function wolf_state_2(index)
{
    PRINT_DEBUG_WOLF("wolf_state_2");
    level.wolf_heads[index] Show();
    level.wolf_runes[index] Hide();
    level.wolf_bodies[index] hide_wolf_heads();
    level.wolf_heads[index] thread wolfhead_idle();
}

function wolf_state_3(index)
{
    level.wolf_heads[index] Show();
    level.wolf_runes[index] Show();
    level.wolf_bodies[index] hide_wolf_heads();
    level.wolf_runes[index] StopLoopSound();
    thread wolfhead_depart(index);
}

function wolf_state_4(index)
{     
    level.wolf_heads[index] Hide();
    level.wolf_runes[index] Show();
    level.wolf_bodies[index] hide_wolf_heads();
    level.wolf_runes[index] SetModel("p6_zm_al_dream_catcher_on");
    level.wolf_runes[index] rune_glow();
    
    PRINT_DEBUG_WOLF("wolf done setting model to dream catcher on");
}

function wolfhead_arrive(index)
{
    rune = level.wolf_runes[index];
    head = level.wolf_heads[index];

    rune.portalFxOrg = Spawn("script_model", rune.origin);
    rune.portalFxOrg SetModel("tag_origin");
    rune.portalFxOrg.angles = rune.angles + (0, 90, 0);
    rune.portalFxOrg.origin += (10, 10, 10) * anglesToForward(rune.portalFxOrg.angles);

    PlayFxOnTag(level._effect["hell_portal"], rune.portalFxOrg, "tag_origin");
    
    head PlaySound("evt_wolfhead_spawn");
    head.wolf_ent = Spawn("script_origin", head.origin);
    head.wolf_ent PlayLoopSound("evt_wolfhead_fire_loop");

    n_anim_length = GetAnimLength(%o_zombie_dreamcatcher_intro);
    head AnimScripted("notify", head.origin, head.angles, %o_zombie_dreamcatcher_intro, "normal", %o_zombie_dreamcatcher_intro, 1, 0.3);
    wait n_anim_length;
}

function wolfhead_depart(index)
{   
    rune = level.wolf_runes[index];
    head = level.wolf_heads[index];

    PRINT_DEBUG_WOLF("now playing " + %o_zombie_dreamcatcher_outtro + " anim");
    head AnimScripted("notify", head.origin, head.angles, %o_zombie_dreamcatcher_outtro, "normal", %o_zombie_dreamcatcher_outtro, 1, 0.3);
    rune.portalFxOrg Delete();
    
    rune_forward = AnglesToForward(rune.angles + VectorScale((0, 1, 0), 90));
    rune_up = AnglesToUp(rune.angles);
    PlayFX(level._effect["hell_portal_close"], rune.origin, rune_forward, rune_up);

    head PlaySound("evt_wolfhead_depart");
    head.wolf_ent StopLoopSound();

    WAIT_SERVER_FRAME;
    if (isdefined(head.wolf_ent))
    {
        head.wolf_ent Delete();
    }
    
    head notify("wolf_departing");
}

function wolfhead_idle()
{
    self endon(KILL_WOLF_HEAD_WATCHERS_NOTIFICATION);
    self endon("wolf_eating");
    self endon("wolf_departing");
    self notify("wolf_idling");

    PRINT_DEBUG_WOLF("wolf_idling");
    level.wolf_head_idle_anims = [];
    level.wolf_head_idle_anims[0] = %o_zombie_dreamcatcher_idle;
    level.wolf_head_twitch_anims = [];
    level.wolf_head_twitch_anims[0] = %o_zombie_dreamcatcher_idle_twitch_scan;

    while(1)
    {
        random_idle_anim = array::random(level.wolf_head_idle_anims);
        n_anim_length = GetAnimLength(random_idle_anim);
        PRINT_DEBUG_WOLF("now playing " + random_idle_anim + " anim");
        self AnimScripted("notify", self.origin, self.angles, random_idle_anim, "normal", random_idle_anim, 1, 0.3);
        wait n_anim_length;

        random_twitch_anim = array::random(level.wolf_head_twitch_anims);
        n_anim_length = GetAnimLength(random_twitch_anim);
        PRINT_DEBUG_WOLF("now playing " + random_twitch_anim + " anim");
        self AnimScripted("notify", self.origin, self.angles, random_twitch_anim, "normal", random_twitch_anim, 1, 0.3);
        wait n_anim_length;
    }
}


function private rune_glow() // self == level.wolf_runes[index]
{
    rune_forward = anglesToForward(self.angles);
    rune_charged_glow_location = self.origin + (3, 3, 3) * rune_forward;
    PlayFX(level._effect["soul_charged"], rune_charged_glow_location, rune_forward);
    self PlayLoopSound("evt_runeglow_loop");
}

function wolf_state_eat(index, n_eating_anim, zombie)
{
    if(n_eating_anim == 3)
    {
        level.wolf_heads[index] thread wolfhead_eat_aligned(zombie, "front", index);
    }
    if(n_eating_anim == 4)
    {
        level.wolf_heads[index] thread wolfhead_eat_aligned(zombie, "right", index);
    }
    if(n_eating_anim == 5)
    {
        level.wolf_heads[index] thread wolfhead_eat_aligned(zombie, "left", index);
    }
}

function wolfhead_eat_aligned(zombie, direction, index)
{
    self endon("wolf_idling");
    self endon("wolf_departing");

    self notify("wolf_eating");

    level.wolf_bodies[index] EnableLinkTo();
    zombie EnableLinkTo();
    zombie LinkTo(level.wolf_bodies[index]);

    self wolfhead_pre_eat_aligned(zombie, direction);
    level.wolf_bodies[index].origin = self GetTagOrigin("j_tongue_1");//tag_mouth_fx
    level.wolf_bodies[index].angles = self GetTagAngles("j_tongue_1");//tag_mouth_fx
    zombie.angles = self GetTagAngles("j_tongue_1");//tag_mouth_fx
    level.wolf_bodies[index] LinkTo(self, "j_tongue_1", (0, 0, 0), (0, 0, 0));

    self thread play_blood_fx_on_bite();
    PRINT_DEBUG_WOLF("now playing " + level.wolfhead_eat_anims[direction] + " anim");
    self AnimScripted("notify", self.origin, self.angles, level.wolfhead_eat_anims[direction], "normal", level.wolfhead_eat_anims[direction], 1, 0.3); 
    zombie AnimScripted("notify", zombie.origin, zombie.angles, level.wolfhead_body_anims[direction], "normal", level.wolfhead_body_anims[direction], 1, 0.3); 
    PRINT_DEBUG_WOLF("now playing " + level.wolfhead_body_anims[direction] + " anim");
    wait GetAnimLength(level.wolfhead_eat_anims[direction]);

    self PlaySound("evt_wolfhead_eat");
    self Unlink();
    
    level.wolf_bodies[index] Unlink();
}

function wolfhead_pre_eat_aligned(zombie, direction)
{
    s_closest = util::get_array_of_closest(self.origin, level.a_wolf_structs);

    m_body = s_closest[0].body;
    m_wolf = s_closest[0].head;
    PRINT_DEBUG_WOLF("now playing " + level.wolfhead_pre_eat_anims[direction] + " anim");
    m_wolf AnimScripted("notify", m_wolf.origin, m_wolf.angles, level.wolfhead_pre_eat_anims[direction], "normal", level.wolfhead_pre_eat_anims[direction], 1, 0.3);
    m_body Unlink();
    m_body Show();

    m_body body_moveto_wolf(m_wolf, zombie);
}

function play_blood_fx_on_bite()
{
    self waittill("bite", note);
    // PlayFXOnTag(level._effect["soul_charge_impact"], self, "tag_mouth_fx");
    PlayFXOnTag(level._effect["wolf_bite_blood"], self, "tag_mouth_fx");
}

function body_moveto_wolf(m_wolf, zombie)
{
    self.m_soul_fx_player = Spawn("script_model", self.origin);

    self.m_soul_fx_player SetModel("tag_origin");
    zombie AnimScripted("notify", zombie.origin, zombie.angles, %ai_zombie_dreamcatch_rise, "normal", %ai_zombie_dreamcatch_rise, 1, 0.3);

    vec_dir = m_wolf.origin - self.origin;
    vec_dir_scaled = VectorScale(vec_dir, 0.2);
    self.m_soul_fx_player.angles = VectortoAngles(vec_dir);
    self.m_soul_fx_player LinkTo(self);
    PlayFXOnTag(level._effect["soul_charge_start"], self, "tag_origin");
    self PlaySound("evt_soulsuck_body");
    self MoveTo(self.origin + vec_dir_scaled, 1.5, 1.5);

    self waittill("movedone");
    zombie.angles = self.angles;
    zombie AnimScripted("notify", zombie.origin, zombie.angles, %ai_zombie_dreamcatch_shrink_a, "normal", %ai_zombie_dreamcatch_shrink_a, 1, 0.3);
    zombie_move_offset = AnglesToForward(m_wolf.angles) * 36 + AnglesToUp(m_wolf.angles) * 0;
    self MoveTo(m_wolf.origin + zombie_move_offset, 0.5, 0.5);

    self waittill("movedone");
    self.m_soul_fx_player Unlink();
    self.m_soul_fx_player Delete();
    self.m_soul_fx_player = undefined;
}

function soul_catcher_check()
{
    self endon(KILL_WOLF_HEAD_WATCHERS_NOTIFICATION);

    self.is_charged = 0;
    while (1)
    {
        if (self.souls_received >= ZOMBIE_EATEN_BEFORE_COMPLETION)
        {
            level.soul_catchers_charged++;
            self.is_charged = 1;
            self notify("fully_charged");
            PRINT_DEBUG_WOLF("fully_charged");
            break;
        }
        else
        {
            wait 0.05;
        }
    }

    if (level.soul_catchers_charged == 1)
    {
        self thread first_wolf_complete_vo();
    }
    else if (level.soul_catchers_charged >= level.soul_catchers.size)
    {
        self thread final_wolf_complete_vo();
    }
}

function get_the_zoms()
{
    level endon(KILL_WOLF_HEAD_WATCHERS_NOTIFICATION);

    while(true)
    {
        wait 0.1; 
        zoms = GetAISpeciesArray("axis"); 
        for (i = 0; i < zoms.size; i++)
        {
            if (isdefined(zoms[i].is_accounted) && zoms[i].is_accounted == true)
            {
                continue;
            }

            if(isdefined(zoms[i].is_brutus) && zoms[i].is_brutus)
            {
                continue;
            }

            zoms[i].is_accounted = true;
            zoms[i] thread watch_for_death(); 
        }
    }
}

function watch_for_death()
{
    if (level.soul_catchers_abolished)
        return;

    if(!isdefined(self) || self.archetype == "ally_zod_robot_companion_ar")
        return;

    self waittill("death", attacker);
    
    if(!isdefined(attacker) || !IsPlayer(attacker))
        return;

    for (i = 0; i < level.soul_catchers.size; i++)
    {
        if (!(self IsTouching(level.soul_catchers_vol[i]) && !level.soul_catchers[i].is_charged))
        {
            continue;
        }

        if (!self BodyShouldBeEatenByWolf(i)) 
        {
            return;
        }
        
        self.my_soul_catcher = level.soul_catchers[i];
        if (isdefined(self.my_soul_catcher.souls_received) 
            && self.my_soul_catcher.souls_received == 0 
            && isdefined(level.wolf_encounter_vo_played) 
            && !level.wolf_encounter_vo_played 
            && level.soul_catchers_charged == 0)
        {
            self.my_soul_catcher thread first_wolf_encounter_vo();
        }
        
        self Hide();
        level.soul_catchers[i].is_eating = true;
        clone = self get_zombie_clone();
        clone UseAnimTree(#animtree);
        clone thread do_impact_anim();

        if (level.soul_catchers[i].souls_received == 0)
        {
            level.soul_catchers[i] notify("first_zombie_killed_in_zone");
            level.soul_catchers[i] thread notify_wolf_intro_anim_complete();
            level.soul_catchers[i] waittill("wolf_intro_anim_complete");
        }

        while(!isdefined(clone.wolf_impact_done))
        {
            wait 0.05;
        }
        clone.my_soul_catcher = level.soul_catchers[i];
        clone pose_dead_body();
        n_eating_anim = clone which_eating_anim();
        level thread wolf_state_eat(i, n_eating_anim, clone);
        if (n_eating_anim == 3)
        {
            total_wait_time = 3 + GetAnimLength(%ai_zombie_dreamcatcher_wallconsume_align_f);
        }
        else if (n_eating_anim == 4)
        {
            total_wait_time = 3 + GetAnimLength(%ai_zombie_dreamcatcher_wallconsume_align_r);
        }
        else
        {
            total_wait_time = 3 + GetAnimLength(%ai_zombie_dreamcatcher_wallconsume_align_l);
        }
        wait (total_wait_time - 0.5);
        level.soul_catchers[i].souls_received++;
        wait 0.5;
        level.soul_catchers[i] notify("finished_eating");
        PRINT_DEBUG_WOLF("finished_eating");
        level.soul_catchers[i].is_eating = false;
        clone Delete();

        return;
    }
}

function BodyShouldBeEatenByWolf(index) 
{
    // self = ai entity
    if (level.soul_catchers_abolished)
        return false;

    if (level.soul_catchers[index].is_eating == true)
        return false;
        
    if (level.soul_catchers[index].souls_received >= ZOMBIE_EATEN_BEFORE_COMPLETION)
        return false;

    if (IsDefined(self.animname) && self.animname == "napalm_zombie")
        return false;

    if (IsDefined(self.archetype) && self.archetype == ARCHETYPE_ZOMBIE)
        return true;

    return false;
}

function get_zombie_clone()
{
    gib_ref = "";
    if(IsDefined(self.a.gib_ref))
    {
        gib_ref = self.a.gib_ref; 
    } 
    
    limb_data = getLimbData(gib_ref, self);
    zombie_clone = spawn("script_model", self.origin);
    zombie_clone.angles = self.angles;
    zombie_clone SetModel(limb_data["body"]);
    zombie_clone Attach(limb_data["head"]);
    zombie_clone Attach(limb_data["legs"]);
    self Delete();
    
    return zombie_clone;     
}

function getLimbData(gib_ref, zombie)
{
    temp_array = [];
 
    temp_array["head"] = "c_zom_zombie_mask_head";
    temp_array["body"] = zombie.torsoDmg1;
    temp_array["legs"] = zombie.legDmg1;
    temp_array["type"] = "zombie";

    if(gib_ref == "right_arm")
    {  
        if(IsDefined(zombie.torsoDmg2))
        {
            temp_array["body"] = zombie.torsoDmg2;
            return temp_array;
        }
    }
 
    if(gib_ref == "left_arm")
    {
        if(IsDefined(zombie.torsoDmg3))
        {
            temp_array["body"] = zombie.torsoDmg3;
        }
    }

    if(gib_ref == "guts")
    {
        if(IsDefined(zombie.torsoDmg4))
        {
            temp_array["body"] = zombie.legDtorsoDmg4mg3;
        }
    }

    if(gib_ref == "head")
    {
        if(IsDefined(zombie.torsoDmg5))
        {
            temp_array["body"] = zombie.torsoDmg5;
        }
    }
 
    if(gib_ref == "right_leg")
    {  
        if(IsDefined(zombie.legDmg2))
        {
            temp_array["legs"] = zombie.legDmg2;
            temp_array["type"] = "crawler";
        }
    }
 
    if(gib_ref == "left_leg")
    {
        if(IsDefined(zombie.legDmg3))
        {
            temp_array["legs"] = zombie.legDmg3;
            temp_array["type"] = "crawler";
        }
    }
 
    if(gib_ref == "no_legs")
    {
        if(IsDefined(zombie.legDmg4))
        {
            temp_array["legs"] = zombie.legDmg4;
            temp_array["type"] = "crawler";
        }
    }
 
    return temp_array;
}

function do_impact_anim()
{
    self.wolf_impact_done = undefined;
    self AnimScripted("notify" , self.origin , self.angles, %ai_zombie_dreamcatch_impact);
    wait GetAnimLength(%ai_zombie_dreamcatch_impact) - 0.1;
    self.noragdoll = true;
    self.nodeathragdoll = true;
    self.wolf_impact_done = true;
}

function pose_dead_body()
{
    s_closest = util::get_array_of_closest(self.origin, level.a_wolf_structs);
    m_body = s_closest[0].body;
    m_wolf = s_closest[0].head;
    m_body.origin = self.origin;
    m_body.angles = self.angles;
}

function notify_wolf_intro_anim_complete()
{
    anim_length = GetAnimLength(%o_zombie_dreamcatcher_intro);
    wait anim_length;
    self notify("wolf_intro_anim_complete");
}

function which_eating_anim()
{
    soul_catcher = self.my_soul_catcher;
    forward_dot = VectorDot(AnglesToForward(soul_catcher.angles), VectorNormalize(self.origin - soul_catcher.origin));
    if (forward_dot > 0.85)
    {
        return 3;
    }
    else
    {
        right_dot = VectorDot(AnglesToRight(soul_catcher.angles), self.origin - soul_catcher.origin);
        if (right_dot > 0)
        {
            return 4;
        }
        else
        {
            return 5;
        }
    }
}

function wolf_head_removal(wolf_head_model_string)
{
    wolf_head_model = GetEnt(wolf_head_model_string, "targetname");
    wolf_head_model SetModel("p6_zm_al_dream_catcher");
    self waittill("fully_charged");
    wolf_head_model SetModel("p6_zm_al_dream_catcher_on");
}

function soul_catchers_charged()
{
    while (1)
    {
        if (level.soul_catchers_charged >= level.soul_catchers.size)
        {
            PRINT_DEBUG_WOLF("there are " + level.soul_catchers.size + " wolves");
            level flag::set("soul_catchers_charged");
            level notify("soul_catchers_charged");
            
            if (!level.soul_catchers_abolished 
                && IsFunctionPtr(level.soul_catchers_charged_callback)) 
            {
                level thread [[ level.soul_catchers_charged_callback ]]();
            }
            return;
        }
        else
        {
            wait 1;
        }
    }
}

function first_wolf_encounter_vo()
{
    wait 2;
    a_players = GetPlayers();
    a_closest = util::get_array_of_closest(self.origin, a_players);
    i = 0;
    while (i < a_closest.size)
    {
        if (isdefined(a_closest[i].dontspeak) && !a_closest[i].dontspeak)
        {
            a_closest[i] thread zm_utility::do_player_general_vox("general", "wolf_encounter");
            level.wolf_encounter_vo_played = 1;
            return;
        }
        else
        {
            i++;
        }
    }
}

function first_wolf_complete_vo()
{
    wait 3.5;
    a_players = GetPlayers();
    a_closest = util::get_array_of_closest(self.origin, a_players);
    i = 0;
    while (i < a_closest.size)
    {
        if (isdefined(a_closest[i].dontspeak) && !a_closest[i].dontspeak)
        {
            a_closest[i] thread zm_utility::do_player_general_vox("general", "wolf_first_complete");
            return;
        }
        else
        {
            i++;
        }
    }
}

function final_wolf_complete_vo()
{
    wait 3.5;
    a_players = GetPlayers();
    a_closest = util::get_array_of_closest(self.origin, a_players);
    i = 0;
    while (i < a_closest.size)
    {
        if (isdefined(a_closest[i].dontspeak) && !a_closest[i].dontspeak)
        {
            a_closest[i] thread zm_utility::do_player_general_vox("general", "wolf_complete");
            return;
        }
        else
        {
            i++;
        }
    }
}
