#using scripts\shared\array_shared; 
/*
    Scripter: Vertasea (with evolutions from Reapy)
    Panning End Game Camera 
*/

#using scripts\codescripts\struct;

#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\lui_shared;

#insert scripts\shared\shared.gsh;

#namespace gameover_camera;
REGISTER_SYSTEM("gameover_camera", &_init, undefined)

/* region settings */

// I would recommend localizing strings
#define CUSTOM_GAME_OVER_TEXT "GAME OVER"
#define CUSTOM_GAME_OVER_TEXT_COLOR_GOOD GREEN
#define CUSTOM_GAME_OVER_TEXT_COLOR_NEUTRAL ORANGE
#define CUSTOM_GAME_OVER_TEXT_COLOR_BAD RED
#define ROUNDS_SURVIVED_TEXT_COLOR WHITE

#define DEFAULT_INTERMISSION_SPEED 8.0
#define INTERMISSION_TRANSITIONS 3
#define LASTSTAND_EXTRA_DURATION 2.5 // in order to give some time for death animations in _zm_t6_deathanim.gsc

/* endregion */

function private _init()
{
    level.custom_game_over_hud_elem = &custom_game_over_hud;
}

function custom_game_over_hud(player, game_over_hud, survived_hud)
{
    level.custom_intermission =&custom_intermission;

    game_over_hud.alignX = "center";
    game_over_hud.alignY = "middle";
    game_over_hud.horzAlign = "center";
    game_over_hud.vertAlign = "middle";
    game_over_hud.y -= 130;
    game_over_hud.foreground = true;
    game_over_hud.fontScale = 3;
    game_over_hud.alpha = 0;
    game_over_hud.color = get_game_over_color();
    game_over_hud.hidewheninmenu = true;
    game_over_hud SetText(CUSTOM_GAME_OVER_TEXT);

    game_over_hud FadeOverTime(1);
    game_over_hud.alpha = 1;
    if (player isSplitScreen())
    {
        game_over_hud.fontScale = 2;
        game_over_hud.y += 40;
    }

    survived_hud.alignX = "center";
    survived_hud.alignY = "middle";
    survived_hud.horzAlign = "center";
    survived_hud.vertAlign = "middle";
    survived_hud.y -= 100;
    survived_hud.foreground = true;
    survived_hud.fontScale = 2;
    survived_hud.alpha = 0;
    survived_hud.color = (ROUNDS_SURVIVED_TEXT_COLOR);
    survived_hud.hidewheninmenu = true;
    if (player isSplitScreen())
    {
        survived_hud.fontScale = 1.5;
        survived_hud.y += 40;
    }
}

function private get_game_over_color()
{
    if (IsFunctionPtr(level.custom_game_over_hud_elem_color_function))
    {
        return [[ level.custom_game_over_hud_elem_color_function ]]();
    }

    return CUSTOM_GAME_OVER_TEXT_COLOR_BAD;
}

function custom_intermission()
{
    intermissions = [];
    index = 0;
    while (true)
    {
        source = struct::get("intermission_" + index);
        if (!isdefined(source))
        {
            break;
        }

        destination = struct::get(source.target);
        focus_point = struct::get(destination.target);
        camera_position_ent = util::spawn_model("tag_origin", source.origin, source.angles);

        intermissions[index] = array(source, destination, focus_point, camera_position_ent);
        index++;
    }

    intermissions = array::randomize(intermissions);
    foreach (intermission in intermissions)
    {
        speed = DEFAULT_INTERMISSION_SPEED;
        if (IsDefined(destination.script_transition_time))
        {
            speed = destination.script_transition_time;
        }

        thread specific_custom_intermission(intermission, speed);
        // Wait a little bit less because we want to switch camera position before end of trajectory
        wait (speed - 1.0); 
    }
}

function specific_custom_intermission(intermission, speed)
{
    destination = intermission[1];
    focus_point = intermission[2];
    camera_position_ent = intermission[3];

    players = GetPlayers();

    foreach (player in players)
    {
        player thread end_game_player_setup();
    }

    wait(1.0 + LASTSTAND_EXTRA_DURATION);

    foreach (player in players)
    {
        // We move the player so if intermission is outside, we still see outside FXs normally.
        player thread move_progressively(camera_position_ent.origin, destination.origin, speed);
        player StartCameraTween(0.1);
        player CameraActivate(true);
        player CameraSetPosition(camera_position_ent);
        player CameraSetLookAt(focus_point.origin);
    }

    camera_position_ent MoveTo(destination.origin, speed);
    camera_position_ent RotateTo(destination.angles, speed);
    wait(speed);
    camera_position_ent Delete();
}

function end_game_player_setup()
{
    self FreezeControls(true);
    wait(0.5 + LASTSTAND_EXTRA_DURATION);
    self thread lui::screen_flash( 0.5, 1.25, 0.5, 1, "black" );
    self setClientUIVisibilityFlag( "hud_visible", 0 );
    wait(0.5);
    self Ghost();
}

function private move_progressively(source, destination, time, steps = 20.0) // self == player
{
    offset = (destination - source) / steps;
    delay = time/steps;
    for (step = 0; step < steps - 1; step++)
    {
        location = source + (offset * step);
        self SetOrigin(location);
        wait delay;
    }
}