#define DEBUG_ELEVATORS 1
#define PRINT_ELEV_DEBUG(__str) if(DEBUG_ELEVATORS) IPrintLnBold(__str) // Note: don't use comas in __str

#define BOTTOM_FLOOR_ELEVATOR 0
#define TOP_FLOOR_ELEVATOR 1

#define OPEN true
#define CLOSE false

#define BOTTOM_FLOOR_OFFSET 256
#define ELEVATOR_TRANSITION_TIME 8
#define DOOR_OPEN_OFFSET 30
#define DOOR_TRANSITION_TIME 1.0
#define DOOR_GRID_OPEN_OFFSET 101
#define DOOR_GRID_TRANSITION_TIME 3.0

#define PLAYER_TP_OFFSET 8
#define PLAYER_TP_NOTIFICATION "elevator_tp_notification"

#define ELEVATOR_ENT array("bottom_elevator", "top_elevator")
#define ELEVATOR_PLATFORM_ENT array("bottom_elevator_platform", "top_elevator_platform")
#define ELEVATOR_LEFT_DOOR_ENT array("bottom_elevator_door_left", "top_elevator_door_left")
#define ELEVATOR_RIGHT_DOOR_ENT array("bottom_elevator_door_right", "top_elevator_door_right")
#define ELEVATOR_GRID_DOOR_ENT array("bottom_elevator_grid", "top_elevator_grid")
#define ELEVATOR_LIGHT_ENT array("bottom_elevator_light", "top_elevator_light")
#define ELEVATOR_TRIGGER_ENT array("bottom_elevator_trigger", "top_elevator_trigger")
#define ELEVATOR_DOOR_TRIGGER_ENT array("bottom_elevator_door_trigger", "top_elevator_door_trigger")
#define ELEVATOR_CLIPBRUSH_ENT array("bottom_elevator_clipbrush", "top_elevator_clipbrush")

#define ELEVATOR_LIGHT_FX "_reapy/fx_elevator_light"

#define ELEVATOR_EARTHQUAKE_INTENSITY 0.15

#define ELEVATOR_SOUND_LIFT "todo"
#define ELEVATOR_SOUND_CLIP "todo"
#define ELEVATOR_SOUND_MUSIC "todo"
#define ELEVATOR_SOUND_DING "todo"