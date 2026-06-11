#using scripts\shared\clientfield_shared; 
#using scripts\shared\util_shared; 
#using scripts\shared\system_shared; 

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\hellround\zm_hellround_shared.gsh;
#insert scripts\zm\hellround\zm_hellround_environment.gsh;
#namespace zm_hellround_environment;

#precache("client_fx", HRENV_FX_TRANSITION);

REGISTER_SYSTEM("zm_hellround_environment", &init, undefined)

class HellroundEnvironment
{
    var volumes_show;
    var volumes_hide;

    var models_show;
    var models_hide;

    var sounds;
}

function init() 
{
    level._effect["hellround_fire_tornado"] = HRENV_TORNADO_BLOCKER_FX;
    level.hellround_environment = new HellroundEnvironment();
    level.hellround_environment.volumes_show = FindVolumeDecalIndexArray("hellround_volume_show");
    level.hellround_environment.volumes_hide = FindVolumeDecalIndexArray("hellround_volume_hide");
    level.hellround_environment.models_show = FindStaticModelIndexArray("hellround_model_show");
    level.hellround_environment.models_hide = FindStaticModelIndexArray("hellround_model_hide");
    level.hellround_environment.sounds = [];

    clientfield::register("world", HRENV_TOGGLE_CLIENT_FIELD, VERSION_SHIP, 1, "int", &hellround_environment, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT);
}

function hellround_environment(n_client_num, _oldVal, n_new_val, b_new_ent, b_initial_snap, _fieldName, _bWasTimeJump)
{
    util::waitforclient(n_client_num);
    PRINT_HR_DEBUG("Called hellround environment update with: " + n_new_val);

    if (!b_new_ent)
    {
        play_transition_fx(n_client_num);
        play_transition_sounds(n_client_num);
    }
    fog_update(IS_TRUE(n_new_val));
    show_hellround_volumes(IS_TRUE(n_new_val));
    show_hellround_models(IS_TRUE(n_new_val));
    play_environment_sounds(n_client_num, IS_TRUE(n_new_val));

    if (b_new_ent || b_initial_snap)
    {
        // Force the fog refresh, sometime it glitches in transition fog (random)...
        wait 5;
        fog_update(true);
        wait 5;
        fog_update(false);
    }
}

/* region fx */

function play_transition_fx(n_client_num)
{
    foreach (player in GetLocalPlayers())
    {
        PlayFXOnCamera(n_client_num, HRENV_FX_TRANSITION);
    }

    PlayFXOnCamera(n_client_num, level._effect["parasite_round"]);
}

/* endregion */
/* region fog */

function fog_update(b_hellfog)
{
    fog_index = (b_hellfog ? HRENV_FOG_INDEX_BLOODY : HRENV_FOG_INDEX_NORMAL);
    set_fog_index(HRENV_FOG_INDEX_TRANSITION, HRENV_FOG_RADIANT_TIME);
    wait HRENV_FOG_TRANSITION_TIME;
    set_fog_index(fog_index, HRENV_FOG_RADIANT_TIME);
}

function private set_fog_index(index, transition_time)
{
    fog_bank = 1 << index;
    lit_fog_bank = index;
    
    foreach (player in GetLocalPlayers())
    {
        client_number = player GetLocalClientNumber();
        SetWorldFogActiveBank(client_number, fog_bank);
        SetLitFogBank(client_number, -1, lit_fog_bank, transition_time);
    }
}

/* endregion */
/* region volumes */

function private show_hellround_volumes(b_show)
{
    if(b_show)
    {
        foreach(volume in level.hellround_environment.volumes_show)
        {
            UnhideVolumeDecal(volume);
        }

        foreach(volume in level.hellround_environment.volumes_hide)
        {
            HideVolumeDecal(volume);
        }
    }
    else
    {
        foreach(volume in level.hellround_environment.volumes_show)
        {
            HideVolumeDecal(volume);
        }

        foreach(volume in level.hellround_environment.volumes_hide)
        {
            UnhideVolumeDecal(volume);
        }
    }
}

/* endregion */
/* region models */

function private show_hellround_models(b_show)
{
    if(b_show)
    {
        foreach(model in level.hellround_environment.models_show)
        {
            UnhideStaticModel(model);
        }

        foreach(model in level.hellround_environment.models_hide)
        {
            HideStaticModel(model);
        }
    }
    else
    {
        foreach(model in level.hellround_environment.models_show)
        {
            HideStaticModel(model);
        }

        foreach(model in level.hellround_environment.models_hide)
        {
            UnhideStaticModel(model);
        }
    }
}

/* endregion */
/* region sounds */

function play_transition_sounds(n_client_num)
{
    if (!IsSplitScreen() || IsSplitScreenHost(n_client_num))
    {
        player = GetLocalPlayer(n_client_num);
        player PlaySound(n_client_num, HRENV_SND_TRANSITION);
    }
}

function private play_environment_sounds(n_client_num, b_enable)
{
    if (!IsSplitScreen() || IsSplitScreenHost(n_client_num))
    {
        player = GetLocalPlayer(n_client_num);

        player stop_loop_sounds();
        if (b_enable)
        {
            level.hellround_environment.sounds[HRENV_AMBIANCE_SOUND_1] = player PlayLoopSound(HRENV_AMBIANCE_SOUND_1, 1);
            level.hellround_environment.sounds[HRENV_AMBIANCE_SOUND_2] = player PlayLoopSound(HRENV_AMBIANCE_SOUND_2, 1);
        }
    }
}

function private stop_loop_sounds() // self == player
{
    if (isdefined(level.hellround_environment.sounds[HRENV_AMBIANCE_SOUND_1]))
    {
        self StopLoopSound(level.hellround_environment.sounds[HRENV_AMBIANCE_SOUND_1], 1);
    }
    
    if (isdefined(level.hellround_environment.sounds[HRENV_AMBIANCE_SOUND_2]))
    {
        self StopLoopSound(level.hellround_environment.sounds[HRENV_AMBIANCE_SOUND_2], 1);
    }
}

/* endregion */
