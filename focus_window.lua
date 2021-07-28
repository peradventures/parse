--[[
    DESCRIPTION:    	Builds the focus window.
]] 
function focus_player()
    local player_name = Focus_Entity
    local name_col   = Column_Widths['name']
    local dmg_col    = Column_Widths['dmg']
    local single_col = Column_Widths['single']
    local small_col  = Column_Widths['small']
    local has_data = false

    focus_layout = {}
     
    local damage_total   = get_data(player_name, 'total', 'total')   
    table.insert(focus_layout, 'Name   : '..player_name..' | Total: '..String_Length(Add_Comma(damage_total), dmg_col))
    table.insert(focus_layout, '-------------------------------------------------------')
    
    -- Melee

    local melee_total          = get_data(player_name, 'melee', 'total')
    local melee_acc            = get_percent(get_data(player_name, 'melee', 'hits'), get_data(player_name, 'melee', 'count'))
    local melee_crit_damage    = get_data(player_name, 'melee', 'crit damage')

    if melee_total > 0 then 
        has_data = true
        local melee_header = String_Length('Melee', dmg_col)..' '..String_Length('% Dmg', small_col)..' '..String_Length('% Acc', small_col)
                             ..' '..String_Length('Crit', dmg_col)..' '..String_Length('% Crt', small_col)
        table.insert(focus_layout, melee_header)
        
        local melee_string         = String_Length(Add_Comma(melee_total), dmg_col)
        local melee_percent_string = String_Length(get_percent(melee_total, damage_total), small_col)
        local melee_acc_string     = String_Length(melee_acc, small_col)
        local melee_crit_string    = String_Length(Add_Comma(melee_crit_damage), dmg_col)
        local melee_crit_percent   = String_Length(get_percent(melee_crit_damage,  damage_total), small_col)
        local melee_data = melee_string..' '..melee_percent_string..' '..melee_acc_string..' '..melee_crit_string..' '..melee_crit_percent
        table.insert(focus_layout, melee_data) 
        
        table.insert(focus_layout, '-------------------------------------------------------')
    end
    
    -- Ranged

    local ranged_total         = get_data(player_name, 'ranged', 'total')
    local ranged_acc           = get_percent(get_data(player_name, 'ranged', 'hits'), get_data(player_name, 'ranged', 'count'))
    local ranged_crit_damage   = get_data(player_name, 'ranged', 'crit damage') 

    if ranged_total > 0 then
        has_data = true
        local ranged_header = String_Length('Ranged', dmg_col)..' '..String_Length('% Dmg', small_col)..' '..String_Length('% Acc', small_col)
                             ..' '..String_Length('Crit', dmg_col)..' '..String_Length('% Crt', small_col)
        table.insert(focus_layout, ranged_header)

        local ranged_string         = String_Length(Add_Comma(ranged_total), dmg_col)
        local ranged_percent_string = String_Length(get_percent(ranged_total, damage_total), small_col)
        local ranged_acc_string     = String_Length(ranged_acc, small_col)
        local ranged_crit_string    = String_Length(Add_Comma(ranged_crit_damage), dmg_col)
        local ranged_crit_percent   = String_Length(get_percent(ranged_crit_damage,  damage_total), small_col)
        local ranged_data = ranged_string..' '..ranged_percent_string..' '..ranged_acc_string..' '..ranged_crit_string..' '..ranged_crit_percent
        table.insert(focus_layout, ranged_data) 
        
        table.insert(focus_layout, '-------------------------------------------------------')
    end

    -- Weaponskill / Skillchain

    local ws_total = get_data(player_name, 'ws', 'total')
    local ws_acc   = get_percent(get_data(player_name, 'ws', 'hits'), get_data(player_name, 'ws', 'count'))
    local sc_total = get_data(player_name, 'sc', 'total')

    if ws_total > 0 then
        has_data = true
        local ws_header = String_Length('WS', dmg_col)..' '..String_Length('% Dmg', small_col)..' '..String_Length('% Acc', small_col)
                          ..' '..String_Length('SC', dmg_col)..' '..String_Length('% SC', small_col)
        table.insert(focus_layout, ws_header)

        local ws_string         = String_Length(Add_Comma(ws_total), dmg_col)
        local ws_percent_string = String_Length(get_percent(ws_total, damage_total), small_col)
        local ws_acc_string     = String_Length(ws_acc, small_col)
        local sc_string         = String_Length(Add_Comma(sc_total), dmg_col)
        local sc_percent_string = String_Length(get_percent(sc_total, damage_total), small_col)
        local ws_data = ws_string..' '..ws_percent_string..' '..ws_acc_string..' '..sc_string..' '..sc_percent_string
        table.insert(focus_layout, ws_data)

        table.insert(focus_layout, '-------------------------------------------------------')
    end

    -- Magic

    local magic_total = get_data(player_name, 'magic', 'total')

    if magic_total > 0 then
        has_data = true
        local magic_header = String_Length('Magic', dmg_col)..' '..String_Length('% Dmg', small_col)
        table.insert(focus_layout, magic_header)

        local magic_string         = String_Length(Add_Comma(magic_total), dmg_col)
        local magic_percent_string = String_Length(get_percent(magic_total, damage_total), small_col)
        local magic_data = magic_string..' '..magic_percent_string
        table.insert(focus_layout, magic_data)

        table.insert(focus_layout, '-------------------------------------------------------')
    end
    
    -- Ability

    local ability_total = get_data(player_name, 'ability', 'total')

    if ability_total > 0 then
        has_data = true
        local ability_header = String_Length('Ability', dmg_col)..' '..String_Length('% Dmg', small_col)
        table.insert(focus_layout, ability_header)

        local ability_string         = String_Length(Add_Comma(ability_total), dmg_col)
        local ability_percent_string = String_Length(get_percent(ability_total, damage_total), small_col)
        local ability_data = ability_string..' '..ability_percent_string
        table.insert(focus_layout, ability_data)

        table.insert(focus_layout, '-------------------------------------------------------')
    end

    -- Healing

    local healing_total = get_data(player_name, 'healing', 'total')

    if healing_total > 0 then
        has_data = true
        local healing_header = String_Length('Healing', dmg_col)..' '..String_Length('% Tot', small_col)
        table.insert(focus_layout, healing_header)

        local healing_string         = String_Length(Add_Comma(healing_total), dmg_col)
        local healing_percent_string = String_Length(get_percent(healing_total, damage_total), small_col)
        local healing_data = healing_string..' '..healing_percent_string
        table.insert(focus_layout, healing_data)

        table.insert(focus_layout, '-------------------------------------------------------')
    end

    if not has_data then 
        table.insert(focus_layout, 'No data')
        table.insert(focus_layout, '-------------------------------------------------------')
    end
    table.insert(focus_layout, ' ')

    single_data(player_name)
