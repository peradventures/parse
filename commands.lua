-- ******************************************************************************************************
-- *
-- *                                              Toggles
-- *
-- ******************************************************************************************************

--[[
    DESCRIPTION:
]]
function Toggle_Window(args)

    if (args[1]:lower() == 'blog') then
        Show_Blog  = not Show_Blog
        Refresh_Blog()
        Add_Message_To_Chat('A', 'Toggle_Window^commands', 'Battle Log visibility is now: ' ..tostring(Show_Blog))

    elseif (args[1]:lower() == 'error') then
        Show_Error = not Show_Error
        Add_Message_To_Chat('A', 'Toggle_Window^commands', 'Show_Error is now '..tostring(Show_Error))

    elseif (args[1]:lower() == 'warning') then
        Show_Warning = not Show_Warning
        Add_Message_To_Chat('A', 'Toggle_Window^commands', 'Show_Warning is now '..tostring(Show_Warning))

    else
        Add_Message_To_Chat('A', 'Toggle_Window^commands', tostring(args)..' is an unknown window and cannot be toggled.')

    end

end

function Toggle_Formatting_Config(command)

    if     (command:lower() == 'total')      then Total_Damage_Only = not Total_Damage_Only
    elseif (command:lower() == 'compact')    then Compact_Mode      = not Compact_Mode
    elseif (command:lower() == 'melee')      then Log_Melee        = not Log_Melee            -- Adds melee attacks to battle log
    elseif (command:lower() == 'crits')      then Show_Crit         = not Show_Crit
    elseif (command:lower() == 'acc')        then Show_Total_Acc    = not Show_Total_Acc
    elseif (command:lower() == 'sc')         then Include_SC_Damage = not Include_SC_Damage
    elseif (command:lower() == 'pet')        then Show_Pet          = not Show_Pet
    elseif (command:lower() == 'healing')    then Show_Healing      = not Show_Healing
    elseif (command:lower() == 'deaths')     then Show_Deaths       = not Show_Deaths
    elseif (command:lower() == 'percent')    then Show_Percent      = not Show_Percent           -- Total Damage Percent
    elseif (command:lower() == 'helptext')   then Show_Help_Text    = not Show_Help_Text

    elseif (command:lower() == 'screenshot') then
        Show_Crit = true
        Include_SC_Damage = true
        Compact_Mode = false
        Show_Percent = true
        Show_Deaths = true
        Show_Help_Text = true

    elseif (command:lower() == 'parse') then
        Show_Crit = false
        Include_SC_Damage = false
        Compact_Mode = true
        Show_Percent = false

    else
        Add_Message_To_Chat('A', 'Addon Command^parse', 'Hud command not recognized. Command: '..command)

    end

end


-- ******************************************************************************************************
-- *
-- *                                          Universal Settings
-- *
-- ******************************************************************************************************

function Set_Mob_Filter(args)

    if (args[1] == nil) then
        Mob_Filter = nil
        Add_Message_To_Chat('A', 'Set_Mob_Filter^commands', 'Mob filter cleared.')

    else
        Mob_Filter = Build_Arg_String(args)
        Add_Message_To_Chat('A', 'Set_Mob_Filter^commands', 'Mob filter set to '..Mob_Filter)

    end

end

-- ******************************************************************************************************
-- *
-- *                                          Horse Race Window
-- *
-- ******************************************************************************************************

function Set_Horse_Race_Display_Limit(args)

    if (args[1] == nil) then
        Top_Rank = Top_Rank_Default
        Add_Message_To_Chat('A', 'Set_Horse_Race_Display_Limit^commands', 'Setting top ranking limit to the default: '..tostring(Top_Rank_Default))

    else
        Top_Rank = tonumber(args[1])
        Add_Message_To_Chat('A', 'Set_Horse_Race_Display_Limit^commands', 'Setting top ranking limit to: '..args[1])

    end
end

-- ******************************************************************************************************
-- *
-- *                                            Focus Window
-- *
-- ******************************************************************************************************

function Focus_Target(args)

    if (args[1]:lower() == 'ws') then
        Focused_Trackable = 'ws'
        Add_Message_To_Chat('A', 'Focus_Target^commands', 'Focus type set to: Weaponskill')

    elseif (args[1]:lower() == 'sc') then
        Focused_Trackable = 'sc'
        Add_Message_To_Chat('A', 'Focus_Target^commands', 'Focus type set to: Skillchain')

    elseif (args[1]:lower() == 'ability') then
        Focused_Trackable = 'ability'
        Add_Message_To_Chat('A', 'Focus_Target^commands', 'Focus type set to: Ability')

    elseif (args[1]:lower() == 'healing') then
        Focused_Trackable = 'healing'
        Add_Message_To_Chat('A', 'Focus_Target^commands', 'Focus type set to: Healing')

    elseif (args[1]:lower() == 'magic') then
        Focused_Trackable = 'magic'
        Add_Message_To_Chat('A', 'Focus_Target^commands', 'Focus type set to: Magic')

    -- Focus on a player
    else
        Focused_Entity = args[1]
        Add_Message_To_Chat('A', 'Focus_Target^commands', 'Focusing on '..tostring(args[1]))

    end

    Refresh_Focus_Window()

end

-- ******************************************************************************************************
-- *
-- *                                             Battle Log
-- *
-- ******************************************************************************************************

function Set_Battle_Log_Filters(args)

    if (args[1]:lower() == 'melee') then
        Log_Melee = not Log_Melee
        Add_Message_To_Chat('A', 'Focus_Target^commands', 'Battle Log will show melee: '..tostring(Log_Melee))

    elseif (args[1]:lower() == 'ranged') then
        Log_Ranged = not Log_Ranged
        Add_Message_To_Chat('A', 'Focus_Target^commands', 'Battle Log will show ranged: '..tostring(Log_Melee))

    elseif (args[1]:lower() == 'ws') then
        Log_WS = not Log_WS
        Add_Message_To_Chat('A', 'Focus_Target^commands', 'Battle Log will show weaponskills: '..tostring(Log_Melee))

    elseif (args[1]:lower() == 'sc') then
        Log_SC = not Log_SC
        Add_Message_To_Chat('A', 'Focus_Target^commands', 'Battle Log will show skillchains: '..tostring(Log_Melee))

    elseif (args[1]:lower() == 'magic') then
        Log_Magic = not Log_Magic
        Add_Message_To_Chat('A', 'Focus_Target^commands', 'Battle Log will show magic: '..tostring(Log_Melee))

    elseif (args[1]:lower() == 'ability') then
        Log_Abiilty = not Log_Abiilty
        Add_Message_To_Chat('A', 'Focus_Target^commands', 'Battle Log will show ability: '..tostring(Log_Melee))

    elseif (args[1]:lower() == 'pet') then
        Log_Pet = not Log_Pet
        Add_Message_To_Chat('A', 'Focus_Target^commands', 'Battle Log will show pet actions: '..tostring(Log_Melee))

    elseif (args[1]:lower() == 'all') then
        Set_Log_Show_All()
        Add_Message_To_Chat('A', 'Focus_Target^commands', 'Battle Log will show all actions.')

    elseif (args[1]:lower() == 'reset') then
        Set_Log_Show_Defaults()
        Add_Message_To_Chat('A', 'Focus_Target^commands', 'Battle Log will show default actions.')

    -- Focus on a player
    else
        Focused_Entity = args[1]
        Add_Message_To_Chat('A', 'Focus_Target^commands', 'Focusing on '..tostring(args[1]))

    end

    Refresh_Focus_Window()

end
