#define DEBUG_FAUNA false
#define PRINT_FAUNA_DEBUG(__str) if(DEBUG_FAUNA) IPrintLnBold(__str) // Note: don't use comas in __str

#define ANIMTREE "generic"

// Rats
#define RAT_CLIENTFIELD "toggle_rats_clientfield"
#define XANIMS_RATS array(%p7_fxanim_mp_apartments_rat_comd_p1_a_anim, %p7_fxanim_mp_apartments_rat_heli_p2_a_anim, %p7_fxanim_mp_apartments_rat_heli_p2_a_anim, %p7_fxanim_mp_apartments_rat_kit_p3_a_anim, %p7_fxanim_mp_apartments_rat_kit_p3_a_anim, %p7_fxanim_mp_apartments_rat_heli_p2_a_anim, %p7_fxanim_mp_apartments_rat_comd_p1_a_anim, %p7_fxanim_mp_apartments_rat_comd_p1_a_anim)
#define SCRIPTMODELS_RATS array("rat_0", "rat_1", "rat_2", "rat_3", "rat_4", "rat_5", "rat_6", "rat_7")
// Rats configuration
#define RAT_ANIMATION_MAX_TIME 15.0 // Cap rat animation time because of enormous amount of frames.
#define RAT_ANIMATION_RATE 1.0
#define MAX_RATS_RUNNING 2
#define MIN_DELAY_BETWEEN_RATS_ANIMATIONS 1.0
#define MAX_DELAY_BETWEEN_RATS_ANIMATIONS 5.0
#define MIN_DELAY_BETWEEN_RATS_ANIMATION_LOOP 15.0
#define MAX_DELAY_BETWEEN_RATS_ANIMATION_LOOP 30.0

// Ravens
#define RAVEN_CLIENTFIELD "toggle_ravens_clientfield"
#define XANIMS_RAVEN array(%p7_fxanim_gp_raven_circle_lotus_01_anim, %p7_fxanim_gp_raven_circle_lotus_02_anim, %p7_fxanim_gp_raven_circle_lotus_03_anim, %p7_fxanim_gp_raven_circle_lotus_04_anim, %p7_fxanim_gp_raven_circle_lotus_05_anim, %p7_fxanim_gp_raven_circle_lotus_06_anim, %p7_fxanim_gp_raven_circle_lotus_07_anim, %p7_fxanim_gp_raven_circle_lotus_08_anim, %p7_fxanim_gp_raven_circle_lotus_09_anim, %p7_fxanim_gp_raven_circle_lotus_10_anim, %p7_fxanim_gp_raven_circle_lotus_11_anim, %p7_fxanim_gp_raven_circle_lotus_12_anim)
#define SCRIPTMODEL_RAVENS array("raven_0", "raven_1", "raven_2", "raven_3", "raven_4", "raven_5", "raven_6", "raven_7", "raven_8", "raven_9")
// Ravens configuration
#define RAVEN_ANIMATION_RATE 1.0
#define MAX_RAVENS_FLYING 1
#define MIN_DELAY_BETWEEN_RAVENS_ANIMATIONS 1.0
#define MAX_DELAY_BETWEEN_RAVENS_ANIMATIONS 5.0
#define MIN_DELAY_BETWEEN_RAVENS_ANIMATION_LOOP 15.0
#define MAX_DELAY_BETWEEN_RAVENS_ANIMATION_LOOP 40.0
