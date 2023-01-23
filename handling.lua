------------------------------------------------------------------------------------------------------
-- Set data for a melee action.
-- NOTES:
-- message 				https://github.com/Windower/Lua/wiki/Message-IDs
-- has_add_effect		boolean
-- add_effect_animation	https://github.com/Windower/Lua/wiki/Additional-Effect-IDs
-- Enspell element
-- add_effect_message	229: comes up with Ygnas bonus attack
-- add_effect_param		enspell damage
-- spike_effect_param	0: consistently on MNK vs Apex bats
-- spike_effect_effect	
-- effect 				2: killing blow
-- 						4: counter? (probably not)
-- stagger 				animation the target does when being hit
-- reaction 			8: hit; consistently on MNK vs Apex bats
-- 						9: miss?; very rarely on MNK vs Apex bats
------------------------------------------------------------------------------------------------------
-- metadata    : contains all the information for the action
-- player_name : name of the player that did the action
-- target_name : name of the target that received the action
-- owner_mob   : if the action was from a pet then this will hold the owner's mob
------------------------------------------------------------------------------------------------------
function Melee_Damage(metadata, player_name, target_name, owner_mob)
    local animation_id = metadata.animation
    local damage = metadata.param
    local throwing = false

    -- Need special handling for pets
    local broad_melee_type, discrete_melee_type
    if (owner_mob) then
        broad_melee_type = 'pet_melee'
        discrete_melee_type = 'pet_melee_discrete'
        player_name = owner_mob.name
    else
        broad_melee_type = 'melee'
        discrete_melee_type = Get_Discrete_Melee_Type(animation_id)
    end

    local audits = {
        player_name = player_name,
        target_name = target_name,
    }

    -- Totals ///////////////////////////////////////////////////////
    Update_Data('inc', damage, audits, 'total', 'total')
    Update_Data('inc', damage, audits, 'total_no_sc', 'total')
    Update_Data('inc', damage, audits, discrete_melee_type, 'total')
    Update_Data('inc',      1, audits, discrete_melee_type, 'count')

    if (owner_mob) then
        Update_Data('inc', damage, audits, 'pet', 'total')
    end

    -- Melee ////////////////////////////////////////////////////////
    if (animation_id >= 0) and (animation_id < 4) then
        Update_Data('inc', damage, audits, broad_melee_type, 'total')
        Update_Data('inc',      1, audits, broad_melee_type, 'count')

    -- Throwing /////////////////////////////////////////////////////
    elseif (animation_id == 4) then
        throwing = true
        Update_Data('inc', damage, audits, 'ranged', 'total')
        Update_Data('inc',      1, audits, 'ranged', 'count')

    -- Unhandled Animation //////////////////////////////////////////
    else
        Add_Message_To_Chat('W', 'Melee_Damage^handling', 'Unhandled animation: '..tostring(animation_id))
    end

    -- Min/Max //////////////////////////////////////////////////////
    if (throwing) then
        if (damage > 0) and (damage < Get_Data(player_name, 'ranged', 'min')) then Update_Data('set', damage, audits, 'ranged', 'min') end
        if (damage > Get_Data(player_name, 'ranged', 'max')) then Update_Data('set', damage, audits, 'ranged', 'max') end
    else
        if (damage > 0) and (damage < Get_Data(player_name, broad_melee_type, 'min')) then Update_Data('set', damage, audits, broad_melee_type, 'min') end
        if (damage > Get_Data(player_name, broad_melee_type, 'max')) then Update_Data('set', damage, audits, broad_melee_type, 'max') end
    end

    -- Enspell //////////////////////////////////////////////////////
    local enspell_damage = metadata.add_effect_param
    if (enspell_damage > 0) then
        -- Element of the enspell is in add_effect_animation
        Update_Data('inc', enspell_damage, audits, 'magic',   'total')
        Update_Data('inc', enspell_damage, audits, 'enspell', 'total')
        Update_Data('inc',              1, audits, 'magic', 'count')
        if (enspell_damage < Get_Data(player_name, 'magic', 'min')) then Update_Data('set', enspell_damage, audits, 'magic', 'min') end
        if (enspell_damage > Get_Data(player_name, 'magic', 'max')) then Update_Data('set', enspell_damage, audits, 'magic', 'max') end
    end

    -- Metadata /////////////////////////////////////////////////////
    local message_id = metadata.message

    -- Hit
    if (message_id == 1) then
        Update_Data('inc',      1, audits, broad_melee_type,    'hits')
        Update_Data('inc',      1, audits, discrete_melee_type, 'hits')
        Running_Accuracy(player_name, true)

    -- Healing with melee attacks
    elseif (message_id == 3) or (message_id == 373) then
        Update_Data('inc',      1, audits, broad_melee_type,    'hits')
        Update_Data('inc',      1, audits, discrete_melee_type, 'hits')
        Update_Data('inc', damage, audits, broad_melee_type,    'mob heal')

    -- Misses
    elseif (message_id == 15) then
        Update_Data('inc',      1, audits, broad_melee_type, 'misses')
        Running_Accuracy(player_name, false)

    -- DRK vs. Omen Gorger
    elseif (message_id == 30) then
        Add_Message_To_Chat('A', 'Melee_Damage^handling', 'Attack Nuance 30 -- DRK vs. Omen Gorger')

    -- Attack absorbed by shadows
    elseif (message_id == 31) then
        Update_Data('inc',      1, audits, broad_melee_type,    'hits')
        Update_Data('inc',      1, audits, discrete_melee_type, 'hits')
        Update_Data('inc',      1, audits, broad_melee_type,    'shadows')

    -- Attack dodged (Perfect Dodge) / Remove the count so perfect dodge doesn't count.
    elseif (message_id == 32) then
        Update_Data('inc',     -1, audits, broad_melee_type,    'count')
        Update_Data('inc',     -1, audits, discrete_melee_type, 'count')

    -- Critical Hits
    elseif (message_id == 67) then 
        Update_Data('inc',      1, audits, broad_melee_type,    'hits')
        Update_Data('inc',      1, audits, discrete_melee_type, 'hits')
        Update_Data('inc',      1, audits, broad_melee_type,    'crits')
        Update_Data('inc', damage, audits, broad_melee_type,    'crit damage')
        Running_Accuracy(player_name, true)

    -- Throwing Critical Hit
    elseif (message_id == 353) then
        Update_Data('inc',      1, audits, 'ranged', 'hits')
        Update_Data('inc',      1, audits, 'ranged', 'crits')
        Update_Data('inc', damage, audits, 'ranged', 'crit damage')
        Running_Accuracy(player_name, true)

    -- Throwing Miss
    elseif (message_id == 354) then
        Update_Data('inc',      1, audits, 'ranged', 'misses')
        Running_Accuracy(player_name, false)

    -- Throwing Square Hit
    elseif (message_id == 576) then
        Update_Data('inc',      1, audits, 'ranged', 'hits')
        Running_Accuracy(player_name, true)

    -- Throwing Truestrike
    elseif (message_id == 577) then
        Update_Data('inc',      1, audits, 'ranged', 'hits')
        Running_Accuracy(player_name, true)

    else
        Add_Message_To_Battle_Log(player_name, 'Att. nuance '..message_id) end

    local spikes = metadata.spike_effect_effect

    return damage
