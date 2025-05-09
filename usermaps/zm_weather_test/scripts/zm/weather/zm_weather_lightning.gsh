#define LIGHTNING_EXPLODER_CF_NAME "lightning_exploder_cf"

#define LIGHTNING_INTENSITY_OFF 0
#define LIGHTNING_INTENSITY_LOW 1
#define LIGHTNING_INTENSITY_MED 2
#define LIGHTNING_INTENSITY_HIG 3
#define LIGHTNING_INTENSITY_DEFAULT LIGHTNING_INTENSITY_LOW

// 3 seconds is roughly equivalent to 1 KM distance
#define LIGHTNING_SOUND_DISTANCE array(0, 5.0, 4.0, 3.0)
#define LIGHTNING_BASE_MIN_WAIT array(10000, 30.0, 20.0, 15.0)
#define LIGHTNING_BASE_MAX_WAIT array(10001, 40.0, 30.0, 25.0)

#define LIGHTNING_EXPLODERS_TIME 0.818
#define LIGHTNING_EXPLODERS array("thunder_north_1", "thunder_north_2", "thunder_north_3", "thunder_south_1", "thunder_south_2", "thunder_south_3")
#define LIGHTNING_SOUNDS array("", "amb_lightning_low", "amb_lightning_medium", "amb_lightning_high")
