#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\compass;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\_zm_utility.gsh;

#using scripts\zm\_load;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_zonemgr;
#using scripts\zm\_zm_score;  
#using scripts\zm\_zm_laststand; 
#using scripts\shared\aat_shared;
#using scripts\shared\bots\_bot;


//Perks
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_pack_a_punch;
#using scripts\zm\_zm_pack_a_punch_util;
#using scripts\zm\_zm_perk_additionalprimaryweapon;
#using scripts\zm\_zm_perk_doubletap2;
#using scripts\zm\_zm_perk_deadshot;
#using scripts\zm\_zm_perk_juggernaut;
#using scripts\zm\_zm_perk_quick_revive;
#using scripts\zm\_zm_perk_sleight_of_hand;
#using scripts\zm\_zm_perk_staminup;
#using scripts\zm\_zm_perk_electric_cherry;
#using scripts\zm\_zm_perk_widows_wine;

//Powerups
#using scripts\zm\_zm_powerup_double_points;
#using scripts\zm\_zm_powerup_carpenter;
#using scripts\zm\_zm_powerup_fire_sale;
#using scripts\zm\_zm_powerup_free_perk;
#using scripts\zm\_zm_powerup_full_ammo;
#using scripts\zm\_zm_powerup_insta_kill;
#using scripts\zm\_zm_powerup_nuke;
#using scripts\zm\_zm_powerup_weapon_minigun;

// Weapons
#using scripts\zm\_zm_weap_bowie;
#using scripts\zm\_zm_weap_bouncingbetty;
#using scripts\zm\_zm_weap_cymbal_monkey;
#using scripts\zm\_zm_weap_tesla;
#using scripts\zm\_zm_weap_rocketshield;
#using scripts\zm\_zm_weap_gravityspikes;
#using scripts\zm\_zm_weap_annihilator;
#using scripts\zm\_zm_weap_thundergun;
#using scripts\zm\_zm_weap_octobomb;
#using scripts\zm\_zm_weap_raygun_mark3;

//Traps
#using scripts\zm\_zm_trap_electric;

// AI
#using scripts\shared\ai\zombie;
#using scripts\shared\ai\behavior_zombie_dog;
#using scripts\shared\ai\zombie_utility;

#using scripts\zm\_zm_ai_dogs;

#using scripts\zm\zm_usermap_ai;

#precache( "fx", "misc/fx_zombie_eye_single" );
#precache( "fx", "impacts/fx_flesh_hit" );
#precache( "fx", "misc/fx_zombie_bloodsplat" );
#precache( "fx", "misc/fx_zombie_bloodspurt" );
#precache( "fx", "weapon/bullet/fx_flesh_gib_fatal_01" );
#precache( "fx", "trail/fx_trail_blood_streak" );
#precache( "fx", "zombie/fx_glow_eye_orange" );
#precache( "fx", "zombie/fx_bul_flesh_head_fatal_zmb" );
#precache( "fx", "zombie/fx_bul_flesh_head_nochunks_zmb" );
#precache( "fx", "zombie/fx_bul_flesh_neck_spurt_zmb" );
#precache( "fx", "zombie/fx_blood_torso_explo_zmb" );
#precache( "fx", "trail/fx_trail_blood_streak" );
#precache( "fx", "electric/fx_elec_sparks_directional_orange" );

#precache( "fx", "zombie/fx_perk_juggernaut_factory_zmb" );
#precache( "fx", "zombie/fx_perk_quick_revive_factory_zmb" );
#precache( "fx", "zombie/fx_perk_sleight_of_hand_factory_zmb" );
#precache( "fx", "zombie/fx_perk_doubletap2_factory_zmb" );
#precache( "fx", "zombie/fx_perk_daiquiri_factory_zmb" );
#precache( "fx", "zombie/fx_perk_stamin_up_factory_zmb" );
#precache( "fx", "zombie/fx_perk_mule_kick_factory_zmb" );
#precache( "fx", "dlc5/zmhd/fx_perk_widows_wine" );

#precache( "triggerstring", "ZOMBIE_NEED_POWER" );
#precache( "triggerstring", "ZOMBIE_ELECTRIC_SWITCH");
#precache( "triggerstring", "ZOMBIE_ELECTRIC_SWITCH_OFF");
 
#precache( "triggerstring", "ZOMBIE_PERK_QUICKREVIVE","500" );
#precache( "triggerstring", "ZOMBIE_PERK_QUICKREVIVE","1500" );
#precache( "triggerstring", "ZOMBIE_PERK_FASTRELOAD","3000" );
#precache( "triggerstring", "ZOMBIE_PERK_DOUBLETAP","2000" );
#precache( "triggerstring", "ZOMBIE_PERK_JUGGERNAUT","2500" );
#precache( "triggerstring", "ZOMBIE_PERK_MARATHON", "2000" );
#precache( "triggerstring", "ZOMBIE_PERK_DEADSHOT", "1500" );
#precache( "triggerstring", "ZOMBIE_PERK_WIDOWSWINE", "4000" );
#precache( "triggerstring", "ZOMBIE_PERK_ADDITIONALPRIMARYWEAPON","4000" );
 
#precache( "triggerstring", "ZOMBIE_PERK_PACKAPUNCH","5000" );
#precache( "triggerstring", "ZOMBIE_PERK_PACKAPUNCH","1000" );
#precache( "triggerstring", "ZOMBIE_PERK_PACKAPUNCH_AAT","2500" );
#precache( "triggerstring", "ZOMBIE_PERK_PACKAPUNCH_AAT","500" );
 
#precache( "triggerstring", "ZOMBIE_RANDOM_WEAPON_COST","950" );
#precache( "triggerstring", "ZOMBIE_RANDOM_WEAPON_COST","10" );

#precache( "triggerstring", "ZOMBIE_BGB_MACHINE_OUT_OF");
#precache( "triggerstring", "ZOMBIE_BGB_MACHINE_OFFERING");
#precache( "triggerstring", "ZOMBIE_BGB_MACHINE_AVAILABLE_CFILL");
#precache( "triggerstring", "ZOMBIE_BGB_MACHINE_AVAILABLE");
#precache( "triggerstring", "ZOMBIE_BGB_MACHINE_COMEBACK");

#precache( "triggerstring", "ZOMBIE_RANDOM_PERK_TOO_MANY" );
#precache( "triggerstring", "ZOMBIE_RANDOM_PERK_BUY" );
#precache( "triggerstring", "ZOMBIE_RANDOM_PERK_PICKUP" );
#precache( "triggerstring", "ZOMBIE_RANDOM_PERK_ELSEWHERE" );
 
#precache( "triggerstring", "ZOMBIE_UNDEFINED" );

