#using scripts\shared\util_shared; 
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared; 
#using scripts\shared\clientfield_shared; 
#using scripts\shared\exploder_shared; 
#using scripts\shared\flag_shared;
#using scripts\shared\system_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\hellround\zm_hellround_shared;
#insert scripts\zm\hellround\zm_hellround_shared.gsh;
#insert scripts\zm\hellround\zm_hellround_collectors.gsh;
#namespace zm_hellround_collectors;

REGISTER_SYSTEM_EX("zm_hellround_collectors", &init, &main, undefined)

#precache("fx", HRCOLL_FX_TRAIL);
#precache("fx", HRCOLL_FX_COLLECT);

class HellroundCollectors
{
    var skulls;
    var exploders;
    var exploders_depart;
    var clips;
    var models;

    var souls;
    var collection_start_callback;
    var collection_stop_callback;
    var reward_callback;
    var completion_callback;
}

function private init()
{
    clientfield::register("world", HRCOLL_CLIENT_FIELD, VERSION_SHIP, 2, "int");

    level.hellround_collectors = new HellroundCollectors();
    level.hellround_collectors.exploders = HRCOLL_EXPLODERS;
    level.hellround_collectors.exploders_depart = HRCOLL_EXPLODERS_DEPART;
    level.hellround_collectors.skulls = [];
    level.hellround_collectors.skulls[0] = GetEnt(HRCOLL_SKULLS[0], "targetname");
    level.hellround_collectors.skulls[1] = GetEnt(HRCOLL_SKULLS[1], "targetname");
    level.hellround_collectors.skulls[2] = GetEnt(HRCOLL_SKULLS[2], "targetname");
    level.hellround_collectors.clips = [];
    level.hellround_collectors.clips[0] = GetEntArray(HRCOLL_CLIPS[0], "targetname");
    level.hellround_collectors.clips[1] = GetEntArray(HRCOLL_CLIPS[1], "targetname");
    level.hellround_collectors.clips[2] = GetEntArray(HRCOLL_CLIPS[2], "targetname");
    level.hellround_collectors.models = [];
    level.hellround_collectors.models[0] = GetEntArray(HRCOLL_MODELS[0], "targetname");
    level.hellround_collectors.models[1] = GetEntArray(HRCOLL_MODELS[1], "targetname");
    level.hellround_collectors.models[2] = GetEntArray(HRCOLL_MODELS[2], "targetname");
    level.hellround_collectors.souls = [];
    level.hellround_collectors.souls[0] = 0;
    level.hellround_collectors.souls[1] = 0;
    level.hellround_collectors.souls[2] = 0;
    level.hellround_collectors.collection_start_callback = undefined;
    level.hellround_collectors.collection_stop_callback = undefined;
    level.hellround_collectors.completion_callback = undefined;

    callback::on_connect(&sync_hellround_collectors);
    callback::on_ai_spawned(&watch_ai_death_for_collection);
}

function private main()
{
    thread float_skulls();
    zm_hellround_shared::wait_for_map_load();
    show_hellround_collectors(HRCOLL_DISABLED);
    depart_hellround_collector_exploders(HRCOLL_DISABLED);
    
    foreach (skull in level.hellround_collectors.skulls)
    {
        skull.total_souls_left = get_total_souls_to_collect();
        skull.idle_sound = Spawn("script_origin", skull.origin);
        skull.idle_sound LinkTo(skull, "tag_origin");
    }

    if (DEBUG_HELLROUNDS)
    {
        thread modvar_debug_show_hellround_collectors();
    }
}

function private sync_hellround_collectors() // self == player
{
    show_hellround_collectors(HRCOLL_DISABLED);

    WAIT_SERVER_FRAME;

    if (zm_hellround_shared::is_hellround_running())
    {
        show_hellround_collectors(zm_hellround_shared::get_current_iteration());
    }
}

