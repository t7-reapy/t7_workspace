require( "ui.uieditor.widgets.Lobby.Common.H1ButtonListItem" )

-- Restart the whole match for everyone. map_restart (full level reload) is used
-- on purpose over fast_restart: it tears the level down cleanly so the map's
-- custom HUD / LUI widgets don't linger into the new game. Host only.
local IntermissionRestart = function ( self, element, controller, actionParam, menu )
	Engine.Exec( controller, "map_restart" )

	return true
end

-- Leave the match back to the front end / lobby.
local IntermissionLeave = function ( self, element, controller, actionParam, menu )
	QuitGame_MP( self, element, controller, actionParam, menu )

	return true
end

DataSources.IntermissionOptions = ListHelper_SetupDataSource( "IntermissionOptions", function ( controller )
	local options = {}

	-- Only the host can restart the level for the lobby.
	if Engine.IsLobbyHost( Enum.LobbyType.LOBBY_TYPE_GAME ) then
		table.insert( options, {
			models = {
				displayText = "MENU_RESTART_LEVEL_CAPS",
				action = IntermissionRestart
			}
		} )
	end

	table.insert( options, {
		models = {
			displayText = "MENU_QUIT_GAME_CAPS",
			action = IntermissionLeave
		}
	} )

	return options
end, true )

LUI.createMenu.Intermission_Main = function ( controller )
	local self = CoD.Menu.NewForUIEditor( "Intermission_Main" )

	if PreLoadFunc then
		PreLoadFunc( self, controller )
	end

	self.soundSet = "ChooseDecal"
	self:setOwner( controller )
	self:setLeftRight( true, true, 0, 0 )
	self:setTopBottom( true, true, 0, 0 )
	self:playSound( "menu_open", controller )
	self.anyChildUsesUpdateState = true

	-- Dim the game-over view behind the menu (matches the dark H1 pause look).
	self.Darken = LUI.UIImage.new()
	self.Darken:setLeftRight( true, true, 0, 0 )
	self.Darken:setTopBottom( true, true, 0, 0 )
	self.Darken:setImage( RegisterImage( "white" ) )
	self.Darken:setRGB( 0, 0, 0 )
	self.Darken:setAlpha( 0.8 )
	self:addElement( self.Darken )

	self.TitleText = LUI.UIText.new()
	self.TitleText:setLeftRight( true, false, 60, 540 )
	self.TitleText:setTopBottom( true, false, 110, 170 )
	self.TitleText:setTTF( "fonts/defaultbold.ttf" )
	self.TitleText:setText( Engine.Localize( "GAME OVER" ) )
	self.TitleText:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_LEFT )
	self.TitleText:setScale( 0.7 )
	self:addElement( self.TitleText )

	-- Same button list widget the pause menu (H1StartMenu_GameOptions_ZM) uses,
	-- so the intermission menu matches the rest of the map's UI.
	self.buttonList = LUI.UIList.new( self, controller, 6.5, 0, nil, true, false, 0, 0, false, false )
	self.buttonList:makeFocusable()
	self.buttonList:setLeftRight( true, false, 60, 300 )
	self.buttonList:setTopBottom( true, false, 200, 0 )
	self.buttonList:setWidgetType( CoD.H1ButtonListItem )
	self.buttonList:setVerticalCount( 5 )
	self.buttonList:setDataSource( "IntermissionOptions" )
	self.buttonList.id = "buttonList"
	self:addElement( self.buttonList )

	self:AddButtonCallbackFunction( self.buttonList, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, "ENTER", function ( element, menu, controller, model )
		ProcessListAction( self, element, controller )

		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, "MENU_SELECT" )

		return true
	end, false )

	-- Forward focus to the button list so it is navigable as soon as it opens.
	self:registerEventHandler( "gain_focus", function ( element, event )
		if element.buttonList then
			return element.buttonList:processEvent( event )
		end

		return LUI.UIElement.gainFocus( element, event )
	end )

	self:processEvent( {
		name = "menu_loaded",
		controller = controller
	} )

	self.buttonList:processEvent( {
		name = "gain_focus",
		controller = controller
	} )

	LUI.OverrideFunction_CallOriginalSecond( self, "close", function ( element )
		element.Darken:close()
		element.TitleText:close()
		element.buttonList:close()
	end )

	if PostLoadFunc then
		PostLoadFunc( self, controller )
	end

	return self
end