#define JUGGERNAUT_MACHINE_LIGHT_FX                                     "jugger_light"        
#define QUICK_REVIVE_MACHINE_LIGHT_FX                                   "revive_light"    
#define SLEIGHT_OF_HAND_MACHINE_LIGHT_FX                                "sleight_light"    
#define DOUBLETAP2_MACHINE_LIGHT_FX                                     "doubletap2_light"    
#define DEADSHOT_MACHINE_LIGHT_FX                                       "deadshot_light"    
#define STAMINUP_MACHINE_LIGHT_FX                                       "marathon_light"    
#define ADDITIONAL_PRIMARY_WEAPON_MACHINE_LIGHT_FX                      "additionalprimaryweapon_light"
#define ELECTRIC_CHERRY_MACHINE_LIGHT_FX                                "electric_cherry_light"
#define WIDOWS_WINE_FX_MACHINE_LIGHT                                    "widow_light"

#define PLAYTYPE_REJECT 1
#define PLAYTYPE_QUEUE 2
#define PLAYTYPE_ROUND 3
#define PLAYTYPE_SPECIAL 4
#define PLAYTYPE_GAMEEND 5

#namespace zm_usermap; 

//*****************************************************************************
// MAIN
//*****************************************************************************

function autoexec opt_in()
{
	DEFAULT(level.aat_in_use,true);
	DEFAULT(level.bgb_in_use,true);
}

function autoexec init_fx()
{
	clientfield::register( "clientuimodel", "player_lives", VERSION_SHIP, 2, "int" );
}

function main()
{
	level._uses_default_wallbuy_fx = 1;
	
	zm::init_fx();

	level util::set_lighting_state( 0 );
	
	level._effect["eye_glow"]				= "zombie/fx_glow_eye_orange";
	level._effect["headshot"]				= "zombie/fx_bul_flesh_head_fatal_zmb";
	level._effect["headshot_nochunks"]		= "zombie/fx_bul_flesh_head_nochunks_zmb";
	level._effect["bloodspurt"]				= "zombie/fx_bul_flesh_neck_spurt_zmb";

	level._effect["animscript_gib_fx"]		= "zombie/fx_blood_torso_explo_zmb"; 
	level._effect["animscript_gibtrail_fx"]	= "trail/fx_trail_blood_streak"; 	
	level._effect["switch_sparks"]			= "electric/fx_elec_sparks_directional_orange";

	//Setup game mode defaults
	level.default_start_location = "start_room";	
	level.default_game_mode = "zclassic";	
	
	level.giveCustomLoadout =&giveCustomLoadout;
	level.precacheCustomCharacters =&precacheCustomCharacters;
	level.giveCustomCharacters =&giveCustomCharacters;
	level thread setup_personality_character_exerts();
	initCharacterStartIndex();

	//Weapons and Equipment
	level.register_offhand_weapons_for_level_defaults_override = &offhand_weapon_overrride;
	level.zombiemode_offhand_weapon_give_override = &offhand_weapon_give_override;

	DEFAULT(level._zombie_custom_add_weapons,&custom_add_weapons);
	
	level._allow_melee_weapon_switching = 1;
	
	level.zombiemode_reusing_pack_a_punch = true;

	//Level specific stuff
	include_weapons();

	load::main();

	//Handles Power Switch
	level thread PowerSwitch();

	DEFAULT(level.dog_rounds_allowed,1);
	if( level.dog_rounds_allowed )
	{
		zm_ai_dogs::enable_dog_rounds();
	}
	
	_zm_weap_cymbal_monkey::init();
	_zm_weap_tesla::init();
	level._round_start_func = &zm::round_start;
	
	perk_init();
	level thread zm_perks::spare_change();
	array::thread_all(GetEntArray("audio_bump_trigger", "targetname"), &zm_perks::thread_bump_trigger);

	//Developer Commands
	if(isDefined(level.enable_dvars) && level.enable_dvars)
	{
		level thread dvar_commands();
	}

    level thread sndFunctions();

}

function template_test_zone_init()
{
	level flag::init( "always_on" );
	level flag::set( "always_on" );
}	

function offhand_weapon_overrride()
{
	zm_utility::register_lethal_grenade_for_level( "frag_grenade" );
	level.zombie_lethal_grenade_player_init = GetWeapon( "frag_grenade" );

	zm_utility::register_melee_weapon_for_level( level.weaponBaseMelee.name );
	level.zombie_melee_weapon_player_init = level.weaponBaseMelee;

	zm_utility::register_tactical_grenade_for_level( "cymbal_monkey" );
	zm_utility::register_tactical_grenade_for_level( "octobomb" );

	
	level.zombie_equipment_player_init = undefined;
}

function offhand_weapon_give_override( weapon )
{
	self endon( "death" );
	
	if( zm_utility::is_tactical_grenade( weapon ) && IsDefined( self zm_utility::get_player_tactical_grenade() ) && !self zm_utility::is_player_tactical_grenade( weapon )  )
	{
		self SetWeaponAmmoClip( self zm_utility::get_player_tactical_grenade(), 0 );
		self TakeWeapon( self zm_utility::get_player_tactical_grenade() );
	}
	return false;
}

function include_weapons()
{
}

function precacheCustomCharacters()
{
}

function initCharacterStartIndex()
{
	level.characterStartIndex = RandomInt( 4 );
}

function selectCharacterIndexToUse()
{
	if( level.characterStartIndex>=4 )
	level.characterStartIndex = 0;

	self.characterIndex = level.characterStartIndex;
	level.characterStartIndex++;

	return self.characterIndex;
}


function assign_lowest_unused_character_index()
{
	//get the lowest unused character index
	charindexarray = [];
	charindexarray[0] = 0;// - Dempsey )
	charindexarray[1] = 1;// - Nikolai )
	charindexarray[2] = 2;// - Richtofen )
	charindexarray[3] = 3;// - Takeo )
	
	players = GetPlayers();
	if ( players.size == 1 )
	{
		charindexarray = array::randomize( charindexarray );
		if ( charindexarray[0] == 2 )
		{
			level.has_richtofen = true;	
		}

		return charindexarray[0];
	}
	else // 2 or more players just assign the lowest unused value
	{
		n_characters_defined = 0;

		foreach ( player in players )
		{
			if ( isDefined( player.characterIndex ) )
			{
				ArrayRemoveValue( charindexarray, player.characterIndex, false );
				n_characters_defined++;
			}
		}
		
		if ( charindexarray.size > 0 )
		{
			// If this is the last guy and we don't have Richtofen in the group yet, make sure he's Richtofen
			if ( n_characters_defined == (players.size - 1) )
			{
				if ( !IS_TRUE( level.has_richtofen ) )
				{
					level.has_richtofen = true;
					return 2;
				}	
			}
			
			// Randomize the array
			charindexarray = array::randomize(charindexarray);
			if ( charindexarray[0] == 2 )
			{
				level.has_richtofen = true;	
			}

			return charindexarray[0];
		}
	}

	//failsafe
	return 0;
}

