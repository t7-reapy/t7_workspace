#using scripts\zm\_zm_utility;
#using scripts\shared\flag_shared; 
#using scripts\shared\callbacks_shared; 
#using scripts\shared\util_shared; 
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\room_of_thanks\zm_room_of_thanks_elevator;

#insert scripts\zm\room_of_thanks\zm_room_of_thanks.gsh;

#namespace zm_room_of_thanks;

#precache("triggerstring", ROTSND_TRIGGER_LOCALIZED);

REGISTER_SYSTEM("zm_room_of_thanks", &init, undefined)

function private init()
{
    clientfield::register("world", ROTSND_CLIENTFIELD, VERSION_SHIP, 1, "int");

    sound_trigger = GetEnt(ROTSND_TRIGGER_TARGETNAME, "targetname");
    sound_trigger setup_sound_trigger();
}

function private setup_sound_trigger() // self == trigger
{
    self SetHintString(&ROTSND_TRIGGER_LOCALIZED);

    while (true)
    {
        level clientfield::set(ROTSND_CLIENTFIELD, false);
        self waittill("trigger", player);
        self SetHintString("");
        level clientfield::set(ROTSND_CLIENTFIELD, true);
        
        waitrealtime(ROTSND_SOUND_TRIGGER_DELAY);
        self SetHintString(&ROTSND_TRIGGER_LOCALIZED);
    }
}