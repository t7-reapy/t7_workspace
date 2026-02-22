#using scripts\codescripts\struct;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\callbacks_shared; 
#using scripts\shared\flag_shared;
#using scripts\shared\math_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_utility;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#precache( "model", "c_t7_zm_dlchd_shangrila_nva_mini_head2" );
#precache( "model", "c_t7_zm_dlchd_shangrila_nva_mini_body" );
#precache( "model", "c_t7_zm_dlchd_shangrila_nva_mini_g_blegsoff" );
#precache( "model", "c_t7_zm_dlchd_shangrila_nva_mini_g_larmoff" );
#precache( "model", "c_t7_zm_dlchd_shangrila_nva_mini_g_llegoff" );
#precache( "model", "c_t7_zm_dlchd_shangrila_nva_mini_g_loclean" );
#precache( "model", "c_t7_zm_dlchd_shangrila_nva_mini_g_rarmoff" );
#precache( "model", "c_t7_zm_dlchd_shangrila_nva_mini_g_rlegoff" );
#precache( "model", "c_t7_zm_dlchd_shangrila_nva_mini_g_upclean" );
#precache( "fx", "dlc5/temple/fx_ztem_zombie_mini_squish" );
#precache( "fx", "dlc5/temple/fx_ztem_zombie_mini_drown" );
#precache( "fx", "dlc5/temple/fx_ztem_monkey_shrink" );
#precache( "fx", "dlc5/zmb_weapon/fx_shrink_ray_zombie_shrink" );
#precache( "fx", "dlc5/zmb_weapon/fx_shrink_ray_zombie_unshrink" );

#namespace zm_weap_shrink_ray;

function autoexec __init__sytem__()
{
	system::register("zm_weap_shrink_ray", &__init__, &__main__, undefined);
}

function __init__()
{
	clientfield::register("actor", "fun_size", VERSION_SHIP, 1, "int");
	level.shrink_models = [];
	zombie_utility::set_zombie_var("shrink_ray_fling_range", 480);
	level._effect["shrink_ray_stepped_on"] = "dlc5/temple/fx_ztem_zombie_mini_squish";
	level._effect["shrink_ray_stepped_on_in_water"] = "dlc5/temple/fx_ztem_zombie_mini_drown";
	level._effect["shrink_ray_stepped_on_no_gore"] = "dlc5/temple/fx_ztem_monkey_shrink";
	level._effect["shrink"] = "dlc5/zmb_weapon/fx_shrink_ray_zombie_shrink";
	level._effect["unshrink"] = "dlc5/zmb_weapon/fx_shrink_ray_zombie_unshrink";
	callback::on_spawned(&function_37ce705e);
	level.var_c50bd012 = [];
	level.w_shrink_ray = getweapon("shrink_ray");
	level.w_shrink_ray_upgraded = getweapon("shrink_ray_upgraded");
	zm::register_player_damage_callback(&function_19171a77);

	level.shrink_ray_model_mapping_func = &temple_shrink_ray_model_mapping_func;
}

function __main__()
{
	if(isdefined(level.shrink_ray_model_mapping_func))
	{
		[[level.shrink_ray_model_mapping_func]]();
	}
}

function add_shrinkable_object(ent)
{
	array::add(level.var_c50bd012, ent, 0);
}

function remove_shrinkable_object(ent)
{
	arrayremovevalue(level.var_c50bd012, ent);
}

function function_ebf92008()
{
	while(true)
	{
		level.var_1b24c8b0 = 0;
		util::wait_network_frame();
	}
}

function function_37ce705e()
{
	self endon("disconnect");
	for(;;)
	{
		self waittill("weapon_fired");
		currentweapon = self getcurrentweapon();
		if(currentweapon == level.w_shrink_ray || currentweapon == level.w_shrink_ray_upgraded)
		{
			self thread function_fe7a4182(currentweapon == level.w_shrink_ray_upgraded);
		}
	}
}

function function_19171a77(e_inflictor, e_attacker, n_damage, n_dflags, str_means_of_death, w_weapon, v_point, v_dir, str_hit_loc, psoffsettime, b_damage_from_underneath, n_model_index, str_part_name)
{
	if(isdefined(e_inflictor))
	{
		if(isdefined(e_inflictor.shrinked) && e_inflictor.shrinked)
		{
			return 5;
		}
	}
	return n_damage;
}

function function_fe7a4182(upgraded)
{
	zombies = function_66ab6f95(upgraded, 0);
	objects = function_66ab6f95(upgraded, 1);
	zombies = arraycombine(zombies, objects, 1, 0);
	var_744b41f1 = 1000;
	for(i = 0; i < zombies.size && i < var_744b41f1; i++)
	{
		if(isai(zombies[i]))
		{
			zombies[i] thread shrink_zombie(upgraded, self);
			continue;
		}
		zombies[i] notify("shrunk", upgraded);
	}
}

