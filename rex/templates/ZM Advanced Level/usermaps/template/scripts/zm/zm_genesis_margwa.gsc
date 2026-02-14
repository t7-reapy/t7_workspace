#using scripts\codescripts\struct;
#using scripts\shared\ai\margwa;
#using scripts\shared\ai\systems\animation_state_machine_mocomp;
#using scripts\shared\ai\systems\behavior_tree_utility;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\math_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\zm\_zm_ai_margwa_elemental;
#using scripts\zm\_zm_ai_margwa;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_portals;
#using scripts\zm\_zm_ai_margwa;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace zm_genesis_margwa;

function autoexec init()
{
	function_e84ffe9c();
	level thread margwa_round_spawning();
	spawner::add_archetype_spawn_function("margwa", &function_57c223eb);
	margwabehavior::adddirecthitweapon("turret_zm_genesis");
	margwabehavior::adddirecthitweapon("shotgun_energy");
	margwabehavior::adddirecthitweapon("shotgun_energy_upgraded");
	margwabehavior::adddirecthitweapon("pistol_energy");
	margwabehavior::adddirecthitweapon("pistol_energy_upgraded");
	if(!isdefined(level.var_fd47363))
	{
		level.var_fd47363 = [];
		level.var_fd47363["head_le"] = "c_zom_dlc4_margwa_chunks_le";
		level.var_fd47363["head_mid"] = "c_zom_dlc4_margwa_chunks_mid";
		level.var_fd47363["head_ri"] = "c_zom_dlc4_margwa_chunks_ri";
		level.var_fd47363["gore_le"] = "c_zom_dlc4_margwa_gore_le";
		level.var_fd47363["gore_mid"] = "c_zom_dlc4_margwa_gore_mid";
		level.var_fd47363["gore_ri"] = "c_zom_dlc4_margwa_gore_ri";
		level.margwa_head_left_model_override = level.var_fd47363["head_le"];
		level.margwa_head_mid_model_override = level.var_fd47363["head_mid"];
		level.margwa_head_right_model_override = level.var_fd47363["head_ri"];
		level.margwa_gore_left_model_override = level.var_fd47363["gore_le"];
		level.margwa_gore_mid_model_override = level.var_fd47363["gore_mid"];
		level.margwa_gore_right_model_override = level.var_fd47363["gore_ri"];
	}
	if(!isdefined(level.var_6b7244b4))
	{
		level.var_6b7244b4 = 100;
	}
}

function private function_e84ffe9c()
{
	behaviortreenetworkutility::registerbehaviortreescriptapi("genesisMargwaVortexService", &function_96a94112);
	behaviortreenetworkutility::registerbehaviortreescriptapi("genesisMargwaSpiderService", &function_9f065361);
	behaviortreenetworkutility::registerbehaviortreescriptapi("genesisMargwaReactStunTerminate", &function_a5e64246);
	behaviortreenetworkutility::registerbehaviortreescriptapi("genesisMargwaReactIDGunTerminate", &function_a478da01);
}

function private function_96a94112(entity)
{
	if(isdefined(entity.var_28763934) && entity.var_28763934 < gettime())
	{
		return zm_ai_margwa::function_6312be59(entity);
	}
	return 0;
}

function private function_9f065361(entity)
{
	zombies = getaiteamarray(level.zombie_team);
	foreach(zombie in zombies)
	{
		if(zombie.archetype == "spider")
		{
			distsq = distancesquared(entity.origin, zombie.origin);
			if(distsq < 2304)
			{
				zombie kill();
			}
		}
	}
}


function private function_a5e64246(entity)
{
	margwabehavior::margwareactstunterminate(entity);
	entity.var_aa0a91dd = gettime() + 10000;
}


function private function_a478da01(entity)
{
	margwabehavior::margwareactidgunterminate(entity);
	entity.var_28763934 = gettime() + 10000;
}