end

function single_data(player_name)
    if not focus_skill then focus_skill = 'ws' end

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

    table.insert(focus_layout, header)

    if not skill_data[focus_skill] then return end
    if not skill_data[focus_skill][player_name] then return end

    sort_single_damage(player_name)

    for i, v in ipairs(single_damage_race) do
        action_name = v[1]
        single_row(player_name, action_name)
    end

    -- for action_name, z in pairs(skill_data[focus_skill][player_name]) do
    --     single_row(player_name, action_name)
    -- end
end

function single_row(player_name, action_name)
    local name_col   = Column_Widths['name']
    local dmg_col    = Column_Widths['dmg']
    local single_col = Column_Widths['single']
    local small_col  = Column_Widths['small']

    row = String_Length(action_name, name_col)

    local single_damage = get_data_single(player_name, focus_skill, action_name, 'total')
    local single_hits   = get_data_single(player_name, focus_skill, action_name, 'hits')
    local single_count  = get_data_single(player_name, focus_skill, action_name, 'count')

    row = row..String_Length(Add_Comma(single_damage), dmg_col)
    row = row..String_Length(single_count, single_col)
    row = row..String_Length(get_percent(single_hits, single_count), small_col)

    local single_average = tonumber(string.format("%d", single_damage / single_count))
    if single_count == 0 then single_average = 0 end

    row = row..String_Length(Add_Comma(single_average), dmg_col)
    row = row..String_Length(Add_Comma(get_data_single(player_name, focus_skill, action_name, 'min')), dmg_col)
    row = row..String_Length(Add_Comma(get_data_single(player_name, focus_skill, action_name, 'max')), dmg_col)
    table.insert(focus_layout, row)
end