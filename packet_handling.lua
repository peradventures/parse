--[[
    DESCRIPTION:    Parse the melee attack packet.
    PARAMETERS :    
]] 
function Melee_Attack(act, actor, log_offense)
    -- Will need to remove this when implementing defense metrics.
    if (not log_offense) then return end

    -- Check to see if this is a pet.
    local owner = Pet_Owner(act)

    local result, target
    local damage = 0
    for target_index, target_value in pairs(act.targets) do
        for action_index, _ in pairs(target_value.actions) do

            result = act.targets[target_index].actions[action_index]
            target = Get_Entity_Data(act.targets[target_index].id)
            damage = damage + Melee_Damage(result, actor.name, target.name, owner)

        end
    end

    if (Log_Melee) and (not actor.is_npc) then Add_Message_To_Battle_Log(actor.name, 'Melee', damage) end
end

--[[
    DESCRIPTION:    Parse the ranged attack packet.
    PARAMETERS :    
]] 
function Ranged_Attack(act, actor, log_offense)
    if (not log_offense) then return end

    local result, target
    local damage = 0

    for target_index, target_value in pairs(act.targets) do
        for action_index, _ in pairs(target_value.actions) do

            result = act.targets[target_index].actions[action_index]
            target = Get_Entity_Data(act.targets[target_index].id)

            -- Only log damage for party members whether they are NPC or not
            damage = damage + Handle_Ranged(result, actor.name, target.name)
        end
    end

    if (Log_Ranged) and (not actor.is_npc) then Add_Message_To_Battle_Log(actor.name, 'Ranged', damage) end
end

--[[
    DESCRIPTION:    Parse the finish weaponskill packet.
    PARAMETERS :    
]] 
function Finish_WS(act, actor, log_offense)
    if (not log_offense) then return end

    local ws_name = Get_WS_Name(act)
    if (ws_name == 0) then return end

    local ws_id   = act.param
    local ws_data = Res.weapon_skills[ws_id]

    -- Some abilities like jump oddly show up in this packet
    if (WS_Abilities[ws_id]) then
        Job_Ability(act, actor, log_offense)
        return
    end

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

    local audits = {
        player_name = actor.name,
        target_name = target.name,
    }

    Update_Data('inc', 1, audits, 'ws', 'count')
    if (damage > 0) then
        Update_Data('inc', 1, audits, 'ws', 'hits')
        Update_Data_Single('inc', 1, audits, 'ws', ws_name, 'hits')
    end

    -- Update the battle log
    if (not actor.is_npc) then

        if (Log_WS) and (not actor.is_npc) then
            Add_Message_To_Battle_Log(actor.name, ws_name, damage, nil, Find_Party_Member_By_Name(actor.name, 'tp'), 'ws', ws_data)
        end

        if (Log_SC) and (skillchain) and (not actor.is_npc) then 
            Add_Message_To_Battle_Log(actor.name, sc_name, sc_damage, nil, nil) 
        end

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

        end
    end

    if (Damage_Spell_List[spell_id]) and (not actor.is_npc) then
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

    local result, target
    local damage = 0
    for target_index, target_value in pairs(act.targets) do
        for action_index, _ in pairs(target_value.actions) do

            result = act.targets[target_index].actions[action_index]
            target = Get_Entity_Data(act.targets[target_index].id)
            if (not target) then return end

            damage = damage + Handle_Ability(act, result, actor, target.name)

        end
    end

    -- Increment the count here to avoid counting for multiple targets.
    local audits = {
        player_name = actor.name,
        target_name = target.name,
    }

    -- Log the use of the ability
    Update_Data_Single('inc', 1, audits, 'ability', ability_name, 'count')

    -- Battle log message gets handled in Handle_Ability if the damage is >0
    if (Log_Abiilty) and (not actor.is_npc) and (damage <= 0) then
        Add_Message_To_Battle_Log(actor.name, ability_name, damage)
    end
end

--[[
    DESCRIPTION:    Puppet ranged attacks fall into this too.
    PARAMETERS :
]]
function Finish_Monster_TP_Move(act, actor, log_offense)
    if (not log_offense) then return end

    -- Check to see if the pet belongs to anyone in the party.
    local owner_mob = Pet_Owner(act)

    local result, target, ws_name, sc_id, sc_name, skillchain
    local sc_damage  = 0
    local damage     = 0

    for target_index, target_value in pairs(act.targets) do
        for action_index, _ in pairs(target_value.actions) do

            result = act.targets[target_index].actions[action_index]
            target = Get_Entity_Data(act.targets[target_index].id)

            -- Puppet ranged attack
            if (act.param == 1949) then
                Handle_Ranged(result, actor.name, target.name, owner_mob)
                ws_name = 'Pet Ranged'
                damage = result.param

            else
                local ws_data = Res.monster_abilities[act.param]
                ws_name = ws_data.name

                -- Check for skillchains
                sc_id = result.add_effect_message
                if (sc_id > 0) then 
                    skillchain = true
                    sc_name    = Skillchain_List[sc_id]
                    sc_damage  = sc_damage + Skillchain_Damage(result, actor.name, target.name, sc_name)
                end

                -- Need to calculate WS damage here to account for AOE weaponskills
                damage = damage + Weaponskill_Damage(result, actor.name, target.name, ws_name, owner_mob)
            end

        end
    end

    if (Log_Pet) and (owner_mob) then
        Add_Message_To_Battle_Log(actor.name, ws_name, damage)
    end

end

--[[
    DESCRIPTION:    SMN bloodpacts; DRG wyvern breaths
    PARAMETERS :
]]
function Pet_Ability(act, actor, log_offense)
    if (not log_offense) then return end

    -- Check to see if the pet belongs to anyone in the party.
    local owner_mob = Pet_Owner(act)

    local ability_name = Get_Ability_Name(act)
    if (not ability_name) then
        Add_Message_To_Chat('E', 'Pet_Ability^packet_handling', 'Ability name not found.')
        return false
    end

    local result, target
    local damage = 0

    for target_index, target_value in pairs(act.targets) do
        for action_index, _ in pairs(target_value.actions) do

            result = act.targets[target_index].actions[action_index]
            target = Get_Entity_Data(act.targets[target_index].id)
            damage = damage + Handle_Ability(act, result, owner_mob, target.name, owner_mob)

        end
    end

    local audits = {
        player_name = owner_mob.name,
        target_name = target.name,
    }

    if (damage > 0) then
        Update_Data('inc', 1, audits, 'ability', 'hits')
    end

    -- Battle log message gets handled in Handle_Ability if the damage is >0
    if (Log_Pet) and (damage <= 0) then
        Add_Message_To_Battle_Log(actor.name, ability_name, damage)
    end
end

--[[
    DESCRIPTION:
    PARAMETERS :
]]
function Player_Death(actor_id, target_id)
    local target = Get_Entity_Data(target_id)
    if (not target) then return end

    local log_death = (target.is_party) or (target.is_alliance)
    if (not log_death) then return end

    local actor = Get_Entity_Data(actor_id)
    if (not actor) then return end

    local audits = {
        player_name = target.name,
        target_name = actor.name,
    }

    Update_Data('inc', 1, audits, 'death', 'count')

    if (Log_Deaths) then Add_Message_To_Battle_Log(actor.name, 'Death', 0) end
end