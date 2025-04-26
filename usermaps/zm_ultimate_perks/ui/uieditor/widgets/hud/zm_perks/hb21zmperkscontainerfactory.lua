require( "ui.uieditor.widgets.HUD.ZM_Perks.hb21perklistitemfactory" )

local PerkTable = 
{
		quick_revive 							= "i_t7_specialty_quickrevive",
		doubletap2 							= "i_t7_specialty_doubletap2",
		juggernaut 							= "i_t7_specialty_armorvest",
		sleight_of_hand 					= "i_t7_specialty_fastreload",
		dead_shot 							= "i_t7_specialty_deadshot",
		phdflopper 							= "i_t7_specialty_phdflopper",
		marathon 								= "i_t7_specialty_staminup",
		additional_primary_weapon 	= "i_t7_specialty_additionalprimaryweapon",
		tombstone 							= "i_t7_specialty_tombstone",
		whoswho 								= "i_t7_specialty_whoswho",
		electric_cherry 						= "i_t7_specialty_electriccherry",
        vultureaid 								= "i_t7_specialty_vultureaid",
		widows_wine 						= "i_t7_specialty_widowswine",
		elemental_pop 						= "i_t7_specialty_elemental_pop"
}

local GetPerkIndex = function ( tableref, key )
	if tableref ~= nil then
		for index = 1, #tableref, 1 do
			if tableref[ index ].properties.key == key then
				return index
			end
		end
	end
	return nil
end

local GetPerkNewState = function ( tableref, key, status )
	if tableref ~= nil then
		for index = 1, #tableref, 1 do
			if tableref[ index ].properties.key == key and tableref[ index ].models.status ~= status then
				return index
			end
		end
	end
	return -1
end

local UpdatePerkList = function ( menu, controller )

	if not menu.perksList then
		menu.perksList = {}
	end
	
	local perkTableChanged = false
	local perkListModel = Engine.GetModel( Engine.GetModelForController( controller ), "hudItems.perks" )
	
	for perkKey, perkImage in pairs( PerkTable ) do
		local perkStatus = Engine.GetModelValue( Engine.GetModel( perkListModel, perkKey ) )
		if perkStatus ~= nil and perkStatus > 0 then
			if not GetPerkIndex( menu.perksList, perkKey ) then
				table.insert( menu.perksList, {
					models = {
						image = perkImage,
						status = perkStatus,
						newPerk = false,
						perkid = perkKey
					},
					properties = {
						key = perkKey
					}
				} )
				perkTableChanged = true
			end
			local perkNewStatus = GetPerkNewState( menu.perksList, perkKey, perkStatus )
			if perkNewStatus > 0 then
				menu.perksList[perkNewStatus].models.status = perkStatus
				Engine.SetModelValue( Engine.GetModel( Engine.GetModel( Engine.GetModelForController( controller ), "ZMPerksFactory" ), tostring( perkNewStatus ) .. ".status" ), perkStatus )
			end
		else
			local perkNewStatus = GetPerkIndex( menu.perksList, perkKey )
			if perkNewStatus then
				table.remove( menu.perksList, perkNewStatus )
				perkTableChanged = true
			end
		end
	end
	if perkTableChanged then
		for index = 1, #menu.perksList, 1 do
			menu.perksList[ index ].models.newPerk = index == #menu.perksList
		end
		return true
	end
	for index = 1, #menu.perksList, 1 do
		Engine.SetModelValue( Engine.GetModel( perkListModel, menu.perksList[ index ].properties.key ), menu.perksList[ index ].models.status )
	end
	return false
end

DataSources.ZMPerksFactory = DataSourceHelpers.ListSetup( "ZMPerksFactory", function ( controller, tableref )
	UpdatePerkList( tableref, controller )
	return tableref.perksList
end, true )

local PreLoadFunc = function ( self, controller )
	local perkListModel = Engine.CreateModel( Engine.GetModelForController( controller ), "hudItems.perks" )
	for perkKey, perkImage in pairs( PerkTable ) do
		self:subscribeToModel( Engine.CreateModel( perkListModel, perkKey ), function ( modelRef )
			if UpdatePerkList( self.PerkList, controller ) then
				self.PerkList:updateDataSource()
			end
		end, false )
	end
end

