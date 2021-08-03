-- Focus window is shared with the battle log. It is initialized in battle_log.lua

Focus_Skill = 'ws'

--[[
    DESCRIPTION:    	Builds the focus window.
]] 
function Focus_Player()
    local player_name = Focus_Entity
    local dmg_col     = Column_Widths['dmg']

    Focus_Layout = {}
    local has_data = false
     
    local total_damage = Get_Data(player_name, 'total', 'total')   
    table.insert(Focus_Layout, 'Name   : '..player_name..' | Total: '..String_Length(Add_Comma(total_damage), dmg_col))
    table.insert(Focus_Layout, '-------------------------------------------------------')
    
    has_data = Focus_Melee(player_name, total_damage)
    has_data = Focus_Ranged(player_name, total_damage)
    has_data = Focus_WS_And_SC(player_name, total_damage)
    has_data = Focus_Magic(player_name, total_damage)
    has_data = Focus_Ability(player_name, total_damage)
    has_data = Focus_Healing(player_name, total_damage)    

    if (not has_data) then 
        table.insert(Focus_Layout, 'No data')
        table.insert(Focus_Layout, '-------------------------------------------------------')
    end
    table.insert(Focus_Layout, ' ')

    Single_Data(player_name)
end

function Single_Data(player_name)
    if (not Focus_Skill) then Focus_Skill = 'ws' end

    local row, header, name
    local name_col   = Column_Widths['name']
    local dmg_col    = Column_Widths['dmg']
    local single_col = Column_Widths['single']
    local small_col  = Column_Widths['small']

    header = String_Length('Name', name_col)
    header = header..String_Length('Total',   dmg_col)
    header = header..String_Length('###',     single_col)
    header = header..String_Length('Acc',   small_col)
    header = header..String_Length('Average', dmg_col)
    header = header..String_Length('Min',     dmg_col)
    header = header..String_Length('Max',     dmg_col)

    table.insert(Focus_Layout, header)

    if (not Skill_Data[Focus_Skill]) then return end
    if (not Skill_Data[Focus_Skill][player_name]) then return end

    Sort_Single_Damage(player_name)

    local action_name
    for _, data in ipairs(Single_Damage_Race) do
        action_name = data[1]
        Single_Row(player_name, action_name)
    end

    -- for action_name, z in pairs(skill_data[focus_skill][player_name]) do
    --     single_row(player_name, action_name)
    -- end
end

--[[
    DESCRIPTION:
    PARAMETERS :
]]
function Focus_Melee(player_name, total_damage)
    local dmg_col   = Column_Widths['dmg']
    local small_col = Column_Widths['small']
    
    local melee_total       = Get_Data(player_name, 'melee', 'total')
    local melee_acc         = Format_Percent(Get_Data(player_name, 'melee', 'hits'), Get_Data(player_name, 'melee', 'count'), small_col)
    local melee_crit_damage = Get_Data(player_name, 'melee', 'crit damage')

    local has_data = false

    if (melee_total > 0) then
        has_data = true
        local melee_header = String_Length('Melee', dmg_col)..' '..String_Length('% Dmg', small_col)..' '..String_Length('% Acc', small_col)
                             ..' '..String_Length('Crit', dmg_col)..' '..String_Length('% Crt', small_col)
        table.insert(Focus_Layout, melee_header)
        
        local melee_string         = String_Length(Add_Comma(melee_total), dmg_col)
        local melee_percent_string = Format_Percent(melee_total, total_damage, small_col)
        local melee_acc_string     = melee_acc
        local melee_crit_string    = String_Length(Add_Comma(melee_crit_damage), dmg_col)
        local melee_crit_percent   = Format_Percent(melee_crit_damage, total_damage, small_col)
        local melee_data = melee_string..' '..melee_percent_string..' '..melee_acc_string..' '..melee_crit_string..' '..melee_crit_percent
        table.insert(Focus_Layout, melee_data) 
        
        table.insert(Focus_Layout, '-------------------------------------------------------')
    end

    return has_data
end

--[[
    DESCRIPTION:
    PARAMETERS :
]]
function Focus_Ranged(player_name, total_damage)
    local dmg_col   = Column_Widths['dmg']
    local small_col = Column_Widths['small']
    
    local ranged_total       = Get_Data(player_name, 'ranged', 'total')
    local ranged_acc         = Format_Percent(Get_Data(player_name, 'ranged', 'hits'), Get_Data(player_name, 'ranged', 'count'))
    local ranged_crit_damage = Get_Data(player_name, 'ranged', 'crit damage') 

    local has_data = false

    if (ranged_total) > 0 then
        has_data = true
        local ranged_header = String_Length('Ranged', dmg_col)..' '..String_Length('% Dmg', small_col)..' '..String_Length('% Acc', small_col)
                             ..' '..String_Length('Crit', dmg_col)..' '..String_Length('% Crt', small_col)
        table.insert(Focus_Layout, ranged_header)

        local ranged_string         = String_Length(Add_Comma(ranged_total), dmg_col)
        local ranged_percent_string = String_Length(Format_Percent(ranged_total, total_damage), small_col)
        local ranged_acc_string     = String_Length(ranged_acc, small_col)
        local ranged_crit_string    = String_Length(Add_Comma(ranged_crit_damage), dmg_col)
        local ranged_crit_percent   = String_Length(Format_Percent(ranged_crit_damage,  total_damage), small_col)
        local ranged_data = ranged_string..' '..ranged_percent_string..' '..ranged_acc_string..' '..ranged_crit_string..' '..ranged_crit_percent
        table.insert(Focus_Layout, ranged_data) 
        
        table.insert(Focus_Layout, '-------------------------------------------------------')
    end

    return has_data
