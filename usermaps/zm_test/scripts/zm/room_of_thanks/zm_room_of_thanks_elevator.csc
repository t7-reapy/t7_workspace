#using scripts\shared\array_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;

#insert scripts\zm\_zm_utility.gsh;
#insert scripts\zm\_zm.gsh;
#insert scripts\shared\shared.gsh;

#insert scripts\zm\room_of_thanks\zm_room_of_thanks_elevator.gsh;
#namespace zm_room_of_thanks_elevator;

REGISTER_SYSTEM_EX("zm_room_of_thanks_elevator", &init, &main, undefined)

class ThanksElevator {
    var is_bottom_floor;

    var sound_lift;
    var sound_clip;
    var sound_music;
    var sound_ding;
}

function private init()
{
    level.thanks_elevators = array(new ThanksElevator(), new ThanksElevator());

    level.thanks_elevators[BOTTOM_FLOOR_ELEVATOR].is_bottom_floor = true;
    level.thanks_elevators[BOTTOM_FLOOR_ELEVATOR].sound_lift = ELEVATOR_SOUND_LIFT;
    level.thanks_elevators[BOTTOM_FLOOR_ELEVATOR].sound_clip = ELEVATOR_SOUND_CLIP;
    level.thanks_elevators[BOTTOM_FLOOR_ELEVATOR].sound_music = ELEVATOR_SOUND_MUSIC;
    level.thanks_elevators[BOTTOM_FLOOR_ELEVATOR].sound_ding = ELEVATOR_SOUND_DING;

    level.thanks_elevators[TOP_FLOOR_ELEVATOR].is_bottom_floor = false;
    level.thanks_elevators[TOP_FLOOR_ELEVATOR].sound_lift = ELEVATOR_SOUND_LIFT;
    level.thanks_elevators[TOP_FLOOR_ELEVATOR].sound_clip = ELEVATOR_SOUND_CLIP;
    level.thanks_elevators[TOP_FLOOR_ELEVATOR].sound_music = ELEVATOR_SOUND_MUSIC;
    level.thanks_elevators[TOP_FLOOR_ELEVATOR].sound_ding = ELEVATOR_SOUND_DING;

    //array::thread_all(level.thanks_elevators, &elevator_init);
}

function private main()
{
    thread end_game();

    // TODO: remove ?
}

function private end_game()
{
    level waittill("end_game");

    // TODO: remove ?
}