CoD.ZMPerksContainerFactory = InheritFrom( LUI.UIElement )
CoD.ZMPerksContainerFactory.new = function ( menu, controller )
	local self = LUI.UIElement.new()
	if PreLoadFunc then
		PreLoadFunc( self, controller )
	end
	self:setUseStencil( false )
	self:setClass( CoD.ZMPerksContainerFactory )
	self.id = "ZMPerksContainerFactory"
	self.soundSet = "default"
	self:setLeftRight( true, false, 0, 151 )
	self:setTopBottom( true, false, 0, 36 )
	self.anyChildUsesUpdateState = true
	
	local PerkList = LUI.UIList.new( menu, controller, 2, 0, nil, false, false, 0, 0, false, false )
	PerkList:makeFocusable()
	PerkList:setLeftRight( true, false, 0, 378 )
	PerkList:setTopBottom( false, true, -36, 0 )
	PerkList:setWidgetType( CoD.PerkListItemFactory )
	PerkList:setHorizontalCount( 50 )
	PerkList:setDataSource( "ZMPerksFactory" )
	self:addElement( PerkList )
	self.PerkList = PerkList
	
	self.clipsPerState = {
		DefaultState = {
			DefaultClip = function ()
				self:setupElementClipCounter( 1 )
				PerkList:completeAnimation()
				self.PerkList:setAlpha( 1 )
				self.clipFinished( PerkList, {} )
			end
		},
		Hidden = {
			DefaultClip = function ()
				self:setupElementClipCounter( 1 )
				PerkList:completeAnimation()
				self.PerkList:setAlpha( 0 )
				self.clipFinished( PerkList, {} )
			end
		}
	}
	
	self:mergeStateConditions( {
		{
			stateName = "Hidden",
			condition = function ( menu, element, event )
				if not Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_AMMO_COUNTER_HIDE ) and
				not Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_DEMO_ALL_GAME_HUD_HIDDEN ) and
				not Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_DEMO_CAMERA_MODE_MOVIECAM ) and
				not Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_EMP_ACTIVE ) and
				not Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_GAME_ENDED ) and
				Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_HUD_VISIBLE ) then
					if not Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_IN_GUIDED_MISSILE ) and
					not Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_IN_REMOTE_KILLSTREAK_STATIC ) and
					not Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_IN_VEHICLE ) and
					not Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_IS_FLASH_BANGED ) and
					not Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_IS_PLAYER_IN_AFTERLIFE ) and
					not Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_IS_SCOPED ) and
					not Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN ) and
					not Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_UI_ACTIVE ) then
						return false
					end
				else
					return true
				end
				return false
			end
		}
	} )
	
	self:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_AMMO_COUNTER_HIDE ), function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_AMMO_COUNTER_HIDE
		} )
	end )
	self:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_DEMO_ALL_GAME_HUD_HIDDEN ), function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_DEMO_ALL_GAME_HUD_HIDDEN
		} )
	end )
	self:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_DEMO_CAMERA_MODE_MOVIECAM ), function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_DEMO_CAMERA_MODE_MOVIECAM
		} )
	end )
	self:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_EMP_ACTIVE ), function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_EMP_ACTIVE
		} )
	end )
	self:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_GAME_ENDED ), function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_GAME_ENDED
		} )
	end )
	self:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_HUD_VISIBLE ), function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_HUD_VISIBLE
		} )
	end )
	self:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IN_GUIDED_MISSILE ), function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IN_GUIDED_MISSILE
		} )
	end )
	self:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IN_REMOTE_KILLSTREAK_STATIC ), function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IN_REMOTE_KILLSTREAK_STATIC
		} )
	end )
	self:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IN_VEHICLE ), function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IN_VEHICLE
		} )
	end )
	self:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IS_FLASH_BANGED ), function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IS_FLASH_BANGED
		} )
	end )
	self:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IS_PLAYER_IN_AFTERLIFE ), function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IS_PLAYER_IN_AFTERLIFE
		} )
	end )
	self:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IS_SCOPED ), function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IS_SCOPED
		} )
	end )
	self:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN ), function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN
		} )
	end )
	self:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_UI_ACTIVE ), function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_UI_ACTIVE
		} )
	end )
	
	PerkList.id = "PerkList"
	
	LUI.OverrideFunction_CallOriginalSecond( self, "close", function ( element )
		element.PerkList:close()
	end )
	
	if PostLoadFunc then
		PostLoadFunc( self, controller, menu )
	end
	
	return self
end