end

------------------------------------------------------------------------------------------------------
-- Set data for a ranged attack action.
------------------------------------------------------------------------------------------------------
-- metadata    : contains all the information for the action
-- player_name : name of the player that did the action
-- target_name : name of the target that received the action
-- owner_mob   : if the action was from a pet then this will hold the owner's mob
------------------------------------------------------------------------------------------------------
function Handle_Ranged(metadata, player_name, target_name, owner_mob)
    local damage = metadata.param
    local message_id = metadata.message

    -- Need special handling for pets
    local ranged_type
    if (owner_mob) then
        ranged_type = 'pet_ranged'
        player_name = owner_mob.name
    else
        ranged_type = 'ranged'
    end

    local audits = {
        player_name = player_name,
        target_name = target_name,
    }

    -- Totals ///////////////////////////////////////////////////////
    Update_Data('inc', damage, audits, 'total',  'total')
    Update_Data('inc', damage, audits, 'total_no_sc', 'total')
    Update_Data('inc',      1, audits, ranged_type, 'count')

    if (owner_mob) then
        Update_Data('inc', damage, audits, 'pet', 'total')
    end

    -- Miss /////////////////////////////////////////////////////////
    if (message_id == 354) then 
    	Update_Data('inc',      1, audits, ranged_type, 'misses')
        Running_Accuracy(player_name, false)
    	return damage

    -- Shadows //////////////////////////////////////////////////////
    elseif (message_id == 31) then
        Update_Data('inc',      1, audits, ranged_type, 'hits')
        Update_Data('inc',      1, audits, ranged_type, 'shadows')
        return damage

    -- Puppet ///////////////////////////////////////////////////////
    elseif (message_id == 185) then
        Update_Data('inc',      1, audits, ranged_type, 'hits')
        Update_Data('inc', damage, audits, ranged_type, 'total')
        Running_Accuracy(player_name, true)

    -- Regular Hit //////////////////////////////////////////////////
    elseif (message_id == 352) then
        Update_Data('inc',      1, audits, ranged_type, 'hits')
        Update_Data('inc', damage, audits, ranged_type, 'total')
        Running_Accuracy(player_name, true)

    -- Square Hit ///////////////////////////////////////////////////
    elseif (message_id == 576) then
        Update_Data('inc',      1, audits, ranged_type, 'hits')
        Update_Data('inc', damage, audits, ranged_type, 'total')
        Running_Accuracy(player_name, true)

    -- Truestrike ///////////////////////////////////////////////////
    elseif (message_id == 577) then
        Update_Data('inc',      1, audits, ranged_type, 'hits')
        Update_Data('inc', damage, audits, ranged_type, 'total')
        Running_Accuracy(player_name, true)

    -- Crit /////////////////////////////////////////////////////////
    elseif (message_id == 353) then
        Update_Data('inc',      1, audits, ranged_type, 'hits')
        Update_Data('inc',      1, audits, ranged_type, 'crits')
        Update_Data('inc', damage, audits, ranged_type, 'crit damage')
        Update_Data('inc', damage, audits, ranged_type, 'total')
        Running_Accuracy(player_name, true)

    else
        Add_Message_To_Battle_Log(player_name, 'Ranged nuance '..tostring(message_id)) end

    if (damage == 0) then
        Add_Message_To_Chat('W', 'Handle_Ranged^handling', 'Ranged damage was 0.')
    end

    if (damage > 0) and (damage < Get_Data(player_name, ranged_type, 'min')) then Update_Data('set', damage, audits, ranged_type, 'min') end
    if (damage > Get_Data(player_name, ranged_type, 'max')) then Update_Data('set', damage, audits, ranged_type, 'max') end

    return damage
