------------------------------------------------------------------------------------------------------
-- Parse the melee attack packet.
------------------------------------------------------------------------------------------------------
-- act         : action packet data
-- actor_mob   : the mob data of the entity performing the action
-- log_offense : boolean of if we should log the data; initial filtering happens in action packet
------------------------------------------------------------------------------------------------------
function Melee_Attack(act, actor_mob, log_offense)
    -- Will need to remove this when implementing defense metrics.
    if (not log_offense) then return end

    -- Check to see if this is a pet.
    local owner = Pet_Owner(act)

    local result, target
    local damage = 0

    for target_index, target_value in pairs(act.targets) do
        for action_index, _ in pairs(target_value.actions) do
            result = act.targets[target_index].actions[action_index]
            target = windower.ffxi.get_mob_by_id(act.targets[target_index].id)
            if (not target) then target = {name = 'test'} end
            damage = damage + Melee_Damage(result, actor_mob.name, target.name, owner)
        end
    end

    if (not actor_mob.is_npc) then
        if (Log_CSV) then
            local data = {
                ["Actor Name"] = actor_mob.name,
                ["Action Name"] = "Melee",
                ["Melee"] = damage
            }
            Add_CSV_Entry(data)
        end
        if (Log_Melee) then
            Add_Message_To_Battle_Log(actor_mob.name, 'Melee', damage)
        end
    end
end

------------------------------------------------------------------------------------------------------
-- Parse the ranged attack packet.
------------------------------------------------------------------------------------------------------
-- act         : action packet data
-- actor_mob   : the mob data of the entity performing the action
-- log_offense : boolean of if we should log the data; initial filtering happens in action packet
------------------------------------------------------------------------------------------------------
function Ranged_Attack(act, actor_mob, log_offense)
    if (not log_offense) then return end

    local result, target
    local damage = 0

    for target_index, target_value in pairs(act.targets) do
        for action_index, _ in pairs(target_value.actions) do
            result = act.targets[target_index].actions[action_index]
            target = windower.ffxi.get_mob_by_id(act.targets[target_index].id)
            if (target) then
                damage = damage + Handle_Ranged(result, actor_mob.name, target.name)
            end
        end
    end

    if (not actor_mob.is_npc) then
        if (Log_CSV) then
            local data = {
                ["Actor Name"] = actor_mob.name,
                ["Action Name"] = "Ranged",
                ["Ranged"] = damage
            }
            Add_CSV_Entry(data)
        end
        if (Log_Ranged) then
            Add_Message_To_Battle_Log(actor_mob.name, 'Ranged', damage)
        end

    end
end

