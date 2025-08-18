#using scripts\shared\clientfield_shared; 
#using scripts\shared\util_shared; 
#using scripts\shared\system_shared; 

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\hellround\zm_hellround_shared.gsh;
#insert scripts\zm\hellround\zm_hellround_collectors.gsh;
#namespace zm_hellround_collectors;

REGISTER_SYSTEM("zm_hellround_collectors", &init, undefined)

class HellroundCollectors
{
    var volumes;
}

function private init() 
{
    clientfield::register("world", HRCOLL_CLIENT_FIELD, VERSION_SHIP, 2, "int", &hellround_collector, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT);

    level.hellround_collectors = new HellroundCollectors();
    level.hellround_collectors.volumes = [];
    level.hellround_collectors.volumes[0] = FindVolumeDecalIndexArray(HRCOLL_VOLUMES[0]);
    level.hellround_collectors.volumes[1] = FindVolumeDecalIndexArray(HRCOLL_VOLUMES[1]);
    level.hellround_collectors.volumes[2] = FindVolumeDecalIndexArray(HRCOLL_VOLUMES[2]);
}

function hellround_collector(n_client_num, _oldVal, n_iteration, _bNewEnt, _bInitialSnap, _fieldName, _bWasTimeJump)
{
    util::waitforclient(n_client_num);

    update_hellround_collector_volumes(n_iteration);
}

// #region volumes

function private update_hellround_collector_volumes(n_iteration)
{
    foreach(volumes in level.hellround_collectors.volumes)
    {
        foreach(volume in volumes)
        {
            HideVolumeDecal(volume);
        }
    }

    if (n_iteration == HRCOLL_DISABLED)
    {
        return;
    }

    volumes_index = n_iteration - 1;
    volumes_to_show = level.hellround_collectors.volumes[volumes_index];

    foreach(volume in volumes_to_show)
    {
        UnhideVolumeDecal(volume);
    }
}

// #endregion
