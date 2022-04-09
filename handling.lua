-- ******************************************************************************************************
-- *
-- *                                            Melee Attacks
-- *
-- ******************************************************************************************************

--[[
    DESCRIPTION:    Set a node to a particular value.
    PARAMETERS :
        result      Data for each action taken on a target.
        actor       Primary node.
    NOTES      :
    	message 				https://github.com/Windower/Lua/wiki/Message-IDs
    	has_add_effect			Boolean
    	add_effect_animation	https://github.com/Windower/Lua/wiki/Additional-Effect-IDs
    							Enspell element
   		add_effect_message		229: comes up with Ygnas bonus attack
   		add_effect_param		Enspell damage
    	spike_effect_param		0: Consistently on MNK vs Apex bats
    	spike_effect_effect	
   		effect 					2: Killing blow
   								4: Counter? (probably not)
   		stagger 				Animation the target does when being hit
   		reaction 				8: Hit; Consistently on MNK vs Apex bats
   								9: Miss?; Very rarely on MNK vs Apex bats
]] 
function Melee_Damage(result, player_name, target_name, owner_mob)
    local animation_id = result.animation
    local damage = result.param
    local throwing = false

    -- Need special handling for pets
    local broad_melee_type, discrete_melee_type
    if (owner_mob) then
        broad_melee_type    = 'pet_melee'
        discrete_melee_type = 'pet_melee_discrete'
        player_name = owner_mob.name
    else
        broad_melee_type    = 'melee'
        discrete_melee_type = Get_Discrete_Melee_Type(animation_id)
    end

    local audits = {
        player_name = player_name,
        target_name = target_name,
    }

    Update_Data('inc', damage, audits, 'total', 'total')
    Update_Data('inc', damage, audits, 'total_no_sc', 'total')
    Update_Data('inc', damage, audits, discrete_melee_type, 'total')
    Update_Data('inc',      1, audits, discrete_melee_type, 'count')

    if (owner_mob) then
        Update_Data('inc', damage, audits, 'pet', 'total')
    end

    -- MELEE ------------------------------------------------------------------
    if (animation_id >= 0) and (animation_id < 4) then
        Update_Data('inc', damage, audits, broad_melee_type, 'total')
        Update_Data('inc',      1, audits, broad_melee_type, 'count')

    -- THROWING ---------------------------------------------------------------
    elseif (animation_id == 4) then
        throwing = true
        Update_Data('inc', damage, audits, 'ranged', 'total')
        Update_Data('inc',      1, audits, 'ranged', 'count')

    -- UNHANDLED ANIMATION ----------------------------------------------------
    else
        Add_Message_To_Chat('W', 'Melee_Damage^handling', 'Unhandled animation: '..tostring(animation_id))
    end

    -- MIN/MAX ----------------------------------------------------------------
    if throwing then
        if (damage < Get_Data(player_name, 'ranged', 'min')) then Update_Data('set', damage, audits, 'ranged', 'min') end
        if (damage > Get_Data(player_name, 'ranged', 'max')) then Update_Data('set', damage, audits, 'ranged', 'max') end
    else
        if (damage < Get_Data(player_name, broad_melee_type, 'min')) then Update_Data('set', damage, audits, broad_melee_type, 'min') end
        if (damage > Get_Data(player_name, broad_melee_type, 'max')) then Update_Data('set', damage, audits, broad_melee_type, 'max') end
    end

    -- ENSPELL ----------------------------------------------------------------
    local enspell_damage = result.add_effect_param

    if (enspell_damage > 0) then

        -- Element of the enspell is in add_effect_animation
        Update_Data('inc', enspell_damage, audits, 'magic',   'total')
        Update_Data('inc', enspell_damage, audits, 'enspell', 'total')
        Update_Data('inc',              1, audits, 'magic', 'count')
        if (enspell_damage < Get_Data(player_name, 'magic', 'min')) then Update_Data('set', enspell_damage, audits, 'magic', 'min') end
        if (enspell_damage > Get_Data(player_name, 'magic', 'max')) then Update_Data('set', enspell_damage, audits, 'magic', 'max') end

    end

    -- NUANCE -----------------------------------------------------------------
    local message_id = result.message

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

    -----------------------------------------------------------------------

    local spikes = result.spike_effect_effect

    return damage
