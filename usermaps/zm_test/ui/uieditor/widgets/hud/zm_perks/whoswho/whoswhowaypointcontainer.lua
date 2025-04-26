require("ui.uieditor.widgets.HUD.ZM_Revive.ZM_ReviveClampedArrow")
require("ui.uieditor.widgets.HUD.ZM_Perks.Whoswho.WhosWhoWaypoint")
require("ui.uieditor.widgets.HUD.ZM_Perks.whoswho.WhosWhoReviveWidget")

local f0_local0 = function (f1_arg0, f1_arg1)
	if f1_arg1.objId then
		f1_arg0.objId = f1_arg1.objId
		local f1_local0 = f1_arg0.Waypoint
		f1_local0.objective = f1_arg0.objective
		f1_local0:setupWaypoint(f1_arg1)
		if f1_local0.waypoint_image_default == nil then
			f1_local0:setState("NoIcon")
		else
			f1_local0:setState("Default")
			f1_local0.WaypointCenter.waypointCenterImage:setImage(RegisterImage(f1_local0.waypoint_image_default))
		end
		local f1_local1 = f1_arg1.controller
		local f1_local2 = f1_arg0.objId
		if f1_local0.objective.minimapMaterial ~= nil then
			Engine.SetObjectiveIcon(f1_local1, f1_local2, CoD.GametypeBase.mapIconType, f1_local0.objective.minimapMaterial)
		else
			Engine.ClearObjectiveIcon(f1_local1, f1_local2, CoD.GametypeBase.mapIconType)
		end
		if f1_local0.waypoint_label_default == "" then
			f1_local0.WaypointText:setState("NoText")
		else
			f1_local0.WaypointText:setState("Default")
		end
		if f1_local0.objective.hide_arrow then
			f1_local0.WaypointArrowContainer:setState("Invisible")
		end
		f1_local0.WaypointText.text:setText(Engine.Localize(f1_local0.waypoint_label_default))
	end
end

local f0_local1 = function (f2_arg0, f2_arg1)
	f2_arg0.Waypoint:update(f2_arg1)
	if f2_arg1.objState ~= nil then
		if f2_arg1.objState == CoD.OBJECTIVESTATE_DONE then
			f2_arg0:setState("Done")
		elseif f2_arg1.objState == CoD.OBJECTIVESTATE_CURRENT then
			f2_arg0:setState("Visible_Reviving")
			f2_arg0.ZMReviveWidget:setState("Reviving")
		else
			f2_arg0:setState("Visible")
			f2_arg0.ZMReviveWidget:setState("BleedingOut_Low")
		end
		if f2_arg0.visible == true then
			f2_arg0:show()
		else
			f2_arg0:hide()
		end
	end
end

local f0_local2 = function (f3_arg0, f3_arg1)
	local f3_local0 = f3_arg1.controller
	local f3_local1 = f3_arg0.Waypoint
	local f3_local2 = Engine.GetObjectiveTeam(f3_local0, f3_arg0.objId)
	if f3_local2 == Enum.team_t.TEAM_FREE or f3_local2 == Enum.team_t.TEAM_NEUTRAL then
		return true
	else
		return f3_local1:isOwnedByMyTeam(f3_local0)
	end
end

local PostLoadFunc = function (f4_arg0)
	f4_arg0.update = f0_local1
	f4_arg0.shouldShow = f0_local2
	f4_arg0.setupWaypointContainer = f0_local0
end

