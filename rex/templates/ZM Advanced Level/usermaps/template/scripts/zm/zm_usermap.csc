#using scripts\codescripts\struct;
#using scripts\shared\audio_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;


#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_load;
#using scripts\zm\_zm_weapons;

//Perks
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_pack_a_punch;
#using scripts\zm\_zm_perk_additionalprimaryweapon;
#using scripts\zm\_zm_perk_doubletap2;
#using scripts\zm\_zm_perk_deadshot;
#using scripts\zm\_zm_perk_juggernaut;
#using scripts\zm\_zm_perk_quick_revive;
#using scripts\zm\_zm_perk_sleight_of_hand;
#using scripts\zm\_zm_perk_staminup;
#using scripts\zm\_zm_perk_electric_cherry;
#using scripts\zm\_zm_perk_widows_wine;
#using scripts\zm\_zm_perk_random;

//Powerups
#using scripts\zm\_zm_powerup_double_points;
#using scripts\zm\_zm_powerup_carpenter;
#using scripts\zm\_zm_powerup_fire_sale;
#using scripts\zm\_zm_powerup_free_perk;
#using scripts\zm\_zm_powerup_full_ammo;
#using scripts\zm\_zm_powerup_insta_kill;
#using scripts\zm\_zm_powerup_nuke;
#using scripts\zm\_zm_powerup_weapon_minigun;
#using scripts\zm\_zm_powerup_zombie_blood;

//Traps
#using scripts\zm\_zm_trap_electric;

//Water
#using scripts\zm\_zm_water;

//Portals
#using scripts\zm\_zm_portals;

//Teleporter
#using scripts\zm\_zm_teleporter;

//Vehicle Tank
#using scripts\zm\_zm_tank;

//Minecart
#using scripts\zm\_zm_minecart;

//Flingers
#using scripts\zm\_zm_flingers;

//Weather
#using scripts\zm\_zm_weather;

//Wearables
#using scripts\zm\_zm_wearables;

//Low Gravity
#using scripts\zm\_zm_low_grav;

//Soul Box
#using scripts\zm\_zm_soul_box;
#using scripts\zm\zm_challenges_template;

//Magic Box
#using scripts\zm\_zm_custom_magicbox;

//Moon Gravity
#using scripts\zm\zm_moon_gravity;

//Shields
//#using scripts\zm\_zm_weap_dragon_shield;
//#using scripts\zm\_zm_weap_island_shield;

//Audio
#using scripts\zm\template_audio;

// Weapons
#using scripts\zm\_zm_weap_bouncingbetty;
#using scripts\zm\_zm_weap_cymbal_monkey;
#using scripts\zm\_zm_weap_tesla;
#using scripts\zm\_zm_weap_rocketshield;
#using scripts\zm\_zm_weap_gravityspikes;
#using scripts\zm\_zm_weap_thundergun;
#using scripts\zm\_zm_weap_octobomb;
//#using scripts\zm\_zm_weap_raygun_mark3;

#using scripts\zm\_zm_weap_idgun;
//6#using scripts\zm\_zm_weap_elemental_bow;
//#using scripts\zm\_zm_weap_elemental_bow_demongate;
//#using scripts\zm\_zm_weap_elemental_bow_rune_prison;
//#using scripts\zm\_zm_weap_elemental_bow_storm;
//#using scripts\zm\_zm_weap_elemental_bow_wolf_howl;
//#using scripts\zm\_zm_weap_staff_air;
//#using scripts\zm\_zm_weap_staff_fire;
//#using scripts\zm\_zm_weap_staff_lightning;
//#using scripts\zm\_zm_weap_staff_water;
//#using scripts\zm\_zm_weap_mirg2000;
//#using scripts\zm\_zm_weap_shrink_ray;
//#using scripts\zm\_zm_weap_microwavegun;
#using scripts\zm\_zm_weap_black_hole_bomb;
#using scripts\zm\_zm_weap_quantum_bomb;
//#using scripts\zm\_zm_weap_beacon;
//#using scripts\zm\_zm_weap_dragon_strike;

