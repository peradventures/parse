Errors_Suppressed = 0
Warnings_Suppressed = 0

Column_Widths = {
    ['name']   = 15,
    ['dmg']    = 11,
    ['small']  = 8,
    ['single'] = 4
}

Column_Widths_Compact = {
    ['name']   = 10,
    ['dmg']    = 8,
    ['small']  = 8,
    ['single'] = 4
}

--[[
    DESCRIPTION:    Gets some data about who is taking the action.
    PARAMETERS :
        entity_id   ID of the entity.
    RETURNS    :    Table containing discrete data about the entity.
]] 
function Get_Entity_Data(entity_id)
    if (entity_id == nil) then return end

    local entity = windower.ffxi.get_mob_by_id(entity_id)
    if (entity == nil) then return end

    local entity_data = {}
    entity_data['name']        = entity.name
    entity_data['is_npc']      = entity.is_npc
    entity_data['is_party']    = entity.in_party
    entity_data['is_alliance'] = entity.in_alliance
    entity_data['mob_type']    = entity.entity_type
    entity_data['spawn_type']  = entity.spawn_type

    return entity_data
end

--[[
    DESCRIPTION:    Checks to see if a given string matches your character's name.
    PARAMETERS :
        string      Entity data array
    RETURNS    :    TRUE: This is you; FALSE: This is not you
]] 
function Is_Me(string)
    local player = windower.ffxi.get_player()
    
    -- Run-time error prevention
    if (not player) then return false end

    local match = false
    if (player.name == string) then match = true end

    return match
end

--[[
    DESCRIPTION:    Calculates a percent
    PARAMETERS :
        num         Numerator
        denom       Denominator
    RETURNS    :    Percent with a format of ###.#
    ASSUMES    : 
        percent     Toggled via command.
]] 
function Format_Percent(num, denom)
    
    if (denom == 0) then return 0 end

    local p = (num / denom) * 100
    
    if (p == 0) then 
        return 0
    else
        return string.format("%5.1f", p)
    end

end

--[[
    DESCRIPTION:
    PARAMETERS :
]] 
function Build_Arg_String(args)
    local arg_count = Count_Table_Elements(args)
    local arg_string = ""
    local space = ""
    
    for i = 1, arg_count, 1 do
        if (i == 1) then space = "" else space = " " end
        arg_string = arg_string..space..args[i]
    end
    
    return arg_string
end

--[[
    DESCRIPTION:    Get the weaponskill name.
    PARAMETERS :
        act         Action packet
]] 
function Get_WS_Name(act)
    local ws = Res.weapon_skills[act.param]

    -- Check to see if weaponskill exists in weapon_skills.lua; If it doesn't then fall back to WS_Filter
    if (not ws) then
        ws = WS_Filter[act.param]
    end
    
    -- If WS_Filter didn't have it either then we need to throw an error.
    if (not ws) and (Show_Error) then 
        Add_Message_To_Chat('E', 'PARSE: Get_WS_Name^lib')
        Add_Message_To_Chat('E', 'Add WS ID'..tostring(act.param)..' to WS_Filter.')
        return 0
    end

    local ws_name = ws.english
    
    -- If we don't have a weaponskill name at this point then something is messed up.
    if (ws_name == nil) and (Show_Error) then 
        Add_Message_To_Chat('E', 'PARSE: Get_WS_Name^lib')
        Add_Message_To_Chat('E', tostring(ws.id)..' needs a name in weapon_skills.lua or WS_Filter.')
        return 0
    end

    -- For some reason jumps get treated as weaponskills
    if     (ws_name == "Gale Axe")      then ws_name = "Jump"         -- 66
    elseif (ws_name == "Avalanche Axe") then ws_name = "High Jump"    -- 67
    elseif (ws_name == "Spinning Axe")  then ws_name = "Super Jump"   -- 68
    end

    return ws_name
end

--[[
    DESCRIPTION:    Get the ability name from the Windower job_abilities resource file.
    PARAMETERS :
        act         Action packet
]] 
function Get_Ability_Name(act)
    local ability_id = act.param
    local ability_object = Res.job_abilities[ability_id]
    
    if (not ability_object) and (Show_Error) then
        Add_Message_To_Chat('E', 'PARSE | Get_Ability_Name^lib')
        Add_Message_To_Chat('E', 'Can\'t find ability '..tostring(ability_id)) 
        return nil
    end
    
    return ability_object.en
end

-- message_string needs to be formatted to string ahead of time.
function Add_Message_To_Chat(message_type, message_string)
    local show_message = true

    -- Error
    if (message_type:lower() == 'e') then
        
        if (not Show_Error) then
            show_message = false
            Errors_Suppressed = Errors_Suppressed + 1
        end

    -- Warning
    elseif (message_type:lower() == 'w') then
        
        if (not Show_Warning) then
            show_message = false
            Warnings_Suppressed = Warnings_Suppressed + 1
        end

    end

    if show_message then windower.add_to_chat(C_Chat, message_string) end
end

--[[
    DESCRIPTION:    Count the number of elements in the battle log.
]]
function Count_Table_Elements(table)
    local count = 0
    
    for i, v in ipairs(table) do
        count = count + 1
    end
    
    return count
end