local package = ...
local profile = Game.GetProfile()

-- Helper: resolve a frame ID with fallback
local function resolve_frame(primary, fallback)
	if data.frames[primary] then return primary end
	if fallback and data.frames[fallback] then return fallback end
	return primary
end

-- Frame IDs (v1.0 uses "f_bot_1s_a" / "f_bot_2m_a"; older builds used "f_bot_1s_as" / "f_bot_2m_as")
local SCOUT_FRAME = resolve_frame("f_bot_1s_a", "f_bot_1s_as")
local LANDER_FRAME = resolve_frame("f_bot_2m_a", "f_bot_2m_as")

function package:setup_scenario(settings)
end

function package:on_world_spawn()
end

function package:init()
	-- Silence tutorial popups
	local ok_fx, fx_err = pcall(function()
		if data.fx and data.fx.fx_ui_WINDOW_TUT_NEXT then
			data.fx.fx_ui_WINDOW_TUT_NEXT.sound = "creativemode/silence.ogg"
		end
		if data.fx and data.fx.fx_ui_WINDOW_TUT_POPOUT then
			data.fx.fx_ui_WINDOW_TUT_POPOUT.sound = "creativemode/silence.ogg"
		end
	end)

	-- Free items
	if profile.CM_ItemCost then
		local ok, err = pcall(function()
			for k, item in pairs(data.items) do
				if item and item.production_recipe then
					if item.production_recipe.ingredients then
						item.production_recipe.ingredients = {}
					end
					if type(item.production_recipe) == "table" and item.production_recipe.producers then
						for p, m in pairs(item.production_recipe.producers) do
							item.production_recipe.producers[p] = 1
						end
					end
				end
			end
		end)
	end

	-- Free components
	if profile.CM_ComponentCost then
		local ok, err = pcall(function()
			for k, component in pairs(data.components) do
				if component and component.production_recipe then
					if component.production_recipe.ingredients then
						component.production_recipe.ingredients = {}
					end
					if type(component.production_recipe) == "table" and component.production_recipe.producers then
						for p, m in pairs(component.production_recipe.producers) do
							component.production_recipe.producers[p] = 1
						end
					end
				end
			end
		end)
	end

	-- Free buildings and/or free bots
	if profile.CM_BuildingCost or profile.CM_BotCost then
		local ok, err = pcall(function()
			for k, frame in pairs(data.frames) do
				if frame then
					if profile.CM_BuildingCost and frame.construction_recipe then
						if frame.construction_recipe.ingredients then
							frame.construction_recipe.ingredients = {}
						end
						if frame.construction_recipe.ticks then
							frame.construction_recipe.ticks = 1
						end
					end
					if profile.CM_BotCost and frame.production_recipe then
						if frame.production_recipe.ingredients then
							frame.production_recipe.ingredients = {}
						end
						if type(frame.production_recipe) == "table" and frame.production_recipe.producers then
							for p, m in pairs(frame.production_recipe.producers) do
								frame.production_recipe.producers[p] = 1
							end
						end
					end
				end
			end
		end)
	end

	-- Custom values (power cell power, transfer radius, scout view radius)
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
		if view_val and data.frames and data.frames[SCOUT_FRAME] then
			data.frames[SCOUT_FRAME].visibility_range = view_val
		end
	end)
end

function package:on_player_faction_spawn(faction, is_respawn, player_faction_num)
	faction.extra_data.started = Map.GetTick()
	faction.home_location = GetPlayerFactionHomeOnGround()
	local loc = faction.home_location

	-- Lander bot
	local lander = Map.CreateEntity(faction, LANDER_FRAME)
	lander:AddComponent("c_deployment", "hidden")
	lander:AddComponent("c_power_cell")
	lander:AddComponent("c_assembler", 1)
	lander:AddComponent("c_fabricator", 2)
	lander:AddItem("metalbar", 20)
	lander:AddItem("metalplate", 20)
	lander:AddItem("reinforced_plate", 20)
	lander:AddItem("energized_plate", 20)
	lander:AddItem("circuit_board", 20)
	lander:AddItem("wire", 20)
	lander:Place(loc.x, loc.y)
	lander.disconnected = false
	faction.home_entity = lander

	-- Spawn scouts
	if profile.CM_ExtraScouts then
		local amount = tonumber(profile.CM_ExtraScoutsAmount) or 10
		spawn_bots(faction, amount, loc)
	else
		spawn_bots(faction, 3, loc)
	end

	-- Research unlocked
	if profile.CM_Research then
		pcall(function()
			for k, tech in pairs(data.techs) do
				faction:Unlock(k)
			end
		end)
	else
		faction:Unlock("t_robot_tech_basic")
	end
end

function spawn_bots(faction, num, loc)
	for i = 1, num do
		local bot = Map.CreateEntity(faction, SCOUT_FRAME)
		bot:AddComponent("c_adv_miner", 1)
		if profile.CM_ScoutCell then
			bot:AddComponent("c_power_cell")
		end
		bot:Place(loc.x, loc.y)
		bot.disconnected = false
	end
end
