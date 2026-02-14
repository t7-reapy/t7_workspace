void AddGadgetFields( asset Asset )
{
	Asset.BeginCategory( "Gadget" );
	{
		Asset.AddEntry_Combo( "gadget_type", "none | other | optic_camo | juke | shield | grenade | armor | drone | pulse_vision | multirocket | deployed_turret | hacker | infrared | speed_burst | hero_weapon | combat_efficiency | flashback | cleanse | system_overload | servo_shortout | exo_breakdown | surge | ravage_core | remote_hijack | iff_override | takedown | forced_malfunction | concussive_wave | overdrive | unstoppable_force | rapid_strike | sensory_overload | es_strike | immolation | firefly_swarm | smokescreen | misdirection | cacophony | active_camo | shock_field | resurrect | heat_wave | clone | roulette | thief" ).SetTitle( "Gadget Type" ).SetToolTip( "The gadget type is used to differentiate betweeen gadgets and to make the script callbacks to the correct scripts." );
		Asset.AddEntry_Combo( "activate_mode", "hold | toggle | single | toggle_attack | toggle_hold | single_stay_on | auto | prime_on_hold_activate_on_release | prime_on_hold_activate_on_release_stay_on" ).SetTitle( "Activate Mode" ).SetToolTip( "The activate mode is used to select the different button presses required to turn the gadget on and off." );
		Asset.AddEntry_Combo( "weapon_hold_mode", "wield | offhand | throw | hands_free" ).SetTitle( "Weapon Hold Mode" ).SetToolTip( "The weapon hold mode is used to switch and raise the gadget. Wield means the weapon is out while the gadget is on; Offhand means there is a raise and drop to activate; Hands Free just turns the gadget on without any weapon motion." );
		Asset.AddEntry_Combo( "power_use_type", "ammo | cooldown | powerbar" ).SetTitle( "Power Use Type" ).SetToolTip( "The power use type: power is translated into ammo, and ammo is calculated as powermax/treshhold; cooldown means its powerbased and that there is no powerbar; powerbar means its power based and that a powerbar is shown." );		
		Asset.AddEntry_Int( "activate_with_primed_delay", 0, 0, 10000 ).SetTitle( "Active With Primed Delay" ).SetToolTip( "The time in seconds betweeen pressing the button to activate and the actual gadget activation." );		
		Asset.AddEntry_CheckBox( "heroVersion_2_0", false ).SetTitle( "Hero Weapon Version 2.0" ).SetToolTip( "" );
		Asset.AddEntry_Int( "gadget_max_hitpoints", 100, 0, 100 ).SetTitle( "HitPoints_Max" ).SetToolTip( "The max damage it can take before it deactivates" );
	}
	Asset.BeginCategory( "Gadget Power" );
	{
		Asset.AddEntry_CheckBox( "power_init_empty", false ).SetTitle( "power_init_empty" ).SetToolTip( "The power_init_empty property" );
		Asset.AddEntry_CheckBox( "power_reset_on_death_if_active", false ).SetTitle( "power_reset_on_death_if_active" ).SetToolTip( "The power_reset_on_death_if_active property" );		
		Asset.AddEntry_CheckBox( "power_reset_on_class_change", false ).SetTitle( "power_reset_on_class_change" ).SetToolTip( "The power_reset_on_class_change property" );
		Asset.AddEntry_CheckBox( "power_reset_on_spawn", false ).SetTitle( "power_reset_on_spawn" ).SetToolTip( "The power_reset_on_spawn property" );
		Asset.AddEntry_CheckBox( "power_reset_on_team_change", false ).SetTitle( "power_reset_on_team_change" ).SetToolTip( "The power_reset_on_team_change property" );
		Asset.AddEntry_CheckBox( "power_reset_on_round_switch", false ).SetTitle( "power_reset_on_round_switch" ).SetToolTip( "The power_reset_on_round_switch property" );		
		Asset.AddEntry_CheckBox( "power_gain_score_ignore_self", false ).SetTitle( "power_gain_score_ignore_self" ).SetToolTip( "The power_gain_score_ignore_self property" );
		Asset.AddEntry_CheckBox( "power_gain_score_ignore_when_active", false ).SetTitle( "power_gain_score_ignore_when_active" ).SetToolTip( "The power_gain_score_ignore_when_active property" );
		Asset.AddEntry_CheckBox( "power_recharge_disable_on_emp", false ).SetTitle( "power_recharge_disable_on_emp" ).SetToolTip( "Recharging disabled when emp jammed." );
		Asset.AddEntry_CheckBox( "power_consume_on_ammo_use", false ).SetTitle( "Power Consume on Ammo Use" ).SetToolTip( "Power is consumed when fired and ammo is used." );

		Asset.AddEntry_Int( "power_power_bonus", 0, 0, 100 ).SetTitle( "power_power_bonus" ).SetToolTip( "The power_power_bonus property" );
		Asset.AddEntry_Float( "power_usage_rate", 10, 0, 500 ).SetTitle( "power_usage_rate" ).SetToolTip( "The power_usage_rate property" );
		Asset.AddEntry_Float( "power_recharge_rate", 10, 0, 100 ).SetTitle( "power_recharge_rate" ).SetToolTip( "The power_recharge_rate property" );
		Asset.AddEntry_Int( "power_usable_threshold", 1, 0, 100 ).SetTitle( "power_usable_threshold" ).SetToolTip( "The power_usable_threshold property" );
		Asset.AddEntry_Float( "power_replenish_factor", 0, 0, 1 ).SetTitle( "power_replenish_factor" ).SetToolTip( "The power_replenish_factor property" );		
		Asset.AddEntry_Int( "power_attack_loss", 0, 0, 100 ).SetTitle( "power_attack_loss" ).SetToolTip( "The power_attack_loss property" );
		Asset.AddEntry_Float( "power_damage_factor", 0, 0, 10 ).SetTitle( "power_damage_factor" ).SetToolTip( "The power_damage_factor property" );
		Asset.AddEntry_Float( "power_flicker_chance", 0.11, 0, 1 ).SetTitle( "power_flicker_chance" ).SetToolTip( "The power_flicker_chance property" );
		Asset.AddEntry_Int( "power_flicker_frequency", 1000, 0, 10000 ).SetTitle( "power_flicker_frequency" ).SetToolTip( "The power_flicker_frequency property" );
		Asset.AddEntry_Int( "power_flicker_threshold", 40, 0, 100 ).SetTitle( "power_flicker_threshold" ).SetToolTip( "The power_flicker_threshold property" );
		Asset.AddEntry_Float( "power_gain_score_factor", 0, 0, 10 ).SetTitle( "power_gain_score_factor" ).SetToolTip( "The power_gain_score_factor property" );

		Asset.AddEntry_Int( "power_juke_loss", 0, 0, 100 ).SetTitle( "power_juke_loss" ).SetToolTip( "The power_juke_loss property" );
		Asset.AddEntry_Int( "power_jump_loss", 0, 0, 100 ).SetTitle( "power_jump_loss" ).SetToolTip( "The power_jump_loss property" );
		Asset.AddEntry_Int( "power_melee_loss", 0, 0, 100 ).SetTitle( "power_melee_loss" ).SetToolTip( "The power_melee_loss property" );
		Asset.AddEntry_Int( "power_move_loss", 0, 0, 100 ).SetTitle( "power_move_loss" ).SetToolTip( "The power_move_loss property" );
		Asset.AddEntry_Int( "power_move_loss_speed", 0, 0, 500 ).SetTitle( "power_move_loss_speed" ).SetToolTip( "The power_move_loss_speed property" );
		Asset.AddEntry_Float( "power_on_damage_factor", 0, 0, 10 ).SetTitle( "power_on_damage_factor" ).SetToolTip( "The power_on_damage_factor property" );		
		Asset.AddEntry_Int( "power_recharge_delay", 1000, 0, 10000 ).SetTitle( "power_recharge_delay" ).SetToolTip( "The power_recharge_delay property" );
		Asset.AddEntry_Int( "power_recharge_delay_max", 1000, 0, 10000 ).SetTitle( "power_recharge_delay_max" ).SetToolTip( "The power_recharge_delay_max property" );
		Asset.AddEntry_Int( "power_sprint_loss", 0, 0, 100 ).SetTitle( "power_sprint_loss" ).SetToolTip( "The power_sprint_loss property" );
		Asset.AddEntry_Int( "power_round_end_active_penalty", 0, 0, 100 ).SetTitle( "power_round_end_active_penalty" ).SetToolTip( "The power_round_end_active_penalty property" );
		Asset.AddEntry_Int( "power_shut_off_on_death_penalty", 0, 0, 100 ).SetTitle( "power_shut_off_on_death_penalty" ).SetToolTip( "The power_shut_off_on_death_penalty property" );
		Asset.AddEntry_Int( "power_shut_off_penalty", 0, 0, 100 ).SetTitle( "power_shut_off_penalty" ).SetToolTip( "The penalty for shutting off the gadget" );
		Asset.AddEntry_Int( "power_turn_off_penalty", 0, 0, 100 ).SetTitle( "power_turn_off_penalty" ).SetToolTip( "The power_turn_off_penalty property" );	
		Asset.AddEntry_Int( "flicker_on_damage", 0, 0, 10000 ).SetTitle( "flicker_on_damage" ).SetToolTip( "The flicker_on_damage property" );
		Asset.AddEntry_Int( "flicker_on_power_loss", 0, 0, 10000 ).SetTitle( "flicker_on_power_loss" ).SetToolTip( "The flicker_on_power_loss property" );
		Asset.AddEntry_Int( "flicker_on_power_low", 0, 0, 10000 ).SetTitle( "flicker_on_power_low" ).SetToolTip( "The flicker_on_power_low property" );
		Asset.AddEntry_Int( "flicker_on_whizby", 0, 0, 10000 ).SetTitle( "flicker_on_whizby" ).SetToolTip( "The flicker_on_whizby property" );
	}
	Asset.BeginCategory( "Gadget Movement Multipliers" );
	{
		Asset.AddEntry_Float( "movementMultiplierStrafe", 1, 1, 5 ).SetTitle( "movementMultiplierStrafe" ).SetToolTip( "The movement multiplier property for strafe" );
		Asset.AddEntry_Float( "movementMultiplierWalk", 1, 1, 5 ).SetTitle( "movementMultiplierADSWalk" ).SetToolTip( "The movement multiplier property for ads walk" );
		Asset.AddEntry_Float( "movementMultiplierRun", 1, 1, 5 ).SetTitle( "movementMultiplierNonADS" ).SetToolTip( "The movement multiplier property for non ads movement" );
		Asset.AddEntry_Float( "movementMultiplierSprint", 1, 1, 5 ).SetTitle( "movementMultiplierSprint" ).SetToolTip( "The movement multiplier property for sprint" );
		Asset.AddEntry_Float( "movementMultiplierProne", 1, 1, 5 ).SetTitle( "movementMultiplierProne" ).SetToolTip( "The movement multiplier property for prone" );
		Asset.AddEntry_Float( "movementMultiplierCrouch", 1, 1, 5 ).SetTitle( "movementMultiplierCrouch" ).SetToolTip( "The movement multiplier property for crouch" );
		Asset.AddEntry_Float( "movementMultiplierSlide", 1, 1, 5 ).SetTitle( "movementMultiplierSlide" ).SetToolTip( "The movement multiplier property for slide" );
		Asset.AddEntry_Float( "movementMultiplierWallrun", 1, 1, 5 ).SetTitle( "movementMultiplierWallrun" ).SetToolTip( "The movement multiplier property for wallrun" );
		Asset.AddEntry_Float( "movementMultiplierDoubleJump", 1, 1, 5 ).SetTitle( "movementMultiplierDoubleJump" ).SetToolTip( "The movement multiplier property for double jump" );
		Asset.AddEntry_Float( "movementMultiplierJump", 1, 1, 5 ).SetTitle( "movementMultiplierJump" ).SetToolTip( "The movement multiplier property for jump" );
		Asset.AddEntry_Float( "movementMultiplierLeap", 1, 1, 5 ).SetTitle( "movementMultiplierLeap" ).SetToolTip( "The movement multiplier property for leap" );
		Asset.AddEntry_Float( "movementMultiplierSprintBob", 1, .001, 1 ).SetTitle( "movementMultiplierSprintBob" ).SetToolTip( "The movement multiplier property for the bob when sprinting" );
		Asset.AddEntry_Float( "movementMultiplierNonSprintBob", 1, .001, 1 ).SetTitle( "movementMultiplierNonSprintBob" ).SetToolTip( "The movement multiplier property for the bob when not sprinting" );
		Asset.AddEntry_Float( "movementMultiplierSwim", 1, 1, 5 ).SetTitle( "movementMultiplierSwim" ).SetToolTip( "The movement multiplier property for swim" );
	}
	Asset.BeginCategory( "Gadget Sounds" );
	{
		Asset.AddEntry_String( "gadgetLoopSound", "" ).SetTitle( "Gadget Loop" ).SetToolTip( "Gadget loop sound" );
		Asset.AddEntry_String( "gadgetAltLoopSound", "" ).SetTitle( "Gadget Alt Loop" ).SetToolTip( "Gadget alt loop sound" );
		Asset.AddEntry_String( "gadgetOnSound", "" ).SetTitle( "Gadget On" ).SetToolTip( "Gadget turns on sound" );
		Asset.AddEntry_String( "gadgetOffSound", "" ).SetTitle( "Gadget Off" ).SetToolTip( "Gadget turns off sound" );
		Asset.AddEntry_String( "gadgetPrimedLoopSound", "" ).SetTitle( "Gadget Primed Loop" ).SetToolTip( "Gadget primed loop sound" );
		Asset.AddEntry_String( "gadgetPrimedOnSound", "" ).SetTitle( "Gadget Primed On" ).SetToolTip( "Gadget gets primed sound" );
		Asset.AddEntry_String( "gadgetPrimedOffSound", "" ).SetTitle( "Gadget Primed Off" ).SetToolTip( "Gadget stops being primed off sound" );
		Asset.AddEntry_String( "gadgetReadySound", "" ).SetTitle( "Gadget Ready" ).SetToolTip( "Gadget is ready sound" );
		Asset.AddEntry_String( "gadgetFlickerSound", "" ).SetTitle( "Gadget Flicker" ).SetToolTip( "Gadget flickers sound" );
		Asset.AddEntry_String( "gadgetLoopSoundPlayer", "" ).SetTitle( "Gadget Loop Player" ).SetToolTip( "Gadget loop sound" );
		Asset.AddEntry_String( "gadgetAltLoopSoundPlayer", "" ).SetTitle( "Gadget Alt Loop Player" ).SetToolTip( "Gadget Alt loop sound" );
		Asset.AddEntry_String( "gadgetOnSoundPlayer", "" ).SetTitle( "Gadget On Player" ).SetToolTip( "Gadget turns on sound" );
		Asset.AddEntry_String( "gadgetOffSoundPlayer", "" ).SetTitle( "Gadget Off Player" ).SetToolTip( "Gadget turns off sound" );
		Asset.AddEntry_String( "gadgetPrimedLoopSoundPlayer", "" ).SetTitle( "Gadget Primed Loop" ).SetToolTip( "Gadget primed loop sound" );
		Asset.AddEntry_String( "gadgetPrimedOnSoundPlayer", "" ).SetTitle( "Gadget Primed On" ).SetToolTip( "Gadget gets primed sound" );
		Asset.AddEntry_String( "gadgetPrimedOffSoundPlayer", "" ).SetTitle( "Gadget Primed Off" ).SetToolTip( "Gadget stops being primed off sound" );
		Asset.AddEntry_String( "gadgetReadySoundPlayer", "" ).SetTitle( "Gadget Ready Player" ).SetToolTip( "Gadget is ready sound" );
		Asset.AddEntry_String( "gadgetFlickerSoundPlayer", "" ).SetTitle( "Gadget Flicker Player" ).SetToolTip( "Gadget flickers sound" );
		Asset.AddEntry_String( "gadgetTakeSoundPlayer", "" ).SetTitle( "Gadget Take Player" ).SetToolTip( "Gadget is taken from player sound" );
		Asset.AddEntry_String( "gadgetGiveSoundPlayer", "" ).SetTitle( "Gadget Give Player" ).SetToolTip( "Gadget is given to player" );
		Asset.AddEntry_String( "gadgetPingSoundPlayer", "" ).SetTitle( "Gadget Ping Player" ).SetToolTip( "Gadget makes ping sound for player" );
		Asset.AddEntry_String( "gadgetEnemyPingSoundPlayer", "" ).SetTitle( "Gadget Enemy Ping Player" ).SetToolTip( "Ping sound when enemy gadget has found this player" );
		Asset.AddEntry_String( "gadgetMissSoundPlayer", "" ).SetTitle( "Gadget Miss Player" ).SetToolTip( "Sound when gadget fails (i.e. vision pulse does not hit anything)" );
	}
	Asset.BeginCategory( "Gadget Fx" );
	{
		Asset.AddEntry_AssetCombo( "tagFXFirstPersonOn", "tagfx").SetTitle( "tagFXFirstPersonOn" ).SetToolTip( "Use this to specify the tagFXFirstPersonOn asset for the tagFXFirstPersonOn." );
		Asset.AddEntry_AssetCombo( "tagFXFirstPersonOff", "tagfx").SetTitle( "tagFXFirstPersonOff" ).SetToolTip( "Use this to specify the tagFXFirstPersonOff asset for the tagFXFirstPersonOff." );
		Asset.AddEntry_AssetCombo( "tagFXFirstPersonOnAlt", "tagfx").SetTitle( "tagFXFirstPersonAlt" ).SetToolTip( "Use this to specify the tagFXFirstPersonAlt asset for the tagFXFirstPersonAlt." );
		Asset.AddEntry_AssetCombo( "tagFXFirstPersonLoop", "tagfx").SetTitle( "tagFXFirstPersonLoop" ).SetToolTip( "Use this to specify the tagFXFirstPersonLoop asset for the tagFXFirstPersonLoop." );
		
		Asset.AddEntry_AssetCombo( "tagFXThirdPersonOn", "tagfx").SetTitle( "tagFXThirdPersonOn" ).SetToolTip( "Use this to specify the tagFXThirdPersonOn asset for the tagFXThirdPersonOn." );
		Asset.AddEntry_AssetCombo( "tagFXThirdPersonOff", "tagfx").SetTitle( "tagFXThirdPersonOff" ).SetToolTip( "Use this to specify the tagFXThirdPersonOff asset for the tagFXThirdPersonOff." );
		Asset.AddEntry_AssetCombo( "tagFXThirdPersonOnAlt", "tagfx").SetTitle( "tagFXThirdPersonAlt" ).SetToolTip( "Use this to specify the tagFXThirdPersonAlt asset for the tagFXThirdPersonAlt." );
		Asset.AddEntry_AssetCombo( "tagFXThirdPersonLoop", "tagfx").SetTitle( "tagFXThirdPersonLoop" ).SetToolTip( "Use this to specify the tagFXThirdPersonLoop asset for the tagFXThirdPersonLoop." );
	}
	Asset.BeginCategory( "Gadget HUD" );
	{
		Asset.AddEntry_AssetCombo( "gadgetIconAvailable", "image" ).SetTitle( "Gadget Icon (Available)" ).SetToolTip( "HUD Icon to show when the gadget is available" );
		Asset.AddEntry_AssetCombo( "gadgetIconUnavailable", "image" ).SetTitle( "Gadget Icon (Unavailable)" ).SetToolTip( "HUD Icon to show while the gadget is charging" );
	}
	Asset.BeginCategory( "Gadget Events" );
	{
		Asset.AddEntry_CheckBox( "turnoff_onAttack", false ).SetTitle( "turnoff_onAttack" ).SetToolTip( "The turnoff_onAttack property" );
		Asset.AddEntry_CheckBox( "turnoff_onEmpJammed", true ).SetTitle( "turnoff_onEmpJammed" ).SetToolTip( "The turnoff_onEmpJammed property" );
		Asset.AddEntry_CheckBox( "turnoff_onHeldKillstreak", false ).SetTitle( "turnoff_onHeldKillstreak" ).SetToolTip( "The turnoff_onHeldKillstreak property" );		
		Asset.AddEntry_CheckBox( "wielded_stayOn_onEmpJammed", false ).SetTitle( "wielded_stayOn_onEmpJammed" ).SetToolTip( "A wielded gadget stays on when emp jammed" );
		Asset.AddEntry_CheckBox( "wielded_stayOn_onHeldKillstreak", true ).SetTitle( "wielded_stayOn_onHeldKillstreak" ).SetToolTip( "A wielded gadget stays on when activating a held killstreak" );
		Asset.AddEntry_CheckBox( "wielded_stayOn_onOffhandThrow", true ).SetTitle( "wielded_stayOn_onOffhandThrow" ).SetToolTip( "A wielded gadget stays on when doing an offhand throw" );
		Asset.AddEntry_CheckBox( "can_activate_whenEmpJammed", true ).SetTitle( "can_activate_whenEmpJammed" ).SetToolTip( "If set, the player can activate this gadget when emp jammed." );
	}
	Asset.BeginCategory( "Gadget Misc" );
	{
		Asset.AddEntry_Float( "flashback_screenFlashShotFadeTime", 0, 0, 1000 ).SetTitle( "Flash Shot Fade Time (in sec)" );
		Asset.AddEntry_Float( "flashback_screenFlashWhiteFadeTime", 0, 0, 1000 ).SetTitle( "Flash White Fade Time (in sec)" );
		Asset.AddEntry_Int( "flashback_rewindTime", 0, 0, 25000 ).SetTitle( "Flashback Rewind Time" ).SetToolTip( "How far back time is rewound" );
		Asset.AddEntry_Float( "flashback_rewindDistance", 600, 0, 10000 ).SetTitle( "Flashback Rewind Distance" ).SetToolTip( "Desired safe distance for flashback" );
		Asset.AddEntry_Float( "shock_field_radius", 0, 0, 10000 ).SetTitle( "shockField Radius" ).SetToolTip( "The radius of the shock field" );
		Asset.AddEntry_Float( "shock_field_damage", 0, 0, 1000 ).SetTitle( "shockField Damage" ).SetToolTip( "The amount of damage per shock the field should do" );
		Asset.AddEntry_Float( "blurAmount", 0, 0, 1 ).SetTitle( "blurAmount" ).SetToolTip( "The ratio between 0 and 1 of blur to apply" );
		Asset.AddEntry_Float( "blurRadiusInner", 0, 0, 1 ).SetTitle( "blurRadiusInner" ).SetToolTip( "The inner radius between 0 and 1" );
		Asset.AddEntry_Float( "blurRadiusOuter", 0, 0, 1 ).SetTitle( "blurRadiusOuter" ).SetToolTip( "The outer radius between 0 and 1" );
		Asset.AddEntry_Float( "blurOutScale", 300, 1, 60000 ).SetTitle( "blurOutScale" ).SetToolTip( "Speed at which no blur applies is 1.0" );
		Asset.AddEntry_Int( "blurInTime", 0, 0, 10000 ).SetTitle( "blurInTime" ).SetToolTip( "The blurInTime property" );
		Asset.AddEntry_Int( "blurOutTime", 0, 0, 10000 ).SetTitle( "blurOutTime" ).SetToolTip( "The blurOutTime property" );
		Asset.AddEntry_CheckBox( "blur_screen", false ).SetTitle( "Should Blur Screen" ).SetToolTip( "Setting this box will blur the screen when activated." );
		Asset.AddEntry_Int( "camo_bread_crumb_duration", 0, 0, 10000 ).SetTitle( "camo_bread_crumb_duration" ).SetToolTip( "The camo_bread_crumb_duration property" );
		Asset.AddEntry_Int( "camo_invisibility_alert_time", 2000, 0, 10000 ).SetTitle( "camo_invisibility_alert_time" ).SetToolTip( "The camo_invisibility_alert_time property" );
		Asset.AddEntry_Int( "camo_invisibility_flicker_extension_time", 500, 0, 10000 ).SetTitle( "camo_invisibility_flicker_extension_time" ).SetToolTip( "The camo_invisibility_flicker_extension_time property" );
		Asset.AddEntry_Float( "camo_invisibility_flicker_radius_extension", 2, 1, 10 ).SetTitle( "camo_invisibility_flicker_radius_extension" ).SetToolTip( "The camo_invisibility_flicker_radius_extension property" );
		Asset.AddEntry_Int( "camo_invisibility_radius", 100, 0, 10000 ).SetTitle( "camo_invisibility_radius" ).SetToolTip( "The camo_invisibility_radius property" );
		Asset.AddEntry_Int( "camo_invisibility_takedown_response_radius", 500, 0, 10000 ).SetTitle( "camo_invisibility_takedown_response_radius" ).SetToolTip( "The camo_invisibility_takedown_response_radius property" );
		Asset.AddEntry_Int( "camo_invisibility_takedown_reveal_time", 5000, 0, 10000 ).SetTitle( "camo_invisibility_takedown_reveal_time" ).SetToolTip( "The camo_invisibility_takedown_reveal_time property" );
		Asset.AddEntry_Int( "camo_takedown_power_gain", 0, 0, 100 ).SetTitle( "camo_takedown_power_gain" ).SetToolTip( "The camo_takedown_power_gain property" );
		Asset.AddEntry_Float( "escort_drone_bullet_dmg_power_loss", 0, 0, 100 ).SetTitle( "escort_drone_bullet_dmg_power_loss" ).SetToolTip( "The escort_drone_bullet_dmg_power_loss property" );
		Asset.AddEntry_Float( "escort_drone_burst_count_max", 1, 0, 10 ).SetTitle( "escort_drone_burst_count_max" ).SetToolTip( "The escort_drone_burst_count_max property" );
		Asset.AddEntry_Float( "escort_drone_burst_count_min", 1, 0, 10 ).SetTitle( "escort_drone_burst_count_min" ).SetToolTip( "The escort_drone_burst_count_min property" );
		Asset.AddEntry_Int( "escort_drone_burst_power_loss", 0, 0, 100 ).SetTitle( "escort_drone_burst_power_loss" ).SetToolTip( "The escort_drone_burst_power_loss property" );
		Asset.AddEntry_Int( "escort_drone_burst_wait_time", 0, 0, 10000 ).SetTitle( "escort_drone_burst_wait_time" ).SetToolTip( "The escort_drone_burst_wait_time property" );
		Asset.AddEntry_Float( "escort_drone_exp_dmg_power_loss", 0, 0, 100 ).SetTitle( "escort_drone_exp_dmg_power_loss" ).SetToolTip( "The escort_drone_exp_dmg_power_loss property" );
		Asset.AddEntry_Int( "escort_drone_hover_dist", 0, 0, 5000 ).SetTitle( "escort_drone_hover_dist" ).SetToolTip( "The escort_drone_hover_dist property" );
		Asset.AddEntry_Int( "escort_drone_launch_dist", 0, 0, 5000 ).SetTitle( "escort_drone_launch_dist" ).SetToolTip( "The escort_drone_launch_dist property" );
		Asset.AddEntry_Float( "escort_drone_misc_dmg_power_loss", 0, 0, 100 ).SetTitle( "escort_drone_misc_dmg_power_loss" ).SetToolTip( "The escort_drone_misc_dmg_power_loss property" );
		Asset.AddEntry_Int( "escort_drone_target_acquire_time", 0, 0, 5000 ).SetTitle( "escort_drone_target_acquire_time" ).SetToolTip( "The escort_drone_target_acquire_time property" );
		Asset.AddEntry_Int( "escort_drone_tether_max_dist", 0, 0, 20000 ).SetTitle( "escort_drone_tether_max_dist" ).SetToolTip( "The escort_drone_tether_max_dist property" );
		Asset.AddEntry_Int( "escort_drone_tether_min_dist", 0, 0, 10000 ).SetTitle( "escort_drone_tether_min_dist" ).SetToolTip( "The escort_drone_tether_min_dist property" );
		Asset.AddEntry_Int( "multiRocket_acquisition_time", 0, 0, 5000 ).SetTitle( "multiRocket_acquisition_time" ).SetToolTip( "The multiRocket_acquisition_time property" );
		Asset.AddEntry_Int( "multiRocket_fire_interval", 0, 0, 5000 ).SetTitle( "multiRocket_fire_interval" ).SetToolTip( "The multiRocket_fire_interval property" );
		Asset.AddEntry_Int( "multiRocket_fire_power_loss", 0, 0, 100 ).SetTitle( "multiRocket_fire_power_loss" ).SetToolTip( "The multiRocket_fire_power_loss property" );
		Asset.AddEntry_Int( "multirocket_target_number", 0, 0, 10 ).SetTitle( "multirocket_target_number" ).SetToolTip( "The multirocket_target_number property" );
		Asset.AddEntry_Int( "multiRocket_target_radius", 0, 0, 10000 ).SetTitle( "multiRocket_target_radius" ).SetToolTip( "The multiRocket_target_radius property" );
		Asset.AddEntry_Int( "pulse_duration", 0, 0, 30000 ).SetTitle( "pulse_duration" ).SetToolTip( "The pulse_duration property" );
		Asset.AddEntry_Int( "pulse_margin", 0, 0, 30000 ).SetTitle( "pulse_margin" ).SetToolTip( "The pulse_margin property" );
		Asset.AddEntry_Int( "pulse_reveal_time", 0, 0, 30000 ).SetTitle( "pulse_reveal_time" ).SetToolTip( "The pulse_reveal_time property" );
		Asset.AddEntry_Int( "pulse_reveal_camo_time", 0, 0, 30000 ).SetTitle( "pulse_reveal_camo_time" ).SetToolTip( "The pulse_reveal_camo_time property" );
		Asset.AddEntry_Int( "pulse_reveal_time_viewModel", 0, 0, 30000 ).SetTitle( "pulse_reveal_time_viewModel" ).SetToolTip( "The pulse_reveal_time property for a victims viewmodel" );
		Asset.AddEntry_Combo( "pulse_enemy_share_type", "none | minimap |	viewport | both" ).SetTitle( "pulse_enemy_share_type" ).SetToolTip( "The pulse_enemy_share_type property" );
		Asset.AddEntry_Combo( "pulse_share_type", "none | minimap |	viewport | both" ).SetTitle( "pulse_share_type" ).SetToolTip( "The pulse_share_type property" );
		Asset.AddEntry_Combo( "pulse_type", "none | minimap |	viewport | both" ).SetTitle( "pulse_type" ).SetToolTip( "The pulse_type property (Local Player)" );
		Asset.AddEntry_Int( "pulse_share_radius", -1, -1, 30000 ).SetTitle( "pulse_share_radius" ).SetToolTip( "The pulse_share_radius property" );		
		Asset.AddEntry_Int( "pulse_max_range", 0, 0, 30000 ).SetTitle( "pulse_max_range" ).SetToolTip( "The pulse_max_range property" );
		Asset.AddEntry_Float( "shield_blast_protection_120", 0.1, 0, 1 ).SetTitle( "shield_blast_protection_120" ).SetToolTip( "The shield_blast_protection_120 property" );
		Asset.AddEntry_Float( "shield_blast_protection_180", 0, 0, 1 ).SetTitle( "shield_blast_protection_180" ).SetToolTip( "The shield_blast_protection_180 property" );
		Asset.AddEntry_Float( "shield_blast_protection_30", 0.4, 0, 1 ).SetTitle( "shield_blast_protection_30" ).SetToolTip( "The shield_blast_protection_30 property" );
		Asset.AddEntry_Float( "shield_blast_protection_60", 0.2, 0, 1 ).SetTitle( "shield_blast_protection_60" ).SetToolTip( "The shield_blast_protection_60 property" );
		Asset.AddEntry_Float( "shield_reflect_actor_accuracy_multiplier", 0, 0, 10 ).SetTitle( "shield_reflect_actor_accuracy_multiplier" ).SetToolTip( "The shield_reflect_actor_accuracy_multiplier property" );
		Asset.AddEntry_Float( "shield_reflect_aim_assist_lerp", 1, 0, 1 ).SetTitle( "shield_reflect_aim_assist_lerp" ).SetToolTip( "The shield_reflect_aim_assist_lerp property" );
		Asset.AddEntry_Float( "shield_reflect_damage_multiplier", 1, 0, 10 ).SetTitle( "shield_reflect_damage_multiplier" ).SetToolTip( "The shield_reflect_damage_multiplier property" );
		Asset.AddEntry_Int( "shield_reflect_power_gain", 0, 0, 100 ).SetTitle( "shield_reflect_power_gain" ).SetToolTip( "The shield_reflect_power_gain property" );
		Asset.AddEntry_Int( "shield_reflect_power_loss", 0, 0, 100 ).SetTitle( "shield_reflect_power_loss" ).SetToolTip( "The shield_reflect_power_loss property" );
		Asset.AddEntry_Float( "speed_sprint_out_scale", 1, 0, 10 ).SetTitle( "speed_sprint_out_scale" ).SetToolTip( "The speed_sprint_out_scale property" );
		Asset.AddEntry_Float( "speed_wallrun_out_scale", 1, 0, 10 ).SetTitle( "speed_wallrun_out_scale" ).SetToolTip( "The speed_wallrun_out_scale property" );		
		Asset.AddEntry_Float( "speed_max_power_usage_rate", 10, 0, 500 ).SetTitle( "speed_max_power_usage_rate" ).SetToolTip( "The speed_max_power_usage_rate property" );
		Asset.AddEntry_Float( "speed_max_power_speed_threshold", 200, 0, 30000 ).SetTitle( "speed_max_power_speed_threshold" ).SetToolTip( "The speed_max_power_speed_threshold property" );
		Asset.AddEntry_Int( "turret_fire_power_loss", 0, 0, 100 ).SetTitle( "turret_fire_power_loss" ).SetToolTip( "The turret_fire_power_loss property" );
		Asset.AddEntry_CheckBox( "changeLens", false ).SetTitle( "Change Lens When Active" ).SetToolTip( "Setting this box allow you to set various lens (FOV) using the values below when the gadget is active" );
		Asset.AddEntry_Float( "lensScaleInitial", 1, 0, 500 ).SetTitle( "lensScaleInitial" ).SetToolTip( "The lensScaleInitial property" );
		Asset.AddEntry_Float( "lensScaleFinal", 1, 0, 500 ).SetTitle( "lensScaleFinal" ).SetToolTip( "The lensScaleFinal property" );
		Asset.AddEntry_Float( "lensMinFocalLength", 14.64, 12, 14.64 ).SetTitle( "lensMinFocalLength" ).SetToolTip( "The lensMinFocalLength property" );
		Asset.AddEntry_Float( "lensMaxFocalLength", 14.64, 12, 14.64 ).SetTitle( "lensMaxFocalLength" ).SetToolTip( "The lensMaxFocalLength property" );
		Asset.AddEntry_Int( "lensTransTimeIn", 500, 0, 10000 ).SetTitle( "lensTransTimeIn" ).SetToolTip( "The lensTransTimeIn property" );
		Asset.AddEntry_Int( "lensTransTimeOut", 500, 0, 10000 ).SetTitle( "lensTransTimeOut" ).SetToolTip( "The lensTransTimeOut property" );
	}
}