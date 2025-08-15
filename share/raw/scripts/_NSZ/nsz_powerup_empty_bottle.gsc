#using scripts\codescripts\struct;

#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\shared\ai\zombie_death;

#using scripts\zm\_zm_blockers;
#using scripts\zm\_zm_pers_upgrades;
#using scripts\zm\_zm_pers_upgrades_functions;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_utility;

#using scripts\shared\array_shared;

#insert scripts\zm\_zm_powerups.gsh;
#insert scripts\zm\_zm_utility.gsh;

#precache( "model", "powerup_money" );

REGISTER_SYSTEM( "zm_powerup_empty_bottle", &__init__, undefined )

//-----------------------------------------------------------------------------------
// setup
//-----------------------------------------------------------------------------------
function __init__()
{
	level.get_player_perk_purchase_limit = &new_perk_check; 
	
	zm_powerups::register_powerup( "empty_bottle", &grab_bottle );
	if( ToLower( GetDvarString( "g_gametype" ) ) != "zcleansed" )
	{
		zm_powerups::add_zombie_powerup( "empty_bottle", "empty_bottle", "", &func_should_drop_empty_bottle, POWERUP_ONLY_AFFECTS_GRABBER, !POWERUP_ANY_TEAM, !POWERUP_ZOMBIE_GRABBABLE );
	}

}

function new_perk_check()
{
	n_perk_purchase_limit_override = level.perk_purchase_limit; // start with the default value
	
	if( isDefined(self.num_of_empty_bottles) )
		n_perk_purchase_limit_override+=self.num_of_empty_bottles; 
	return n_perk_purchase_limit_override; 
}

function func_should_drop_empty_bottle()
{
	return true;
}

function grab_bottle( player )
{
	if( !isDefined(player.num_of_empty_bottles) )
		player.num_of_empty_bottles = 0; 
	player.num_of_empty_bottles++; 
	
	player thread correct_later(); 
}

function correct_later()
{
	self util::waittill_any_return( "fake_death", "death", "player_downed" ); 
	self.num_of_empty_bottles--; 
}