function giveCustomCharacters()
{
	if( isdefined(level.hotjoin_player_setup) && [[level.hotjoin_player_setup]]("c_zom_farmgirl_viewhands") )
	{
		return;
	}
	
	self DetachAll();
	
	// Only Set Character Index If Not Defined, Since This Thread Gets Called Each Time Player Respawns
	//-------------------------------------------------------------------------------------------------
	if ( !isdefined( self.characterIndex ) )
	{
		self.characterIndex = assign_lowest_unused_character_index();
	}
	
	self.favorite_wall_weapons_list = [];
	self.talks_in_danger = false;	
	
	self SetCharacterBodyType( self.characterIndex );
	self SetCharacterBodyStyle( 0 );
	self SetCharacterHelmetStyle( 0 );
	
	switch( self.characterIndex )
	{
		case 1:
		{
				// Nikolai
//				level.vox zm_audio::zmbVoxInitSpeaker( "player", "vox_plr_", self );				
				self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = GetWeapon( "870mcs" );
				break;
		}
		case 0:
		{
				// Dempsey

//				level.vox zm_audio::zmbVoxInitSpeaker( "player", "vox_plr_", self );				
				self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = GetWeapon( "frag_grenade" );
				self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = GetWeapon( "bouncingbetty" );
				break;
		}
		case 3:
		{
				// Takeo
//				level.vox zm_audio::zmbVoxInitSpeaker( "player", "vox_plr_", self );
				self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = GetWeapon( "hk416" );
				break;
		}
		case 2:
		{	
				// Richtofen
//				level.vox zm_audio::zmbVoxInitSpeaker( "player", "vox_plr_", self );
				self.talks_in_danger = true;
				level.rich_sq_player = self;
				level.sndRadioA = self;
				self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = GetWeapon( "pistol_standard" );
				break;
		}
	}	

	self SetMoveSpeedScale( 1 );
	self SetSprintDuration( 4 );
	self SetSprintCooldown( 0 );	

	//self zm_utility::set_player_tombstone_index();	
	self thread set_exert_id();
	
}

function set_exert_id()
{
	self endon("disconnect");
	
	util::wait_network_frame();
	util::wait_network_frame();
	
	self zm_audio::SetExertVoice(self.characterIndex + 1);
}

function setup_personality_character_exerts()
{
	level.exert_sounds[1]["burp"][0] = "evt_belch";
	level.exert_sounds[1]["burp"][1] = "evt_belch";
	level.exert_sounds[1]["burp"][2] = "evt_belch";

	level.exert_sounds[2]["burp"][0] = "evt_belch";
	level.exert_sounds[2]["burp"][1] = "evt_belch";
	level.exert_sounds[2]["burp"][2] = "evt_belch";

	level.exert_sounds[3]["burp"][0] = "evt_belch";
	level.exert_sounds[3]["burp"][1] = "evt_belch";
	level.exert_sounds[3]["burp"][2] = "evt_belch";
	
	level.exert_sounds[4]["burp"][0] = "evt_belch";
	level.exert_sounds[4]["burp"][1] = "evt_belch";
	level.exert_sounds[4]["burp"][2] = "evt_belch";
	

	// medium hit
	level.exert_sounds[1]["hitmed"][0] = "vox_plr_0_exert_pain_0";
	level.exert_sounds[1]["hitmed"][1] = "vox_plr_0_exert_pain_1";
	level.exert_sounds[1]["hitmed"][2] = "vox_plr_0_exert_pain_2";
	level.exert_sounds[1]["hitmed"][3] = "vox_plr_0_exert_pain_3";
	level.exert_sounds[1]["hitmed"][4] = "vox_plr_0_exert_pain_4";
	
	level.exert_sounds[2]["hitmed"][0] = "vox_plr_1_exert_pain_0";
	level.exert_sounds[2]["hitmed"][1] = "vox_plr_1_exert_pain_1";
	level.exert_sounds[2]["hitmed"][2] = "vox_plr_1_exert_pain_2";
	level.exert_sounds[2]["hitmed"][3] = "vox_plr_1_exert_pain_3";
	level.exert_sounds[2]["hitmed"][4] = "vox_plr_1_exert_pain_4";
	
	level.exert_sounds[3]["hitmed"][0] = "vox_plr_2_exert_pain_0";
	level.exert_sounds[3]["hitmed"][1] = "vox_plr_2_exert_pain_1";
	level.exert_sounds[3]["hitmed"][2] = "vox_plr_2_exert_pain_2";
	level.exert_sounds[3]["hitmed"][3] = "vox_plr_2_exert_pain_3";
	level.exert_sounds[3]["hitmed"][4] = "vox_plr_2_exert_pain_4";
	
	level.exert_sounds[4]["hitmed"][0] = "vox_plr_3_exert_pain_0";
	level.exert_sounds[4]["hitmed"][1] = "vox_plr_3_exert_pain_1";
	level.exert_sounds[4]["hitmed"][2] = "vox_plr_3_exert_pain_2";
	level.exert_sounds[4]["hitmed"][3] = "vox_plr_3_exert_pain_3";
	level.exert_sounds[4]["hitmed"][4] = "vox_plr_3_exert_pain_4";

	// large hit
	level.exert_sounds[1]["hitlrg"][0] = "vox_plr_0_exert_pain_0";
	level.exert_sounds[1]["hitlrg"][1] = "vox_plr_0_exert_pain_1";
	level.exert_sounds[1]["hitlrg"][2] = "vox_plr_0_exert_pain_2";
	level.exert_sounds[1]["hitlrg"][3] = "vox_plr_0_exert_pain_3";
	level.exert_sounds[1]["hitlrg"][4] = "vox_plr_0_exert_pain_4";
	
	level.exert_sounds[2]["hitlrg"][0] = "vox_plr_1_exert_pain_0";
	level.exert_sounds[2]["hitlrg"][1] = "vox_plr_1_exert_pain_1";
	level.exert_sounds[2]["hitlrg"][2] = "vox_plr_1_exert_pain_2";
	level.exert_sounds[2]["hitlrg"][3] = "vox_plr_1_exert_pain_3";
	level.exert_sounds[2]["hitlrg"][4] = "vox_plr_1_exert_pain_4";
	
	level.exert_sounds[3]["hitlrg"][0] = "vox_plr_2_exert_pain_0";
	level.exert_sounds[3]["hitlrg"][1] = "vox_plr_2_exert_pain_1";
	level.exert_sounds[3]["hitlrg"][2] = "vox_plr_2_exert_pain_2";
	level.exert_sounds[3]["hitlrg"][3] = "vox_plr_2_exert_pain_3";
	level.exert_sounds[3]["hitlrg"][4] = "vox_plr_2_exert_pain_4";
	
	level.exert_sounds[4]["hitlrg"][0] = "vox_plr_3_exert_pain_0";
	level.exert_sounds[4]["hitlrg"][1] = "vox_plr_3_exert_pain_1";
	level.exert_sounds[4]["hitlrg"][2] = "vox_plr_3_exert_pain_2";
	level.exert_sounds[4]["hitlrg"][3] = "vox_plr_3_exert_pain_3";
	level.exert_sounds[4]["hitlrg"][4] = "vox_plr_3_exert_pain_4";
}

