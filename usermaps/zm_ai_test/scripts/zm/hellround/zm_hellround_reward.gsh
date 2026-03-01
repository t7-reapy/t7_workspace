#define HELLROUND_HIGHTIER_REWARD "TODO: give_all_perks"
#define HELLROUND_REWARDS array("full_ammo", "full_ammo", "full_ammo", "empty_bottle", "empty_bottle", "empty_bottle")

#define HRRWRD_FINISH_MAP_WEAPON_CAMO_INDEX 4
#define HRRWRD_SURVIVE_BAD_PATH_WEAPON_CAMO_INDEX 5
#define HRRWRD_FINISHED_MAP_AND_SURVIVED_BAD_PATH_WEAPON "t8_maddox_rfb"
#define HRRWRD_LOSESTREAK_THRESHOLDS array(3, 5, 7)
#define HRRWRD_LOSESTREAK_1_REWARD 1000 // Points
#define HRRWRD_LOSESTREAK_2_REWARD "iw8_50gs" // Weapon 
#define HRRWRD_LOSESTREAK_3_REWARD "specialty_fastreload" // Perk 

#define HRRWRD_DATA_INDEX 402
#define HRRWRD_DATA_HAS_FINISHED_MAP_MASK 16 // Bit 4 (0-based) indicates if the player has finished the map at least once
#define HRRWRD_DATA_HAS_SURVIVED_BAD_PATH_MASK 32 // Bit 5 (0-based) indicates if the player has survived the bad path at least once
#define HRRWRD_DATA_LOSESTREAK_MASK 15 // Bits 0-3 (0-based) store the current lose streak count, allowing for a maximum of 15