------------------------------------------------------------------------------------------------------
-- Parse the weaponskill packet.
------------------------------------------------------------------------------------------------------
-- act         : action packet data
-- actor_mob   : the mob data of the entity performing the action
-- log_offense : boolean of if we should log the data; initial filtering happens in action packet
------------------------------------------------------------------------------------------------------
function Finish_WS(act, actor_mob, log_offense)
    if (not log_offense) then return end

    local ws_name = Get_WS_Name(act)
    if (ws_name == 0) then return end

    local ws_id = act.param
    local ws_data = Res.weapon_skills[ws_id]

    -- Some abilities--like DRG Jumps--oddly show up in this packet
    if (WS_Abilities[ws_id]) then
        Job_Ability(act, actor_mob, log_offense)
        return
    end

    local result, target, sc_id, sc_name, skillchain
    local damage    = 0
    local sc_damage = 0

    for target_index, target_value in pairs(act.targets) do
        for action_index, _ in pairs(target_value.actions) do

            result = act.targets[target_index].actions[action_index]
            target = windower.ffxi.get_mob_by_id(act.targets[target_index].id)
            if (not target) then target = {name = 'test'} end

            -- Check for skillchains
            sc_id = result.add_effect_message
            if (sc_id > 0) then 
                skillchain = true
                sc_name    = Skillchain_List[sc_id]
                sc_damage  = sc_damage + Skillchain_Damage(result, actor_mob.name, target.name, sc_name)
            end

            -- Need to calculate WS damage here to account for AOE weaponskills
            damage = damage + Weaponskill_Damage(result, actor_mob.name, target.name, ws_name)
        end
    end

    -- Finalize weaponskill data
    -- Have to do it outside of the loop to avoid counting attempts and hits multiple times

    local audits = {
        player_name = actor_mob.name,
        target_name = target.name,
    }

    Update_Data('inc', 1, audits, 'ws', 'count')
    Update_Data_Catalog('inc', 1, audits, 'ws', ws_name, 'hits')

    if (damage > 0) then
        Update_Data('inc', 1, audits, 'ws', 'hits')
        Update_Data_Catalog('inc', 1, audits, 'ws', ws_name, 'hits')
    end

    -- Update the battle log
    if (not actor_mob.is_npc) then
        if (Log_CSV) then
            local data = {
                ["Actor Name"] = actor_mob.name,
                ["Action Name"] = ws_data.name,
                ["WS"] = damage
            }
            Add_CSV_Entry(data)

            data = {
                ["Actor Name"] = actor_mob.name,
                ["Action Name"] = sc_name,
                ["SC"] = sc_damage
            }
        end
        if (Log_WS) then
            Add_Message_To_Battle_Log(actor_mob.name, ws_name, damage, nil, Find_Party_Member_By_Name(actor_mob.name, 'tp'), 'ws', ws_data)
        end
        if (Log_SC) and (skillchain) then
            Add_Message_To_Battle_Log(actor_mob.name, sc_name, sc_damage, nil, nil)
        end
    end
end

------------------------------------------------------------------------------------------------------
-- Parse the finish spell casting packet.
------------------------------------------------------------------------------------------------------
-- act         : action packet data
-- actor_mob   : the mob data of the entity performing the action
-- log_offense : boolean of if we should log the data; initial filtering happens in action packet
------------------------------------------------------------------------------------------------------
function Finish_Spell_Casting(act, actor_mob, log_offense)
    if (not log_offense) then return end

    local result, target, new_damage
    local damage = 0
    local spell_id = act.param
    local spell = Res.spells[spell_id]
    if (not spell) then return end

    for target_index, target_value in pairs(act.targets) do
        for action_index, _ in pairs(target_value.actions) do
            result = act.targets[target_index].actions[action_index]
            target = windower.ffxi.get_mob_by_id(act.targets[target_index].id)
            if (not target) then target = {name = "test"} end

            new_damage = Handle_Spell(act, result, actor_mob.name, target.name)
            if (not new_damage) then new_damage = 0 end

            damage = damage + new_damage
        end
    end

    local audits = {
        player_name = actor_mob.name,
        target_name = target.name,
    }

    -- Log the use of the spell
    Update_Data_Catalog('inc', 1, audits, 'magic', spell.en, 'count')

    if (Damage_Spell_List[spell_id]) and (not actor_mob.is_npc) then
        Add_Message_To_Battle_Log(actor_mob.name, spell.name, damage, nil, nil, 'spell', spell)
    end
end

------------------------------------------------------------------------------------------------------
-- Parse the job ability casting packet.
------------------------------------------------------------------------------------------------------
-- act         : action packet data
-- actor_mob   : the mob data of the entity performing the action
-- log_offense : boolean of if we should log the data; initial filtering happens in action packet
------------------------------------------------------------------------------------------------------
function Job_Ability(act, actor_mob, log_offense)
    if (not log_offense) then return end

    local ability_name = Get_Ability_Name(act)
    if (not ability_name) then return end

    local result, target
    local damage = 0

    for target_index, target_value in pairs(act.targets) do
        for action_index, _ in pairs(target_value.actions) do
            result = act.targets[target_index].actions[action_index]
            target = windower.ffxi.get_mob_by_id(act.targets[target_index].id)
            if (not target) then target = {name = 'test'} end
            damage = damage + Handle_Ability(act, result, actor_mob, target.name)
        end
    end

    local audits = {
        player_name = actor_mob.name,
        target_name = target.name,
    }

    -- Log the use of the ability
    Update_Data_Catalog('inc', 1, audits, 'ability', ability_name, 'count')

    -- Battle log message gets handled in Handle_Ability if the damage is >0
    if (Log_Abiilty) and (not actor_mob.is_npc) and (damage <= 0) then
        Add_Message_To_Battle_Log(actor_mob.name, ability_name, damage)
    end
