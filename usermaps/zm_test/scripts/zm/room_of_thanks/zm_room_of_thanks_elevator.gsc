#using scripts\shared\array_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;

#insert scripts\zm\_zm_utility.gsh;
#insert scripts\zm\_zm.gsh;
#insert scripts\shared\shared.gsh;

#insert scripts\zm\room_of_thanks\zm_room_of_thanks_elevator.gsh;
#namespace zm_room_of_thanks_elevator;

#precache("fx", ELEVATOR_LIGHT_FX);

REGISTER_SYSTEM_EX("zm_room_of_thanks_elevator", &init, &main, undefined)

/* region public */

function teleport_player_and_start_elevator()
{
    level.thanks_elevators[BOTTOM_FLOOR_ELEVATOR] notify(PLAYER_TP_NOTIFICATION);
}

/* endregion */

class ThanksElevator {
    var is_bottom_floor;

    var ent_elevator;
    var ent_platform_clipbrush;
    var ent_left_door;
    var ent_right_door;
    var ent_grid_door;
    var touch_trigger;
    var touch_door_trigger;
    var ent_door_clipbrush;
    var ent_light;
}

/* region init & main */

function private init()
{
    level.thanks_elevators = array(new ThanksElevator(), new ThanksElevator());

    level.thanks_elevators[BOTTOM_FLOOR_ELEVATOR].is_bottom_floor = true;
    level.thanks_elevators[BOTTOM_FLOOR_ELEVATOR].ent_elevator = GetEnt(ELEVATOR_ENT[BOTTOM_FLOOR_ELEVATOR], "targetname");
    level.thanks_elevators[BOTTOM_FLOOR_ELEVATOR].ent_platform_clipbrush = GetEnt(ELEVATOR_PLATFORM_ENT[BOTTOM_FLOOR_ELEVATOR], "targetname");
    level.thanks_elevators[BOTTOM_FLOOR_ELEVATOR].ent_left_door = GetEnt(ELEVATOR_LEFT_DOOR_ENT[BOTTOM_FLOOR_ELEVATOR], "targetname");
    level.thanks_elevators[BOTTOM_FLOOR_ELEVATOR].ent_right_door = GetEnt(ELEVATOR_RIGHT_DOOR_ENT[BOTTOM_FLOOR_ELEVATOR], "targetname");
    level.thanks_elevators[BOTTOM_FLOOR_ELEVATOR].ent_grid_door = GetEnt(ELEVATOR_GRID_DOOR_ENT[BOTTOM_FLOOR_ELEVATOR], "targetname");
    level.thanks_elevators[BOTTOM_FLOOR_ELEVATOR].touch_trigger = GetEnt(ELEVATOR_TRIGGER_ENT[BOTTOM_FLOOR_ELEVATOR], "targetname");
    level.thanks_elevators[BOTTOM_FLOOR_ELEVATOR].touch_door_trigger = GetEnt(ELEVATOR_DOOR_TRIGGER_ENT[BOTTOM_FLOOR_ELEVATOR], "targetname");
    level.thanks_elevators[BOTTOM_FLOOR_ELEVATOR].ent_door_clipbrush = GetEnt(ELEVATOR_CLIPBRUSH_ENT[BOTTOM_FLOOR_ELEVATOR], "targetname");
    level.thanks_elevators[BOTTOM_FLOOR_ELEVATOR].ent_light = GetEnt(ELEVATOR_LIGHT_ENT[BOTTOM_FLOOR_ELEVATOR], "targetname");
	level.thanks_elevators[BOTTOM_FLOOR_ELEVATOR].ent_light = util::spawn_model("tag_origin", level.thanks_elevators[BOTTOM_FLOOR_ELEVATOR].ent_light.origin);

    level.thanks_elevators[TOP_FLOOR_ELEVATOR].is_bottom_floor = false;
    level.thanks_elevators[TOP_FLOOR_ELEVATOR].ent_elevator = GetEnt(ELEVATOR_ENT[TOP_FLOOR_ELEVATOR], "targetname");
    level.thanks_elevators[TOP_FLOOR_ELEVATOR].ent_platform_clipbrush = GetEnt(ELEVATOR_PLATFORM_ENT[TOP_FLOOR_ELEVATOR], "targetname");
    level.thanks_elevators[TOP_FLOOR_ELEVATOR].ent_left_door = GetEnt(ELEVATOR_LEFT_DOOR_ENT[TOP_FLOOR_ELEVATOR], "targetname");
    level.thanks_elevators[TOP_FLOOR_ELEVATOR].ent_right_door = GetEnt(ELEVATOR_RIGHT_DOOR_ENT[TOP_FLOOR_ELEVATOR], "targetname");
    level.thanks_elevators[TOP_FLOOR_ELEVATOR].ent_grid_door = GetEnt(ELEVATOR_GRID_DOOR_ENT[TOP_FLOOR_ELEVATOR], "targetname");
    level.thanks_elevators[TOP_FLOOR_ELEVATOR].touch_trigger = GetEnt(ELEVATOR_TRIGGER_ENT[TOP_FLOOR_ELEVATOR], "targetname");
    level.thanks_elevators[TOP_FLOOR_ELEVATOR].touch_door_trigger = GetEnt(ELEVATOR_DOOR_TRIGGER_ENT[TOP_FLOOR_ELEVATOR], "targetname");
    level.thanks_elevators[TOP_FLOOR_ELEVATOR].ent_door_clipbrush = GetEnt(ELEVATOR_CLIPBRUSH_ENT[TOP_FLOOR_ELEVATOR], "targetname");
    level.thanks_elevators[TOP_FLOOR_ELEVATOR].ent_light = GetEnt(ELEVATOR_LIGHT_ENT[TOP_FLOOR_ELEVATOR], "targetname");
	level.thanks_elevators[TOP_FLOOR_ELEVATOR].ent_light = util::spawn_model("tag_origin", level.thanks_elevators[TOP_FLOOR_ELEVATOR].ent_light.origin);

    array::thread_all(level.thanks_elevators, &elevator_init);
}

