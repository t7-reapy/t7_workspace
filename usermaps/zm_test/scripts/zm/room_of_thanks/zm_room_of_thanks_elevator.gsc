#using scripts\shared\callbacks_shared; 
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

function teleport_players_and_start_elevator()
{
    level.thanks_elevators[BOTTOM_FLOOR_ELEVATOR] notify(PLAYER_TP_NOTIFICATION);
}

function add_enter_room_of_thanks_callback(func_ptr)
{
    if (IsFunctionPtr(func_ptr))
    {
        ARRAY_ADD(level.thanks_elevators[BOTTOM_FLOOR_ELEVATOR].travel_callbacks, func_ptr);
    }
}

function add_exit_room_of_thanks_callback(func_ptr)
{
    if (IsFunctionPtr(func_ptr))
    {
        ARRAY_ADD(level.thanks_elevators[TOP_FLOOR_ELEVATOR].travel_callbacks, func_ptr);
    }
}

/* endregion */

class ThanksElevator {
    var is_bottom_floor;
    var travel_callbacks;
    var should_manage_respawns;

    var ent_elevator;
    var ent_platform_clipbrush;
    var ent_left_door;
    var ent_right_door;
    var ent_grid_door;
    var touch_trigger;
    var touch_door_trigger;
    var ent_door_clipbrush;
    var ent_light;
    var ent_light_model;

    var snd_ent_elevator;
    var snd_ent_elevator_ding;
    var snd_ent_left_door;
    var snd_ent_right_door;
    var snd_ent_grid_door;
}

/* region init & main */

