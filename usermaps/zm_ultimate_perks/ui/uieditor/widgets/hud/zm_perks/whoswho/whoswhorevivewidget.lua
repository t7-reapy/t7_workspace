require("ui.uieditor.widgets.HUD.ZM_Revive.ZM_ReviveBleedoutRedEyeGlow")
require("ui.uieditor.widgets.HUD.core_AmmoWidget.AmmoWidget_AbilityGlow")
CoD.WhosWhoReviveWidget = InheritFrom(LUI.UIElement)
CoD.WhosWhoReviveWidget.new = function (HudRef, InstanceRef, waypointContainer, Event)

	local objectiveModel = Engine.GetModel(Engine.GetModelForController(waypointContainer), ("objective" .. Event.objId))	
	
	local Widget = LUI.UIElement.new()
	
	if PreLoadFunc then
		PreLoadFunc(Widget, InstanceRef)
	end
	
	Widget:setUseStencil(false)
	Widget:setClass(CoD.WhosWhoReviveWidget)
	Widget.id = "WhosWhoReviveWidget"
	Widget.soundSet = "default"
	Widget:setLeftRight(false, false, 0, 220)
	Widget:setTopBottom(false, false, 0, 120)
	Widget.anyChildUsesUpdateState = true

	local GlowOrangeOver = LUI.UIImage.new()
	GlowOrangeOver:setLeftRight(false, false, -80, 80)
	GlowOrangeOver:setTopBottom(false, false, -126.5, 126.5)
	GlowOrangeOver:setRGB(1, 0.31, 0)
	GlowOrangeOver:setAlpha(0.4)
	GlowOrangeOver:setZRot(90)
	GlowOrangeOver:setImage(RegisterImage("uie_t7_core_hud_mapwidget_panelglow"))
	GlowOrangeOver:setMaterial(LUI.UIImage.GetCachedMaterial("ui_add"))
	Widget:addElement(GlowOrangeOver)
	Widget.GlowOrangeOver = GlowOrangeOver
	
	local glow = LUI.UIImage.new()
	glow:setLeftRight(false, false, -70, 70)
	glow:setTopBottom(false, false, -70, 70)
	glow:setImage(RegisterImage("uie_t7_zm_hud_revive_glow"))
	Widget:addElement(glow)
	Widget.glow = glow
	
	local RingGlow = LUI.UIImage.new()
	RingGlow:setLeftRight(false, false, -70, 70)
	RingGlow:setTopBottom(false, false, -70, 70)
	RingGlow:setRGB(1, 0.72, 0)
	RingGlow:setAlpha(0)
	RingGlow:setImage(RegisterImage("uie_t7_zm_hud_revive_ringblur"))
	RingGlow:setMaterial(LUI.UIImage.GetCachedMaterial("ui_add"))
	Widget:addElement(RingGlow)
	Widget.RingGlow = RingGlow
	
	local RingMiddle = LUI.UIImage.new()
	RingMiddle:setLeftRight(false, false, -70, 70)
	RingMiddle:setTopBottom(false, false, -70, 70)
	RingMiddle:setRGB(1, 0.45, 0)
	RingMiddle:setAlpha(0.1)
	RingMiddle:setImage(RegisterImage("uie_t7_zm_hud_revive_ringmiddle"))
	RingMiddle:setMaterial(LUI.UIImage.GetCachedMaterial("ui_add"))
	Widget:addElement(RingMiddle)
	Widget.RingMiddle = RingMiddle
	
	local RingTopBleedOut = LUI.UIImage.new()
	RingTopBleedOut:setLeftRight(false, false, -70, 70)
	RingTopBleedOut:setTopBottom(false, false, -70, 70)
	RingTopBleedOut:setRGB(1, 0.92, 0)
	RingTopBleedOut:setImage(RegisterImage("uie_t7_zm_hud_revive_ringtop"))
	RingTopBleedOut:setMaterial(LUI.UIImage.GetCachedMaterial("uie_clock_add"))
	RingTopBleedOut:setShaderVector(1, 0.5, 0, 0, 0)
	RingTopBleedOut:setShaderVector(2, 0.5, 0, 0, 0)
	RingTopBleedOut:setShaderVector(3, 0.05, 0, 0, 0)
	Engine.CreateModel(objectiveModel, "whoswho_clone_bleedout_percent")
	Widget:subscribeToModel(Engine.GetModel(objectiveModel, "whoswho_clone_bleedout_percent"), function(ModelRef)
		local ModelValue = Engine.GetModelValue(ModelRef)
		if ModelValue then
			RingTopBleedOut:beginAnimation("keyframe", 1000, false, false, CoD.TweenType.Linear)
			RingTopBleedOut:setShaderVector(0, CoD.GetVectorComponentFromString(ModelValue, 1), CoD.GetVectorComponentFromString(ModelValue, 2), CoD.GetVectorComponentFromString(ModelValue, 3), CoD.GetVectorComponentFromString(ModelValue, 4))
		end
	end)
	
	Widget:addElement(RingTopBleedOut)
	Widget.RingTopBleedOut = RingTopBleedOut
	
	local RingTopRevive = LUI.UIImage.new()
	RingTopRevive:setLeftRight(false, false, -70, 70)
	RingTopRevive:setTopBottom(false, false, -70, 70)
	RingTopRevive:setRGB(0, 1, 0.01)
	RingTopRevive:setAlpha(0)
	RingTopRevive:setImage(RegisterImage("uie_t7_zm_hud_revive_ringtop"))
	RingTopRevive:setMaterial(LUI.UIImage.GetCachedMaterial("uie_clock_add"))
	RingTopRevive:setShaderVector(1, 0.5, 0, 0, 0)
	RingTopRevive:setShaderVector(2, 0.65, 0, 0, 0)
	RingTopRevive:setShaderVector(3, 0.34, 0, 0, 0)
	Engine.CreateModel(objectiveModel, "whoswho_clone_revive_percent")
	Widget:subscribeToModel(Engine.GetModel(objectiveModel, "whoswho_clone_revive_percent"), function(ModelRef)
		local ModelValue = Engine.GetModelValue(ModelRef)
		if ModelValue then
			RingTopRevive:beginAnimation("keyframe", 100, false, false, CoD.TweenType.Linear)
			RingTopRevive:setShaderVector(0, CoD.GetVectorComponentFromString(ModelValue, 1), CoD.GetVectorComponentFromString(ModelValue, 2), CoD.GetVectorComponentFromString(ModelValue, 3), CoD.GetVectorComponentFromString(ModelValue, 4))
		end
	end)
	Widget:addElement(RingTopRevive)
	Widget.RingTopRevive = RingTopRevive
	
	local Skull = LUI.UIImage.new()
	Skull:setLeftRight(false, false, -70, 70)
	Skull:setTopBottom(false, false, -70, 70)
	Skull:setImage(RegisterImage("uie_t7_zm_hud_revive_skull"))
	Widget:addElement(Skull)
	Widget.skull = Skull
	
	local AbilitySwirl = LUI.UIImage.new()
	AbilitySwirl:setLeftRight(false, false, -67.86, 69)
	AbilitySwirl:setTopBottom(false, false, -69, 67.86)
	AbilitySwirl:setRGB(1, 0.64, 0)
	AbilitySwirl:setAlpha(0)
	AbilitySwirl:setScale(1.3)
	AbilitySwirl:setImage(RegisterImage("uie_t7_core_hud_ammowidget_abilityswirl"))
	AbilitySwirl:setMaterial(LUI.UIImage.GetCachedMaterial("ui_add"))
	Widget:addElement(AbilitySwirl)
	Widget.AbilitySwirl = AbilitySwirl
	
	local ZMReviveBleedoutRedEyeGlow = CoD.ZM_ReviveBleedoutRedEyeGlow.new(HudRef, InstanceRef)
	ZMReviveBleedoutRedEyeGlow:setLeftRight(false, false, -23.91, -6.75)
	ZMReviveBleedoutRedEyeGlow:setTopBottom(false, false, 3.48, 21.64)
	Widget:addElement(ZMReviveBleedoutRedEyeGlow)
	Widget.ZMReviveBleedoutRedEyeGlow = ZMReviveBleedoutRedEyeGlow
	
	local ZMReviveBleedoutRedEyeGlow0 = CoD.ZM_ReviveBleedoutRedEyeGlow.new(HudRef, InstanceRef)
	ZMReviveBleedoutRedEyeGlow0:setLeftRight(false, false, 6.09, 23.25)
	ZMReviveBleedoutRedEyeGlow0:setTopBottom(false, false, 3.48, 21.64)
	Widget:addElement(ZMReviveBleedoutRedEyeGlow0)
	Widget.ZMReviveBleedoutRedEyeGlow0 = ZMReviveBleedoutRedEyeGlow0
	
	local Glow0 = CoD.AmmoWidget_AbilityGlow.new(HudRef, InstanceRef)
	Glow0:setLeftRight(true, true, 4, -4)
	Glow0:setTopBottom(true, true, 4, -4)
	Glow0:setRGB(1, 0.49, 0)
	Glow0:setAlpha(0)
	Glow0:setZoom(13.47)
	Glow0:setScale(0.7)
	Widget:addElement(Glow0)
	Widget.Glow0 = Glow0
	
	Widget.clipsPerState = 
	{
		DefaultState = 
		{
			DefaultClip = function ()
				Widget:setupElementClipCounter(9)
				GlowOrangeOver:completeAnimation()
				Widget.GlowOrangeOver:setAlpha(0)
				Widget.clipFinished(GlowOrangeOver, {})
				glow:completeAnimation()
				Widget.glow:setAlpha(0)
				Widget.clipFinished(glow, {})
				RingGlow:completeAnimation()
				Widget.RingGlow:setAlpha(0)
				Widget.clipFinished(RingGlow, {})
				RingMiddle:completeAnimation()
				Widget.RingMiddle:setAlpha(0)
				Widget.clipFinished(RingMiddle, {})
				RingTopBleedOut:completeAnimation()
				Widget.RingTopBleedOut:setAlpha(0)
				Widget.clipFinished(RingTopBleedOut, {})
				Skull:completeAnimation()
				Widget.skull:setAlpha(0)
				Widget.clipFinished(Skull, {})
				ZMReviveBleedoutRedEyeGlow:completeAnimation()
				Widget.ZMReviveBleedoutRedEyeGlow:setAlpha(0)
				Widget.clipFinished(ZMReviveBleedoutRedEyeGlow, {})
				ZMReviveBleedoutRedEyeGlow0:completeAnimation()
				Widget.ZMReviveBleedoutRedEyeGlow0:setAlpha(0)
				Widget.clipFinished(ZMReviveBleedoutRedEyeGlow0, {})
				Glow0:completeAnimation()
				Widget.Glow0:setAlpha(0)
				Widget.clipFinished(Glow0, {})
			end
		}, 
		Reviving = 
		{
			DefaultClip = function ()
				Widget:setupElementClipCounter(11)
				GlowOrangeOver:completeAnimation()
				Widget.GlowOrangeOver:setRGB(0, 1, 0.01)
				Widget.GlowOrangeOver:setAlpha(0.4)
				local f6_local0 = function (f36_arg0, f36_arg1)
					local f36_local0 = function (f39_arg0, f39_arg1)
						local f39_local0 = function (f40_arg0, f40_arg1)
							local f40_local0 = function (f41_arg0, f41_arg1)
								local f41_local0 = function (f42_arg0, f42_arg1)
									if not f42_arg1.interrupted then
										f42_arg0:beginAnimation("keyframe", 289, false, false, CoD.TweenType.Linear)
									end
									f42_arg0:setRGB(0, 1, 0.01)
									f42_arg0:setAlpha(0.4)
									if f42_arg1.interrupted then
										Widget.clipFinished(f42_arg0, f42_arg1)
									else
										f42_arg0:registerEventHandler("transition_complete_keyframe", Widget.clipFinished)
									end
								end

								if f41_arg1.interrupted then
									f41_local0(f41_arg0, f41_arg1)
									return 
								else
									f41_arg0:beginAnimation("keyframe", 120, false, false, CoD.TweenType.Linear)
									f41_arg0:setAlpha(0.7)
									f41_arg0:registerEventHandler("transition_complete_keyframe", f41_local0)
								end
							end

							if f40_arg1.interrupted then
								f40_local0(f40_arg0, f40_arg1)
								return 
							else
								f40_arg0:beginAnimation("keyframe", 200, false, false, CoD.TweenType.Linear)
								f40_arg0:registerEventHandler("transition_complete_keyframe", f40_local0)
							end
						end

						if f39_arg1.interrupted then
							f39_local0(f39_arg0, f39_arg1)
							return 
						else
							f39_arg0:beginAnimation("keyframe", 300, false, false, CoD.TweenType.Linear)
							f39_arg0:setAlpha(0.4)
							f39_arg0:registerEventHandler("transition_complete_keyframe", f39_local0)
						end
					end

					if f36_arg1.interrupted then
						f36_local0(f36_arg0, f36_arg1)
						return 
					else
						f36_arg0:beginAnimation("keyframe", 100, false, false, CoD.TweenType.Linear)
						f36_arg0:setAlpha(0.71)
						f36_arg0:registerEventHandler("transition_complete_keyframe", f36_local0)
					end
				end

				f6_local0(GlowOrangeOver, {})
				glow:completeAnimation()
				Widget.glow:setAlpha(1)
				Widget.clipFinished(glow, {})
				RingGlow:completeAnimation()
				Widget.RingGlow:setRGB(0, 1, 0.01)
				Widget.RingGlow:setAlpha(0)
				Widget.clipFinished(RingGlow, {})
				RingMiddle:completeAnimation()
				Widget.RingMiddle:setRGB(0, 1, 0.01)
				Widget.RingMiddle:setAlpha(0.06)
				Widget.clipFinished(RingMiddle, {})
				RingTopBleedOut:completeAnimation()
				Widget.RingTopBleedOut:setRGB(0, 1, 0.01)
				Widget.RingTopBleedOut:setAlpha(0)
				Widget.clipFinished(RingTopBleedOut, {})
				RingTopRevive:completeAnimation()
				Widget.RingTopRevive:setAlpha(1)
				Widget.RingTopRevive:setMaterial(LUI.UIImage.GetCachedMaterial("uie_clock_add"))
				Widget.RingTopRevive:setShaderVector(1, 0.5, 0, 0, 0)
				Widget.RingTopRevive:setShaderVector(2, 0.5, 0, 0, 0)
				Widget.RingTopRevive:setShaderVector(3, 0.05, 0, 0, 0)
				Widget.clipFinished(RingTopRevive, {})
				Skull:completeAnimation()
				Widget.skull:setAlpha(1)
				Widget.skull:setScale(1)
				local f6_local1 = function (f37_arg0, f37_arg1)
					local f37_local0 = function (f43_arg0, f43_arg1)
						if not f43_arg1.interrupted then
							f43_arg0:beginAnimation("keyframe", 909, false, false, CoD.TweenType.Linear)
						end
						f43_arg0:setAlpha(1)
						f43_arg0:setScale(1)
						if f43_arg1.interrupted then
							Widget.clipFinished(f43_arg0, f43_arg1)
						else
							f43_arg0:registerEventHandler("transition_complete_keyframe", Widget.clipFinished)
						end
					end

					if f37_arg1.interrupted then
						f37_local0(f37_arg0, f37_arg1)
						return 
					else
						f37_arg0:beginAnimation("keyframe", 100, false, false, CoD.TweenType.Linear)
						f37_arg0:setScale(1.2)
						f37_arg0:registerEventHandler("transition_complete_keyframe", f37_local0)
					end
				end

				f6_local1(Skull, {})
				AbilitySwirl:completeAnimation()
				Widget.AbilitySwirl:setAlpha(0)
				Widget.clipFinished(AbilitySwirl, {})
				ZMReviveBleedoutRedEyeGlow:completeAnimation()
				Widget.ZMReviveBleedoutRedEyeGlow:setRGB(1, 1, 1)
				Widget.ZMReviveBleedoutRedEyeGlow:setAlpha(0)
				Widget.clipFinished(ZMReviveBleedoutRedEyeGlow, {})
				ZMReviveBleedoutRedEyeGlow0:completeAnimation()
				Widget.ZMReviveBleedoutRedEyeGlow0:setRGB(1, 1, 1)
				Widget.ZMReviveBleedoutRedEyeGlow0:setAlpha(0)
				Widget.clipFinished(ZMReviveBleedoutRedEyeGlow0, {})
				Glow0:completeAnimation()
				Widget.Glow0:setRGB(0, 1, 0.01)
				Widget.Glow0:setAlpha(0)
				local f6_local2 = function (f38_arg0, f38_arg1)
					local f38_local0 = function (f44_arg0, f44_arg1)
						if not f44_arg1.interrupted then
							f44_arg0:beginAnimation("keyframe", 909, false, false, CoD.TweenType.Linear)
						end
						f44_arg0:setRGB(0, 1, 0.01)
						f44_arg0:setAlpha(0.1)
						if f44_arg1.interrupted then
							Widget.clipFinished(f44_arg0, f44_arg1)
						else
							f44_arg0:registerEventHandler("transition_complete_keyframe", Widget.clipFinished)
						end
					end

					if f38_arg1.interrupted then
						f38_local0(f38_arg0, f38_arg1)
						return 
					else
						f38_arg0:beginAnimation("keyframe", 100, false, false, CoD.TweenType.Linear)
						f38_arg0:setAlpha(0.1)
						f38_arg0:registerEventHandler("transition_complete_keyframe", f38_local0)
					end
				end

				f6_local2(Glow0, {})
				Widget.nextClip = "DefaultClip"
			end
		}, 
		BleedingOut_Low = 
		{
			DefaultClip = function ()
				Widget:setupElementClipCounter(11)
				GlowOrangeOver:completeAnimation()
				Widget.GlowOrangeOver:setRGB(0.61, 0.01, 0)
				Widget.GlowOrangeOver:setAlpha(0.4)
				local f7_local0 = function (f45_arg0, f45_arg1)
					local f45_local0 = function (f50_arg0, f50_arg1)
						local f50_local0 = function (f51_arg0, f51_arg1)
							local f51_local0 = function (f52_arg0, f52_arg1)
								if not f52_arg1.interrupted then
									f52_arg0:beginAnimation("keyframe", 290, false, false, CoD.TweenType.Linear)
								end
								f52_arg0:setRGB(0.61, 0.01, 0)
								f52_arg0:setAlpha(0.4)
								if f52_arg1.interrupted then
									Widget.clipFinished(f52_arg0, f52_arg1)
								else
									f52_arg0:registerEventHandler("transition_complete_keyframe", Widget.clipFinished)
								end
							end

							if f51_arg1.interrupted then
								f51_local0(f51_arg0, f51_arg1)
								return 
							else
								f51_arg0:beginAnimation("keyframe", 69, false, false, CoD.TweenType.Linear)
								f51_arg0:setAlpha(0.8)
								f51_arg0:registerEventHandler("transition_complete_keyframe", f51_local0)
							end
						end

						if f50_arg1.interrupted then
							f50_local0(f50_arg0, f50_arg1)
							return 
						else
							f50_arg0:beginAnimation("keyframe", 70, false, false, CoD.TweenType.Linear)
							f50_arg0:setAlpha(0.4)
							f50_arg0:registerEventHandler("transition_complete_keyframe", f50_local0)
						end
					end

					if f45_arg1.interrupted then
						f45_local0(f45_arg0, f45_arg1)
						return 
					else
						f45_arg0:beginAnimation("keyframe", 70, false, false, CoD.TweenType.Linear)
						f45_arg0:setAlpha(0.8)
						f45_arg0:registerEventHandler("transition_complete_keyframe", f45_local0)
					end
				end

				f7_local0(GlowOrangeOver, {})
				glow:completeAnimation()
				Widget.glow:setRGB(1, 0.38, 0.38)
				Widget.glow:setAlpha(1)
				Widget.clipFinished(glow, {})
				RingGlow:completeAnimation()
				Widget.RingGlow:setRGB(1, 0, 0.12)
				Widget.RingGlow:setAlpha(0)
				Widget.clipFinished(RingGlow, {})
				RingMiddle:completeAnimation()
				Widget.RingMiddle:setRGB(1, 0, 0)
				Widget.RingMiddle:setAlpha(0.06)
				Widget.clipFinished(RingMiddle, {})
				RingTopBleedOut:completeAnimation()
				Widget.RingTopBleedOut:setRGB(1, 0, 0.06)
				Widget.RingTopBleedOut:setAlpha(1)
				Widget.clipFinished(RingTopBleedOut, {})
				RingTopRevive:completeAnimation()
				Widget.RingTopRevive:setAlpha(0)
				Widget.clipFinished(RingTopRevive, {})
				Skull:completeAnimation()
				Widget.skull:setAlpha(1)
				Widget.skull:setScale(1)
				local f7_local1 = function (f46_arg0, f46_arg1)
					local f46_local0 = function (f53_arg0, f53_arg1)
						if not f53_arg1.interrupted then
							f53_arg0:beginAnimation("keyframe", 430, false, false, CoD.TweenType.Linear)
						end
						f53_arg0:setAlpha(1)
						f53_arg0:setScale(1)
						if f53_arg1.interrupted then
							Widget.clipFinished(f53_arg0, f53_arg1)
						else
							f53_arg0:registerEventHandler("transition_complete_keyframe", Widget.clipFinished)
						end
					end

					if f46_arg1.interrupted then
						f46_local0(f46_arg0, f46_arg1)
						return 
					else
						f46_arg0:beginAnimation("keyframe", 70, false, false, CoD.TweenType.Linear)
						f46_arg0:setScale(1.1)
						f46_arg0:registerEventHandler("transition_complete_keyframe", f46_local0)
					end
				end

				f7_local1(Skull, {})
				AbilitySwirl:completeAnimation()
				Widget.AbilitySwirl:setAlpha(0)
				Widget.clipFinished(AbilitySwirl, {})
				ZMReviveBleedoutRedEyeGlow:completeAnimation()
				Widget.ZMReviveBleedoutRedEyeGlow:setLeftRight(false, false, -23.91, -6.75)
				Widget.ZMReviveBleedoutRedEyeGlow:setTopBottom(false, false, 3.48, 21.64)
				Widget.ZMReviveBleedoutRedEyeGlow:setAlpha(1)
				local f7_local2 = function (f47_arg0, f47_arg1)
					local f47_local0 = function (f54_arg0, f54_arg1)
						if not f54_arg1.interrupted then
							f54_arg0:beginAnimation("keyframe", 430, false, false, CoD.TweenType.Linear)
						end
						f54_arg0:setLeftRight(false, false, -23.91, -6.75)
						f54_arg0:setTopBottom(false, false, 3.48, 21.64)
						f54_arg0:setAlpha(1)
						if f54_arg1.interrupted then
							Widget.clipFinished(f54_arg0, f54_arg1)
						else
							f54_arg0:registerEventHandler("transition_complete_keyframe", Widget.clipFinished)
						end
					end

					if f47_arg1.interrupted then
						f47_local0(f47_arg0, f47_arg1)
						return 
					else
						f47_arg0:beginAnimation("keyframe", 70, false, false, CoD.TweenType.Linear)
						f47_arg0:setLeftRight(false, false, -25.91, -8.75)
						f47_arg0:setTopBottom(false, false, 4.48, 22.64)
						f47_arg0:registerEventHandler("transition_complete_keyframe", f47_local0)
					end
				end

				f7_local2(ZMReviveBleedoutRedEyeGlow, {})
				ZMReviveBleedoutRedEyeGlow0:completeAnimation()
				Widget.ZMReviveBleedoutRedEyeGlow0:setLeftRight(false, false, 6.09, 23.25)
				Widget.ZMReviveBleedoutRedEyeGlow0:setTopBottom(false, false, 3.48, 21.64)
				Widget.ZMReviveBleedoutRedEyeGlow0:setAlpha(1)
				local f7_local3 = function (f48_arg0, f48_arg1)
					local f48_local0 = function (f55_arg0, f55_arg1)
						if not f55_arg1.interrupted then
							f55_arg0:beginAnimation("keyframe", 430, false, false, CoD.TweenType.Linear)
						end
						f55_arg0:setLeftRight(false, false, 6.09, 23.25)
						f55_arg0:setTopBottom(false, false, 3.48, 21.64)
						f55_arg0:setAlpha(1)
						if f55_arg1.interrupted then
							Widget.clipFinished(f55_arg0, f55_arg1)
						else
							f55_arg0:registerEventHandler("transition_complete_keyframe", Widget.clipFinished)
						end
					end

					if f48_arg1.interrupted then
						f48_local0(f48_arg0, f48_arg1)
						return 
					else
						f48_arg0:beginAnimation("keyframe", 70, false, false, CoD.TweenType.Linear)
						f48_arg0:setLeftRight(false, false, 8.09, 25.25)
						f48_arg0:setTopBottom(false, false, 4.48, 22.64)
						f48_arg0:registerEventHandler("transition_complete_keyframe", f48_local0)
					end
				end

				f7_local3(ZMReviveBleedoutRedEyeGlow0, {})
				Glow0:completeAnimation()
				Widget.Glow0:setRGB(1, 0, 0)
				Widget.Glow0:setAlpha(0.1)
				local f7_local4 = function (f49_arg0, f49_arg1)
					local f49_local0 = function (f56_arg0, f56_arg1)
						if not f56_arg1.interrupted then
							f56_arg0:beginAnimation("keyframe", 430, false, false, CoD.TweenType.Linear)
						end
						f56_arg0:setRGB(1, 0, 0)
						f56_arg0:setAlpha(0.1)
						if f56_arg1.interrupted then
							Widget.clipFinished(f56_arg0, f56_arg1)
						else
							f56_arg0:registerEventHandler("transition_complete_keyframe", Widget.clipFinished)
						end
					end

					if f49_arg1.interrupted then
						f49_local0(f49_arg0, f49_arg1)
						return 
					else
						f49_arg0:beginAnimation("keyframe", 70, false, false, CoD.TweenType.Linear)
						f49_arg0:setAlpha(0.2)
						f49_arg0:registerEventHandler("transition_complete_keyframe", f49_local0)
					end
				end

				f7_local4(Glow0, {})
				Widget.nextClip = "DefaultClip"
			end
		},
		BleedingOut = 
		{
			DefaultClip = function ()
				Widget:setupElementClipCounter(11)
				GlowOrangeOver:completeAnimation()
				Widget.GlowOrangeOver:setAlpha(0.4)
				local f9_local0 = function (f68_arg0, f68_arg1)
					local f68_local0 = function (f71_arg0, f71_arg1)
						if not f71_arg1.interrupted then
							f71_arg0:beginAnimation("keyframe", 899, false, false, CoD.TweenType.Linear)
						end
						f71_arg0:setAlpha(0.4)
						if f71_arg1.interrupted then
							Widget.clipFinished(f71_arg0, f71_arg1)
						else
							f71_arg0:registerEventHandler("transition_complete_keyframe", Widget.clipFinished)
						end
					end

					if f68_arg1.interrupted then
						f68_local0(f68_arg0, f68_arg1)
						return 
					else
						f68_arg0:beginAnimation("keyframe", 100, false, false, CoD.TweenType.Linear)
						f68_arg0:setAlpha(0.6)
						f68_arg0:registerEventHandler("transition_complete_keyframe", f68_local0)
					end
				end

				f9_local0(GlowOrangeOver, {})
				glow:completeAnimation()
				Widget.glow:setAlpha(1)
				Widget.clipFinished(glow, {})
				RingGlow:completeAnimation()
				Widget.RingGlow:setAlpha(0)
				Widget.clipFinished(RingGlow, {})
				RingMiddle:completeAnimation()
				Widget.RingMiddle:setAlpha(0.1)
				Widget.clipFinished(RingMiddle, {})
				RingTopBleedOut:completeAnimation()
				Widget.RingTopBleedOut:setAlpha(1)
				Widget.clipFinished(RingTopBleedOut, {})
				RingTopRevive:completeAnimation()
				Widget.RingTopRevive:setAlpha(0)
				Widget.clipFinished(RingTopRevive, {})
				Skull:completeAnimation()
				Widget.skull:setLeftRight(false, false, -70, 70)
				Widget.skull:setTopBottom(false, false, -70, 70)
				Widget.skull:setAlpha(1)
				Widget.skull:setScale(1)
				local f9_local1 = function (f69_arg0, f69_arg1)
					local f69_local0 = function (f72_arg0, f72_arg1)
						if not f72_arg1.interrupted then
							f72_arg0:beginAnimation("keyframe", 899, false, false, CoD.TweenType.Linear)
						end
						f72_arg0:setLeftRight(false, false, -70, 70)
						f72_arg0:setTopBottom(false, false, -70, 70)
						f72_arg0:setAlpha(1)
						f72_arg0:setScale(1)
						if f72_arg1.interrupted then
							Widget.clipFinished(f72_arg0, f72_arg1)
						else
							f72_arg0:registerEventHandler("transition_complete_keyframe", Widget.clipFinished)
						end
					end

					if f69_arg1.interrupted then
						f69_local0(f69_arg0, f69_arg1)
						return 
					else
						f69_arg0:beginAnimation("keyframe", 100, false, false, CoD.TweenType.Linear)
						f69_arg0:setScale(1.1)
						f69_arg0:registerEventHandler("transition_complete_keyframe", f69_local0)
					end
				end

				f9_local1(Skull, {})
				AbilitySwirl:completeAnimation()
				Widget.AbilitySwirl:setLeftRight(false, false, -67.86, 69)
				Widget.AbilitySwirl:setTopBottom(false, false, -69, 67.86)
				Widget.AbilitySwirl:setAlpha(0)
				Widget.clipFinished(AbilitySwirl, {})
				ZMReviveBleedoutRedEyeGlow:completeAnimation()
				Widget.ZMReviveBleedoutRedEyeGlow:setLeftRight(false, false, -23.91, -6.75)
				Widget.ZMReviveBleedoutRedEyeGlow:setTopBottom(false, false, 3.48, 21.64)
				Widget.ZMReviveBleedoutRedEyeGlow:setAlpha(0)
				Widget.clipFinished(ZMReviveBleedoutRedEyeGlow, {})
				ZMReviveBleedoutRedEyeGlow0:completeAnimation()
				Widget.ZMReviveBleedoutRedEyeGlow0:setLeftRight(false, false, 6.09, 23.25)
				Widget.ZMReviveBleedoutRedEyeGlow0:setTopBottom(false, false, 3.48, 21.64)
				Widget.ZMReviveBleedoutRedEyeGlow0:setAlpha(0)
				Widget.clipFinished(ZMReviveBleedoutRedEyeGlow0, {})
				Glow0:completeAnimation()
				Widget.Glow0:setAlpha(0)
				local f9_local2 = function (f70_arg0, f70_arg1)
					local f70_local0 = function (f73_arg0, f73_arg1)
						if not f73_arg1.interrupted then
							f73_arg0:beginAnimation("keyframe", 899, false, false, CoD.TweenType.Linear)
						end
						f73_arg0:setAlpha(0)
						if f73_arg1.interrupted then
							Widget.clipFinished(f73_arg0, f73_arg1)
						else
							f73_arg0:registerEventHandler("transition_complete_keyframe", Widget.clipFinished)
						end
					end

					if f70_arg1.interrupted then
						f70_local0(f70_arg0, f70_arg1)
						return 
					else
						f70_arg0:beginAnimation("keyframe", 100, false, false, CoD.TweenType.Linear)
						f70_arg0:setAlpha(0.3)
						f70_arg0:registerEventHandler("transition_complete_keyframe", f70_local0)
					end
				end

				f9_local2(Glow0, {})
				Widget.nextClip = "DefaultClip"
			end
		}
	}
	
	LUI.OverrideFunction_CallOriginalSecond(Widget, "close", function (Sender)
		Sender.ZMReviveBleedoutRedEyeGlow:close()
		Sender.ZMReviveBleedoutRedEyeGlow0:close()
		Sender.Glow0:close()
		Sender.RingTopBleedOut:close()
		Sender.RingTopRevive:close()
	end)
	
	if PostLoadFunc then
		PostLoadFunc(Widget, InstanceRef, HudRef)
	end
	
	return Widget
end