function private function_57c223eb()
{
	self.margwapainterminatecb = &function_cc95e566;
	self thread function_e1f5236a();
	self.idgun_damage_cb = &function_df77c1c3;
	self.var_fbaea41d = &function_a8ffa66c;
	self.var_c732138b = &function_f769285c;
	self.var_aa0a91dd = gettime();
	self.var_28763934 = gettime();
	self.var_15704e8d = gettime();
	self.heroweapon_kill_power = 5;
}

function private function_9ba47060()
{
	self endon("death");
	wait(0.1);
	if(isdefined(self.traveler))
	{
		self.traveler delete();
	}
}

function private function_f05e4819()
{
	self endon("death");
	self.waiting = 1;
	self.needteleportin = 1;
	self thread margwaserverutils::margwatell();
	wait(2);
	self.travelertell clientfield::set("margwa_fx_travel_tell", 0);
	self.waiting = 0;
	self.needteleportout = 0;
}

function private function_e1f5236a()
{
	self endon("death");
	wait(1);
	self margwaserverutils::margwaenablestun();
}


function private function_cc95e566()
{
	if(math::cointoss())
	{
		if(zm_ai_margwa_elemental::function_6bbd2a18(self))
		{
			self.var_322364e8 = 1;
		}
		else if(zm_ai_margwa_elemental::function_b9fad980(self))
		{
			self.var_3c58b79c = 1;
		}
	}
}

function private function_df77c1c3(inflictor, attacker)
{
	if(isdefined(self))
	{
		foreach(head in self.head)
		{
			if(head.health > 0)
			{
				damage = self.headhealthmax * 0.5;
				head.health = head.health - damage;
				if(head.health <= 0)
				{
					player = undefined;
					if(isdefined(self.vortex))
					{
						player = self.vortex.attacker;
					}
					if(self margwaserverutils::margwakillhead(head.model, player))
					{
						self kill();
					}
				}
				return;
			}
		}
	}
}

function private function_a8ffa66c(player)
{
	if(isdefined(self))
	{
		if(gettime() > self.var_15704e8d)
		{
			foreach(head in self.head)
			{
				if(head.health > 0)
				{
					head.health = 0;
					if(self margwaserverutils::margwakillhead(head.model, player))
					{
						self kill();
					}
					self.var_15704e8d = gettime() + 10000;
					return;
				}
			}
		}
	}
}


function private function_f769285c()
{
	if(self function_2a03f05f())
	{
		self.reactstun = 1;
		return true;
	}
	return false;
}

function function_2a03f05f()
{
	if(isdefined(self.canstun) && self.canstun && self.var_aa0a91dd < gettime())
	{
		return true;
	}
	return false;
}


function margwa_round_spawning()
{
	level.b_margwa_zombies_enabled	= 1;
	level.n_margwa_max	= 4;
	level.n_next_margwa_spawn_round	= 5 + randomIntRange( 0, 2 + 1 );

	level thread margwa_zombie_spawn_logic();

}

function delay_if_blackscreen_pending()
{
	while ( !flag::exists( "initial_blackscreen_passed" ) )
		WAIT_SERVER_FRAME;
	
	if ( !flag::get( "initial_blackscreen_passed" ) )
		level flag::wait_till( "initial_blackscreen_passed" );
	
}

function custom_spawn_location_selection( a_spots )
{
	if ( isDefined( level.zombie_respawns ) && level.zombie_respawns > 0 )
	{
		if( !isDefined( level.n_player_spawn_selection_index ) )
			level.n_player_spawn_selection_index = 0;

		a_players = getPlayers();
		level.n_player_spawn_selection_index++;
		if ( level.n_player_spawn_selection_index >= a_players.size )
			level.n_player_spawn_selection_index = 0;
		
		e_player = a_players[ level.n_player_spawn_selection_index ];

		arraySortClosest( a_spots, e_player.origin );

		a_candidates = [];

		v_player_dir = anglesToForward( e_player.angles );
		
		for ( i = 0; i < a_spots.size; i++ )
		{
			v_dir = a_spots[ i ].origin - e_player.origin;
			dp = vectorDot( v_player_dir, v_dir );
			if ( dp >= 0.0 )
			{
				a_candidates[ a_candidates.size ] = a_spots[ i ];
				if ( a_candidates.size > 10 )
					break;
				
			}
		}

		if ( a_candidates.size )
			s_spot = array::random( a_candidates );
		else
			s_spot = array::random(a_spots);
		
	}
	else
		s_spot = array::random( a_spots );
	
	return s_spot;
}


