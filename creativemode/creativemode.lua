local package = ...
local profile = Game.GetProfile()

function package:setup_scenario(settings)
end

function package:on_world_spawn()
end

function package:init()
	-- Silence tutorial popups (safe)
	pcall(function()
		if data.fx then
			if data.fx.fx_ui_WINDOW_TUT_NEXT then
				data.fx.fx_ui_WINDOW_TUT_NEXT.sound = "creativemode/silence.ogg"
			end
			if data.fx.fx_ui_WINDOW_TUT_POPOUT then
				data.fx.fx_ui_WINDOW_TUT_POPOUT.sound = "creativemode/silence.ogg"
			end
		end
	end)

	-- Free items (clear ingredients, set production time to 1)
	if profile.CM_ItemCost then
		pcall(function()
			for k, item in pairs(data.items) do
				if item and type(item) == "table" and item.production_recipe and type(item.production_recipe) == "table" then
					if item.production_recipe.ingredients then
						item.production_recipe.ingredients = {}
					end
					if item.production_recipe.producers then
						for p, _ in pairs(item.production_recipe.producers) do
							item.production_recipe.producers[p] = 1
						end
					end
				end
			end
		end)
	end

	-- Free components
	if profile.CM_ComponentCost then
		pcall(function()
			for k, component in pairs(data.components) do
				if component and type(component) == "table" and component.production_recipe and type(component.production_recipe) == "table" then
					if component.production_recipe.ingredients then
						component.production_recipe.ingredients = {}
					end
					if component.production_recipe.producers then
						for p, _ in pairs(component.production_recipe.producers) do
							component.production_recipe.producers[p] = 1
						end
					end
				end
			end
		end)
	end

	-- Free buildings and/or free bots
	if profile.CM_BuildingCost or profile.CM_BotCost then
		pcall(function()
			for k, frame in pairs(data.frames) do
				if frame and type(frame) == "table" then
					if profile.CM_BuildingCost and frame.construction_recipe and type(frame.construction_recipe) == "table" then
						if frame.construction_recipe.ingredients then
							frame.construction_recipe.ingredients = {}
						end
						if frame.construction_recipe.ticks ~= nil then
							frame.construction_recipe.ticks = 1
						end
					end
					if profile.CM_BotCost and frame.production_recipe and type(frame.production_recipe) == "table" then
						if frame.production_recipe.ingredients then
							frame.production_recipe.ingredients = {}
						end
						if frame.production_recipe.producers then
							for p, _ in pairs(frame.production_recipe.producers) do
								frame.production_recipe.producers[p] = 1
							end
						end
					end
				end
			end
		end)
	end

	-- Custom values (all wrapped in pcall for safety)
	pcall(function()
		local power_val = tonumber(profile.CM_PowerCellPower)
		if power_val and data.components and data.components.c_power_cell then
			data.components.c_power_cell.power = math.floor(power_val / 5)
		end
	end)

	pcall(function()
		local radius_val = tonumber(profile.CM_PowerCellRadius)
		if radius_val and data.components and data.components.c_power_cell then
			data.components.c_power_cell.transfer_radius = radius_val
		end
	end)

	pcall(function()
		local view_val = tonumber(profile.CM_ScoutViewRadius)
		if view_val and data.frames then
			-- Try multiple possible scout frame IDs
			local scout = data.frames["f_bot_1s_a"] or data.frames["f_bot_1s_as"]
			if scout then
				scout.visibility_range = view_val
			end
		end
	end)
end

function package:on_player_faction_spawn(faction, is_respawn, player_faction_num)
	-- Initialize extra_data safely
	if not faction.extra_data then
		faction.extra_data = {}
	end
	pcall(function()
		faction.extra_data.started = Map.GetTick()
	end)

	-- Select starting location
	faction.home_location = GetPlayerFactionHomeOnGround()
	local loc = faction.home_location

	-- Determine frame IDs at runtime
	local lander_frame = nil
	if data.frames then
		-- Try multiple possible lander frame IDs
		if data.frames["f_bot_2m_as"] then
			lander_frame = "f_bot_2m_as"
		elseif data.frames["f_bot_2m_a"] then
			lander_frame = "f_bot_2m_a"
		elseif data.frames["f_bot_2m"] then
			lander_frame = "f_bot_2m"
		end
	end

	-- Spawn lander bot
	if lander_frame then
		local ok, err = pcall(function()
			local lander = Map.CreateEntity(faction, lander_frame)
			pcall(function() lander:AddComponent("c_deployment", "hidden") end)
			pcall(function() lander:AddComponent("c_power_cell") end)
			pcall(function() lander:AddComponent("c_assembler", 1) end)
			pcall(function() lander:AddComponent("c_fabricator", 2) end)
			pcall(function() lander:AddItem("metalbar", 20) end)
			pcall(function() lander:AddItem("metalplate", 20) end)
			pcall(function() lander:AddItem("reinforced_plate", 20) end)
			pcall(function() lander:AddItem("energized_plate", 20) end)
			pcall(function() lander:AddItem("circuit_board", 20) end)
			pcall(function() lander:AddItem("wire", 20) end)
			lander:Place(loc.x, loc.y)
			lander.disconnected = false
			faction.home_entity = lander
		end)
	else
		-- Fallback: create a simple starter bot if lander frame doesn't exist
		pcall(function()
			local bot = Map.CreateEntity(faction, "f_bot_1s_a")
			pcall(function() bot:AddComponent("c_power_cell") end)
			pcall(function() bot:AddComponent("c_assembler", 1) end)
			bot:Place(loc.x, loc.y)
			bot.disconnected = false
			faction.home_entity = bot
		end)
	end

	-- Determine scout frame ID
	local scout_frame = "f_bot_1s_a"
	if data.frames and data.frames["f_bot_1s_as"] then
		scout_frame = "f_bot_1s_as"
	end

	-- Spawn scouts
	local num_scouts = 3
	if profile.CM_ExtraScouts then
		num_scouts = tonumber(profile.CM_ExtraScoutsAmount) or 10
	end

	for i = 1, num_scouts do
		pcall(function()
			local bot = Map.CreateEntity(faction, scout_frame)
			pcall(function() bot:AddComponent("c_adv_miner", 1) end)
			if profile.CM_ScoutCell then
				pcall(function() bot:AddComponent("c_power_cell") end)
			end
			bot:Place(loc.x, loc.y)
			bot.disconnected = false
		end)
	end

	-- Research unlocked
	if profile.CM_Research then
		pcall(function()
			for k, tech in pairs(data.techs) do
				pcall(function() faction:Unlock(k) end)
			end
		end)
	else
		pcall(function() faction:Unlock("t_robot_tech_basic") end)
	end
end
