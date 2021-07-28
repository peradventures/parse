--[[
Copyright © 2020, Amarara of Quetzalcoatl
All rights reserved.
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of React nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Langly BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

_addon.author = 'Amarara'
_addon.version = '1.0.0'
_addon.commands = {'p', 'parse'}

Res     = require('resources')
Texts   = require('texts')
Packets = require('packets')

require('window')
require('magic_numbers')
require('string_formatting')
require('lib')
require('metrics')
require('party')
require('handling')
require('battle_log')
require('display')

Update_Parser()
Update_Blog()

throttle = 10
count = 0

--[[
    DESCRIPTION: The pre-render function will trigger every time the client does a frame refresh.
                 So this function is used to drive many other things that need to be checked consistently across time.
]] 
windower.register_event('prerender', 
function()
    -- Throttling
    count = (count + 1) % throttle
    if count > 0 then return end
    Update_Parser()
    Update_Blog()
end)


--[[
    DESCRIPTION:    Handle the action packet. 
                    Documentation: https://github.com/Windower/Lua/wiki/Action-Event
                    (Documentation gets it right ~97% of the time.)
]] 
windower.register_event('action', 
function(act)
    if not act then return end

    local result, target, log_offense

    -- This is the entity that is performing the action
    local actor = get_entity(act.actor_id)
    if not actor then return end
    
    -- Record all offensive actions from entities in party and alliance
    if actor.is_party or actor.is_alliance then 
        --initialize_check(actor.name, actor.is_npc)
        log_offense = true
    end

    local damage = 0
    
    -- Melee Attack ///////////////////////////////////////////////////////////////////////////////////////////////
    if act.category == 1 then

        for i, v in pairs(act.targets) do
            for n, m in pairs(v.actions) do
                
                result = act.targets[i].actions[n]
                target = get_entity(act.targets[i].id)

                -- Only log damage for party members whether they are NPC or not
                if log_offense then damage = damage + melee_damage(result, actor.name, target.name) end
                
                -- Only log damage taken for party members whether they are NPC or not      -- //////////////////////// IMPLEMENT DEFENSE LATER
                -- if target.is_party or target.is_alliance then
                --     initialize_check(actor.name, actor.is_npc, target.name, true)
                --     handle_defense(result, target.name)                          
                -- end

            end
        end

        if show_melee and not actor.is_npc then Add_Message_To_Battle_Log(entity_name, 'Melee', damage) end

    -- Ranged Attack //////////////////////////////////////////////////////////////////////////////////////////////
    elseif act.category == 2 then

        for i, v in pairs(act.targets) do
            for n, m in pairs(v.actions) do

                result = act.targets[i].actions[n]
                target = get_entity(act.targets[i].id)

                -- Only log damage for party members whether they are NPC or not
                if log_offense then handle_ranged(result, actor.name, target.name) end

            end
        end
        
    -- Finish WS //////////////////////////////////////////////////////////////////////////////////////////////////
    elseif act.category == 3 then 
        local sc_id, sc_name
        local damage     = 0
        local sc_damage  = 0
        local skillchain = false

        -- Only log damage for party members whether they are NPC or not
        if not log_offense then return end
        
        local ws_name = get_ws_name(act)
        if ws_name == 0 then windower.add_to_chat(c_chat, 'Couldn\'t find WS name.') return end

        for i, v in pairs(act.targets) do
            for n, m in pairs(v.actions) do

                result = act.targets[i].actions[n]
                target = get_entity(act.targets[i].id)

                -- Check for skillchains
                local sc_id = result.add_effect_message
                if sc_id > 0 then 
                    skillchain = true
                    sc_name    = skillchains[sc_id]
                    sc_damage  = sc_damage + skillchain_damage(result, actor.name, target.name, sc_name)
                end

                -- Need to calculate WS damage here to account for AOE weaponskills
                damage = damage + weaponskill_damage(result, actor.name, target.name, ws_name)
            end
        end 

        update_data('inc', 1, actor.name, target.name, 'ws', 'count')
        if damage > 0 then
            update_data('inc', 1, actor.name, target.name, 'ws', 'hits')
            update_data_single('inc', 1, actor.name, target.name, 'ws', ws_name, 'hits')
        end

        if not actor.is_npc then 
            Add_Message_To_Battle_Log(actor.name, ws_name, damage, nil, find_party_member_by_name(actor.name, 'tp'))
            if skillchain then Add_Message_To_Battle_Log(actor.name, sc_name, sc_damage, nil, nil) end
        end

    -- Finish Spell Casting ///////////////////////////////////////////////////////////////////////////////////////
    elseif act.category == 4 then

        for i, v in pairs(act.targets) do
            for n, m in pairs(v.actions) do

                result = act.targets[i].actions[n]
                target = get_entity(act.targets[i].id)

                -- Only log damage for party members whether they are NPC or not
                if log_offense then Handle_Spell(act, result, actor.name, target_name) end

                -- Only log damage taken for party members whether they are NPC or not
                -- if target.is_party or target.is_alliance then
                --     initialize_check(actor.name, actor.is_npc, target.name, true)
                --     handle_spell(act, result, target.name)
                -- end

            end
        end 

    -- Finish Item Use ////////////////////////////////////////////////////////////////////////////////////////////
    elseif act.category == 5 then
        -- do nothing

    -- Abilities //////////////////////////////////////////////////////////////////////////////////////////////////
    elseif act.category == 6 then

        --if strat_abils[act.param] and is_me(actor) then use_strat() end ///////////////////////// Count strats used

        if not log_offense then return end

        local ability_name = get_ability_name(act)
        if not ability_name then windower.add_to_chat(c_chat, 'fce: Ability name not found.') return false end
        
        -- Increment the count here to avoid counting for multiple targets.
        --if not inc_single_count(act, actor.name, 'ability', ability_name) then return end

        for i, v in pairs(act.targets) do
            for n, m in pairs(v.actions) do
                result = act.targets[i].actions[n]
                target = get_entity(act.targets[i].id)
                handle_ability(act, result, actor.name, target.name)
            end
        end

    -- Begin WS ///////////////////////////////////////////////////////////////////////////////////////////////////
    elseif act.category == 7 then
        
        target = get_entity(act.targets[1].id)

    -- Begin Spellcasting /////////////////////////////////////////////////////////////////////////////////////////
    elseif act.category == 8 then
        -- Do nothing

    -- Begin item use or interrupt usage //////////////////////////////////////////////////////////////////////////
    elseif act.category == 9 then
        -- do nothing

    -- Finish Monster TP move /////////////////////////////////////////////////////////////////////////////////////
    elseif act.category == 11 then

        -- ///////////////////////////////////////////////////////////// IMPLEMENT THIS LATER
        -- for i, v in pairs(act.targets) do
        --     for n, m in pairs(v.actions) do

        --         result = act.targets[i].actions[n]
        --         target = get_entity(act.targets[i].id)
        --         if not target then return end

        --         if not target.is_party and not target.is_alliance then return end   -- Don't consider non party/alliance members
                    
        --         if not target.is_npc then                                           -- Only track damage taken for PC characters
        --             initialize_check(actor.name, actor.is_npc, target.name, true)
        --             mob_ability(act, result, target.name)
        --         end

        --     end
        -- end

    -- Begin Ranged Attack ////////////////////////////////////////////////////////////////////////////////////////
    elseif act.category == 12 then
        -- do nothing

    -- Pet Ability (SMN/BST) //////////////////////////////////////////////////////////////////////////////////////
    elseif act.category == 13 then

        -- Influenced by flippant parse
        local pet_data = windower.ffxi.get_mob_by_id(act.actor_id)
        local position, member, owner

        -- /////////// Might need to sort over the alliance

        -- Check to see if the pet belongs to anyone in the party.
        for position, member in pairs(windower.ffxi.get_party()) do
            if type(member) == 'table' and member.mob then
                if member.mob.pet_index == pet_data.index then owner = member.mob.name end
            end
        end

        local ability_name = get_ability_name(act)
        if not ability_name then windower.add_to_chat(c_chat, 'fce: Ability name not found.') return false end

        -- Increment the count here to avoid counting for multiple targets.
        --if not inc_single_count(act, owner, 'ability', ability_name) then return end

        for i, v in pairs(act.targets) do
            for n, m in pairs(v.actions) do
                result = act.targets[i].actions[n]
                target = get_entity(act.targets[i].id)
                handle_ability(act, result, owner, target.name)
            end
        end

    -- Unblinkable Job Ability ////////////////////////////////////////////////////////////////////////////////////
    elseif act.category == 14 then

    else
        windower.add_to_chat(c_chat, 'Uncaptured_Category: '..act.category)

    end
end)

--[[
    DESCRIPTION:    Detect loss of buffs.
]] 
windower.register_event('action message',
function (actor_id, target_id, actor_index, target_index, message_id, param_1, param_2, param_3)

    target = get_entity(target_id)

    -- Effect wears off
    if message_id == 206 then
        if target.is_party or target.is_alliance then
            if important_buffs[param_1] then
                --add_message(target.name, '-'..important_buffs[param_1].name, ' ', c_orange)
            end
        end
    end

end)

windower.register_event('addon command', 
function(command, ...)
    if debugging then windower.debug('addon command') end
    local args = {...}

    command = command and command:lower()
    if command then
        if command:lower() == 'load' then -- Do nothing
        
        elseif command:lower() == 'show'     then Toggle_Window_Display(args[1])
        elseif command:lower() == 'reset'    then 
            reset_parser() 

        elseif command:lower() == 'alliance' then show_alliance = not show_alliance

        -- Commands for the Focus window
        elseif command:lower() == 'focus' then
            if     args[1] == nil  then 
                Blog_Type = 'log' 
                windower.add_to_chat(c_chat, 'Switching back to the battle log.')
            elseif args[1]:lower() == 'ws' then
                focus_skill = 'ws'
                windower.add_to_chat(c_chat, 'Focus type set to: Weaponskill')
            elseif args[1]:lower() == 'sc' then
                focus_skill = 'sc'
                windower.add_to_chat(c_chat, 'Focus type set to: Skillchain')
            elseif args[1]:lower() == 'ability' then
                focus_skill = 'ability'
                windower.add_to_chat(c_chat, 'Focus type set to: Ability')
            elseif args[1]:lower() == 'healing' then
                focus_skill = 'healing'
                windower.add_to_chat(c_chat, 'Focus type set to: Healing')
            elseif args[1]:lower() == 'magic' then
                focus_skill = 'magic'
                windower.add_to_chat(c_chat, 'Focus type set to: Magic')
            else 
                Focus_Entity = args[1] 
                Blog_Type = 'focus' 
                windower.add_to_chat(c_chat, 'Focusing on '..tostring(args[1])) 
            end
            Update_Blog()

        -- Set the mob filtering
        elseif command:lower() == 'mob' then
            if      args[1] == nil then Mob_Filter = nil windower.add_to_chat(c_chat, 'Mob filter cleared.')
            else   
                    Mob_Filter = build_arg_string(args) windower.add_to_chat(c_chat, 'Mob filter set to '..Mob_Filter) 
            end

        -- Set the Top # Ranking
        elseif command:lower() == 'top' then
            if      args[1] == nil then 
                top_rank = top_rank_default 
                windower.add_to_chat(c_chat, 'Setting top ranking limit to '..top_rank_default)
            elseif  tonumber(args[1]) == nil then windower.add_to_chat(c_chat, 'Must enter a number.')
            else    top_rank = tonumber(args[1])
            end

        -- Blog functions
        elseif command:lower() == 'log'      then Blog_Type = 'log'     Update_Blog() windower.add_to_chat(c_chat, 'Focus set to log.')
       
        -- Horse Race Formatting Functions
        elseif command:lower() == 'compact'  then Compact_Mode         = not Compact_Mode
        elseif command:lower() == 'crit'     then Show_Crit            = not Show_Crit
        elseif command:lower() == 'acc'      then Show_Total_Acc       = not Show_Total_Acc
        elseif command:lower() == 'sc'       then Include_SC_Damage    = not Include_SC_Damage
        elseif command:lower() == 'percent'  then show_percent         = not show_percent           -- Total Damage Percent
        elseif command:lower() == 'combine'  then combine_damage_types = not combine_damage_types
        elseif command:lower() == 'healing'  then show_healing         = not show_healing

        -- Data functions (Not Implemented)
        elseif command:lower() == 'snapshot' then -- Create a snapshot of the currently held data
        
        else windower.add_to_chat(c_chat, 'Hud command not recognized. Command: '..command) end
    end
end)