function function_20c24bab(upgraded, player)
{
	damage = 10;
	self dodamage(damage, player.origin, player, undefined, "projectile");
	self function_9ae4cf1b(damage, (0, 1, 0));
}

function function_9af5d92d(upgraded, e_attacker)
{
	if(isdefined(self.shrinked) && self.shrinked)
	{
		return;
	}
	self.shrinked = 1;
	var_36333499 = self getattachsize();
	for(i = var_36333499 - 1; i >= 0; i--)
	{
		model = self getattachmodelname(i);
		self detach(model);
		var_89a773f5 = level.shrink_models[model];
		if(isdefined(var_89a773f5))
		{
			self attach(var_89a773f5);
		}
	}
	var_87aa5c26 = level.shrink_models[self.model];
	if(isdefined(var_87aa5c26))
	{
		self setmodel(var_87aa5c26);
	}
}

function shrink_zombie( upgraded, e_attacker )
{
	self endon( "death" );
	if ( IS_TRUE( self.b_shrinked ) )
		return;
	
	if ( !isDefined( self.n_shrink_count ) )
		self.n_shrink_count = 0;
	
	n_shrink_time = 2.5;
	if ( self.animname == "sonic_zombie" )
	{
		if ( self.n_shrink_count == 0 )
			n_shrink_time = .75;
		else
		{
			if ( self.n_shrink_count == 1 )
				n_shrink_time = 1.5;
			else
				n_shrink_time = 2.5;
			
		}
	}
	else
	{
		if ( self.animname == "napalm_zombie" )
		{
			if ( self.n_shrink_count == 0 )
				n_shrink_time = .75;
			else
			{
				if ( self.n_shrink_count == 1 )
					n_shrink_time = 1.5;
				else
					n_shrink_time = 2.5;
				
			}
		}
		else
		{
			n_shrink_time = 2.5;
			n_shrink_time = n_shrink_time + randomFloatRange( 0, .5 );
		}
	}
	if ( upgraded )
		n_shrink_time = n_shrink_time * 2;
	
	self.n_shrink_count++;
	n_shrink_fx_wait = 0;
	if ( isActor( self ) )
		self clientfield::set( "fun_size", 1 );
	
	self notify( "shrink" );
	self.b_shrinked = 1;
	self.e_shrink_attacker = e_attacker;
	self.kill_on_wine_coccon = 1;
	if ( !isDefined( e_attacker.b_shrinked_zombies ) )
		e_attacker.b_shrinked_zombies = [];
	
	if ( !isDefined( e_attacker.b_shrinked_zombies[ self.animname ] ) )
		e_attacker.b_shrinked_zombies[ self.animname ] = 0;
	
	e_attacker.b_shrinked_zombies[ self.animname ]++;
	str_normal_model = self.model;
	n_health = self.health;
	if ( isDefined( self.animname ) && self.animname == "monkey_zombie" )
	{
		if ( isDefined( self.shrink_ray_fling ) )
			self [ [ self.shrink_ray_fling ] ]( e_attacker );
		else
		{
			n_fling_range_squared = level.zombie_vars[ "shrink_ray_fling_range" ] * level.zombie_vars[ "shrink_ray_fling_range" ];
			v_view_pos = e_attacker getWeaponMuzzlePoint();
			v_test_origin = self getCentroid();
			n_test_range_squared = distanceSquared( v_view_pos, v_test_origin );
			n_dist_mult = ( n_fling_range_squared - n_test_range_squared ) / n_fling_range_squared;
			v_fling_vec = vectorNormalize( v_test_origin - v_view_pos );
			v_fling_vec = ( v_fling_vec[ 0 ], v_fling_vec[ 1 ], abs( v_fling_vec[ 2 ] ) );
			v_fling_vec = vectorScale( v_fling_vec, 100 + ( 100 * n_dist_mult ) );
			self doDamage( self.health + 666, e_attacker.origin, e_attacker );
			self startRagdoll();
			self launchRagdoll( v_fling_vec );
		}
	}
	else
	{
		if ( self function_f23d2379() )
			self function_6140a171( e_attacker );
		else
		{
			self playSound( "evt_shrink" );
			self.e_shrink_attacker thread zm_audio::create_and_play_dialog( "kill", "shrink" );
			self thread function_259d2f7a( "shrink", "j_mainroot" );
			n_saved_melee_damage = self.meleedamage;
			self.meleedamage = 5;
			self.no_gib = 1;
			self zombie_utility::zombie_eye_glow_stop();
			a_attached_models = [];
			a_attached_tags = [];
			str_hatmodel = self.hatmodel;
			n_num_models = self getAttachSize();
			for ( i = n_num_models - 1; i >= 0; i-- )
			{
				str_model = self getAttachModelName( i );
				str_tag = self getAttachTagName( i );
				b_is_hat = isDefined( self.hatmodel ) && self.hatmodel == str_hatmodel;
				if ( b_is_hat )
					self.hatmodel = undefined;
				
				a_attached_models[ a_attached_models.size ] = str_model;
				a_attached_tags[ a_attached_tags.size ] = str_tag;
				self detach( str_model );
				str_attach_model = level.shrink_models[ get_model( str_model ) ];
				if ( isDefined( str_attach_model ) )
				{
					self attach( str_attach_model );
					if ( b_is_hat )
						self.hatmodel = str_attach_model;
					
				}
			}
			str_mini_model = level.shrink_models[ get_model( self.model ) ];
			if ( isDefined( str_mini_model ) )
				self setModel( str_mini_model );
			
			if ( !self.missinglegs )
				self setPhysParams( 8, -2, 32 );
			else
			{
				self allowPitchAngle( 0 );
				v_new_origin = self.origin + vectorScale( ( 0, 0, 1 ), 10 );
				self teleport( v_new_origin, self.angles );
				self setPhysParams( 8, -16, 10 );
			}
			self.health = 1;
			self thread function_6d284e94();
			self thread function_643fa9c8();
			self thread watch_for_death();
			self.zombie_board_tear_down_callback = &function_8b44a1f8;
			if ( isDefined( self._zombie_shrink_callback ) )
				self [ [ self._zombie_shrink_callback ] ]();
			
			wait n_shrink_time;
			self playSound( "evt_unshrink" );
			self thread function_259d2f7a( "unshrink", "j_mainroot" );
			wait .5;
			self.zombie_board_tear_down_callback = undefined;
			if ( isDefined( self._zombie_unshrink_callback ) )
				self [ [ self._zombie_unshrink_callback ] ]();
			
			n_num_models = self getAttachSize();
			for ( i = n_num_models - 1; i >= 0; i-- )
			{
				str_model = self getAttachModelName( i );
				str_tag = self getAttachTagName( i );
				self detach( str_model );
			}
			self.hatmodel = str_hatmodel;
			for ( i = 0; i < a_attached_models.size; i++ )
				self attach( a_attached_models[ i ] );
			
			self setModel( str_normal_model );
			if ( !self.missinglegs )
				self setPhysParams( 15, 0, 72 );
			else
			{
				self setPhysParams( 15, 0, 24 );
				self allowPitchAngle( 1 );
			}
			self.health = n_health;
			self.meleedamage = n_saved_melee_damage;
			self.no_gib = 0;
		}
	}
	self zombie_utility::zombie_eye_glow();
	if ( isActor( self ) )
		self clientfield::set( "fun_size", 0 );
	
	self notify( "unshrink" );
	self.b_shrinked = 0;
	self.e_shrink_attacker = undefined;
	self.kill_on_wine_coccon = undefined;
}

