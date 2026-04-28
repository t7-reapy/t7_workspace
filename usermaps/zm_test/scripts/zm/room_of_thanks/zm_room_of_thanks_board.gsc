#using scripts\shared\clientfield_shared; 
#using scripts\shared\callbacks_shared; 
#using scripts\shared\array_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;

#insert scripts\zm\_zm_utility.gsh;
#insert scripts\zm\_zm.gsh;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\room_of_thanks\zm_room_of_thanks_board.gsh;
#namespace zm_room_of_thanks_board;

#precache("triggerstring", VIDEO_TRIGGER_PLAY_LOCALIZED);
#precache("triggerstring", VIDEO_TRIGGER_STOP_LOCALIZED);

REGISTER_SYSTEM_EX("zm_room_of_thanks_board", &init, &main, undefined)

class ThanksBoard {
    var board_code_missing_model;
    var board_code_present_model;
    
    var video_trigger;
    var video_controller_trigger;
    var code_display_trigger;
    var subtitle_hud_element;
    
    var secret_code_unlocked;
}

/* region init & main */

function private init()
{
    clientfield::register("world", CLIENTFIELD_BOARDS_SOUND_AND_SUBTITLE, VERSION_SHIP, 1, "int");

    level.thanks_board = new ThanksBoard();

    level.thanks_board.board_code_missing_model = GetEnt(ENT_BOARD_CODE_MISSING, "targetname");
    level.thanks_board.board_code_present_model = GetEnt(ENT_BOARD_CODE_PRESENT, "targetname");

    level.thanks_board.video_trigger = GetEnt(VIDEO_TRIGGER_NAME, "targetname");
    level.thanks_board.video_controller_trigger = GetEnt(VIDEO_CONTROLLER_TRIGGER_NAME, "targetname");
    level.thanks_board.code_display_trigger = GetEnt(ENT_TRIGGER_CODE_DISPLAY, "targetname");
    level.thanks_board.subtitle_hud_element = undefined;
    
    level.thanks_board.secret_code_unlocked = false;
}

function private main()
{
    thread end_game();

    level.thanks_board.board_code_present_model Hide();
    level.thanks_board.video_trigger thread video_trigger_think();
    level.thanks_board.video_controller_trigger video_controller_trigger_think();

    if (DEBUG_BOARDS) 
    {
        thread modvar_debug_board();
    }

    VideoPrime(VIDEO_NAME);
}

function private end_game()
{
    level waittill("end_game");
    
    thread stop_video();
}

/* endregion */
/* region main logic */


function private play_video()
{
    // Secret timed display
    level.thanks_board thread delayed_board_model_udpate();
    level.thanks_board.code_display_trigger thread code_showup_trigger_think();

    // Video
    VideoStart(VIDEO_NAME, false);

    // Audio
    level clientfield::set(CLIENTFIELD_BOARDS_SOUND_AND_SUBTITLE, true);

    // Subtitles
    thread print_video_subtitles();
}

function stop_video()
{
    PRINT_BOARD_DEBUG("STOP VIDEO");

    // Secret timed display
    if (!level.thanks_board.secret_code_unlocked)
    {
        level notify(VIDEO_CANCEL_SECRET_DISPLAY_NOTIFY);
    }

    // Video
    VideoStop(VIDEO_NAME);

    // Audio
    level clientfield::set(CLIENTFIELD_BOARDS_SOUND_AND_SUBTITLE, false);

    // Subtitles
    level notify(VIDEO_CANCEL_SUBTITLES_NOTIFY);
    if (isdefined(level.thanks_board.subtitle_hud_element))
    {
        level.thanks_board.subtitle_hud_element thread push_away_subtitle();
    }
}

function private video_trigger_think() // self == trigger
{
    level endon("end_game");

    self waittill("trigger");
    PRINT_BOARD_DEBUG("player stepped into the trigger once");
    thread play_video();
}

function private video_controller_trigger_think() // self == trigger
{
    level endon("end_game");
    self SetCursorHint("HINT_NOICON");

    while(true)
    {
        self SetHintString(&VIDEO_TRIGGER_STOP_LOCALIZED);
        self util::waittill_any("trigger", VIDEO_ENDED_NOTIFY);
        PRINT_BOARD_DEBUG("video stop");
        thread stop_video();

        self SetHintString(&VIDEO_TRIGGER_PLAY_LOCALIZED);
        self waittill("trigger");
        PRINT_BOARD_DEBUG("video play");
        thread play_video();
    }
}

function private delayed_board_model_udpate() // self == thanks_board
{
    level endon("end_game");
    level endon(VIDEO_CANCEL_SECRET_DISPLAY_NOTIFY);

    if (!self.secret_code_unlocked)
    {
        wait CODE_SHOWUP_DELAY_BEFORE;
    }
    self.secret_code_unlocked = true;
    self.board_code_missing_model Hide();
    self.board_code_present_model Show();
}

function private code_showup_trigger_think() // self == trigger
{
    level endon("end_game");
    level endon(VIDEO_CANCEL_SECRET_DISPLAY_NOTIFY);
    
    ensure_hud_elements_created();
    while (!level.thanks_board.secret_code_unlocked)
    {
        WAIT_SERVER_FRAME;
    }

    while(true)
    {
        WAIT_SERVER_FRAME;
        self waittill("trigger", who);

        if (IsPlayer(who))
        {
            who thread display_secret_code(self);
            who thread hide_secret_code(self);
        }
    }
}

/* endregion */
/* region HUD */

