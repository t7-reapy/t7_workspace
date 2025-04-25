#using scripts\codescripts\struct;
#using scripts\shared\audio_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\system_shared;
#using scripts\shared\trigger_shared;
#using scripts\shared\util_shared;

#using scripts\shared\filter_shared;
#using scripts\shared\water_surface;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

function autoexec main()
{
	callback::on_localclient_connect( &OnPlayerConnect );
}

function OnPlayerConnect( localClientNum )
{
	level thread WaterSheetTrigger( localClientNum );
}

function WaterSheetTrigger( localClientNum )
{
	waterSheetTriggers = GetEntArray( localClientNum, "water_sheeting", "targetname" );

	foreach( waterSheetTrigger in waterSheetTriggers )
		waterSheetTrigger thread WaterSheetSetup( localClientNum );
}

function WaterSheetSetup( localClientNum )
{
	self._localClientNum = localClientNum;

	while(1)
	{
		self waittill( "trigger", trigPlayer );

		if( trigPlayer != GetLocalPlayer( localClientNum ) )
		{
			continue;
		}

		filter::init_filter_water_sheeting( trigPlayer );

		self thread trigger::function_thread( trigPlayer, &TrigEnterWaterSheet, &TrigLeaveWaterSheet );
	} 
}

function TrigEnterWaterSheet( trigPlayer )
{
	trigPlayer endon( "entityshutdown" );

	localClientNum = self._localClientNum; 

	if( trigPlayer IsPlayer() && trigPlayer IsLocalPlayer() )
	{
		if( isdefined( trigPlayer GetLocalClientNumber()) && localClientNum == trigPlayer GetLocalClientNumber() )
		{
			StartWaterSheetingFX( localClientNum, 0 );

			filter::enable_filter_water_sheeting( trigPlayer, 1 ); 

			if ( !isdefined( trigPlayer.sheetOpacity ) )
				trigPlayer.sheetOpacity = 0;

			while( self IsTouching( trigPlayer ) )
			{
				trigPlayer.sheetOpacity += 0.01;

				if( trigPlayer.sheetOpacity > 1 )
				{
					trigPlayer.sheetOpacity = 1;
				}

				filter::set_filter_water_sheet_reveal( trigPlayer, 1, trigPlayer.sheetOpacity );
				filter::set_filter_water_sheet_speed( trigPlayer, 1, trigPlayer.sheetOpacity );

				rivulet1 = trigPlayer.sheetOpacity - 0.19;
				rivulet2 = trigPlayer.sheetOpacity - 0.13;
				rivulet3 = trigPlayer.sheetOpacity - 0.07;

				filter::set_filter_water_sheet_rivulet_reveal( trigPlayer, 1, rivulet1, rivulet2, rivulet3 );

				WAIT_CLIENT_FRAME;
			}
		}
	}
}

function TrigLeaveWaterSheet( trigPlayer )
{
	trigPlayer endon( "entityshutdown" );

	localClientNum = self._localClientNum; 

	if( trigPlayer IsPlayer() && trigPlayer IsLocalPlayer() )
	{
		if( isdefined( trigPlayer GetLocalClientNumber() ) && localClientNum == trigPlayer GetLocalClientNumber() )
		{
			StopWaterSheetingFX( localClientNum, 1 );

			while( !self IsTouching( trigPlayer ) &&  trigPlayer.sheetOpacity > 0)
			{
				trigPlayer.sheetOpacity -= 0.01;


				filter::set_filter_water_sheet_reveal( trigPlayer, 1, trigPlayer.sheetOpacity );
				filter::set_filter_water_sheet_speed( trigPlayer, 1, trigPlayer.sheetOpacity );

				rivulet1 = trigPlayer.sheetOpacity - 0.19;
				rivulet2 = trigPlayer.sheetOpacity - 0.13;
				rivulet3 = trigPlayer.sheetOpacity - 0.07;

				filter::set_filter_water_sheet_rivulet_reveal( trigPlayer, 1, rivulet1, rivulet2, rivulet3 );

				WAIT_CLIENT_FRAME;
			}

			filter::set_filter_water_sheet_reveal( trigPlayer, 1, 0.0 );
			filter::set_filter_water_sheet_speed( trigPlayer, 1, 0.0 );
			filter::set_filter_water_sheet_rivulet_reveal( trigPlayer, 1, 0.0, 0.0, 0.0 );

			filter::disable_filter_water_sheeting( trigPlayer, 1 );
		}
	}
}