function private elevator_init() // self == elevator
{
    if (self.is_bottom_floor)
    {
        self move_elevator((0, 0, -BOTTOM_FLOOR_OFFSET), 0.1);
    }
    else
    {
        self doors_activate(OPEN);
    }

    PlayFxOnTag(ELEVATOR_LIGHT_FX, self.ent_light, "tag_origin");
    self.touch_trigger TriggerEnable(false);
    self.touch_door_trigger TriggerEnable(false);
}

function private main()
{
    thread end_game();
    array::thread_all(level.thanks_elevators, &elevator_think);

    if (DEBUG_ELEVATORS) 
    {
        thread modvar_debug_elevator();
    }
}

function private end_game()
{
    level waittill("end_game");

    foreach(elevator in level.thanks_elevators)
    {
        elevator notify("kill_elevator_think");
    }
}

/* endregion */

/* region elevator logic */

function private elevator_think() // self == elevator
{
    self endon("kill_elevator_think");
    
    if (self.is_bottom_floor)
    {
        self waittill(PLAYER_TP_NOTIFICATION);
        self teleport_players_inside_elevator();
        self elevator_lift();
        self doors_activate(OPEN);
        self elevator_exit();
        self doors_activate(CLOSE);
    }
    else
    {
        level flag::wait_till("initial_blackscreen_passed");
        self elevator_enter();
        self doors_activate(CLOSE);
        self elevator_lift();
    }
}

/* endregion */

/* region methods */

function private teleport_players_inside_elevator() // self == elevator
{
    foreach(player in GetPlayers())
    {
        player SetOrigin(self.ent_platform_clipbrush.origin + (0, 0, PLAYER_TP_OFFSET));
        player SetPlayerAngles(self.ent_elevator.angles);
    }
}

function private elevator_lift() // self == elevator
{
    PRINT_ELEV_DEBUG("elevator lifting");
    
    thread elevator_earthquake(ELEVATOR_EARTHQUAKE_INTENSITY, 0, ELEVATOR_TRANSITION_TIME);
    if (self.is_bottom_floor)
    {
        self move_elevator((0, 0, BOTTOM_FLOOR_OFFSET), ELEVATOR_TRANSITION_TIME);
        self.ent_elevator waittill("movedone");
    }
    else
    {        
        self move_elevator((0, 0, -BOTTOM_FLOOR_OFFSET), ELEVATOR_TRANSITION_TIME);
        self.ent_elevator waittill("movedone");
    }

    self.is_bottom_floor = !self.is_bottom_floor;
}

