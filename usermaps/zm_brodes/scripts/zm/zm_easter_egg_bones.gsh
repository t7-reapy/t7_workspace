#define DEBUG_SKULL 0
#define PRINT_DEBUG_SKULL(__str) if(DEBUG_SKULL) IPrintLnBold(__str) // Note: don't use comas in __str

#define EASTER_EGG_POWERUP_REWARD "free_perk"
#define EASTER_EGG_MAX_SPOTS 5

#define EASTER_EGG_TRIGGER_ORIGIN "easter_egg_skull_origin"
#define EASTER_EGG_REWARD_LOCATION_NAME "easter_egg_reward_location"

#define ZM_AAT_TURNED_NAME "zm_aat_turned"

#define SKELETON_ROTATION_TIME 16.0
#define SKELETON_FLOAT_TIME 4.0
#define SKELETON_FLOAT_DISTANCE 15
#define SKELETON_ORIGIN_DISTANCE_OFFSET (0, 0, -20)

#define MODEL_SKELETON_0 "model_skeleton_corpse_01"
#define MODEL_SKELETON_1 "model_skeleton_corpse_02"
#define MODEL_SKELETON_2 "model_skeleton_corpse_03"
#define MODELS_SKELETONS array(MODEL_SKELETON_0) // MODEL_SKELETON_1, MODEL_SKELETON_2 didn't look great.

#define ANGLES_SKELETON_0 (8.6, 0, 90)
#define ANGLES_SKELETON_1 (346.6, 212.9, 67.1)
#define ANGLES_SKELETON_2 (331.0, 16.6, 55.25)
#define ANGLES_SKELETONS array(ANGLES_SKELETON_0, ANGLES_SKELETON_1, ANGLES_SKELETON_2)

#define BONES_FLOAT_TRAVEL_TIME 2.5
#define BONES_FLOAT_ASSEMBLE_TIME 2.5
#define BONES_FLOAT_DISTANCE 60

#define ANIMTREE_BONES_FLOAT "generic"
#define MODEL_BONES_FLOAT "fxanim_floating_bones_mod"
#define ANGLES_BONES_FLOAT (40, 90, 90)
#define ANIM_BONES_FLOAT %fxanim_floating_bones_anim
#define BUNDLE_BONES_FLOAT "fxanim_floating_bones_bundle"

#define FX_BONES_START "_reapy/fx_skull_quest_portal_start_island"
#define FX_BONES_LOOP "_reapy/fx_skull_quest_portal_loop_island"
#define FX_BONES_END "_reapy/fx_skull_quest_portal_end_island"
#define FX_BONES_TRAIL "_reapy/fx_megachew_ball_poof_green"
#define FX_BONES_MERGE "_reapy/fx_portal_bamf_zod_zmb"

#define FX_BONES_START_TIME 1.0
#define FX_BONES_DISAPPEAR_DELAY 1.0

#define SOUND_BONES_SHOT "easter_egg_bones_shot"
#define SOUND_BONES_POOF "easter_egg_bones_poof"
#define SOUND_BONES_COMPLETED "easter_egg_bones_completed"
#define SOUND_BONES_ASSEMBLE "easter_egg_bones_assemble"
#define SOUND_BONES_MERGE "easter_egg_bones_merge"
#define SOUND_BONES_FLOAT_LOOP "easter_egg_bones_float_loop"