function function_f23d2379()
{
	if(isdefined(self getlinkedent()))
	{
		return true;
	}
	if(isdefined(self.sliding) && self.sliding)
	{
		return true;
	}
	if(isdefined(self.in_the_ceiling) && self.in_the_ceiling)
	{
		return true;
	}
	return false;
}

function function_6d284e94()
{
	self endon("unshrink");
	self endon("hash_b6537d92");
	self endon("kicked");
	self endon("death");
	wait(randomfloatrange(0.2, 0.5));
	while(true)
	{
		self playsound("zmb_mini_ambient");
		wait(randomfloatrange(1, 2.25));
	}
}

function function_259d2f7a(fxname, jointname, offset)
{
	playfxontag(level._effect[fxname], self, "tag_origin");
}

function function_206493fd(alias)
{
	self endon("death");
	wait(randomfloat(0.5));
	self zm_utility::play_sound_on_ent(alias);
}

function function_643fa9c8()
{
	self endon("death");
	self endon("unshrink");
	self.var_f0dec186 = spawn("trigger_radius", self.origin, 0, 30, 24);
	self.var_f0dec186 sethintstring("");
	self.var_f0dec186 setcursorhint("HINT_NOICON");
	self.var_f0dec186 enablelinkto();
	self.var_f0dec186 linkto(self);
	self.var_f0dec186 thread function_2c318bd(self);
	self.var_f0dec186 endon("death");
	while(true)
	{
		self.var_f0dec186 waittill("trigger", who);
		if(!isplayer(who))
		{
			continue;
		}
		if(!(isdefined(self.completed_emerging_into_playable_area) && self.completed_emerging_into_playable_area))
		{
			continue;
		}
		if(isdefined(self.magic_bullet_shield) && self.magic_bullet_shield)
		{
			continue;
		}
		movement = who getnormalizedmovement();
		if(length(movement) < 0.1)
		{
			continue;
		}
		toenemy = self.origin - who.origin;
		toenemy = (toenemy[0], toenemy[1], 0);
		toenemy = vectornormalize(toenemy);
		forward_view_angles = anglestoforward(who.angles);
		var_884fd8ec = vectordot(forward_view_angles, toenemy);
		if(var_884fd8ec > 0.5 && movement[0] > 0)
		{
			self notify("kicked");
			who notify("hash_49423c6f");
			self function_867ec02b(who);
		}
		else
		{
			self notify("hash_b6537d92");
			self function_6140a171(who);
		}
	}
}

