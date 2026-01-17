#using scripts\codescripts\struct;

#using scripts\shared\aat_shared;
#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\demo_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\animation_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_bgb;
#using scripts\zm\_zm_daily_challenges;
#using scripts\zm\_zm_equipment;
#using scripts\zm\_zm_pack_a_punch_util;
#using scripts\zm\_zm_pers_upgrades_functions;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_unitrigger;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;

#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;

#namespace aw_mbox;

REGISTER_SYSTEM_EX("aw_mbox", &__init__, &__main__, undefined)

//*****************************************************************************
// MAIN
//*****************************************************************************

#define DEFAULT_CHEST_COST 950
#define HINT_AWAY_PRINTER "^33D PRINTER MALFUNCTION^7"

#using_animtree( "generic" );
#precache("fx", "_custom/atlas/aw_magicbox_open");
#precache("fx", "_custom/atlas/aw_idle_box_fx");
#precache("fx", "_custom/atlas/aw_idle_box_off_fx");

function __init__(){
	clientfield::register( "scriptmover", "exo_magicbox_dr_holo", VERSION_SHIP, 1, "int" );
}

function __main__(){

	exo_mysterybox_loc = struct::get_array("aw_exo_mysterybox_location");
	exo_mysterybox_loc = array::randomize(exo_mysterybox_loc);

	level._effect["idle_box_fx"] = "_custom/atlas/aw_idle_box_fx";
	level._effect["idle_box_off_fx"] = "_custom/atlas/aw_idle_box_off_fx";

	level.chest_accessed = 0; //Keeps track of how many times the box is opened
    level.chest_moves = 1; //Keeps track of how many times the box moved
    level.available_chests = []; //Used anywhere
	exo_mbox_starting_locs = []; //Used here

	wait(0.05);

	foreach( box in exo_mysterybox_loc ){ //Inits all boxes, if script_noteworthy is equal to "starting_loc" it will be kept for random box spawing
		if(isdefined(self.script_noteworthy) && self.script_noteworthy == "starting_loc")
			exo_mbox_starting_locs[exo_mbox_starting_locs.size] = self;
		box init_weaponbox(); // Setsup each box.
	}

	if(exo_mbox_starting_locs.size > 1){ //If there are more than 1 starting location pick randomly
		exo_mbox_starting_locs = array::randomize(exo_mbox_starting_locs);
		starting_chest = exo_mbox_starting_locs[0];	
	}
	else{
		starting_chest = exo_mysterybox_loc[0];
	}

    if(!(exo_mysterybox_loc.size > 1)) starting_chest.is_static = 1; //if there's one box then theres no need to do
        // do all the moving logic

    level.available_chests = exo_mysterybox_loc; //Save all locations for later

	level.chest_index = 0; //Keeps track of which box is being used to avoid moving to the same location
	level.starting_chest = starting_chest;
	level.starting_chest thread spawn_chest(); //Spawn the box at the starting loc
	level.starting_chest thread box_encounter_vo(); //Setup encounter gvox
}

function reset_chest(){ //This function resets any location (self = struct) to it's default proprieties
	self notify("stop_cycle");

	self zm_unitrigger::unregister_unitrigger(self.unitrigger_stub);

	self.actual_weapon = level.weaponNone; //set the weapon to none to avoid issues
	self.grabber = undefined;
	self.model SetModel("tag_origin"); //The cycling model set to inbisible
	self.model clientfield::set("exo_magicbox_dr_holo", 1); //Make the clone glow
	self.model Show(); //Set to show to reset the blinking in cause it was left on self Ghost();
	if(isdefined(self.fxmodel))
		self.fxmodel Delete();
	self.fxmodel = util::spawn_model( "tag_origin", self.animmodel.origin, self.animmodel.angles );
	PlayFXOnTag(level._effect["idle_box_off_fx"], self.fxmodel, "tag_origin");
}

