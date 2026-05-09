#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\demo_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\util_shared;
#using scripts\shared\lui_shared;
#using scripts\shared\animation_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\hud_util_shared;
#using scripts\shared\hud_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\system_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\flagsys_shared;
#using scripts\shared\aat_shared;

#insert scripts\shared\duplicaterender.gsh;
#using scripts\shared\duplicaterender_mgr;

#using scripts\shared\ai\zombie_death;
#using scripts\shared\ai\zombie_shared;
#using scripts\shared\ai\systems\gib;
#using scripts\shared\ai\zombie_utility;

#using scripts\zm\_zm_powerup_nuke;
#using scripts\zm\_util;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_behavior;
#using scripts\zm\_zm_behavior_utility;
#using scripts\zm\_zm_blockers;
#using scripts\zm\_zm_bgb;
#using scripts\zm\_zm_equipment;
#using scripts\zm\_zm_laststand;
#using scripts\zm\_zm_net;
#using scripts\zm\_zm_pers_upgrades;
#using scripts\zm\_zm_pers_upgrades_functions;
#using scripts\zm\_zm_perk_additionalprimaryweapon;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_puppet;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_zonemgr;
#using scripts\shared\ai\zombie_utility;
#using scripts\zm\_zm_ai_dogs;
#using scripts\zm\_zm_unitrigger;

#insert scripts\zm\_zm_utility.gsh;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\shared\ai\zombie.gsh;
#insert scripts\shared\ai\systems\gib.gsh;
#insert scripts\zm\_zm.gsh;
#insert scripts\zm\_zm_perks.gsh;

#using scripts\Sphynx\commands\_zm_name_checker;

#using scripts\zm\craftables\_zm_craftables;

#define INIT_DEV_COMMANDS true // NEEDED TO HAVE COMMANDS -- Can stay on TRUE if you use XUID or Username -- FOR FULL

#define DEV_ONLY_COMMANDS false
#define DEV_ONLY_USERNAME_ARRAY array( "", "" ) // Change this to your own steam playername -- MAKE SURE XUID IS EMPTY IF YOU USE USERNAME!! -- KEEP EMPTY IF XUID -- CAN ADD SEVERAL (ARRAY USAGE)
#define DEV_ONLY_XUID_ARRAY array( "", "" ) // Change this to your own XUID -- KEEP EMPTY FOR ONLY USERNAME -- CAN ADD SEVERAL (ARRAY USAGE)

#define VERSION "1.09 - By Sphynx"

#namespace zm_commands;

REGISTER_SYSTEM( "zm_commandsgui", &__init__, undefined )

function __init__()
{
    //Version check
    ModVar("versionCommands", VERSION);

    if(ToLower( GetDvarString( "mapname" ) ) != "zm_castle") {
        //Debug Model Outline
        clientfield::register( "scriptmover", "debug_enable_keyline", VERSION_SHIP, 1, "int" );

        //Debug Zombie Outlines
        clientfield::register( "actor", "debug_zombie_enable_keyline", VERSION_SHIP, 1, "int" );
    }
    
    util::registerClientSys( "subtitleMessage" );

    if(!IS_TRUE(INIT_DEV_COMMANDS)){
        break;
    }

    if(IS_TRUE(DEV_ONLY_COMMANDS)){
        if(!array::contains( DEV_ONLY_USERNAME_ARRAY, GetPlayers()[0].name ) && DEV_ONLY_USERNAME_ARRAY[0] != "")
            break;
        if(!array::contains( DEV_ONLY_XUID_ARRAY, GetPlayers()[0] GetXUID() ) && DEV_ONLY_XUID_ARRAY[0] != "")
            break;
    }

    SetDvar("sv_cheats", 1);

    clientfield::register("world", "fog_cf_update", VERSION_SHIP, 2, "int");

    thread _get_xuid_command_response(); // Gets the player XUID and their playername
    thread _give_weapon_command_response(); //Give weapon (better give) -- OR USE /give random for a random weapon or /give random_up
    thread _points_command_response(); // Give points to player
    thread _spawn_dog_command_response(); //  spawn a specified number of dogs
    thread _spawn_zombie_command_response(); //  spawn a specified number of zombies
    thread _powerup_command_response(); // Spawn powerups where the player is looking
    thread _upgrade_weapon_command_response(); // Upgrade current weapon
    thread _downgrade_weapon_command_response(); // downgrade current weapon
    thread _change_round_command_response(); // Change round to value
    thread _next_round_command_response(); // Change round to Next Round
    thread _previous_round_command_response(); // Change round to Previous Round
    thread _dog_round_command_response(); //Next round will be a dog round
    thread _give_perk_command_response(); // Give perks to players
    thread _take_perk_command_response(); // Take perks from players
    thread _revive_command_response(); //Revive player
    thread _ignore_command_response(); //Make player ignored by zombies
    thread _power_command_response(); //Turn power on or off
    thread _infinite_ammo_command_response(); //turn on infinite ammo on player
    thread _change_camo_command_response(); //Change camo on current weapon
    thread _change_lighting_command_response(); //Change light state
    thread _change_fog_command_response(); //Change fog state
    thread _open_doors_command_response(); //Open all doors
    thread _godmode_command_response(); //Give godmode to player
    thread _spawning_command_response(); // Turn on/off spawning
    thread _difficulty_command_response(); //Change difficulty from easy (1) to hard (4)
    thread _notify_command_response(); //notify a level or specific target
    thread _flag_command_response(); //Enable/disable flag on level or specific target
    thread _alias_command_response(); //Play an alias sound (non looping)
    thread _stop_alias_command_response(); //Play an alias sound (looping)
    thread _get_coords_command_response(); //Get the origin and angles of where the player is standing
    thread _teleport_zombies_command_response(); //Teleports zombies to player
    thread _give_bgb_command_response(); //gives the player BGB!

    if( ToLower( GetDvarString( "mapname" ) ) != "zm_castle" ){
        thread _debug_keyline_command_response(); //Add keylines around a specific model to look for it easier
        thread _show_zombies_command_response(); //Shows all zombies through walls - Gives Death Perception
    }

    // FUN CHEATS
    thread _aimbot_command_response(); //Enabled aimbot for player
}

/*###############################################################*/
/*##                    COMMAND RESPONSES                      ##*/
/*###############################################################*/

function private _get_xuid_command_response(command_args)
{
    ModVar("getxuid", "");

    for(;;){
        WAIT_SERVER_FRAME

        dvar_value = ToLower(GetDvarString("getxuid", ""));

        if(isdefined(dvar_value) && dvar_value != "")
        {
            ModVar("getxuid", "");

            tokenized = StrTok(dvar_value, " ");
            if(tokenized.size > 1){
                player_index = Int(tokenized[0]);
                value = Int(tokenized[1]);

                print_subtitle(level.players[player_index], "^5Dev: Checked XUID of " + level.players[player_index].playername);

                if(player_index >= 0 && player_index <= 7){
                    IPrintLnBold("Checked XUID of player " + level.players[player_index].playername + " | XUID: " + level.players[player_index] GetXUID(true));
                }else{
                    foreach(player in GetPlayers()){
                        IPrintLnBold("Checked XUID of player " + player + " | XUID: " + player GetXUID(true));
                    }
                }
            }else{
                value = Int(tokenized[0]);

                foreach(player in GetPlayers()){
                    IPrintLnBold("Checked XUID of player " + player.playername + " | XUID: " + player GetXUID(true));
                }

                print_subtitle(undefined, "^5Dev: Checked XUID of everyone");
            }
        }
    }
}

