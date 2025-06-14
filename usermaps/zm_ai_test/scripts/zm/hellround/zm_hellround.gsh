#define DEBUG_HELL_ROUNDS 0
#define PRINT_DEBUG_HR(__str) if(DEBUG_HELL_ROUNDS) IPrintLnBold(__str) // Note: don't use comas in __str

// Flags and notification
#define HELL_ROUND_TRIGGER_FLAG "power_on"
#define HELL_ROUND_FLAG "hell_round"
#define HELL_ROUND_MINOR_FLAG "hell_round_minor"
#define HELL_ROUND_ABOLISHED_FLAG "hell_rounds_abolished"
#define KILL_HELL_ROUND_WATCHERS_NOTIFICATION "kill_hell_round_watchers"