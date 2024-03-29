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
DISCLAIMED. IN NO EVENT SHALL --Amarara-- BE LIABLE FOR ANY
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

-- Debugging
LUA_Name = 'PARSE'

require('data.settings')

require('magic_numbers')
require('debug_tools')
require('string_lib')
require('lib')
require('csv_log')
require('metrics')
require('party')
require('handling')
require('packet_handling')
require('commands')

-- Windows
require('windows._class_screen_item')
require('window')
require('windows.columns')
require('windows.battle_log')
require('windows.horse_race_window')
require('windows.focus_window')
require('windows.window_toggles')

-- Monster specific damage filter
Mob_Filter = nil

--[[
    DESCRIPTION:    The pre-render function will trigger every time the client does a frame refresh.
                    This function is throttled to improve performance. 
]]
windower.register_event('prerender',
function()
    if (Log_CSV) and (Log_Ticks) then CSV_Tick() end
    Window_Refresh_Count = (Window_Refresh_Count + 1) % Settings.Performance.Throttling

    if (Window_Refresh_Count > 0) then return end

    Refresh_Horse_Race()
    Refresh_Blog()
    Refresh_Focus_Window()
end)

-- Record all offensive actions from players or pets in party or alliance

--[[
    DESCRIPTION:    Handle the action packet. 
                    Documentation: https://github.com/Windower/Lua/wiki/Action-Event
                    (Documentation gets it right ~97% of the time.)
]]
windower.register_event('action',
function(act)
    if (not act) then return end

    local actor_mob = windower.ffxi.get_mob_by_id(act.actor_id)
    if (not actor_mob) then return end

    local owner_mob = Pet_Owner(act)
    local log_offense = owner_mob or actor_mob.in_party or actor_mob.in_alliance

    if     (act.category ==  1) then Melee_Attack(act, actor_mob, log_offense)
    elseif (act.category ==  2) then Ranged_Attack(act, actor_mob, log_offense)
    elseif (act.category ==  3) then Finish_WS(act, actor_mob, log_offense)
    elseif (act.category ==  4) then Finish_Spell_Casting(act, actor_mob, log_offense)
    elseif (act.category ==  5) then -- Do nothing (Finish Item Use)
    elseif (act.category ==  6) then Job_Ability(act, actor_mob, log_offense)
    elseif (act.category ==  7) then -- Do nothing (Begin WS)
    elseif (act.category ==  8) then -- Do nothing (Begin Spellcasting)
    elseif (act.category ==  9) then -- Do nothing (Begin or Interrupt Item Usage)
    elseif (act.category == 11) then Finish_Monster_TP_Move(act, actor_mob, log_offense)
    elseif (act.category == 12) then -- Do nothing (Begin Ranged Attack)
    elseif (act.category == 13) then Pet_Ability(act, actor_mob, log_offense)
    elseif (act.category == 14) then -- Do nothing (Unblinkable Job Ability)
    else
        Add_Message_To_Chat('W', ' Action Event^parse', 'Uncaptured_Category: '..act.category)
    end

end)

--[[
    DESCRIPTION:    Detect loss of buffs.
]] 
windower.register_event('action message',
function (actor_id, target_id, actor_index, target_index, message_id, param_1, param_2, param_3)

    local target = windower.ffxi.get_mob_by_id(target_id)
    if (not target) then return end

    -- Effect wears off
    if (message_id == 206) then
        if (target.in_party or target.in_alliance) then
            if Important_Buffs[param_1] then
                --add_message(target.name, '-'..important_buffs[param_1].name, ' ', c_orange)
            end
        end

    elseif (message_id == 97) then
        Player_Death(actor_id, target_id)

    else
        --Add_Message_To_Chat('W', 'action message^parse', 'Action Message: '..tostring(message_id))

    end

end)

windower.register_event('addon command',
function(command, ...)
    local args = {...}

    command = command and command:lower()
    if (command) then
        if command:lower() == 'load' then -- Do nothing

        -- Turn windows on or off
        elseif (command:lower() == 'show') or (command:lower() == 'hide') then Toggle_Window(args)

        -- Determine what shows up in the battle log
        elseif (command:lower() == 'log') then Set_Battle_Log_Filters(args)

        -- Reset the parser
        elseif (command:lower() == 'reset') then Reset_Parser()

        -- Commands for the Focus window
        elseif (command:lower() == 'focus') then Focus_Target(args)

        -- Set the mob filtering
        elseif (command:lower() == 'mob') then Set_Mob_Filter(args)

        -- Set the Top # Ranking
        elseif (command:lower() == 'top') then Set_Horse_Race_Display_Limit(args)

        -- Data functions (Not Implemented)
        elseif (command:lower() == 'snapshot') then -- Create a snapshot of the currently held data

        else
            Toggle_Formatting_Config(command)
        end

    end
end)