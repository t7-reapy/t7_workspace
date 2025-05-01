
#insert scripts\shared\shared.gsh;

#insert scripts\zm\weather\zm_weather_shared.gsh;
#insert scripts\zm\weather\zm_weather_rain.gsh;
#namespace zm_weather_rain;

function init() {

}

function run()
{
    level endon(KILL_RAIN_NOTIFICATION);

    while(true)
    {
        rain();

        WAIT_SERVER_FRAME;
    }
}

function rain() {
    // TODO: play SFXs 
    // TODO: play FXs
}