function function_2c318bd(var_34c9bd99)
{
	self endon("death");
	var_34c9bd99 waittill("death");
	self delete();
}

function watch_for_death()
{
	self endon("unshrink");
	self endon("hash_b6537d92");
	self endon("kicked");
	self waittill("death");
	self function_6140a171();
}

function function_12c1fddf(v_launch)
{
	if(!isdefined(level.var_6d0abb4c))
	{
		level.var_6d0abb4c = 0;
	}
	if(level.var_6d0abb4c < 5)
	{
		level.var_6d0abb4c++;
		self launchragdoll(v_launch);
		wait(3);
		level.var_6d0abb4c--;
	}
}

function function_867ec02b(killer)
{
	if(level flag::get("world_is_paused"))
	{
		self setignorepauseworld(1);
	}
	self thread function_9ac50518();
	kickangles = killer.angles;
	kickangles = kickangles + (randomfloatrange(-30, -20), randomfloatrange(-5, 5), 0);
	launchdir = anglestoforward(kickangles);
	if(killer issprinting())
	{
		launchforce = randomfloatrange(350, 400);
	}
	else
	{
		vel = killer getvelocity();
		speed = length(vel);
		scale = math::clamp(speed / 190, 0.1, 1);
		launchforce = randomfloatrange(200 * scale, 250 * scale);
	}
	self startragdoll();
	self thread function_12c1fddf(launchdir * launchforce);
	util::wait_network_frame();
	killer thread zm_audio::create_and_play_dialog("kill", "shrunken");
	self dodamage(self.health + 666, self.origin, killer);
	if(isdefined(self.var_f0dec186))
	{
		self.var_f0dec186 delete();
	}
}

function function_9ac50518()
{
	if(!isdefined(level.var_1b24c8b0))
	{
		level thread function_ebf92008();
	}
	if(level.var_1b24c8b0 > 3)
	{
		return;
	}
	level.var_1b24c8b0++;
	playsoundatposition("zmb_mini_kicked", self.origin);
}

function function_6140a171(killer)
{
	playsoundatposition("zmb_mini_squashed", self.origin);
	if(level flag::get("world_is_paused"))
	{
		self setignorepauseworld(1);
	}
	playfx(level._effect["shrink_ray_stepped_on_no_gore"], self.origin);
	self thread zombie_utility::zombie_eye_glow_stop();
	util::wait_network_frame();
	self hide();
	self dodamage(self.health + 666, self.origin, killer);
	if(isdefined(self.var_f0dec186))
	{
		self.var_f0dec186 delete();
	}
}

