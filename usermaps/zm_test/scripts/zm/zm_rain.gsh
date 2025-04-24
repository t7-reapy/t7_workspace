// Rain constants
#define SHOULD_START_WITH_RAIN true

#define FX_RAIN_LIGHT "custom/env/fx_rain_player_z_light"
#define FX_RAIN_REGULAR "custom/env/fx_rain_player_z_regular"
#define FX_RAIN_HEAVY "custom/env/fx_rain_player_z_heavy"

#define FX_RAIN_TOGGLE "fx_rain_toggle"
#define DECAL_RAIN_TOGGLE "decal_rain_toggle"

// Thunder constants
#define SHOULD_START_WITH_THUNDER true
#define MIN_WAIT_BETWEEN_STRIKES 10
#define MAX_WAIT_BETWEEN_STRIKES 45
// Close strikes
#define LIGHTSTATE_THUNDER_MISSING 0
#define LIGHTSTATE_THUNDER_STRIKES array(1, 2)
#define THUNDER_CLOSE_SOUNDS array("thunder_close", "thunder_snap", "lightning_strike_lrg_00", "lightning_strike_lrg_01", "lightning_strike_lrg_02", "lightning_strike_lrg_03")
#define THUNDER_CLOSE_STRIKE_CHANCE_PERCENT 15
// Distant strikes
#define THUNDER_DISTANT_DELAY 2.5 // in seconds
#define THUNDER_DISTANT_EXPLODERS array("thunder_north_1", "thunder_north_2", "thunder_north_3", "thunder_south_1", "thunder_south_2", "thunder_south_3")
#define THUNDER_DISTANT_SOUNDS array("amb_thunder_clap_00", "amb_thunder_clap_01", "amb_thunder_clap_03", "amb_thunder_clap_04", "amb_thunder_clap_05", "thunder_low_dist_00", "thunder_low_dist_01", "thunder_low_dist_02", "thunder_low_dist_03", "thunder_low_dist_04", "thunder_low_dist_05", "dist_thunder_00", "dist_thunder_01", "dist_thunder_02", "dist_thunder_03")