function PowerSwitch()
{
    level endon("end_game");

    for(;;)
    {
        level flag::wait_till( "power_on" );
        level util::set_lighting_state( 2 );
        level flag::wait_till_clear( "power_on" );
        level util::set_lighting_state( 0 );
    }
}

function giveCustomLoadout( takeAllWeapons, alreadySpawned )
{
	self giveWeapon( level.weaponBaseMelee );
	self zm_utility::give_start_weapon( true );
}

function custom_add_weapons()
{
	zm_weapons::load_weapon_spec_from_table("gamedata/weapons/zm/zm_levelcommon_weapons.csv", 1);
}

function perk_init()
{
	level._effect[JUGGERNAUT_MACHINE_LIGHT_FX] = "zombie/fx_perk_juggernaut_factory_zmb";
	level._effect[QUICK_REVIVE_MACHINE_LIGHT_FX] = "zombie/fx_perk_quick_revive_factory_zmb";
	level._effect[SLEIGHT_OF_HAND_MACHINE_LIGHT_FX] = "zombie/fx_perk_sleight_of_hand_factory_zmb";
	level._effect[DOUBLETAP2_MACHINE_LIGHT_FX] = "zombie/fx_perk_doubletap2_factory_zmb";	
	level._effect[DEADSHOT_MACHINE_LIGHT_FX] = "zombie/fx_perk_daiquiri_factory_zmb";
	level._effect[STAMINUP_MACHINE_LIGHT_FX] = "zombie/fx_perk_stamin_up_factory_zmb";
	level._effect[ADDITIONAL_PRIMARY_WEAPON_MACHINE_LIGHT_FX] = "zombie/fx_perk_mule_kick_factory_zmb";
	level._effect[WIDOWS_WINE_FX_MACHINE_LIGHT] = "dlc5/zmhd/fx_perk_widows_wine";
	level._effect[ELECTRIC_CHERRY_MACHINE_LIGHT_FX] = "zombie/fx_perk_quick_revive_factory_zmb";
}

function sndFunctions()
{
	level thread setupMusic();
}

function setupMusic()
{
	zm_audio::musicState_Create("round_start", PLAYTYPE_ROUND, "roundstart1", "roundstart2", "roundstart3", "roundstart4" );
	zm_audio::musicState_Create("round_start_short", PLAYTYPE_ROUND, "roundstart_short1", "roundstart_short2", "roundstart_short3", "roundstart_short4" );
	zm_audio::musicState_Create("round_start_first", PLAYTYPE_ROUND, "roundstart_first" );
	zm_audio::musicState_Create("round_end", PLAYTYPE_ROUND, "roundend1" );
	zm_audio::musicState_Create("game_over", PLAYTYPE_GAMEEND, "gameover" );
	zm_audio::musicState_Create("dog_start", PLAYTYPE_ROUND, "dogstart1" );
	zm_audio::musicState_Create("dog_end", PLAYTYPE_ROUND, "dogend1" );
	zm_audio::musicState_Create("timer", PLAYTYPE_ROUND, "timer" );
	zm_audio::musicState_Create("power_on", PLAYTYPE_QUEUE, "poweron" );
}

function dvar_commands()
{
	SetDvar("sv_cheats", 1);
	thread lightstates();
	thread change_round();
	thread change_weapon_camo();
	thread change_characterindex();
	thread upgrade_weapon();
	thread downgrade_weapon();
	thread give_weapon();
	thread give_points();
	thread give_perks();
	thread give_powerups();
	thread add_bots();

}

function lightstates()
{
    ModVar("lightstate", "");

    for(;;)
	{
        WAIT_SERVER_FRAME;
        dvar_template = ToLower(GetDvarString("lightstate", ""));

        if(isdefined(dvar_template) && dvar_template != "")
        {
            ModVar("lightstate", "");

            level util::set_lighting_state(Int(dvar_template));
            IPrintLn("lighting state " + dvar_template);        
        }
    }
}

function private change_round()
{
    ModVar("round", "");

    for(;;)
	{
        WAIT_SERVER_FRAME;
        dvar_template = ToLower(GetDvarString("round", ""));

        if(isdefined(dvar_template) && dvar_template != "")
        {
            ModVar("round", "");

            round = Int(dvar_template);

            thread switch_round( round );
            IPrintLn("Round " + round);
        }
    }
}

function switch_round(round_number = undefined)
{
    if(!isdefined(round_number))
        round_number = zm::get_round_number();

    if(round_number == zm::get_round_number())
        return;
		
    if(round_number < 0)
        return;

    foreach(zombie in zombie_utility::get_round_enemy_array())
    {
        zombie Kill();
    }

    level.zombie_total = 0;
    level notify("end_of_round");
    wait 0.05;
    zm::set_round_number(round_number);
    round_number = zm::get_round_number();

    zombie_utility::ai_calculate_health(round_number);
    SetRoundsPlayed(round_number);

    if(level.gamedifficulty == 0)
        level.zombie_move_speed = round_number * level.zombie_vars["zombie_move_speed_multiplier_easy"];
    else
        level.zombie_move_speed = round_number * level.zombie_vars["zombie_move_speed_multiplier"];

    level.zombie_vars["zombie_spawn_delay"] = [[level.func_get_zombie_spawn_delay]](round_number);

    level.sndGotoRoundOccurred = true;
}

function private change_weapon_camo()
{
    ModVar("camo", "");

    for(;;)
	{
        WAIT_SERVER_FRAME;
        dvar_template = ToLower(GetDvarString("camo", ""));

        if(isdefined(dvar_template) && dvar_template != "")
        {
            ModVar("camo", "");

            string_token = StrTok(dvar_template, " ");
            if(string_token.size > 1)
			{
                player_index = Int(string_token[0]);
                value = Int(string_token[1]);

                if(player_index >= 0 && player_index <= 7)
				{
                    level.players[player_index] UpdateWeaponOptions( level.players[player_index] GetCurrentWeapon(), level.players[player_index] CalcWeaponOptions(value, 0, 0) );
                }
				else
				{
                    foreach(player in GetPlayers())
                        player UpdateWeaponOptions( player GetCurrentWeapon(), player CalcWeaponOptions(value, 0, 0) );
                }
                level.pack_a_punch_camo_index = value;
            }
			else
			{
                value = Int(string_token[0]);

                foreach(player in GetPlayers())
				{
                    player UpdateWeaponOptions( player GetCurrentWeapon(), player CalcWeaponOptions(value, 0, 0) );
                }

                level.pack_a_punch_camo_index = value;
            }
        }
    }
}