function private _points_command_response(command_args)
{
    ModVar("points", "");

    for(;;){
        WAIT_SERVER_FRAME

        dvar_value = ToLower(GetDvarString("points", ""));

        if(isdefined(dvar_value) && dvar_value != "")
        {
            ModVar("points", "");

            tokenized = StrTok(dvar_value, " ");
            if(tokenized.size > 1){
                player_index = Int(tokenized[0]);
                value = Int(tokenized[1]);

                print_subtitle(level.players[player_index], "^5Dev: added " + value + " points to " + level.players[player_index].playername);

                if(player_index >= 0 && player_index <= 7){
                    level.players[player_index] zm_score::add_to_player_score( value );
                    zm_utility::play_sound_at_pos( "purchase", level.players[player_index].origin );
                }else{
                    foreach(player in GetPlayers()){
                        player zm_score::add_to_player_score( value );
                        zm_utility::play_sound_at_pos( "purchase", player.origin );
                    }
                }
            }else{
                value = Int(tokenized[0]);

                foreach(player in GetPlayers()){
                    player zm_score::add_to_player_score( value );
                    zm_utility::play_sound_at_pos( "purchase", player.origin );
                }

                print_subtitle(undefined, "^5Dev: added " + value + " points to all players");
            }
        }
    }
}

function private _give_weapon_command_response(command_args)
{
    ModVar("give", "");

    for(;;){
        WAIT_SERVER_FRAME;

        dvar_value = ToLower(GetDvarString("give", ""));

        if(isdefined(dvar_value) && dvar_value != "")
        {
            ModVar("give", "");

            tokenized = StrTok(dvar_value, " ");
            if(tokenized.size > 1){
                player_index = Int(tokenized[0]);
                weapon_name = tokenized[1];

                print_subtitle(level.players[player_index], "^5Dev: Weapon " + weapon_name + " given to " + level.players[player_index].playername);

                if(weapon_name == "ammo"){
                    if(player_index >= 0 && player_index <= 7){
                        level.players[player_index] thread _player_max_ammo();
                    }else{
                        foreach(player in GetPlayers()){
                            player thread _player_max_ammo();
                        }
                    }
                }else if(weapon_name == "random"){
                    if(player_index >= 0 && player_index <= 7){
                        level.players[player_index] zm_weapons::weapon_give( array::random( GetArrayKeys( level.zombie_weapons ) ), false, false, true, true );
                    }else{
                        foreach(player in GetPlayers()){
                            player zm_weapons::weapon_give( array::random( GetArrayKeys( level.zombie_weapons ) ), false, false, true, true );
                        }
                    }
                }else if(weapon_name == "random_up"){
                    if(player_index >= 0 && player_index <= 7){
                        level.players[player_index] zm_weapons::weapon_give( array::random( GetArrayKeys( level.zombie_weapons_upgraded ) ), false, false, true, true );
                    }else{
                        foreach(player in GetPlayers()){
                            player zm_weapons::weapon_give( array::random( GetArrayKeys( level.zombie_weapons ) ), false, false, true, true );
                        }
                    }
                }else{
                    if(player_index >= 0 && player_index <= 7){
                        level.players[player_index] zm_weapons::weapon_give( GetWeapon(weapon_name), false, false, true, true );
                    }else{
                        foreach(player in GetPlayers()){
                            player zm_weapons::weapon_give( GetWeapon(weapon_name), false, false, true, true );
                        }
                    }
                }
            }else{
                weapon_name = tokenized[0];

                if(weapon_name == "ammo"){
                    array::thread_all( GetPlayers(), &_player_max_ammo);
                }else if(weapon_name == "random"){
                    foreach(player in GetPlayers()){
                        player zm_weapons::weapon_give( array::random( GetArrayKeys( level.zombie_weapons ) ), false, false, true, true );
                    }
                }else if(weapon_name == "random_up"){
                    foreach(player in GetPlayers()){
                        player zm_weapons::weapon_give( array::random( GetArrayKeys( level.zombie_weapons_upgraded ) ), false, false, true, true );
                    }
                }else{
                    foreach(player in GetPlayers()){
                        player zm_weapons::weapon_give( GetWeapon(weapon_name), false, false, true, true );
                    }
                }

                print_subtitle(undefined, "^5Dev: given " + weapon_name + " weapon to all players");
            }
        }
    }
}

function private _player_max_ammo(){
    weapons_list = self GetWeaponsList(true);
    foreach(weapon in weapons_list){
        if ( weapon != level.weaponNone )
        {
            self SetWeaponOverheating( 0,0 );
            max = weapon.maxAmmo;
            if (isdefined(max))
            {
                self SetWeaponAmmoStock( weapon, max );
            }
            
            if ( isdefined( self zm_utility::get_player_tactical_grenade() ) )
            {
                self GiveMaxAmmo( self zm_utility::get_player_tactical_grenade() );
            }
            if ( isdefined( self zm_utility::get_player_lethal_grenade() ) )
            {
                self GiveMaxAmmo( self zm_utility::get_player_lethal_grenade() );
            }
        }
    }
}

function private _give_bgb_command_response(command_args)
{
    ModVar("bgb", "");

    for(;;)
    {
        WAIT_SERVER_FRAME

        dvar_value = ToLower(GetDvarString("bgb", ""));

        if(isdefined(dvar_value) && dvar_value != "")
        {
            ModVar("bgb", "");

            tokenized = StrTok(dvar_value, " ");
            
            pre_gum_name = ToLower(tokenized[0]);
            gum_name = "";
            if(pre_gum_name == "random")
            {
                rand_keys = array::randomize(getarraykeys(level.bgb));
                gum_name = rand_keys[0];
            }
            else
            {
                gum_name = "zm_bgb_" + pre_gum_name;
            }

            keys = getarraykeys(level.bgb);
            if( array::contains( keys, gum_name ) )
            {
                if(tokenized.size > 1)
                {
                    player_index = Int(tokenized[1]);
                    if( isdefined(level.players[player_index]) )
                    {
                        level.players[player_index] thread bgb::give( gum_name );
                    }
                    else
                    {
                        foreach(player in GetPlayers())
                        {
                            player thread bgb::give( gum_name );
                        }
                    }
                    print_subtitle(level.players[player_index], "^5Dev: gave bgb " + gum_name + " to " + level.players[player_index].playername);
                }
                else
                {
                    foreach(player in  GetPlayers())
                    {
                        player thread bgb::give( gum_name );
                    }
                    print_subtitle(undefined, "^5Dev: gave " + gum_name + " points to all players");
                }
            }
            else
            {
                print_subtitle(undefined, "^5Dev: bgb " + gum_name + " not found");
            }
        }
    }
}

