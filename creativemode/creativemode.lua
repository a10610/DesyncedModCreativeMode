local package = ...
local profile = Game.GetProfile()

-- Ensure all profile defaults exist (before any if-checks)
local function ensure_defaults()
	if profile.CM_Research == nil then profile.CM_Research = true end
	if profile.CM_BuildingCost == nil then profile.CM_BuildingCost = true end
	if profile.CM_ExtraScouts == nil then profile.CM_ExtraScouts = true end
	if profile.CM_ScoutCell == nil then profile.CM_ScoutCell = true end
	if profile.CM_ComponentCost == nil then profile.CM_ComponentCost = true end
	if profile.CM_BotCost == nil then profile.CM_BotCost = true end
	if profile.CM_ItemCost == nil then profile.CM_ItemCost = false end
	if profile.CM_ProductionSpeed == nil then profile.CM_ProductionSpeed = true end
	if profile.CM_AutoFillComponents == nil then profile.CM_AutoFillComponents = true end
	if profile.CM_ExtraScoutsAmount == nil then profile.CM_ExtraScoutsAmount = 10 end
	if profile.CM_PowerCellPower == nil then profile.CM_PowerCellPower = 500 end
	if profile.CM_PowerCellRadius == nil then profile.CM_PowerCellRadius = 10 end
	if profile.CM_ScoutViewRadius == nil then profile.CM_ScoutViewRadius = 10 end
	if profile.CM_SpeedMultiplier == nil then profile.CM_SpeedMultiplier = 1.0 end
end