function start_collection_logic()
{
    collection_start_callback();
    wait HRCOLL_SPAWN_DELAY;
    show_hellround_collectors(zm_hellround_shared::get_current_iteration());
    start_hellround_collector_logic();
}

function cancel_collection_logic()
{
    iteration = zm_hellround_shared::get_current_iteration();
    if (!is_collector_iteration(iteration))
    {
        PRINT_HR_DEBUG("cancel_collection_logic: not a collector iteration.");
        return;
    }

    collector = get_active_collector_skull();
    if (isdefined(collector))
    {
        collector.is_collecting = false;
        collector notify("cancel_collection");
        collector.idle_sound StopLoopSound(0.5);
    }

    depart_hellround_collector_exploders(iteration);
    wait HRCOLL_FX_DEPART_DELAY;
    show_hellround_collectors(HRCOLL_DISABLED);
}

function private start_hellround_collector_logic()
{
    iteration = zm_hellround_shared::get_current_iteration();

    if (!is_collector_iteration(iteration))
    {
        PRINT_HR_DEBUG("start_hellround_collector_logic: not a collector iteration.");
        return;
    }

    get_active_collector_skull() thread collect_souls(iteration);
}

function private show_hellround_collectors(n_iteration)
{
    update_hellround_collector_exploders(n_iteration);
    update_hellround_collector_clips(n_iteration);

    if (n_iteration != HRCOLL_DISABLED)
    {
        // Display models and volumes after fx is done.
        wait HRCOLL_FX_SPAWN_DELAY;
    }

    update_hellround_collector_models(n_iteration);
    update_hellround_collector_skulls(n_iteration);
    level clientfield::set(HRCOLL_CLIENT_FIELD, n_iteration);
}

/* region utils */

function private is_collector_iteration(n_iteration)
{
    return zm_hellround_shared::is_hellround_running() 
        && n_iteration != HELLROUND_BAD_FLAG_INDEX 
        && n_iteration != HRCOLL_DISABLED;
}

function private get_active_collector_skull()
{
    iteration = zm_hellround_shared::get_current_iteration();

    if(!is_collector_iteration(iteration))
    {
        return undefined;
    }

    skull = level.hellround_collectors.skulls[iteration - 1];

    return skull;
}

function private should_notify_completion()
{
    // Last completion just finished, give it a little time for flags to refresh.
    wait 1;
    return zm_hellround_shared::is_last_iteration_completed();
}

/* endregion */
/* region exploders */

function private update_hellround_collector_exploders(n_iteration)
{
    foreach(exploder in level.hellround_collectors.exploders)
    {
        exploder::kill_exploder(exploder);
    }

    if (n_iteration == HRCOLL_DISABLED)
    {
        return;
    }

    exploder::exploder(level.hellround_collectors.exploders[n_iteration - 1]);
}

function private depart_hellround_collector_exploders(n_iteration)
{
    foreach(exploder in level.hellround_collectors.exploders_depart)
    {
        exploder::kill_exploder(exploder);
    }

    if (n_iteration == HRCOLL_DISABLED)
    {
        return;
    }

    exploder::exploder(level.hellround_collectors.exploders_depart[n_iteration - 1]);
}

/* endregion */
/* region clips */

function private update_hellround_collector_clips(n_iteration)
{
    foreach(clips in level.hellround_collectors.clips)
    {
        foreach(clip in clips)
        {
            clip Hide();
            clip NotSolid();
        }
    }

    if (n_iteration == HRCOLL_DISABLED)
    {
        return;
    }

    iteration_index = n_iteration - 1;
    foreach(clip in level.hellround_collectors.clips[iteration_index])
    {
        clip Show();
        clip Solid();
    }
}

/* endregion */
/* region models */

function private update_hellround_collector_models(n_iteration)
{
    foreach(models in level.hellround_collectors.models)
    {
        foreach(model in models)
        {
            model Hide();
            model NotSolid();
        }
    }

    if (n_iteration == HRCOLL_DISABLED)
    {
        return;
    }

    models_index = n_iteration - 1;
    models_to_show = level.hellround_collectors.models[models_index];

    foreach(model in models_to_show)
    {
        model Show();
        model Solid();
    }
}

