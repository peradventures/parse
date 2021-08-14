-- ******************************************************************************************************
-- *
-- *                                               Headers
-- *
-- ******************************************************************************************************

--[[
    DESCRIPTION:
]]
function Col_Header_Rank(column_width)
    return 'R   '..String_Length('Name', column_width)
end

--[[
    DESCRIPTION:
]]
function Col_Header_Player_Name(player_name)

end

--[[
    DESCRIPTION:
]]
function Col_Header_Damage_Percent(column_width)
    local damage_percent = ''

    if (Show_Percent) then
        damage_percent = String_Length('T%', column_width, true)
    end

    return damage_percent
end

--[[
    DESCRIPTION:
]]
function Col_Header_Damage_Number(column_width)
    return String_Length('T#', column_width, true)
end

--[[
    DESCRIPTION:
]]
function Col_Header_Accuracy(column_width)
    local accuracy_header = ''

    if (Show_Total_Acc) then
        accuracy_header = String_Length('A-T%', column_width, true)
    else
        accuracy_header = String_Length('A'..tostring(Running_Accuracy_Limit)..'%', column_width, true)
    end

    return accuracy_header
end

--[[
    DESCRIPTION:
    PARAMETERS :
]]
function Col_Header_Melee_Damage(column_width)
    local melee_header = ''

    if (not Total_Damage_Only) then
        melee_header = String_Length('Melee', column_width, true)
    end

    return melee_header
end

--[[
    DESCRIPTION:
    PARAMETERS :
]]
function Col_Header_Crits(column_width)
    local crit_header = ''

    if (Show_Crit) then

        if (Combine_Crit) then

            crit_header = String_Length('Crits', column_width, true)

        else

            crit_header = String_Length('M. Crit', column_width, true)
            crit_header = String_Length('R. Crit', column_width, true)

        end
    end

    return crit_header
end

--[[
    DESCRIPTION:
    PARAMETERS :
]]
function Col_Header_Weaponskill(column_width)
    return String_Length('WS', column_width, true)
end

--[[
    DESCRIPTION:
    PARAMETERS :
]]
function Col_Header_Skillchain(column_width)
    local skillchain_header = ''

    if (Include_SC_Damage) then
        skillchain_header = String_Length('SC', column_width, true)
    end

    return skillchain_header
end

--[[
    DESCRIPTION:
    PARAMETERS :
]]
function Col_Header_Ranged_Damage(column_width)
    local ranged_header = ''

    if (not Total_Damage_Only) then
        ranged_header = String_Length('Ranged', column_width, true)
    end

    return ranged_header
end

--[[
    DESCRIPTION:
    PARAMETERS :
]]
function Col_Header_Magic_Damage(column_width)
    local magic_header = ''

    if (not Total_Damage_Only) then
        magic_header = String_Length('Magic', column_width, true)
    end

    return magic_header
end

--[[
    DESCRIPTION:
    PARAMETERS :
]]
function Col_Header_Job_Ability_Damage(column_width)
    local ability_header = ''

    if (not Total_Damage_Only) then
        ability_header = String_Length('JA', column_width, true)
    end

    return ability_header
end

--[[
    DESCRIPTION:
    PARAMETERS :
]]
function Col_Header_Healing(column_width)
    local healing_header = ''

    if (Show_Healing) then
        healing_header = String_Length('Heals', column_width, true)
    end

    return healing_header
end

--[[
    DESCRIPTION:
    PARAMETERS :
]]
function Col_Header_Deaths(column_width)
    local death_header = ''

    if (Show_Deaths) then
        death_header = String_Length('Deaths', column_width, true)
    end

    return death_header
end

-- ******************************************************************************************************
-- *
-- *                                                 Data
-- *
-- ******************************************************************************************************

--[[
    DESCRIPTION:
    PARAMETERS :
]]
function Col_Rank(rank, player_name, column_width)
    local color

    if Is_Me(player_name) then
        color = C_Bright_Green
    else
        color = C_White
    end

    return color..rank..'.  '..String_Length(player_name, column_width)
end

