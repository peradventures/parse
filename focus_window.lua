-- Focus window is shared with the battle log. It is initialized in battle_log.lua

Focus_Skill = 'ws'

--[[
    DESCRIPTION: Builds the focus window.
]]
function Focus_Player()
    local player_name = Focus_Entity
    local dmg_col     = Column_Widths['dmg']

    Focus_Layout = {}

    table.insert(Focus_Layout, player_name..' ('..Col_Grand_Total(player_name)..')')
    table.insert(Focus_Layout, '-------------------------------------------------------')

    Focus_Melee(player_name)
    Focus_Ranged(player_name)
    Focus_WS_And_SC(player_name)
    Focus_Magic(player_name)
    Focus_Ability(player_name)
    Focus_Healing(player_name)

    table.insert(Focus_Layout, ' ')

    Single_Data(player_name)
end

--[[
    DESCRIPTION:
    PARAMETERS :
]]
function Focus_Melee(player_name)
    local melee_total = Get_Data(player_name, 'melee', 'total')

    if (melee_total > 0) then

        -- Header
        local melee_header = Col_Header_Basic('Melee')        ..' '..
                             Col_Header_Basic('% Dmg', true)  ..' '..
                             Col_Header_Basic('% Acc', true)  ..' '..
                             Col_Header_Basic('Crit')         ..' '..
                             Col_Header_Basic('% Crit', true)
        table.insert(Focus_Layout, melee_header)

        -- Construct string
        local melee_data = Col_Damage(player_name, 'melee')       ..' '..
                           Col_Damage(player_name, 'melee', true) ..' '..
                           Col_Accuracy(player_name, 'melee')     ..' '..
                           Col_Crits(player_name, 'melee')        ..' '..
                           Col_Crits(player_name, 'melee', true)

        -- Output
        table.insert(Focus_Layout, melee_data)
        table.insert(Focus_Layout, '-------------------------------------------------------')
    end

end

--[[
    DESCRIPTION:
    PARAMETERS :
]]
function Focus_Ranged(player_name)
    local ranged_total       = Get_Data(player_name, 'ranged', 'total')

    if (ranged_total) > 0 then

        -- Header
        local ranged_header = Col_Header_Basic('Ranged')      ..' '..
                              Col_Header_Basic('% Dmg', true) ..' '..
                              Col_Header_Basic('% Acc', true) ..' '..
                              Col_Header_Basic('Crit')        ..' '..
                              Col_Header_Basic('% Crit', true)
        table.insert(Focus_Layout, ranged_header)

        -- Construct string
        local ranged_data = Col_Damage(player_name, 'ranged')       ..' '..
                            Col_Damage(player_name, 'ranged', true) ..' '..
                            Col_Accuracy(player_name, 'ranged')     ..' '..
                            Col_Crits(player_name, 'ranged')        ..' '..
                            Col_Crits(player_name, 'ranged', true)

        -- Output
        table.insert(Focus_Layout, ranged_data)
        table.insert(Focus_Layout, '-------------------------------------------------------')
    end

end

--[[
    DESCRIPTION:
    PARAMETERS :
]]
function Focus_WS_And_SC(player_name)
    local ws_total = Get_Data(player_name, 'ws', 'total')

    if (ws_total > 0) then

        -- Header
        local ws_header = Col_Header_Basic('WS')          ..' '..
                          Col_Header_Basic('% Dmg', true) ..' '..
                          Col_Header_Basic('% Acc', true) ..' '..
                          Col_Header_Basic('SC')          ..' '..
                          Col_Header_Basic('% SC', true)
        table.insert(Focus_Layout, ws_header)

        -- Construct string
        local ws_data = Col_Damage(player_name, 'ws')       ..' '..
                        Col_Damage(player_name, 'ws', true) ..' '..
                        Col_Accuracy(player_name, 'ws')     ..' '..
                        Col_Damage(player_name, 'sc')       ..' '..
                        Col_Damage(player_name, 'sc', true)

        -- Output
        table.insert(Focus_Layout, ws_data)
        table.insert(Focus_Layout, '-------------------------------------------------------')
    end

