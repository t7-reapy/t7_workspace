/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//        **  **      ****      **        *******   ******    ****    **    ****     ****    if any of this is used//
//       ** ** **     ** **     **        **        **   **   ** **   **  **    **   ** **     plz creadit         //
//      **  **  **    ** *      **        ******    **    **  **  **  ** **      **  ** *       where its due      //
//     **        **   ** **     **        **        **   **   **   ** **  **    **   **  **          ***           //
//    **          **  **  **  * ********* *******   ******    **    ****    *****    **   **   wolf soul colleters //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\demo_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\util_shared;
#using scripts\shared\callbacks_shared;

#using scripts\shared\ai\zombie_death;
#using scripts\shared\ai\zombie_shared;
#using scripts\shared\ai\systems\gib;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\spawner_shared;
#using scripts\shared\scene_shared;

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
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_puppet;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_zonemgr;

#using scripts\shared\system_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\shared\ai\zombie.gsh;
#insert scripts\shared\ai\systems\gib.gsh;
#insert scripts\zm\_zm.gsh;
#insert scripts\zm\_zm_perks.gsh;





#precache( "model", "p6_zm_al_dream_catcher" );
#precache( "model", "p6_zm_al_dream_catcher_on" );
#precache( "model", "c_zom_zombie_mask_head" );
#precache( "model", "c_zom_wolf_head");
#precache( "model", "c_zom_test_body1");


#precache("fx", "lednors_wolfs/soul_charge_start");
#precache("fx", "lednors_wolfs/soul_charged");
#precache("fx", "lednors_wolfs/hell_portal");
#precache("fx", "lednors_wolfs/wolf_bite_blood");
#precache( "script_bundle", "wolf_bundle"  );

#using_animtree( "generic" );  

#namespace zm_wolf_soul_colletors;

REGISTER_SYSTEM_EX( "zm_wolf_soul_colletors", &init, undefined, undefined )

