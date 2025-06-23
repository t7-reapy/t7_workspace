#define DEBUG_HELLROUNDS 1
#define PRINT_DEBUG_HR(__str) if(DEBUG_HELLROUNDS) IPrintLnBold(__str) // Note: don't use comas in __str

#define KILL_HELLROUND_WATCHERS_NOTIFICATION "kill_hellround_watchers"

// Flag and notification definitions for bad version of Hellrounds
#define HELLROUND_BAD_FLAG_TRIGGER "power_on"
#define HELLROUND_BAD_FLAG "hellround_bad_version"
#define HELLROUND_BAD_FLAG_INDEX 4

// Flag and notification definitions for good version Hellrounds
#define HELLROUND_FLAGS array("hellround_cerberus", "hellround_iteration_1", "hellround_iteration_2", "hellround_iteration_3", HELLROUND_BAD_FLAG)