function private init()
{
    level.thanks_elevators = array(new ThanksElevator(), new ThanksElevator());

    level.thanks_elevators[BOTTOM_FLOOR_ELEVATOR].is_bottom_floor = true;
    level.thanks_elevators[BOTTOM_FLOOR_ELEVATOR].travel_callbacks = [];
    level.thanks_elevators[BOTTOM_FLOOR_ELEVATOR].should_manage_respawns = false;
    level.thanks_elevators[BOTTOM_FLOOR_ELEVATOR].ent_elevator = GetEnt(ELEVATOR_ENT[BOTTOM_FLOOR_ELEVATOR], "targetname");
    level.thanks_elevators[BOTTOM_FLOOR_ELEVATOR].ent_platform_clipbrush = GetEnt(ELEVATOR_PLATFORM_ENT[BOTTOM_FLOOR_ELEVATOR], "targetname");
    level.thanks_elevators[BOTTOM_FLOOR_ELEVATOR].ent_left_door = GetEnt(ELEVATOR_LEFT_DOOR_ENT[BOTTOM_FLOOR_ELEVATOR], "targetname");
    level.thanks_elevators[BOTTOM_FLOOR_ELEVATOR].ent_right_door = GetEnt(ELEVATOR_RIGHT_DOOR_ENT[BOTTOM_FLOOR_ELEVATOR], "targetname");
    level.thanks_elevators[BOTTOM_FLOOR_ELEVATOR].ent_grid_door = GetEnt(ELEVATOR_GRID_DOOR_ENT[BOTTOM_FLOOR_ELEVATOR], "targetname");
    level.thanks_elevators[BOTTOM_FLOOR_ELEVATOR].touch_trigger = GetEnt(ELEVATOR_TRIGGER_ENT[BOTTOM_FLOOR_ELEVATOR], "targetname");
    level.thanks_elevators[BOTTOM_FLOOR_ELEVATOR].touch_door_trigger = GetEnt(ELEVATOR_DOOR_TRIGGER_ENT[BOTTOM_FLOOR_ELEVATOR], "targetname");
    level.thanks_elevators[BOTTOM_FLOOR_ELEVATOR].ent_door_clipbrush = GetEnt(ELEVATOR_CLIPBRUSH_ENT[BOTTOM_FLOOR_ELEVATOR], "targetname");
	level.thanks_elevators[BOTTOM_FLOOR_ELEVATOR].ent_light = GetEnt(ELEVATOR_LIGHT_ENT[BOTTOM_FLOOR_ELEVATOR], "targetname");
	level.thanks_elevators[BOTTOM_FLOOR_ELEVATOR].ent_light_model = GetEnt(ELEVATOR_LIGHT_MODEL_ENT[BOTTOM_FLOOR_ELEVATOR], "targetname");
	level.thanks_elevators[BOTTOM_FLOOR_ELEVATOR].snd_ent_elevator = GetEnt(ELEVATOR_SOUND_ELEVATOR_ENT[BOTTOM_FLOOR_ELEVATOR], "targetname");
    level.thanks_elevators[BOTTOM_FLOOR_ELEVATOR].snd_ent_elevator_ding = GetEnt(ELEVATOR_SOUND_ELEVATOR_ENT[BOTTOM_FLOOR_ELEVATOR], "targetname");
    level.thanks_elevators[BOTTOM_FLOOR_ELEVATOR].snd_ent_left_door = GetEnt(ELEVATOR_SOUND_LEFT_DOOR_ENT[BOTTOM_FLOOR_ELEVATOR], "targetname");
	level.thanks_elevators[BOTTOM_FLOOR_ELEVATOR].snd_ent_right_door = GetEnt(ELEVATOR_SOUND_RIGHT_DOOR_ENT[BOTTOM_FLOOR_ELEVATOR], "targetname");
	level.thanks_elevators[BOTTOM_FLOOR_ELEVATOR].snd_ent_grid_door = GetEnt(ELEVATOR_SOUND_GRID_ENT[BOTTOM_FLOOR_ELEVATOR], "targetname");
    
    level.thanks_elevators[TOP_FLOOR_ELEVATOR].is_bottom_floor = false;
    level.thanks_elevators[TOP_FLOOR_ELEVATOR].travel_callbacks = [];
    level.thanks_elevators[TOP_FLOOR_ELEVATOR].should_manage_respawns = false;
    level.thanks_elevators[TOP_FLOOR_ELEVATOR].ent_elevator = GetEnt(ELEVATOR_ENT[TOP_FLOOR_ELEVATOR], "targetname");
    level.thanks_elevators[TOP_FLOOR_ELEVATOR].ent_platform_clipbrush = GetEnt(ELEVATOR_PLATFORM_ENT[TOP_FLOOR_ELEVATOR], "targetname");
    level.thanks_elevators[TOP_FLOOR_ELEVATOR].ent_left_door = GetEnt(ELEVATOR_LEFT_DOOR_ENT[TOP_FLOOR_ELEVATOR], "targetname");
    level.thanks_elevators[TOP_FLOOR_ELEVATOR].ent_right_door = GetEnt(ELEVATOR_RIGHT_DOOR_ENT[TOP_FLOOR_ELEVATOR], "targetname");
    level.thanks_elevators[TOP_FLOOR_ELEVATOR].ent_grid_door = GetEnt(ELEVATOR_GRID_DOOR_ENT[TOP_FLOOR_ELEVATOR], "targetname");
    level.thanks_elevators[TOP_FLOOR_ELEVATOR].touch_trigger = GetEnt(ELEVATOR_TRIGGER_ENT[TOP_FLOOR_ELEVATOR], "targetname");
    level.thanks_elevators[TOP_FLOOR_ELEVATOR].touch_door_trigger = GetEnt(ELEVATOR_DOOR_TRIGGER_ENT[TOP_FLOOR_ELEVATOR], "targetname");
    level.thanks_elevators[TOP_FLOOR_ELEVATOR].ent_door_clipbrush = GetEnt(ELEVATOR_CLIPBRUSH_ENT[TOP_FLOOR_ELEVATOR], "targetname");
	level.thanks_elevators[TOP_FLOOR_ELEVATOR].ent_light = GetEnt(ELEVATOR_LIGHT_ENT[TOP_FLOOR_ELEVATOR], "targetname");
	level.thanks_elevators[TOP_FLOOR_ELEVATOR].ent_light_model = GetEnt(ELEVATOR_LIGHT_MODEL_ENT[TOP_FLOOR_ELEVATOR], "targetname");
	level.thanks_elevators[TOP_FLOOR_ELEVATOR].snd_ent_elevator = GetEnt(ELEVATOR_SOUND_ELEVATOR_ENT[TOP_FLOOR_ELEVATOR], "targetname");
	level.thanks_elevators[TOP_FLOOR_ELEVATOR].snd_ent_elevator_ding = GetEnt(ELEVATOR_SOUND_ELEVATOR_ENT[TOP_FLOOR_ELEVATOR], "targetname");
	level.thanks_elevators[TOP_FLOOR_ELEVATOR].snd_ent_left_door = GetEnt(ELEVATOR_SOUND_LEFT_DOOR_ENT[TOP_FLOOR_ELEVATOR], "targetname");
	level.thanks_elevators[TOP_FLOOR_ELEVATOR].snd_ent_right_door = GetEnt(ELEVATOR_SOUND_RIGHT_DOOR_ENT[TOP_FLOOR_ELEVATOR], "targetname");
	level.thanks_elevators[TOP_FLOOR_ELEVATOR].snd_ent_grid_door = GetEnt(ELEVATOR_SOUND_GRID_ENT[TOP_FLOOR_ELEVATOR], "targetname");

    array::thread_all(level.thanks_elevators, &elevator_init);
    callback::on_spawned(&on_player_spawned);
}

