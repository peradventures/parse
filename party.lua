function Find_Party_Member_By_Name(name, index)
	local party = windower.ffxi.get_party()
	if not party then return false end

	local pt1_count = party.party1_count - 1
    local pt2_count = party.party2_count - 1
    local pt3_count = party.party3_count - 1

	for i = 0, pt1_count, 1 do
        if party[pt[i]]['name'] == name then
        	return party[pt[i]][index]
        end
    end

    for i = 0, pt2_count, 1 do
    	if party[pt2[i]]['name'] == name then
    		return party[pt2[i]][index]
    	end
    end

    for i = 0, pt3_count, 1 do
       	if party[pt3[i]]['name'] == name then
    		return party[pt3[i]][index]
    	end
    end
end

--[[
    DESCRIPTION:        Calculates total party / alliance damage for use in percentages.
    PARAMETERS :    
        party           Party data structure
    RETURNS    :        Total party / alliance damage
    ASSUMES    :
        show_alliance
]] 
function Total_Party_Damage(party)
    if not party then return 1 end
    
    local total_damage = 0
    local pt1_count = party.party1_count - 1
    local pt2_count = party.party2_count - 1
    local pt3_count = party.party3_count - 1

    -- Party 1
    for i = 0, pt1_count, 1 do
        player_name = party[pt[i]].name
        
        local index = build_index(player_name)
        Init_Data(index)
        total_damage = total_damage + Get_Data(player_name, 'total', 'total')
    end

    -- Party 2
    for i = 0, pt2_count, 1 do
        player_name = party[pt2[i]].name
        
        local index = build_index(player_name)
        Init_Data(index)
        total_damage = total_damage + Get_Data(player_name, 'total', 'total')
    end

    -- Party 3
    for i = 0, pt3_count, 1 do
        player_name = party[pt3[i]].name
        
        local index = build_index(player_name)
        Init_Data(index)
        total_damage = total_damage + Get_Data(player_name, 'total', 'total')
    end

    return total_damage
end
