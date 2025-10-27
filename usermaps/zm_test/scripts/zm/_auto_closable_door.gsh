#define DEBUG_DOORS 1
#define PRINT_DOOR_DEBUG(__str) if(DEBUG_DOORS) IPrintLnBold(__str) // Note: don't use comas in __str

#define DEFAULT_DOOR_OPEN_TIME 1.0
#define DELAY_BEFORE_DOOR_AUTOCLOSE 5.0