function function_66ab6f95(upgraded, var_5eafa9ab)
{
	range = 480;
	radius = 60;
	if(upgraded)
	{
		range = 1200;
		radius = 84;
	}
	var_91820d09 = [];
	view_pos = self getweaponmuzzlepoint();
	test_list = undefined;
	if(var_5eafa9ab)
	{
		test_list = level.var_c50bd012;
		range = range * 5;
	}
	else
	{
		test_list = getaispeciesarray(level.zombie_team, "all");
	}
	zombies = util::get_array_of_closest(view_pos, test_list, undefined, undefined, range * 1.1);
	if(!isdefined(zombies))
	{
		return;
	}
	range_squared = range * range;
	radius_squared = radius * radius;
	forward_view_angles = self getweaponforwarddir();
	end_pos = view_pos + vectorscale(forward_view_angles, range);
	/#
		if(2 == getdvarint(""))
		{
			near_circle_pos = view_pos + vectorscale(forward_view_angles, 2);
			circle(near_circle_pos, radius, (1, 0, 0), 0, 0, 100);
			line(near_circle_pos, end_pos, (0, 0, 1), 1, 0, 100);
			circle(end_pos, radius, (1, 0, 0), 0, 0, 100);
		}
	#/
	for(i = 0; i < zombies.size; i++)
	{
		if(!isdefined(zombies[i]) || (isai(zombies[i]) && !isalive(zombies[i])))
		{
			continue;
		}
		if(isdefined(zombies[i].shrinked) && zombies[i].shrinked)
		{
			zombies[i] function_9ae4cf1b("shrinked", (1, 0, 0));
			continue;
		}
		if(isdefined(zombies[i].no_shrink) && zombies[i].no_shrink)
		{
			zombies[i] function_9ae4cf1b("no_shrink", (1, 0, 0));
			continue;
		}
		test_origin = zombies[i] getcentroid();
		test_range_squared = distancesquared(view_pos, test_origin);
		if(test_range_squared > range_squared)
		{
			zombies[i] function_9ae4cf1b("range", (1, 0, 0));
			break;
		}
		normal = vectornormalize(test_origin - view_pos);
		dot = vectordot(forward_view_angles, normal);
		if(0 > dot)
		{
			zombies[i] function_9ae4cf1b("dot", (1, 0, 0));
			continue;
		}
		radial_origin = pointonsegmentnearesttopoint(view_pos, end_pos, test_origin);
		if(distancesquared(test_origin, radial_origin) > radius_squared)
		{
			zombies[i] function_9ae4cf1b("cylinder", (1, 0, 0));
			continue;
		}
		if(0 == zombies[i] damageconetrace(view_pos, self))
		{
			zombies[i] function_9ae4cf1b("cone", (1, 0, 0));
			continue;
		}
		var_91820d09[var_91820d09.size] = zombies[i];
	}
	return var_91820d09;
}

function function_9ae4cf1b(msg, color)
{
	
}

function function_8b44a1f8()
{
	self endon("death");
	self endon("unshrink");
	while(true)
	{
		taunt_anim = array::random(level._zombie_board_taunt["zombie"]);
	}
}

function temple_shrink_ray_model_mapping_func()
{
	level.shrink_models[ "head" ] = "c_t7_zm_dlchd_shangrila_nva_mini_head2";
	level.shrink_models[ "body" ] = "c_t7_zm_dlchd_shangrila_nva_mini_body";
	level.shrink_models[ "blegsoff" ] = "c_t7_zm_dlchd_shangrila_nva_mini_g_blegsoff";
	level.shrink_models[ "larmoff" ] = "c_t7_zm_dlchd_shangrila_nva_mini_g_larmoff";
	level.shrink_models[ "llegoff" ] = "c_t7_zm_dlchd_shangrila_nva_mini_g_llegoff";
	level.shrink_models[ "loclean" ] = "c_t7_zm_dlchd_shangrila_nva_mini_g_loclean";
	level.shrink_models[ "rarmoff" ] = "c_t7_zm_dlchd_shangrila_nva_mini_g_rarmoff";
	level.shrink_models[ "rlegoff" ] = "c_t7_zm_dlchd_shangrila_nva_mini_g_rlegoff";
	level.shrink_models[ "upclean" ] = "c_t7_zm_dlchd_shangrila_nva_mini_g_upclean";
}

function function_90b3897b(ai)
{
	if(isdefined(ai.shrinked) && ai.shrinked)
	{
		return false;
	}
	if(isdefined(ai.animname) && ai.animname == "napalm_zombie")
	{
		return false;
	}
	return true;
}

function function_339a163c()
{
	if(isdefined(self) && (isdefined(self.shrinked) && self.shrinked))
	{
		return false;
	}
	return true;
}

function get_model( str_model )
{
	if ( isSubStr( str_model, "head" ) ) str_model = "head";
	else if ( isSubStr( str_model, "body" ) ) str_model = "body";
	else if ( isSubStr( str_model, "blegsoff" ) ) str_model = "blegsoff";
	else if ( isSubStr( str_model, "larmoff" ) ) str_model = "larmoff";
	else if ( isSubStr( str_model, "llegoff" ) ) str_model = "llegoff";
	else if ( isSubStr( str_model, "loclean" ) ) str_model = "loclean";
	else if ( isSubStr( str_model, "rarmoff" ) ) str_model = "rarmoff";
	else if ( isSubStr( str_model, "rlegoff" ) ) str_model = "rlegoff";
	else if ( isSubStr( str_model, "upclean" ) ) str_model = "upclean";
	return str_model;
}
