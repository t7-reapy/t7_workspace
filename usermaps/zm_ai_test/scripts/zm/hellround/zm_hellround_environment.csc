#using scripts\shared\clientfield_shared; 
#using scripts\shared\util_shared; 
#using scripts\shared\system_shared; 

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\hellround\zm_hellround_shared.gsh;
#insert scripts\zm\hellround\zm_hellround_environment.gsh;
#namespace zm_hellround_environment;

REGISTER_SYSTEM("zm_hellround_environment", &init, undefined)

function init() 
{
	level.volumes_show = FindVolumeDecalIndexArray("hellround_volume_show");
	level.volumes_hide = FindVolumeDecalIndexArray("hellround_volume_hide");
	level.models_show = FindStaticModelIndexArray("hellround_model_show");
	level.models_hide = FindStaticModelIndexArray("hellround_model_hide");

    clientfield::register("world", HRENV_TOGGLE_CLIENT_FIELD, VERSION_SHIP, 1, "int", &hellround_environment, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT);
}

function hellround_environment(n_client_num, _oldVal, n_new_val, _bNewEnt, _bInitialSnap, _fieldName, _bWasTimeJump)
{
    util::waitforclient(n_client_num);

	fog_update(IS_TRUE(n_new_val));
    show_hellround_models(IS_TRUE(n_new_val));
    show_hellround_volumes(IS_TRUE(n_new_val));
}

// #region fog  

function private fog_update(b_hellfog)
{
    fog_index = (b_hellfog ? HRENV_FOG_INDEX_BLOODY : HRENV_FOG_INDEX_NORMAL);
    fog_bank = 1 << fog_index;
    lit_fog_bank = fog_index;
    foreach (player in GetLocalPlayers())
    {
		client_number = player GetLocalClientNumber();
        SetWorldFogActiveBank(client_number, fog_bank);
        SetLitFogBank(client_number, -1, lit_fog_bank, 0);
    }
}

// #endregion
// #region models

function private show_hellround_models(b_show)
{
    if (b_show)
    {
        foreach(model in level.models_show)
        {
            UnhideStaticModel(model);
        }

        foreach(model in level.models_hide)
        {
            HideStaticModel(model);
        }
    }
    else
    {
        foreach(model in level.models_show)
        {
            HideStaticModel(model);
        }

        foreach(model in level.models_hide)
        {
            UnhideStaticModel(model);
        }
    }
}

// #endregion
// #region volumes

function private show_hellround_volumes(b_show)
{
    if(b_show)
    {
        foreach(volume in level.volumes_show)
        {
            UnhideVolumeDecal(volume);
        }

        foreach(volume in level.volumes_hide)
        {
            HideVolumeDecal(volume);
        }
    }
    else
    {
        foreach(volume in level.volumes_show)
        {
            HideVolumeDecal(volume);
        }

        foreach(volume in level.volumes_hide)
        {
            UnhideVolumeDecal(volume);
        }
    }
}

// #endregion
