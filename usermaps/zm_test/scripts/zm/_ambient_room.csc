#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\system_shared;
#using scripts\shared\trigger_shared;
#using scripts\shared\util_shared;
#using scripts\shared\music_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

/*
 * Author: Ardivee (& Reapy)
 * Version: 0.6.2
 * Description: Setup ambient rooms to add reverb to weapons, background sounds, and more!
 * Give credit if used
 */
 
// Adapt to your needs
#define AMBIENT_FILE_NAME "zm_test_ambient.csv"
#define AMBIENT_DEBUG 1

#namespace ambient_room;

REGISTER_SYSTEM("ambient_room", &__init__, undefined)
    
function __init__()
{
    level.ambient_room_table = "sound/ambients/" + AMBIENT_FILE_NAME;
    DEFAULT2(level.default_ambient_room, undefined, get_default_ambient_room());
    level.ambient_debug = AMBIENT_DEBUG;

    level.ambient_rooms = [];
    level.active_ambient_room = "";

    callback::on_localclient_connect(&player_amb_connect);
}

function player_amb_connect(localClientNum)
{
    if (!IsSplitScreen())
    {
        level thread ambient_room_trigger(localClientNum);
    }
    else if (IsSplitScreenHost(localClientNum))
    {
        activate_ambient_room(level.default_ambient_room);
    }
}

function ambient_room_trigger(localClientNum)
{
    ambient_rooms = GetEntArray(localClientNum, "ambient_room", "targetname");

    foreach(ambient_room in ambient_rooms)
    {
        ambient_room thread ambient_room_setup(localClientNum);
    }
}

function ambient_room_setup(localClientNum)
{
    ARRAY_ADD(level.ambient_rooms, self);

    self._localClientNum = localClientNum;

    while(1)
    {
        self waittill("trigger", trigPlayer);
        self thread trigger::function_thread(trigPlayer, &trig_enter_ambient_room, &trim_leave_ambient_room);
    } 
}

function ambient_room_to_activate()
{
    active_rooms = get_active_ambient_rooms();

    _IPrintLnBold("current active rooms: " + active_rooms.size);

    room_to_activate = undefined;
    highest_priority = 0;

    if(active_rooms.size > 0)
    {
        foreach(active_room in active_rooms)
        {
            if(isdefined(active_room.script_ambientpriority))
            {
                //get room with highest priority if triggers are overlapping each other
                if(active_room.script_ambientpriority >= highest_priority)
                {
                    highest_priority = active_room.script_ambientpriority;
                    room_to_activate = active_room;
                }
            } else {
                _IPrintLnBold("WARNING: script_ambientpriority is not defined!");
            }
        }

        if(isdefined(room_to_activate.script_ambientroom))
        {
            _IPrintLnBold(active_room.script_ambientroom + " is active now!");
            activate_ambient_room(room_to_activate.script_ambientroom);
        } else {
            _IPrintLnBold("WARNING: script_ambientroom is not defined!");
        }
    } else {
        //fallback to default room if we are not in a ambient room trigger
        _IPrintLnBold("falling back to default room: " + level.default_ambient_room);

        activate_ambient_room(level.default_ambient_room);
    }
}

function activate_ambient_room(ambient_room)
{
    //looking if the ambient room is also setup in the table
    ambient_room_lookup = TableLookup(level.ambient_room_table, 0, ambient_room, 0);

    if(isdefined(ambient_room_lookup) && ambient_room_lookup == ambient_room)
    {
        if(ambient_room != level.active_ambient_room)
        {
            level.active_ambient_room = ambient_room;

            //Set the ambientroom, background loop if presented and adds reverb to the sounds
            ForceAmbientRoom(ambient_room);

            ctx = ambient_contexts(ambient_room);

            //Set the sound context, to enable or disable aliases playing
            SetSoundContext(ctx.ctx_type0, ctx.ctx_value0);

            SetSoundContext(ctx.ctx_type1, ctx.ctx_value1);
            
            SetSoundContext(ctx.ctx_type2, ctx.ctx_value2);

            //SetSoundContext(ctx.global_ctx_type, ctx.global_ctx_value); //not really needed i think, so disabling it for now

            _IPrintLnBold("EntityContextType0: " + ctx.ctx_type0 + " - EntityContextValue0: " + ctx.ctx_value0);
            _IPrintLnBold("EntityContextType1: " + ctx.ctx_type1 + " - EntityContextValue1: " + ctx.ctx_value1);
            _IPrintLnBold("EntityContextType2: " + ctx.ctx_type2 + " - EntityContextValue2: " + ctx.ctx_value2);

        } else {
            _IPrintLnBold("current room is already active");
        }
    } else {
        _IPrintLnBold("ERROR: " + ambient_room + " is not defined in the table");
    }
}

function trig_enter_ambient_room(trigPlayer)
{
    localClientNum = self._localClientNum; 

    if(trigPlayer IsPlayer() && trigPlayer IsLocalPlayer())
    {
        if(isdefined(trigPlayer GetLocalClientNumber()) && localClientNum == trigPlayer GetLocalClientNumber())
        {
            self.is_active = true;
            ambient_room_to_activate();
        }
    }
}

function trim_leave_ambient_room(trigPlayer)
{
    localClientNum = self._localClientNum; 

    if(trigPlayer IsPlayer() && trigPlayer IsLocalPlayer())
    {
        if(isdefined(trigPlayer GetLocalClientNumber()) && localClientNum == trigPlayer GetLocalClientNumber())
        {
            self.is_active = false;
            ambient_room_to_activate();
        }
    }
}

function ambient_contexts(ambient_room)
{
    ctx = SpawnStruct();

    ctx.ctx_type0 = TableLookup(level.ambient_room_table, 0, ambient_room, 6); //EntityContextType0
    ctx.ctx_value0 = TableLookup(level.ambient_room_table, 0, ambient_room, 7); //EntityContextValue0

    ctx.ctx_type1 = TableLookup(level.ambient_room_table, 0, ambient_room, 8); //EntityContextType1
    ctx.ctx_value1 = TableLookup(level.ambient_room_table, 0, ambient_room, 9); //EntityContextValue1

    ctx.ctx_type2 = TableLookup(level.ambient_room_table, 0, ambient_room, 10); //EntityContextType2
    ctx.ctx_value2 = TableLookup(level.ambient_room_table, 0, ambient_room, 11); //EntityContextValue2

    ctx.global_ctx_type = TableLookup(level.ambient_room_table, 0, ambient_room, 12); //GlobalContextType
    ctx.global_ctx_value = TableLookup(level.ambient_room_table, 0, ambient_room, 13); //GlobalContextValue

    return ctx;
}

function get_default_ambient_room()
{
    return TableLookup(level.ambient_room_table, 2, "yes", 0);
}

function get_active_ambient_rooms()
{
    active_rooms = [];

    foreach(ambient_room in level.ambient_rooms)
    {
        if(IS_TRUE(ambient_room.is_active))
        {
            ARRAY_ADD(active_rooms, ambient_room);
        }
    }

    return active_rooms;
}

function _IPrintLnBold(val)
{
    if(level.ambient_debug)
        IPrintLnBold(val);
}