function private move_elevator(offset, time) // self == elevator
{
    self.ent_elevator MoveTo(self.ent_elevator.origin + offset, time);
    self.ent_left_door MoveTo(self.ent_left_door.origin + offset, time);
    self.ent_right_door MoveTo(self.ent_right_door.origin + offset, time);
    self.ent_platform_clipbrush MoveTo(self.ent_platform_clipbrush.origin + offset, time);
    self.ent_door_clipbrush MoveTo(self.ent_door_clipbrush.origin + offset, time);
    self.ent_light MoveTo(self.ent_light.origin + offset, time);
}

function private doors_activate(open) // self == elevator
{
    if (open)
    {
        forward = AnglesToForward(self.ent_left_door.angles);
        self.ent_left_door MoveTo(self.ent_left_door.origin + (forward * DOOR_OPEN_OFFSET), DOOR_TRANSITION_TIME);
        self.ent_right_door MoveTo(self.ent_right_door.origin - (forward * DOOR_OPEN_OFFSET), DOOR_TRANSITION_TIME);
        self.ent_grid_door MoveTo(self.ent_grid_door.origin - (0, 0, DOOR_GRID_OPEN_OFFSET), DOOR_GRID_TRANSITION_TIME);
        self.ent_grid_door waittill("movedone");
        self.ent_door_clipbrush NotSolid();
    }
    else
    {
        self.ent_door_clipbrush Solid();
        forward = AnglesToForward(self.ent_left_door.angles);
        self.ent_left_door MoveTo(self.ent_left_door.origin - (forward * DOOR_OPEN_OFFSET), DOOR_TRANSITION_TIME);
        self.ent_right_door MoveTo(self.ent_right_door.origin + (forward * DOOR_OPEN_OFFSET), DOOR_TRANSITION_TIME);
        self.ent_grid_door MoveTo(self.ent_grid_door.origin + (0, 0, DOOR_GRID_OPEN_OFFSET), DOOR_GRID_TRANSITION_TIME);
        self.ent_grid_door waittill("movedone");
    }
}

function private elevator_exit() // self == elevator
{
    self.touch_trigger TriggerEnable(true);
    self.touch_door_trigger TriggerEnable(true);
    while(self is_any_player_inside_elevator() || self is_any_player_in_door_way()) 
    {
        WAIT_SERVER_FRAME;
    }
    self.touch_trigger TriggerEnable(false);
    self.touch_door_trigger TriggerEnable(false);
}

function private elevator_enter() // self == elevator
{
    self.touch_trigger TriggerEnable(true);
    self.touch_door_trigger TriggerEnable(true);
    while(!self are_players_inside_elevator() || self is_any_player_in_door_way()) 
    {
        WAIT_SERVER_FRAME;
    }
    self.touch_trigger TriggerEnable(false);
    self.touch_door_trigger TriggerEnable(false);
}

function private are_players_inside_elevator() // self == elevator
{
    foreach (player in GetPlayers())
    {
        if (!player IsTouching(self.touch_trigger))
        {
            return false;
        }
    }
    return true;
}

function private is_any_player_inside_elevator() // self == elevator
{
    foreach (player in GetPlayers())
    {
        if (player IsTouching(self.touch_trigger))
        {
            return true;
        }
    }
    return false;
}

function private is_any_player_in_door_way() // self == elevator
{
    foreach (player in GetPlayers())
    {
        if (player IsTouching(self.touch_door_trigger))
        {
            return true;
        }
    }
    return false;
}

function elevator_earthquake(intensity, delay, duration)
{
    if (delay > 0.0)
    {
        wait delay;
    }
    Earthquake(intensity, duration, (0, 0, 0), 50000);
}

/* endregion */

/* region debug */

function private modvar_debug_elevator()
{
    ModVar("rotelev", "");

    while(true)
    {
        WAIT_SERVER_FRAME;

        dvar_value = GetDvarString("rotelev", "");

        if(!isdefined(dvar_value) || dvar_value == "")
        {
            continue;
        }
        ModVar("rotelev", "");

        switch(Int(dvar_value))
        {
            case 1:
                level.thanks_elevators[BOTTOM_FLOOR_ELEVATOR] thread elevator_lift();
                break;
            case 2:
                level.thanks_elevators[TOP_FLOOR_ELEVATOR] thread elevator_lift();
                break;
            case 3:
                foreach(elevator in level.thanks_elevators)
                {
                    elevator notify("kill_elevator_think");
                }
                break;
            case 4:
                thread teleport_player_and_start_elevator();
                break;
            default:
                PRINT_ELEV_DEBUG("Unsupported");
                break;
        }
    }
}

/* endregion */