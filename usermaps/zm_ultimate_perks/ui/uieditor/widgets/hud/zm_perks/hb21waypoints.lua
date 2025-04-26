require("ui.uieditor.widgets.HUD.ZM_Perks.whoswho.whoswhowaypointcontainer")
require("ui.uieditor.widgets.HUD.Waypoint.GenericWaypointContainer")
require("ui.uieditor.widgets.MPHudWidgets.WaypointBase")

local f0_local0 = function (f1_arg0, f1_arg1, f1_arg2)
	local f1_local0 = {}
	local f1_local1 = f1_arg0.Waypoint
	local f1_local2 = Engine.GetObjectiveGamemodeFlags(f1_arg1, f1_arg0.objId)
	f1_local0.mapimagename = f1_arg0.waypoint_image_map
	if f1_local2 == f1_arg0.robotShutdown then
		f1_local0.progresscolor = CoD.GetColorBlindColorForPlayer(f1_arg1, "PlayerYellow")
		f1_local0.imagename = f1_arg0.waypoint_image_shutdown
	else
		f1_local0.progresscolor = CoD.white
		f1_local0.imagename = f1_arg0.waypoint_image
	end
	if f1_local1:isOwnedByMyTeam(f1_arg1) then
		f1_local0.imagecolor = CoD.GetColorSetFriendlyColor(f1_arg1, f1_local1:getTeam(f1_arg1))
		f1_local0.centerPulse = false
		if f1_local2 == f1_arg0.robotShutdown then
			f1_local0.waypointType = f1_arg0.waypoint_text_shutdown
		elseif f1_arg0.Waypoint.playerUsing ~= nil and f1_arg0.Waypoint.playerUsing == true then
			f1_local0.waypointType = f1_arg0.waypoint_text_escorting
			f1_local0.centerPulse = true
		else
			f1_local0.waypointType = f1_arg0.waypoint_text
		end
	else
		f1_local0.imagecolor = CoD.GetColorSetEnemyColor(f1_arg1, f1_local1:getTeam(f1_arg1))
		if f1_local2 == f1_arg0.robotShutdown then
			f1_local0.waypointType = f1_arg0.waypoint_text_shutdown
		else
			f1_local0.waypointType = f1_arg0.waypoint_text_enemy
		end
	end
	return f1_local0
end

local f0_local1 = function (f2_arg0, f2_arg1)
	local f2_local0 = f2_arg1.controller
	local f2_local1 = f2_arg0.objId
	local f2_local2 = f2_arg0.Waypoint
	f2_local2.zOffset = f2_arg0.waypoint_z_offset
	local f2_local3 = f0_local0(f2_arg0, f2_local0, f2_local1)
	if f2_local3.progresscolor then
		f2_local2.progressMeter:setRGB(f2_local3.progresscolor.r, f2_local3.progresscolor.g, f2_local3.progresscolor.b)
	end
	if f2_local3.imagename then
		f2_local2.WaypointCenter.waypointCenterImage:setImage(RegisterImage(f2_local3.imagename))
		if f2_local3.imagecolor then
			f2_local2.WaypointCenter.waypointCenterImage:setRGB(f2_local3.imagecolor.r, f2_local3.imagecolor.g, f2_local3.imagecolor.b)
		end
	end
	if f2_local3.waypointType then
		f2_local2.WaypointText.text:setText(Engine.Localize(f2_local3.waypointType))
	end
	if f2_local3.centerPulse then
		f2_local2.WaypointCenter:setState("Pulsing")
	else
		f2_local2.WaypointCenter:setState("DefaultState")
	end
	if f2_arg0.visible == true then
		f2_arg0:show()
		f2_local2:update(f2_arg1)
		f2_local2:setCompassObjectiveIcon(f2_local0, f2_local1, f2_local3.mapimagename, f2_local3.imagecolor)
		Engine.SetObjectiveIgnoreEntity(f2_local0, f2_local1, CoD.GametypeBase.mapIconType, f2_local2.ping == true)
	else
		f2_arg0:hide()
		f2_local2:clearCompassObjectiveIcon(f2_local0, f2_local1)
	end
end