function private _ignore_command_response(command_args)
{
    ModVar("ignore", "");

    for(;;){
        WAIT_SERVER_FRAME;

        dvar_value = ToLower(GetDvarString("ignore", ""));

        if(isdefined(dvar_value) && dvar_value != "")
        {
            ModVar("ignore", "");

            player_index = Int(dvar_value);

            print_subtitle(level.players[player_index], "^5Dev: Make player " + level.players[player_index].playername + " ignored");

            if(player_index >= 0 && player_index <= 7){
                level.players[player_index] _player_ignore();
            }else{
                foreach(player in GetPlayers()){
                    player _player_ignore();
                }
            }
        }
    }
}

function private _player_ignore(){

    if(!IS_TRUE(self.ignoreme)){
        self.ignoreme = true;
    }else{
        self.ignoreme = false;
    }

}

function private _infinite_ammo_command_response(){
    ModVar("infinite_ammo", "");

    for(;;){
        WAIT_SERVER_FRAME;

        dvar_value = ToLower(GetDvarString("infinite_ammo", ""));

        if(isdefined(dvar_value) && dvar_value != "")
        {
            ModVar("infinite_ammo", "");

            player_index = Int(dvar_value);

            print_subtitle(level.players[player_index], "^5Dev: Give player " + level.players[player_index].playername + " infinite ammo");

            if(player_index >= 0 && player_index <= 7){
                level.players[player_index] thread _toggle_ammo_infinite();
            }else{
                foreach(player in GetPlayers()){
                    player thread _toggle_ammo_infinite();
                }
            }
        }
    }
}

function _toggle_ammo_infinite()
{
    self notify("toggle_infinite_ammo" + (self GetEntityNumber() + 1));
    self endon("toggle_infinite_ammo" + (self GetEntityNumber() + 1));

    if(!IS_TRUE(self.ammo4evah)){
        self.ammo4evah = true;

        for(;;)
        {
            weapon = self GetCurrentWeapon();
            if ( weapon != level.weaponNone )
            {
                self SetWeaponOverheating( 0,0 );
                max = weapon.maxAmmo;
                if (isdefined(max))
                {
                    self SetWeaponAmmoStock( weapon, max );
                }
                
                if ( isdefined( self zm_utility::get_player_tactical_grenade() ) )
                {
                    self GiveMaxAmmo( self zm_utility::get_player_tactical_grenade() );
                }
                if ( isdefined( self zm_utility::get_player_lethal_grenade() ) )
                {
                    self GiveMaxAmmo( self zm_utility::get_player_lethal_grenade() );
                }
                self SetWeaponAmmoClip(weapon, weapon.clipsize);
            }
            WAIT_SERVER_FRAME
        }
    }else{
        self.ammo4evah = false;
        self notify("toggle_infinite_ammo" + (self GetEntityNumber() + 1));
    }
}

function private _teleport_zombies_command_response(command_args)
{
    ModVar("teleportz", "");

    for(;;){
        WAIT_SERVER_FRAME;

        dvar_value = ToLower(GetDvarString("teleportz", ""));

        if(isdefined(dvar_value) && dvar_value != "")
        {
            ModVar("teleportz", "");

            player_index = Int(dvar_value);

            if(player_index >= 0 && player_index <= 7){
                level.players[player_index] _tele_zombies_command();
                print_subtitle(level.players[player_index], "^5Dev: Teleport zombies to " + level.players[player_index].playername);
            }else{
                print_subtitle(level.players[player_index], "^5Dev: Couldn't teleport zombies to player, please give an index from 0 - 7");
            }
        }
    }
}

function private _tele_zombies_command(){
    player_angles = self GetPlayerAngles();
    forward_vec = AnglesToForward( (0, player_angles[1] + 100, 0) );

    foreach(zombie in GetAITeamArray( "axis" ))
        zombie ForceTeleport( self.origin, forward_vec, 1 );
}

function private _spawning_command_response(command_args)
{
    ModVar("spawning", "");

    for(;;){
        WAIT_SERVER_FRAME;

        dvar_value = ToLower(GetDvarString("spawning", ""));

        if(isdefined(dvar_value) && dvar_value != "")
        {
            ModVar("spawning", "");

            if(dvar_value == "on" || dvar_value == "activate" || dvar_value == "1"){
                level flag::set("spawn_zombies");
                print_subtitle(undefined, " ^5Dev: Turned spawning on");
            }else if(dvar_value == "off" || dvar_value == "deactivate" || dvar_value == "0"){
                level flag::clear("spawn_zombies");
                a_ai_enemies = GetAITeamArray( "axis" );
                foreach( ai_enemy in a_ai_enemies )
                {
                    level.zombie_total++;
                    level.zombie_respawns++;    // Increment total of zombies needing to be respawned
                    
                    ai_enemy Kill();
                }
                print_subtitle(undefined, " ^1Dev: Turned spawning off");
            }
        }
    }
}

function private _godmode_command_response(command_args)
{
    ModVar("godmode", "");

    for(;;){
        WAIT_SERVER_FRAME;

        dvar_value = ToLower(GetDvarString("godmode", ""));

        if(isdefined(dvar_value) && dvar_value != "")
        {
            ModVar("godmode", "");

            tokenized = StrTok(dvar_value, " ");
            if(tokenized.size > 1){
                player_index = Int(tokenized[0]);
                value = tokenized[1];

                print_subtitle(level.players[player_index], "^5Dev: Set godmode to " + value + " for " + level.players[player_index].playername);

                if(player_index >= 0 && player_index <= 7){
                    level.players[player_index] thread _godmode_activate(value);
                }else{
                    array::thread_all(GetPlayers(), &_godmode_activate, value);
                }
            }else{
                value = tokenized[0];

                array::thread_all(GetPlayers(), &_godmode_activate, value);

                //IPrintLn( " ^5Dev: added " + value + " points to all players" );
                //SubtitlePrint( 0, 100, "^5Dev: added " + value + " points to all players" );
                print_subtitle(undefined, "^5Dev: Set godmode to " + value + " to all players");
            }
        }
    }
}

function private _godmode_activate(onoff){
    if(onoff == "on" || onoff == "activate" || onoff == "1"){
        self EnableInvulnerability();
    }else if(onoff == "off" || onoff == "deactivate" || onoff == "0"){
        self DisableInvulnerability();
    }
}

