#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;

#namespace rotating_object;

REGISTER_SYSTEM("rotating_object", &__init__, undefined)    

function __init__()
{
    callback::on_localclient_connect(&init);
}

function init(localClientNum)
{
    rotating_objects = GetEntArray(localClientNum, "rotating_object", "targetname");
    array::thread_all(rotating_objects, &rotating_object_think);
}

function rotating_object_think() // self == script struct
{
    self endon ("entityshutdown");
    
    util::waitforallclients();

    axis = "yaw";
    direction = 360;
    revolutions = 100;
    rotate_time = 12;
    
    if(isdefined(self.script_noteworthy))
    {
        axis = self.script_noteworthy;
    }

    if(isdefined(self.script_float)) 
    {
        rotate_time = self.script_float;
    }

    if (rotate_time == 0)
    {
        rotate_time = 12;
    }

    if (rotate_time < 0)
    {
        direction *= -1;
        rotate_time *= -1;
    }
    
    angles = self.angles;
    
    while(1)
    {
        switch(axis)
        {
            case "roll":
                self RotateRoll(direction * revolutions, rotate_time * revolutions);
            break;

            case "pitch":
                self RotatePitch(direction * revolutions, rotate_time * revolutions);
            break;

            case "yaw":
            default:
                self RotateYaw(direction * revolutions, rotate_time * revolutions);
            break;
        }
        
        self waittill("rotatedone");
        self.angles = angles;
    }
}