local f0_local2 = function (f3_arg0, f3_arg1, f3_arg2, f3_arg3)
	f3_arg0.progressMeter:setShaderVector(0, Engine.GetObjectiveProgress(f3_arg1, f3_arg0.objId), 0, 0, 0)
end

local f0_local3 = function (f4_arg0, f4_arg1)
	if f4_arg1.objId then
		f4_arg0.objId = f4_arg1.objId
		local f4_local0 = f4_arg0.Waypoint
		f4_local0.objective = f4_arg0.objective
		f4_local0:setupWaypoint(f4_arg1)
		f4_local0.snapToCenterWhenContested = false
		f4_local0.snapToCenterForOtherTeams = false
		f4_local0.updateProgress = f0_local2
		f4_local0.ProgressMeterFrame:setAlpha(1)
		f4_local0.WaypointArrowContainer:setState("Progress")
		local f4_local1 = f4_arg0.objective.id
		f4_arg0.waypoint_text = Engine.StructTableLookupString("objectives", "id", f4_local1, "waypoint_text")
		f4_arg0.waypoint_text_enemy = Engine.StructTableLookupString("objectives", "id", f4_local1, "waypoint_text_enemy")
		f4_arg0.waypoint_text_escorting = Engine.StructTableLookupString("objectives", "id", f4_local1, "waypoint_text_escorting")
		f4_arg0.waypoint_text_shutdown = Engine.StructTableLookupString("objectives", "id", f4_local1, "waypoint_text_shutdown")
		f4_arg0.waypoint_image = Engine.StructTableLookupString("objectives", "id", f4_local1, "waypoint_image")
		f4_arg0.waypoint_image_map = Engine.StructTableLookupString("objectives", "id", f4_local1, "waypoint_image_map")
		f4_arg0.waypoint_image_shutdown = Engine.StructTableLookupString("objectives", "id", f4_local1, "waypoint_image_shutdown")
		f4_arg0.waypoint_z_offset = Engine.StructTableLookupNumber("objectives", "id", f4_local1, "waypoint_z_offset")
	end
end

local f0_local4 = function (f5_arg0, f5_arg1)
	return true
end

local f0_local5 = function (f6_arg0)
	f6_arg0.update = f0_local1
	f6_arg0.setupWaypointContainer = f0_local3
	f6_arg0.shouldShow = f0_local4
	f6_arg0.robotNone = 0
	f6_arg0.robotMoving = 1
	f6_arg0.robotShutdown = 2
end

function CoD.GetCachedObjective(HudRef)
    if HudRef == nil then
        return nil
    end
    if CoD.Zombie.ObjectivesTable[HudRef] ~= nil then
        return CoD.Zombie.ObjectivesTable[HudRef]
    end
    local objective = Engine.GetObjectiveInfo(HudRef)
    if objective ~= nil then
        CoD.Zombie.ObjectivesTable[HudRef] = objective
    end
    return objective
end

local function PreLoadCallback(HudRef, InstanceRef)
    CoD.Zombie.CommonPreLoadHud(HudRef, InstanceRef)
end