function private _change_camo_command_response(command_args)
{
    ModVar("camo", "");

    for(;;){
        WAIT_SERVER_FRAME;

        dvar_value = ToLower(GetDvarString("camo", ""));

        if(isdefined(dvar_value) && dvar_value != "")
        {
            ModVar("camo", "");

            tokenized = StrTok(dvar_value, " ");
            if(tokenized.size > 1){
                player_index = Int(tokenized[0]);
                value = Int(tokenized[1]);

                print_subtitle(level.players[player_index], "^5Dev: Changed weaponcamo to " + value + " for " + level.players[player_index].playername);

                if(player_index >= 0 && player_index <= 7){
                    level.players[player_index] UpdateWeaponOptions( level.players[player_index] GetCurrentWeapon(), level.players[player_index] CalcWeaponOptions(value, 0, 0) );
                }else{
                    foreach(player in GetPlayers())
                        player UpdateWeaponOptions( player GetCurrentWeapon(), player CalcWeaponOptions(value, 0, 0) );
                }
                //Camo PaP
                level.pack_a_punch_camo_index = value;
            }else{
                value = Int(tokenized[0]);

                foreach(player in GetPlayers()){
                    player UpdateWeaponOptions( player GetCurrentWeapon(), player CalcWeaponOptions(value, 0, 0) );
                }

                //Camo PaP
                level.pack_a_punch_camo_index = value;

                print_subtitle(undefined, "^5Dev: Changed weaponcamo to " + value + " for all players");
            }
        }
    }
}

function _change_lighting_command_response(command_args)
{
    ModVar("lighting", "");

    for(;;){
        WAIT_SERVER_FRAME;

        dvar_value = ToLower(GetDvarString("lighting", ""));

        if(isdefined(dvar_value) && dvar_value != "")
        {
            ModVar("lighting", "");

            level util::set_lighting_state(Int(dvar_value));

            print_subtitle(undefined, "^5Dev: Changed lightingstate to " + dvar_value);        
        }
    }
}

function _change_fog_command_response(command_args)
{
    ModVar("fog", "");

    while(true)
    {
        WAIT_SERVER_FRAME;

        dvar_value = ToLower(GetDvarString("fog", ""));

        if(isdefined(dvar_value) && dvar_value != "")
        {
            ModVar("fog", "");

            level clientfield::set("fog_cf_update", Int(dvar_value));

            print_subtitle(undefined, "^5Dev: Changed fogstate to " + dvar_value);        
        }
    }
}

function private _revive_command_response(command_args)
{
    ModVar("revive", "");

    for(;;){
        WAIT_SERVER_FRAME;

        dvar_value = ToLower(GetDvarString("revive", ""));

        if(isdefined(dvar_value) && dvar_value != "")
        {
            ModVar("revive", "");

            player_index = dvar_value;

            print_subtitle(level.players[player_index], "^5Dev: revived " + level.players[player_index].playername);

            if(player_index >= 0 && player_index <= 7){
                level.players[player_index] thread _revive_player();
            }else{
                array::thread_all( GetPlayers(), &_revive_player ); 
                print_subtitle(undefined, "^5Dev: revived all players");
            }
        }
    }
}

function private _get_coords_command_response(command_args)
{
    ModVar("get_coords", "");

    for(;;){
        WAIT_SERVER_FRAME;

        dvar_value = ToLower(GetDvarString("get_coords", ""));

        if(isdefined(dvar_value) && dvar_value != "")
        {
            ModVar("get_coords", "");

            IPrintLnBold("Origin: " + level.players[0].origin);
            IPrintLnBold("Angles: " + level.players[0].angles);

            //print_subtitle(undefined, " ^5Dev: Spawned " + dvar_value + " dogs");
        }
    }
}

function private _revive_player(){
    self reviveplayer(); 
    self notify( "stop_revive_trigger" );
    if (isdefined(self.revivetrigger) )
    {
        self.revivetrigger delete();
        self.revivetrigger = undefined;
    }
    self AllowJump( true );
    
    self.ignoreme = false;
    self.laststand = undefined;
    self notify("player_revived",self);
}

function private _spawn_dog_command_response(command_args)
{
    ModVar("spawn_dog", "");

    for(;;){
        WAIT_SERVER_FRAME;

        dvar_value = ToLower(GetDvarString("spawn_dog", ""));

        if(isdefined(dvar_value) && dvar_value != "")
        {
            ModVar("spawn_dog", "");

            if( !IsDefined( level.dogs_enabled ) || !level.dogs_enabled )
            {
                print_subtitle(undefined, " ^1Dev: Dogs not enabled in the map");
                continue;
            }

            zm_ai_dogs::special_dog_spawn(Int(dvar_value));
            print_subtitle(undefined, " ^5Dev: Spawned " + dvar_value + " dogs");
        }
    }
}

function private _spawn_zombie_command_response(command_args)
{
    ModVar("spawn_zombie", "");

    for(;;){
        WAIT_SERVER_FRAME;

        dvar_value = ToLower(GetDvarString("spawn_zombie", ""));

        if(isdefined(dvar_value) && dvar_value != "")
        {
            ModVar("spawn_zombie", "");

            level thread _spawn_zombies_command_func(dvar_value);

            print_subtitle(undefined, " ^5Dev: Spawned " + dvar_value + " zombies");
        }
    }
}

function private _spawn_zombies_command_func(dvar_value){
    count = 0;
    while ( count < dvar_value )
    {
        count++;
        spawner = array::random( level.zombie_spawners );
        zombie = zombie_utility::spawn_zombie( spawner );
        wait( level.zombie_vars["zombie_spawn_delay"] );
    }
}

function private _power_command_response(command_args)
{
    ModVar("power", "");

    for(;;){
        WAIT_SERVER_FRAME;

        dvar_value = ToLower(GetDvarString("power", ""));

        if(isdefined(dvar_value) && dvar_value != "")
        {
            ModVar("power", "");

            if(dvar_value == "on" || dvar_value == "activate" || dvar_value == "1"){
                level flag::clear( "power_off" );
                level flag::set("power_on");
                print_subtitle(undefined, " ^5Dev: power turned on");
            }else if(dvar_value == "off" || dvar_value == "deactivate" || dvar_value == "0"){
                level flag::clear( "power_on" );
                level flag::set("power_off");
                level clientfield::set("zombie_power_off", 0);
                level notify("power_off" );
                print_subtitle(undefined, " ^1Dev: power turned off");
            }
        }
    }
}

function private _show_zombies_command_response(command_args)
{
    ModVar("show_zombies", "");

    for(;;){
        WAIT_SERVER_FRAME;

        dvar_value = ToLower(GetDvarString("show_zombies", ""));

        if(isdefined(dvar_value) && dvar_value != "")
        {
            ModVar("show_zombies", "");

            if(dvar_value == "on" || dvar_value == "activate" || dvar_value == "1"){
                GetPlayers()[0] thread _show_zombie_outlines_func(true);
                print_subtitle(undefined, " ^5Dev: Show zombies outline through walls");
            }else if(dvar_value == "off" || dvar_value == "deactivate" || dvar_value == "0"){
                GetPlayers()[0] thread _show_zombie_outlines_func(false);
                print_subtitle(undefined, " ^5Dev: Hide zombies outline through walls");
            }        
        }
    }
}

