Horse_Race_Window, Horse_Race_Content = Create_Window(550, 50, 11, nil, 240)
Texts.stroke_width(Horse_Race_Window, 3)

Show_Horse           = true
Compact_Mode         = true
Show_Crit            = false
Show_Total_Acc       = false
Include_SC_Damage    = false
Show_Percent         = false
Combine_Damage_Types = false
Show_Healing         = false
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
    Add_Message_To_Chat('W', 'PARSE | Toggle_Horse_Race^horse_race_window')
    Add_Message_To_Chat('A', 'Horse Race visibility is now: '..tostring(Show_Horse))
end

--[[
    DESCRIPTION:    Populates horse race parser.
]] 
function Horse_Race()
    local party = windower.ffxi.get_party()
    if not party then return end

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
        if i <= Top_Rank then Horse_Race_Rows(i, player_name, party_damage) end
    end

    Horse_Race_Content.token = Concat_Strings(Horse_Race_Data)
end

--[[
    DESCRIPTION:    Builds the header for the horse race window.
]] 
function Horse_Race_Header()
    
    local cols
    if Compact_Mode then cols = Column_Widths_Compact
    else cols = Column_Widths end

    local name_col  = cols['name']
    local dmg_col   = cols['dmg']
    local small_col = cols['small']

    local filter
    if Mob_Filter then filter = Mob_Filter else filter = 'All' end
    table.insert(Horse_Race_Data, 'Mob Filter: '..filter)

    local header = 'R   '..String_Length('Name', name_col)
    
    -- Total Damage %
    if Show_Percent then header = header..String_Length('T%',   small_col, true) end
    
    -- Total Damage Amount (Raw)
    header = header..String_Length('T#',   dmg_col,   true)
    
    -- Accuracy for total run vs. accuracy over the last [X] hits
    if Show_Total_Acc then
        header = header..String_Length('A-T%', small_col, true)
    else
        header = header..String_Length('A'..tostring(Running_Accuracy_Limit)..'%', small_col, true)
    end
    
    -- Critical Hit %
    if Show_Crit then header = header..String_Length('Crit', small_col, true) end

    -- Can just show total damage or break out each of the damage types
    if (not Combine_Damage_Types) then header = header..String_Length('Melee', dmg_col, true) end

    -- Weaponskill Damage
    header = header..String_Length('WS', dmg_col, true)
    
    -- Skillchain Damage
    if Include_SC_Damage then header = header..String_Length('SC', dmg_col, true) end
    
    -- Ranged, Magic, and Job Ability Damage
    if not Combine_Damage_Types then
        header = header..String_Length('Ranged', dmg_col, true)
        header = header..String_Length('Magic',   dmg_col,   true)
        header = header..String_Length('JA',  dmg_col,   true)
    end

    -- Healing
    if Show_Healing then
        header = header..String_Length('Heals',  dmg_col,   true)
    end
    
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
    if Compact_Mode then cols = Column_Widths_Compact
    else cols = Column_Widths end

    local name_col  = cols['name']
    local dmg_col   = cols['dmg']
    local small_col = cols['small']

    -- Skillchain damage can be included in the grand total or not
    local grand_total
    if Include_SC_Damage then 
        grand_total = Get_Data(player_name, 'total',        'total')
    else
        grand_total = Get_Data(player_name, 'total_no_sc',  'total')
    end

    local melee_total   = Get_Data(player_name, 'melee',   'total')
    local ws_total      = Get_Data(player_name, 'ws',      'total')
    local sc_total      = Get_Data(player_name, 'sc',      'total')
    local range_total   = Get_Data(player_name, 'ranged',  'total')
    local magic_total   = Get_Data(player_name, 'magic',   'total')
    local ability_total = Get_Data(player_name, 'ability', 'total')
    local healing_total = Get_Data(player_name, 'healing', 'total')
    local accuracy_flow = Tally_Running_Accuracy(player_name, small_col)
    --if melee_heal then healing_total = healing_total + get_player_node(actor, 'melee', 'mob_heal') end

    local count = Get_Data(player_name, 'melee', 'count')

    local color
    if Is_Me(player_name, true) then color = C_Bright_Green
    else color  = C_White end 

    local row = color..rank..'.  '..String_Length(player_name, name_col)

    -- Total % column can be toggled on and off
    if Show_Percent then
        row = row..Format_Percent(grand_total, party_damage, small_col)
    end

    -- Total Damage (Raw)
    row = row..Format_Number(grand_total, dmg_col)

    -- Accuracy can be toggled between total accuracy or recent accuracy
    if Show_Total_Acc then
        local hits  = Get_Data(player_name, 'melee', 'hits')
        row = row..Format_Percent(hits, count, small_col)
    else
        row = row..accuracy_flow
    end

    -- Crits can be toggled on and off
    if Show_Crit then
        local crits = Get_Data(player_name, 'melee', 'crits')
        row = row..Format_Percent(crits, count, small_col)
    end

    -- Can just show total damage or break out each of the damage types
    if not Combine_Damage_Types then
        row = row..Format_Number(melee_total, dmg_col)
    end

    row = row..Format_Number(ws_total, dmg_col)

    -- Skillchain damage can be toggled on and off
    if Include_SC_Damage then 
        row = row..Format_Number(sc_total, dmg_col)
    end

    -- Can just show total damage or break out each of the damage types
    if not Combine_Damage_Types then
        row = row..Format_Number(range_total, dmg_col)
        row = row..Format_Number(magic_total, dmg_col)
        row = row..Format_Number(ability_total, dmg_col)
    end

    -- Healing can be toggled on and off
    if Show_Healing then
        row = row..Format_Number(healing_total, dmg_col)
    end

    row = row..C_White

    table.insert(Horse_Race_Data, row)
end