CoD.Waypoints = function(HudRef, InstanceRef)
	 local function AddObjectiveElements(HudRef, InstanceRef)
        -- Create elements for objective display
        HudRef.GenericWaypointContainer = CoD.GenericWaypointContainer.new(HudRef, InstanceRef)
        HudRef.GenericWaypointContainer:setLeftRight(false, false, -640, 640)
        HudRef.GenericWaypointContainer:setTopBottom(false, false, -360, 360)
        HudRef.GenericWaypointContainer:setAlpha(0)
        HudRef:addElement(HudRef.GenericWaypointContainer)
        
        HudRef.WaypointBase = CoD.WaypointBase.new(HudRef, InstanceRef)
        HudRef.WaypointBase:setLeftRight(false, false, -640, 640)
        HudRef.WaypointBase:setTopBottom(false, false, -360, 360)
        HudRef.WaypointBase.WaypointContainerList = {}
        HudRef:addElement(HudRef.WaypointBase)
 
        HudRef.WaypointBase:registerEventHandler("menu_loaded", function(Sender, Event)
            SizeToSafeArea(Sender, InstanceRef)
            f65_local0 = Sender:dispatchEventToChildren(Event)
			return f65_local0
        end)
    end
    AddObjectiveElements(HudRef, InstanceRef)
    -- Handle everything
    local function HandleObjectiveWaypoint(WaypointBase, ObjectiveData)
        local objectiveName = Engine.GetObjectiveName(ObjectiveData.controller, ObjectiveData.objId)
        local objective = CoD.GetCachedObjective(objectiveName)
        if objective == nil then
            return 
        end
 
        if Dvar.cg_luiDebug:get() == true then
            DebugPrint("Waypoint ID " .. ObjectiveData.objId .. ": " .. objectiveName .. ": " .. #WaypointBase.WaypointContainerList .. " waypoints active")
        end
        if not WaypointBase.savedStates then
            WaypointBase.savedStates = {}
            WaypointBase.savedEntNums = {}
            WaypointBase.savedObjectiveNames = {}
            WaypointBase.savedTeam = -1
            WaypointBase.savedRound = -1
        end
 
        local objectiveState = Engine.GetObjectiveState(InstanceRef, ObjectiveData.objId)
        local savedObjectiveState = WaypointBase.savedStates[ObjectiveData.objId]
        if not savedObjectiveState then
            savedObjectiveState = CoD.OBJECTIVESTATE_EMPTY
        end
        
        local objectiveModel = Engine.GetModel(Engine.GetModelForController(ObjectiveData.controller), "objective" .. ObjectiveData.objId)
        local objectiveStateModel
        if objectiveModel == 0 then
            objectiveStateModel = objectiveModel
        else
            objectiveStateModel = Engine.GetModel(objectiveModel, "state")
        end
 
        local entNumModel = CoD.SafeGetModelValue(objectiveModel, "entNum")
        local teamID = CoD.GetTeamID(InstanceRef)
        local roundsPlayed = Engine.GetRoundsPlayed(InstanceRef)
 
        if teamID ~= WaypointBase.savedTeam or roundsPlayed ~= WaypointBase.savedRound then
            WaypointBase.savedStates = {}
            WaypointBase.savedEntNums = {}
            WaypointBase.savedObjectiveNames = {}
        end
 
        if not CoD.isCampaign and Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_GAME_ENDED) and objectiveState == savedObjectiveState and entNumModel == WaypointBase.savedEntNums[ObjectiveData.objId] and objectiveName == WaypointBase.savedObjectiveNames[ObjectiveData.objId] then
            if objectiveStateModel ~= nil then
                Engine.ForceNotifyModelSubscriptions(objectiveStateModel)
            end
            return 
        elseif objectiveStateModel ~= nil then
            local ModelValue = Engine.GetModelValue(objectiveStateModel)
            Engine.SetModelValue(objectiveStateModel, CoD.OBJECTIVESTATE_EMPTY)
            Engine.SetModelValue(objectiveStateModel, ModelValue)
        end
 
        WaypointBase.savedStates[ObjectiveData.objId] = objectiveState
        WaypointBase.savedEntNums[ObjectiveData.objId] = entNumModel
        WaypointBase.savedObjectiveNames[ObjectiveData.objId] = objectiveName
        WaypointBase.savedTeam = teamID
        WaypointBase.savedRound = roundsPlayed
        if objectiveName then
            local waypointContainer = CoD.WaypointWidgetContainer.new(WaypointBase, ObjectiveData.controller)
			waypointContainer:setLeftRight(true, true, 0, 0)
			waypointContainer:setTopBottom(true, true, 0, 0)
            waypointContainer.objective = objective
            
            -- In setup waypoint, need to check for the right objective from registered ones
            waypointContainer.setupWaypoint = function(waypointContainer, ObjectiveData)                
                local controller = ObjectiveData.controller
                if waypointContainer.objective.id == "waypoint_whoswho" then
					waypointContainer.gameTypeContainer = CoD.WhosWhoWaypointContainer.new(waypointContainer.menu, controller, waypointContainer, ObjectiveData)
				else
                    waypointContainer.gameTypeContainer = CoD.GenericWaypointContainer.new(waypointContainer.menu, controller)
				end
				waypointContainer.gameTypeContainer:setLeftRight(true, true, 0, 0)
                waypointContainer.gameTypeContainer:setTopBottom(true, true, 0, 0)
                waypointContainer:addElement(waypointContainer.gameTypeContainer)
                waypointContainer.gameTypeContainer.objective = waypointContainer.objective
                waypointContainer.gameTypeContainer:setupWaypointContainer(ObjectiveData)
            end
            
            waypointContainer:setupWaypoint(ObjectiveData)
            WaypointBase:addElement(waypointContainer)
 
            table.insert(WaypointBase.WaypointContainerList, waypointContainer)
            waypointContainer:update(ObjectiveData)
            waypointContainer:setModel(objectiveModel)
 
            local controller = ObjectiveData.controller
            waypointContainer:subscribeToModel(objectiveStateModel, function(ModelRef)
                local ModelValue = Engine.GetModelValue(ModelRef)
                WaypointBase.savedStates[ObjectiveData.objId] = ModelValue
                if ModelValue == CoD.OBJECTIVESTATE_ACTIVE or ModelValue == CoD.OBJECTIVESTATE_CURRENT or ModelValue == CoD.OBJECTIVESTATE_DONE then
                    waypointContainer:show()
                    waypointContainer:update({controller = controller, objState = ModelValue})
                elseif ModelValue == CoD.OBJECTIVESTATE_EMPTY then
                    WaypointBase:removeWaypoint(ObjectiveData.objId)
                    WaypointBase.savedEntNums[ObjectiveData.objId] = nil
                else
                    waypointContainer:hide()
                end
            end)
 
            local updateTimeModel = Engine.GetModel(objectiveModel, "updateTime")
            if updateTimeModel ~= nil then
                waypointContainer:subscribeToModel(updateTimeModel, function(ModelRef)
                    waypointContainer:update({controller = controller})
                end)
            end
			
			waypointContainer:subscribeToModel(Engine.GetModel(objectiveModel, "whoswho_clone_bleedout_percent"), function(ModelRef)
                waypointContainer:update({controller = controller, progress = Engine.GetModelValue(ModelRef)})
            end)
			
			waypointContainer:subscribeToModel(Engine.GetModel(objectiveModel, "whoswho_clone_revive_percent"), function(ModelRef)
                waypointContainer:update({controller = controller, progress = Engine.GetModelValue(ModelRef)})
            end)
			
			waypointContainer:subscribeToModel(Engine.GetModel(objectiveModel, "whoswho_clone_name"), function(ModelRef)
                waypointContainer:update({controller = controller, progress = Engine.GetModelValue(ModelRef)})
            end)
 
            waypointContainer:subscribeToModel(Engine.GetModel(objectiveModel, "clientUseMask"), function(ModelRef)
                waypointContainer:update({controller = controller, clientUseMask = Engine.GetModelValue(ModelRef)})
            end)
 
            local colorblindModel = Engine.GetModel(Engine.GetModelForController(ObjectiveData.controller), "profile.colorBlindMode")
            if colorblindModel then
                waypointContainer:subscribeToModel(colorblindModel, function(ModelRef)
                    waypointContainer:update({controller = controller})
                end, false)
            end
        end
        return true
    end
 
    CoD.Zombie.ObjectivesTable = Engine.BuildObjectivesTable()
    if CoD.Zombie.ObjectivesTable == nil or #CoD.Zombie.ObjectivesTable == 0 then
        error("LUI Error: Failed to load objectives.json!")
    end
 
    -- Weird stuff they do to use the objective ID as the key in the ObjectivesTable instead of using a numbered index.
    -- This allows them to reference objectives easier.
    for index = #CoD.Zombie.ObjectivesTable, 1, -1 do
        local objective = CoD.Zombie.ObjectivesTable[index]
        CoD.Zombie.ObjectivesTable[objective.id] = objective
        table.remove(CoD.Zombie.ObjectivesTable, index)
    end

    HudRef:subscribeToModel(Engine.CreateModel(Engine.GetModelForController(InstanceRef), "newObjectiveType" .. Enum.ObjectiveTypes.OBJECTIVE_TYPE_WAYPOINT), function(ModelRef)
        HandleObjectiveWaypoint(HudRef.WaypointBase, {controller = InstanceRef, objId = Engine.GetModelValue(ModelRef), objType = Enum.ObjectiveTypes.OBJECTIVE_TYPE_WAYPOINT})
    end, false)
end