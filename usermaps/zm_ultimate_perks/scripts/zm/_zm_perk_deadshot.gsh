// SETTINGS
// ======================================================================================================
#define DEADSHOT_VERSION															"3.1.0"
#define DEADSHOT_LEVEL_USE_PERK												1
#define DEADSHOT_PERK_COST													1500
#define DEADSHOT_PERK_COST_STRING										"1500"
#define DEADSHOT_RADIANT_MACHINE_NAME								"vending_deadshot"	
#define DEADSHOT_ALIAS																"deadshot"
#define DEADSHOT_SCRIPT_STRING												"deadshot_perk"
#define DEADSHOT_JINGLE															"mus_perks_deadshot_jingle"
#define DEADSHOT_STING																"mus_perks_deadshot_sting"
#define DEADSHOT_PERK																"specialty_deadshot"
#define DEADSHOT_CLIENTFIELD													"hudItems.perks.dead_shot"
#define DEADSHOT_UI_GLOW_CLIENTFIELD									"dead_shot_ui_glow"
#define DEADSHOT_IN_WONDERFIZZ												1

#define DEADSHOT_SHOW_UI_GLOW_ON_HEADSHOTS					1
#define DEADSHOT_SHOW_UI_GLOW_DURATION							.25
#define DEADSHOT_INCREASED_HEAD_DAMAGE								1
#define DEADSHOT_HEAD_DAMAGE_MULTIPLIER								1.3
#define DEADSHOT_KILL_AWARDS_BONUS_POINTS						1
#define DEADSHOT_HEADSHOT_KILL_BONUS_POINTS						40

#define DEADSHOT_USE_SECONDARY_PERKS									1
#define DEADSHOT_HIPFIRE_SPREAD_MULTIPLIER							.4225
#define DEADSHOT_SECONDARY_PERKS										array( "specialty_fastads", "specialty_stalker", "specialty_bulletaccuracy" )
#define DEADSHOT_SECONDARY_PERK_CONFLICT_BGBS				"zm_bgb_always_done_swiftly"

// WEAPON FILES
// ======================================================================================================
#define DEADSHOT_PERK_BOTTLE_WEAPON									"zombie_perk_bottle_deadshot"

// MODELS
// ======================================================================================================
#define DEADSHOT_MACHINE_DISABLED_MODEL							"p9_sur_vending_ads_off"
#define DEADSHOT_MACHINE_ACTIVE_MODEL								"p9_sur_vending_ads"

// FX
// ======================================================================================================
#define DEADSHOT_MACHINE_LIGHT_FX											"harry/zm_perks/fx_perk_daiquiri_light"		
#define DEADSHOT_VULTUREAID_WAYPOINT									"harry/vulture_aid/fx_vulture_aid_waypoint_deadshot_daiquiri"