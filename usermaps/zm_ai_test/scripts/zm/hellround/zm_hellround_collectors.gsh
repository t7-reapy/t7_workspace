#define HRCOLL_CLIENT_FIELD "zm_hellround_collectors"
#define HRCOLL_DISABLED 0

#define HRCOLL_SKULLS array("hellround_skull_01", "hellround_skull_02", "hellround_skull_03")
#define HRCOLL_SKULLS_FLOAT_DELTA 8.0
#define HRCOLL_SKULLS_FLOAT_TIME 4.0
#define HRCOLL_RINGS array("hellround_ring_01", "hellround_ring_02", "hellround_ring_03")
#define HRCOLL_RING_FLOAT_DELTA 4.0
#define HRCOLL_RING_FLOAT_TIME 2.0
#define HRCOLL_RING_ROTATE_TIME 3.0
#define HRCOLL_FX_SPAWN_DELAY 2.5
#define HRCOLL_FX_DEPART_DELAY 2.6

#define HRCOLL_CLIPS array("hellround_collector_01_clip", "hellround_collector_02_clip", "hellround_collector_03_clip")
#define HRCOLL_MODELS array("hellround_collector_01_model", "hellround_collector_02_model", "hellround_collector_03_model")
#define HRCOLL_VOLUMES array("hellround_collector_01_volume", "hellround_collector_02_volume", "hellround_collector_03_volume")
#define HRCOLL_EXPLODERS array("hellround_collector_01_exploder", "hellround_collector_02_exploder", "hellround_collector_03_exploder")
#define HRCOLL_EXPLODERS_DEPART array("hellround_collector_01_depart_exploder", "hellround_collector_02_depart_exploder", "hellround_collector_03_depart_exploder")

#define HRCOLL_TOTAL_SOULS 2
#define HRCOLL_TOTAL_SOULS_PER_PLAYER 2
#define HRCOLL_SPAWN_DELAY 3.0
#define HRCOLL_SOUL_TRAVEL_SPEED 150
#define HRCOLL_SOUL_MAX_DISTANCE 500
#define HRCOLL_LOS_REQUIRED true

#define HRCOLL_FX_TRAIL "_reapy/fx_hellround_collector_soul_trail"
#define HRCOLL_FX_COLLECT "_reapy/fx_hellround_collector_soul_collect"

#define HRCOLL_SND_IDLE_LOOP "hr_collector_idle"
#define HRCOLL_SND_SOUL_SPAWN "hr_soul_spawn"
#define HRCOLL_SND_SOUL_TRAVEL "hr_soul_travel"
#define HRCOLL_SND_SOUL_ENTER "hr_soul_enter"
#define HRCOLL_SND_COMPLETED "hr_collector_completed"

// Delay applied before notifying the game that collection was completed by players
#define HRCOLL_DELAY_BEFORE_COMPLETION 1.0