function private elevator_init() // self == elevator
{
    self.ent_door_clipbrush Solid();
    if (self.is_bottom_floor)
    {
        self move_elevator((0, 0, -BOTTOM_FLOOR_OFFSET), 0.1);
    }
    else
    {
        self doors_activate(OPEN);
    }

    self.ent_light SetModel("tag_origin");
	self.snd_ent_elevator SetModel("tag_origin");
	self.snd_ent_elevator_ding SetModel("tag_origin");
	self.snd_ent_left_door SetModel("tag_origin");
	self.snd_ent_right_door SetModel("tag_origin");
	self.snd_ent_grid_door SetModel("tag_origin");

    PlayFxOnTag(ELEVATOR_LIGHT_FX, self.ent_light, "tag_origin");
    self.touch_trigger SetCursorHint("HINT_NOICON");
    self.touch_trigger SetHintString("");
    self.touch_trigger SetHintLowPriority(true);
    self.touch_trigger TriggerEnable(false);
    self.touch_door_trigger SetCursorHint("HINT_NOICON");
    self.touch_door_trigger SetHintString("");
    self.touch_door_trigger SetHintLowPriority(true);
    self.touch_door_trigger TriggerEnable(false);
}

function private on_player_spawned()
{
    elevator = level.thanks_elevators[BOTTOM_FLOOR_ELEVATOR];

    if (!elevator.should_manage_respawns)
    {
        return;
    }

    elevator thread elevator_player_spawn(self);
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
        self.should_manage_respawns = true;
        self thread elevator_travel_callbacks();
        self teleport_players_inside_elevator();

        self thread elevator_lift_sounds();
        self thread elevator_earthquake();
        self elevator_lift();

        wait DELAY_BEFORE_DOOR_OPEN;
        self thread elevator_arrive_sounds();
        self thread doors_activate_sounds(OPEN);
        self doors_activate(OPEN);

        self elevator_exit();

        self thread doors_activate_sounds(CLOSE);
        self doors_activate(CLOSE);
    }
    else
    {
        level flag::wait_till("initial_blackscreen_passed");
        self elevator_enter();
        self thread elevator_travel_callbacks();

        self thread elevator_arrive_sounds();
        self thread doors_activate_sounds(CLOSE);
        self doors_activate(CLOSE);

        self thread elevator_lift_sounds();
        self elevator_lift();
    }
}

function private elevator_player_spawn(player) // self == elevator
{
    self thread elevator_travel_callbacks();
    self teleport_player_inside_elevator(player);

    wait DELAY_BEFORE_DOOR_OPEN;
    self thread elevator_arrive_sounds();
    self thread doors_activate_sounds(OPEN);
    self doors_activate(OPEN);

    self elevator_exit();

    self thread doors_activate_sounds(CLOSE);
    self doors_activate(CLOSE);
}

/* endregion */
/* region methods */

function private teleport_players_inside_elevator() // self == elevator
{
    foreach(player in GetPlayers())
    {
        self teleport_player_inside_elevator(player);
    }
}

function private teleport_player_inside_elevator(player) // self == elevator
{
    player SetOrigin(self.ent_platform_clipbrush.origin + (0, 0, PLAYER_TP_OFFSET));
    player SetPlayerAngles(self.ent_elevator.angles + (0, -90, 0));
}

function private elevator_lift() // self == elevator
{
    PRINT_ELEV_DEBUG("elevator lifting");
    
    if (self.is_bottom_floor)
    {
        self move_elevator((0, 0, BOTTOM_FLOOR_OFFSET), ELEVATOR_TRANSITION_TIME, ELEVATOR_TRANSITION_ACCELARATION_TIME, ELEVATOR_TRANSITION_DECELARATION_TIME);
        self.ent_elevator waittill("movedone");
    }
    else
    {        
        self move_elevator((0, 0, -BOTTOM_FLOOR_OFFSET), ELEVATOR_TRANSITION_TIME, ELEVATOR_TRANSITION_ACCELARATION_TIME, ELEVATOR_TRANSITION_DECELARATION_TIME);
        self.ent_elevator waittill("movedone");
    }

    self.is_bottom_floor = !self.is_bottom_floor;
}