end

--[[
    DESCRIPTION:
    PARAMETERS :
]]
function Focus_Magic(player_name)
    local magic_total = Get_Data(player_name, 'magic', 'total')

    if (magic_total > 0) then

        -- Header
        local magic_header = Col_Header_Basic('Magic')..' '..
                             Col_Header_Basic('% Dmg', true)
        table.insert(Focus_Layout, magic_header)

        -- Construct string
        local magic_data = Col_Damage(player_name, 'magic')..' '..
                           Col_Damage(player_name, 'magic', true)

        -- Output
        table.insert(Focus_Layout, magic_data)
        table.insert(Focus_Layout, '-------------------------------------------------------')
    end

end

--[[
    DESCRIPTION:
    PARAMETERS :
]]
function Focus_Ability(player_name)
    local ability_total = Get_Data(player_name, 'ability', 'total')

    if (ability_total > 0) then

        -- Header
        local ability_header = Col_Header_Basic('Ability')..' '..
                               Col_Header_Basic('% Dmg', true)
        table.insert(Focus_Layout, ability_header)

        -- Construct string
        local ability_data = Col_Damage(player_name, 'ability')..' '..
                             Col_Damage(player_name, 'ability', true)

        -- Output
        table.insert(Focus_Layout, ability_data)
        table.insert(Focus_Layout, '-------------------------------------------------------')
    end

end

--[[
    DESCRIPTION:
    PARAMETERS :
]]
function Focus_Healing(player_name)
    local healing_total = Get_Data(player_name, 'healing', 'total')

    if (healing_total > 0) then

        -- Header
        local healing_header = Col_Header_Basic('Healing')..' '..
                               Col_Header_Basic('% Tot', true)
        table.insert(Focus_Layout, healing_header)

        -- Construct string
        local healing_data = Col_Damage(player_name, 'healing')..' '..
                             Col_Damage(player_name, 'healing', true)

        -- Output
        table.insert(Focus_Layout, healing_data)
        table.insert(Focus_Layout, '-------------------------------------------------------')
    end

end

--[[
    DESCRIPTION:Builds the focus window.
]]
function Single_Data(player_name)
    if (not Focus_Skill) then Focus_Skill = 'ws' end

    local header
    local name_col   = Column_Widths['name']
    local dmg_col    = Column_Widths['dmg']
    local single_col = Column_Widths['single']
    local small_col  = Column_Widths['small']

    -- Header
    header = String_Length('Name', name_col)
    header = header..Col_Header_Basic('Total')
    header = header..String_Length(' ###', single_col)
    header = header..Col_Header_Basic('Acc', true)
    header = header..Col_Header_Basic('Avg')
    header = header..Col_Header_Basic('Min')
    header = header..Col_Header_Basic('Max')
    table.insert(Focus_Layout, header)

    -- Error Protection
    if (not Skill_Data[Focus_Skill]) then return end
    if (not Skill_Data[Focus_Skill][player_name]) then return end

    Sort_Single_Damage(player_name)

    local action_name
    for _, data in ipairs(Single_Damage_Race) do
        action_name = data[1]
        Single_Row(player_name, action_name)
    end

end

--[[
    DESCRIPTION:
    PARAMETERS :
]]
function Single_Row(player_name, action_name)
    local name_col   = Column_Widths['name']

    local row = String_Length(action_name, name_col)
    row = row..Col_Single_Damage(player_name, action_name, 'total')
    row = row..Col_Single_Attempts(player_name, action_name)
    row = row..Col_Single_Accuracy(player_name, action_name)
    row = row..Col_Single_Average_Damage(player_name, action_name)
    row = row..Col_Single_Damage(player_name, action_name, 'min')
    row = row..Col_Single_Damage(player_name, action_name, 'max')

    table.insert(Focus_Layout, row)
end