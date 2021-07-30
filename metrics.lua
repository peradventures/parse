Skill_List = {
    'total',
    'total_no_sc',
    'melee',
    'melee primary',
    'melee secondary',
    'melee kicks',
    'ranged',
    'throwing',
    'ws',
    'sc',
    'ability',
    'magic',
    'enspell',
    'nuke',
    'healing',
    'pet',
    'death',
}

Metric_List = {
    'total',
    'count',
    'hits',
    'crits',
    'crit damage',
    'misses',
    'shadows',
    'mob heal',
    'min',
    'max',
}

-- Holds all of the damage data that the parser uses
Parse_Data = {} -- index is player:mob

-- Keeps track of which skills have been initialized
Skill_Data = {}	-- [skill][player_name]

-- Keeps track of which players have been initialized
Initialized_Players = {}

-- Keeps track of the running accuracy data
Running_Accuracy_Data = {}
Running_Accuracy_Limit = 50

-- Ranks players based on relative total damage done
Total_Damage_Race  = {}

-- Ranks weaponskills, skillchains, abilities, etc
Single_Damage_Race = {}

-- ******************************************************************************************************
-- *
-- *                                            Initialization
-- *
-- ******************************************************************************************************

--[[
    DESCRIPTION:    
    PARAMETERS :    
]] 
function Init_Data(index, player_name)
	if Parse_Data[index] then return end

	Parse_Data[index] = {}

	-- Initialize data nodes
	for _, skill in pairs(Skill_List) do
		Parse_Data[index][skill] = {}
		Parse_Data[index][skill]['single'] = {}
		
		for _, metric in pairs(Metric_List) do
			Set_Data(0, index, skill, metric)
		end
	end

	-- Initialize tracking tables
	if (player_name) and (not Initialized_Players[player_name]) then
		Initialized_Players[player_name] = true
		Running_Accuracy_Data[player_name] = {}
	end
end

--[[
    DESCRIPTION:    
    PARAMETERS :    
]] 
function Init_Data_Single(index, player_name, skill, action_name)
	Init_Data(index, player_name)

	-- Don't want to overwrite action_name node if it is already built out
	if (Parse_Data[index][skill]['single'][action_name]) then return end

	Parse_Data[index][skill]['single'][action_name] = {}

	-- Initialize single data nodes
	for _, metric in pairs(Metric_List) do
		Set_Data_Single(0, index, skill, action_name, metric)
	end

	-- Need to set minimum high manually to capture accurate minimums
	Set_Data_Single(100000, index, skill, action_name, 'min')

	-- Initialize tracking tables
	if (not Skill_Data[skill]) then Skill_Data[skill] = {} end
	if (not Skill_Data[skill][player_name]) then Skill_Data[skill][player_name] = {} end
end

-- ******************************************************************************************************
-- *
-- *                                                Sets
-- *
-- ******************************************************************************************************

--[[
    DESCRIPTION:    
    PARAMETERS :    
]] 
function Update_Data(mode, value, player_name, target_name, skill, metric)
	local index = build_index(player_name, target_name)
	Init_Data(index, player_name)

	-- Increment from existing value
	if mode == 'inc' then
		Inc_Data(value, index, skill, metric)
	
	-- Set value directly
	elseif mode == 'set' then
		Set_Data(value, index, skill, metric)
	
	else windower.add_to_chat(c_chat, 'Invalid mode: '..mode) end
end

--[[
    DESCRIPTION:    
    PARAMETERS :    
]] 
function Update_Data_Single(mode, value, player_name, target_name, skill, action_name, metric)
	local index = build_index(player_name, target_name)
	Init_Data_Single(index, player_name, skill, action_name)

	-- This holds all of the players who have data.
	if not Initialized_Players[player_name] then Initialized_Players[player_name] = true end

	-- Increment from existing value
	if mode == 'inc' then
		Inc_Data_Single(value, index, skill, action_name, metric)
	
	-- Set value directly
	elseif mode == 'set' then
		Set_Data_Single(value, index, skill, action_name, metric)
	
	else windower.add_to_chat(c_chat, 'Invalid mode: '..mode) end

	-- This is used for the focus window
	Skill_Data[skill][player_name][action_name] = true
