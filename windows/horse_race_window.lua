Horse_Race_Window = Window:New({
    name       = 'Horse Race',
    message    = 'Horse Race',
    x_pos      = 600,
    y_pos      = 120,
    padding    = 1,
    bg_alpha   = 225,
    bg_red     = 0,
    bg_green   = 0,
    bg_blue    = 15,
    bg_visible = true,
})

Top_Rank_Default = 6

Compact_Mode           = true
Total_Damage_Only      = false
Show_Crit              = false
Show_Pet               = false
Show_Percent           = false
Show_Healing           = false
Show_Deaths            = true
Show_Help_Text         = false
Show_Total_Acc         = false
Combine_Crit           = true
Include_SC_Damage      = false
Accuracy_Show_Attempts = false
Top_Rank               = Top_Rank_Default

------------------------------------------------------------------------------------------------------
-- Refreshes the parser on the screen.
------------------------------------------------------------------------------------------------------
function Refresh_Horse_Race()
    Horse_Race()
    Horse_Race_Window.Update()

    if (Settings.HorseRace.Show) then
        Horse_Race_Window.Show()
    else
        Horse_Race_Window.Hide()
    end
end

--[[
    DESCRIPTION:    Populates horse race parser.
]] 
function Horse_Race()

    Sort_Damage()
    Horse_Race_Header()

    -- Populate the horse race window with data from the top [x] players
    local player_name
    for i, v in ipairs(Total_Damage_Race) do
        player_name = v[1]
        if (i <= Top_Rank) then Horse_Race_Rows(i, player_name) end
    end

    Horse_Race_Help_Text()
end

--[[
    DESCRIPTION:    Builds the header for the horse race window.
]]
function Horse_Race_Header()
    local name_col  = Column_Widths['name']
    local small_col = Column_Widths['small']

    local filter
    if (Mob_Filter) then filter = Mob_Filter else filter = 'All' end
    Horse_Race_Window.Add_Line(' Mob Filter: '..filter)

    local header = ''

    if (Debug) then
        header = header..Col_Header_Basic('PT Dmg')
    end

    header = header..Col_Header_Rank(name_col)
    header = header..Col_Header_Basic('%T', true)
    header = header..Col_Header_Basic('Total')
    header = header..Col_Header_Basic('%A'..tostring(Running_Accuracy_Limit), true)

    if (not Total_Damage_Only) then
        header = header..Col_Header_Basic('T Acc', true)

        header = header..Col_Header_Basic('Melee')
        if (Show_Pet)  then header = header..Col_Header_Basic('Pet M')   end
        if (Show_Crit) then header = header..Col_Header_Crits(small_col) end

        header = header..Col_Header_Basic('WS')
        if (Show_Pet)          then header = header..Col_Header_Basic('Pet WS')   end
        if (Include_SC_Damage) then header = header..Col_Header_Basic('SC') end

        header = header..Col_Header_Basic('Ranged')
        if (Show_Pet)  then header = header..Col_Header_Basic('Pet R')   end

        header = header..Col_Header_Basic('Magic')
        header = header..Col_Header_Basic('JA')
        if (Show_Pet)  then header = header..Col_Header_Basic('Pet A')   end

        if (Show_Healing) then header = header..Col_Header_Basic('Healing')  end
        if (Show_Deaths)  then header = header..Col_Header_Deaths(small_col) end
    end

    Horse_Race_Window.Add_Line(header)
end

--[[
    DESCRIPTION:    	Builds a row for each entity in the horse race parser.
    PARAMETERS :
    	actor			Primary node
    	party_damage 	Total damage from party / alliance
]]
function Horse_Race_Rows(rank, player_name)
    local name_col  = Column_Widths['name']
    local small_col = Column_Widths['small']

    local melee_attempts = Get_Data(player_name, 'melee', 'count')

    local row = ''

    if (Debug) then
        row = row..Col_Debug()
    end

    row = row..Col_Rank(rank, player_name, name_col)
    row = row..Col_Grand_Total(player_name, true)
    row = row..Col_Grand_Total(player_name)
    row = row..Col_Running_Accuracy(player_name, small_col)

    if (not Total_Damage_Only) then
        row = row..Col_Accuracy(player_name, 'combined')

        row = row..Col_Damage(player_name, 'melee')
        if (Show_Pet)  then row = row..Col_Damage(player_name, 'pet_melee') end
        if (Show_Crit) then row = row..Col_Critical_Rate(player_name, melee_attempts, small_col) end

        row = row..Col_Damage(player_name, 'ws')
        if (Show_Pet)          then row = row..Col_Damage(player_name, 'pet_ws') end
        if (Include_SC_Damage) then row = row..Col_Damage(player_name, 'sc') end

        row = row..Col_Damage(player_name, 'ranged')
        if (Show_Pet)  then row = row..Col_Damage(player_name, 'pet_ranged') end

        row = row..Col_Damage(player_name, 'magic')
        row = row..Col_Damage(player_name, 'ability')
        if (Show_Pet)  then row = row..Col_Damage(player_name, 'pet_ability') end

        if (Show_Healing) then row = row..Col_Damage(player_name, 'healing') end
        if (Show_Deaths)  then row = row..Col_Deaths(player_name, small_col) end
    end

    row = row..C_White

    Horse_Race_Window.Add_Line(row)
end

--[[
    DESCRIPTION: Displays what is currently being filtered out and what other settings.
    PARAMETERS :
]]
function Horse_Race_Help_Text()

    if (Show_Help_Text) then
        Horse_Race_Window.Add_Line('')
        Horse_Race_Window.Add_Line('CURRENT FILTERS AND SETTINGS')

        if (not Include_SC_Damage) then
            Horse_Race_Window.Add_Line('-- NO Skillchain Damage.')
        end

        if (not Show_Percent) then
            Horse_Race_Window.Add_Line('-- NO Total Percent.')
        end

        if (not Show_Healing) then
            Horse_Race_Window.Add_Line('-- NO Healing.')
        end

        if (not Show_Deaths) then
            Horse_Race_Window.Add_Line('-- NO Deaths.')
        end

        if (Combine_Crit) then
            Horse_Race_Window.Add_Line('-- Melee and Ranged critical hits are combined.')
        end

        if (Show_Total_Acc) then
            Horse_Race_Window.Add_Line('-- Showing total accuracy for whole duration.')
        end
    end

end