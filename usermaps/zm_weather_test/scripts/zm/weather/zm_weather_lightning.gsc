#using scripts\shared\exploder_shared; 
#using scripts\shared\flag_shared; 

#insert scripts\shared\shared.gsh;

#insert scripts\zm\weather\zm_weather_shared.gsh;
#insert scripts\zm\weather\zm_weather_lightning.gsh;

#namespace zm_weather_lightning;

class Lightning {
    var min_wait;
    var max_wait;

    var exploders;
    var sounds;
}

function init() {
    level.weather.lightning = default_lightning_state();
}

function run()
{
    while(level flag::get(ACTIVE_LIGHTNING_FLAG))
    {
        level.weather.lightning lightning_strike();
        WAIT_SERVER_FRAME;
    }

    // striking stopped, let's restore defaults.
    level.weather.lightning = default_lightning_state();
}

function pause()
{
    
}

function private default_lightning_state() 
{
    lightning = new Lightning();
    lightning.min_wait = DEFAULT_MIN_WAIT_LIGHTNING;
    lightning.max_wait = DEFAULT_MAX_WAIT_LIGHTNING;
    lightning.exploders = LIGHTNING_EXPLODERS;
    lightning.sounds = LIGHTNING_SOUNDS;

    return lightning;
}

function greater_intensity()
{
    level.weather.lightning.min_wait /= HIGH_FREQUENCY_FACTOR_LIGHTNING;
    level.weather.lightning.max_wait /= HIGH_FREQUENCY_FACTOR_LIGHTNING;
}

function lesser_intensity()
{
    level.weather.lightning.min_wait *= HIGH_FREQUENCY_FACTOR_LIGHTNING;
    level.weather.lightning.max_wait *= HIGH_FREQUENCY_FACTOR_LIGHTNING;
}

function private lightning_strike() 
{
    // self = Lightning (level.weather.lightning)

    wait RandomFloatRange(self.min_wait, self.max_wait);
    
    if (!level flag::get(ACTIVE_LIGHTNING_FLAG))
    {
        WEATHER_PRINT_DEBUG("lightning strike canceled");
        return;
    }

    // TODO: play FXs with level.weather.lightning.effects

    lightning_sound = self.sounds[RandomIntRange(0, self.sounds.size)];
    lightning_exploder = self.exploders[RandomIntRange(0, self.exploders.size)];
    lightning_effect = undefined; //self.effects[RandomIntRange(0, self.effects.size)];

    WEATHER_PRINT_DEBUG("lightning strike !");
    exploder::exploder(lightning_exploder);
    // Strike is distant, so the sound takes time to come to player's ears
    delay = RandomFloatRange(LIGHTNING_SOUND_DELAY/2, LIGHTNING_SOUND_DELAY);
    wait delay;
    PlaySoundAtPosition(lightning_sound, (0, 0, 0));
    wait (LIGHTNING_SOUND_DELAY - delay);
    exploder::exploder_stop(lightning_exploder);
}