function private _show_zombie_outlines_func(activate){

    self notify("end_zombie_outlining" + (self GetEntityNumber() + 1));
    self endon("end_zombie_outlining" + (self GetEntityNumber() + 1));

    if(IS_TRUE(activate)){
        for(;;){
            foreach(zombie in GetAITeamArray( level.zombie_team )){
                zombie clientfield::set( "debug_zombie_enable_keyline", 1 );
                zombie thread _check_for_outline_death();
            }
            wait 2;
        }
    }

    foreach(zombie in GetAITeamArray( level.zombie_team )){
        zombie clientfield::set( "debug_zombie_enable_keyline", 0 );
    }
}

function private _check_for_outline_death(){

    self util::waittill_any_return( "death" );

    self clientfield::set( "debug_zombie_enable_keyline", 0 );

}

function private _debug_keyline_command_response(command_args)
{
    ModVar("outline", "");

    for(;;){
        WAIT_SERVER_FRAME;

        dvar_value = ToLower(GetDvarString("outline", ""));

        if(isdefined(dvar_value) && dvar_value != "")
        {
            ModVar("outline", "");

            tokenized = StrTok(dvar_value, " ");
            if(tokenized.size > 2){
                type = tokenized[0];
                model_list = tokenized[1];
                value = tokenized[2];

                if(dvar_value == "on" || dvar_value == "activate" || dvar_value == "1"){
                    if(type == "struct"){
                        foreach( struct in struct::get_array(model_list) )
                        {
                            struct.model clientfield::set( "debug_enable_keyline", 1 );
                        }
                    }else{
                        foreach( model in GetEntArray(model_list, "targetname") )
                        {
                            model clientfield::set( "debug_enable_keyline", 1 );
                        }
                    }
                    print_subtitle(undefined, " ^5Dev: Turned outline on for models: " + model_list);
                }else if(dvar_value == "off" || dvar_value == "deactivate" || dvar_value == "0"){
                    if(type == "struct"){
                        foreach( struct in struct::get_array(model_list) )
                        {
                            struct.model clientfield::set( "debug_enable_keyline", 0 );
                        }
                    }else{
                        foreach( model in GetEntArray(model_list, "targetname") )
                        {
                            model clientfield::set( "debug_enable_keyline", 0 );
                        }
                    }
                    print_subtitle(undefined, " ^1Dev: Turned outline off for models: " + model_list);
                }
            }else{
                print_subtitle(undefined, " ^1Dev: Please provide information!: /outline type models on");
            }

            
        }
    }
}

function private _give_perk_command_response(command_args)
{
    ModVar("perk", "");

    for(;;){
        WAIT_SERVER_FRAME;

        dvar_value = ToLower(GetDvarString("perk", ""));

        if(isdefined(dvar_value) && dvar_value != "")
        {
            ModVar("perk", "");

            tokenized = StrTok(dvar_value, " ");
            if(tokenized.size > 1){
                player_index = Int(tokenized[0]);

                perk = zm_name_checker::get_perk_name(tokenized[1]);

                print_subtitle(level.players[player_index], "^5Dev: added " + tokenized[1] + " perk to " + level.players[player_index].playername);

                if(player_index >= 0 && player_index <= 7){
                    level.players[player_index] _give_perk( perk );
                }else{
                    array::thread_all( GetPlayers(), &_give_perk, perk ); 
                }
            }else{
                array::thread_all( GetPlayers(), &_give_perk, zm_name_checker::get_perk_name(tokenized[0]) ); 

                print_subtitle(undefined, "^5Dev: added " + tokenized[0] + " perk to all players");
            }
        }
    }
}

function private _take_perk_command_response(command_args)
{
    ModVar("take_perk", "");

    for(;;){
        WAIT_SERVER_FRAME;

        dvar_value = ToLower(GetDvarString("take_perk", ""));

        if(isdefined(dvar_value) && dvar_value != "")
        {
            ModVar("take_perk", "");

            tokenized = StrTok(dvar_value, " ");
            if(tokenized.size > 1){
                player_index = Int(tokenized[0]);
                value = tokenized[1];

                perk = zm_name_checker::get_perk_name(value);

                print_subtitle(level.players[player_index], "^5Dev: taken " + perk + " perk from " + level.players[player_index].playername);

                if(player_index >= 0 && player_index <= 7){
                    level.players[player_index] _take_perk( perk );
                }else{
                    array::thread_all( GetPlayers(), &_take_perk, perk ); 
                }
            }else{
                array::thread_all( GetPlayers(), &_take_perk, tokenized[0] );

                print_subtitle(undefined, "^5Dev: taken " + tokenized[0] + " perk from all players");
            }
        }
    }
}

function private _next_round_command_response(command_args)
{
    ModVar("next_round", "");

    for(;;){
        WAIT_SERVER_FRAME;

        dvar_value = ToLower(GetDvarString("next_round", ""));

        if(isdefined(dvar_value) && dvar_value != "")
        {
            ModVar("next_round", "");

            thread _goto_round( level.round_number + 1 );
            print_subtitle(undefined, " ^5Dev: Next round");
        }
    }
}

function private _previous_round_command_response(command_args)
{
    ModVar("previous_round", "");

    for(;;){
        WAIT_SERVER_FRAME;

        dvar_value = ToLower(GetDvarString("previous_round", ""));

        if(isdefined(dvar_value) && dvar_value != "")
        {
            ModVar("previous_round", "");

            thread _goto_round( level.round_number - 1 );
            print_subtitle(undefined, " ^5Dev: Previous round");
        }
    }
}

function private _change_round_command_response(command_args)
{
    ModVar("round", "");

    for(;;){
        WAIT_SERVER_FRAME;

        dvar_value = ToLower(GetDvarString("round", ""));

        if(isdefined(dvar_value) && dvar_value != "")
        {
            ModVar("round", "");

            round = Int(dvar_value);

            thread _goto_round( round );
            print_subtitle(undefined, " ^5Dev: Changed round to " + round);
        }
    }
}

function private _dog_round_command_response(command_args)
{
    ModVar("doground", "");

    for(;;){
        WAIT_SERVER_FRAME;

        dvar_value = ToLower(GetDvarString("doground", ""));

        if(isdefined(dvar_value) && dvar_value != "")
        {
            ModVar("doground", "");

            switch(dvar_value){
                case "on":
                case "1":
                case "activate":
                    thread _goto_round( level.next_dog_round);
                    print_subtitle(undefined, " ^5Dev: Changed round to Dog Round");
                    break;
            }
        }
    }
}

