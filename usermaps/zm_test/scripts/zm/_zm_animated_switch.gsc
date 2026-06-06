// Master switch (for animated switch prefab) by Vertasea

#using scripts\codescripts\struct; 
#using scripts\shared\util_shared; 
#using scripts\shared\flag_shared; 
#using scripts\shared\exploder_shared; 
#using scripts\shared\scene_shared; 
#using scripts\zm\_zm_audio; 

// In order to fix power switch lag when toggled ON.
#precache("triggerstring", "ZOMBIE_NEED_POWER");
#precache("triggerstring", "ZOMBIE_ELECTRIC_SWITCH");
#precache("triggerstring", "ZOMBIE_ELECTRIC_SWITCH_OFF");
#precache("triggerstring", "ZOMBIE_PERK_QUICKREVIVE", "500");
#precache("triggerstring", "ZOMBIE_PERK_QUICKREVIVE", "1500");
#precache("triggerstring", "ZOMBIE_PERK_FASTRELOAD", "3000");
#precache("triggerstring", "ZOMBIE_PERK_DOUBLETAP", "2000");
#precache("triggerstring", "ZOMBIE_PERK_JUGGERNAUT", "2500");
#precache("triggerstring", "ZOMBIE_PERK_MARATHON", "2000");
#precache("triggerstring", "ZOMBIE_PERK_DEADSHOT", "1500");
#precache("triggerstring", "ZOMBIE_PERK_WIDOWSWINE", "3000");
#precache("triggerstring", "ZOMBIE_PERK_ADDITIONALPRIMARYWEAPON", "4000");
#precache("triggerstring", "ZOMBIE_PERK_PACKAPUNCH", "5000");
#precache("triggerstring", "ZOMBIE_PERK_PACKAPUNCH", "1000");
#precache("triggerstring", "ZOMBIE_PERK_PACKAPUNCH_AAT", "2500");
#precache("triggerstring", "ZOMBIE_PERK_PACKAPUNCH_AAT", "500");
#precache("triggerstring", "ZOMBIE_RANDOM_WEAPON_COST", "950");
#precache("triggerstring", "ZOMBIE_RANDOM_WEAPON_COST", "10");
#precache("triggerstring", "ZOMBIE_UNDEFINED");

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