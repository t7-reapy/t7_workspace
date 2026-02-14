#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_magicbox;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_unitrigger;
#using scripts\zm\_zm_utility;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#precache("fx", "dlc5/tomb/fx_tomb_marker");
#precache("fx", "dlc5/tomb/fx_tomb_marker_fl");

#namespace tomb_magicbox;

REGISTER_SYSTEM_EX("tomb_magicbox", &__init__, undefined, undefined)

function __init__()
{
	DEFAULT( level.a_box_classnames, [] );
	clientfield::register("zbarrier", "tomb_magicbox_initial_fx", VERSION_SHIP, 1, "int");
	clientfield::register("zbarrier", "tomb_magicbox_amb_fx", VERSION_SHIP, 2, "int");
	clientfield::register("zbarrier", "tomb_magicbox_open_fx", VERSION_SHIP, 1, "int");
	clientfield::register("zbarrier", "tomb_magicbox_leaving_fx", VERSION_SHIP, 1, "int");
	level._effect[ "tomb_light_marker" ] 		= "dlc5/tomb/fx_tomb_marker";
	level._effect[ "tomb_light_marker_flare" ] 	= "dlc5/tomb/fx_tomb_marker_fl";

	if ( isDefined( level.a_box_classnames[ "zbarrier_zmcore_magicbox_t7_origins" ]))
	return;

	magicbox_struct = spawnStruct();
	magicbox_struct.custom_show_box = &tomb_show_box;
	magicbox_struct.custom_magic_box_timer_til_despawn = &tomb_magic_box_timer_til_despawn;
	magicbox_struct.custom_pandora_show_func = &tomb_pandora_show_func;
	magicbox_struct.custom_pandora_fx_func = &tomb_pandora_fx_func;
	magicbox_struct.custom_magic_box_weapon_wait = &tomb_custom_magic_box_weapon_wait;
	magicbox_struct.custom_joker_movement = &tomb_joker_movement;
	magicbox_struct.custom_magic_box_do_weapon_rise = &tomb_magic_box_do_weapon_rise;
	magicbox_struct.custom_process_magic_box_zbarrier_state = &set_tomb_magic_box_zbarrier_state;

	level.a_box_classnames[ "zbarrier_zmcore_magicbox_t7_origins" ] = magicbox_struct;
	level thread tomb_wait_then_create_base_magic_box_fx();
	level thread handle_fire_sale();
}

function tomb_joker_movement()
{
	self.weapon_model.origin = self.origin + ( anglesToUp( self.angles ) * 50 );
	v_origin = self.weapon_model.origin - vectorScale( ( 0, 0, 1 ), 5 );
	self.weapon_model delete();
	m_lock = util::spawn_model( level.chest_joker_model, v_origin, self.angles );
	m_lock playSound( "zmb_hellbox_bear" );
	wait .5;
	level notify( "weapon_fly_away_start" );
	wait 1;
	m_lock rotateYaw( 3000, 4, 4 );
	wait 3;
	v_angles = anglesToForward( self.angles - vectorScale( ( 0, 1, 0 ), 90 ) );
	m_lock moveTo( m_lock.origin + 20 * v_angles, .5, .5 );
	m_lock waittill( "movedone" );
	m_lock moveTo( m_lock.origin + -100 * v_angles, .5, .5 );
	m_lock waittill( "movedone" );
	m_lock delete();
	self notify( "box_moving" );
	level notify( "weapon_fly_away_end" );
}

function tomb_magic_box_timer_til_despawn(tomb_magic_box)
{
	self endon( "kill_weapon_movement" );
	self.origin = tomb_magic_box.origin + ( anglesToUp( tomb_magic_box.angles ) * 50 );
	putbacktime = 12;
	v_float = anglesToForward( tomb_magic_box.angles - vectorScale( ( 0, 1, 0 ), 90 ) ) * 40;
	self moveTo(self.origin - ( v_float * .25 ), putbacktime, putbacktime * .5 );
	wait putbacktime;
	if ( isDefined( self ) )
		self delete();
}

function tomb_custom_magic_box_weapon_wait()
{
	wait(0.5);
}


function tomb_wait_then_create_base_magic_box_fx()
{
	while(!isdefined(level.chests))
	{
		wait(0.5);
	}
	while(!isdefined(level.chests[level.chests.size - 1].zbarrier))
	{
		wait(0.5);
	}
	foreach(chest in level.chests)
	{
		if ( chest.zbarrier.classname == "zbarrier_zmcore_magicbox_t7_origins" )
		{
			chest.zbarrier clientfield::set( "tomb_magicbox_initial_fx", 1 );
			chest.zbarrier clientfield::set( "tomb_magicbox_amb_fx", 3 );
		}
	}
}


function set_tomb_magic_box_zbarrier_state(state)
{
	for(i = 0; i < self getnumzbarrierpieces(); i++)
	{
		self hidezbarrierpiece(i);
	}
	self notify("zbarrier_state_change");
	switch(state)
	{
		case "away":
		{
			self showzbarrierpiece(0);
			self.state = "away";
			self.owner.is_locked = 0;
			break;
		}
		case "arriving":
		{
			self showzbarrierpiece(1);
			self thread tomb_magic_box_arrives();
			self.state = "arriving";
			break;
		}
		case "initial":
		{
			self showzbarrierpiece(1);
			self thread tomb_magic_box_initial();
			thread zm_unitrigger::register_static_unitrigger(self.owner.unitrigger_stub, &zm_magicbox::magicbox_unitrigger_think);
			self.state = "close";
			break;
		}
		case "open":
		{
			self showzbarrierpiece(2);
			self thread tomb_magic_box_opens();
			self.state = "open";
			break;
		}
		case "close":
		{
			self showzbarrierpiece(2);
			self thread tomb_magic_box_closes();
			self.state = "close";
			break;
		}
		case "leaving":
		{
			self showzbarrierpiece(1);
			self thread tomb_magic_box_leaves();
			self.state = "leaving";
			self.owner.is_locked = 0;
			break;
		}
		default:
		{
			if(isdefined(level.custom_magicbox_state_handler))
			{
				self [[level.custom_magicbox_state_handler]](state);
			}
			break;
		}
	}
}

