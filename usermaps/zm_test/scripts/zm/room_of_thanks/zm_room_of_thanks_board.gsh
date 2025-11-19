#define DEBUG_BOARDS 0
#define PRINT_BOARD_DEBUG(__str) if(DEBUG_BOARDS) IPrintLnBold(__str) // Note: don't use comas in __str

#define CLIENTFIELD_BOARDS_SOUND_AND_SUBTITLE "cf_zm_room_of_thanks_board"

#define ENT_BOARD_CODE_MISSING "rot_board_empty"
#define ENT_BOARD_CODE_PRESENT "rot_board_with_code"
#define ENT_TRIGGER_CODE_DISPLAY "rot_board_code_display"

#define VIDEO_TRIGGER_PLAY_LOCALIZED "ROOM_OF_THANKS_PLAY"
#define VIDEO_TRIGGER_STOP_LOCALIZED "ROOM_OF_THANKS_STOP"

#define VIDEO_CANCEL_SECRET_DISPLAY_NOTIFY "rot_stop_secret_display"
#define VIDEO_CANCEL_SUBTITLES_NOTIFY "rot_stop_subtitles_display"
#define VIDEO_TRIGGER_NAME "rot_video_trigger"
#define VIDEO_CONTROLLER_TRIGGER_NAME "rot_video_controller"
#define VIDEO_NAME "room_of_thanks_video"
#define VIDEO_SOUND_NAME "room_of_thanks_video_sound"
#define VIDEO_SOUND_STRUCT "room_of_thanks_video_sound"
#define VIDEO_SUBTITLE_FILE "subtitles/room_of_thanks.csv"
#define VIDEO_SUBTITLE_FADEIN_TIME 0.5
#define VIDEO_SUBTITLE_FADEOUT_TIME 1.5
#define VIDEO_SUBTITLE_MOVE_TIME 0.5
#define VIDEO_SUBTITLE_MOVE_DISTANCE -15

#define CODE_LOOKUP_TABLE "secrets/keys.csv"
#define CODE_LOOKUP_TABLE_KEY_NAME "BoardSecretKey"
#define CODE_SHOWUP_DELAY_BEFORE 27.0
#define CODE_SHOWUP_FADING_TIME 1.5
