#using scripts\shared\array_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;

#insert scripts\zm\_zm_utility.gsh;
#insert scripts\zm\_zm.gsh;
#insert scripts\shared\shared.gsh;

#insert scripts\zm\_auto_closable_door.gsh;
#namespace auto_closable_door;

REGISTER_SYSTEM_EX("auto_closable_door", &init, &main, undefined)

function private init()
{
    level._closable_doors = GetEntArray("closable_door", "targetname");
    array::thread_all(level._closable_doors, &door_init);
}

function private main()
{
    thread end_game();

    if (DEBUG_DOORS) 
    {
        level flag::wait_till("initial_blackscreen_passed");
        door_count = (IsArray(level._closable_doors) ? level._closable_doors.size : 0);
        PRINT_DOOR_DEBUG("Found " + door_count + " doors");
    }
}

function private end_game()
{
    level waittill("end_game");

    foreach(door in level._closable_doors)
    {
        door notify("kill_door_think");
    }
}

function private door_init() // self == door trigger
{
    self SetCursorHint("HINT_NOICON");
    self SetHintString("");
    self SetHintLowPriority(true);
    
    self.targets = GetEntArray(self.target, "targetname");
    array::thread_all(self.targets, &classify, self);

    self thread door_think();
}

function private classify(door_trig) // self == door target
{
    // Doors are closed by default...
    self Solid();
    self DisconnectPaths();

    // If it's the model part of the door, it should contain all the necessary stuff.
    if (self.classname == "script_model")
    {
        DEFAULT(self.script_string, "rotate");
        DEFAULT(self.script_angles, "0 90 0");
        DEFAULT(self.script_transition_time, DEFAULT_DOOR_OPEN_TIME);

        // In order to pass timing to clips
        if (!isdefined(door_trig.transition_time) || self.script_transition_time > door_trig.transition_time)
        {
            door_trig.transition_time = self.script_transition_time;
        }

        // Keep original angles and position for closure
        DEFAULT(self.og_origin, self.origin);
        DEFAULT(self.og_angles, self.angles);

        if (isdefined(self.script_sound))
        {
            sounds = StrTok(self.script_sound, ",");
            self.open_sound = (sounds.size > 0 ? sounds[0] : undefined);
            self.close_sound = (sounds.size > 1 ? sounds[1] : self.open_sound);
        }
    }
}

function private door_think()
{
    self endon("kill_door_think");
    
    while(true)
    {
        if (!self door_buy())
        {
            continue;
        }
        PRINT_DOOR_DEBUG("door has been bought");

        self door_opened();
    }
}

function private door_buy() // self == door trigger
{
    self waittill("trigger", who);
    
    if(!who UseButtonPressed())
    {
        return false;
    }
    
    return true;
}

function private door_opened() // self == door trigger
{
    self TriggerEnable(false);
    array::thread_all(self.targets, &target_activate, true, self.transition_time);
    wait DELAY_BEFORE_DOOR_AUTOCLOSE;
    array::thread_all(self.targets, &target_activate, false, self.transition_time);
    self TriggerEnable(true);
}

function private target_activate(open, transition_time) // self == door target
{
    self NotSolid();
    self ConnectPaths();
    
    if (open)
    {
        self notify(CANCEL_CLOSE_DOOR_NOTIFY);

        if(isdefined(self.open_sound))
        {
            playsoundatposition(self.open_sound, self.origin);
            PRINT_DOOR_DEBUG("open_sound is " + self.open_sound);
        }

        // if(isdefined(self.script_firefx))
        // {
        //     PlayFX(level._effect[self.script_firefx], self.origin);
        // }
    }
    else
    {
        if(isdefined(self.close_sound))
        {
            playsoundatposition(self.close_sound, self.origin);
            PRINT_DOOR_DEBUG("close_sound is " + self.close_sound);
        }

        self thread door_solid_thread(transition_time);
        self thread disconnect_paths_when_done(transition_time);
    }

    if (!isdefined(self.script_string))
    {
        return;
    }
    
    switch(self.script_string)
    {
        case "rotate":
            rot_angle = (open ? self.og_angles + self.script_angles : self.og_angles);
            self RotateTo(rot_angle, transition_time, 0, 0); 
            PRINT_DOOR_DEBUG("door rotating to " + rot_angle);
            break;
        default:
            // For now, only support rotating doors
            // Take examples from _zm_blockers for other types.
            break;
    }
}

function private door_solid_thread(transition_time) // self == door target
{
    self endon(CANCEL_CLOSE_DOOR_NOTIFY);

    wait transition_time;
    player_touching = false; 
    do {
        player_touching = false; 
        foreach (player in GetPlayers())
        {
            if(player IsTouching(self))
            {
                player_touching = true; 
                break; 
            }
        }

        WAIT_SERVER_FRAME;
    }
    while(player_touching);

    self Solid();
    PRINT_DOOR_DEBUG("door closed");
}

function private disconnect_paths_when_done(transition_time) // self == door target
{
    self endon(CANCEL_CLOSE_DOOR_NOTIFY);
    
    wait transition_time;
    self DisconnectPaths();
    PRINT_DOOR_DEBUG("path disconnected");
}