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
require('focus_window')
require('horse_race_window')
require('packet_handling')

Mob_Filter = nil
Refresh_Horse_Race()
Refresh_Blog()

Window_Refresh_Throttling = 10
Window_Refresh_Count = 0

--[[
    DESCRIPTION:    The pre-render function will trigger every time the client does a frame refresh.
                    This function is throttled to improve performance. 
]] 
windower.register_event('prerender', 
function()
    Window_Refresh_Count = (Window_Refresh_Count + 1) % Window_Refresh_Throttling
    
    if Window_Refresh_Count > 0 then return end
    
    Refresh_Horse_Race()
    Refresh_Blog()
end)

--[[
    DESCRIPTION:    Handle the action packet. 
                    Documentation: https://github.com/Windower/Lua/wiki/Action-Event
                    (Documentation gets it right ~97% of the time.)
]] 
windower.register_event('action', 
function(act)
    if not act then return end

    -- This is the entity that is performing the action. It could be a player, mob, or NPC.
    local actor = Get_Entity_Data(act.actor_id)
    if not actor then return end
    
    -- Record all offensive actions from players in party or alliance
    local log_offense = actor.is_party or actor.is_alliance
    
    if     act.category ==  1 then Melee_Attack(act, actor, log_offense)
    elseif act.category ==  2 then Ranged_Attack(act, actor, log_offense)
    elseif act.category ==  3 then Finish_WS(act, actor, log_offense)
    elseif act.category ==  4 then Finish_Spell_Casting(act, actor, log_offense)
    elseif act.category ==  5 then -- Do nothing (Finish Item Use)
    elseif act.category ==  6 then Job_Ability(act, actor, log_offense)
    elseif act.category ==  7 then -- Do nothing (Begin WS)
    elseif act.category ==  8 then -- Do nothing (Begin Spellcasting)
    elseif act.category ==  9 then -- Do nothing (Begin or Interrupt Item Usage)
    elseif act.category == 11 then -- Do nothing (Finish Monster TP Move)
    elseif act.category == 12 then -- Do nothing (Begin Ranged Attack)
    elseif act.category == 13 then Pet_Ability(act, actor, log_offense)
    elseif act.category == 14 then -- Do nothing (Unblinkable Job Ability)
    else   windower.add_to_chat(c_chat, 'Uncaptured_Category: '..act.category) 
    end

end)

--[[
    DESCRIPTION:    Detect loss of buffs.
]] 
windower.register_event('action message',
function (actor_id, target_id, actor_index, target_index, message_id, param_1, param_2, param_3)

    target = Get_Entity_Data(target_id)

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
        
        -- Turn windows on or off
        elseif command:lower() == 'show' then
            
            if args[1]:lower() == 'blog' then
                Toggle_Blog()
            elseif args[1]:lower() == 'horse' then
                Toggle_Horse_Race()
            elseif args[1]:lower() == 'error' then
                Show_Error = not Show_Error
                windower.add_to_chat(c_chat, 'PARSE: Show_Error is now '..Show_Error)
            elseif args[1]:lower() == 'warning' then
                Show_Warning = not Show_Warning
                windower.add_to_chat(c_chat, 'PARSE: Show_Warning is now '..Show_Warning)
            else
                windower.add_to_chat(c_chat, 'PARSE: '..tostring(args[1])..' is an unknown window and cannot be toggled.')
            end
        
        -- Reset the parser
        elseif command:lower() == 'reset' then
            reset_parser()

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
            Refresh_Blog()

        -- Set the mob filtering
        elseif command:lower() == 'mob' then
            if      args[1] == nil then Mob_Filter = nil windower.add_to_chat(c_chat, 'Mob filter cleared.')
            else   
                    Mob_Filter = build_arg_string(args) windower.add_to_chat(c_chat, 'Mob filter set to '..Mob_Filter) 
            end

        -- Set the Top # Ranking
        elseif command:lower() == 'top' then
            if      args[1] == nil then 
                Top_Rank = Top_Rank_Default 
                windower.add_to_chat(c_chat, 'Setting top ranking limit to '..Top_Rank_Default)
            elseif  tonumber(args[1]) == nil then windower.add_to_chat(c_chat, 'Must enter a number.')
            else    Top_Rank = tonumber(args[1])
            end

        -- Blog functions
        elseif command:lower() == 'log'      then Blog_Type = 'log'     Refresh_Blog() windower.add_to_chat(c_chat, 'Focus set to log.')
       
        -- Horse Race Formatting Functions
        elseif command:lower() == 'melee'    then Show_Melee           = not Show_Melee
        elseif command:lower() == 'compact'  then Compact_Mode         = not Compact_Mode
        elseif command:lower() == 'crit'     then Show_Crit            = not Show_Crit
        elseif command:lower() == 'acc'      then Show_Total_Acc       = not Show_Total_Acc
        elseif command:lower() == 'sc'       then Include_SC_Damage    = not Include_SC_Damage
        elseif command:lower() == 'percent'  then Show_Percent         = not Show_Percent           -- Total Damage Percent
        elseif command:lower() == 'combine'  then Combine_Damage_Types = not Combine_Damage_Types
        elseif command:lower() == 'healing'  then Show_Healing         = not Show_Healing

        -- Data functions (Not Implemented)
        elseif command:lower() == 'snapshot' then -- Create a snapshot of the currently held data
        
        else windower.add_to_chat(c_chat, 'Hud command not recognized. Command: '..command) end
    end
end)