function init()
{
	level flag::init( "soul_catchers_charged" );

	level.soul_catchers = [];
	level.soul_catchers_vol = [];

	level.a_wolf_structs = GetEntArray( "wolf_position", "targetname" );
	i = 0;
	while ( i < level.a_wolf_structs.size )
	{
		level.soul_catchers[ i ] = level.a_wolf_structs[ i ];
		level.soul_catchers_vol[ i ] = GetEnt( level.soul_catchers[ i ].target, "targetname" );
		level.wolf_heads[ i ] = GetEnt( level.soul_catchers[ i ].script_label, "targetname" );
		level.wolf_heads[ i ] UseAnimTree(#animtree);
		level.wolf_heads[ i ] Hide();
		level.soul_catchers[ i ].head = level.wolf_heads[ i ];
		level.soul_catchers[ i ].wolf_kill_cooldown = 0;
		level.wolf_bodies[ i ] = GetEnt( level.soul_catchers[ i ].script_friendname, "targetname" );
		level.wolf_bodies[ i ] UseAnimTree(#animtree);
		level.wolf_bodies[ i ] SetModel("tag_origin");
		level.wolf_bodies[ i ] Hide();
		level.soul_catchers[ i ].body = level.wolf_bodies[ i ];
		level.wolf_runes[ i ] = GetEnt(  level.soul_catchers[i].script_noteworthy, "targetname" );
		level.soul_catchers[ i ].rune = level.wolf_runes[ i ];
		i++;
	}
	level flag::wait_till( "all_players_connected" );
	level.no_gib_in_wolf_area = &check_for_zombie_in_wolf_area;
	level.soul_catcher_clip[ "rune_2" ] = GetEnt( "wolf_clip_docks", "targetname" );
	level.soul_catcher_clip[ "rune_3" ] = GetEnt( "wolf_clip_infirmary", "targetname" );
	_a24 = level.soul_catcher_clip;
	_k24 = GetFirstArrayKey( _a24 );
	while ( isdefined( _k24 ) )
	{
		e_clip = _a24[ _k24 ];
		e_clip SetInvisibleToAll();
		e_clip ConnectPaths();
		_k24 = GetNextArrayKey( _a24, _k24 );
	}
	level thread create_anim_references_on_server();
	
	i = 0;
	while ( i < level.soul_catchers.size )
	{
		level.soul_catchers[ i ].souls_received = 0;
		level.soul_catchers[ i ].is_eating = 0;
		level.soul_catchers[ i ] thread soul_catcher_check();
		if ( zm_utility::is_classic() )
		{
			level.soul_catchers[ i ] thread soul_catcher_state_manager( i );
		}
		else
		{
			level.soul_catchers[ i ] thread grief_soul_catcher_state_manager( i );
		}
		level.soul_catchers[ i ] thread wolf_head_removal( "tomahawk_door_sign_" + ( i + 1 ) );
		level.soul_catchers_vol[ i ] = GetEnt( level.soul_catchers[ i ].target, "targetname" );
		i++;
	}
	level.soul_catchers_charged = 0;
	level thread soul_catchers_charged();
	level thread get_the_zoms();
}

function create_anim_references_on_server()
{
	root = %root;
	wolfhead_intro_anim = %o_zombie_dreamcatcher_intro;
	wolfhead_outtro_anim = %o_zombie_dreamcatcher_outtro;
	woflhead_idle_anims = [];
	wolfhead_idle_anim[ 0 ] = %o_zombie_dreamcatcher_idle;
	wolfhead_idle_anim[ 1 ] = %o_zombie_dreamcatcher_idle_twitch_scan;
	wolfhead_body_death = %ai_zombie_dreamcatch_impact;
	wolfhead_body_float = %ai_zombie_dreamcatch_rise;
	wolfhead_body_shrink = %ai_zombie_dreamcatch_shrink_a;
	level.wolfhead_pre_eat_anims = [];
	level.wolfhead_pre_eat_anims[ "right" ] = %o_zombie_dreamcatcher_wallconsume_pre_eat_r;
	level.wolfhead_pre_eat_anims[ "left" ] = %o_zombie_dreamcatcher_wallconsume_pre_eat_l;
	level.wolfhead_pre_eat_anims[ "front" ] = %o_zombie_dreamcatcher_wallconsume_pre_eat_f;
	level.wolfhead_eat_anims[ "right" ] = %o_zombie_dreamcatcher_wallconsume_align_r;
	level.wolfhead_eat_anims[ "left" ] = %o_zombie_dreamcatcher_wallconsume_align_l;
	level.wolfhead_eat_anims[ "front" ] = %o_zombie_dreamcatcher_wallconsume_align_f;
	level.wolfhead_body_anims[ "right" ] = %ai_zombie_dreamcatcher_wallconsume_align_r;
	level.wolfhead_body_anims[ "left" ] = %ai_zombie_dreamcatcher_wallconsume_align_l;
	level.wolfhead_body_anims[ "front" ] = %ai_zombie_dreamcatcher_wallconsume_align_f;
}

function soul_catcher_state_manager (index)
{
	wait 1;
	if ( self.script_noteworthy == "rune_3" )
	{
		trigger = GetEnt( "wolf_hurt_trigger", "targetname" );
		trigger Hide();
	}
	else
	{
		if ( self.script_noteworthy == "rune_2" )
		{
			trigger = GetEnt( "wolf_hurt_trigger_docks", "targetname" );
			trigger Hide();
		}
	}
	level thread wolf_state_0(index);
	self waittill( "first_zombie_killed_in_zone" );
	//IPrintLnBold("first zombie_dead");
	if ( self.script_noteworthy == "rune_3" )
	{
		trigger = GetEnt( "wolf_hurt_trigger", "targetname" );
		trigger Show();
	}
	else
	{
		if ( self.script_noteworthy == "rune_2" )
		{
			trigger = GetEnt( "wolf_hurt_trigger_docks", "targetname" );
			trigger Show();
		}
	}
	if ( isdefined( level.soul_catcher_clip[ self.script_noteworthy ] ) )
	{
		level.soul_catcher_clip[ self.script_noteworthy ] SetVisibleToAll();
		level.soul_catcher_clip[ self.script_noteworthy ] DisconnectPaths();
	}
	level thread wolf_state_1(index);
	anim_length = GetAnimLength( %o_zombie_dreamcatcher_intro );
	wait anim_length;
	self waittill( "finished_eating" );
	while ( !self.is_charged )
	{
		wait 0.05;
		level thread wolf_state_2(index);
		self waittill( "finished_eating" );
		//IPrintLnBold("finished_eating or fully_charged");
	}
	//IPrintLnBold("filling done");
	level thread wolf_state_6(index);
	anim_length = GetAnimLength( %o_zombie_dreamcatcher_outtro );
	wait anim_length;
	if ( isdefined( level.soul_catcher_clip[ self.script_noteworthy ] ) )
	{
		level.soul_catcher_clip[ self.script_noteworthy ] Delete();
		level.soul_catcher_clip[ self.script_noteworthy ] ConnectPaths();
	}
	if ( self.script_noteworthy == "rune_3" )
	{
		trigger = GetEnt( "wolf_hurt_trigger", "targetname" );
		trigger Delete();
	}
	else
	{
		if ( self.script_noteworthy == "rune_2" )
		{
			trigger = GetEnt( "wolf_hurt_trigger_docks", "targetname" );
			trigger Delete();
		}
	}
	level thread wolf_state_7(index);
	//IPrintLnBold("nothig");
}

function wolf_state_0(index)
{
	rune = level.wolf_runes[index];
	rune_forward = AnglesToForward( rune.angles + VectorScale( ( 0, 1, 0 ), 90 ) );
	rune_up = AnglesToUp( rune.angles );
	level.wolf_heads[index].portal_fx = Spawn("script_model", ( rune.origin - rune_forward * 2.5 ) - rune_up * 24 );
	level.wolf_heads[index].portal_fx SetModel("tag_origin");
	level.wolf_heads[index] Hide();
	level.wolf_runes[ index ] Show();
	level.wolf_bodies[index] Hide();
}

function wolf_state_1(index)
{
	//IPrintLnBold("first zombie_dead");
	level.wolf_heads[index] Show();
	level.wolf_runes[index] Hide();
	level.wolf_bodies[index] Hide();
	level.wolf_heads[index] thread wolfhead_arrive(  level.wolf_runes[index] );
}

function wolfhead_arrive( rune )
{
	rune_forward = AnglesToForward( rune.angles + VectorScale( ( 0, 1, 0 ), 90 ) );
	rune_up = AnglesToUp( rune.angles );
	rune.portal_fx = Spawn("script_model", rune.origin + (0,0,10) );
	rune.portal_fx SetModel("tag_origin");
	rune.portal_fx.angles = rune.angles + (0,90,0);
	PlayFXOnTag(level._effect["hell_portal"],rune.portal_fx, "tag_origin" );
	self.portal_fx = PlayFX(  level._effect["hell_portal"],  ( rune.origin - rune_forward * 2.5 ) - rune_up * 24, rune_forward, rune_up  );
	self PlaySound(  "evt_wolfhead_spawn" );
	self.wolf_ent = Spawn( "script_origin", self.origin );
	self.wolf_ent PlayLoopSound( "evt_wolfhead_fire_loop" );
	n_anim_length = GetAnimLength( %o_zombie_dreamcatcher_intro );
	self AnimScripted( "notify", self.origin, self.angles, %o_zombie_dreamcatcher_intro, "normal", %o_zombie_dreamcatcher_intro, 1, 0.3 );
	wait n_anim_length;
}

function wolf_state_2( index )
{
	//IPrintLnBold("wolf_state_2");
	level.wolf_heads[index] Show();
	level.wolf_runes[index] Hide();
	level.wolf_bodies[index] Hide();
	level.wolf_bodies[index].head.hat Hide();
	level.wolf_bodies[index].head Hide();
	level.wolf_heads[index] thread wolfhead_idle();
}

function wolfhead_idle()
{
	self endon( "wolf_eating" );
	self endon( "wolf_departing" );
	self notify( "wolf_idling" );
	//IPrintLnBold("wolf_idling");
	level.wolf_head_idle_anims = [];
	level.wolf_head_idle_anims[0] = %o_zombie_dreamcatcher_idle;
	level.wolf_head_twitch_anims = [];
	level.wolf_head_twitch_anims[0] = %o_zombie_dreamcatcher_idle_twitch_scan;
	while(1)
	{
		random_idle_anim = array::random( level.wolf_head_idle_anims );
		n_anim_length = GetAnimLength( random_idle_anim );
		//IPrintLnBold("now playing " + random_idle_anim + " anim");
		self AnimScripted( "notify", self.origin, self.angles, random_idle_anim, "normal", random_idle_anim, 1, 0.3 );
		wait n_anim_length;
		random_twitch_anim = array::random( level.wolf_head_twitch_anims );
		n_anim_length = GetAnimLength( random_twitch_anim );
		//IPrintLnBold("now playing " + random_twitch_anim + " anim");
		self AnimScripted( "notify", self.origin, self.angles, random_twitch_anim, "normal", random_twitch_anim, 1, 0.3 );
		wait n_anim_length;
	}
}

function wolf_state_6(index)
{
	level.wolf_heads[index] Show();
	level.wolf_runes[index] Show();
	level.wolf_bodies[index] Hide();
	level.wolf_bodies[index].head Hide();
	level.wolf_runes[index] StopLoopSound();
	level.wolf_bodies[index].head.hat Hide();
	level.wolf_heads[index] thread wolfhead_depart( level.wolf_runes[index] );
}

function wolfhead_depart( rune )
{   
	//IPrintLnBold("now playing " + %o_zombie_dreamcatcher_outtro + " anim");
	self AnimScripted( "notify", self.origin, self.angles, %o_zombie_dreamcatcher_outtro, "normal", %o_zombie_dreamcatcher_outtro, 1, 0.3 );
	rune_forward = AnglesToForward( rune.angles + VectorScale( ( 0, 1, 0 ), 90 ) );
	rune_up = AnglesToUp( rune.angles );
	rune.portal_fx Delete();
	self.portal_fx = PlayFX( level._effect["hell_portal_close"], ( rune.origin - rune_forward * 2.5 ) - rune_up * 24, rune_forward, rune_up);
	self PlaySound( "evt_wolfhead_depart" );
	self.wolf_ent StopLoopSound();
	self.wolf_ent Delete();
	self notify( "wolf_departing" );
}

function wolf_state_7(index)
{ 
	//IPrintLnBold("wolf done, setting model to dream catcher on");
	level.wolf_heads[index] Hide();
	level.wolf_runes[index] Show();
	level.wolf_bodies[index] Hide();
	level.wolf_bodies[index].head Hide();
	level.wolf_bodies[index].head.hat Hide();
	level.wolf_runes[index] SetModel( "p6_zm_al_dream_catcher_on" );
	PlayFXOnTag(  level._effect["soul_charged"], level.wolf_runes[index], "tag_origin" );
	level.wolf_runes[index] PlayLoopSound( "evt_runeglow_loop" );
}

function wolf_state_eat(index , n_eating_anim ,zombie)
{
	if( n_eating_anim == 3)
	{
		level.wolf_heads[index] thread wolfhead_eat_aligned( zombie, "front", index );
	}
	if( n_eating_anim == 4)
	{
		level.wolf_heads[index] thread wolfhead_eat_aligned( zombie, "right", index );
	}
	if( n_eating_anim == 5)
	{
		level.wolf_heads[index] thread wolfhead_eat_aligned( zombie, "left", index );
	}
}

function wolfhead_eat_aligned( zombie ,direction, index )
{
	self endon( "wolf_idling" );
	self endon( "wolf_departing" );
	self notify( "wolf_eating" );
	level.wolf_bodies[ index ] EnableLinkTo();
	zombie EnableLinkTo();
	zombie LinkTo(level.wolf_bodies[ index ]);
	self wolfhead_pre_eat_aligned( zombie,  direction );
	level.wolf_bodies[ index ].origin = self GetTagOrigin( "j_tongue_1" );//tag_mouth_fx
	level.wolf_bodies[ index ].angles = self GetTagAngles( "j_tongue_1" );//tag_mouth_fx
	zombie.angles = self GetTagAngles( "j_tongue_1" );//tag_mouth_fx
	level.wolf_bodies[ index ] LinkTo( self, "j_tongue_1", ( 0, 0, 0 ), ( 0, 0, 0 ) );
	n_anim_length = GetAnimLength( level.wolfhead_eat_anims[direction] );
	self thread play_blood_fx_on_bite();
	//IPrintLnBold("now playing " + level.wolfhead_eat_anims[direction] + " anim");
	self AnimScripted( "notify", self.origin, self.angles, level.wolfhead_eat_anims[direction], "normal", level.wolfhead_eat_anims[direction], 1, 0.3 ); 
	zombie AnimScripted( "notify", zombie.origin, zombie.angles, level.wolfhead_body_anims[direction], "normal", level.wolfhead_body_anims[direction], 1, 0.3 ); 
	//IPrintLnBold("now playing " + level.wolfhead_body_anims[direction] + " anim");
	wait n_anim_length;
	self PlaySound( "evt_wolfhead_eat" );
	self Unlink();
	zombie Delete();
	level.wolf_bodies[ index ] Unlink();
}

function wolfhead_pre_eat_aligned( zombie, direction )
{
	s_closest = util::get_array_of_closest( self.origin, level.a_wolf_structs );
	m_body = s_closest[0].body;
	m_wolf = s_closest[0].head;
	//IPrintLnBold("now playing " + level.wolfhead_pre_eat_anims[direction] + " anim");
	m_wolf AnimScripted( "notify", m_wolf.origin, m_wolf.angles, level.wolfhead_pre_eat_anims[direction], "normal", level.wolfhead_pre_eat_anims[direction], 1, 0.3 );
	m_body Unlink();
	m_body Show();
	m_body body_moveto_wolf( m_wolf, zombie );
}

function play_blood_fx_on_bite(  )
{
	self waittill( "bite", note );
	PlayFXOnTag(  level._effect["soul_charge_impact"], self, "tag_mouth_fx" );
	PlayFXOnTag( level._effect["wolf_bite_blood"], self, "tag_mouth_fx" );
}

function body_moveto_wolf( m_wolf, zombie )
{
	self.m_soul_fx_player = Spawn(  self GetTagOrigin( "J_SpineLower" ), "script_model" );
	self.m_soul_fx_player SetModel( "tag_origin" );
	zombie AnimScripted( "notify", zombie.origin, zombie.angles, %ai_zombie_dreamcatch_rise, "normal", %ai_zombie_dreamcatch_rise, 1, 0.3 );
	vec_dir = m_wolf.origin - self.origin;
	vec_dir_scaled = VectorScale( vec_dir, 0.2 );
	self.m_soul_fx_player.angles = VectortoAngles( vec_dir );
	self.m_soul_fx_player LinkTo( self );
	PlayFXOnTag(  level._effect["soul_charge_start"], self, "tag_origin" );
	self PlaySound( "evt_soulsuck_body" );
	self MoveTo( self.origin + vec_dir_scaled, 1.5, 1.5 );
	self waittill( "movedone" );
	zombie.angles = self.angles;
	zombie AnimScripted( "notify", zombie.origin, zombie.angles, %ai_zombie_dreamcatch_shrink_a, "normal", %ai_zombie_dreamcatch_shrink_a, 1, 0.3 );
	zombie_move_offset = AnglesToForward( m_wolf.angles ) * 36 + AnglesToUp( m_wolf.angles ) * 0;
	self MoveTo( m_wolf.origin + zombie_move_offset, 0.5, 0.5 );
	self waittill( "movedone" );
	self.m_soul_fx_player Unlink();
	self.m_soul_fx_player Delete();
	self.m_soul_fx_player = undefined;
}

function grief_soul_catcher_state_manager( index )
{
	wait 1;
	while ( 1 )
	{
		level thread wolf_state_0(index);
		self waittill( "first_zombie_killed_in_zone" );
		if ( isdefined( level.soul_catcher_clip[ self.script_noteworthy ] ) )
		{
			level.soul_catcher_clip[ self.script_noteworthy ] SetVisibleToAll();
			level.soul_catcher_clip[ self.script_noteworthy ] DisconnectPaths();
		}
		level thread wolf_state_1(index);
		anim_length = GetAnimLength( %o_zombie_dreamcatcher_intro );
		wait anim_length;
		while ( !self.is_charged )
		{
			level thread wolf_state_2(index);
			self util::waittill_either( "fully_charged", "finished_eating" );
		}
		level thread wolf_state_6(index);
		anim_length = GetAnimLength( %o_zombie_dreamcatcher_outtro );
		wait anim_length;
		if ( isdefined( level.soul_catcher_clip[ self.script_noteworthy ] ) )
		{
			level.soul_catcher_clip[ self.script_noteworthy ] SetInvisibleToAll();
			level.soul_catcher_clip[ self.script_noteworthy ] ConnectPaths();
		}
		self.souls_received = 0;
		level thread wolf_spit_out_powerup();
		wait 20;
		self thread soul_catcher_check();
	}
}

function soul_catcher_check()
{
	self.is_charged = 0;
	while ( 1 )
	{
		if ( self.souls_received >= 6 )
		{
			level.soul_catchers_charged++;
			self.is_charged = 1;
			self notify( "fully_charged" );
			//IPrintLnBold("fully_charged");
			break;
		}
		else
		{
			wait 0.05;
		}
	}
	if ( level.soul_catchers_charged == 1 )
	{
		self thread first_wolf_complete_vo();
	}
	else
	{
		if ( level.soul_catchers_charged >= level.soul_catchers.size )
		{
			self thread final_wolf_complete_vo();
		}
	}
}

function wolf_spit_out_powerup()
{
	if ( isdefined( level.enable_magic ) && !level.enable_magic )
	{
		return;
	}
	power_origin_struct = struct::get( "wolf_puke_powerup_origin", "targetname" );
	if ( randomint( 100 ) < 20 )
	{
		i = 0;
		while ( i < level.zombie_powerup_array.size )
		{
			if ( level.zombie_powerup_array[ i ] == "meat_stink" )
			{
				level.zombie_powerup_index = i;
				found = 1;
				break;
			}
			else
			{
				i++;
			}
		}
	}
	else
	{
		level.zombie_powerup_index = RandomInt( level.zombie_powerup_array.size );
		while ( level.zombie_powerup_array[ level.zombie_powerup_index ] == "nuke" )
		{
			wait 0.05;
		}
	}
	spawn_infinite_powerup_drop( power_origin_struct.origin, level.zombie_powerup_array[ level.zombie_powerup_index ] );
	power_ups = util::get_array_of_closest( power_origin_struct.origin, level.active_powerups, undefined, undefined, 100 );
	if ( isdefined( power_ups[ 0 ] ) )
	{
		power_ups[ 0 ] MoveZ( 120, 4 );
	}
}

function get_the_zoms()
{
	while(1)
	{
		wait(.1); 
		zoms = GetAISpeciesArray("axis"); 
		for (i=0;i<zoms.size;i++)
		{
			if ( isdefined(zoms[i].is_accounted) && zoms[i].is_accounted == true)
			{

			}
			else
			{
				if(isdefined(zoms[i].is_brutus) && zoms[i].is_brutus)
				{

				}
				else
				{
					zoms[i].is_accounted = true;
					zoms[i] thread watch_for_death(); 
				}
			}
			
		}
	}
}

function watch_for_death()
{   
   // level flag::wait_till( "power_on" );//add a gsh with a flag 
	self waittill("death", attacker);
	//IPrintLnBold("zombie_died");
	i = 0;
	while ( i < level.soul_catchers.size )
	{
		if ( self IsTouching( level.soul_catchers_vol[ i ] ) && !level.soul_catchers[ i ].is_charged)
		{
			if ( level.soul_catchers[ i ].is_eating == true)
			{
				return;
			}
			if ( level.soul_catchers[ i ].souls_received >= 6 )
			{
				return;
			}
			if(!isdefined(self))
			{
				return;
			}
			if(!isdefined(attacker) || !IsPlayer(attacker))
			{
				return;
			}
			if ( level flag::exists( "dog_round" ) && level flag::get( "dog_round" ) ) 
			{
			     return;
			}
			if ( level flag::exists( "apothicon_fury_round" ) && level flag::get( "apothicon_fury_round" ) ) 
			{
			     return;
			}
			if( self.archetype == "ally_zod_robot_companion_ar" ) 
            {
                 return;
            }
			
			self.my_soul_catcher = level.soul_catchers[ i ];
			if ( isdefined( self.my_soul_catcher.souls_received ) && self.my_soul_catcher.souls_received == 0 )
			{
				if ( isdefined( level.wolf_encounter_vo_played ) && !level.wolf_encounter_vo_played )
				{
					if ( level.soul_catchers_charged == 0 )
					{
						self.my_soul_catcher thread first_wolf_encounter_vo();
					}
				}
			}
			origin = self.origin;
			self Hide();
			level.soul_catchers[ i ].is_eating = true;
			clone = self get_zombie_clone();
			clone UseAnimTree(#animtree);
			clone thread do_impact_anim();
			if ( level.soul_catchers[ i ].souls_received == 0 )
			{
				level.soul_catchers[ i ] notify( "first_zombie_killed_in_zone" );
				level.soul_catchers[ i ] thread notify_wolf_intro_anim_complete();
			}
			if ( level.soul_catchers[ i ].souls_received == 0 )
			{
				level.soul_catchers[ i ] waittill( "wolf_intro_anim_complete" );
			}
			while(!isdefined(clone.wolf_impact_done))
			{
				wait 0.05;
			}
			clone.my_soul_catcher = level.soul_catchers[ i ];
			clone pose_dead_body();
			n_eating_anim = clone which_eating_anim();
			level thread wolf_state_eat(i , n_eating_anim,clone);
			if ( n_eating_anim == 3 )
			{
				total_wait_time = 3 + GetAnimLength( %ai_zombie_dreamcatcher_wallconsume_align_f );
			}
			else if ( n_eating_anim == 4 )
			{
				total_wait_time = 3 + GetAnimLength( %ai_zombie_dreamcatcher_wallconsume_align_r );
			}
			else
			{
				total_wait_time = 3 + GetAnimLength( %ai_zombie_dreamcatcher_wallconsume_align_l );
			}
			wait ( total_wait_time - 0.5 );
			level.soul_catchers[ i ].souls_received++;
			wait 0.5;
			level.soul_catchers[ i ] notify( "finished_eating" );
			//IPrintLnBold("finished_eating");
			level.soul_catchers[ i ].is_eating = false;
			clone Delete();
			return;
		}
		i++;
	}
}

function get_zombie_clone()
{
	gib_ref = "";
	if(IsDefined( self.a.gib_ref ))
	{
		gib_ref = self.a.gib_ref; 
	} 
	
	limb_data = getLimbData( gib_ref, self);
	zombie_clone = spawn("script_model", self.origin);
	zombie_clone.angles = self.angles;
	zombie_clone SetModel( limb_data["body"] );
	zombie_clone Attach( limb_data["head"] );
	zombie_clone Attach( limb_data["legs"] );
	self Delete();
	
	return zombie_clone; 	
}

function getLimbData(gib_ref, zombie)
{
    temp_array = [];
 
    temp_array["head"] = "c_zom_zombie_mask_head";
    temp_array["body"] = zombie.torsoDmg1;
    temp_array["legs"] = zombie.legDmg1;
    temp_array["type"] = "zombie";

    if(gib_ref == "right_arm")
    {  
        if(IsDefined( zombie.torsoDmg2 ))
        {
            temp_array["body"] = zombie.torsoDmg2;
            return temp_array;
        }
    }
 
    if(gib_ref == "left_arm")
    {
        if(IsDefined( zombie.torsoDmg3 ))
        {
            temp_array["body"] = zombie.torsoDmg3;
        }
    }

    if(gib_ref == "guts")
    {
        if(IsDefined( zombie.torsoDmg4 ))
        {
            temp_array["body"] = zombie.legDtorsoDmg4mg3;
        }
    }

    if(gib_ref == "head")
    {
        if(IsDefined( zombie.torsoDmg5 ))
        {
            temp_array["body"] = zombie.torsoDmg5;
        }
    }
 
    if(gib_ref == "right_leg")
    {  
        if(IsDefined( zombie.legDmg2 ))
        {
            temp_array["legs"] = zombie.legDmg2;
            temp_array["type"] = "crawler";
        }
    }
 
    if(gib_ref == "left_leg")
    {
        if(IsDefined( zombie.legDmg3 ))
        {
            temp_array["legs"] = zombie.legDmg3;
            temp_array["type"] = "crawler";
        }
    }
 
    if(gib_ref == "no_legs")
    {
        if(IsDefined( zombie.legDmg4 ))
        {
            temp_array["legs"] = zombie.legDmg4;
            temp_array["type"] = "crawler";
        }
    }
 
    return temp_array;
}

function do_impact_anim()
{
	self.wolf_impact_done = undefined;
	self AnimScripted( "notify" , self.origin , self.angles, %ai_zombie_dreamcatch_impact);
	wait GetAnimLength(%ai_zombie_dreamcatch_impact) - 0.1;
	self.noragdoll = true;
	self.nodeathragdoll = true;
	self.wolf_impact_done = true;
}

function pose_dead_body()
{
	s_closest = util::get_array_of_closest( self.origin, level.a_wolf_structs );
	m_body = s_closest[0].body;
	m_wolf = s_closest[0].head;
	m_body.origin = self.origin;
	m_body.angles = self.angles;
}

function check_for_zombie_in_wolf_area()
{
	i = 0;
	while ( i < level.soul_catchers.size )
	{
		if ( self IsTouching( level.soul_catchers_vol[ i ] ) )
		{
			if ( !level.soul_catchers[ i ].is_charged && !level.soul_catchers[ i ].is_eating )
			{
				return 1;
			}
		}
		i++;
	}
	return 0;
}

function notify_wolf_intro_anim_complete()
{
	anim_length = GetAnimLength( %o_zombie_dreamcatcher_intro );
	wait anim_length;
	self notify( "wolf_intro_anim_complete" );
}

function which_eating_anim()
{
	soul_catcher = self.my_soul_catcher;
	forward_dot = VectorDot( AnglesToForward( soul_catcher.angles ), VectorNormalize( self.origin - soul_catcher.origin ) );
	if ( forward_dot > 0.85 )
	{
		return 3;
	}
	else
	{
		right_dot = VectorDot( AnglesToRight( soul_catcher.angles ), self.origin - soul_catcher.origin );
		if ( right_dot > 0 )
		{
			return 4;
		}
		else
		{
			return 5;
		}
	}
}

function wolf_head_removal( wolf_head_model_string )
{
	wolf_head_model = GetEnt( wolf_head_model_string, "targetname" );
	wolf_head_model SetModel( "p6_zm_al_dream_catcher" );
	self waittill( "fully_charged" );
	wolf_head_model SetModel( "p6_zm_al_dream_catcher_on" );
}

function soul_catchers_charged()
{

	while ( 1 )
	{
		if ( level.soul_catchers_charged >= level.soul_catchers.size )
		{
			//IPrintLnBold("there are " + level.soul_catchers.size + " wolves");
			level flag::set( "soul_catchers_charged" );
			level notify( "soul_catchers_charged" );
			door_models = GetEntArray("pap_wall","targetname");
			foreach(door in door_models)
			{
			  door thread door_remove(); 
			}
			return;
		}
		else
		{
			wait 1;
		}
	}
}

function door_remove()
{
	self.origin = self.origin - (0,0,1000);
	self ConnectPaths();
	self Delete();
}

function first_wolf_encounter_vo()
{
	if ( !zm_utility::is_classic() )
	{
		return;
	}
	wait 2;
	a_players = GetPlayers();
	a_closest = util::get_array_of_closest( self.origin, a_players );
	i = 0;
	while ( i < a_closest.size )
	{
		if ( isdefined( a_closest[ i ].dontspeak ) && !a_closest[ i ].dontspeak )
		{
			a_closest[ i ] thread zm_utility::do_player_general_vox( "general", "wolf_encounter" );
			level.wolf_encounter_vo_played = 1;
			return;
		}
		else
		{
			i++;
		}
	}
}

function first_wolf_complete_vo()
{
	if ( !zm_utility::is_classic() )
	{
		return;
	}
	wait 3.5;
	a_players = GetPlayers();
	a_closest = util::get_array_of_closest( self.origin, a_players );
	i = 0;
	while ( i < a_closest.size )
	{
		if ( isdefined( a_closest[ i ].dontspeak ) && !a_closest[ i ].dontspeak )
		{
			a_closest[ i ] thread zm_utility::do_player_general_vox( "general", "wolf_complete" );
			return;
		}
		else
		{
			i++;
		}
	}
}

function final_wolf_complete_vo()
{
	if ( !zm_utility::is_classic() )
	{
		return;
	}
	wait 3.5;
	a_players = GetPlayers();
	a_closest = util::get_array_of_closest( self.origin, a_players );
	i = 0;
	while ( i < a_closest.size )
	{
		if ( isdefined( a_closest[ i ].dontspeak ) && !a_closest[ i ].dontspeak )
		{
			return;
		}
		else
		{
			i++;
		}
	}
}

function tomahawk_upgrade_quest()
{

}

function toggle_redeemer_trigger()
{

}

function hellhole_projectile_watch()
{

}

function hellhole_tomahawk_watch()
{

}

function hellhole_grenades( grenade )
{

}

function hellhole_tomahawk( grenade )
{

}

function spawn_infinite_powerup_drop( v_origin, str_type )
{

}