end

------------------------------------------------------------------------------------------------------
-- Parse the finish monster TP move packet.
-- Puppet ranged attacks fall into this too.
------------------------------------------------------------------------------------------------------
-- act         : action packet data
-- actor_mob   : the mob data of the entity performing the action
-- log_offense : boolean of if we should log the data; initial filtering happens in action packet
------------------------------------------------------------------------------------------------------
function Finish_Monster_TP_Move(act, actor_mob, log_offense)
    if (not log_offense) then return end

    -- Check to see if the pet belongs to anyone in the party.
    local owner_mob = Pet_Owner(act)

    local result, target, ws_name, sc_id, sc_name
    local sc_damage  = 0
    local damage     = 0

    for target_index, target_value in pairs(act.targets) do
        for action_index, _ in pairs(target_value.actions) do

            result = act.targets[target_index].actions[action_index]
            target = windower.ffxi.get_mob_by_id(act.targets[target_index].id)
            if (not target) then target = {name = 'test'} end

            -- Puppet ranged attack
            if (act.param == 1949) then
                Handle_Ranged(result, actor_mob.name, target.name, owner_mob)
                ws_name = 'Pet Ranged'
                damage = result.param

            else
                local ws_data = Res.monster_abilities[act.param]
                ws_name = ws_data.name

                -- Check for skillchains
                sc_id = result.add_effect_message
                if (sc_id > 0) then 
                    sc_name    = Skillchain_List[sc_id]
                    sc_damage  = sc_damage + Skillchain_Damage(result, actor_mob.name, target.name, sc_name)
                end

                -- Need to calculate WS damage here to account for AOE weaponskills
                damage = damage + Weaponskill_Damage(result, actor_mob.name, target.name, ws_name, owner_mob)
            end

        end
    end

    if (Log_Pet) and (owner_mob) then
        Add_Message_To_Battle_Log(actor_mob.name, ws_name, damage)
    end
end

------------------------------------------------------------------------------------------------------
-- Parse the pet ability packet.
-- SMN bloodpacts; DRG wyvern breaths
------------------------------------------------------------------------------------------------------
-- act         : action packet data
-- actor_mob   : the mob data of the entity performing the action
-- log_offense : boolean of if we should log the data; initial filtering happens in action packet
------------------------------------------------------------------------------------------------------
function Pet_Ability(act, actor_mob, log_offense)
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
            target = windower.ffxi.get_mob_by_id(act.targets[target_index].id)
            if (not target) then target = {name = 'test'} end
            damage = damage + Handle_Ability(act, result, owner_mob, target.name, owner_mob)
        end
    end

    local audits = {
        player_name = owner_mob.name,
        target_name = target.name,
    }

    if (damage > 0) then
        Update_Data('inc', 1, audits, 'ability', 'hits')

        if (Log_Pet) then
            Add_Message_To_Battle_Log(actor_mob.name, ability_name, damage)
        end
    end
end

------------------------------------------------------------------------------------------------------
-- Parse the player death message.
------------------------------------------------------------------------------------------------------
-- actor_id  : mob id of the entity performing the action
-- target_id : mob id of the entity receiving the action (this is the person dying)
------------------------------------------------------------------------------------------------------
function Player_Death(actor_id, target_id)
    local target = windower.ffxi.get_mob_by_id(target_id)
    if (not target) then return end

    local log_death = (target.in_party) or (target.in_alliance)
    if (not log_death) then return end

    local actor = windower.ffxi.get_mob_by_id(actor_id)
    if (not actor) then return end

    local audits = {
        player_name = target.name,
        target_name = actor.name,
    }

    Update_Data('inc', 1, audits, 'death', 'count')

    if (Log_Deaths) then Add_Message_To_Battle_Log(actor.name, 'Death', 0) end
end