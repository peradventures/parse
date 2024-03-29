Blog_Window,  Blog_Content  = Create_Window(220, 680, 10, nil, 0)
Texts.stroke_width(Blog_Window, 2)
Texts.stroke_color(Blog_Window, 28, 28, 28)
Texts.bold(Blog_Window, true)

Blog = {}
Blog_Length  = 13
Show_Blog    = true

Log_Melee    = false
Log_Ranged   = false
Log_WS       = true
Log_SC       = true
Log_Magic    = true
Log_Abiilty  = false
Log_Pet      = false
Log_Healing  = false
Log_Deaths   = false

Blog_Default_Color = C_White

--[[
    DESCRIPTION:    Refresh the battle log.
]]
function Refresh_Blog()
    if (Show_Blog) then Blog_Window:show() else Blog_Window:hide() end
    Blog_Content.token = Concat_Strings(Blog)
    Blog_Window:update(Blog_Content)
end

--[[
    DESCRIPTION:    Add an entry to battle log.
    PARAMETERS :
        player_name: Name of the player that took the action
        action_name: Name of the action the player took (like a weaponskill or ability)
        damage     : Usually how much damage the action did
        line_color : The color that this line in the battle log should be
        tp_value   : How much TP was used by the weaponskill
]]
function Add_Message_To_Battle_Log(player_name, action_name, damage, line_color, tp_value, action_type, action_data)

    -- If the blog is at max length then we will need to remove the last element
    if Count_Table_Elements(Blog) >= Blog_Length then table.remove(Blog, Blog_Length) end

    -- Message Components
    local player_name = Blog_Name(player_name)
    local damage      = Blog_Damage(damage)
    local action_name = Blog_Action(action_name, action_type, action_data)
    local tp_value    = Blog_TP(tp_value)

    -- Need the space at the beginning to keep the color cut off glitch from happening.
    table.insert(Blog, 1, ' '..tostring(player_name)..' '..tostring(damage)..' '..tostring(action_name)..' '..tostring(tp_value)..Blog_Default_Color)
    
    Refresh_Blog()
end

--[[
    DESCRIPTION:    Format the name component of the battle log.
]]
function Blog_Name(player_name)
    local color = Blog_Default_Color

    if Is_Me(player_name) then color = C_Bright_Green end

    return Format_String(player_name, 9, color)
end

--[[
    DESCRIPTION:    Format the damage component of the battle log.
]]
function Blog_Damage(damage)
    
    -- Damage threshold colors
    local color = Blog_Default_Color

    local damage_string Format_Number(0, 6)
    
    if (not damage) then
        -- Do nothing
    elseif (damage >= 70000) then
        damage_string = Format_Number(damage, 6, C_Bright_Green)
    elseif (damage >= 50000) then
        damage_string = Format_Number(damage, 6, C_Green)
    elseif (damage >= 30000) then
        damage_string = Format_Number(damage, 6, C_Yellow)
    elseif (damage >= 10000) then
        damage_string = Format_Number(damage, 6, C_Orange)
    elseif (damage == 0) then
        damage_string = Format_String(' MISS!', 6, C_Red)
    else
        damage_string = Format_Number(damage, 6)
    end

    return damage_string
end

function Blog_Action(action_name, action_type, action_data)
    local color = C_White

    if (action_type == 'spell') or (action_type == 'ability') or (action_type == 'ws') then

        if (not action_data) then
            Add_Message_To_Chat('W', 'Blog_Action^battle_log', 'action_data is nil for '..action_name)
        end

        color = Elemental_Coloring(action_data)
    end

    -- SC Colors
    -- Ability Colors

    return Format_String(action_name, 15, color)
end

--[[
    DESCRIPTION:    Format the TP string for the battle log.
    PARAMETERS :
        tp_value: How much TP was used by the weaponskill
]]
function Blog_TP(tp_value)
    local color

    if tp_value then
        
        if (tp_value == 3000) then
            color = C_Green

        elseif (tp_value >= 2500) then
            color = C_Yellow

        elseif (tp_value >= 2000) then
            color = C_Orange
        
        end
        
        return '('..Format_Number(tp_value, 5, color, nil, nil, true)..')'
    
    else
        return ''
    
    end

end

--[[
    DESCRIPTION:
]]
function Elemental_Coloring(action_data)
    if (not action_data) then return end

    local color = Elemental_Colors[action_data.element]

    if (not color) then
        Add_Message_To_Chat('W', 'Spell_Coloring^battle_log', 'Unable to map spell coloring for '..action_data.name)
    end

    return color
end

--[[
    DESCRIPTION:
]]
function Set_Log_Show_Defaults()
    Log_Melee    = false
    Log_Ranged   = false
    Log_WS       = true
    Log_SC       = true
    Log_Magic    = true
    Log_Abiilty  = false
    Log_Pet      = false
    Log_Healing  = false
    Log_Deaths   = false
end

--[[
    DESCRIPTION:
]]
function Set_Log_Show_All()
    Log_Melee    = true
    Log_Ranged   = true
    Log_WS       = true
    Log_SC       = true
    Log_Magic    = true
    Log_Abiilty  = true
    Log_Pet      = true
    Log_Healing  = true
    Log_Deaths   = true
end