--[[
    DESCRIPTION:    Builds the UI for the horse race parser
]] 
function horse_race() 
    local name
    local party = windower.ffxi.get_party()

    sort_damage()

    -- local pt1_count = party.party1_count - 1
    -- local pt2_count = party.party2_count - 1
    -- local pt3_count = party.party3_count - 1
    local total_dmg, party_damage

    parse_layout = {}
    horse_race_header()

    party_damage = total_pt_damage(party)

    for i, v in ipairs(total_damage_race) do
        name = v[1]
        if i <= top_rank then horse_race_rows(i, name, party_damage) end
    end

    -- -- Party 1
    -- for i = 0, pt1_count, 1 do
    --     name = party[pt[i]].name     
    --     horse_race_rows(name, party_damage)
    -- end

    -- -- Party 2
    -- if show_alliance then
    --     for i = 0, pt2_count, 1 do
    --         name = party[pt2[i]].name
    --         horse_race_rows(name, party_damage)
    --     end
    -- end

    -- -- Party 3
    -- if show_alliance then
    --     for i = 0, pt3_count, 1 do
    --         name = party[pt3[i]].name
    --         horse_race_rows(name, party_damage)
    --     end
    -- end
    horse_content.modestates = concat_strings(parse_layout)

end

--[[
    DESCRIPTION:    Builds the header for the horse race window.
]] 
function horse_race_header()
    local header
    
    local cols
    if compact_mode then cols = Column_Widths_Compact
    else cols = Column_Widths end

    local name_col  = cols['name']
    local dmg_col   = cols['dmg']
    local small_col = cols['small']

    local filter
    if Mob_Filter then filter = Mob_Filter else filter = 'All' end
    table.insert(parse_layout, 'Mob Filter: '..filter)

    header = 'R   '..String_Length('Name', name_col)
    
    -- Total % column can be toggled on and off
    if show_percent then
        header = header..String_Length('T%',   small_col, true)
    end
    
    header = header..String_Length('T#',   dmg_col,   true)
    
    -- Accuracy can be toggled between total accuracy or recent accuracy
    if Show_Total_Acc then
        header = header..String_Length('A-T%', small_col, true)
    else
        header = header..String_Length('A50%', small_col, true)
    end
    
    -- Crits can be toggled on and off
    if Show_Crit then
        header = header..String_Length('Crit', small_col, true)
    end

    -- Can just show total damage or break out each of the damage types
    if not combine_damage_types then
        header = header..String_Length('Melee', dmg_col, true)
    end

    header = header..String_Length('WS', dmg_col, true)
    
    -- Skillchain damage can be toggled on and off
    if Include_SC_Damage then 
        header = header..String_Length('SC', dmg_col, true)
    end
    
    -- Can just show total damage or break out each of the damage types
    if not combine_damage_types then
        header = header..String_Length('Ranged', dmg_col, true)
        header = header..String_Length('Magic',   dmg_col,   true)
        header = header..String_Length('JA',  dmg_col,   true)
    end

    -- Healing can be toggled on and off
    if show_healing then
        header = header..String_Length('Heals',  dmg_col,   true)
    end
    
    table.insert(parse_layout, header)
end

--[[
    DESCRIPTION:    	Builds a row for each entity in the horse race parser.
    PARAMETERS :
    	actor			Primary node
    	party_damage 	Total damage from party / alliance
]] 
function horse_race_rows(rank, player_name, party_damage)
    local row
    
    local cols
    if compact_mode then cols = Column_Widths_Compact
    else cols = Column_Widths end

    local name_col  = cols['name']
    local dmg_col   = cols['dmg']
    local small_col = cols['small']

    -- Skillchain damage can be toggled on and off
    local grand_total
    if Include_SC_Damage then 
        grand_total = get_data(player_name, 'total',        'total')
    else
        grand_total = get_data(player_name, 'total_no_sc',  'total')
    end

    local melee_total    = get_data(player_name, 'melee',   'total')
    local ws_total       = get_data(player_name, 'ws',      'total')
    local sc_total       = get_data(player_name, 'sc',      'total')
    local range_total    = get_data(player_name, 'ranged',  'total')
    local magic_total    = get_data(player_name, 'magic',   'total')
    local ability_total  = get_data(player_name, 'ability', 'total')
    local healing_total  = get_data(player_name, 'healing', 'total')
    local accuracy_flow  = tally_running_acc(player_name)
    --if melee_heal then healing_total = healing_total + get_player_node(actor, 'melee', 'mob_heal') end

    
    local count = get_data(player_name, 'melee', 'count')

    local color 
    if Is_Me(player_name, true) then color = c_bright_green
    else color  = c_white end 

    row =      color..rank..'.  '..String_Length(player_name, name_col)
    
    -- Total % column can be toggled on and off
    if show_percent then
        row = row..String_Length(Remove_Zero(get_percent(grand_total, party_damage)), small_col, true)
    end

    row = row..Format_Number(grand_total,   dmg_col)
    
    -- Accuracy can be toggled between total accuracy or recent accuracy
    if Show_Total_Acc then
        local hits  = get_data(player_name, 'melee', 'hits')
        row = row..String_Length(Remove_Zero(get_percent(hits,  count)), small_col, true)
    else
        row = row..String_Length(accuracy_flow, small_col, true)
    end
    
    -- Crits can be toggled on and off
    if Show_Crit then 
        local crits = get_data(player_name, 'melee', 'crits')
        row = row..String_Length(Remove_Zero(get_percent(crits, count)), small_col, true)
    end
    
    -- Can just show total damage or break out each of the damage types
    if not combine_damage_types then
        row = row..Format_Number(melee_total,   dmg_col)
    end

    row = row..Format_Number(ws_total,      dmg_col)
    
    -- Skillchain damage can be toggled on and off
    if Include_SC_Damage then 
        row = row..Format_Number(sc_total, dmg_col)
    end

    -- Can just show total damage or break out each of the damage types
    if not combine_damage_types then
        row = row..Format_Number(range_total, dmg_col)
        row = row..Format_Number(magic_total,   dmg_col)
        row = row..Format_Number(ability_total, dmg_col)
    end
    
    -- Healing can be toggled on and off
    if show_healing then
        row = row..Format_Number(healing_total, dmg_col)
    end

    row = row..c_white

    table.insert(parse_layout, row)
end