function init_weaponbox(){ //Init any location to be usable in the script
	if( !isdefined(self) || !level.enable_magic) //If the struct was deleted or magic was disabled then do nothing
		return;

	if(!isdefined(self.chest_cost))
		self.chest_cost = DEFAULT_CHEST_COST;

	self.model = util::spawn_model( "tag_origin", self.origin, self.angles ); //Spawn a model used for weapon cycle
	self.actual_weapon = level.weaponNone; //Var used to keep track of which weapon to give
	self.animmodel = GetEnt(self.target, "targetname"); //Get the animated model for animations
	self.animmodel UseAnimTree( #animtree ); //Enable animations
	if(isdefined(self.fxmodel)) self.fxmodel Delete();
	self.fxmodel = util::spawn_model( "tag_origin", self.animmodel.origin, self.animmodel.angles );
	self.state = "close";
	self.grabber = undefined;
    //Spawn an unitrigger helping the player know if the box is active or not
	self thread set_up_unitrigger(64, 64, 64, false, HINT_AWAY_PRINTER, undefined, &trigger_update_prompt_default);
	PlayFXOnTag(level._effect["idle_box_off_fx"], self.fxmodel, "tag_origin");
}

function spawn_chest(){ //make a box location usable, self is struct
	while(self.state != "close"){
		wait 0.05;
	}
	self reset_chest(); //Reset the basic proprieties
	wait 0.05;
	self thread cycle_weapons(); //Start cycling through weapons
	wait 0.05;
	if(isdefined(self.fxmodel)) self.fxmodel Delete();
	self.fxmodel = util::spawn_model( "tag_origin", self.animmodel.origin, self.animmodel.angles );
	PlayFXOnTag(level._effect["idle_box_fx"], self.fxmodel, "tag_origin");
	//self.state = "open";
	self.animmodel PlaySound("interact_mystery_box_ready"); //Notify the player that the box is ready
    //Setup the trigger for use
	WAIT_SERVER_FRAME;
	self set_up_unitrigger(64, 64, 64, false, "Hold ^3[{+activate}]^7 to print a weapon [ Cost: "+ self.chest_cost +" ]", &box_bought, &trigger_update_prompt_default);
}

function cycle_weapons(){ //This function handles cycling through all available weapons to show in the box
	self endon("printer_go_away"); //End when the box moves
	self endon("printer_bought"); //End when the player buys a weapon
	self endon("stop_cycle");

	while(1){
		self.actual_weapon = (treasure_chest_ChooseWeightedRandomWeapon()); //Pick a random weapon from the loaded ones
		if(!isdefined(self.actual_weapon) || !isdefined(self.actual_weapon.worldModel)) continue;
		self.model SetModel(self.actual_weapon.worldModel); //Set the spawned model to the weapon model
		wait RandomFloatRange( 0.2, 1 ); //Wait a random amount of time for the player to react
	}
}

function pick_an_usable_weapon(player){
	keys = array::randomize( GetArrayKeys( level.zombie_weapons ) );
	pap_triggers = zm_pap_util::get_triggers();
	for ( i = 0; i < keys.size; i++ ) if ( treasure_chest_CanPlayerReceiveWeapon( player, keys[i], pap_triggers ) ) return keys[i];
}

function treasure_chest_CanPlayerReceiveWeapon( player, weapon, pap_triggers ){
	if ( !zm_weapons::get_is_in_box( weapon ) )	return false;

	if ( IsDefined( player ) && player zm_weapons::has_weapon_or_upgrade( weapon ) ) return false;

	if ( !zm_weapons::limited_weapon_below_quota( weapon, player, pap_triggers )) return false;
	
	if ( !player zm_weapons::player_can_use_content( weapon ) ) return false;
	
	if(isdefined(level.custom_magic_box_selection_logic))
	{
		if(![[level.custom_magic_box_selection_logic]](weapon, player, pap_triggers))
		{
			return false;
		}
	}

	if ( weapon.name == "ray_gun" )	if ( player zm_weapons::has_weapon_or_upgrade( GetWeapon( "raygun_mark2" ) ) )	return false;
	
	if ( weapon.name == "raygun_mark2" ) if ( player zm_weapons::has_weapon_or_upgrade( GetWeapon( "ray_gun" ) ) ) return false;

	// enable special level by level weapon checks
	if( IsDefined( player ) && isdefined( level.special_weapon_magicbox_check ) ) return player [[level.special_weapon_magicbox_check]]( weapon );
	return true;
}

function treasure_chest_ChooseWeightedRandomWeapon(){ //Returns a random weapon from the ones loaded in the level
	keys = array::randomize( GetArrayKeys( level.zombie_weapons ) );
	i = 0;
	max_size = keys.size;
	while(1){
		while( !zm_weapons::get_is_in_box( keys[i] ) && i < max_size) i++;
		wait 0.05;
		if(!zm_weapons::get_is_in_box( keys[i] ) ) continue;
		else break;
	}
	
	return keys[i];
}

function box_bought(player){ //Function that handles what happens once the player interacts with the box
    self zm_unitrigger::unregister_unitrigger(self.unitrigger_stub); //Delete trigger to avoid multiple buys

	if( !player zm_score::can_player_purchase( self.chest_cost ) ){ // Do nothing if player doesn't have money
		player zm_audio::create_and_play_dialog( "general", "outofmoney", 0 );
        self thread spawn_chest(); //Reset this chest
		return;
	}

	self.state = "open";
	self notify("printer_bought"); //Notify the box that it was accessed
    if(!IS_TRUE( level.zombie_vars["zombie_powerup_fire_sale_on"] ))level.chest_accessed++; // Increase var
	player zm_score::minus_to_player_score( self.chest_cost ); //Take points from player

	if(player zm_weapons::has_weapon_or_upgrade(self.actual_weapon)){
		self.actual_weapon = pick_an_usable_weapon(player);
		self.model SetModel(self.actual_weapon.worldModel);
	}

	self.grabber = player;

	if( self treasure_chest_should_move() ){ //Check if it should move

		self.animmodel thread animation::play("dlc_weapon_mystery_box_01_malfunction", self.animmodel.origin, self.animmodel.angles); //Play the broken box anim
		self.animmodel waittill("box_malfunction"); //Wait till anim notify
		self.model SetModel("tag_origin"); //The cycling model set to inbisible
		player zm_score::add_to_player_score( self.chest_cost , false, "magicbox_bear" ); //Refund points
		self thread box_move_away(player); //Move the box
		return;

	}
    //If box doesn't move then proceed with giving a weapon
	self.animmodel PlaySound("interact_mystery_box"); //Open box sound
	wait 0.65; //For sound/anim synch.
	self thread open_box_lid();
    //Now spawn a new trigger
	wait 2.08;
	self.model clientfield::set("exo_magicbox_dr_holo", 0); //Make the clone glow
	self thread set_up_unitrigger(64, 64, 64, false, "Hold ^3[{+activate}]^7 to get " + self.actual_weapon.displayName , &box_get_weapon, &trigger_update_prompt_get_weapon);
	//Start counting down, removes the weapon if the player doesnt acquire it
    self thread wpn_box_timeout();	
}

function open_box_lid(){
	self.animmodel animation::play("dlc_weapon_mystery_box_01_open", self.animmodel.origin, self.animmodel.angles); //Play open box anim
	WAIT_SERVER_FRAME;
	self.animmodel thread animation::play("dlc_weapon_mystery_box_01_open_idle", self.animmodel.origin, self.animmodel.angles); //Lock the box in it's open state
}

function box_get_weapon(player){//Function that handles what happens once the player gets the weapon
    self zm_unitrigger::unregister_unitrigger(self.unitrigger_stub); //Delete trigger to avoid multiple buys
	self.model SetModel("tag_origin");
    self.model notify("weapon_obtained");
	WAIT_SERVER_FRAME;
	WAIT_SERVER_FRAME;
	player zm_weapons::weapon_give(self.actual_weapon, false, true);
	self.animmodel animation::stop();
	WAIT_SERVER_FRAME;
	self.animmodel animation::play("dlc_weapon_mystery_box_01_close"); //Close the box
	wait 0.005;
	if(!IS_TRUE(self.waiting_to_spawn) )
		self thread spawn_chest(); //Reset this location to its original state
	self.state = "close";
}

function box_move_away(player_vox){ //This function handles moving the box to a new location
	level.chest_moves++;
	level.chest_accessed = 0;
	self.state = "leaving";

	level thread zm_audio::sndAnnouncerPlayVox("boxmove"); // Make the announcer talk
	wait 1;
	player_vox util::delay( randomintrange(5,7), undefined, &zm_audio::create_and_play_dialog, "general", "box_move"  ); //Make the character respond to the box moving
	self thread reset_chest(); //Reset this box to it's original state 
	self thread set_up_unitrigger(64, 64, 64, false, HINT_AWAY_PRINTER, undefined, &trigger_update_prompt_default);
	wait 10; //After 1 second disable the location
	self.state = "close";
	level.chest_index = get_next_chest_index(); //Choose a new box location

	if(!IS_TRUE(self.waiting_to_spawn))
		level.available_chests[level.chest_index] thread spawn_chest(); //Spawn the box at the new location
}

function get_next_chest_index(){ //This function gets an index for the new box location, keeps rolling until it's different from the current one
	do{
		newI = RandomInt(level.available_chests.size);
        wait 0.05;
	}while(newI == level.chest_index);
	return newI;
}

function wpn_box_timeout(){ //Start counting down, removes the weapon if the player doesnt acquire it
	self.model endon("weapon_obtained"); //Stop immediatly if the player gets the weapon

	wait 8;
	self.model thread weapon_model_blink(); //After 8 seconds start blinking!
	wait 4;
	self.model notify("weapon_timeout"); //Let the weapon model know the weapon has timeout-ed. (This is used to stop the blinking of the model)
	self zm_unitrigger::unregister_unitrigger(self.unitrigger_stub); //Delete trigger to avoid multiple buys
	self.animmodel animation::stop();
	WAIT_SERVER_FRAME;
	self.animmodel animation::play("dlc_weapon_mystery_box_01_close"); //Close the box
	WAIT_SERVER_FRAME;
	self.state = "close";
	if(!IS_TRUE(self.waiting_to_spawn))
		self thread spawn_chest(); // Reset current box to it's normal behaviour
}

//Make the weapon model blink when time is running out
function weapon_model_blink(){
    self endon("weapon_timeout"); //Stop when the weapon hasn't been picked up
    self endon("weapon_obtained"); //Stop when the weapon has been picked up

	while(1){
		self Ghost(); //Send network info but dont render.
		wait 0.5;
		self Show();
		wait 0.5;
	}

}

function box_encounter_vo(){ //This function handles the initial encounter vox
	level flag::wait_till( "initial_blackscreen_passed" );
	
	while (1){
		foreach (player in getPlayers()){
			distanceFromPlayerToBox = distance(player.origin, self.origin);
			
			if (distanceFromPlayerToBox < 300){
				player zm_audio::create_and_play_dialog( "box", "encounter" );
				return;				
			}			
		}
		wait 0.5;
	}
}

function treasure_chest_should_move(){ //This function handles choosing if the box needs to move
	// Increase the chance of joker appearing from 0-100 based on amount of the time chest has been opened.
	if( ( GetDvarString( "magic_chest_movable") == "1") && !treasure_chest_firesale_active() ){
		// random change of getting the joker that moves the box
		random = Randomint(100);

		if( !isdefined( level.chest_min_move_usage ) ) level.chest_min_move_usage = 4;
		if( level.chest_accessed < level.chest_min_move_usage )	chance_of_joker = -1;
		else{
			chance_of_joker = level.chest_accessed + 20;

			// make sure teddy bear appears on the 8th pull if it hasn't moved from the initial spot
			if ( level.chest_moves == 0 && level.chest_accessed >= 8 )chance_of_joker = 100;

			// pulls 4 thru 8, there is a 15% chance of getting the teddy bear
			// NOTE:  this happens in all cases
			if( level.chest_accessed >= 4 && level.chest_accessed < 8 ){
				if( random < 15 ) chance_of_joker = 100;
				else chance_of_joker = -1;
			}

			// after the first magic box move the teddy bear percentages changes
			if ( level.chest_moves > 0 ){
				// between pulls 8 thru 12, the teddy bear percent is 30%
				if( level.chest_accessed >= 8 && level.chest_accessed < 13 )
				{
					if( random < 30 ) chance_of_joker = 100;
					else chance_of_joker = -1;
				}	
				// after 12th pull, the teddy bear percent is 50%
				if( level.chest_accessed >= 13 ){
					if( random < 50 ) chance_of_joker = 100;
					else chance_of_joker = -1;
				}
			}
		}

		if(IsDefined(self.is_static)) chance_of_joker = -1;

		if ( chance_of_joker > random ) return true; 
	}
	return false; 	
}

function treasure_chest_firesale_active(){ //Self explanatory
	return IS_TRUE( level.zombie_vars["zombie_powerup_fire_sale_on"] ); 
}

////
// UNITRIGGER FUNCS
////

function trigger_update_prompt_get_weapon( player ){// Handles standard visibility for unitriggers
	self endon( "kill_trigger" );
	
	if ( isdefined( self ) ){
		can_use = stub_update_prompt( player );
		if(isdefined(self.stub.trigger_target.grabber) && self.stub.trigger_target.grabber != player) can_use = false;
		self setInvisibleToPlayer( player, !can_use );
		self SetHintString( self.stub.hint_string );
		return can_use;
	}
	self SetHintString("");
	return false;
}

function trigger_update_prompt_default( player ){// Handles standard visibility for unitriggers
	self endon( "kill_trigger" );

	if ( isdefined( self ) ){
		can_use = stub_update_prompt( player );
		self setInvisibleToPlayer( player, !can_use );
		self SetHintString( self.stub.hint_string );
		return can_use;
	}
	self SetHintString("");
	return false;
}

//Sets up a new unitrigger, self == struct/ent
function set_up_unitrigger(width = 64, lenght = 64, height = 64, LOOKAT = false, HINTSTRING, TRIGGERED_FUNC, UPDATE_PROMPT ){
	self.unitrigger_stub = SpawnStruct();
	self.unitrigger_stub.origin = self.origin;
	self.unitrigger_stub.angles = self.angles;
	self.unitrigger_stub.script_unitrigger_type = "unitrigger_box_use";
	self.unitrigger_stub.script_width = width;
	self.unitrigger_stub.script_height = height;
	self.unitrigger_stub.script_length = lenght;
	self.unitrigger_stub.require_look_toward = LOOKAT;
	self.unitrigger_stub.cursor_hint = "HINT_NOICON";
	self.unitrigger_stub.hint_string = HINTSTRING;
	self.unitrigger_stub.trigger_target = self;
	self.unitrigger_stub.triggered_func = TRIGGERED_FUNC;
	self.unitrigger_stub.prompt_and_visibility_func = UPDATE_PROMPT;
	self zm_unitrigger::register_static_unitrigger( self.unitrigger_stub, &check_valid );
}

function check_valid(){
	self endon( "kill_trigger" );

	while( 1 ){
		self waittill( "trigger", player );
		if ( !zm_utility::is_player_valid( player ) )
			continue;
		if ( isdefined( self.stub.triggered_func ) )
			self.stub.trigger_target thread [[ self.stub.triggered_func ]]( player );
	}
}

function stub_update_prompt( player ){	
	if( !zm_utility::is_player_valid( player ) )
		return false;
	if( player zm_utility::in_revive_trigger() )
		return false;
	if( IS_DRINKING(player.is_drinking) )
		return false;
	return true;
}