Blog = {}
Blog_Length  = 15
Show_Blog    = true
Blog_Type    = 'log'
Focus_Entity = 'Amarara'

--[[
    DESCRIPTION:    Update the battle log.
]] 
function Update_Blog()
    if Show_Blog then blog_box:show() else blog_box:hide() end

    if Blog_Type == 'log' then
        blog_content.modestates = concat_strings(Blog)
        blog_box:update(blog_content)

    else
        focus_player()
        blog_content.modestates = concat_strings(focus_layout)
        blog_box:update(blog_content)
    end
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
    
    line_color = Message_Line_Color(line_color, player_name)
    
    -- If the blog is at max length then we will need to remove the last element
    if Count_Log_Elements() >= Blog_Length then table.remove(Blog, Blog_Length) end

    -- Message Components
    local player_name = String_Length(player_name, 9)
    local damage      = Format_Number(damage, 6)
    local action_name = String_Length(action_name, 15)
    local tp_value    = Message_TP_String(tp_value)

    -- Need the space at the beginning to keep the color cut off glitch from happening.
    table.insert(Blog, 1, ' '..line_color..player_name..' '..damage..' '..action_name..' '..tp_value..c_white)
    
    Update_Blog()
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

--[[
    DESCRIPTION:    Sets the color of the entire message line.
]]
function Message_Line_Color(line_color, player_name)
    
    if not line_color then
        if Is_Me(player_name) then
            return c_bright_green
        else
            return c_white
        end
    else
        return line_color
    end

end

--[[
    DESCRIPTION:    Format the TP string for the battle log.
    PARAMETERS :
        tp_value: How much TP was used by the weaponskill
]]
function Message_TP_String(tp_value)
    
    if tp_value then
        return '('..Format_Number(tp_value, 5)..')'
    else
        return ''
    end

end