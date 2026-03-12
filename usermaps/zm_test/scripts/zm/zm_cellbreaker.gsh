#define DEBUG_CELLBREAKER 0
#define PRINT_CB_DEBUG(__str) if(DEBUG_CELLBREAKER) IPrintLnBold(__str) // Note: don't use comas in __str

#define HELMET_HEALTH 50
#define BRUTUS_HEALTH 2500
#define BERSERK_TIME 10
#define GAS_DROP_INTERVAL 20 //secs to next drop
#define BARRICADE_BREAK_INTERVAL 10 //secs to next break
#define DROP_GAS_ANYWHERE 1 //0 to only drop on specific spots 
#define GAS_SPOT_ATTRACT_DISTANCE 1000 //also barricades

#define AUTOSPAWN 0
#define FIRST_SPAWN_ROUND 2 //not 1
#define SPAWN_ROUND_INTERVAL 1
#define HEALTH_PER_ROUND 1000
#define MAX_HEALTH 3000
#define DUAL_SPAWN_ROUND 3