function private _powerup_command_response(command_args)
{
    ModVar("powerup", "");

    for(;;){
        WAIT_SERVER_FRAME;

        dvar_value = ToLower(GetDvarString("powerup", ""));

        if(isdefined(dvar_value) && dvar_value != "")
        {
            ModVar("powerup", "");

            tokenized = StrTok(dvar_value, " ");
            if(tokenized.size > 1){
                player_index = Int(tokenized[0]);
                powerup_name = tokenized[1];

                powerup = zm_name_checker::get_powerup_name(powerup_name);

                if(powerup != "all"){
                    for ( i = 0; i < level.zombie_powerup_array.size; i++ )
                    {
                        if ( level.zombie_powerup_array[i] == powerup )
                        {
                            level.zombie_powerup_index = i;
                            found = true;
                            break;
                        }
                    } 
                }else{
                    found = true;
                }

                if ( !found )
                {
                    print_subtitle(undefined, " ^1Dev: Powerup: " + powerup + " does not exist!");
                    continue;
                }

                print_subtitle(level.players[player_index], " ^5Dev: Spawned " + powerup + " powerup to " + level.players[player_index].playername);

                if(player_index >= 0 && player_index <= 7){
                    origin = level.players[player_index] _get_eye_location();
                    if(powerup == "all"){level.players[player_index] _spawn_all_powerups();}else{
                        level thread zm_powerups::specific_powerup_drop(powerup, origin, undefined, undefined, undefined, undefined, false );
                    }
                }else{
                    foreach(player in GetPlayers()){
                        origin = player _get_eye_location();
                        if(powerup == "all"){player _spawn_all_powerups();}else{
                            level thread zm_powerups::specific_powerup_drop(powerup, origin, undefined, undefined, undefined, undefined, false );
                        }
                    }
                }
            }else{
                powerup = zm_name_checker::get_powerup_name(tokenized[0]);

                if(powerup != "all"){
                    for ( i = 0; i < level.zombie_powerup_array.size; i++ )
                    {
                        if ( level.zombie_powerup_array[i] == powerup )
                        {
                            level.zombie_powerup_index = i;
                            found = true;
                            break;
                        }
                    } 
                }else{
                    found = true;
                }

                if ( !found )
                {
                    print_subtitle(undefined, " ^1Dev: Powerup: " + powerup + " does not exist!");
                    continue;
                }

                foreach(player in GetPlayers()){
                    origin = player _get_eye_location();
                    if(powerup == "all"){player _spawn_all_powerups();}else{
                        level thread zm_powerups::specific_powerup_drop(powerup, origin, undefined, undefined, undefined, undefined, false );
                    }
                }

                print_subtitle(undefined, " ^5Dev: Spawned " + powerup + " powerup to all players");
            }
        }
    }
}

function private _spawn_all_powerups(){
    level thread zm_name_checker::spawn_powerup_player("minigun", self zm_name_checker::powerup_placement(1));
    level thread zm_name_checker::spawn_powerup_player("nuke", self zm_name_checker::powerup_placement(2));
    level thread zm_name_checker::spawn_powerup_player("carpenter", self zm_name_checker::powerup_placement(3));
    level thread zm_name_checker::spawn_powerup_player("free_perk", self zm_name_checker::powerup_placement(4));
    level thread zm_name_checker::spawn_powerup_player("fire_sale", self zm_name_checker::powerup_placement(5));
    level thread zm_name_checker::spawn_powerup_player("insta_kill", self zm_name_checker::powerup_placement(6));
    level thread zm_name_checker::spawn_powerup_player("full_ammo", self zm_name_checker::powerup_placement(7));
    level thread zm_name_checker::spawn_powerup_player("double_points", self zm_name_checker::powerup_placement(8));
}

function private _upgrade_weapon_command_response(command_args)
{
    ModVar("upgrade_weapon", "none");

    for(;;){
        WAIT_SERVER_FRAME;

        dvar_value = ToLower(GetDvarString("upgrade_weapon", "none"));

        if(isdefined(dvar_value) && dvar_value != "none")
        {
            ModVar("upgrade_weapon", "none");

            if(dvar_value == ""){
                foreach(player in GetPlayers()){
                    player _give_upgraded_weapon();
                }
            }

            tokenized = StrTok(dvar_value, " ");
            if(tokenized.size > 1){
                player_index = Int(tokenized[0]);
                value = Int(tokenized[1]);

                print_subtitle(level.players[player_index], "^5Dev: upgraded weapon of " + level.players[player_index].playername);

                if(player_index >= 0 && player_index <= 7){
                    level.players[player_index] _give_upgraded_weapon();
                }else{
                    array::thread_all( GetPlayers(), &_give_upgraded_weapon ); 
                }
            }else{
                array::thread_all( GetPlayers(), &_give_upgraded_weapon ); 

                print_subtitle(undefined, "^5Dev: upgraded weapon of all players");
            }
        }
    }
}

function private _give_upgraded_weapon(){

    weap = self getcurrentweapon();
    weapon = zm_weapons::get_upgrade_weapon( weap, false );

    if ( ( isdefined( level.aat_in_use ) && level.aat_in_use ) )
    {
        self thread aat::acquire( weapon );
    }

    weapon.camo_index = self zm_weapons::get_pack_a_punch_weapon_options( weapon );
    self TakeWeapon( weap );
    self GiveWeapon( weapon, weapon.camo_index );
    if(self HasPerk("specialty_extraammo"))
        self GiveMaxAmmo( weapon );
    else
        self GiveStartAmmo( weapon );
        
    self SwitchToWeapon( weapon );

    zm_utility::play_sound_at_pos( "zmb_perks_packa_ready", self );
}

function private _downgrade_weapon_command_response(command_args)
{
    ModVar("downgrade_weapon", "");

    for(;;){
        WAIT_SERVER_FRAME;

        dvar_value = ToLower(GetDvarString("downgrade_weapon", ""));

        if(isdefined(dvar_value) && dvar_value != "")
        {
            ModVar("downgrade_weapon", "");

            tokenized = StrTok(dvar_value, " ");
            if(tokenized.size > 1){
                player_index = Int(tokenized[0]);
                value = Int(tokenized[1]);

                print_subtitle(level.players[player_index], "^5Dev: Downgraded weapon of " + level.players[player_index].playername);

                if(player_index >= 0 && player_index <= 7){
                    level.players[player_index] _take_upgraded_weapon();
                }else{
                    array::thread_all( GetPlayers(), &_take_upgraded_weapon ); 
                }
            }else{
                value = Int(tokenized[0]);

                array::thread_all( GetPlayers(), &_take_upgraded_weapon ); 

                print_subtitle(undefined, " ^5Dev: Downgraded all players' weapon");
            }
        }
    }
}

function private _open_doors_command_response(command_args)
{
    ModVar("open", "");

    for(;;){
        WAIT_SERVER_FRAME;

        dvar_value = ToLower(GetDvarString("open", ""));

        if(isdefined(dvar_value) && dvar_value != "")
        {
            ModVar("open", "");

            thread open_sesame_now();
            print_subtitle(undefined, " ^5Dev: Opened all " + dvar_value);
        }
    }
}