-- Apply data table modifications (items, components, frames)
-- This is called from init() and also from the Apply button
local function apply_data_modifications()
	ensure_defaults()

	-- Free items (clear ingredients)
	if profile.CM_ItemCost then
		pcall(function()
			for k, item in pairs(data.items) do
				if item and type(item) == "table" and item.production_recipe and type(item.production_recipe) == "table" then
					if item.production_recipe.ingredients then
						item.production_recipe.ingredients = {}
					end
				end
			end
		end)
	end

	-- Production speed for items
	if profile.CM_ProductionSpeed then
		pcall(function()
			local speed = tonumber(profile.CM_SpeedMultiplier) or 1.0
			if speed < 0.01 then speed = 0.01 end
			for k, item in pairs(data.items) do
				if item and type(item) == "table" and item.production_recipe and type(item.production_recipe) == "table" then
					if item.production_recipe.producers then
						for p, ticks in pairs(item.production_recipe.producers) do
							if type(ticks) == "number" and ticks > 0 then
								local new_ticks = math.max(1, math.floor(ticks / speed))
								item.production_recipe.producers[p] = new_ticks
							else
								item.production_recipe.producers[p] = 1
							end
						end
					end
				end
			end
		end)
	end

	-- Free components (clear ingredients)
	if profile.CM_ComponentCost then
		pcall(function()
			for k, component in pairs(data.components) do
				if component and type(component) == "table" and component.production_recipe and type(component.production_recipe) == "table" then
					if component.production_recipe.ingredients then
						component.production_recipe.ingredients = {}
					end
				end
			end
		end)
	end

	-- Production speed for components
	if profile.CM_ProductionSpeed then
		pcall(function()
			local speed = tonumber(profile.CM_SpeedMultiplier) or 1.0
			if speed < 0.01 then speed = 0.01 end
			for k, component in pairs(data.components) do
				if component and type(component) == "table" and component.production_recipe and type(component.production_recipe) == "table" then
					if component.production_recipe.producers then
						for p, ticks in pairs(component.production_recipe.producers) do
							if type(ticks) == "number" and ticks > 0 then
								local new_ticks = math.max(1, math.floor(ticks / speed))
								component.production_recipe.producers[p] = new_ticks
							else
								component.production_recipe.producers[p] = 1
							end
						end
					end
				end
			end
		end)
	end

	-- Free buildings and/or free bots
	if profile.CM_BuildingCost or profile.CM_BotCost or profile.CM_ProductionSpeed then
		pcall(function()
			local speed = tonumber(profile.CM_SpeedMultiplier) or 1.0
			if speed < 0.01 then speed = 0.01 end
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
					end
					-- Production speed for bots/frames
					if profile.CM_ProductionSpeed and frame.production_recipe and type(frame.production_recipe) == "table" then
						if frame.production_recipe.producers then
							for p, ticks in pairs(frame.production_recipe.producers) do
								if type(ticks) == "number" and ticks > 0 then
									local new_ticks = math.max(1, math.floor(ticks / speed))
									frame.production_recipe.producers[p] = new_ticks
								else
									frame.production_recipe.producers[p] = 1
								end
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

-- Apply research unlock to a faction
local function apply_research(faction)
	if not faction then return end
	if profile.CM_Research then
		pcall(function()
			for k, tech in pairs(data.techs) do
				pcall(function() faction:Unlock(k) end)
			end
		end)
	end
end

-----------------------------------------------------------------------
-- Auto-fill components monitor
-- Scans player entities every 10 ticks (~2 seconds).
-- For non-construction entities with empty sockets, instantly equip
-- components so you don't have to wait for bots to deliver them.
-----------------------------------------------------------------------
local cm_processed_entities = {}   -- track entity keys already processed
local cm_construction_watch = {}   -- track entities that were construction sites

local function auto_fill_components_for_entity(entity)
	if not entity or not entity.exists then return end
	if entity.is_construction then return end -- still building

	local socket_count = entity.socket_count or 0
	if socket_count <= 0 then return end

	-- Strategy 1: Check item slots for packed component items
	-- When pasting, the game may have packed component items in inventory
	pcall(function()
		local slots = entity.slots
		if slots then
			for _, slot in ipairs(slots) do
				if slot and slot.exists then
					local item_id = slot.id
					-- If slot contains a packed component (component items start with "c_")
					if item_id and type(item_id) == "string" and string.sub(item_id, 1, 2) == "c_" then
						pcall(function()
							local free_socket = entity:GetFreeSocket(item_id)
							if free_socket then
								entity:AddComponent(item_id, free_socket)
								pcall(function() slot:Clear() end)
							end
						end)
					end
				end
			end
		end
	end)

	-- Strategy 2: Check frame definition for default components
	-- Fill empty sockets based on what the frame type normally has
	pcall(function()
		local frame_def = entity.def
		if frame_def and frame_def.components then
			for socket_idx = 1, socket_count do
				local existing = entity:GetComponent(socket_idx)
				if not existing then
					local default_comp = frame_def.components[socket_idx]
					if default_comp then
						local comp_id = default_comp
						if type(default_comp) == "table" then
							comp_id = default_comp.id or default_comp[1]
						end
						if comp_id and type(comp_id) == "string" then
							pcall(function()
								entity:AddComponent(comp_id, socket_idx)
							end)
						end
					end
				end
			end
		end
	end)
end

-- Delay handler for the auto-fill tick loop
-- (Map.Delay uses Delay.FUNCNAME, not MapMsg.FUNCNAME)
if not Delay then Delay = {} end
function Delay.CM_AutoFillTick()
	-- Reschedule for next check (every 10 ticks = ~2 seconds)
	pcall(function()
		Map.Delay("CM_AutoFillTick", 10)
	end)

	if not profile.CM_AutoFillComponents then return end

	pcall(function()
		local factions = Map.GetPlayerFactions()
		if not factions then return end

		for _, faction in ipairs(factions) do
			pcall(function()
				local entities = faction.entities
				if not entities then return end

				for _, entity in ipairs(entities) do
					if entity and entity.exists then
						local ekey = entity.key

						if entity.is_construction then
							-- Track construction sites
							cm_construction_watch[ekey] = true
						else
							-- Process if just finished construction or new entity
							if cm_construction_watch[ekey] or not cm_processed_entities[ekey] then
								auto_fill_components_for_entity(entity)
								cm_processed_entities[ekey] = true
								cm_construction_watch[ekey] = nil
							end
						end
					end
				end
			end)
		end
	end)
end

-- Global function callable from options UI Apply button
function CM_ApplySettings()
	ensure_defaults()
	-- Re-apply data table modifications
	apply_data_modifications()
	-- Re-apply research to all player factions
	pcall(function()
		local factions = Map.GetPlayerFactions()
		if factions then
			for _, faction in ipairs(factions) do
				apply_research(faction)
			end
		end
	end)
	-- Re-trigger auto-fill for all entities (clear processed cache)
	cm_processed_entities = {}
	cm_construction_watch = {}
	print("[Creative Mode] Settings applied!")
end

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

	-- Apply all data modifications
	apply_data_modifications()
end

function package:post_init()
	-- Start the auto-fill component monitor
	ensure_defaults()
	if profile.CM_AutoFillComponents then
		pcall(function()
			Map.Delay("CM_AutoFillTick", 50) -- start after ~10 seconds
		end)
	end
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
	apply_research(faction)
	if not profile.CM_Research then
		pcall(function() faction:Unlock("t_robot_tech_basic") end)
	end

	-- Start auto-fill monitor if not already running
	if profile.CM_AutoFillComponents then
		pcall(function()
			Map.Delay("CM_AutoFillTick", 50)
		end)
	end
end
