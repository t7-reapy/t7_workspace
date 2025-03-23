// Number of stages
// per stage:
//   looping / length (secs)
//   material
//   shader constants:
//     name (scriptVector0...)
//     Channels
//     Anim type
//       one shot: hold, linear, ease in, ease out, ease inout
//       looping: hold, sin, repeat, mirror
//     Start value
//     End value (if not looping and not hold)
//   

// Shared between all graphics bundles (postfxbundle & duprenderbundle)

void GfxBundle( asset Asset, int MAX_STAGES, int MAX_SHADER_CONSTANTS )
{
	string shaderConstantNames =
	"""
		scriptVector0 |
		scriptVector1 |
		scriptVector2 |
		scriptVector3 |
		scriptVector4 |
		scriptVector5 |
		scriptVector6 |
		scriptVector7
	""";

	string animTypesOneshot = 
	"""
		hold |
		step |
		linear |
		ease in |
		ease out |
		ease inout
	""";
	
	string animTypesLoop = 
	"""
		hold |
		step |
		linear repeat |
		linear mirror |
		sin
	""";

	string channelNames = 
	"""
		1 |
		2 |
		3 |
		4 |
		color |
		color+alpha
	""";

	// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

	Asset.AddEntry_CheckBox( "looping", false ).SetTitle( "Looping" ).SetToolTip( "Looping" ).Show(true).UpdateOnChange( true );
	bool looping = Asset.GetEntryBool( "looping" );

	Asset.AddEntry_CheckBox( "firstpersononly", false ).SetTitle( "First Person Only" ).SetToolTip( "Should this post effect only be rendered in first person" ).Show(true).UpdateOnChange( true );
	
	Asset.AddEntry_CheckBox( "enterStage", false ).SetTitle( "Enter Stage" ).SetToolTip( "Include a stage that will be played before the looping stage starts." ).Show( looping ).UpdateOnChange( true );
	bool enterStage = Asset.GetEntryBool( "enterStage" );

	Asset.AddEntry_CheckBox( "exitStage", false ).SetTitle( "Exit Stage" ).SetToolTip( "Include a stage that will be played when the effect is done." ).Show( looping ).UpdateOnChange( true );
	bool exitStage = Asset.GetEntryBool( "exitStage" );

	Asset.AddEntry_CheckBox( "finishLoopOnExit", false ).SetTitle( "Finish Loop On Exit" ).SetToolTip( "Start the Exit Stage when the looping stage is done - otherwise Exit Stage starts immediatly." ).Show( looping && exitStage ).UpdateOnChange( true );

	Asset.AddEntry_CheckBox( "screenCapture", false ).SetTitle( "Screen Capture" ).SetToolTip( "Capture the screen at the beginning of the effect and keep it until the end" ).Show(true);

	int numLoopingStages = 1 + ( enterStage ? 1 : 0 ) + ( exitStage ? 1 : 0 );
	Asset.AddEntry_Int( "num_stages", 1, 1, looping ? numLoopingStages : MAX_STAGES ).SetTitle( "Number of stages" ).Show(true).Enable(!looping).UpdateOnChange(true);
	int numStages = looping ? numLoopingStages : Asset.GetEntryValue( "num_stages" ).ToInt();

	if ( looping )
		Asset.GetEntryControl( "num_stages" ).SetInt( numLoopingStages );

	//
	for ( int i = 0 ; i < MAX_STAGES ; i++ )
	{
		string stageString = "s";
		if ( i < 10 ) { stageString += "0"; }
		stageString += i;
		stageString += "_";

		bool showStage = i < numStages;

		int stageIdx = i + 1;
		string StageName = "Stage " + stageIdx;
		bool oneShot = true;
		if ( looping )
		{
			switch ( i )
			{
				case 0: StageName += enterStage ? " (Enter)" : " (Looping)";	if ( !enterStage ) oneShot = false; break;
				case 1: StageName += enterStage ? " (Looping)" : " (Exit)";		if ( enterStage )  oneShot = false;	break;
				case 2: StageName += " (Exit)";																	    break;
			}
		}
		Asset.BeginCategory( StageName, 0.1, 0.1, 0.9, "" );

		Asset.AddEntry_Float(stageString + "length", 1.0, 0.01, 10.0 ).SetTitle("Length").SetToolTip("The amount of time this stage will be active in seconds").Show(showStage).UpdateOnChange(true);
		Asset.AddEntry_CheckBox( stageString + "screenCapture", false ).SetTitle( "Stage Screen Capture" ).SetToolTip( "Capture the screen at the beginning of the stage and keep it in this stage (overrides the global during the stage)" ).Show(showStage).UpdateOnChange(true);

		GfxBundleSpecific( Asset, StageName, stageString, showStage );

		Asset.AddEntry_Int( stageString + "num_consts", 0, 0, MAX_SHADER_CONSTANTS ).SetTitle( "Number of shader constants" ).Show(showStage).UpdateOnChange(true);
		int numConsts = Asset.GetEntryValue( stageString + "num_consts" ).ToInt();

		for ( int j = 0 ; j < MAX_SHADER_CONSTANTS ; j++ )
		{
			string constString = stageString + "c";
			if ( j < 10 ) { constString += "0"; }
			constString += j;
			constString += "_";

			bool showConst = j < numConsts && showStage;

			int constIdx = j + 1;
			Asset.BeginCategory( StageName + ".Shader Constant " + constIdx, 0.9, 0.1, 0.1, "" );

			// use "anm" instead of "anim" since script bundle will try to load an XANIM_BIN when seeing "anim" string in the key
			Asset.AddEntry_Combo( constString + "name", shaderConstantNames ).SetTitle( "Name" ).Show( showConst ).SetDefaultValue("").UpdateOnChange(true);
			Asset.AddEntry_Combo( constString + "anm", oneShot ? animTypesOneshot : animTypesLoop ).SetTitle( "Animation" ).Show( showConst ).SetDefaultValue("").UpdateOnChange(true);
			Asset.AddEntry_Combo( constString + "channels", channelNames ).SetTitle( "Number of channels" ).Show( showConst ).SetDefaultValue("").UpdateOnChange(true);

			if ( Asset.GetEntryValue( constString + "anm" ) != "hold" )
				AddShaderConstant( Asset, constString + "delay_", Asset.GetEntryValue( constString + "channels" ), true ).SetTitle( "Anim Delay" ).SetToolTip( "Delay (in seconds) until the animation starts" ).Show( showConst );
			AddShaderConstant( Asset, constString + "start_", Asset.GetEntryValue( constString + "channels" ), false ).SetTitle( "Start value" ).Show( showConst );
			if ( Asset.GetEntryValue( constString + "anm" ) != "hold" )
				AddShaderConstant( Asset, constString + "end_", Asset.GetEntryValue( constString + "channels" ), false ).SetTitle( "End value" ).Show( showConst );
		}
	}
}

