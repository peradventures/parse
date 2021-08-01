--[[
    DESCRIPTION:    Parse the melee attack packet.
    PARAMETERS :    
]] 
function Melee_Attack(act, actor, log_offense)
    -- Will need to remove this when implementing defense metrics.
    if (not log_offense) then return end

    local result, target
    local damage = 0
    for target_index, target_value in pairs(act.targets) do
        for action_index, _ in pairs(target_value.actions) do
            
            result = act.targets[target_index].actions[action_index]
            target = Get_Entity_Data(act.targets[target_index].id)

            -- Only log damage for party members whether they are NPC or not
            -- WHY DO I HAVE DAMAGE = DAMAGE + ???
            if log_offense then damage = damage + Melee_Damage(result, actor.name, target.name) end
            
            -- IMPLEMENT DEFENSE LATER
            -- Only log damage taken for party members whether they are NPC or not      
            -- if target.is_party or target.is_alliance then
            --     initialize_check(actor.name, actor.is_npc, target.name, true)
            --     handle_defense(result, target.name)                          
            -- end
        end
    end

    if Show_Melee and (not actor.is_npc) then Add_Message_To_Battle_Log(actor.name, 'Melee', damage) end
end

--[[
    DESCRIPTION:    Parse the ranged attack packet.
    PARAMETERS :    
]] 
function Ranged_Attack(act, actor, log_offense)
    -- Will need to remove this when implementing defense metrics.
    if (not log_offense) then return end
    
    local result, target
    
    for target_index, target_value in pairs(act.targets) do
        for action_index, _ in pairs(target_value.actions) do

            result = act.targets[target_index].actions[action_index]
            target = Get_Entity_Data(act.targets[target_index].id)

            -- Only log damage for party members whether they are NPC or not
            if log_offense then Handle_Ranged(result, actor.name, target.name) end
        end
    end
end

--[[
    DESCRIPTION:    Parse the finish weaponskill packet.
    PARAMETERS :    
]] 
function Finish_WS(act, actor, log_offense)
    -- Only log damage for party members whether they are NPC or not
    if (not log_offense) then return end

    local ws_name = Get_WS_Name(act)
    if (ws_name == 0) then return end

    local ws_data = Res.weapon_skills[act.param]

    local result, target, sc_id, sc_name, skillchain
    local damage    = 0
    local sc_damage = 0
    
    for target_index, target_value in pairs(act.targets) do
        for action_index, _ in pairs(target_value.actions) do

            result = act.targets[target_index].actions[action_index]
            target = Get_Entity_Data(act.targets[target_index].id)

            -- Check for skillchains
            sc_id = result.add_effect_message
            if (sc_id > 0) then 
                skillchain = true
                sc_name    = Skillchain_List[sc_id]
                sc_damage  = sc_damage + Skillchain_Damage(result, actor.name, target.name, sc_name)
            end

            -- Need to calculate WS damage here to account for AOE weaponskills
            damage = damage + Weaponskill_Damage(result, actor.name, target.name, ws_name)
        end
    end

    -- Finalize weaponskill data
    -- Have to do it outside of the loop to avoid count attempts and hits multiple times
    Update_Data('inc', 1, actor.name, target.name, 'ws', 'count')
    if (damage > 0) then
        Update_Data('inc', 1, actor.name, target.name, 'ws', 'hits')
        Update_Data_Single('inc', 1, actor.name, target.name, 'ws', ws_name, 'hits')
    end

    -- Update the battle log
    if (not actor.is_npc) then
        Add_Message_To_Battle_Log(actor.name, ws_name, damage, nil, Find_Party_Member_By_Name(actor.name, 'tp'), 'ws', ws_data)
        if skillchain then Add_Message_To_Battle_Log(actor.name, sc_name, sc_damage, nil, nil) end
    end
end

--[[
    DESCRIPTION:    Parse the finish spell casting packet.
    PARAMETERS :    
]] 
function Finish_Spell_Casting(act, actor, log_offense)
    -- Only log damage for party members whether they are NPC or not
    if (not log_offense) then return end
    
    local result, target, new_damage

    local spell_id = act.param
    local spell = Res.spells[spell_id]
    local damage = 0

    for target_index, target_value in pairs(act.targets) do
        for action_index, _ in pairs(target_value.actions) do

            result = act.targets[target_index].actions[action_index]
            target = Get_Entity_Data(act.targets[target_index].id)
            if (not target) then return end

            -- Only log damage for party members whether they are NPC or not
            if (log_offense) then
                new_damage = Handle_Spell(act, result, actor.name, target.name)
                if (not new_damage) then new_damage = 0 end
                damage = damage +  new_damage
            end

            -- IMPLEMENT DEFENSE LATER
            -- Only log damage taken for party members whether they are NPC or not
            -- if target.is_party or target.is_alliance then
            --     initialize_check(actor.name, actor.is_npc, target.name, true)
            --     handle_spell(act, result, target.name)
            -- end
        end
    end
    
    if (Damage_Spell_List[spell_id]) then
        Add_Message_To_Battle_Log(actor.name, spell.name, damage, nil, nil, 'spell', spell)
    end
end

--[[
    DESCRIPTION:    Parse the job ability packet.
    PARAMETERS :    
]] 
function Job_Ability(act, actor, log_offense)
    -- Only log damage for party members whether they are NPC or not
    if (not log_offense) then return end

    local ability_name = Get_Ability_Name(act)
    if (not ability_name) then return end
    
    -- Increment the count here to avoid counting for multiple targets.
    --if not inc_single_count(act, actor.name, 'ability', ability_name) then return end

    local result, target

    for target_index, target_value in pairs(act.targets) do
        for action_index, _ in pairs(target_value.actions) do

            result = act.targets[target_index].actions[action_index]
            target = Get_Entity_Data(act.targets[target_index].id)

            Handle_Ability(act, result, actor.name, target.name)

        end
    end
end

--[[
    DESCRIPTION:    Parse the pet ability packet.
    PARAMETERS :    
]] 
function Pet_Ability(act, actor, log_offense)
    -- Influenced by flippant parse
    local pet_data = windower.ffxi.get_mob_by_id(act.actor_id)

    -- Check to see if the pet belongs to anyone in the party.
    local owner
    for _, member in pairs(windower.ffxi.get_party()) do
        if type(member) == 'table' and member.mob then
            if (member.mob.pet_index == pet_data.index) then
                owner = member.mob.name
            end
        end
    end

    local ability_name = Get_Ability_Name(act)
    if (not ability_name) then
        Add_Message_To_Chat('E', 'PARSE | Pet_Ability^packet_handling')
        Add_Message_To_Chat('E', 'Ability name not found.')
        return false
    end

    -- Increment the count here to avoid counting for multiple targets.
    --if not inc_single_count(act, owner, 'ability', ability_name) then return end

    local result, target

    for target_index, target_value in pairs(act.targets) do
        for action_index, _ in pairs(target_value.actions) do

            result = act.targets[target_index].actions[action_index]
            target = Get_Entity_Data(act.targets[target_index].id)
            
            Handle_Ability(act, result, owner, target.name)

        end
    end
end