--[[
    DESCRIPTION:
    PARAMETERS :
]]
function Col_Damage_Percent(grand_total, party_damage, column_width)
    local percent = ''

    if (Show_Percent) then
        percent = Format_Percent(grand_total, party_damage, column_width)
    end

    return percent
end

--[[
    DESCRIPTION:
    PARAMETERS :
]]
function Col_Damage_Number(grand_total, column_width)
    return Format_Number(grand_total, column_width)
end

--[[
    DESCRIPTION:
    PARAMETERS :
]]
function Col_Melee_Accuracy(player_name, melee_attempts, column_width)
    local accuracy = ''

    if (Show_Total_Acc) then
        local hits = Get_Data(player_name, 'melee', 'hits')
        accuracy = Format_Percent(hits, melee_attempts, column_width)
    else
        local accuracy_flow = Tally_Running_Accuracy(player_name, column_width)
        accuracy = accuracy_flow
    end

    return accuracy
end

--[[
    DESCRIPTION:
    PARAMETERS :
]]
function Col_Critical_Rate(player_name, count, column_width)
    local critical_rate = ''

    if (Show_Crit) then

        local melee_crits  = Get_Data(player_name, 'melee', 'crits')
        local ranged_crits = Get_Data(player_name, 'ranged', 'crits')

        if (Combine_Crit) then

            local final_crits = melee_crits + ranged_crits
            critical_rate = Format_Percent(final_crits, count, column_width)

        else

            critical_rate = Format_Percent(melee_crits,  count, column_width)
            critical_rate = Format_Percent(ranged_crits, count, column_width)

        end
    end

    return critical_rate
end

--[[
    DESCRIPTION:
    PARAMETERS :
]]
function Col_Melee_Damage(player_name, column_width)
    local melee_damage = ''

    if (not Total_Damage_Only) then
        local melee_total = Get_Data(player_name, 'melee', 'total')
        melee_damage = Format_Number(melee_total, column_width)
    end

    return melee_damage
end

--[[
    DESCRIPTION:
    PARAMETERS :
]]
function Col_Weaponskill_Damage(player_name, column_width)
    local ws_total = Get_Data(player_name, 'ws', 'total')
    return Format_Number(ws_total, column_width)
end

--[[
    DESCRIPTION:
    PARAMETERS :
]]
function Col_Skillchain_Damage(player_name, column_width)
    local skillchain_damage = ''

    if (Include_SC_Damage) then
        local sc_total = Get_Data(player_name, 'sc', 'total')
        skillchain_damage = Format_Number(sc_total, column_width)
    end

    return skillchain_damage
end

--[[
    DESCRIPTION:
    PARAMETERS :
]]
function Col_Ranged_Damage(player_name, column_width)
    local ranged_damage = ''

    if (not Total_Damage_Only) then
        local range_total = Get_Data(player_name, 'ranged', 'total')
        ranged_damage = Format_Number(range_total, column_width)
    end

    return ranged_damage
end

--[[
    DESCRIPTION:
    PARAMETERS :
]]
function Col_Magic_Damage(player_name, column_width)
    local magic_damage = ''

    if (not Total_Damage_Only) then
        local magic_total = Get_Data(player_name, 'magic', 'total')
        magic_damage = Format_Number(magic_total, column_width)
    end

    return magic_damage
end

--[[
    DESCRIPTION:
    PARAMETERS :
]]
function Col_Ability_Damage(player_name, column_width)
    local ability_damage = ''

    if (not Total_Damage_Only) then
        local ability_total = Get_Data(player_name, 'ability', 'total')
        ability_damage = Format_Number(ability_total, column_width)
    end

    return ability_damage
end

--[[
    DESCRIPTION:
    PARAMETERS :
]]
function Col_Healing_Amount(player_name, column_width)
    local healing_amount = ''

    if (Show_Healing) then
        local healing_total = Get_Data(player_name, 'healing', 'total')
        healing_amount = Format_Number(healing_total, column_width)
    end

    return healing_amount
end

--[[
    DESCRIPTION:
    PARAMETERS :
]]
function Col_Deaths(player_name, column_width)
    local death_count = ''

    if (Show_Deaths) then
        local death_data = Get_Data(player_name, 'death', 'count')
        death_count = Format_Number(death_data, column_width)
    end

    return death_count
end