end

--[[
    DESCRIPTION:    
    PARAMETERS :    
]] 
function Set_Data(value, index, skill, metric)
	Parse_Data[index][skill][metric] = value
end

function Set_Data_Single(value, index, skill, action_name, metric)
	Parse_Data[index][skill]['single'][action_name][metric] = value
end

function Inc_Data(value, index, skill, metric)
	Parse_Data[index][skill][metric] = Parse_Data[index][skill][metric] + value
end

function Inc_Data_Single(value, index, skill, action_name, metric)
	Parse_Data[index][skill]['single'][action_name][metric] = Parse_Data[index][skill]['single'][action_name][metric] + value
end

-- ******************************************************************************************************
-- *
-- *                                                Gets
-- *
-- ******************************************************************************************************

--[[
    DESCRIPTION:    
    PARAMETERS :    
]] 
function Get_Data(player_name, skill, metric)
	local total = 0

	for index, value in pairs(Parse_Data) do
		-- If there is no mob filter then get everything associated with this player.
		if not Mob_Filter then
			if string.find(index, player_name) then
				total = total + Parse_Data[index][skill][metric]
			end
		
		-- Otherwise get everything for this specific mob. Partial matches count.
		else
			if string.find(index, player_name..":"..Mob_Filter) then
				total = total + Parse_Data[index][skill][metric]
			end
		end
	end

	return total
end

--[[
    DESCRIPTION:    
    PARAMETERS :    
]] 
function get_data_single(player_name, skill, action_name, metric)
	local value = 0

	for index, v in pairs(Parse_Data) do
		
		if not Mob_Filter then
			if string.find(index, player_name) then 
				value = get_data_single_calculation(value, index, skill, action_name, metric)
			end

		else
			if string.find(index, player_name..":"..Mob_Filter) then
				value = get_data_single_calculation(value, index, skill, action_name, metric)
			end
		end

	end

	return value
end

--[[
    DESCRIPTION:    
    PARAMETERS :    
]] 
function get_data_single_calculation(value, index, skill, action_name, metric)
	if Parse_Data[index][skill]['single'][action_name] then
		if     metric == 'min' then value = get_data_single_min_calculation(value, index, skill, action_name, metric)
		elseif metric == 'max' then value = get_data_single_max_calculation(value, index, skill, action_name, metric)
		else 					    value = value + Parse_Data[index][skill]['single'][action_name][metric] end
	end
	return value
end

--[[
    DESCRIPTION:    
    PARAMETERS :    
]] 
function get_data_single_min_calculation(min, index, skill, action_name, metric)
	if min <= Parse_Data[index][skill]['single'][action_name][metric] then
		min = Parse_Data[index][skill]['single'][action_name][metric]
	end
	return min
end

--[[
    DESCRIPTION:    
    PARAMETERS :    
]] 
function get_data_single_max_calculation(max, index, skill, action_name, metric)
	if Parse_Data[index][skill]['single'][action_name][metric] > max then
		max = Parse_Data[index][skill]['single'][action_name][metric]
	end
	return max
end

-- ******************************************************************************************************
-- *
-- *                                             Utility Functions
-- *
-- ******************************************************************************************************

--[[
    DESCRIPTION:    
    PARAMETERS :    
]] 
function reset_parser()
	Parse_Data = {}
	Skill_Data = {}
	Initialized_Players = {}
	Blog_Content = {}
end

--[[
    DESCRIPTION:    
    PARAMETERS :    
]] 
function build_index(player_name, target_name)
	if not target_name then target_name = 'test' end
	return player_name..':'..target_name
end