//Specialist Weapons
//#using scripts\zm\_zm_weap_glaive;
//#using scripts\shared\vehicles\_glaive;
//#using scripts\zm\_zm_weap_dragon_gauntlet;
//#using scripts\zm\_zm_weap_keeper_skull;

#using scripts\zm\_zm_weap_one_inch_punch;
#using scripts\zm\_zm_equip_hacker;
#using scripts\zm\_zm_equip_gasmask;
//#using scripts\zm\_zm_weap_plunger;
//#using scripts\zm\_zm_weap_ball;

// AI
#using scripts\shared\ai\mechz;
#using scripts\zm\template_mechz;
#using scripts\zm\_zm_ai_mechz;
//#using scripts\zm\zm_genesis_margwa;
#using scripts\zm\_zm_ai_wasp;
#using scripts\zm\_zm_ai_raps;
#using scripts\zm\_zm_ai_spiders;
#using scripts\zm\_zm_ai_keeper;
#using scripts\zm\_zm_ai_monkey;
#using scripts\zm\_zm_temple_ai_monkey;
//#using scripts\zm\_zm_ai_napalm;
//#using scripts\zm\_zm_ai_sonic;
//#using scripts\zm\_zm_ai_apothicon_fury;
//#using scripts\zm\_zm_ai_quad;
//#using scripts\zm\_zm_ai_astro;
//#using scripts\zm\_zm_ai_thrasher;
//#using scripts\shared\ai\raz;
//#using scripts\zm\_zm_ai_raz;
//#using scripts\shared\vehicles\_sentinel_drone;
//#using scripts\zm\_zm_ai_sentinel_drone;
#using scripts\zm\_zm_ai_dogs;

#namespace zm_usermap; 

#precache( "client_fx", "zombie/fx_glow_eye_orange" );
#precache( "client_fx", "zombie/fx_bul_flesh_head_fatal_zmb" );
#precache( "client_fx", "zombie/fx_bul_flesh_head_nochunks_zmb" );
#precache( "client_fx", "zombie/fx_bul_flesh_neck_spurt_zmb" );
#precache( "client_fx", "zombie/fx_blood_torso_explo_zmb" );
#precache( "client_fx", "trail/fx_trail_blood_streak" );
#precache( "client_fx", "dlc0/factory/fx_snow_player_os_factory" );

#precache( "client_fx", "zombie/fx_perk_juggernaut_factory_zmb" );
#precache( "client_fx", "zombie/fx_perk_quick_revive_factory_zmb" );
#precache( "client_fx", "zombie/fx_perk_sleight_of_hand_factory_zmb" );
#precache( "client_fx", "zombie/fx_perk_doubletap2_factory_zmb" );
#precache( "client_fx", "zombie/fx_perk_daiquiri_factory_zmb" );
#precache( "client_fx", "zombie/fx_perk_stamin_up_factory_zmb" );
#precache( "client_fx", "zombie/fx_perk_mule_kick_factory_zmb" );
#precache( "client_fx", "dlc5/zmhd/fx_perk_widows_wine" );

#define JUGGERNAUT_MACHINE_LIGHT_FX                "jugger_light"        
#define QUICK_REVIVE_MACHINE_LIGHT_FX              "revive_light"    
#define SLEIGHT_OF_HAND_MACHINE_LIGHT_FX           "sleight_light"    
#define DOUBLETAP2_MACHINE_LIGHT_FX                "doubletap2_light"    
#define DEADSHOT_MACHINE_LIGHT_FX                  "deadshot_light"    
#define STAMINUP_MACHINE_LIGHT_FX                  "marathon_light"    
#define ADDITIONAL_PRIMARY_WEAPON_MACHINE_LIGHT_FX "additionalprimaryweapon_light"
#define ELECTRIC_CHERRY_MACHINE_LIGHT_FX           "electric_cherry_light"
#define WIDOWS_WINE_FX_MACHINE_LIGHT               "widow_light"