function tomb_pandora_show_func(e_anchor, e_anchor_target, a_pieces)
{
	if (!isdefined(self.pandora_light))
	self thread custom_pandora_fx_func();
	
	playFX(level._effect["tomb_light_marker_flare"], self.pandora_light.origin);
}

function custom_pandora_fx_func()
{
	self endon("death");
	self.pandora_light = spawn("script_model", self.zbarrier.origin);
	self.pandora_light.angles = self.zbarrier.angles + vectorScale((-1, 0, -1), 90);
	self.pandora_light setModel("tag_origin");
	if (!IS_TRUE(level._box_initialized))
	{
		level flag::wait_till( "start_zombie_round_logic");
		level._box_initialized = 1;
	}
	wait 1;
	if (isdefined(self) && isdefined(self.pandora_light))
	playFXOnTag(level._effect["tomb_light_marker"], self.pandora_light, "tag_origin");

}

function tomb_magic_box_initial()
{
	self setzbarrierpiecestate(1, "open");
	wait(1);
	self clientfield::set("tomb_magicbox_amb_fx", 2);
}

function tomb_magic_box_arrives()
{
	self clientfield::set("tomb_magicbox_leaving_fx", 0);
	self setzbarrierpiecestate(1, "opening");
	while(self getzbarrierpiecestate(1) == "opening")
	{
		wait(0.05);
	}
	self notify("arrived");
	self.state = "close";
	self clientfield::set("tomb_magicbox_amb_fx", 2);
}

function tomb_magic_box_leaves()
{
	self notify("stop_open_idle");
	self clientfield::set("tomb_magicbox_leaving_fx", 1);
	self clientfield::set("tomb_magicbox_open_fx", 0);
	self setzbarrierpiecestate(1, "closing");
	self playsound("zmb_hellbox_rise");
	while(self getzbarrierpiecestate(1) == "closing")
	{
		wait(0.1);
	}
	self notify("left");
	self clientfield::set("tomb_magicbox_amb_fx", 3);
}

function tomb_magic_box_opens()
{
	self notify( "stop_idle" );
	self setZBarrierPieceState( 2, "opening" );
	self clientfield::set( "tomb_magicbox_open_fx", 1 );
	self playSound( "zmb_hellbox_open" );
	while ( self getZBarrierPieceState( 2 ) == "opening" )
		wait .1;
	
	self notify( "opened" );
	self thread tomb_magic_box_open_idle();
}

function tomb_magic_box_open_idle()
{
	self notify( "tomb_magic_box_open_idle" );
	self endon( "tomb_magic_box_open_idle" );
	self endon( "stop_open_idle" );
	self hideZBarrierPiece( 2 );
	self showZBarrierPiece( 5 );
	while ( isDefined( self ) )
	{
		self setZBarrierPieceState( 5, "opening" );
		while ( self getZBarrierPieceState( 5 ) != "open" )
			wait .05;
		
	}
}

function tomb_magic_box_closes()
{
	self notify("stop_open_idle");
	self hidezbarrierpiece(5);
	self showzbarrierpiece(2);
	self setzbarrierpiecestate(2, "closing");
	self playsound("zmb_hellbox_close");
	self clientfield::set("tomb_magicbox_open_fx", 0);
	while(self getzbarrierpiecestate(2) == "closing")
	{
		wait(0.1);
	}
	self notify("closed");
}

function tomb_magic_box_do_weapon_rise()
{
	self endon("box_hacked_respin");
	wait(0.5);
	self setzbarrierpiecestate(3, "closed");
	self setzbarrierpiecestate(4, "closed");
	util::wait_network_frame();
	self zbarrierpieceuseboxriselogic(3);
	self zbarrierpieceuseboxriselogic(4);
	self showzbarrierpiece(3);
	self showzbarrierpiece(4);
	self setzbarrierpiecestate(3, "opening");
	self setzbarrierpiecestate(4, "opening");
	while(self getzbarrierpiecestate(3) != "open")
	{
		wait(0.5);
	}
	self hidezbarrierpiece(3);
	self hidezbarrierpiece(4);
}

function handle_fire_sale()
{
	while ( isdefined( self ) )
	{
		level waittill( "fire_sale_off" );
		for ( i = 0; i < level.chests.size; i++ )
		{
			if ( level.chest_index != i && isdefined( level.chests[ i ].was_temp ) )
			{
				if ( level.chests[ i ].zbarrier.classname != "zbarrier_zmcore_magicbox_t7_origins" )
					continue;
				
				level.chests[ i ].zbarrier clientfield::set( "tomb_magicbox_amb_fx", 3 );
				continue;
			}
		}
	}
}

function tomb_pandora_fx_func()
{
}

function custom_treasure_chest_glowfx()
{
}

function tomb_show_box( box_hide )
{
	if ( box_hide )
	{
	}
	else
	{
	}
}