function private open_sesame_now()
{
    SetDvar("zombie_unlock_all",1);
    
    //turn on the power first
    level flag::set( "power_on" );
    level clientfield::set( "zombie_power_on", 0 );
    //DCS: this will set all zone controlling power switch flags.
    power_trigs = GetEntArray( "use_elec_switch", "targetname" );
    foreach(trig in power_trigs)
    {
        if(IsDefined(trig.script_int))
        {
            level flag::set("power_on" + trig.script_int);
            level clientfield::set( "zombie_power_on", trig.script_int );
        }
    }
    
    //get all the door triggers and trigger them
    // DOORS ----------------------------------------------------------------------------- //
    zombie_doors = GetEntArray( "zombie_door", "targetname" ); 

    for( i = 0; i < zombie_doors.size; i++ )
    {
        zombie_doors[i] notify("trigger",level.players[0]);
        
        if ( ( isdefined( zombie_doors[i].power_door_ignore_flag_wait ) && zombie_doors[i].power_door_ignore_flag_wait ) )
        {
            zombie_doors[i] notify( "power_on" );
        }
        
        wait(.05);
    }

    // AIRLOCK DOORS ----------------------------------------------------------------------------- //
    zombie_airlock_doors = GetEntArray( "zombie_airlock_buy", "targetname" ); 

    for( i = 0; i < zombie_airlock_doors.size; i++ )
    {
        zombie_airlock_doors[i] notify("trigger",level.players[0]);
        wait(.05);
    }

    // DEBRIS ---------------------------------------------------------------------------- //
    zombie_debris = GetEntArray( "zombie_debris", "targetname" ); 

    for( i = 0; i < zombie_debris.size; i++ )
    {
        if (isdefined(zombie_debris[i]))
            zombie_debris[i] notify("trigger",level.players[0]); 
        wait(.05);
    }

    // BUILDABLES ---------------------------------------------------------------------------- //
    foreach ( uts_craftable in level.a_uts_craftables )
    {
            player = GetPlayers()[0];
            player zm_craftables::player_finish_craftable( uts_craftable.craftableSpawn );
            //thread zm_unitrigger::unregister_unitrigger( uts_craftable );

            if ( isdefined( uts_craftable.craftableStub.onFullyCrafted ) )
            {
                uts_craftable [[ uts_craftable.craftableStub.onFullyCrafted ]]();
            }
    }

    level notify("open_sesame");
    wait( 1 );          
    SetDvar( "zombie_unlock_all", 0 );
}

function private _difficulty_command_response(){
    ModVar("difficulty", "");

    for(;;){
        WAIT_SERVER_FRAME;

        dvar_value = ToLower(GetDvarString("difficulty", ""));

        if(isdefined(dvar_value) && dvar_value != "")
        {
            ModVar("difficulty", "");

            difficulty_index = Int(dvar_value);

            switch(difficulty_index){
                case 1:
                    thread new_zombie_speed(1, 24, 8);
                break;

                case 2:
                    thread new_zombie_speed(5, 48, 500);
                break;

                case 3:
                    thread new_zombie_speed(50, 64, 2500);
                break;

                case 4:
                    thread new_zombie_speed(100, 64, 3500);
                break;
            }

            thread _goto_round(level.round_number);
            
            print_subtitle(undefined, " ^5Dev: Changed difficulty to " + difficulty_index);
        }
    }
}

function private new_zombie_speed(multiplier, actor_limit, dog_health)
{
    zombie_utility::set_zombie_var( "zombie_move_speed_multiplier",       multiplier,    false );    //  Multiply by the round number to give the base speed value.  0-40 = walk, 41-70 = run, 71+ = sprint
    zombie_utility::set_zombie_var( "zombie_move_speed_multiplier_easy",  multiplier,    false );    //  Multiply by the round number to give the base speed value.  0-40 = walk, 41-70 = run, 71+ = sprint

    level.zombie_actor_limit = actor_limit;
    level.zombie_ai_limit = actor_limit;

    level.dog_health = dog_health;
}

function private _notify_command_response(command_args)
{
    ModVar("notify", "");

    for(;;){
        WAIT_SERVER_FRAME;

        dvar_value = ToLower(GetDvarString("notify", ""));

        if(isdefined(dvar_value) && dvar_value != "")
        {
            ModVar("notify", "");

            tokenized = StrTok(dvar_value, " ");
            if(tokenized.size > 1){
                target = Int(tokenized[0]);
                value = Int(tokenized[1]);

                if(tokenized.size > 2){
                    value2 = Int(tokenized[2]);

                    foreach(targ in GetEntArray(target, "targetname")){
                        targ notify(value, value2);
                    }
                    
                }else{
                    foreach(targ in GetEntArray(target, "targetname")){
                        targ notify(value);
                    }
                }
            }else{
                value = Int(tokenized[0]);

                level notify(value);
            }


            print_subtitle(undefined, " ^1Dev: Turned spawning off");
        }
    }
}

function private _flag_command_response(command_args)
{
    ModVar("flag", "");

    for(;;){
        WAIT_SERVER_FRAME;

        dvar_value = ToLower(GetDvarString("flag", ""));

        if(isdefined(dvar_value) && dvar_value != "")
        {
            ModVar("flag", "");

            tokenized = StrTok(dvar_value, " ");
            if(tokenized.size > 1){
                target = Int(tokenized[0]);
                value = Int(tokenized[1]);

                foreach(targ in GetEntArray(target, "targetname")){
                    targ flag::set(value);
                }
            }else{
                value = Int(tokenized[0]);

                level flag::set(value);
            }


            print_subtitle(undefined, " ^1Dev: Turned spawning off");
        }
    }
}

function private _alias_command_response(command_args)
{
    ModVar("play", "");

    for(;;){
        WAIT_SERVER_FRAME;

        dvar_value = ToLower(GetDvarString("play", ""));

        if(isdefined(dvar_value) && dvar_value != "")
        {
            ModVar("play", "");

            alias = dvar_value;
            time = SoundGetPlaybackTime(alias) * .001;

            foreach(player in GetPlayers()){
                player PlaySoundToPlayer(alias, player);
            }
            wait time;

            foreach(player in GetPlayers()){
                player StopSounds();
            }

            print_subtitle(undefined, " ^1Dev: Played sound: " + alias);
        }
    }
}

function private _stop_alias_command_response(command_args)
{
    ModVar("stop", "");

    for(;;){
        WAIT_SERVER_FRAME;

        dvar_value = ToLower(GetDvarString("stop", ""));

        if(isdefined(dvar_value) && dvar_value != "")
        {
            ModVar("stop", "");

            tokenized = StrTok(dvar_value, " ");

            if(tokenized.size > 1){
                    player_index = Int(tokenized[0]);
                    value = Int(tokenized[1]);

                    print_subtitle(level.players[player_index], "^5Dev: Stopped all sounds from playing on player: " + level.players[player_index].playername);

                    if(player_index >= 0 && player_index <= 7){
                        level.players[player_index] StopSounds();
                    }else{
                        foreach(player in GetPlayers())
                            player StopSounds();
                    }
                }else{
                    value = Int(tokenized[0]);

                    foreach(player in GetPlayers())
                        player StopSounds();

                    print_subtitle(undefined, " ^5Dev: Stopped all sounds from playing for all players");
                }
        }
    }
}