function change_characterindex()
{
    ModVar("character", "");
    for(;;)
	{
        dvar_template = ToLower( GetDvarString( "character", "" ) );
        if( isdefined( dvar_template ) && dvar_template != "" )
		{
            string_token = StrTok( dvar_template, " " );
            if( string_token.size > 1 ) 
			{
                player_index = Int( string_token[0] );
                character_index = Int( string_token[1] );
                if( isdefined( player_index ) && isdefined( character_index ) ) 
				{
					level.players[player_index] SetCharacterBodyType( character_index, character_index );
                }
            }
            ModVar("character", "");
        }
        wait .05;
    }
}

function upgrade_weapon()
{
	ModVar("upgrade_weapon", "none");

    for(;;)
	{

        WAIT_SERVER_FRAME;
        dvar_template = ToLower(GetDvarString("upgrade_weapon", "none"));

        if(isdefined(dvar_template) && dvar_template != "none")
        {
            ModVar("upgrade_weapon", "none");

            if(dvar_template == "")
			{
                foreach(player in GetPlayers())
				{
                    player upgrade_weapon();
                }
            }

            string_token = StrTok(dvar_template, " ");
            if(string_token.size > 1)
			{
                player_index = Int(string_token[0]);
                value = Int(string_token[1]);

                if(player_index >= 0 && player_index <= 7)
				{
                    level.players[player_index] give_upgrade_weapon();
                }
				else
				{
                    array::thread_all( GetPlayers(), &give_upgrade_weapon ); 
                }
            }
			else
			{
                array::thread_all( GetPlayers(), &give_upgrade_weapon ); 
            }
        }
    }
}

function private give_upgrade_weapon()
{

    weap = self getcurrentweapon();
    weapon = zm_weapons::get_upgrade_weapon( weap, false );

    if ( ( isdefined( level.aat_in_use ) && level.aat_in_use ) )
    {
        self thread aat::acquire( weapon );
    }

    weapon.camo_index = self zm_weapons::get_pack_a_punch_weapon_options( weapon );

    self TakeWeapon( weap );
    self GiveWeapon( weapon, weapon.camo_index );

    if(self HasPerk("specialty_extraammo"))
        self GiveMaxAmmo( weapon );

    else
        self GiveStartAmmo( weapon );
   		self SwitchToWeapon( weapon );
}

function private downgrade_weapon()
{
    ModVar("downgrade_weapon", "");

    for(;;)
	{

        WAIT_SERVER_FRAME;
        dvar_template = ToLower(GetDvarString("downgrade_weapon", ""));

        if(isdefined(dvar_template) && dvar_template != "")
        {
            ModVar("downgrade_weapon", "");

            string_token = StrTok(dvar_template, " ");
            if(string_token.size > 1)
			{
                player_index = Int(string_token[0]);
                value = Int(string_token[1]);

                if(player_index >= 0 && player_index <= 7)
				{
                    level.players[player_index] downgrade_current_weapon();
                }
				else
				{
                    array::thread_all( GetPlayers(), &downgrade_current_weapon ); 
                }
            }
			else
			{
                value = Int(string_token[0]);
                array::thread_all( GetPlayers(), &downgrade_current_weapon ); 
            }
        }
    }
}

function private downgrade_current_weapon()
{

    weap = self getcurrentweapon();
    weapon = zm_weapons::get_base_weapon( weap );

    self TakeWeapon( weap );
    self GiveWeapon( weapon, self zm_weapons::get_pack_a_punch_weapon_options( weapon ) );
    self GiveStartAmmo( weapon );
    self SwitchToWeapon( weapon );
}

function give_points()
{
	ModVar("points", "");

    for(;;)
	{
        WAIT_SERVER_FRAME;
        dvar_template = ToLower(GetDvarString("points", ""));

        if(isdefined(dvar_template) && dvar_template != "")
        {
            ModVar("points", "");

            string_token = StrTok(dvar_template, " ");
            if(string_token.size > 1)
			{
                player_index = Int(string_token[0]);

                value = Int(string_token[1]);

                if(player_index >= 0 && player_index <= 7)
				{
                    level.players[player_index] zm_score::add_to_player_score( value );

                    zm_utility::play_sound_at_pos( "purchase", level.players[player_index].origin );
                }
				else
				{
                    foreach(player in GetPlayers())
					{
                        player zm_score::add_to_player_score( value );

                        zm_utility::play_sound_at_pos( "purchase", player.origin );
                    }
                }
            }
			else
			{
                value = Int(string_token[0]);

                foreach(player in GetPlayers())
				{
                    player zm_score::add_to_player_score( value );
					IPrintLn("points " + value);
					
                    zm_utility::play_sound_at_pos( "purchase", player.origin );
                }
            }
        }
    }
}

function private give_weapon()
{
    ModVar("give", "");

    for(;;)
	{
        WAIT_SERVER_FRAME;
        dvar_template = ToLower(GetDvarString("give", ""));

        if(isdefined(dvar_template) && dvar_template != "")
        {
            ModVar("give", "");

            string_token = StrTok(dvar_template, " ");
            if(string_token.size > 1)
			{
                player_index = Int(string_token[0]);
                weapon_name = string_token[1];

                if(weapon_name == "ammo")
				{
                    if(player_index >= 0 && player_index <= 7)
					{
                        level.players[player_index] thread give_player_max_ammo();
                    }
					else
					{
                        foreach(player in GetPlayers())
						{
                            player thread give_player_max_ammo();
                        }
                    }
                }
				else
				{
                    if(player_index >= 0 && player_index <= 7)
					{
                        level.players[player_index] zm_weapons::weapon_give( GetWeapon(weapon_name), false, false, true, true );
                    }
					else
					{
                        foreach(player in GetPlayers())
						{
                            player zm_weapons::weapon_give( GetWeapon(weapon_name), false, false, true, true );
                        }
                    }
                }
            }
			else
			{
                weapon_name = string_token[0];
                if(weapon_name == "ammo")
				{
                    array::thread_all( GetPlayers(), &give_player_max_ammo);
                }
				else
				{
                    foreach(player in GetPlayers())
					{
                        player zm_weapons::weapon_give( GetWeapon(weapon_name), false, false, true, true );
                    }
                }

            }
        }
    }
}