CoD.WhosWhoWaypointContainer = InheritFrom(LUI.UIElement)
CoD.WhosWhoWaypointContainer.new = function (HudRef, InstanceRef, waypointContainer, Event)

	local objectiveModel = Engine.GetModel(Engine.GetModelForController(waypointContainer), ("objective" .. Event.objId))	
	
	local Widget = LUI.UIElement.new()
	
	if PreLoadFunc then
		PreLoadFunc(Widget, InstanceRef)
	end
	
	Widget:setUseStencil(false)
	Widget:setClass(CoD.WhosWhoWaypointContainer)
	Widget.id = "WhosWhoWaypointContainer"
	Widget.soundSet = "default"
	Widget:setLeftRight(true, true, 0, 0)
	Widget:setTopBottom(true, true, 0, 0)
	Widget.anyChildUsesUpdateState = true
	
	local Waypoint = CoD.WhosWhoWaypoint.new(HudRef, InstanceRef)
	Waypoint:setLeftRight(true, false, -128, 128)
	Waypoint:setTopBottom(true, false, -128, 128)
	Widget:addElement(Waypoint)
	Widget.Waypoint = Waypoint	
	
	local playerName = LUI.UITightText.new()
	playerName:setLeftRight(true, false, 89 - 110, 267.69 - 110)
	playerName:setTopBottom(true, false, -44 - 30, 6 - 30 - 25)
	playerName:setRGB(1, 0.75, 0.44)
	playerName:setTTF("fonts/RefrigeratorDeluxe-Regular.ttf")
	playerName:setLetterSpacing(1)
	Waypoint:addElement(playerName)
	Widget.playerName = playerName
	Waypoint.playerName = playerName
	Engine.CreateModel(objectiveModel, "whoswho_clone_name")
	Widget:subscribeToModel(Engine.GetModel(objectiveModel, "whoswho_clone_name"), function(ModelRef)
		local ModelValue = Engine.GetModelValue(ModelRef)
		if ModelValue == nil then
			ModelValue = ""
		end
		playerName:setText(Engine.Localize(ModelValue))
	end)
	
	local prompt = LUI.UITightText.new()
	prompt:setLeftRight(true, false, 89 - 110, 178 - 110)
	prompt:setTopBottom(true, false, 3 - 30- 20, 43 - 30 - 40)
	prompt:setTTF("fonts/RefrigeratorDeluxe-Regular.ttf")
	prompt:setLetterSpacing(1)
	prompt:setText(Engine.Localize("ZMUI_REVIVE"))
	Waypoint:addElement(prompt)
	Widget.prompt = prompt
	Waypoint.prompt = prompt
	
	local ZMReviveWidget = CoD.WhosWhoReviveWidget.new(HudRef, InstanceRef, waypointContainer, Event)
	ZMReviveWidget:setLeftRight(false, false, -109.5, 110.5)
	ZMReviveWidget:setTopBottom(false, false, -95, 125)
	ZMReviveWidget:setScale(0.5)
	Waypoint:addElement(ZMReviveWidget)
	Widget.ZMReviveWidget = ZMReviveWidget
	
	local ZMReviveClampedArrow = CoD.ZM_ReviveClampedArrow.new(HudRef, InstanceRef)
	ZMReviveClampedArrow:setLeftRight(false, false, -130, 130)
	ZMReviveClampedArrow:setTopBottom(false, false, -17, 47)
	ZMReviveClampedArrow:setScale(0.5)
	Waypoint:addElement(ZMReviveClampedArrow)
	Widget.ZMReviveClampedArrow = ZMReviveClampedArrow
	Waypoint.ZMReviveClampedArrow = ZMReviveClampedArrow
	
	Widget.clipsPerState = 
	{
		DefaultState = 
		{
			DefaultClip = function ()
				Widget:setupElementClipCounter(3)
				playerName:completeAnimation()
				Widget.playerName:setAlpha(0)
				Widget.clipFinished(playerName, {})
				prompt:completeAnimation()
				Widget.prompt:setAlpha(0)
				Widget.clipFinished(prompt, {})
				ZMReviveClampedArrow:completeAnimation()
				Widget.ZMReviveClampedArrow:setAlpha(0)
				Widget.clipFinished(ZMReviveClampedArrow, {})
			end
		}, 
		Clamped = 
		{
			DefaultClip = function ()
				Widget:setupElementClipCounter(3)
				playerName:completeAnimation()
				Widget.playerName:setAlpha(0)
				Widget.clipFinished(playerName, {})
				prompt:completeAnimation()
				Widget.prompt:setAlpha(0)
				Widget.clipFinished(prompt, {})
				ZMReviveClampedArrow:completeAnimation()
				Widget.ZMReviveClampedArrow:setAlpha(1)
				Widget.clipFinished(ZMReviveClampedArrow, {})
			end
		}, 
		Visible_Reviving = 
		{
			DefaultClip = function ()
				Widget:setupElementClipCounter(3)
				playerName:completeAnimation()
				Widget.playerName:setAlpha(0)
				Widget.clipFinished(playerName, {})
				prompt:completeAnimation()
				Widget.prompt:setAlpha(0)
				Widget.clipFinished(prompt, {})
				ZMReviveClampedArrow:completeAnimation()
				Widget.ZMReviveClampedArrow:setAlpha(0)
				Widget.clipFinished(ZMReviveClampedArrow, {})
			end
		}, 
		Visible = 
		{
			DefaultClip = function ()
				Widget:setupElementClipCounter(3)
				playerName:completeAnimation()
				Widget.playerName:setAlpha(1)
				Widget.clipFinished(playerName, {})
				prompt:completeAnimation()
				Widget.prompt:setAlpha(1)
				Widget.clipFinished(prompt, {})
				ZMReviveClampedArrow:completeAnimation()
				Widget.ZMReviveClampedArrow:setAlpha(0)
				Widget.clipFinished(ZMReviveClampedArrow, {})
			end
		}
	}
	
	LUI.OverrideFunction_CallOriginalSecond(Widget, "close", function (Sender)
		Sender.ZMReviveWidget:close()
		Sender.ZMReviveClampedArrow:close()
		Sender.playerName:close()
		Sender.prompt:close()
	end)
	
	if PostLoadFunc then
		PostLoadFunc(Widget, InstanceRef, HudRef)
	end
	
	return Widget
end