end

------------------------------------------------------------------------------------------------------
-- Set data for a weaponskill action.
------------------------------------------------------------------------------------------------------
-- metadata    : contains all the information for the action
-- player_name : name of the player that did the action
-- target_name : name of the target that received the action
-- ws_name     : name of the weaponskill
-- owner_mob   : if the action was from a pet then this will hold the owner's mob
------------------------------------------------------------------------------------------------------
function Weaponskill_Damage(metadata, player_name, target_name, ws_name, owner_mob)
    local damage = metadata.param

    local ws_type = 'ws'
    if (owner_mob) then
        player_name = owner_mob.name
        ws_type = 'pet_ws'
    end

    local audits = {
        player_name = player_name,
        target_name = target_name,
    }

    if (owner_mob) then
        Update_Data('inc', damage, audits, 'pet', 'total')
    end

    Catalog_Damage(player_name, target_name, ws_type, damage, ws_name)

    return damage
end

------------------------------------------------------------------------------------------------------
-- Set data for a skillchain action.
------------------------------------------------------------------------------------------------------
-- metadata    : contains all the information for the action
-- player_name : name of the player that did the action
-- target_name : name of the target that received the action
-- sc_name     : name of the skillchain
------------------------------------------------------------------------------------------------------
function Skillchain_Damage(metadata, player_name, target_name, sc_name)
    local damage = metadata.add_effect_param
    Catalog_Damage(player_name, target_name, 'sc', damage, sc_name)
    return damage
end

------------------------------------------------------------------------------------------------------
-- Set data for a spell action (including healing).
-- Not all spells do damage and not all spells heal this will sort those out.
------------------------------------------------------------------------------------------------------
-- act         : the main packet; need it to get spell ID
-- metadata    : contains all the information for the action
-- player_name : name of the player that did the action
-- target_name : name of the target that received the action
------------------------------------------------------------------------------------------------------
function Handle_Spell(act, metadata, player_name, target_name)
    local spell_id = act.param
    local spell = Res.spells[spell_id]

    if (not spell) then
        Add_Message_To_Chat('W', 'Handle_Spell^handling', 'Couldn\'t find spell ID '..tostring(spell_id)..' in spells for '..player_name)
        return 0
    end

    local spell_name = spell.en
    local spell_mapped = false
    local damage = metadata.param or 0

    if (Damage_Spell_List[spell_id]) then
        Catalog_Damage(player_name, target_name, 'magic', damage, spell_name)
        spell_mapped = true
    end

    -- TO DO: Handle Overcure
    if (Healing_Spell_List[spell_id]) then
    	Catalog_Damage(player_name, target_name, 'healing', damage, spell_name)
        spell_mapped = true
    end

    if (not spell_mapped) then
        --Add_Message_To_Chat('W', 'Handle_Spell^handling', tostring(spell_name)..' is not included in Damage_Spells global.')
    end

    return damage
end

------------------------------------------------------------------------------------------------------
-- Set data for an ability action.
-- This includes pet damage (since they are ability based).
------------------------------------------------------------------------------------------------------
-- act         : the main packet; need it to get spell ID
-- metadata    : contains all the information for the action
-- actor_mob   : mob of the player that did the action
-- target_name : name of the target that received the action
-- owner_mob   : if the action was from a pet then this will hold the owner's mob
------------------------------------------------------------------------------------------------------
function Handle_Ability(act, metadata, actor_mob, target_name, owner_mob)
    local player_name = actor_mob.name
    local ability_id = act.param
    local ability = Res.job_abilities[ability_id]
    local ability_name = Get_Ability_Name(act)
    local damage = metadata.param

    local ability_type = 'ability'
    if (owner_mob) then
        ability_type = 'pet_ability'
    end

    local audits = {
        player_name = player_name,
        target_name = target_name,
    }

    if (owner_mob) then
        Update_Data('inc', damage, audits, 'pet', 'total')
    end

    if (Damage_Ability_List[ability_id]) or (ability.type == 'BloodPactRage') then
        if (damage > 0) then
            Catalog_Damage(player_name, target_name, ability_type, damage, ability_name)

            if (not actor_mob.is_npc) then
                Add_Message_To_Battle_Log(player_name, ability_name, damage, nil, nil, ability_type, ability)
            end
        end
    end

    return damage
end