function private give_player_max_ammo()
{
    weapons_list = self GetWeaponsList(true);
    foreach(weapon in weapons_list)
	{
        if ( weapon != level.weaponNone )
        {
            self SetWeaponOverheating( 0,0 );
            max = weapon.maxAmmo;
            if (isdefined(max))
            {
                self SetWeaponAmmoStock( weapon, max );
            }
            
            if ( isdefined( self zm_utility::get_player_tactical_grenade() ) )
            {
                self GiveMaxAmmo( self zm_utility::get_player_tactical_grenade() );
            }
            if ( isdefined( self zm_utility::get_player_lethal_grenade() ) )
            {
                self GiveMaxAmmo( self zm_utility::get_player_lethal_grenade() );
            }
        }
    }
}

function private give_perks()
{
    ModVar("perk", "");

    for(;;)
	{
        WAIT_SERVER_FRAME;
        dvar_template = ToLower(GetDvarString("perk", ""));

        if(isdefined(dvar_template) && dvar_template != "")
        {
            ModVar("perk", "");

            string_token = StrTok(dvar_template, " ");

            if(string_token.size > 1)
			{
                player_index = Int(string_token[0]);

                perk = perk_name(string_token[1]);

                if(player_index >= 0 && player_index <= 7)
				{
                    level.players[player_index] give_player_perks( perk );
                }
				else
				{
                    array::thread_all( GetPlayers(), &give_player_perks, perk ); 
                }
            }
			else
			{
                array::thread_all( GetPlayers(), &give_player_perks, perk_name(string_token[0]) ); 
            }
        }
    }
}

function private give_player_perks( perk )
{
    vending_triggers = GetEntArray( "zombie_vending", "targetname" );

    if ( vending_triggers.size < 1 )
    {
        return;
    }

    if(perk == "all")
	{
        foreach( perk_a in GetArrayKeys( level._custom_perks ) )
		{
            self zm_perks::give_perk( perk_a, false );
            wait .5;
        }
    }
	else if(StrEndsWith(perk, ";"))
	{
        string_token = StrTok(perk, " ");
        for(i=0; i<string_token.size;i++)
		{
            self zm_perks::give_perk( string_token[i], false);
        }
    }
	else if(StrIsInt(perk))
	{
        perk = Int(perk);
        for(i=0; i<perk;i++)
		{
            self zm_perks::give_random_perk();
        }
    }
	else
	{
        self zm_perks::give_perk( perk, false );
    }
}

function give_powerups()
{
	ModVar("powerup", "");

    for(;;)
	{
        WAIT_SERVER_FRAME;

        dvar_template = ToLower(GetDvarString("powerup", ""));

        if(isdefined(dvar_template) && dvar_template != "")
        {
            ModVar("powerup", "");

            string_token = StrTok(dvar_template, " ");
            if(string_token.size > 1)
			{
                player_index = Int(string_token[0]);
                powerup_name = string_token[1];

                powerup = get_powerup_name(powerup_name);

                if(powerup != "all")
				{
                    for ( i = 0; i < level.zombie_powerup_array.size; i++ )
                    {
                        if ( level.zombie_powerup_array[i] == powerup )
                        {
                            level.zombie_powerup_index = i;
                            found = true;
                            break;
                        }
                    } 
                }
				else
				{
                    found = true;
                }
                if ( !found )
                {
                    continue;
                }

                if(player_index >= 0 && player_index <= 7)
				{
                    origin = level.players[player_index] set_position();
                    if(powerup == "all")
					{
						level.players[player_index] spawn_all_powerups();
					}
					else
					{
                        level thread zm_powerups::specific_powerup_drop(powerup, origin, undefined, undefined, undefined, undefined, false );
                    }
                }
				else
				{
                    foreach(player in GetPlayers())
					{
                        origin = player set_position();
                        if(powerup == "all")
						{
							player spawn_all_powerups();
						}
						else
						{
                            level thread zm_powerups::specific_powerup_drop(powerup, origin, undefined, undefined, undefined, undefined, false );
                        }
                    }
                }
            }
			else
			{
                powerup = get_powerup_name(string_token[0]);

                if(powerup != "all")
				{
                    for ( i = 0; i < level.zombie_powerup_array.size; i++ )
                    {
                        if ( level.zombie_powerup_array[i] == powerup )
                        {
                            level.zombie_powerup_index = i;
                            found = true;
                            break;
                        }
                    } 
                }
				else
				{
                    found = true;
                }

                if ( !found )
                {
                    continue;
                }

                foreach(player in GetPlayers())
				{
                    origin = player set_position();
                    if(powerup == "all")
					{
						player spawn_all_powerups();
					}
					else
					{
                        level thread zm_powerups::specific_powerup_drop(powerup, origin, undefined, undefined, undefined, undefined, false );
                    }
                }
            }
        }
    }
}

function private set_position()
{
    direction = self GetPlayerAngles();
    direction_vec = AnglesToForward( direction );

    eye = self GetEye();
    scale = 8000;

    direction_vec = (direction_vec[0] * scale, direction_vec[1] * scale, direction_vec[2] * scale);
    trace = bullettrace( eye, eye + direction_vec, 0, undefined );

    final_pos = trace["position"];
    return final_pos;
}

function private spawn_all_powerups()
{
    level thread spawn_powerup_player("minigun", self powerup_placement(1));
    level thread spawn_powerup_player("nuke", self powerup_placement(2));
    level thread spawn_powerup_player("carpenter", self powerup_placement(3));
    level thread spawn_powerup_player("free_perk", self powerup_placement(4));
    level thread spawn_powerup_player("fire_sale", self powerup_placement(5));
    level thread spawn_powerup_player("insta_kill", self powerup_placement(6));
    level thread spawn_powerup_player("full_ammo", self powerup_placement(7));
    level thread spawn_powerup_player("double_points", self powerup_placement(8));
}

function spawn_powerup_player(str_powerup, v_origin)
{
    if(!isdefined(v_origin))
    {
        v_origin = self.origin + VectorScale(AnglesToForward((0, self getPlayerAngles()[1], 0)), 60) + VectorScale((0, 0, 1), 5);
    }
    power_up_drop = zm_powerups::specific_powerup_drop(str_powerup, v_origin);
    wait(1);

    if(isdefined(power_up_drop) && (!power_up_drop zm::in_enabled_playable_area() && !power_up_drop zm::in_life_brush()))
    {
        level thread spawn_reign(power_up_drop);
    }
}

