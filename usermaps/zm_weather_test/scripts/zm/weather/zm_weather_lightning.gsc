
#insert scripts\shared\shared.gsh;

#insert scripts\zm\weather\zm_weather_shared.gsh;
#insert scripts\zm\weather\zm_weather_lightning.gsh;
#namespace zm_weather_lightning;

function init() {

}

function run()
{
    level endon(KILL_LIGHTNING_NOTIFICATION);

    while(true)
    {
        lightning_strike();

        WAIT_SERVER_FRAME;
    }
}

function lightning_strike() {
    // TODO: play SFXs 
    // TODO: play FXs

    wait 3;
    WEATHER_PRINT_DEBUG("Lightning strike");
}