/* endregion */
/* region skulls */

function private update_hellround_collector_skulls(n_iteration)
{
    foreach(skull in level.hellround_collectors.skulls)
    {
        skull Hide();
    }

    if (n_iteration == HRCOLL_DISABLED)
    {
        return;
    }

    level.hellround_collectors.skulls[n_iteration - 1] Show();
}

function private float_skulls()
{
    foreach(skull in level.hellround_collectors.skulls)
    {
        skull thread float_skull();
    }
}

function private float_skull() // self == skull ent
{
    while(true)
    {
        self MoveZ(HRCOLL_SKULLS_FLOAT_DELTA, HRCOLL_SKULLS_FLOAT_TIME);
        wait HRCOLL_SKULLS_FLOAT_TIME;

        self MoveZ(-HRCOLL_SKULLS_FLOAT_DELTA, HRCOLL_SKULLS_FLOAT_TIME);
        wait HRCOLL_SKULLS_FLOAT_TIME;
    }
}

/* endregion */
/* region soul collection */

function private get_total_souls_to_collect()
{
    return HRCOLL_TOTAL_SOULS + level.players.size * HRCOLL_TOTAL_SOULS_PER_PLAYER;
}

function private collect_souls(n_iteration) // self == collector skull ent
{
    if(!isdefined(self))
    {
        return;
    }
    self endon("cancel_collection");

    self.is_collecting = true;

    PRINT_HR_DEBUG("collecting souls for " + self.targetname + " at iteration " + n_iteration);

    self.idle_sound PlayLoopSound(HRCOLL_SND_IDLE_LOOP, 0.5);

    self wait_till_all_souls_collected();
    self PlaySound(HRCOLL_SND_COMPLETED);

    depart_hellround_collector_exploders(n_iteration);

    self.idle_sound StopLoopSound(0.5);

    wait HRCOLL_FX_DEPART_DELAY;
    show_hellround_collectors(HRCOLL_DISABLED);
    
    self.is_collecting = false;

    wait 1.0; // Wait a second time just for smooth transition
    notify_stop_collection_callback();
    give_players_iteration_reward(self.origin + (0, 0, -60));
    
    if (should_notify_completion())
    {
        wait HRCOLL_DELAY_BEFORE_COMPLETION;
        notify_completion_callback();
    }
}

function private wait_till_all_souls_collected() // self == collector skull ent
{
    // Use for loop instead of while to get each and every notifications before exiting the loop.
    total_souls = get_total_souls_to_collect();
    for(i = 0; i < total_souls; i++)
    {
        self waittill("soul_collected");
    }
}

function private soul_travel(destination_skull) // self == zm actor
{
    source = self.origin;
    destination = destination_skull.origin;

    // Update the count of souls collected before the animations.
    destination_skull soul_collected();

    // Spawn the soul
	fx_ent = util::spawn_model("tag_origin", source + (0, 0, 30));
    fx = PlayFxOnTag(HRCOLL_FX_TRAIL, fx_ent, "tag_origin");
    fx_ent PlaySound(HRCOLL_SND_SOUL_SPAWN);

    // Make it travel above the collector
    time = Distance(source, destination) / HRCOLL_SOUL_TRAVEL_SPEED;
    fx_ent MoveTo(destination + (0, 0, 20), time);
    fx_ent PlayLoopSound(HRCOLL_SND_SOUL_TRAVEL, 0.5);

    wait(time - 0.05);
    
    // Finish traveling (entering the collector)
    destination = destination_skull.origin;
    fx_ent MoveTo(destination, 0.5);
    fx_ent waittill("movedone");

    // Soul is now collected
    destination_skull PlaySound(HRCOLL_SND_SOUL_ENTER);
    PlayFX(HRCOLL_FX_COLLECT, destination);
    destination_skull notify("soul_collected");

    // Clear the fx
    fx_ent StopLoopSound();
    WAIT_SERVER_FRAME;
    fx_ent Delete();
}