function autoexec opt_in()
{
	DEFAULT(level.aat_in_use,true);
	DEFAULT(level.bgb_in_use,true);
}

function main()
{
	clientfield::register( "clientuimodel", "zmInventory.widget_shield_parts", VERSION_SHIP, 1, "int", undefined, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	
	// custom client side exert sounds for the special characters
	level.setupCustomCharacterExerts =&setup_personality_character_exerts;
	
	level._effect["eye_glow"]				= "zombie/fx_glow_eye_orange";
	level._effect["headshot"]				= "zombie/fx_bul_flesh_head_fatal_zmb";
	level._effect["headshot_nochunks"]		= "zombie/fx_bul_flesh_head_nochunks_zmb";
	level._effect["bloodspurt"]				= "zombie/fx_bul_flesh_neck_spurt_zmb";

	level._effect["animscript_gib_fx"]		= "zombie/fx_blood_torso_explo_zmb"; 
	level._effect["animscript_gibtrail_fx"]	= "trail/fx_trail_blood_streak"; 

	//If enabled then the zombies will get a keyline round them so we can see them through walls
	level.debug_keyline_zombies = false;

	include_weapons();
	include_perks();

	zm_low_grav::main();

	zm_minecart::main();

	zm_tank::init();

	zm_teleporter::main();

	zm_wearables::function_ad78a144();

	zm_weap_one_inch_punch::init();

	template_audio::init();

	load::main();

	zm_moon_gravity::init();
	
	_zm_weap_cymbal_monkey::init();
	_zm_weap_tesla::init();
	
}

function include_weapons()
{
	zm_weapons::load_weapon_spec_from_table("gamedata/weapons/zm/template.csv", 1);
}

function include_perks()
{
	level._effect[JUGGERNAUT_MACHINE_LIGHT_FX] = 					"zombie/fx_perk_juggernaut_factory_zmb";
	level._effect[QUICK_REVIVE_MACHINE_LIGHT_FX] = 					"zombie/fx_perk_quick_revive_factory_zmb";
	level._effect[SLEIGHT_OF_HAND_MACHINE_LIGHT_FX] = 				"zombie/fx_perk_sleight_of_hand_factory_zmb";
	level._effect[DOUBLETAP2_MACHINE_LIGHT_FX] = 					"zombie/fx_perk_doubletap2_factory_zmb";	
	level._effect[DEADSHOT_MACHINE_LIGHT_FX] = 						"zombie/fx_perk_daiquiri_factory_zmb";
	level._effect[STAMINUP_MACHINE_LIGHT_FX] = 						"zombie/fx_perk_stamin_up_factory_zmb";
	level._effect[ADDITIONAL_PRIMARY_WEAPON_MACHINE_LIGHT_FX] = 	"zombie/fx_perk_mule_kick_factory_zmb";
	level._effect[WIDOWS_WINE_FX_MACHINE_LIGHT] = 					"dlc5/zmhd/fx_perk_widows_wine";
	level._effect[ELECTRIC_CHERRY_MACHINE_LIGHT_FX] = 				"zombie/fx_perk_quick_revive_factory_zmb";
}

function setup_personality_character_exerts()
{
	// falling damage
	level.exert_sounds[1]["falldamage"][0] = "vox_plr_0_exert_pain_0";
	level.exert_sounds[1]["falldamage"][1] = "vox_plr_0_exert_pain_1";
	level.exert_sounds[1]["falldamage"][2] = "vox_plr_0_exert_pain_2";
	level.exert_sounds[1]["falldamage"][3] = "vox_plr_0_exert_pain_3";
	level.exert_sounds[1]["falldamage"][4] = "vox_plr_0_exert_pain_4";
	
	level.exert_sounds[2]["falldamage"][0] = "vox_plr_1_exert_pain_0";
	level.exert_sounds[2]["falldamage"][1] = "vox_plr_1_exert_pain_1";
	level.exert_sounds[2]["falldamage"][2] = "vox_plr_1_exert_pain_2";
	level.exert_sounds[2]["falldamage"][3] = "vox_plr_1_exert_pain_3";
	level.exert_sounds[2]["falldamage"][4] = "vox_plr_1_exert_pain_4";
	
	level.exert_sounds[3]["falldamage"][0] = "vox_plr_2_exert_pain_0";
	level.exert_sounds[3]["falldamage"][1] = "vox_plr_2_exert_pain_1";
	level.exert_sounds[3]["falldamage"][2] = "vox_plr_2_exert_pain_2";
	level.exert_sounds[3]["falldamage"][3] = "vox_plr_2_exert_pain_3";
	level.exert_sounds[3]["falldamage"][4] = "vox_plr_2_exert_pain_4";
	
	level.exert_sounds[4]["falldamage"][0] = "vox_plr_3_exert_pain_0";
	level.exert_sounds[4]["falldamage"][1] = "vox_plr_3_exert_pain_1";
	level.exert_sounds[4]["falldamage"][2] = "vox_plr_3_exert_pain_2";
	level.exert_sounds[4]["falldamage"][3] = "vox_plr_3_exert_pain_3";
	level.exert_sounds[4]["falldamage"][4] = "vox_plr_3_exert_pain_4";
	
	// melee swipe
	level.exert_sounds[1]["meleeswipesoundplayer"][0] = "vox_plr_0_exert_melee_0";
	level.exert_sounds[1]["meleeswipesoundplayer"][1] = "vox_plr_0_exert_melee_1";
	level.exert_sounds[1]["meleeswipesoundplayer"][2] = "vox_plr_0_exert_melee_2";
	level.exert_sounds[1]["meleeswipesoundplayer"][3] = "vox_plr_0_exert_melee_3";
	level.exert_sounds[1]["meleeswipesoundplayer"][4] = "vox_plr_0_exert_melee_4";
	
	level.exert_sounds[2]["meleeswipesoundplayer"][0] = "vox_plr_1_exert_melee_0";
	level.exert_sounds[2]["meleeswipesoundplayer"][1] = "vox_plr_1_exert_melee_1";
	level.exert_sounds[2]["meleeswipesoundplayer"][2] = "vox_plr_1_exert_melee_2";
	level.exert_sounds[2]["meleeswipesoundplayer"][3] = "vox_plr_1_exert_melee_3";
	level.exert_sounds[2]["meleeswipesoundplayer"][4] = "vox_plr_1_exert_melee_4";
	
	level.exert_sounds[3]["meleeswipesoundplayer"][0] = "vox_plr_2_exert_melee_0";
	level.exert_sounds[3]["meleeswipesoundplayer"][1] = "vox_plr_2_exert_melee_1";
	level.exert_sounds[3]["meleeswipesoundplayer"][2] = "vox_plr_2_exert_melee_2";
	level.exert_sounds[3]["meleeswipesoundplayer"][3] = "vox_plr_2_exert_melee_3";
	level.exert_sounds[3]["meleeswipesoundplayer"][4] = "vox_plr_2_exert_melee_4";	
	
	level.exert_sounds[4]["meleeswipesoundplayer"][0] = "vox_plr_3_exert_melee_0";
	level.exert_sounds[4]["meleeswipesoundplayer"][1] = "vox_plr_3_exert_melee_1";
	level.exert_sounds[4]["meleeswipesoundplayer"][2] = "vox_plr_3_exert_melee_2";
	level.exert_sounds[4]["meleeswipesoundplayer"][3] = "vox_plr_3_exert_melee_3";
	level.exert_sounds[4]["meleeswipesoundplayer"][4] = "vox_plr_3_exert_melee_4";	
}