function spawn_reign(power_up_drop)
{
    if(!isdefined(power_up_drop))
    {
        return;
    }
    power_up_drop ghost();
    power_up_drop.clone_model = util::spawn_model(power_up_drop.model, power_up_drop.origin, power_up_drop.angles);
    power_up_drop.clone_model LinkTo(power_up_drop);

    direction = power_up_drop.origin;
    direction = (direction[1], direction[0], 0);

    if(direction[1] < 0 || (direction[0] > 0 && direction[1] > 0))
    {
        direction = (direction[0], direction[1] * -1, 0);
    }
    else if(direction[0] < 0)
    {
        direction = (direction[0] * -1, direction[1], 0);
    }
    if(!(isdefined(power_up_drop.sndNoSamLaugh) && power_up_drop.sndNoSamLaugh))
    {
        players = GetPlayers();
        for(i = 0; i < players.size; i++)
        {
            if(isalive(players[i]))
            {
                players[i] playlocalsound(level.zmb_laugh_alias);
            }
        }
    }
    PlayFXOnTag(level._effect["samantha_steal"], power_up_drop, "tag_origin");

    power_up_drop.clone_model Unlink();
    power_up_drop.clone_model MoveZ(60, 1, 0.25, 0.25);
    power_up_drop.clone_model vibrate(direction, 1.5, 2.5, 1);
    power_up_drop.clone_model waittill("movedone");

    if(isdefined(self.damagearea))
    {
        self.damagearea delete();
    }
    power_up_drop.clone_model delete();
    if(isdefined(power_up_drop))
    {
        if(isdefined(power_up_drop.damagearea))
        {
            power_up_drop.damagearea delete();
        }
        power_up_drop zm_powerups::powerup_delete();
    }
}

function powerup_placement(powerup_circle)
{
    a_spawn = self.origin + VectorScale(AnglesToForward((0, self getPlayerAngles()[1], 0)), 60) + VectorScale((0, 0, 1), 5);
    v_up = VectorScale((0, 0, 1), 5);
    b_spawn = a_spawn + AnglesToForward(self.angles) * 60 + v_up;
    c_spawn = b_spawn + AnglesToForward(self.angles) * 60 + v_up;

    switch(powerup_circle)
    {
        case 1:
            v_origin = a_spawn + AnglesToRight(self.angles) * -60 + v_up;
            break;
        case 2:
            v_origin = a_spawn;
            break;
        case 3:
            v_origin = a_spawn + AnglesToRight(self.angles) * 60 + v_up;
            break;
        case 4:
            v_origin = b_spawn + AnglesToRight(self.angles) * -60 + v_up;
            break;
        case 5:
            v_origin = b_spawn;
            break;
        case 6:
            v_origin = b_spawn + AnglesToRight(self.angles) * 60 + v_up;
            break;
        case 7:
            v_origin = c_spawn + AnglesToRight(self.angles) * -60 + v_up;
            break;
        case 8:
            v_origin = c_spawn;
            break;
        case 9:
            v_origin = c_spawn + AnglesToRight(self.angles) * 60 + v_up;
            break;

        default:
            v_origin = a_spawn;
            break;
    }
    return v_origin;
}

function add_bots()
{
    ModVar("add_bots", "");
	SetDvar("bot_difficulty","3");

    for(;;)
	{
        WAIT_SERVER_FRAME;
        num_bots = (getDvarInt("add_bots", 1));
        {
            ModVar("add_bots", 0);

            for(i=0; i < num_bots; i++)
            {
                bot1 = addTestClient();
				IPrintLn("^8"+bot1.name+" ^7will join next round");
				bot1 thread bgoal();
            }
		}
    }
}

function bgoal()
{	
	level endon( "game_ended" );
	self thread bot_wander();

	while(1) 
	{
		player = thread mplayer();
		self SetMaxHealth(level.zombie_health);
		while(isDefined(player.revivetrigger) && isAlive(player)) 
		{
			self bot::revive_player(player);
			self SetMaxHealth(level.zombie_health);
			if(isDefined(player.revivetrigger) && isDefined(player.revivetrigger.beingRevived) && player.revivetrigger.beingRevived==1) 
			{
				wait(1.4);
				player zm_laststand::revive_success(self);
				player needsRevive(false);
				player AllowJump(true); 
			}
			wait(.05); 
		}
		if(isDefined(self.revivetrigger)) 
		{
			wait(5);
			self zm_laststand::revive_success(self);
			self needsRevive(false);
			self AllowJump(true); 
		}
			weap3 = self GetCurrentWeapon();
			self giveMaxAmmo(weap3);
			wait(.2); 
		}
}

function bot_wander()
{	
	level endon("game_ended");
	player = thread mplayer();
	while(1) 
	{
	if(!isdefined(player.revivetrigger)) 
	{
		self bot::stuck_resolution();
		self thread openDoors();
		wait(1);

		self BotTapButton(3);
		self bot::sprint_to_goal();

		if(isAlive(player)&&!isdefined(player.revivetrigger)) 
		{
			weap1 = player GetCurrentWeapon();
			weap = self GetCurrentWeapon();
			weapa = self GetWeaponsListPrimaries();
			if(weapa.size==2) 
			{
				self takeWeapon(weap);
				self giveWeapon(weap1);
				self switchToWeapon(weap1); 
			}
			if(weapa.size==1) 
			{
				self giveWeapon(weap1);
				self switchToWeapon(weap1);
				self giveWeapon(weap);
				self giveWeapon(getWeapon("bowie_knife")); 
			}
		}
			wait(2.5);
			self BotTapButton(3);
			self bot::sprint_to_goal();
			wait(2.5);
			self BotTapButton(3);
			self bot::sprint_to_goal(); 
		}
		wait(1.5); 
	}
}

function openDoors()
{	
	level endon("game_ended");
	doors1 = getEntArray("zombie_door","targetname");
	doors2 = getEntArray("zombie_debris","targetname");
	doors3 = getEntArray("zombie_airlock_buy","targetname");
	doors4 = arrayCombine(doors1,doors2,true,true);
	targets = arrayCombine(doors3,doors4,true,true);
	for(i=0;i<targets.size;i++) 
	{
		if(targets[i]._door_open==true || targets[i].script_noteworthy=="electric_buyable_door" || targets[i].script_noteworthy=="local_electric_door" || targets[i].script_noteworthy=="electric_door")
		ArrayRemoveIndex(targets,i,true); 
	}

	nearDoor = arrayGetClosest(self.origin+(0,0,60),targets);
	while(isDefined(nearDoor) && nearDoor.zombie_cost <= self.score && nearDoor._door_open!=true) 
	{
		self bot::approach_goal_trigger(nearDoor);

		if(!zm_utility::check_point_in_enabled_zone(self BotGetGoalPosition()) || !TracePassedOnNavMesh(self.origin,self BotGetGoalPosition(),17)) 
		{
			wait(.05); continue; 
		}

		trigGoal = self BotGetGoalPosition();
		wait(.05); 
		break; 
	}

	while(trigGoal == self BotGetGoalPosition()) 
	{
		if(self istouching(nearDoor)) 
		{
			self BotTapButton(3);
			IPrintLnBold("^3"+self.name+" ^7opened a door."); 
			break; 
		}
	wait(.05); 
	}

	if(nearDoor.zombie_cost > self.score || !isDefined(nearDoor) || nearDoor._door_open==true || trigGoal!=self BotGetGoalPosition()) 
	{
		self bot::navmesh_wander(); 
	}
}