function private ensure_hud_elements_created()
{
    foreach (player in GetPlayers())
    {
        if (isdefined(player.secret_hud_element))
        {
            continue;
        }

        player.secret_hud_element = player create_hidden_hud_element("center", "middle", "center", "middle", 0, 0, 3.0, (1.0, 1.0, 1.0));
    }
}

function private create_hidden_hud_element(alignX, alignY, horzAlign, vertAlign, xOffset, yOffset, fontScale, color) // self == undefined or player
{
    hud_elem = (IsPlayer(self) ? NewClientHudElem(self) : NewHudElem());
    hud_elem.alignX = alignX;
    hud_elem.alignY = alignY;
    hud_elem.horzAlign = horzAlign;
    hud_elem.vertAlign = vertAlign;
    hud_elem.x += xOffset;
    hud_elem.y += yOffset;
    hud_elem.foreground = true;
    hud_elem.fontScale = fontScale;
    hud_elem.alpha = 0; // hidden by default
    hud_elem.color = color;
    hud_elem.hidewheninmenu = true;        
    
    return hud_elem;
}

/* endregion */
/* region methods */

function private display_secret_code(trigger) // self == player
{
    PRINT_BOARD_DEBUG("displaying secret code!");
    secret_code = self get_secret_code();
    self fadein_secret_in_hud(secret_code);
}

function private get_secret_code() // self == player
{
    if (isdefined(self.secret_code))
    {
        return self.secret_code;
    }
    secret_key = Int(TableLookup(CODE_LOOKUP_TABLE, 0, "BoardSecretKey", 1));
    total_hour_since_unix = Int(Floor(GetUTC() / 3600));
    steam_sub_xuid = Int(GetSubStr("" + self GetXuid(true), 11));
    secret_code = "" + ((total_hour_since_unix ^ steam_sub_xuid) ^ secret_key);
    while (secret_code.size < 6)
    {
        secret_code = "0" + secret_code;
    }
    self.secret_code = secret_code;
    return self.secret_code;
}

function private fadein_secret_in_hud(secret_code) // self == player
{
    self.secret_hud_element SetText(secret_code);
    self.secret_hud_element FadeOverTime(CODE_SHOWUP_FADING_TIME);
    self.secret_hud_element.alpha = 1;
}

function private hide_secret_code(trigger) // self == player
{
    if (IS_TRUE(self.waiting_to_get_away_from_board))
    {
        return;
    }
    self.waiting_to_get_away_from_board = true;
    trigger wait_for_player_exits(self);
    self.waiting_to_get_away_from_board = false;
    self fadeout_secret_in_hud();
}

function private wait_for_player_exits(player) // self == trigger
{
    level endon("end_game");

    PRINT_BOARD_DEBUG("waiting for player exit ...");
    while (player IsTouching(self))
    {
        WAIT_SERVER_FRAME;
    }

    PRINT_BOARD_DEBUG("player exited code trigger");
}

function private fadeout_secret_in_hud() // self == player
{
    self.secret_hud_element FadeOverTime(CODE_SHOWUP_FADING_TIME);
    self.secret_hud_element.alpha = 0;
}

/* endregion */
/* region subtitles */

function private print_video_subtitles()
{
    level endon(VIDEO_CANCEL_SUBTITLES_NOTIFY);

    PRINT_BOARD_DEBUG("playing subtitles");
    subtitle_index = 0;
    level.thanks_board.subtitle_hud_element = undefined;

    while (true)
    {        
        subtitle = TableLookup(VIDEO_SUBTITLE_FILE, 0, subtitle_index, 1);
        duration = Float(TableLookup(VIDEO_SUBTITLE_FILE, 0, subtitle_index, 2));
        subtitle_index++;

        if (isdefined(level.thanks_board.subtitle_hud_element))
        {
            level.thanks_board.subtitle_hud_element thread push_away_subtitle();
            level.thanks_board.subtitle_hud_element = undefined;
        }

        if (!isdefined(subtitle) || subtitle == "")
        {
            break;
        }

        level.thanks_board.subtitle_hud_element = print_subtitle(subtitle);
        waitrealtime(duration);
    }

    level.thanks_board.video_controller_trigger notify(VIDEO_ENDED_NOTIFY);
}

function private push_away_subtitle() // self == hud element
{
    hud_element = self;
    hud_element FadeOverTime(VIDEO_SUBTITLE_FADEOUT_TIME);
    hud_element MoveOverTime(VIDEO_SUBTITLE_MOVE_TIME);
    hud_element.alpha = 0;
    hud_element.y += VIDEO_SUBTITLE_MOVE_DISTANCE;
    wait VIDEO_SUBTITLE_FADEOUT_TIME;
    hud_element Destroy();
}

function private print_subtitle(subtitle)
{
    hud_element = create_hidden_hud_element("center", "bottom", "center", "bottom", 0, -55, 1.00, (1.0, 1.0, 1.0));
    hud_element SetText(subtitle);
    hud_element FadeOverTime(VIDEO_SUBTITLE_FADEIN_TIME);
    hud_element MoveOverTime(VIDEO_SUBTITLE_MOVE_TIME);
    hud_element.alpha = 1;
    hud_element.y += VIDEO_SUBTITLE_MOVE_DISTANCE;

    return hud_element;
}

/* endregion */
/* region debug */

function private modvar_debug_board()
{
    ModVar("rotboard", "");

    while(true)
    {
        WAIT_SERVER_FRAME;

        dvar_value = GetDvarString("rotboard", "");

        if(!isdefined(dvar_value) || dvar_value == "")
        {
            continue;
        }
        ModVar("rotboard", "");

        switch(Int(dvar_value))
        {
            default:
                PRINT_BOARD_DEBUG("Unsupported");
                break;
        }
    }
}

/* endregion */