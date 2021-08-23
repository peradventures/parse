Horse_Race_Window, Horse_Race_Content = Create_Window(1050, 850, 11, nil, 0)
Texts.stroke_width(Horse_Race_Window, 3)

Show_Horse           = true
Compact_Mode         = true
Show_Crit            = false
Combine_Crit         = true
Show_Total_Acc       = false
Include_SC_Damage    = false
Show_Percent         = false
Total_Damage_Only    = false
Show_Healing         = false
Show_Deaths          = true
Show_Help_Text       = false
Top_Rank_Default     = 6
Top_Rank             = Top_Rank_Default

--[[
    DESCRIPTION:    Refreshes the parser on the screen.
]] 
function Refresh_Horse_Race()
    Horse_Race()
    Horse_Race_Window:update(Horse_Race_Content)

    local info = windower.ffxi.get_info()

    if (Show_Horse) then Horse_Race_Window:show() else Horse_Race_Window:hide() end          
end

--[[
    DESCRIPTION:    Turn the Horse Race on or off (visually).
]]
function Toggle_Horse_Race()
    Show_Horse = not Show_Horse
    Refresh_Horse_Race() 
    Add_Message_To_Chat('A', 'Toggle_Horse_Race^horse_race_window', 'Horse Race visibility is now: '..tostring(Show_Horse))
end

--[[
    DESCRIPTION:    Populates horse race parser.
]] 
function Horse_Race()
    local party = windower.ffxi.get_party()
    if (not party) then return end

    -- Populate Total_Damage_Race to put the highest damage on top
    Sort_Damage()

    -- Iniitialize the horse race window. It will be blank until someone does damage
    Horse_Race_Data = {}
    Horse_Race_Header()

    -- Populate the horse race window with data from the top [x] players
    local party_damage = Total_Party_Damage(party)
    local player_name
    for i, v in ipairs(Total_Damage_Race) do
        player_name = v[1]
        if (i <= Top_Rank) then Horse_Race_Rows(i, player_name, party_damage) end
    end

    Horse_Race_Help_Text()

    Horse_Race_Content.token = Concat_Strings(Horse_Race_Data)
end

--[[
    DESCRIPTION:    Builds the header for the horse race window.
]]
function Horse_Race_Header()

    local cols
    if (Compact_Mode) then
        cols = Column_Widths_Compact
    else
        cols = Column_Widths
    end

    local name_col  = cols['name']
    local dmg_col   = cols['dmg']
    local small_col = cols['small']

    local filter
    if (Mob_Filter) then filter = Mob_Filter else filter = 'All' end
    table.insert(Horse_Race_Data, ' Mob Filter: '..filter)

    local header = ''
    header = header..Col_Header_Rank(name_col)
    header = header..Col_Header_Damage_Percent(small_col)
    header = header..Col_Header_Damage_Number(dmg_col)
    header = header..Col_Header_Melee_Damage(dmg_col)
    header = header..Col_Header_Accuracy(small_col)
    header = header..Col_Header_Crits(small_col)
    header = header..Col_Header_Weaponskill(dmg_col)
    header = header..Col_Header_Skillchain(dmg_col)
    header = header..Col_Header_Ranged_Damage(dmg_col)
    header = header..Col_Header_Magic_Damage(dmg_col)
    header = header..Col_Header_Job_Ability_Damage(dmg_col)
    header = header..Col_Header_Healing(dmg_col)
    header = header..Col_Header_Deaths(small_col)

    table.insert(Horse_Race_Data, header)
end

--[[
    DESCRIPTION:    	Builds a row for each entity in the horse race parser.
    PARAMETERS :
    	actor			Primary node
    	party_damage 	Total damage from party / alliance
]]
function Horse_Race_Rows(rank, player_name, party_damage)
    local cols

    if (Compact_Mode) then
        cols = Column_Widths_Compact
    else
        cols = Column_Widths
    end

    local name_col  = cols['name']
    local dmg_col   = cols['dmg']
    local small_col = cols['small']

    local grand_total
    if (Include_SC_Damage) then
        grand_total = Get_Data(player_name, 'total', 'total')
    else
        grand_total = Get_Data(player_name, 'total_no_sc', 'total')
    end

    local melee_attempts = Get_Data(player_name, 'melee', 'count')

    local row = ''
    row = row..Col_Rank(rank, player_name, name_col)
    row = row..Col_Damage_Percent(grand_total, party_damage, small_col)
    row = row..Col_Damage_Number(grand_total, dmg_col)
    row = row..Col_Melee_Damage(player_name, dmg_col)
    row = row..Col_Melee_Accuracy(player_name, melee_attempts, small_col)
    row = row..Col_Critical_Rate(player_name, melee_attempts, small_col)
    row = row..Col_Weaponskill_Damage(player_name, dmg_col)
    row = row..Col_Skillchain_Damage(player_name, dmg_col)
    row = row..Col_Ranged_Damage(player_name, dmg_col)
    row = row..Col_Magic_Damage(player_name, dmg_col)
    row = row..Col_Ability_Damage(player_name, dmg_col)
    row = row..Col_Healing_Amount(player_name, dmg_col)
    row = row..Col_Deaths(player_name, small_col)
    row = row..C_White

    table.insert(Horse_Race_Data, row)
end

--[[
    DESCRIPTION: Displays what is currently being filtered out and what other settings.
    PARAMETERS :
]]
function Horse_Race_Help_Text()

    if (Show_Help_Text) then
        table.insert(Horse_Race_Data, '')
        table.insert(Horse_Race_Data, 'CURRENT FILTERS AND SETTINGS')

        if (not Include_SC_Damage) then
            table.insert(Horse_Race_Data, '-- NO Skillchain Damage.')
        end

        if (not Show_Percent) then
            table.insert(Horse_Race_Data, '-- NO Total Percent.')
        end

        if (not Show_Healing) then
            table.insert(Horse_Race_Data, '-- NO Healing.')
        end

        if (not Show_Deaths) then
            table.insert(Horse_Race_Data, '-- NO Deaths.')
        end

        if (Combine_Crit) then
            table.insert(Horse_Race_Data, '-- Melee and Ranged critical hits are combined.')
        end

        if (Show_Total_Acc) then
            table.insert(Horse_Race_Data, '-- Showing total accuracy for whole duration.')
        end

        if (Total_Damage_Only) then
            table.insert(Horse_Race_Data, '-- Only showing total damage.')
        end
    end

end