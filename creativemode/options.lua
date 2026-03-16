--[[
Container for a Checkbox --------------------------------------------------------------------------

<HorizontalList><Text width=500 text=""/><Button id= on_click={} width=32 height=32/></HorizontalList>

Container for a Value ---------------------------------------------------------------------------

<HorizontalList><Text width=468 text=""/><InputText id= on_commit={} default=1 min=1 max=65535width=64 height=32 /></HorizontalList>

Container for a Value and Reset ---------------------------------------------------------------------------

<HorizontalList><Text width=400 text=""/><Button text="Default" on_click={} width=65 /><Text width=3 /><InputText id= on_commit={} default=1 min=1 max=255 width=64 height=32 /></HorizontalList>

 ]]



local profile = Game.GetProfile()
return UI.New([[
	<VerticalList child_padding=8>
		<Text text="Creative Mod" size=20 color=title textalign=center/>
		<HorizontalList height = 2><Image color="#FFFFFF" fill=true/></HorizontalList>
		<Text text="Cheats" size=15 color=title textalign=center/>
		<HorizontalList height = 2></HorizontalList>
		<VerticalList child_align=right>
			<HorizontalList><Text width=500 text="Research Unlocked"/><Button id=CM_Research on_click={on_CM_Research} width=32 height=32/></HorizontalList>
			<HorizontalList><Text width=500 text="Buildings for free"/><Button id=CM_BuildingCost on_click={on_CM_BuildingCost} width=32 height=32/></HorizontalList>
			<HorizontalList><Text width=500 text="Start with extra Miner-Scouts"/><Button id=CM_ExtraScouts on_click={on_CM_ExtraScouts} width=32 height=32/></HorizontalList>
			<HorizontalList><Text width=500 text="Equip starting Scouts with a Power Cell"/><Button id=CM_ScoutCell on_click={on_CM_ScoutCell} width=32 height=32/></HorizontalList>
			<HorizontalList><Text width=500 text="Components for free"/><Button id=CM_ComponentCost on_click={on_CM_ComponentCost} width=32 height=32/></HorizontalList>
			<HorizontalList><Text width=500 text="Bots for free"/><Button id=CM_BotCost on_click={on_CM_BotCost} width=32 height=32/></HorizontalList>
			<HorizontalList><Text width=500 text="Items for free"/><Button id=CM_ItemCost on_click={on_CM_ItemCost} width=32 height=32/></HorizontalList>
			<HorizontalList><Text width=500 text="Production Speed Boost"/><Button id=CM_ProductionSpeed on_click={on_CM_ProductionSpeed} width=32 height=32/></HorizontalList>
			<HorizontalList><Text width=500 text="Auto-fill Components on Build"/><Button id=CM_AutoFillComponents on_click={on_CM_AutoFillComponents} width=32 height=32/></HorizontalList>
		</VerticalList>

		<Text text="Custom Values" size=15 color=title textalign=center/>
		<VerticalList child_align=right>
			<HorizontalList><Text width=400 text="Amount of starting Scouts"/><Button text="Default" on_click={reset_CM_ExtraScoutsAmount} width=65 /><Text width=3 /><InputText id=CM_ExtraScoutsAmount on_commit={on_CM_ExtraScoutsAmount} default=1 min=1 max=65535 width=64 height=32 /></HorizontalList>
			<HorizontalList><Text width=400 text="Power generated from Power Cells"/><Button text="Default" on_click={reset_CM_PowerCellPower} width=65 /><Text width=3 /><InputText id=CM_PowerCellPower on_commit={on_CM_PowerCellPower} default=1 min=1 max=65535 width=64 height=32 /></HorizontalList>
			<HorizontalList><Text width=400 text="Power Radius of Power Cells(max 255)"/><Button text="Default" on_click={reset_CM_PowerCellRadius} width=65 /><Text width=3 /><InputText id=CM_PowerCellRadius on_commit={on_CM_PowerCellRadius} default=1 min=1 max=255 width=64 height=32 /></HorizontalList>
			<HorizontalList><Text width=400 text="View Radius of Scouts(max 255)"/><Button text="Default" on_click={reset_CM_ScoutViewRadius} width=65 /><Text width=3 /><InputText id=CM_ScoutViewRadius on_commit={on_CM_ScoutViewRadius} default=1 min=1 max=255 width=64 height=32 /></HorizontalList>
			<HorizontalList><Text width=400 text="Production Speed Multiplier"/><Button text="Default" on_click={reset_CM_SpeedMultiplier} width=65 /><Text width=3 /><InputText id=CM_SpeedMultiplier on_commit={on_CM_SpeedMultiplier} default=1.0 min=0.1 max=100 width=64 height=32 /></HorizontalList>
		</VerticalList>

		<HorizontalList height = 8></HorizontalList>
		<HorizontalList child_align=center>
			<Button id=CM_ApplyBtn text="Apply Settings" on_click={on_CM_Apply} width=200 height=40 />
		</HorizontalList>
		<Text id=CM_ApplyNote text="" size=12 color=highlight textalign=center/>
	</VerticalList>
	]], {
	construct = function(menu)

		-- Default values
		if profile.CM_ExtraScoutsAmount == nil then profile.CM_ExtraScoutsAmount = 10 end
		if profile.CM_PowerCellPower == nil then profile.CM_PowerCellPower = 500 end
		if profile.CM_PowerCellRadius == nil then profile.CM_PowerCellRadius = 10 end
		if profile.CM_ScoutViewRadius == nil then profile.CM_ScoutViewRadius = 10 end
		if profile.CM_SpeedMultiplier == nil then profile.CM_SpeedMultiplier = 1.0 end

		if profile.CM_Research == nil then profile.CM_Research = true end
		if profile.CM_BuildingCost == nil then profile.CM_BuildingCost = true end
		if profile.CM_ExtraScouts == nil then profile.CM_ExtraScouts = true end
		if profile.CM_ScoutCell == nil then profile.CM_ScoutCell = true end
		if profile.CM_ComponentCost == nil then profile.CM_ComponentCost = true end
		if profile.CM_BotCost == nil then profile.CM_BotCost = true end
		if profile.CM_ItemCost == nil then profile.CM_ItemCost = false end
		if profile.CM_ProductionSpeed == nil then profile.CM_ProductionSpeed = true end
		if profile.CM_AutoFillComponents == nil then profile.CM_AutoFillComponents = true end

		-- Research
		local cm_Research = profile.CM_Research
		menu.CM_Research.icon = cm_Research and "icon_small_confirm" or nil
		menu.CM_Research.active = cm_Research or false

		-- BuildingCost
		local cm_BuildingCost = profile.CM_BuildingCost
		menu.CM_BuildingCost.icon = cm_BuildingCost and "icon_small_confirm" or nil
		menu.CM_BuildingCost.active = cm_BuildingCost or false

		-- ExtraScouts
		local cm_ExtraScouts = profile.CM_ExtraScouts
		menu.CM_ExtraScouts.icon = cm_ExtraScouts and "icon_small_confirm" or nil
		menu.CM_ExtraScouts.active = cm_ExtraScouts or false

		-- ScoutCell
		local cm_ScoutCell = profile.CM_ScoutCell
		menu.CM_ScoutCell.icon = cm_ScoutCell and "icon_small_confirm" or nil
		menu.CM_ScoutCell.active = cm_ScoutCell or false

		-- ComponentCost
		local cm_ComponentCost = profile.CM_ComponentCost
		menu.CM_ComponentCost.icon = cm_ComponentCost and "icon_small_confirm" or nil
		menu.CM_ComponentCost.active = cm_ComponentCost or false

		-- BotCost
		local cm_BotCost = profile.CM_BotCost
		menu.CM_BotCost.icon = cm_BotCost and "icon_small_confirm" or nil
		menu.CM_BotCost.active = cm_BotCost or false

		-- ItemCost
		local cm_ItemCost = profile.CM_ItemCost
		menu.CM_ItemCost.icon = cm_ItemCost and "icon_small_confirm" or nil
		menu.CM_ItemCost.active = cm_ItemCost or false

		-- ProductionSpeed
		local cm_ProductionSpeed = profile.CM_ProductionSpeed
		menu.CM_ProductionSpeed.icon = cm_ProductionSpeed and "icon_small_confirm" or nil
		menu.CM_ProductionSpeed.active = cm_ProductionSpeed or false

		-- AutoFillComponents
		local cm_AutoFillComponents = profile.CM_AutoFillComponents
		menu.CM_AutoFillComponents.icon = cm_AutoFillComponents and "icon_small_confirm" or nil
		menu.CM_AutoFillComponents.active = cm_AutoFillComponents or false

		-- InputText values
		menu.CM_ExtraScoutsAmount.text = profile.CM_ExtraScoutsAmount
		menu.CM_PowerCellPower.text = profile.CM_PowerCellPower
		menu.CM_PowerCellRadius.text = profile.CM_PowerCellRadius
		menu.CM_ScoutViewRadius.text = profile.CM_ScoutViewRadius
		menu.CM_SpeedMultiplier.text = profile.CM_SpeedMultiplier
	end,

	on_CM_Research = function(menu, chk)
		local value = not chk.active
		chk.icon = value and "icon_small_confirm" or nil
		chk.active = value
		profile.CM_Research = value
	end,
	on_CM_BuildingCost = function(menu, chk)
		local value = not chk.active
		chk.icon = value and "icon_small_confirm" or nil
		chk.active = value
		profile.CM_BuildingCost = value
	end,
	on_CM_ExtraScouts = function(menu, chk)
		local value = not chk.active
		chk.icon = value and "icon_small_confirm" or nil
		chk.active = value
		profile.CM_ExtraScouts = value
	end,
	on_CM_ScoutCell = function(menu, chk)
		local value = not chk.active
		chk.icon = value and "icon_small_confirm" or nil
		chk.active = value
		profile.CM_ScoutCell = value
	end,
	on_CM_ComponentCost = function(menu, chk)
		local value = not chk.active
		chk.icon = value and "icon_small_confirm" or nil
		chk.active = value
		profile.CM_ComponentCost = value
	end,
	on_CM_BotCost = function(menu, chk)
		local value = not chk.active
		chk.icon = value and "icon_small_confirm" or nil
		chk.active = value
		profile.CM_BotCost = value
	end,
	on_CM_ItemCost = function(menu, chk)
		local value = not chk.active
		chk.icon = value and "icon_small_confirm" or nil
		chk.active = value
		profile.CM_ItemCost = value
	end,
	on_CM_ProductionSpeed = function(menu, chk)
		local value = not chk.active
		chk.icon = value and "icon_small_confirm" or nil
		chk.active = value
		profile.CM_ProductionSpeed = value
	end,
	on_CM_AutoFillComponents = function(menu, chk)
		local value = not chk.active
		chk.icon = value and "icon_small_confirm" or nil
		chk.active = value
		profile.CM_AutoFillComponents = value
	end,

	-- Values --------------------------------------
	on_CM_ExtraScoutsAmount = function(menu, chk)
		local value = chk.text
		if tonumber(value) == nil then MessageBox("Input is not a number") return end
		profile.CM_ExtraScoutsAmount = tonumber(value)
	end,
	reset_CM_ExtraScoutsAmount = function(menu, chk)
		profile.CM_ExtraScoutsAmount = 3
		menu.CM_ExtraScoutsAmount.text = tostring(3)
	end,
	on_CM_PowerCellPower = function(menu, chk)
		local value = chk.text
		if tonumber(value) == nil then MessageBox("Input is not a number") return end
		profile.CM_PowerCellPower = tonumber(value)
	end,
	reset_CM_PowerCellPower = function(menu, chk)
		profile.CM_PowerCellPower = 500
		menu.CM_PowerCellPower.text = tostring(500)
	end,
	on_CM_PowerCellRadius = function(menu, chk)
		local value = chk.text
		if tonumber(value) == nil then MessageBox("Input is not a number") return end
		profile.CM_PowerCellRadius = tonumber(value)
	end,
	reset_CM_PowerCellRadius = function(menu, chk)
		profile.CM_PowerCellRadius = 10
		menu.CM_PowerCellRadius.text = tostring(10)
	end,
	on_CM_ScoutViewRadius = function(menu, chk)
		local value = chk.text
		if tonumber(value) == nil then MessageBox("Input is not a number") return end
		profile.CM_ScoutViewRadius = tonumber(value)
	end,
	reset_CM_ScoutViewRadius = function(menu, chk)
		profile.CM_ScoutViewRadius = 10
		menu.CM_ScoutViewRadius.text = tostring(10)
	end,
	on_CM_SpeedMultiplier = function(menu, chk)
		local value = chk.text
		if tonumber(value) == nil then MessageBox("Input is not a number") return end
		local num = tonumber(value)
		if num < 0.1 then num = 0.1 end
		if num > 100 then num = 100 end
		profile.CM_SpeedMultiplier = num
		menu.CM_SpeedMultiplier.text = tostring(num)
	end,
	reset_CM_SpeedMultiplier = function(menu, chk)
		profile.CM_SpeedMultiplier = 1.0
		menu.CM_SpeedMultiplier.text = tostring(1.0)
	end,

	-- Apply button --------------------------------
	on_CM_Apply = function(menu, chk)
		-- Call the global apply function defined in creativemode.lua
		if CM_ApplySettings then
			CM_ApplySettings()
			menu.CM_ApplyNote.text = "Settings applied! (Some changes may need a world restart)"
		else
			menu.CM_ApplyNote.text = "Apply failed - please restart the world"
		end
	end,
})
