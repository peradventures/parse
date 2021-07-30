Blog_Window,  Blog_Content  = build_hud_box(1200,  800, nil, 9, 50)

Blog = {}
Blog_Length  = 15
Show_Blog    = true
Blog_Type    = 'log'
Focus_Entity = 'Amarara'
Blog_Default_Color = c_white
Show_Melee   = false

--[[
    DESCRIPTION:    Refresh the battle log.
]]
function Refresh_Blog()
    if Show_Blog then Blog_Window:show() else Blog_Window:hide() end

    if Blog_Type == 'log' then
        Blog_Content.modestates = concat_strings(Blog)
        Blog_Window:update(Blog_Content)

    else
        focus_player()
        Blog_Content.modestates = concat_strings(focus_layout)
        Blog_Window:update(Blog_Content)
    end
end

--[[
    DESCRIPTION:    Turn the Blog on or off (visually).
]]
function Toggle_Blog()
    Show_Blog  = not Show_Blog  
    Refresh_Blog()
    windower.add_to_chat(c_chat, 'Battle Log visibility is now: ' ..tostring(Show_Blog))
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
function Add_Message_To_Battle_Log(player_name, action_name, damage, line_color, tp_value)
    
    -- If the blog is at max length then we will need to remove the last element
    if Count_Log_Elements() >= Blog_Length then table.remove(Blog, Blog_Length) end

    -- Message Components
    local player_name = Blog_Name(player_name)
    local damage      = Blog_Damage(damage)
    local action_name = Blog_Action(action_name)
    local tp_value    = Blog_TP(tp_value)

    -- Need the space at the beginning to keep the color cut off glitch from happening.
    table.insert(Blog, 1, ' '..player_name..' '..damage..' '..action_name..' '..tp_value..Blog_Default_Color)
    
    Refresh_Blog()
end

--[[
    DESCRIPTION:    Format the name component of the battle log.
]]
function Blog_Name(player_name)
    local color = Blog_Default_Color
    
    if Is_Me(player_name) then color = c_bright_green end

    return Format_String(player_name, 9, color)
end

--[[
    DESCRIPTION:    Format the damage component of the battle log.
]]
function Blog_Damage(damage)
    
    -- Damage threshold colors
    local color = Blog_Default_Color

    local damage_string
    if (damage == 0) then
        damage_string = Format_String('MISS!', 6, c_red)
    else
        damage_string = Format_Number(damage, 6)
    end
    
    return damage_string
end

function Blog_Action(action_name)

    -- SC Colors
    -- Ability Colors
    -- Nuke Colors

    return Format_String(action_name, 15)
end

--[[
    DESCRIPTION:    Format the TP string for the battle log.
    PARAMETERS :
        tp_value: How much TP was used by the weaponskill
]]
function Blog_TP(tp_value)

    -- TP threshold colors

    if tp_value then
        return '('..Format_Number(tp_value, 5, nil, nil, nil, true)..')'
    else
        return ''
    end

end

--[[
    DESCRIPTION:    Count the number of elements in the battle log.
]]
function Count_Log_Elements()
    local count = 0
    
    for i, v in ipairs(Blog) do
        count = count + 1
    end
    
    return count
end