end

-- ******************************************************************************************************
-- *
-- *                                           Ranged Attacks
-- *
-- ******************************************************************************************************

--[[
    DESCRIPTION:    Set a node to a particular value.
    PARAMETERS :    
        result      Data for each action taken on a target.
        actor       Primary node.
]]
function Handle_Ranged(result, player_name, target_name, owner_mob)
    local damage = result.param
    local message_id = result.message

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

    if (damage < Get_Data(player_name, ranged_type, 'min')) then Update_Data('set', damage, audits, ranged_type, 'min') end
    if (damage > Get_Data(player_name, ranged_type, 'max')) then Update_Data('set', damage, audits, ranged_type, 'max') end

    return damage
end

-- ******************************************************************************************************
-- *
-- *                                     Weaponskills and Skillchains
-- *
-- ******************************************************************************************************

--[[
    DESCRIPTION:    Handle weaponskill damage
    PARAMETERS :    
        result      Data for each action taken on a target
        actor_name  Primary node
        ws_name		Name of the weaponskill
]] 
function Weaponskill_Damage(result, player_name, target_name, ws_name, owner_mob)
    local damage = result.param

    local ws_type
    if (owner_mob) then
        player_name = owner_mob.name
        ws_type = 'pet_ws'
    else
        ws_type = 'ws'
    end

    local audits = {
        player_name = player_name,
        target_name = target_name,
    }

    if (owner_mob) then
        Update_Data('inc', damage, audits, 'pet', 'total')
    end

    Single_Damage(player_name, target_name, ws_type, damage, ws_name)

    return damage
end

--[[
    DESCRIPTION:    Handle skillchain damage
    PARAMETERS :    
        result      Data for each action taken on a target
        actor_name  Primary node
        sc_name		Name of the weaponskill
]] 
function Skillchain_Damage(result, player_name, target_name, sc_name)
    local damage = result.add_effect_param
    Single_Damage(player_name, target_name, 'sc', damage, sc_name)
    return damage
end

-- ******************************************************************************************************
-- *
-- *                                                  Magic
-- *
-- ******************************************************************************************************

--[[
    DESCRIPTION:    Handle spell damage (including healing)
    PARAMETERS :
]]
function Handle_Spell(act, result, player_name, target_name)
    local spell_id = act.param
    local spell = Res.spells[spell_id]

    if (not spell) then
        Add_Message_To_Chat('W', 'Handle_Spell^handling', 'Couldn\'t find spell ID '..tostring(spell_id)..' in spells for '..player_name)
        return 0
    end

    local spell_name = spell.en
    local damage = result.param
    local spell_mapped = false

    if (Damage_Spell_List[spell_id]) then
        Single_Damage(player_name, target_name, 'magic', damage, spell_name)
        spell_mapped = true
    end

    -- TO DO: Handle Overcure
    if (Healing_Spell_List[spell_id]) then
    	Single_Damage(player_name, target_name, 'healing', damage, spell_name)
        spell_mapped = true
    end

    if (not spell_mapped) then
        --Add_Message_To_Chat('W', 'Handle_Spell^handling', tostring(spell_name)..' is not included in Damage_Spells global.')
    end

    if (not damage) then damage = 0 end

    return damage
end

-- ******************************************************************************************************
-- *
-- *                                               Abilities
-- *
-- ******************************************************************************************************

--[[
    DESCRIPTION:    Handle ability damage. This includes pet damage (since they are ability based)
    PARAMETERS :    
        act 		Action data
        result      Data for each action taken on a target
        actor       Primary node
]] 
function Handle_Ability(act, result, actor, target_name, owner_mob)
    local player_name = actor.name
    local ability_id = act.param
    local ability = Res.job_abilities[ability_id]
    local ability_name = Get_Ability_Name(act)
    local damage = result.param

    local ability_type
    if (owner_mob) then
        ability_type = 'pet_ability'
    else
        ability_type = 'ability'
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
            Single_Damage(player_name, target_name, ability_type, damage, ability_name)

            if (not actor.is_npc) then
                Add_Message_To_Battle_Log(player_name, ability_name, damage, nil, nil, ability_type, ability)
            end
        end

    end

    return damage
end