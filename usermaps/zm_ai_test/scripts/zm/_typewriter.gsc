#using scripts\shared\system_shared;

#insert scripts\zm\_zm_utility.gsh;
#insert scripts\zm\_zm.gsh;
#insert scripts\shared\shared.gsh;

// #insert scripts\zm\_typewriter.gsh;
#namespace typewriter;

REGISTER_SYSTEM("typewriter", &init, undefined)

class TypeWritterSettings 
{
    var typing_frequency_milliseconds;
    var typing_decay_duration_milliseconds;
    var delay_before_decaying_out_milliseconds;

    var typing_frequency_milliseconds_for_client;
    var typing_decay_duration_milliseconds_for_client;
    var delay_before_decaying_out_milliseconds_for_client;
}

function private init()
{
    level.typewriter = new TypeWritterSettings();
    level.typewriter.typing_frequency_milliseconds = 75;
    level.typewriter.typing_decay_duration_milliseconds = 3000;
    level.typewriter.delay_before_decaying_out_milliseconds = 3000;

    level.typewriter.typing_frequency_milliseconds_for_client = Int(level.typewriter.typing_frequency_milliseconds / 2);
    level.typewriter.typing_decay_duration_milliseconds_for_client = Int(level.typewriter.typing_decay_duration_milliseconds / 2);
    level.typewriter.delay_before_decaying_out_milliseconds_for_client = level.typewriter.delay_before_decaying_out_milliseconds;
}

function type(...)
{
    intro_hud = [];
    str_text = vararg;

    for (i = 0; i < str_text.size; i++)
    {
        intro_hud[i] = NewHudElem();
        intro_hud[i].x = 20;
        intro_hud[i].y = -150 + (10 * i);
        intro_hud[i].fontscale = (IsSplitScreen() ? 2.00 : 1.00);
        intro_hud[i].alignx = "LEFT";
        intro_hud[i].aligny = "BOTTOM";
        intro_hud[i].horzalign = "LEFT";
        intro_hud[i].vertalign = "BOTTOM";
        intro_hud[i].color = (1.0, 1.0, 1.0);
        intro_hud[i].alpha = 1;
        intro_hud[i].sort = 0;
        intro_hud[i].foreground = true;
        intro_hud[i].hidewheninmenu = true;
        intro_hud[i].archived = false;
        intro_hud[i].showplayerteamhudelemtospectator = true;
        intro_hud[i] SetText(str_text[i]);
        intro_hud[i] SetTypewriterFX(
            level.typewriter.typing_frequency_milliseconds, 
            (level.typewriter.delay_before_decaying_out_milliseconds + level.typewriter.typing_decay_duration_milliseconds * str_text.size) - (level.typewriter.typing_decay_duration_milliseconds * i), 
            level.typewriter.typing_decay_duration_milliseconds);

        wait level.typewriter.typing_decay_duration_milliseconds / 1000;
    }

    wait (level.typewriter.delay_before_decaying_out_milliseconds + level.typewriter.typing_decay_duration_milliseconds * str_text.size) / 1000;

    foreach (hudelem in intro_hud)
    {
		hudelem Destroy();
    }
}

function type_for_player(player, messages)
{
    hud = [];
    str_text = messages;

    for (i = 0; i < str_text.size; i++)
    {
        hud[i] = NewClientHudElem(player);
        hud[i].x = 20;
        hud[i].y = -110 + (10 * i);
        hud[i].fontscale = (IsSplitScreen() ? 2.00 : 1.00);
        hud[i].alignx = "LEFT";
        hud[i].aligny = "BOTTOM";
        hud[i].horzalign = "LEFT";
        hud[i].vertalign = "BOTTOM";
        hud[i].color = (1.0, 1.0, 1.0);
        hud[i].alpha = 1;
        hud[i].sort = 0;
        hud[i].foreground = true;
        hud[i].hidewheninmenu = true;
        hud[i].archived = false;
        hud[i].showplayerteamhudelemtospectator = true;
        hud[i] SetText(str_text[i]);
        hud[i] SetTypewriterFX(
            level.typewriter.typing_frequency_milliseconds_for_client, 
            (level.typewriter.delay_before_decaying_out_milliseconds_for_client + level.typewriter.typing_decay_duration_milliseconds_for_client * str_text.size) - (level.typewriter.typing_decay_duration_milliseconds_for_client * i), 
            level.typewriter.typing_decay_duration_milliseconds_for_client);

        wait level.typewriter.typing_decay_duration_milliseconds_for_client / 1000;
    }

    wait (level.typewriter.delay_before_decaying_out_milliseconds_for_client + level.typewriter.typing_decay_duration_milliseconds_for_client * str_text.size) / 1000;

    foreach (hudelem in hud)
    {
		hudelem Destroy();
    }
}