/*
Rain Template by Ardivee & Zeroy
April 2017

Tutorial: http://wiki.modsrepository.com/index.php?title=Call_of_duty_bo3:_Rain
*/
#using scripts\codescripts\struct;
#using scripts\shared\audio_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_load;
#using scripts\zm\_zm_weapons;

//Perks
#using scripts\zm\_zm_pack_a_punch;
#using scripts\zm\_zm_perk_additionalprimaryweapon;
#using scripts\zm\_zm_perk_doubletap2;
#using scripts\zm\_zm_perk_deadshot;
#using scripts\zm\_zm_perk_juggernaut;
#using scripts\zm\_zm_perk_quick_revive;
#using scripts\zm\_zm_perk_sleight_of_hand;
#using scripts\zm\_zm_perk_staminup;

//Powerups
#using scripts\zm\_zm_powerup_double_points;
#using scripts\zm\_zm_powerup_carpenter;
#using scripts\zm\_zm_powerup_fire_sale;
#using scripts\zm\_zm_powerup_free_perk;
#using scripts\zm\_zm_powerup_full_ammo;
#using scripts\zm\_zm_powerup_insta_kill;
#using scripts\zm\_zm_powerup_nuke;

//Traps
#using scripts\zm\_zm_trap_electric;

#using scripts\zm\zm_usermap;

#precache ("client_fx", "custom/env/fx_rain_player_z_light");
#precache ("client_fx", "custom/env/fx_rain_player_z_regular");
#precache ("client_fx", "custom/env/fx_rain_player_z_heavy");

function main()
{
	clientfield::register( "world", "rain_fx_stop", VERSION_SHIP, 1, "int", &rain_toggle, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
    // Rain player
    level.rain_fx_enabled = true;

	// Decal
	clientfield::register( "world", "decal_toggle", VERSION_SHIP, 1, "int", &decal_toggle, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	level.vdIndexArray = FindVolumeDecalIndexArray( "decalrain" );

	zm_usermap::main();

	include_weapons();

	//FX
	precache_fx();
	
	util::waitforclient( 0 );

    waitrealtime( 1 );

    players = GetLocalPlayers();

    for( i = 0; i < players.size; i++ )
    {
        players[i] thread rain_player(i);
    }
}

function precache_fx()
{
	//level._effect[ "player_rain" ] = "custom/env/fx_rain_player_z_light";
	level._effect[ "player_rain" ] = "custom/env/fx_rain_player_z_regular";
	//level._effect[ "player_rain" ] = "custom/env/fx_rain_player_z_heavy";
}

function include_weapons()
{
	zm_weapons::load_weapon_spec_from_table("gamedata/weapons/zm/zm_levelcommon_weapons.csv", 1);
}

function rain_toggle( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump )
{
    if(newVal)
    {
        level.rain_fx_enabled = false;
    } else {
        level.rain_fx_enabled = true;
    }
}

function decal_toggle( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump )
{
    if(newVal)
    {
        //IPrintLnBold("Decal HIDE");
        for(i=0; i < level.vdIndexArray.size; i++)
        {
            HideVolumeDecal(level.vdIndexArray[i]);
        }
    } else {
        //IPrintLnBold("Decal UNHIDE");
        for(i=0; i < level.vdIndexArray.size; i++)
        {
            UnhideVolumeDecal(level.vdIndexArray[i]);
        }
    }
}

function rain_player( localclientnum )
{
    self endon( "disconnect" );
    self endon( "entityshutdown" );

    self.rain_fx_tag = Spawn( localClientNum, self.origin, "script_model" );
    self.rain_fx_tag setModel("tag_origin");

    self.rain_fx = PlayFxOnTag( localClientNum, level._effect[ "player_rain" ], self.rain_fx_tag, "tag_origin" );

    SetFXIgnorePause( localClientNum, self.rain_fx, true );
    SetFXOutdoor( localClientNum , self.rain_fx);

    while(1)
    {
        waitrealtime( 0.1 );
        if(level.rain_fx_enabled)
        {
            if(!isdefined(self.rain_fx))
            {
                self.rain_fx = PlayFxOnTag( localClientNum, level._effect[ "player_rain" ], self.rain_fx_tag, "tag_origin" );

                SetFXIgnorePause( localClientNum, self.rain_fx, true );
                SetFXOutdoor( localClientNum , self.rain_fx);
            }
            self.rain_fx_tag.origin = self.origin;
        } else {
            if(isdefined(self.rain_fx))
            {
                DeleteFX( localclientnum, self.rain_fx );
                self.rain_fx = undefined;
            }
        }
        
    }
}