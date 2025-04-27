// Master switch (for animated switch prefab) by Vertasea

#using scripts\codescripts\struct; 
#using scripts\shared\util_shared; 
#using scripts\shared\flag_shared; 
#using scripts\shared\exploder_shared; 
#using scripts\shared\scene_shared; 
#using scripts\zm\_zm_audio; 

#namespace zm_animated_switch;

function MasterSwitchInit()
{
    trig = GetEnt("use_master_switch", "targetname");
    trig SetCursorHint("HINT_NOICON");
    trig UseTriggerRequireLookAt();
    trig SetHintString(&"ZOMBIE_ELECTRIC_SWITCH");
    trig waittill("trigger", player);

    if(isdefined(player))
    {
        // This is for VOX- Player who turns on power will say a "power on" voice line
        player zm_audio::create_and_play_dialog("general", "power_on"); 
    }

    // Power turned on sound
    trig PlaySound("zmb_switch_flip"); 

    // This is the power switch scene/scriptbundel being played
    // Not threading so it flips fully before power turns on
    level scene::play("p7_fxanim_zm_power_switch_bundle");

    // Turn on power switch spot lights
    exploder::exploder("master_switch_lgt_meter"); 

    level flag::set("power_on");
    util::wait_network_frame();
    util::clientNotify("ZPO"); // Zombie Power On
    util::wait_network_frame();
    trig Delete(); // Deleting the trigger

    // level util::set_lighting_state(0); // Can change light state

    spark_fx = struct::get("master_switch_fx", "targetname");
    forward = AnglesToForward(spark_fx.origin);
    PlayFX(level._effect["switch_sparks"], spark_fx.origin, forward);

    exploder::exploder("master_switch_lgt_green"); // Turn on power switch green light

    // This will play music after a delay once power is on like in the Giant.
    // level util::delay(19, undefined, &zm_audio::sndMusicSystem_PlayState, "power_on");
}