end

--[[
    DESCRIPTION:
    PARAMETERS :
]]
function Focus_WS_And_SC(player_name, total_damage)
    local dmg_col   = Column_Widths['dmg']
    local small_col = Column_Widths['small']

    local ws_total = Get_Data(player_name, 'ws', 'total')
    local ws_acc   = Format_Percent(Get_Data(player_name, 'ws', 'hits'), Get_Data(player_name, 'ws', 'count'))
    local sc_total = Get_Data(player_name, 'sc', 'total')

    local has_data = false

    if (ws_total > 0) then
        has_data = true
        local ws_header = String_Length('WS', dmg_col)..' '..String_Length('% Dmg', small_col)..' '..String_Length('% Acc', small_col)
                          ..' '..String_Length('SC', dmg_col)..' '..String_Length('% SC', small_col)
        table.insert(Focus_Layout, ws_header)

        local ws_string         = String_Length(Add_Comma(ws_total), dmg_col)
        local ws_percent_string = String_Length(Format_Percent(ws_total, total_damage), small_col)
        local ws_acc_string     = String_Length(ws_acc, small_col)
        local sc_string         = String_Length(Add_Comma(sc_total), dmg_col)
        local sc_percent_string = String_Length(Format_Percent(sc_total, total_damage), small_col)
        local ws_data = ws_string..' '..ws_percent_string..' '..ws_acc_string..' '..sc_string..' '..sc_percent_string
        table.insert(Focus_Layout, ws_data)

        table.insert(Focus_Layout, '-------------------------------------------------------')
    end

    return has_data
end

--[[
    DESCRIPTION:
    PARAMETERS :
]]
function Focus_Magic(player_name, total_damage)
    local dmg_col   = Column_Widths['dmg']
    local small_col = Column_Widths['small']
    
    local magic_total = Get_Data(player_name, 'magic', 'total')

    local has_data = false

    if (magic_total > 0) then
        has_data = true
        local magic_header = String_Length('Magic', dmg_col)..' '..String_Length('% Dmg', small_col)
        table.insert(Focus_Layout, magic_header)

        local magic_string         = String_Length(Add_Comma(magic_total), dmg_col)
        local magic_percent_string = String_Length(Format_Percent(magic_total, total_damage), small_col)
        local magic_data = magic_string..' '..magic_percent_string
        table.insert(Focus_Layout, magic_data)

        table.insert(Focus_Layout, '-------------------------------------------------------')
    end

    return has_data
end

--[[
    DESCRIPTION:
    PARAMETERS :
]]
function Focus_Ability(player_name, total_damage)
    local dmg_col   = Column_Widths['dmg']
    local small_col = Column_Widths['small']

    local ability_total = Get_Data(player_name, 'ability', 'total')

    local has_data = false

    if (ability_total > 0) then
        has_data = true
        local ability_header = String_Length('Ability', dmg_col)..' '..String_Length('% Dmg', small_col)
        table.insert(Focus_Layout, ability_header)

        local ability_string         = String_Length(Add_Comma(ability_total), dmg_col)
        local ability_percent_string = String_Length(Format_Percent(ability_total, total_damage), small_col)
        local ability_data = ability_string..' '..ability_percent_string
        table.insert(Focus_Layout, ability_data)

        table.insert(Focus_Layout, '-------------------------------------------------------')
    end

    return has_data
end

--[[
    DESCRIPTION:
    PARAMETERS :
]]
function Focus_Healing(player_name, total_damage)
    local dmg_col   = Column_Widths['dmg']
    local small_col = Column_Widths['small']
    
    local healing_total = Get_Data(player_name, 'healing', 'total')

    local has_data = false

    if (healing_total > 0) then
        has_data = true
        local healing_header = String_Length('Healing', dmg_col)..' '..String_Length('% Tot', small_col)
        table.insert(Focus_Layout, healing_header)

        local healing_string         = String_Length(Add_Comma(healing_total), dmg_col)
        local healing_percent_string = String_Length(Format_Percent(healing_total, total_damage), small_col)
        local healing_data = healing_string..' '..healing_percent_string
        table.insert(Focus_Layout, healing_data)

        table.insert(Focus_Layout, '-------------------------------------------------------')
    end

    return has_data
end

--[[
    DESCRIPTION:
    PARAMETERS :
]]
function Single_Row(player_name, action_name)
    local name_col   = Column_Widths['name']
    local dmg_col    = Column_Widths['dmg']
    local single_col = Column_Widths['single']
    local small_col  = Column_Widths['small']

    local row = String_Length(action_name, name_col)

    local single_damage = Get_Data_Single(player_name, Focus_Skill, action_name, 'total')
    local single_hits   = Get_Data_Single(player_name, Focus_Skill, action_name, 'hits')
    local single_count  = Get_Data_Single(player_name, Focus_Skill, action_name, 'count')

    row = row..String_Length(Add_Comma(single_damage), dmg_col)
    row = row..String_Length(single_count, single_col)
    row = row..String_Length(Format_Percent(single_hits, single_count), small_col)

    local single_average = tonumber(string.format("%d", single_damage / single_count))
    if (single_count == 0) then single_average = 0 end

    row = row..String_Length(Add_Comma(single_average), dmg_col)
    row = row..String_Length(Add_Comma(Get_Data_Single(player_name, Focus_Skill, action_name, 'min')), dmg_col)
    row = row..String_Length(Add_Comma(Get_Data_Single(player_name, Focus_Skill, action_name, 'max')), dmg_col)
    table.insert(Focus_Layout, row)
end