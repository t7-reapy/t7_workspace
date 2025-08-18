#using scripts\shared\flag_shared; 

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\hellround\zm_hellround_shared.gsh;

#namespace zm_hellround_shared;

function is_hellround_running()
{
    return !IS_TRUE(level.hellround.abolished) 
        && (level flag::get(HELLROUND_FLAGS[0]) 
        || level flag::get(HELLROUND_FLAGS[1]) 
        || level flag::get(HELLROUND_FLAGS[2]) 
        || level flag::get(HELLROUND_FLAGS[3])
        || level flag::get(HELLROUND_BAD_FLAG));
}

function wait_for_map_load()
{
    level flag::wait_till("all_players_connected");
    wait 5.0;
    while (!AreTexturesLoaded())
    {
        WAIT_SERVER_FRAME;
    }
}

function get_current_iteration()
{
    if (!isdefined(level.hellround_spawn_manager) || !isdefined(level.hellround_spawn_manager.current_iteration))
    {
        return 0;
    }

    return level.hellround_spawn_manager.current_iteration;
}