function private _aimbot_command_response(){
    ModVar("aimbot", "");

    for(;;){
        WAIT_SERVER_FRAME;

        dvar_value = ToLower(GetDvarString("aimbot", ""));

        if(isdefined(dvar_value) && dvar_value != "")
        {
            ModVar("aimbot", "");

            tokenized = StrTok(dvar_value, " ");
            if(tokenized.size > 1){
                player_index = Int(tokenized[0]);
                value = Int(tokenized[1]);

                if(dvar_value == "on" || dvar_value == "activate" || dvar_value == "1"){
                    if(player_index >= 0 && player_index <= 7){
                        level.players[player_index] thread _aimbot_func(true);
                    }else{
                        foreach(e_player in GetPlayers()){
                            e_player thread _aimbot_func(true);
                        }
                    }
                    print_subtitle(level.players[player_index], "^5Dev: Activated aimbot to " + level.players[player_index].playername);
                }else if(dvar_value == "off" || dvar_value == "deactivate" || dvar_value == "0"){
                    if(player_index >= 0 && player_index <= 7){
                        level.players[player_index] thread _aimbot_func(false);
                    }else{
                        foreach(e_player in GetPlayers()){
                            e_player thread _aimbot_func(false);
                        }
                    }
                    print_subtitle(level.players[player_index], "^5Dev: Deactivated aimbot to " + level.players[player_index].playername);
                }
            }else{
                value = Int(tokenized[0]);

                if(dvar_value == "on" || dvar_value == "activate" || dvar_value == "1"){
                    foreach(e_player in GetPlayers()){
                        e_player thread _aimbot_func(true);
                    }
                    print_subtitle(level.players[player_index], "^5Dev: Activated aimbot to " + level.players[player_index].playername);
                }else if(dvar_value == "off" || dvar_value == "deactivate" || dvar_value == "0"){
                    foreach(e_player in GetPlayers()){
                        e_player thread _aimbot_func(false);
                    }
                    print_subtitle(level.players[player_index], "^5Dev: Deactivated aimbot to " + level.players[player_index].playername);
                }

                print_subtitle(undefined, "^5Dev: Activated aimbot to all players");
            }
        }
    }
}

function private _aimbot_func(activate){

    self notify("stop_aimbot" + (self GetEntityNumber() + 1));
    self endon("stop_aimbot" + (self GetEntityNumber() + 1));

    if(IS_TRUE(activate)){
        for(;;){
            while(self playerADS() >= 0.3){
                available_aimbot_array = array();

                foreach(enemy in GetAITeamArray( level.zombie_team )){
                    if( enemy CanSee(self) ){
                        ARRAY_ADD(available_aimbot_array, enemy);
                    }
                }

                closest_available_zombie = ArrayGetClosest(self.origin, available_aimbot_array);

                self SetPlayerAngles( VectortoAngles( (closest_available_zombie GetTagOrigin("j_head")) - (self GetEye()) ) );

                WAIT_SERVER_FRAME
            }
            WAIT_SERVER_FRAME
        }
    }

    self notify("stop_aimbot");
}

function private _take_upgraded_weapon(){

    weap = self getcurrentweapon();
    weapon = zm_weapons::get_base_weapon( weap );

    self TakeWeapon( weap );
    self GiveWeapon( weapon, self zm_weapons::get_pack_a_punch_weapon_options( weapon ) );
    self GiveStartAmmo( weapon );
    self SwitchToWeapon( weapon );

    zm_utility::play_sound_at_pos( "zmb_perks_packa_ready", self );
}

function private _get_eye_location(){
    // Trace to where the player is looking
    direction = self GetPlayerAngles();
    direction_vec = AnglesToForward( direction );
    eye = self GetEye();

    scale = 8000;
    direction_vec = (direction_vec[0] * scale, direction_vec[1] * scale, direction_vec[2] * scale);

    // offset 2 units on the Z to fix the bug where it would drop through the ground sometimes
    trace = bullettrace( eye, eye + direction_vec, 0, undefined );

    final_pos = trace["position"];

    return final_pos;
}

function _goto_round(round_number = undefined)
{
    if(!isdefined(round_number))
        round_number = zm::get_round_number();
    if(round_number == zm::get_round_number())
        return;
    if(round_number < 0)
        return;

    // kill_round by default only exists in debug mode
    /#
    level notify("kill_round");
    #/
    // level notify("restart_round");
    foreach(zombie in zombie_utility::get_round_enemy_array())
    {
        zombie Kill();
    }
    level.zombie_total = 0;
    level notify("end_of_round");
    wait 0.05;
    zm::set_round_number(round_number);
    round_number = zm::get_round_number(); // get the clamped round number (max 255)

    zombie_utility::ai_calculate_health(round_number);
    SetRoundsPlayed(round_number);

    if(level.gamedifficulty == 0)
        level.zombie_move_speed = round_number * level.zombie_vars["zombie_move_speed_multiplier_easy"];
    else
        level.zombie_move_speed = round_number * level.zombie_vars["zombie_move_speed_multiplier"];

    level.zombie_vars["zombie_spawn_delay"] = [[level.func_get_zombie_spawn_delay]](round_number);

    level.sndGotoRoundOccurred = true;
}

function private _give_perk( perk )
{
    vending_triggers = GetEntArray( "zombie_vending", "targetname" );

    if ( vending_triggers.size < 1 )
    {
        print_subtitle(self, " ^1Dev: No perk machines found in map");
        return;
    }

    if(perk == "all"){
        foreach( perk_a in GetArrayKeys( level._custom_perks ) ){
            self zm_perks::give_perk( perk_a, false );
            wait .5;
        }
    }else if(StrEndsWith(perk, ";")){
        tokenized = StrTok(perk, " ");
        for(i=0; i<tokenized.size;i++){
            self zm_perks::give_perk( tokenized[i], false);
        }
    }else if(StrIsInt(perk)){
        perk = Int(perk);
        for(i=0; i<perk;i++){
            self zm_perks::give_random_perk();
        }
    }else{
        self zm_perks::give_perk( perk, false );
    }
}

function private _take_perk( perk )
{
    if ( self.perks_active.size < 1 )
    {
        print_subtitle(self, " ^1Dev: Player has no active perks");
        return;
    }

    perks = self.perks_active;

    if(perk == "all"){
        foreach( perk_a in perks ){
            self lose_perk( perk_a );
            wait 1;
        }
    }else if(StrIsInt(perk)){
        perk = Int(perk);
        for(i=0; i<perk;i++){
            self zm_perks::lose_random_perk();
            wait 1;
        }
    }else{
        self lose_perk( perk );
    }
}

function private print_subtitle(player, message){

    if(isdefined(player)){
        player util::setClientSysState( "subtitleMessage", message, player );
    }else{
        foreach(player_e in GetPlayers()){
            player_e util::setClientSysState( "subtitleMessage", message, player_e );
        }
    }    
}

function lose_perk(perk){

    perk_str = perk + "_stop";
    self notify( perk_str );

    if ( use_solo_revive() && perk == PERK_QUICK_REVIVE )
    {
        self.lives--;
    }

}

function use_solo_revive()
{
    if( isdefined(level.override_use_solo_revive) )
    {
        return [[level.override_use_solo_revive]]();
    }

    players = GetPlayers();
    solo_mode = 0;
    if ( players.size == 1 || IS_TRUE( level.force_solo_quick_revive ) )
    {
        solo_mode = 1;
    }
    level.using_solo_revive = solo_mode;
    return solo_mode;
}