function margwa_zombie_spawn_logic()
{
	delay_if_blackscreen_pending();
	
	while ( 1 )
	{
		level waittill( "between_round_over" );
		
		if ( level.round_number > level.n_next_margwa_spawn_round )
			level.n_next_margwa_spawn_round = level.round_number;
		
		if ( isDefined( level.next_dog_round ) && level.next_dog_round == level.n_next_margwa_spawn_round )
			level.n_next_margwa_spawn_round++;
		
		if ( level.round_number < level.n_next_margwa_spawn_round )
			continue;
		
		level margwa_zombie_spawner_logic();
		
		level.n_margwa_max += 4;
		
		if ( level.n_margwa_max > 4 )
			level.n_margwa_max = 4;
		
	}
}

function margwa_zombie_spawner_logic()
{
	level notify( "margwa_zombie_spawner_logic" );
	level endon( "margwa_zombie_spawner_logic" );
	level endon( "end_of_round" );
	
	while ( !isDefined( level.zombie_total ) || level.zombie_total < 1 )
		WAIT_SERVER_FRAME;
	
	n_round_total = level.zombie_total;
	
	n_increment = int( n_round_total / ( level.n_margwa_max + 1 ) );
	
	n_next_spawn = int( n_round_total - n_increment );
		
	level.n_margwa_zombie_spawned_this_round = 0;
	while ( level.n_margwa_zombie_spawned_this_round < level.n_margwa_max )
	{
		while ( IS_TRUE( level.intermission ) )
			WAIT_SERVER_FRAME;
		
		while ( !IS_TRUE( level.b_margwa_zombies_enabled ) )
			WAIT_SERVER_FRAME;
		
		a_margwas = getAIArchetypeArray( "margwa" );
		
		if ( level.zombie_total > n_next_spawn || ( isDefined( a_margwas ) && a_margwas.size >= 3 ) )
		{
			WAIT_SERVER_FRAME;
			continue;
		}
		
		ai_margwa = margwa_zombie_spawn();

		if ( !isDefined( ai_margwa ) )
		{
			WAIT_SERVER_FRAME;
			continue;
		}

		if ( level.n_margwa_zombie_spawned_this_round == 0 )
			level.n_next_margwa_spawn_round = level.round_number + randomIntRange( 1, 2 + 1 );
		
		level.n_margwa_zombie_spawned_this_round++;

		n_next_spawn -= n_increment;
	}
	
}

function margwa_zombie_get_spawn_point()
{
	if ( !isDefined( level.zm_loc_types ) || !isArray( level.zm_loc_types ) )
		return undefined;
	
	if ( !isDefined( level.zm_loc_types[ "margwa_location" ] ) )
		return undefined;
	
	a_structs = level.zm_loc_types[ "margwa_location" ];
	
	s_struct = custom_spawn_location_selection( a_structs );
	return s_struct;
}

function margwa_zombie_spawn( s_struct )
{
	if ( !isDefined( s_struct ) )
		s_struct = margwa_zombie_get_spawn_point();
	
	if ( !isDefined( s_struct ) )
	{
		return undefined;
	}
	
	n_rand = randomInt( 3 );
	if ( n_rand == 0 )
		ai_margwa = zm_ai_margwa_elemental::function_26efbc37( undefined, s_struct );
	else if ( n_rand == 1 )
		ai_margwa = zm_ai_margwa_elemental::function_75b161ab( undefined, s_struct );
	else
		ai_margwa = zm_ai_margwa::function_8a0708c2( s_struct );
	
	if ( isDefined( ai_margwa ) )
	{

	}
	
	return ai_margwa;
}
