-- ******************************************************************************************************
-- *
-- *                                               Headers
-- *
-- ******************************************************************************************************

--[[
    DESCRIPTION:
]]
function Col_Header_Rank(column_width)
    return ' R   '..String_Length('Name', column_width)
end

--[[
    DESCRIPTION:
]]
function Col_Header_Player_Name(player_name)

end

--[[
    DESCRIPTION:
]]
function Col_Header_Basic(text, percent, color, line_color)

    local column_width

    if (percent) then
        column_width = Column_Widths['percent']
    else
        if (Compact_Mode) then
            column_width = Column_Widths['comp dmg']
        else
            column_width = Column_Widths['dmg']
        end
    end

    return Format_String(text, column_width, color, line_color, true)

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

    return color..' '..rank..'.  '..String_Length(player_name, column_width)
end

--[[
    DESCRIPTION:
    PARAMETERS :
]]
function Col_Grand_Total(player_name, percent)

    local grand_total
    if (Include_SC_Damage) then
        grand_total = Get_Data(player_name, 'total', 'total')
    else
        grand_total = Get_Data(player_name, 'total_no_sc', 'total')
    end

    local color
    if (grand_total == 0) then
        color = C_Gray
    end

    local column_width
    if (percent) then
        column_width = Column_Widths['percent']

        local party = windower.ffxi.get_party()
        if (not party) then return 'ERROR' end
        local party_damage = Total_Party_Damage(party)

        return Format_Percent(grand_total, party_damage, column_width, color)
    else
        if (Compact_Mode) then
            column_width = Column_Widths['comp dmg']
        else
            column_width = Column_Widths['dmg']
        end

        return Format_Number(grand_total, column_width, color)
    end

end

--[[
    DESCRIPTION:
    PARAMETERS :
]]
function Col_Damage(player_name, damage_type, percent)

    local column_width
    local focused_damage = Get_Data(player_name, damage_type, 'total')

    local color
    if (focused_damage == 0) then
        color = C_Gray
    end

    if (percent) then
        column_width = Column_Widths['percent']
        local total_damage = Get_Data(player_name, 'total', 'total')
        return Format_Percent(focused_damage, total_damage, column_width, color)
    else
        if (Compact_Mode) then
            column_width = Column_Widths['comp dmg']
        else
            column_width = Column_Widths['dmg']
        end

        return Format_Number(focused_damage, column_width, color)
    end

end

--[[
    DESCRIPTION:
    PARAMETERS :
        acc_type = melee, ranged, throwing, ws, sc
]]
function Col_Accuracy(player_name, acc_type)

    local column_width
    local hits = Get_Data(player_name, acc_type, 'hits')
    local attempts = Get_Data(player_name, acc_type, 'count')

    if (Accuracy_Show_Attempts) then
        column_width = Column_Widths['dmg']
        return Format_Number(attempts, column_width)
    else
        column_width = Column_Widths['percent']
        return Format_Percent(hits, attempts, column_width)
    end

end

--[[
    DESCRIPTION:
    PARAMETERS :
        damage_type = melee, ranged, throwing
]]
function Col_Crits(player_name, damage_type, percent)

    local column_width
    local crit_damage = Get_Data(player_name, damage_type, 'crit damage')

    if (percent) then
        column_width = Column_Widths['percent']
        local total_damage = Get_Data(player_name, 'total', 'total')
        return Format_Percent(crit_damage, total_damage, column_width)
    else
        if (Compact_Mode) then
            column_width = Column_Widths['comp dmg']
        else
            column_width = Column_Widths['dmg']
        end

        return Format_Number(crit_damage, column_width)
    end

end

--[[
    DESCRIPTION: Accuracy for last X amount of attempts. Includes melee and ranged combined.
    PARAMETERS :
]]
function Col_Running_Accuracy(player_name, column_width)

    return Tally_Running_Accuracy(player_name, column_width)

end

--[[
    DESCRIPTION:
    PARAMETERS :
        metric = total, min, max
]]
function Col_Single_Damage(player_name, action_name, metric, percent)

    local column_width
    local single_damage = Get_Data_Single(player_name, Focus_Skill, action_name, metric)

    if (percent) then
        column_width = Column_Widths['percent']
        local total_damage = Get_Data(player_name, 'total', 'total')
        return Format_Percent(single_damage, total_damage, column_width)
    else
        if (Compact_Mode) then
            column_width = Column_Widths['comp dmg']
        else
            column_width = Column_Widths['dmg']
        end

        return Format_Number(single_damage, column_width)
    end

end

--[[
    DESCRIPTION:
    PARAMETERS :
]]
function Col_Single_Attempts(player_name, action_name)
    local column_width = Column_Widths['single']
    local single_attempts = Get_Data_Single(player_name, Focus_Skill, action_name, 'count')
    return Format_Number(single_attempts, column_width)
end

--[[
    DESCRIPTION:
    PARAMETERS :
]]
function Col_Single_Accuracy(player_name, action_name)
    local column_width = Column_Widths['percent']
    local single_hits  = Get_Data_Single(player_name, Focus_Skill, action_name, 'hits')
    local single_attempts = Get_Data_Single(player_name, Focus_Skill, action_name, 'count')
    return Format_Percent(single_hits, single_attempts, column_width)
end

--[[
    DESCRIPTION:
    PARAMETERS :
]]
function Col_Single_Average_Damage(player_name, action_name)

    local column_width
    if (Compact_Mode) then
        column_width = Column_Widths['comp dmg']
    else
        column_width = Column_Widths['dmg']
    end

    local single_attempts = Get_Data_Single(player_name, Focus_Skill, action_name, 'count')
    if (single_attempts == 0) then
        return Format_Number(0, column_width)
    end

    local single_damage  = Get_Data_Single(player_name, Focus_Skill, action_name, 'total')
    local single_average = tonumber(string.format("%d", single_damage / single_attempts))

    return Format_Number(single_average, column_width)

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
function Col_Deaths(player_name, column_width)
    local death_count = ''

    if (Show_Deaths) then
        local death_data = Get_Data(player_name, 'death', 'count')
        death_count = Format_Number(death_data, column_width)
    end

    return death_count
end