function mplayer()
{	
		level endon( "game_ended" );
		mhost = 0;
		playersall = GetPlayers();
		foreach(player in playersall) 
		{
			if(player isHost()) 
		{

	mhost = player;
	}
		return mhost; 
	}
}


function perk_name(perk_value)
{

    if(!isdefined(perk_value))
        return;

    switch(perk_value)
	{
        case "specialty_armorvest":
        case "juggernog":
        case "jugg":
            return "specialty_armorvest";

        case "specialty_quickrevive":
        case "revive":
        case "quickrevive":
            return "specialty_quickrevive";

        case "specialty_fastreload":
        case "fastreload":
        case "reload":
        case "speedcola":
        case "speed":
            return "specialty_fastreload";

        case "specialty_doubletap2":
        case "doubletap":
        case "fastfire":
            return "specialty_doubletap2";

        case "specialty_staminup":
        case "staminup":
        case "marathon":
            return "specialty_staminup";

        case "specialty_phdflopper":
        case "phdflopper":
        case "phd":
        case "flopper":
            return "specialty_phdflopper";

        case "specialty_deadshot":
        case "deadshot":
        case "ads":
        case "daiquiri":
            return "specialty_deadshot";

        case "specialty_additionalprimaryweapon":
        case "additionalprimaryweapon":
        case "mulekick":
        case "mule":
            return "specialty_additionalprimaryweapon";

        case "specialty_electriccherry":
        case "electriccherry":
        case "electric_cherry":
        case "electric":
        case "cherry":
            return "specialty_electriccherry";

        case "specialty_tombstone":
        case "tombstone":
        case "tomb":
            return "specialty_tombstone";

        case "specialty_whoswho":
        case "whoswho":
        case "whos_who":
        case "whos":
            return "specialty_whoswho";

        case "specialty_vultureaid":
        case "vultureaid":
        case "vulture":
        case "aid":
            return "specialty_vultureaid";

        case "specialty_widowswine":
        case "widowswine":
        case "widows":
        case "wine":
            return "specialty_widowswine";

        case "specialty_flakjacket":
        case "moonshine":
        case "moon":
        case "shine":
        case "madgaz_moonshine":
            return "specialty_flakjacket";

        case "specialty_flashprotection":
        case "crusader":
        case "crusader_ale":
        case "ale":
        case "madgaz_crusader":
            return "specialty_flashprotection";

        case "specialty_proximityprotection":
        case "bull_ice_blast":
        case "iceblast":
        case "ice_blast":
        case "bull_ice":
        case "bullice":
        case "madgaz_bull":
        case "bull":
        case "bullsiceblast":
        case "bulliceblast":
            return "specialty_proximityprotection";

        case "specialty_immunecounteruav":
        case "bananacolada":
        case "banana":
        case "colada":
        case "banana_colada":
        case "madgaz_banana":
            return "specialty_immunecounteruav";

        case "specialty_directionalfire":
        case "vigorrush":
        case "vigor":
        case "rush":
        case "vigor_rush":
            return "specialty_directionalfire";

        case "madgaz":
            return "specialty_immunecounteruav specialty_proximityprotection specialty_flashprotection specialty_flakjacket ;";

        case "classic":
            return "specialty_armorvest specialty_fastreload specialty_doubletap2 specialty_quickrevive ;";

        default:
            return perk_value;
    }
}

function get_powerup_name(powerup_value)
{
    if(!isdefined(powerup_value))
        return;

    switch(powerup_value)
	{
        case "full_ammo":
        case "max_ammo":
        case "maxammo":
        case "max":
        case "ammo":
            return "full_ammo";

        case "nuke":
        case "boom":
            return "nuke";

		case "code_cylinder_blue":
			return "code_cylinder_blue";

		case "code_cylinder_red":
			return "code_cylinder_red";

		case "code_cylinder_yellow":
			return "code_cylinder_yellow";

        case "insta_kill":
        case "instakill":
        case "insta":
        case "kill":
            return "insta_kill";

        case "double_points":
        case "doublepoints":
        case "dpoints":
        case "double":
            return "double_points";

        case "carpenter":
            return "carpenter";

        case "fire_sale":
        case "firesale":
        case "fire":
        case "sale":
            return "fire_sale";

        case "bonfire_sale":
        case "bonfire":
        case "bonfiresale":
            return "bonfire_sale";

        case "minigun":
            return "minigun";

        case "free_perk":
        case "freeperk":
        case "perk":
            return "free_perk";

        case "tesla":
            return "tesla";

        case "random_weapon":
        case "randomweapon":
        case "weapon":
            return "random_weapon";

        case "bonus_points_player":
        case "playerpoints":
        case "points_player":
        case "bonus_player":
        case "money_player":
            return "bonus_points_player";

        case "bonus_points_team":
        case "teampoints":
        case "points_team":
        case "bonus_team":
        case "money_team":
        case "points":
            return "bonus_points_team";

        case "lose_points_team":
        case "losepointsteam":
        case "teamlose":
        case "team_lose":
            return "lose_points_team";

        case "lose_perk":
        case "loseperk":
            return "lose_perk";

        case "empty_clip":
        case "emptyclip":
            return "empty_clip";

        case "zombie_blood":
        case "blood":
        case "zombie":
        case "zombieblood":
            return "zombie_blood";

        case "ww_grenade":
        case "ww":
        case "wwgrenade":
        case "widows":
        case "widowswine":
        case "widowswinegrenade":
            return "ww_grenade";

        case "shield_charge":
        case "shieldcharge":
        case "shield":
        case "charge":
            return "shield_charge";

        case "perk_slot":
        case "perkslot":
        case "slot":
            return "perk_slot";

        case "full_power":
        case "fullpower":
        case "power":
            return "full_power";

        case "blood_money":
        case "blood_points":
        case "bloodpoints":
        case "bloodmoney":
            return "blood_money";

        case "bottomless_clip":
        case "clip":
        case "bottomless":
        case "bottomlessclip":
        case "infiniteammo":
        case "infinite":
            return "bottomless_clip";

        case "fast_feet":
        case "fastfeet":
        case "feet":
        case "fast":
            return "fast_feet";

        default:
            return powerup_value;
    }
}

