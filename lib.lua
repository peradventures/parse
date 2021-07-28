initialized = {}
offense     = {}

show_melee    = false

--[[
    DESCRIPTION:    Gets some data about who is taking the action.
    PARAMETERS :
        entity_id   ID of the entity.
    RETURNS    :    Table containing discrete data about the entity.
]] 
function get_entity(entity_id) 
    if entity_id == nil then return end

    local entity = windower.ffxi.get_mob_by_id(entity_id)
    if entity == nil then return end

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
    if not player then return false end

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
function get_percent(num, denom)
    if denom == 0 then return 0 end

    local p

    if percent then
        p = (num / denom) * 100
        if p == 0 then return 0
        else return string.format("%5.1f", p) end
    else
        return num..'/'..denom
    end
end

function count_array_elements(array)
    local count = 0
    for _ in pairs(array) do
        count = count + 1
    end
    return count
end

function build_arg_string(args)
    local arg_count = count_array_elements(args)
    local arg_string = ""
    local space = ""
    for i = 1, arg_count, 1 do
        if i == 1 then space = "" else space = " " end
        arg_string = arg_string..space..args[i]
    end
    return arg_string
end

--[[
    DESCRIPTION:    Get the WS name.
    PARAMETERS :    
        act         Action packet
    RETURNS    :    WS name
]] 
function get_ws_name(act)
    local ws = Res.weapon_skills[act.param]

    -- Some weapon skills do not have a node is weapon_skills.lua
    if not ws then ws = ws_filter[act.param] end
    if not ws and show_error then windower.add_to_chat(c_chat, 'get_ws_name: Check '..tostring(act.param)..' in weapon_skills.lua.') return 0 end

    local ws_name = ws.english
    
    -- Some weapon skills do not have a node is weapon_skills.lua
    if ws_name == nil and show_error then windower.add_to_chat(c_chat, 'get_ws_name: '..tostring(ws.id)) ws_name = ws_filter[ws].en end
    if ws_name == nil and show_error then windower.add_to_chat(c_chat, entity_name..'get_ws_name: Check '..tostring(act.param)..' in weapon_skills.lua.') return 0 end

    -- For some reason jumps get treated as weaponskills
    if     ws_name == "Gale Axe" then ws_name = "Jump"              -- 66
    elseif ws_name == "Avalanche Axe" then ws_name = "High Jump"    -- 67
    elseif ws_name == "Spinning Axe" then ws_name = "Super Jump"    -- 68
    end

    return ws_name
end

--[[
    DESCRIPTION:    Get the ability name.
    PARAMETERS :    
        act         Action packet
    RETURNS    :    Ability name
]] 
function get_ability_name(act)
    local ability_id = act.param
    local ability_object = Res.job_abilities[ability_id]
    
    if not ability_object and show_error then windower.add_to_chat(c_chat, 'get_ability_name: Can\'t find ability '..tostring(ability_id)) return nil end
    
    return ability_object.en
end