function private move_elevator(offset, time, acceleration_time = 0, deceleration_time = 0) // self == elevator
{
    self.ent_elevator MoveTo(self.ent_elevator.origin + offset, time, acceleration_time, deceleration_time);
    self.snd_ent_elevator MoveTo(self.snd_ent_elevator.origin + offset, time, acceleration_time, deceleration_time);
    self.snd_ent_elevator_ding MoveTo(self.snd_ent_elevator_ding.origin + offset, time, acceleration_time, deceleration_time);

    self.ent_left_door MoveTo(self.ent_left_door.origin + offset, time, acceleration_time, deceleration_time);
    self.snd_ent_left_door MoveTo(self.snd_ent_left_door.origin + offset, time, acceleration_time, deceleration_time);

    self.ent_right_door MoveTo(self.ent_right_door.origin + offset, time, acceleration_time, deceleration_time);
    self.snd_ent_right_door MoveTo(self.snd_ent_right_door.origin + offset, time, acceleration_time, deceleration_time);

    self.ent_platform_clipbrush MoveTo(self.ent_platform_clipbrush.origin + offset, time, acceleration_time, deceleration_time);
    self.ent_door_clipbrush MoveTo(self.ent_door_clipbrush.origin + offset, time, acceleration_time, deceleration_time);
    self.ent_light MoveTo(self.ent_light.origin + offset, time, acceleration_time, deceleration_time);
    self.ent_light_model MoveTo(self.ent_light_model.origin + offset, time, acceleration_time, deceleration_time);
}

function private doors_activate(open) // self == elevator
{
    PRINT_ELEV_DEBUG("self.ent_left_door is defined: " + isdefined(self.ent_left_door));
    PRINT_ELEV_DEBUG("self.ent_right_door is defined: " + isdefined(self.ent_right_door));
    PRINT_ELEV_DEBUG("self.ent_grid_door is defined: " + isdefined(self.ent_grid_door));
    PRINT_ELEV_DEBUG("self.ent_door_clipbrush is defined: " + isdefined(self.ent_door_clipbrush));

    if (open)
    {
        forward = AnglesToForward(self.ent_left_door.angles);

        self.ent_left_door MoveTo(self.ent_left_door.origin + (forward * DOOR_OPEN_OFFSET), DOOR_TRANSITION_TIME);
        self.snd_ent_left_door MoveTo(self.snd_ent_left_door.origin + (forward * DOOR_OPEN_OFFSET), DOOR_TRANSITION_TIME);

        self.ent_right_door MoveTo(self.ent_right_door.origin - (forward * DOOR_OPEN_OFFSET), DOOR_TRANSITION_TIME);
        self.snd_ent_right_door MoveTo(self.snd_ent_right_door.origin - (forward * DOOR_OPEN_OFFSET), DOOR_TRANSITION_TIME);

        self.ent_grid_door MoveTo(self.ent_grid_door.origin - (0, 0, DOOR_GRID_OPEN_OFFSET), DOOR_GRID_TRANSITION_TIME);
        self.snd_ent_grid_door MoveTo(self.snd_ent_grid_door.origin - (0, 0, DOOR_GRID_OPEN_OFFSET), DOOR_GRID_TRANSITION_TIME);

        self.ent_grid_door waittill("movedone");
        self.ent_door_clipbrush NotSolid();
    }
    else
    {
        self.ent_door_clipbrush Solid();
        forward = AnglesToForward(self.ent_left_door.angles);

        self.ent_left_door MoveTo(self.ent_left_door.origin - (forward * DOOR_OPEN_OFFSET), DOOR_TRANSITION_TIME);
        self.snd_ent_left_door MoveTo(self.snd_ent_left_door.origin - (forward * DOOR_OPEN_OFFSET), DOOR_TRANSITION_TIME);

        self.ent_right_door MoveTo(self.ent_right_door.origin + (forward * DOOR_OPEN_OFFSET), DOOR_TRANSITION_TIME);
        self.snd_ent_right_door MoveTo(self.snd_ent_right_door.origin + (forward * DOOR_OPEN_OFFSET), DOOR_TRANSITION_TIME);

        self.ent_grid_door MoveTo(self.ent_grid_door.origin + (0, 0, DOOR_GRID_OPEN_OFFSET), DOOR_GRID_TRANSITION_TIME);
        self.snd_ent_grid_door MoveTo(self.snd_ent_grid_door.origin + (0, 0, DOOR_GRID_OPEN_OFFSET), DOOR_GRID_TRANSITION_TIME);

        self.ent_grid_door waittill("movedone");
    }
}

