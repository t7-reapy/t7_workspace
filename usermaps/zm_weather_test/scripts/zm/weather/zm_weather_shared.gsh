#define WEATHER_DEBUG 1
#define WEATHER_PRINT_DEBUG(__str) if (WEATHER_DEBUG) IPrintLnBold(__str)

#define WEATHER_ASSERT_INIT Assert(isdefined(level.weather), "zm_weather was not initialized, call zm_weather::init()")
#define WEATHER_LIGHTNING_ASSERT_INIT Assert(isdefined(level.weather.lightning), "zm_weather_lightning was not initialized, call zm_weather_lightning::init()")
#define WEATHER_RAIN_ASSERT_INIT Assert(isdefined(level.weather.rain), "zm_weather_rain was not initialized, call zm_weather_rain::init()")
#define WEATHER_THUNDER_ASSERT_INIT Assert(isdefined(level.weather.thunder), "zm_weather_thunder was not initialized, call zm_weather_thunder::init()")
#define WEATHER_WIND_ASSERT_INIT Assert(isdefined(level.weather.wind), "zm_weather_wind was not initialized, call zm_weather_wind::init()")

#define KILL_WEATHER_METEO_MANAGER "kill_weather_meteo_manager"
#define KILL_LIGHTNING_NOTIFICATION "kill_lightning_notification"
#define KILL_RAIN_NOTIFICATION "kill_rain_notification"
#define KILL_THUNDER_NOTIFICATION "kill_thunder_notification"
#define KILL_WIND_NOTIFICATION "kill_wind_notification"

#define ACTIVE_LIGHTNING_FLAG "active_lightning_flag"
#define ACTIVE_RAIN_FLAG "active_rain_flag"
#define ACTIVE_THUNDER_FLAG "active_thunder_flag"
#define ACTIVE_WIND_FLAG "active_wind_flag"