function private soul_collected() // self == collector skull ent
{
    self.total_souls_left--;
    PRINT_HR_DEBUG("Soul collected for " + self.targetname + ". Total souls left: " + self.total_souls_left);
}

/* endregion */
/* region callbacks */


function bind_start_collection_callback(func_ptr)
{
    if (IsFunctionPtr(func_ptr))
    {
        level.hellround_collectors.collection_start_callback = func_ptr;
    }
}

function private collection_start_callback()
{
    thread [[ level.hellround_collectors.collection_start_callback ]]();
}

function bind_stop_collection_callback(func_ptr)
{
    if (IsFunctionPtr(func_ptr))
    {
        level.hellround_collectors.collection_stop_callback = func_ptr;
    }
}

function private notify_stop_collection_callback()
{
    if (isdefined(level.hellround_collectors.collection_stop_callback))
    {
        thread [[ level.hellround_collectors.collection_stop_callback ]]();
    }
}

function bind_reward_callback(func_ptr)
{
    if (IsFunctionPtr(func_ptr))
    {
        level.hellround_collectors.reward_callback = func_ptr;
    }
}

function private give_players_iteration_reward(location)
{
    if (isdefined(level.hellround_collectors.reward_callback))
    {
        [[ level.hellround_collectors.reward_callback ]](location);
    }
}

function bind_completion_callback(func_ptr)
{
    if (IsFunctionPtr(func_ptr))
    {
        level.hellround_collectors.completion_callback = func_ptr;
    }
}

function private notify_completion_callback(func_ptr)
{
    if (isdefined(level.hellround_collectors.completion_callback))
    {
        PRINT_HR_DEBUG("Calling HR collectors completion callback !");
        thread [[ level.hellround_collectors.completion_callback ]]();
    }
}

/* region ai death callback */

function private watch_ai_death_for_collection() // self == zm actor
{
    self waittill("death");

    destination_skull = get_active_collector_skull();
    if(!isdefined(destination_skull))
    {
        return;
    }
    
    if(destination_skull.total_souls_left > 0 && self close_and_in_los_of(destination_skull) && IS_TRUE(destination_skull.is_collecting))
    {
        PRINT_HR_DEBUG("soul travels to collector skull: " + destination_skull.targetname);
        self thread soul_travel(destination_skull);
    }
}

function private close_and_in_los_of(collector) // self == zm actor
{
    if(Distance(self.origin, collector.origin) > HRCOLL_SOUL_MAX_DISTANCE)
    {
        PRINT_HR_DEBUG("actor too far from collector skull");
        return false;
    }

    if(!BulletTracePassed(self.origin, collector.origin, false, self, collector) && HRCOLL_LOS_REQUIRED)
    {
        PRINT_HR_DEBUG("actor not in LOS from collector skull");
        return false;
    }
    
    return true;
}

/* endregion */

/* endregion */
/* region debug */

function private modvar_debug_show_hellround_collectors()
{
    ModVar("hrcoll", "");

    while(true)
    {
        WAIT_SERVER_FRAME;

        dvar_value = GetDvarString("hrcoll", "");

        if(!isdefined(dvar_value) || dvar_value == "")
        {
            continue;
        }
        ModVar("hrcoll", "");

        switch(Int(dvar_value))
        {
            case 1:
                show_hellround_collectors(1);
                start_hellround_collector_logic();
                break;
            case 2:
                show_hellround_collectors(2);
                start_hellround_collector_logic();
                break;
            case 3:
                show_hellround_collectors(3);
                start_hellround_collector_logic();
                break;
            default:
                show_hellround_collectors(HRCOLL_DISABLED);
                break;
        }
    }
}

/* endregion */
