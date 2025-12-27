#define DEBUG_WEAPON_HOLDER 0
#define PRINT_WH_DEBUG(__str) if(DEBUG_WEAPON_HOLDER) IPrintLnBold(__str) // Note: don't use comas in __str

#define WEAPON_HOLDER_PRICE_SET "1500"
#define WEAPON_HOLDER_PRICE_GET "1500"
#define WEAPON_HOLDER_PRICE_SWAP "3000"
#define WEAPON_HOLDER_LOCALIZE_SET "WEAPON_HOLDER_DEPOSIT"
#define WEAPON_HOLDER_LOCALIZE_GET "WEAPON_HOLDER_WITHDRAW"
#define WEAPON_HOLDER_LOCALIZE_SWAP "WEAPON_HOLDER_SWAP"

#define WEAPON_HOLDER_EXPLODER "weapon_holder_exploder"
#define WEAPON_HOLDER_SOUND_START "weapon_holder_deposit"
#define WEAPON_HOLDER_SOUND_STOP "weapon_holder_withdraw"
#define WEAPON_HOLDER_SOUND_LOOP "weapon_holder_loop"
