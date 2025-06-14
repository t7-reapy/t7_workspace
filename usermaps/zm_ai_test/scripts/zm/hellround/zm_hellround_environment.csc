#using scripts\codescripts\struct;
#using scripts\shared\audio_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;
#using scripts\shared\system_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\hellround\zm_hellround_environment.gsh;
#namespace zm_hellround_environment;

REGISTER_SYSTEM_EX("zm_hellround_environment", &init, &main, undefined)

function init() 
{
    level.bloodVolumeDecals = FindVolumeDecalIndexArray("decal_blood");
    level.bloodStaticModels = FindStaticModelIndexArray("model_blood");
    clientfield::register("world", BLOODY_TOGGLE_CLIENT_FIELD, VERSION_SHIP, 1, "int", &decal_toggle_blood, !CF_HOST_ONLY, !BLOODY_ENV_SHOW_INIT);
}

function main() 
{
}

function decal_toggle_blood(_localClientNum, _oldVal, showBlood, _bNewEnt, _bInitialSnap, _fieldName, _bWasTimeJump)
{
    if(isdefined(showBlood) && showBlood)
    {
        blood_fog_start();
        for(i=0; i < level.bloodVolumeDecals.size; i++)
        {
            UnhideVolumeDecal(level.bloodVolumeDecals[i]);
        }
        for(i=0; i < level.bloodStaticModels.size; i++)
        {
            UnhideStaticModel(level.bloodStaticModels[i]);
        }
    } 
    else
    {
        blood_fog_stop();
        for(i=0; i < level.bloodVolumeDecals.size; i++)
        {
            HideVolumeDecal(level.bloodVolumeDecals[i]);
        }
        for(i=0; i < level.bloodStaticModels.size; i++)
        {
            HideStaticModel(level.bloodStaticModels[i]);
        }
    }
}

function blood_fog_start()
{
    for (client_number = 0; client_number < level.localPlayers.size;client_number++)
    {
        SetWorldFogActiveBank(client_number, FOG_BANK_2);
        SetLitFogBank(client_number, -1, 1, -1);
    }
}

function blood_fog_stop()
{
    for (client_number = 0; client_number < level.localPlayers.size;client_number++)
    {
        SetWorldFogActiveBank(client_number, FOG_BANK_1);
        SetLitFogBank(client_number, -1, 0, -1);
    }
}