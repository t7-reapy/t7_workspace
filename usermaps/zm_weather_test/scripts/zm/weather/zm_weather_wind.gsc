#insert scripts\shared\shared.gsh;

#insert scripts\zm\weather\zm_weather_shared.gsh;
#insert scripts\zm\weather\zm_weather_wind.gsh;

#namespace zm_weather_wind;

function init() {

}

function run()
{
    while(true)
    {
        wind_blow(undefined);

        WAIT_SERVER_FRAME;
    }
}

function pause()
{

}

function wind_blow(direction) {   
    // TODO: use API to toss around some objects for wind blows
    // Like: PhysicsLaunch, PhysicsJetThrust, PhysicsExplosionCylinder, ...
    // TODO: play wind SFXs 
    // TODO: play wind FXs
}

function greater_intensity() 
{

}

function lesser_intensity() 
{

}