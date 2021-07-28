skills = {
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

metrics = {
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

parse_data = {}
-- index is player:mob

skill_data = {}
players = {}
total_damage_race  = {}
single_damage_race = {}
running_acc_data = {}

running_acc_limit = 50

-- ******************************************************************************************************
-- *
-- *                                            Initialization
-- *
-- ******************************************************************************************************

-- If FALSE is returned then there was an error and we should not proceed.
function init_data(index, player_name)
	-- Already initialized
	if parse_data[index] then return end

	-- Start initialization
	--windower.add_to_chat(c_chat, 'Init '..index)
	parse_data[index] = {}

	for i, skill in pairs(skills) do
		parse_data[index][skill] = {}
		parse_data[index][skill]['single'] = {}
		
		-- Metric Nodes
		for k, metric in pairs(metrics) do	
			set_data(0, index, skill, metric)
		end
	end

	-- players keeps track of which players have been initialized
	-- running_acc_data keeps track of which players have running accuracy running
	if player_name and not players[player_name] then
		players[player_name] = true
		running_acc_data[player_name] = {}
	end
end

function init_data_single(index, player_name, skill, action_name)
	init_data(index, player_name)

	-- Don't want to overwrite action_name node if it is already built out
	if parse_data[index][skill]['single'][action_name] then return end

	-- Start initialization
	parse_data[index][skill]['single'][action_name] = {}

	for k, metric in pairs(metrics) do	
		set_data_single(0, index, skill, action_name, metric)
	end

	set_data_single(100000, index, skill, action_name, 'min')

	if not skill_data[skill] then skill_data[skill] = {} end
	if not skill_data[skill][player_name] then skill_data[skill][player_name] = {} end
end

-- ******************************************************************************************************
-- *
-- *                                                Sets
-- *
-- ******************************************************************************************************

function update_data(mode, value, player_name, target_name, skill, metric)
	local index = build_index(player_name, target_name)
	init_data(index, player_name)

	-- Increment from existing value
	if mode == 'inc' then
		inc_data(value, index, skill, metric)
	
	-- Set value directly
	elseif mode == 'set' then
		set_data(value, index, skill, metric)
	
	else windower.add_to_chat(c_chat, 'Invalid mode: '..mode) end
end

function update_data_single(mode, value, player_name, target_name, skill, action_name, metric)
	local index = build_index(player_name, target_name)
	init_data_single(index, player_name, skill, action_name)

	-- This holds all of the players who have data.
	if not players[player_name] then players[player_name] = true end

	-- Increment from existing value
	if mode == 'inc' then
		inc_data_single(value, index, skill, action_name, metric)
	
	-- Set value directly
	elseif mode == 'set' then
		set_data_single(value, index, skill, action_name, metric)
	
	else windower.add_to_chat(c_chat, 'Invalid mode: '..mode) end

	-- This is used for the focus window
	skill_data[skill][player_name][action_name] = true
end

function set_data(value, index, skill, metric)
	parse_data[index][skill][metric] = value
end

function set_data_single(value, index, skill, action_name, metric)
	parse_data[index][skill]['single'][action_name][metric] = value
end

function inc_data(value, index, skill, metric)
	parse_data[index][skill][metric] = parse_data[index][skill][metric] + value
end

function inc_data_single(value, index, skill, action_name, metric)
	parse_data[index][skill]['single'][action_name][metric] = parse_data[index][skill]['single'][action_name][metric] + value
end

-- ******************************************************************************************************
-- *
-- *                                                Gets
-- *
-- ******************************************************************************************************

function get_data(player_name, skill, metric)
	local total = 0

	for index, value in pairs(parse_data) do
		-- If there is no mob filter then get everything associated with this player.
		if not Mob_Filter then
			if string.find(index, player_name) then
				total = total + parse_data[index][skill][metric]
			end
		
		-- Otherwise get everything for this specific mob. Partial matches count.
		else
			if string.find(index, player_name..":"..Mob_Filter) then
				total = total + parse_data[index][skill][metric]
			end
		end
	end

	return total
end

function get_data_single(player_name, skill, action_name, metric)
	local value = 0

	for index, v in pairs(parse_data) do
		
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

function get_data_single_calculation(value, index, skill, action_name, metric)
	if parse_data[index][skill]['single'][action_name] then
		if     metric == 'min' then value = get_data_single_min_calculation(value, index, skill, action_name, metric)
		elseif metric == 'max' then value = get_data_single_max_calculation(value, index, skill, action_name, metric)
		else 					    value = value + parse_data[index][skill]['single'][action_name][metric] end
	end
	return value
end

function get_data_single_min_calculation(min, index, skill, action_name, metric)
	if min <= parse_data[index][skill]['single'][action_name][metric] then
		min = parse_data[index][skill]['single'][action_name][metric]
	end
	return min
end

function get_data_single_max_calculation(max, index, skill, action_name, metric)
	if parse_data[index][skill]['single'][action_name][metric] > max then
		max = parse_data[index][skill]['single'][action_name][metric]
	end
	return max
end

-- ******************************************************************************************************
-- *
-- *                                             Utility Functions
-- *
-- ******************************************************************************************************

function reset_parser()
	parse_data = {}
	skill_data = {}
	players = {}
	blog_content = {}
end

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
function single_damage(player_name, target_name, skill, damage, action_name)
    local index = build_index(player_name, target_name)
    init_data_single(index, player_name, skill, action_name)

    if skill ~= 'healing' then 
    	update_data('inc', damage, player_name, target_name, 'total', 'total') 
    	update_data('inc', damage, player_name, target_name, 'total_no_sc', 'total')
    end
    
    -- Overall Data
    update_data('inc', damage, player_name, target_name, skill, 'total')
    if damage < get_data(player_name, skill, 'min') then update_data('set', damage, player_name, target_name, skill, 'min') end
    if damage > get_data(player_name, skill, 'max') then update_data('set', damage, player_name, target_name, skill, 'max') end

    -- Single Data
    update_data_single('inc', damage, player_name, target_name, skill, action_name, 'total')
    update_data_single('inc', 1,      player_name, target_name, skill, action_name, 'count')
    -- 'hits' gets incremented in parse.lua to handle AOEs.

    if damage < get_data_single(player_name, skill, action_name, 'min') then 
    	update_data_single('set', damage, player_name, target_name, skill, action_name, 'min')
    end
    
    if damage > get_data_single(player_name, skill, action_name, 'max') then 
    	update_data_single('set', damage, player_name, target_name, skill, action_name, 'max')
    end
end

-- ******************************************************************************************************
-- *
-- *                                           Running Accuracy
-- *
-- ******************************************************************************************************

function running_acc(player_name, hit)
	if not running_acc_data[player_name] then return end

	local max = table.maxn(running_acc_data[player_name])
    if max >= running_acc_limit then table.remove(running_acc_data[player_name], running_acc_limit) end
    table.insert(running_acc_data[player_name], 1, hit)
end

function tally_running_acc(player_name)
	if not running_acc_data[player_name] then return 0 end

	local hits = 0
	local count = 0

	for index, value in pairs(running_acc_data[player_name]) do
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

function sort_damage()
	populate_total_damage_table()
	table.sort(total_damage_race, function (a, b)
		local a_damage = a[2]
		local b_damage = b[2]
		return a_damage > b_damage 
	end)
end

function populate_total_damage_table()
	total_damage_race = {}
	for index, v in pairs(players) do
		table.insert(total_damage_race, {index, get_data(index, 'total', 'total')})
	end
end

function sort_single_damage(player_name)
	populate_single_damage_table(player_name)
	table.sort(single_damage_race, function (a, b)
		local a_damage = a[2]
		local b_damage = b[2]
		return a_damage > b_damage 
	end)
end

function populate_single_damage_table(player_name)
	single_damage_race = {}
	for action_name, z in pairs(skill_data[focus_skill][player_name]) do
		table.insert(single_damage_race, {action_name, get_data_single(player_name, focus_skill, action_name, 'total')})
	end
end