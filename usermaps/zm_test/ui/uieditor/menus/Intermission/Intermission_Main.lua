-- Restart/leave buttons overlaid on the map's gameover_camera travels. Buttons
-- only — no background/scoreboard/title (the gameover HUD provides those).
require( "ui.uieditor.widgets.Lobby.Common.List1ButtonLarge_PH" )

local PostLoadFunc = function ( self, controller )
	-- Don't darken the screen; the camera pan must stay visible behind the buttons.
	self.disableDarkenElement = true

	SetFocusToElement( self, "buttonList", controller )
end

DataSources.Intermission = ListHelper_SetupDataSource( "Intermission", function ( controller )
	local options = {}

	if Engine.IsLobbyHost( Enum.LobbyType.LOBBY_TYPE_GAME ) == true then
		table.insert( options, {
			models = {
				displayText = "MENU_RESTART_LEVEL_CAPS",
				action = function ( self, element, controller, actionParam, menu )
					Engine.Exec( controller, "map_restart" )
				end
			}
		} )

		table.insert( options, {
			models = {
				displayText = "MENU_END_GAME_CAPS",
				action = function ( self, element, controller, actionParam, menu )
					Engine.Exec( controller, "disconnect" )
				end
			}
		} )
	else
		table.insert( options, {
			models = {
				displayText = "MENU_LEAVE_GAME_CAPS",
				action = function ( self, element, controller, actionParam, menu )
					Engine.Exec( controller, "disconnect" )
				end
			}
		} )
	end

	return options
end, true )

LUI.createMenu.Intermission_Main = function ( controller )
	local self = CoD.Menu.NewForUIEditor( "Intermission_Main" )

	if PreLoadFunc then
		PreLoadFunc( self, controller )
	end

	self.soundSet = "ChooseDecal"
	self:setOwner( controller )
	self:setLeftRight( true, false, 0, 1280 )
	self:setTopBottom( true, false, 0, 720 )
	self:playSound( "menu_open", controller )
	self.buttonModel = Engine.CreateModel( Engine.GetModelForController( controller ), "Intermission_Main.buttonPrompts" )
	self.anyChildUsesUpdateState = true

	-- Two large buttons anchored to the bottom, clear of the centered GAME OVER text.
	self.buttonList = LUI.UIList.new( self, controller, 0, 0, nil, true, false, 0, 0, false, false )
	self.buttonList:makeFocusable()
	self.buttonList:setLeftRight( false, false, 0, 0 )
	self.buttonList:setTopBottom( false, true, -110, -30 )
	self.buttonList:setWidgetType( CoD.List1ButtonLarge_PH )
	self.buttonList:setHorizontalCount( 2 )
	self.buttonList:setVerticalCount( 1 )
	self.buttonList:setDataSource( "Intermission" )
	self:AddButtonCallbackFunction( self.buttonList, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, "ENTER", function ( element, menu, controller, model )
		PlaySoundSetSound( self, "list_action" )
		ProcessListAction( self, element, controller )

		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, "MENU_SELECT" )

		return true
	end, false )
	self:addElement( self.buttonList )

	self.buttonList.id = "buttonList"

	LUI.OverrideFunction_CallOriginalSecond( self, "close", function ( element )
		element.buttonList:close()

		Engine.UnsubscribeAndFreeModel( Engine.GetModel( Engine.GetModelForController( controller ), "Intermission_Main.buttonPrompts" ) )
	end )

	if PostLoadFunc then
		PostLoadFunc( self, controller )
	end

	return self
end