entryControl AddShaderConstant( asset& Asset, string& name, string& channels, bool delay )
{
	// Add the entries:
	Asset.AddEntry_Float( name + "x", 0.0, -1000000000, 1000000000 ).Show( false );
	Asset.AddEntry_Float( name + "y", 0.0, -1000000000, 1000000000 ).Show( false );
	Asset.AddEntry_Float( name + "z", 0.0, -1000000000, 1000000000 ).Show( false );
	Asset.AddEntry_Float( name + "w", 0.0, -1000000000, 1000000000 ).Show( false );
	if ( !delay )
		Asset.AddEntry_Color( name + "clr", 0, 0, 0, 0 ).Show( false );

	if ( channels == "1" || delay && ( channels == "color" || channels == "color+alpha" ) )
	{
		return Asset.GetEntryVariable( name + "x" );
	}
	else if ( channels == "2" )
	{
		return Asset.AddEntry_Vector2( name + "x", name + "y", 0.0, 0.0, -1000000000, 1000000000 );
	}
	else if ( channels == "3" )
	{
		return Asset.AddEntry_Vector3( name + "x", name + "y", name + "z", 0.0, 0.0, 0.0, -1000000000, 1000000000 );
	}
	else if ( channels == "color" )
	{
		return Asset.GetEntryVariable( name + "clr" );
	}
	else if ( channels == "color+alpha" )
	{
		return Asset.GetEntryVariable( name + "clr" ).SetShowAlpha( true );
	}
	else
	{
		return Asset.AddEntry_Vector4( name + "x", name + "y", name + "z", name + "w", 0.0, 0.0, 0.0, 0.0, -1000000000, 1000000000 );
	}
}
