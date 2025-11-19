#define DEBUG_ELEVATORS 0
#define PRINT_ELEV_DEBUG(__str) if(DEBUG_ELEVATORS) IPrintLnBold(__str) // Note: don't use comas in __str

#define BOTTOM_FLOOR_ELEVATOR 0
#define TOP_FLOOR_ELEVATOR 1

#define OPEN true
#define CLOSE false

#define BOTTOM_FLOOR_OFFSET 525
#define ELEVATOR_TRANSITION_TIME 16
#define ELEVATOR_TRANSITION_ACCELARATION_TIME 2
#define ELEVATOR_TRANSITION_DECELARATION_TIME 2
#define DOOR_OPEN_OFFSET 30
#define DOOR_TRANSITION_TIME 3.0
#define DOOR_GRID_OPEN_OFFSET 101
#define DOOR_GRID_TRANSITION_TIME 3.0
#define DELAY_BEFORE_DOOR_OPEN 1.0

#define PLAYER_TP_OFFSET 8
#define PLAYER_TP_NOTIFICATION "elevator_tp_notification"

#define ELEVATOR_ENT array("bottom_elevator", "top_elevator")
#define ELEVATOR_PLATFORM_ENT array("bottom_elevator_platform", "top_elevator_platform")
#define ELEVATOR_LEFT_DOOR_ENT array("bottom_elevator_door_left", "top_elevator_door_left")
#define ELEVATOR_RIGHT_DOOR_ENT array("bottom_elevator_door_right", "top_elevator_door_right")
#define ELEVATOR_GRID_DOOR_ENT array("bottom_elevator_grid", "top_elevator_grid")
#define ELEVATOR_LIGHT_ENT array("bottom_elevator_light", "top_elevator_light")
#define ELEVATOR_LIGHT_MODEL_ENT array("bottom_elevator_light_model", "top_elevator_light_model")
#define ELEVATOR_TRIGGER_ENT array("bottom_elevator_trigger", "top_elevator_trigger")
#define ELEVATOR_DOOR_TRIGGER_ENT array("bottom_elevator_door_trigger", "top_elevator_door_trigger")
#define ELEVATOR_CLIPBRUSH_ENT array("bottom_elevator_clipbrush", "top_elevator_clipbrush")

#define ELEVATOR_LIGHT_FX "_reapy/fx_elevator_light"

#define ELEVATOR_EARTHQUAKE_INTENSITY 0.15

#define ELEVATOR_SOUND_DOOR_OPEN "elevator_door_open"
#define ELEVATOR_SOUND_DOOR_CLOSE "elevator_door_close"
#define ELEVATOR_SOUND_GRID "elevator_grid"
#define ELEVATOR_SOUND_LIFT "elevator_lift"
#define ELEVATOR_SOUND_DING "elevator_ding"

#define ELEVATOR_SOUND_ELEVATOR_ENT array("bottom_elevator_sound", "top_elevator_sound")
#define ELEVATOR_SOUND_LEFT_DOOR_ENT array("bottom_elevator_left_door_sound", "top_elevator_left_door_sound")
#define ELEVATOR_SOUND_RIGHT_DOOR_ENT array("bottom_elevator_right_door_sound", "top_elevator_right_door_sound")
#define ELEVATOR_SOUND_GRID_ENT array("bottom_elevator_grid_sound", "top_elevator_grid_sound")
