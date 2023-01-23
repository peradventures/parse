Trackable_List = {
    'total',
    'total_no_sc',
    'melee',
    'melee primary',
    'melee secondary',
    'melee kicks',
	'pet_melee',
	'pet_melee_discrete',
    'ranged',
	'pet_ranged',
    'throwing',
    'ws',
	'pet_ws',
    'sc',
    'ability',
	'pet_ability',
    'magic',
    'enspell',
    'nuke',
    'healing',
    'pet',
    'death',
	'default',
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

Catalog_Node = 'catalog'

-- Holds all of the damage data that the parser uses
Parse_Data = {} -- index is player:mob

-- Keeps track of which skills have been initialized
Trackable_Data = {}	-- [trackable][player_name]

-- Keeps track of which players have been initialized
Initialized_Players = {}

-- Keeps track of the running accuracy data
Running_Accuracy_Data = {}
Running_Accuracy_Limit = 25

-- Ranks players based on relative total damage done
Total_Damage_Race  = {}

-- Ranks weaponskills, skillchains, abilities, etc
Catalog_Damage_Race = {}

------------------------------------------------------------------------------------------------------
-- Initializes a player:mob combination in the primary data node.
-- Also initializes separate tracking globals for Running Accuracy.
-- If the player has already been initialized then this will quit out early.
------------------------------------------------------------------------------------------------------
-- index       : "player_name:mob_name"
-- player_name : "player_name"
------------------------------------------------------------------------------------------------------
function Init_Data(index, player_name)
	if (not index) then return end
	if Parse_Data[index] then return end

	Parse_Data[index] = {}

	-- Initialize data nodes
	for _, trackable in pairs(Trackable_List) do
		Parse_Data[index][trackable] = {}
		Parse_Data[index][trackable][Catalog_Node] = {}

		for _, metric in pairs(Metric_List) do
			Set_Data(0, index, trackable, metric)
		end
	end

	-- Initialize tracking tables
	if (player_name) and (not Initialized_Players[player_name]) then
		Initialized_Players[player_name] = true
		Running_Accuracy_Data[player_name] = {}
	end
end

------------------------------------------------------------------------------------------------------
-- Initializes a cataloged action.
-- If the action has already been initialized then this will quit out early.
-- Also initializes Trackable_Data which is used in the Focus Window.
------------------------------------------------------------------------------------------------------
-- index       : "player_name:mob_name"
-- player_name : "player_name"
-- trackable   : a tracked item from the Trackable_List
-- action_name : the name of the action to be cataloged
------------------------------------------------------------------------------------------------------
function Init_Data_Catalog(index, player_name, trackable, action_name)
	if (not index) or (not player_name) or (not trackable) or (not action_name) then return end

	Init_Data(index, player_name)

	-- Don't want to overwrite action_name node if it is already built out
	if (Parse_Data[index][trackable][Catalog_Node][action_name]) then return end

	Parse_Data[index][trackable][Catalog_Node][action_name] = {}

	-- Initialize catalog data nodes
	for _, metric in pairs(Metric_List) do
		Set_Data_Catalog(0, index, trackable, action_name, metric)
	end

	-- Need to set minimum high manually to capture accurate minimums
	Set_Data_Catalog(100000, index, trackable, action_name, 'min')

	-- Initialize tracking tables
	if (not Trackable_Data[trackable]) then Trackable_Data[trackable] = {} end
	if (not Trackable_Data[trackable][player_name]) then Trackable_Data[trackable][player_name] = {} end
end

------------------------------------------------------------------------------------------------------
-- A handler function that makes sure the data is set appropriately.
-- This does not set data directly. Rather, it calls the Set~ or Inc~ functions.
-- This is called by the functions that perform the action handling.
------------------------------------------------------------------------------------------------------
-- mode      : flag calling out whether the data should be set or incremented
-- value     : the value to set or increment the node to/by
-- audits    : a table containing necessary data; helps save on parameter slots
-- trackable : a tracked item from the Trackable_List
-- metric    : a trackable's metric from the Metric_List
------------------------------------------------------------------------------------------------------
function Update_Data(mode, value, audits, trackable, metric)
	local player_name = audits.player_name
	local target_name = audits.target_name
	local index = Build_Index(player_name, target_name)

	Init_Data(index, player_name)

	if (mode == 'inc') then
		Inc_Data(value, index, trackable, metric)
	elseif (mode == 'set') then
		Set_Data(value, index, trackable, metric)
	else
		Add_Message_To_Chat('E', 'Update_Data^metrics', 'Invalid update mode: '..tostring(mode))
	end
end

------------------------------------------------------------------------------------------------------
-- A handler function that makes sure the data is set appropriately (for cataloged actions)
-- This does not set data directly. Rather, it calls the Set~ or Inc~ functions.
-- This is called by the functions that perform the action handling.
------------------------------------------------------------------------------------------------------
-- mode        : flag calling out whether the data should be set or incremented
-- value       : the value to set or increment the node to/by
-- audits      : a table containing necessary data; helps save on parameter slots
-- trackable   : a tracked item from the Trackable_List
-- action_name : the name of the action to be cataloged
-- metric      : a trackable's metric from the Metric_List
------------------------------------------------------------------------------------------------------
function Update_Data_Catalog(mode, value, audits, trackable, action_name, metric)
	local player_name = audits.player_name
	local target_name = audits.target_name
	local index = Build_Index(player_name, target_name)

	if (not trackable) or (not player_name) or (not action_name) then return end
	Init_Data_Catalog(index, player_name, trackable, action_name)
	if (not Initialized_Players[player_name]) then Initialized_Players[player_name] = true end

	if (mode == 'inc') then
		Inc_Data_Catalog(value, index, trackable, action_name, metric)
	elseif (mode == 'set') then
		Set_Data_Catalog(value, index, trackable, action_name, metric)
	else
		Add_Message_To_Chat('E', 'Update_Data_Catalog^metrics', 'Invalid update mode: '..tostring(mode))
	end

	-- This is used for the focus window
	Trackable_Data[trackable][player_name][action_name] = true
end

------------------------------------------------------------------------------------------------------
-- Directly sets a trackable's metric to a specified value.
------------------------------------------------------------------------------------------------------
-- value     : the value to set the node to
-- index     : "player_name:mob_name"
-- trackable : a tracked item from the Trackable_List
-- metric    : a trackable's metric from the Metric_List
------------------------------------------------------------------------------------------------------
function Set_Data(value, index, trackable, metric)
	if (not value) or (not index) or (not trackable) or (not metric) then return end
	Parse_Data[index][trackable][metric] = value
end

------------------------------------------------------------------------------------------------------
-- Directly sets a trackable's cataloged action metric to a specified value.
-- Some trackables need to be cataloged discretely in addition to holistically.
-- For example, metrics for weapons skill damage and metrics for each individual weapon skill.
-- The discrete tracking happens in the "catalog" node under each trackable.
------------------------------------------------------------------------------------------------------
-- value       : the value to set the node to
-- index       : "player_name:mob_name"
-- trackable   : a tracked item from the Trackable_List
-- action_name : the name of the action to be cataloged
-- metric      : a trackable's metric from the Metric_List
------------------------------------------------------------------------------------------------------
function Set_Data_Catalog(value, index, trackable, action_name, metric)
	if (not value) or (not index) or (not trackable) or (not action_name) or (not metric) then return end
	Parse_Data[index][trackable][Catalog_Node][action_name][metric] = value
end

------------------------------------------------------------------------------------------------------
-- Increments a trackable's metric by a specified amount.
------------------------------------------------------------------------------------------------------
-- value     : the value to set the node to
-- index     : "player_name:mob_name"
-- trackable : a tracked item from the Trackable_List
-- metric    : a trackable's metric from the Metric_List
------------------------------------------------------------------------------------------------------
function Inc_Data(value, index, trackable, metric)
	if (not value) or (not index) or (not trackable) or (not metric) then return end
	Parse_Data[index][trackable][metric] = Parse_Data[index][trackable][metric] + value
end

------------------------------------------------------------------------------------------------------
-- Increments a trackable's metric by a specified amount.
-- Some trackables need to be cataloged discretely in addition to holistically.
-- For example, metrics for weapons skill damage and metrics for each individual weapon skill.
-- The discrete tracking happens in the "catalog" node under each trackable.
------------------------------------------------------------------------------------------------------
-- value       : the value to set the node to
-- index       : "player_name:mob_name"
-- trackable   : a tracked item from the Trackable_List
-- action_name : the name of the action to be cataloged
-- metric      : a trackable's metric from the Metric_List
------------------------------------------------------------------------------------------------------
function Inc_Data_Catalog(value, index, trackable, action_name, metric)
	if (not value) or (not index) or (not trackable) or (not action_name) or (not metric) then return end
	Parse_Data[index][trackable][Catalog_Node][action_name][metric] = Parse_Data[index][trackable][Catalog_Node][action_name][metric] + value
end

------------------------------------------------------------------------------------------------------
-- Gets data from a trackable metric.
-- If the mob filter is set then only actions towards that mob are counted.
------------------------------------------------------------------------------------------------------
-- player_name : string containing the player's name
-- trackable   : a tracked item from the Trackable_List
-- metric      : a trackable's metric from the Metric_List
------------------------------------------------------------------------------------------------------
function Get_Data(player_name, trackable, metric)
	local total = 0
	for index, _ in pairs(Parse_Data) do
		if (not Mob_Filter) then
			if string.find(index, player_name..":") then
				total = total + Parse_Data[index][trackable][metric]
			end
		else
			if string.find(index, player_name..":"..Mob_Filter) then
				total = total + Parse_Data[index][trackable][metric]
			end
		end

	end
	return total
end

------------------------------------------------------------------------------------------------------
-- Gets data from a trackable's cataloged metric.
-- If the mob filter is set then only actions towards that mob are counted.
------------------------------------------------------------------------------------------------------
-- player_name : string containing the player's name
-- trackable   : a tracked item from the Trackable_List
-- action_name : the name of the action to be cataloged
-- metric      : a trackable's metric from the Metric_List
------------------------------------------------------------------------------------------------------
function Get_Data_Catalog(player_name, trackable, action_name, metric)
	local total = 0
	for index, _ in pairs(Parse_Data) do
		if (not Mob_Filter) then
			if string.find(index, player_name) then 
				total = Get_Data_Catalog_Calculation(total, index, trackable, action_name, metric)
			end
		else
			if string.find(index, player_name..":"..Mob_Filter) then
				total = Get_Data_Catalog_Calculation(total, index, trackable, action_name, metric)
			end
		end
	end
	return total
end

------------------------------------------------------------------------------------------------------
-- Helper function for getting cataloged data.
------------------------------------------------------------------------------------------------------
-- value       : original value to be added on to
-- index       : "player_name:mob_name"
-- trackable   : a tracked item from the Trackable_List
-- action_name : the name of the action to be cataloged
-- metric      : a trackable's metric from the Metric_List
------------------------------------------------------------------------------------------------------
function Get_Data_Catalog_Calculation(value, index, trackable, action_name, metric)
	if (Parse_Data[index][trackable][Catalog_Node][action_name]) then
		if     (metric == 'min') then value = Get_Data_Catalog_Min_Calculation(value, index, trackable, action_name, metric)
		elseif (metric == 'max') then value = Get_Data_Catalog_Max_Calculation(value, index, trackable, action_name, metric)
		else value = value + Parse_Data[index][trackable][Catalog_Node][action_name][metric] end
	end
	return value
end

------------------------------------------------------------------------------------------------------
-- Helper function for getting cataloged data for minimum metric.
------------------------------------------------------------------------------------------------------
-- min         : current observed minimum value
-- index       : "player_name:mob_name"
-- trackable   : a tracked item from the Trackable_List
-- action_name : the name of the action to be cataloged
-- metric      : a trackable's metric from the Metric_List
------------------------------------------------------------------------------------------------------
function Get_Data_Catalog_Min_Calculation(min, index, trackable, action_name, metric)
	if (min <= Parse_Data[index][trackable][Catalog_Node][action_name][metric]) then
	   	min =  Parse_Data[index][trackable][Catalog_Node][action_name][metric]
	end
	return min
end

------------------------------------------------------------------------------------------------------
-- Helper function for getting cataloged data for maximum metric.
------------------------------------------------------------------------------------------------------
-- max         : current observed maximum value
-- index       : "player_name:mob_name"
-- trackable   : a tracked item from the Trackable_List
-- action_name : the name of the action to be cataloged
-- metric      : a trackable's metric from the Metric_List
------------------------------------------------------------------------------------------------------
function Get_Data_Catalog_Max_Calculation(max, index, trackable, action_name, metric)
	if (Parse_Data[index][trackable][Catalog_Node][action_name][metric] > max) then
		max = Parse_Data[index][trackable][Catalog_Node][action_name][metric]
	end
	return max
end

------------------------------------------------------------------------------------------------------
-- Resets the parsing data and clears the battle log.
------------------------------------------------------------------------------------------------------
function Reset_Parser()
	Parse_Data = {}
	Trackable_Data = {}
	Initialized_Players = {}
	Blog_Content = {}
	Refresh_Blog()
end

------------------------------------------------------------------------------------------------------
-- Builds the primary index for Parse_Data of the form player_name:mob_name
------------------------------------------------------------------------------------------------------
-- player_name : name of the player or entity performing the action
-- mob_name    : name of the mob or entity receiving the action
------------------------------------------------------------------------------------------------------
function Build_Index(player_name, mob_name)
	if (not mob_name) then mob_name = 'test' end

	if (not player_name) then
		Add_Message_To_Chat('E', 'Build_Index^metrics', 'player_name: '..tostring(player_name)..' target_name: '..tostring(mob_name))
		return
	end

	return player_name..':'..mob_name
end


------------------------------------------------------------------------------------------------------
-- Directs the setting of cataloged data.
-- Called by the action handling functions.
------------------------------------------------------------------------------------------------------
-- player_name : name of the player or entity performing the action
-- mob_name    : name of the mob or entity receiving the action
-- trackable   : a tracked item from the Trackable_List
-- value       : value to be logged
-- action_name : the name of the action to be cataloged
------------------------------------------------------------------------------------------------------
function Catalog_Damage(player_name, mob_name, trackable, value, action_name)
    local index = Build_Index(player_name, mob_name)
    Init_Data_Catalog(index, player_name, trackable, action_name)

	local audits = {
		player_name = player_name,
		target_name = mob_name,
	}

    if (trackable ~= 'healing') then
    	Update_Data('inc', value, audits, 'total', 'total') 

		if (trackable ~= 'sc') then
			Update_Data('inc', value, audits, 'total_no_sc', 'total')
		end

    end

    -- Overall Data
    Update_Data('inc', value, audits, trackable, 'total')
    if (value > 0) and (value < Get_Data(player_name, trackable, 'min')) then Update_Data('set', value, audits, trackable, 'min') end
    if (value > Get_Data(player_name, trackable, 'max')) then Update_Data('set', value, audits, trackable, 'max') end

    -- Catalog Data
    Update_Data_Catalog('inc', value, audits, trackable, action_name, 'total')
    -- 'count' gets incremented in packet_handling.lua

    if (value > 0) and (value < Get_Data_Catalog(player_name, trackable, action_name, 'min')) then
    	Update_Data_Catalog('set', value, audits, trackable, action_name, 'min')
    end

    if (value > Get_Data_Catalog(player_name, trackable, action_name, 'max')) then
    	Update_Data_Catalog('set', value, audits, trackable, action_name, 'max')
    end
end

------------------------------------------------------------------------------------------------------
-- Keeps a tally of the last Running_Accuracy_Limit amount of hit attempts.
-- This is called by the action handling functions.
------------------------------------------------------------------------------------------------------
-- player_name : primary index for the Running_Accuracy_Data table
-- hit         : boolean of whether this is a hit or a miss
------------------------------------------------------------------------------------------------------
function Running_Accuracy(player_name, hit)
	if (not Running_Accuracy_Data[player_name]) then return end
	local max = Count_Table_Elements(Running_Accuracy_Data[player_name])
    if (max >= Running_Accuracy_Limit) then table.remove(Running_Accuracy_Data[player_name], Running_Accuracy_Limit) end
	table.insert(Running_Accuracy_Data[player_name], 1, hit)
end

------------------------------------------------------------------------------------------------------
-- Returns the players accuracy for the last Running_Accuracy_Limit amount of hits.
------------------------------------------------------------------------------------------------------
-- player_name : primary index for the Running_Accuracy_Data table
-- length      : length of the returned accuracy string
------------------------------------------------------------------------------------------------------
function Tally_Running_Accuracy(player_name, length)
	if (not Running_Accuracy_Data[player_name]) then return Format_String('0', length, nil, nil, true) end

	local hits = 0
	local count = 0

	for _, value in pairs(Running_Accuracy_Data[player_name]) do
		if (value) then hits = hits + 1 end
		count = count + 1
	end

	if (count == 0) then count = 1 end
	local percent = (hits / count) * 100

	local color = C_White
	if (percent == 0) then
		color = C_Gray
	elseif (percent < 60) then
		color = C_Red
	elseif (percent < 80) then
		color = C_Orange
	elseif (percent < 95) then
		color = C_Yellow
	end

	return Format_Percent(hits, count, length, color)
end

------------------------------------------------------------------------------------------------------
-- Sorting function for the Total_Damage_Race table.
------------------------------------------------------------------------------------------------------
function Sort_Damage()
	Populate_Total_Damage_Table()
	table.sort(Total_Damage_Race, function (a, b)
		local a_damage = a[2]
		local b_damage = b[2]
		return (a_damage > b_damage)
	end)
end

------------------------------------------------------------------------------------------------------
-- Builds the Total_Damage_Race table.
-- This table contains the total amount of damage that each recognized player has done.
-- Capable of filtering out skillchain damage.
------------------------------------------------------------------------------------------------------
function Populate_Total_Damage_Table()
	Total_Damage_Race = {}
	local damage
	for index, _ in pairs(Initialized_Players) do
		if (Include_SC_Damage) then
			damage = Get_Data(index, 'total', 'total')
		else
			damage = Get_Data(index, 'total_no_sc', 'total')
		end
		table.insert(Total_Damage_Race, {index, damage})
	end
end

------------------------------------------------------------------------------------------------------
-- Sorting function for the Catalog_Damage_Race table.
------------------------------------------------------------------------------------------------------
-- player_name : name of the player that did the cataloged action
------------------------------------------------------------------------------------------------------
function Sort_Catalog_Damage(player_name)
	Populate_Catalog_Damage_Table(player_name)
	table.sort(Catalog_Damage_Race, function (a, b)
		local a_damage = a[2]
		local b_damage = b[2]
		return (a_damage > b_damage)
	end)
end

------------------------------------------------------------------------------------------------------
-- Builds the Catalog_Damage_Race table.
-- This table contains the total amount of damage that each recognized player has done for a cataloged action.
------------------------------------------------------------------------------------------------------
function Populate_Catalog_Damage_Table(player_name)
	Catalog_Damage_Race = {}
	for action_name, _ in pairs(Trackable_Data[Focused_Trackable][player_name]) do
		table.insert(Catalog_Damage_Race, {action_name, Get_Data_Catalog(player_name, Focused_Trackable, action_name, 'total')})
	end
end