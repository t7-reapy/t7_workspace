#using scripts\codescripts\struct; 
#using scripts\shared\clientfield_shared; 
#using scripts\shared\util_shared; 
#using scripts\shared\system_shared; 

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

// Used when meteor is interacted with by the player
#using scripts\zm\hellround\zm_hellround_environment;

#insert scripts\zm\hellround\zm_hellround_shared.gsh;
#insert scripts\zm\hellround\zm_hellround_meteor.gsh;
#namespace zm_hellround_meteor;

REGISTER_SYSTEM("zm_hellround_meteor", &init, undefined)

function init() 
{
    level.hellround_meteor_volumes = FindVolumeDecalIndexArray("hellround_meteor_volume");
    thread setup_meteor_shaky_sounds();

    MAKE_ARRAY(level.hellround_meteor_volumes);

    clientfield::register("world", HRMETEOR_CLIENT_FIELD, VERSION_SHIP, 2, "int", &hellround_meteor, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT);
}

function hellround_meteor(n_client_num, _oldVal, n_new_val, _bNewEnt, _bInitialSnap, _fieldName, _bWasTimeJump)
{
    util::waitforclient(n_client_num);

    switch(n_new_val)
    {
        case HRMETEOR_CLIENT_FIELD_DISABLE:
            thread show_meteor_volumes(false);
            break;
        case HRMETEOR_CLIENT_FIELD_FALLDOWN:
            waitrealtime(HRMETEOR_TIME_BEFORE_SIRENS);
            thread play_sirens_sound(n_client_num);
            waitrealtime(HRMETEOR_TIME_BEFORE_METEORS);
            thread play_meteor_sounds(n_client_num);
            waitrealtime(HRMETEOR_EXPLODER_TIME);
            thread show_meteor_volumes(true);
            break;
        case HRMETEOR_CLIENT_FIELD_FALLDOWN_SKIP:
            thread play_meteor_sounds(n_client_num, true);
            thread show_meteor_volumes(true);
            break;
        case HRMETEOR_CLIENT_FIELD_TRIGGER:
            thread zm_hellround_environment::play_transition_fx(n_client_num);
            thread zm_hellround_environment::play_transition_sounds(n_client_num);
            thread zm_hellround_environment::fog_update(false);
            break;
        default:
            PRINT_HR_DEBUG("unexpected call to meteor client field with value: " + n_new_val);
            break;
    }

}

/* region volumes */

function private show_meteor_volumes(b_show)
{
    if(b_show)
    {
        foreach(volume in level.hellround_meteor_volumes)
        {
            UnhideVolumeDecal(volume);
        }
    }
    else
    {
        foreach(volume in level.hellround_meteor_volumes)
        {
            HideVolumeDecal(volume);
        }
    }
}

/* endregion */
/* region sounds */

function private play_sirens_sound(n_client_num)
{
    if (!IsSplitScreen() || IsSplitScreenHost(n_client_num))
    {
        player = GetLocalPlayer(n_client_num);
        player PlaySound(n_client_num, HRMETEOR_SND_METEOR_SIREN);
    }
}

function private play_meteor_sounds(n_client_num, skip_meteor_falldown = false)
{
    if (!skip_meteor_falldown)
    {
        timings = HRMETEOR_EXPLODER_IMPACT_TIMINGS;
        foreach(timing in timings)
        {
            thread play_shaking_sounds(timing);
        }
        waitrealtime(HRMETEOR_EXPLODER_TIME);
    }

    level notify(HRMETEOR_SND_RAIN_ON_FIRE);
}

function private play_shaking_sounds(delay)
{
    waitrealtime(delay);
    PRINT_HR_DEBUG("Notification sent for shaky sounds");
    level notify(HRMETEOR_SND_METEOR_SHAKE);
}

// Inspired from audio_shared.csc:startSoundLoops()
function private setup_meteor_shaky_sounds()
{
    shaky_sound_structs = struct::get_array("meteor_shake", "script_label");
    
    if(!isdefined(shaky_sound_structs) || shaky_sound_structs.size <= 0)
    {
        return;
    }

    foreach(struct in shaky_sound_structs)
    {
        struct thread sound_struct_think();
        WAIT_CLIENT_FRAME;
    }
}

function sound_struct_think() // self == struct
{
    if(!isdefined(self.script_sound))
    {
        return;
    } 
    
    if(!isdefined(self.origin))
    {
        return;
    }

    notify_name = self.script_string;
    if(isdefined(notify_name))
    {
        while(true)
        {
            level waittill(notify_name);
            PlaySound(0, self.script_sound, self.origin);
        }
    }
}

/* endregion */