--[[
    DESCRIPTION:    Handle weaponskill and skillchain parsing.
    PARAMETERS :    
        actor_name  Primary node
        node        Secondary node
        damage      Damage from the WS or SC
        action_name Name of the WS or SC
]] 
function Single_Damage(player_name, target_name, skill, damage, action_name)
    local index = build_index(player_name, target_name)
    Init_Data_Single(index, player_name, skill, action_name)

    if skill ~= 'healing' then 
    	Update_Data('inc', damage, player_name, target_name, 'total', 'total') 
    	Update_Data('inc', damage, player_name, target_name, 'total_no_sc', 'total')
    end
    
    -- Overall Data
    Update_Data('inc', damage, player_name, target_name, skill, 'total')
    if damage < Get_Data(player_name, skill, 'min') then Update_Data('set', damage, player_name, target_name, skill, 'min') end
    if damage > Get_Data(player_name, skill, 'max') then Update_Data('set', damage, player_name, target_name, skill, 'max') end

    -- Single Data
    Update_Data_Single('inc', damage, player_name, target_name, skill, action_name, 'total')
    Update_Data_Single('inc', 1,      player_name, target_name, skill, action_name, 'count')
    -- 'hits' gets incremented in parse.lua to handle AOEs.

    if damage < get_data_single(player_name, skill, action_name, 'min') then 
    	Update_Data_Single('set', damage, player_name, target_name, skill, action_name, 'min')
    end
    
    if damage > get_data_single(player_name, skill, action_name, 'max') then 
    	Update_Data_Single('set', damage, player_name, target_name, skill, action_name, 'max')
    end
end

-- ******************************************************************************************************
-- *
-- *                                           Running Accuracy
-- *
-- ******************************************************************************************************

--[[
    DESCRIPTION:    
    PARAMETERS :    
]] 
function running_acc(player_name, hit)
	if not Running_Accuracy_Data[player_name] then return end

	local max = table.maxn(Running_Accuracy_Data[player_name])
    if max >= Running_Accuracy_Limit then table.remove(Running_Accuracy_Data[player_name], Running_Accuracy_Limit) end
    table.insert(Running_Accuracy_Data[player_name], 1, hit)
end

--[[
    DESCRIPTION:    
    PARAMETERS :    
]] 
function tally_running_acc(player_name)
	if not Running_Accuracy_Data[player_name] then return 0 end

	local hits = 0
	local count = 0

	for index, value in pairs(Running_Accuracy_Data[player_name]) do
		if value then hits = hits + 1 end
		count = count + 1
	end

	return get_percent(hits, count)
end

-- ******************************************************************************************************
-- *
-- *                                              Sorting
-- *
-- ******************************************************************************************************

--[[
    DESCRIPTION:    
    PARAMETERS :    
]] 
function Sort_Damage()
	Populate_Total_Damage_Table()
	table.sort(Total_Damage_Race, function (a, b)
		local a_damage = a[2]
		local b_damage = b[2]
		return a_damage > b_damage 
	end)
end

--[[
    DESCRIPTION:    
    PARAMETERS :    
]] 
function Populate_Total_Damage_Table()
	Total_Damage_Race = {}
	for index, v in pairs(Initialized_Players) do
		table.insert(Total_Damage_Race, {index, Get_Data(index, 'total', 'total')})
	end
end

--[[
    DESCRIPTION:    
    PARAMETERS :    
]] 
function sort_single_damage(player_name)
	populate_single_damage_table(player_name)
	table.sort(Single_Damage_Race, function (a, b)
		local a_damage = a[2]
		local b_damage = b[2]
		return a_damage > b_damage 
	end)
end

--[[
    DESCRIPTION:    
    PARAMETERS :    
]] 
function populate_single_damage_table(player_name)
	Single_Damage_Race = {}
	for action_name, z in pairs(Skill_Data[focus_skill][player_name]) do
		table.insert(Single_Damage_Race, {action_name, get_data_single(player_name, focus_skill, action_name, 'total')})
	end
end