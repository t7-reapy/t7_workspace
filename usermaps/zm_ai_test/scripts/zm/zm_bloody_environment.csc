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

#insert scripts\zm\zm_bloody_environment.gsh;
#namespace zm_bloody_environment;

REGISTER_SYSTEM_EX("zm_bloody_environment", &init, &main, undefined)

function init() 
{
    level.bloodVolumeDecals = FindVolumeDecalIndexArray( "decal_blood" );
    clientfield::register( "world", "decal_toggle_blood", VERSION_SHIP, 1, "int", &decal_toggle_blood, !CF_HOST_ONLY, !BLOOD_DECALS_SHOW_INIT);
}

function main() 
{
    thread blood_fog_start_watcher();
    thread blood_fog_stop_watcher();
}

function decal_toggle_blood(_localClientNum, _oldVal, showBlood, _bNewEnt, _bInitialSnap, _fieldName, _bWasTimeJump)
{
    if(isdefined(showBlood) && showBlood)
    {
        for(i=0; i < level.bloodVolumeDecals.size; i++)
        {
            UnhideVolumeDecal(level.bloodVolumeDecals[i]);
        }
    } 
    else
    {
        for(i=0; i < level.bloodVolumeDecals.size; i++)
        {
            HideVolumeDecal(level.bloodVolumeDecals[i]);
        }
    }
}

function blood_fog_start_watcher()
{
    while ( 1 )
    {
        level waittill("blood_fog_start");
        thread blood_fog_start();
    }
}

function blood_fog_stop_watcher()
{
    while ( 1 )
    {
        level waittill("blood_fog_stop");
        thread blood_fog_stop();
    }
}

function blood_fog_start()
{
    for (client_number = 0; client_number < level.localPlayers.size;client_number++)
    {
        SetLitFogBank(client_number, -1, 1, -1);
        SetWorldFogActiveBank(client_number, FOG_BANK_2);
    }
}

function blood_fog_stop()
{
    for (client_number = 0; client_number < level.localPlayers.size;client_number++)
    {
        SetLitFogBank(client_number, -1, 0, -1);
        SetWorldFogActiveBank(client_number, FOG_BANK_1);
    }
}