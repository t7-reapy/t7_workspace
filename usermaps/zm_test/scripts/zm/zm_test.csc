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

#precache ("client_fx", "custom/flashlight/flashlight_loop");
#precache ("client_fx", "custom/flashlight/flashlight_loop_world");
#precache ("client_fx", "custom/flashlight/flashlight_loop_view_moths");


function main()
{    
	// Rain player
	clientfield::register( "world", "rain_fx_stop", VERSION_SHIP, 1, "int", &rain_toggle, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
    level.rain_fx_enabled = true;

	// Decal
	clientfield::register( "world", "decal_toggle", VERSION_SHIP, 1, "int", &decal_toggle, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	level.vdIndexArray = FindVolumeDecalIndexArray( "decalrain" );

    //Flashlight
    clientfield::register( "toplayer", "flashlight_fx_view", VERSION_SHIP, 1, "int", &flashlight_fx_view, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
    clientfield::register( "allplayers", "flashlight_fx_world", VERSION_SHIP, 1, "int", &flashlight_fx_world, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
    
	zm_usermap::main();

	include_weapons();

	//FX
	precache_fx();
	
	thread ApplyRainOnAllPlayers();
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


function include_weapons()
{
	zm_weapons::load_weapon_spec_from_table("gamedata/weapons/zm/zm_levelcommon_weapons.csv", 1);
}

function precache_fx()
{
	//level._effect[ "player_rain" ] = "custom/env/fx_rain_player_z_light";
	//level._effect[ "player_rain" ] = "custom/env/fx_rain_player_z_regular";
	level._effect[ "player_rain" ] = "custom/env/fx_rain_player_z_heavy";

    //Flashlight
    level._effect[ "flashlight_fx_loop_view" ] = "custom/flashlight/flashlight_loop";
    level._effect[ "flashlight_fx_loop_view_moths" ] = "custom/flashlight/flashlight_loop_view_moths";
    level._effect[ "flashlight_fx_loop_world" ] = "custom/flashlight/flashlight_loop_world";
}

function ApplyRainOnAllPlayers() {
	util::waitforallclients();
    players = GetLocalPlayers();

    for( i = 0; i < players.size; i++ )
    {
        players[i] thread rain_player(i);
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

//*****************************************************************************
// FLASHLIGHT
//*****************************************************************************
function flashlight_fx_view( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump ) // self == player
{
    if ( newVal )
    {
        if ( isdefined( self.fx_flashlight_view ) )
            KillFx( localClientNum, self.fx_flashlight_view );

        if ( isdefined( self.fx_flashlight_moth ) )
            KillFx( localClientNum, self.fx_flashlight_moth );

        flash_fx_view = level._effect[ "flashlight_fx_loop_view" ];
            self.fx_flashlight_view = PlayViewmodelFx( localclientnum, flash_fx_view, "tag_flash" ); 

        flash_fx_moth = level._effect[ "flashlight_fx_loop_view_moths" ];
            self.fx_flashlight_moth = PlayFxOnTag( localClientNum, flash_fx_moth, self, "j_spine4" );

        playsound( localClientNum, "flashlight_on", self.origin ); 
    }
    else
    {
        if ( isdefined( self.fx_flashlight_view ) )
        {
            KillFx( localClientNum, self.fx_flashlight_view );
                self.fx_flashlight_view = undefined;

            playsound( localClientNum, "flashlight_off", self.origin ); 
        }

        if ( isdefined( self.fx_flashlight_moth ) )
        {
            KillFx( localClientNum, self.fx_flashlight_moth );
                self.fx_flashlight_moth = undefined;
        }
    }
}

function flashlight_fx_world( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump ) // self == player
{
    if ( newVal )
    {
        curr_player = GetLocalPlayer( localClientNum );

        if ( isdefined( self.fx_flashlight_world ) )
            KillFx( localClientNum, self.fx_flashlight_world );

        if( curr_player != self )
        {
            flash_fx_world = level._effect[ "flashlight_fx_loop_world" ];
                self.fx_flashlight_world = PlayFxOnTag( localClientNum, flash_fx_world, self, "tag_flash" );
        }
    }
    else
    {
        if ( isdefined( self.fx_flashlight_world ) )
        {
            KillFx( localClientNum, self.fx_flashlight_world );
                self.fx_flashlight_world = undefined;
        }
    }
}