function private elevator_exit() // self == elevator
{
    while(self is_any_player_inside_elevator() || self is_any_player_in_door_way()) 
    {
        WAIT_SERVER_FRAME;
    }
}

function private elevator_enter() // self == elevator
{
    while(!self are_players_inside_elevator() || self is_any_player_in_door_way()) 
    {
        WAIT_SERVER_FRAME;
    }
}

function private elevator_travel_callbacks() // self == elevator
{
    if (IsArray(self.travel_callbacks))
    {
        foreach (callback in self.travel_callbacks)
        {
            level thread [[ callback ]]();
        }
    }
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

function elevator_earthquake()
{
    Earthquake(ELEVATOR_EARTHQUAKE_INTENSITY, ELEVATOR_TRANSITION_TIME, (0, 0, 0), 50000);
}

/* endregion */
/* region sounds */

function private doors_activate_sounds(open) // self == elevator
{
    door_sound = (open ? ELEVATOR_SOUND_DOOR_OPEN : ELEVATOR_SOUND_DOOR_CLOSE);
    self.snd_ent_left_door PlaySoundOnTag(door_sound, "tag_origin");
    self.snd_ent_right_door PlaySoundOnTag(door_sound, "tag_origin");
    self.snd_ent_grid_door PlaySoundOnTag(ELEVATOR_SOUND_GRID, "tag_origin");
}

function private elevator_lift_sounds() // self == elevator
{
    self.snd_ent_elevator PlaySoundOnTag(ELEVATOR_SOUND_LIFT, "tag_origin");
}


function private elevator_arrive_sounds() // self == elevator
{
    self.snd_ent_elevator_ding PlaySoundOnTag(ELEVATOR_SOUND_DING, "tag_origin");
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
                thread teleport_players_and_start_elevator();
                break;
            case 5:
                thread debug_ents_check();
                break;
            default:
                PRINT_ELEV_DEBUG("Unsupported");
                break;
        }
    }
}

function private debug_ents_check()
{
    PRINT_ELEV_DEBUG("Checking bottom elevator... ");
    wait 0.5;
    level.thanks_elevators[BOTTOM_FLOOR_ELEVATOR] ents_check();

    wait 3.0;
    
    PRINT_ELEV_DEBUG("Checking top elevator... ");
    wait 0.5;
    level.thanks_elevators[TOP_FLOOR_ELEVATOR] ents_check();
}

function private ents_check() // self == elevator
{
    PRINT_ELEV_DEBUG("is_bottom_floor: " + self.is_bottom_floor);

    are_door_ents_okay = isdefined(self.ent_left_door) 
                      && isdefined(self.ent_right_door) 
                      && isdefined(self.ent_grid_door)
                      && isdefined(self.ent_door_clipbrush);
    PRINT_ELEV_DEBUG("Are door entities okay? " + (are_door_ents_okay ? "yes" : "no"));
                 
    are_other_ents_okay = isdefined(self.ent_elevator) 
                       && isdefined(self.ent_platform_clipbrush) 
                       && isdefined(self.ent_light)
                       && isdefined(self.ent_light_model);
    PRINT_ELEV_DEBUG("Are other entities okay? " + (are_other_ents_okay ? "yes" : "no"));

    are_triggers_okay = isdefined(self.touch_trigger)
                     && isdefined(self.touch_door_trigger);
    PRINT_ELEV_DEBUG("Are triggers okay? " + (are_triggers_okay ? "yes" : "no"));

    are_sounds_okay = isdefined(self.snd_ent_elevator)
                   && isdefined(self.snd_ent_elevator_ding)
                   && isdefined(self.snd_ent_left_door)
                   && isdefined(self.snd_ent_right_door)
                   && isdefined(self.snd_ent_grid_door);
    PRINT_ELEV_DEBUG("Are sounds okay? " + (are_sounds_okay ? "yes" : "no"));

    is_okay = are_door_ents_okay && are_other_ents_okay && are_triggers_okay && are_sounds_okay;
    PRINT_ELEV_DEBUG("Is elevator okay? " + (is_okay ? "yes" : "no"));
}

/* endregion */