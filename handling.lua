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
function Melee_Damage(result, player_name, target_name)
    local animation_id = result.animation
    local damage = result.param
    local throwing = false

    local damage_bundle = {
        value = damage,
        player_name = player_name,
        target_name = target_name,
    }

    local inc_bundle = {
        value = 1,
        player_name = player_name,
        target_name = target_name,
    }

    local dec_bundle = {
        value = 1,
        player_name = player_name,
        target_name = target_name,
    }

    Update_Data('inc', damage_bundle, 'total', 'total')
    Update_Data('inc', damage_bundle, 'total_no_sc', 'total')

    -- MELEE ------------------------------------------------------------------

    -- Main Hand
    if (animation_id == 0) then
        Update_Data('inc', damage_bundle, 'melee',         'total')
        Update_Data('inc', damage_bundle, 'melee primary', 'total')

    -- Off Hand
    elseif (animation_id == 1) then
        Update_Data('inc', damage_bundle, 'melee',           'total')
        Update_Data('inc', damage_bundle, 'melee secondary', 'total')

    -- Kicks
    elseif (animation_id == 2) or (animation_id == 3) then
        Update_Data('inc', damage_bundle, 'melee',       'total')
        Update_Data('inc', damage_bundle, 'melee kicks', 'total')

    -- RANGED -----------------------------------------------------------------

    -- Throwing
    elseif (animation_id == 4) then
        throwing = true
        Update_Data('inc', damage_bundle, 'ranged',   'total')
        Update_Data('inc', damage_bundle, 'throwing', 'total')

    else
        Add_Message_To_Chat('W', 'Melee_Damage^handling', 'Unhandled animation: '..tostring(animation_id))

    end

    -- MIN/MAX ----------------------------------------------------------------

    if throwing then
        Update_Data('inc', inc_bundle, 'ranged', 'count')
        if (damage < Get_Data(player_name, 'ranged', 'min')) then Update_Data('set', damage_bundle, 'ranged', 'min') end
        if (damage > Get_Data(player_name, 'ranged', 'max')) then Update_Data('set', damage_bundle, 'ranged', 'max') end
    else
        Update_Data('inc', inc_bundle, 'melee', 'count')
        if (damage < Get_Data(player_name, 'melee', 'min')) then Update_Data('set', damage_bundle, 'melee', 'min') end
        if (damage > Get_Data(player_name, 'melee', 'max')) then Update_Data('set', damage_bundle, 'melee', 'max') end
    end

    -- ENSPELL ----------------------------------------------------------------

    local enspell_damage = result.add_effect_param

    if (enspell_damage > 0) then

        local enspell_bundle = {
            value = enspell_damage,
            player_name = player_name,
            target_name = target_name,
        }

        -- Element of the enspell is in add_effect_animation
        Update_Data('inc', enspell_bundle, 'magic',   'total')
        Update_Data('inc', enspell_bundle, 'enspell', 'total')
        Update_Data('inc', inc_bundle, 'magic', 'count')
        if (enspell_damage < Get_Data(player_name, 'magic', 'min')) then Update_Data('set', enspell_bundle, 'magic', 'min') end
        if (enspell_damage > Get_Data(player_name, 'magic', 'max')) then Update_Data('set', enspell_bundle, 'magic', 'max') end

    end

    -- NUANCE -----------------------------------------------------------------

    local message_id = result.message

    -- Hit
    if (message_id == 1) then 
        Update_Data('inc', inc_bundle, 'melee', 'hits')
        Running_Accuracy(player_name, true)

    -- Healing with melee attacks
    elseif (message_id == 3) or (message_id == 373) then
        Update_Data('inc', inc_bundle, 'melee', 'hits')
        Update_Data('inc', damage_bundle, 'melee', 'mob heal')

    -- Misses
    elseif (message_id == 15) then 
        Update_Data('inc', inc_bundle, 'melee', 'misses')
        Running_Accuracy(player_name, false)

    -- DRK vs. Omen Gorger
    elseif (message_id == 30) then
        Add_Message_To_Chat('A', 'Melee_Damage^handling', 'Attack Nuance 30 -- DRK vs. Omen Gorger')

    -- Attack absorbed by shadows
    elseif (message_id == 31) then
        Update_Data('inc', inc_bundle, 'melee', 'hits')
        Update_Data('inc', inc_bundle, 'melee', 'shadows')

    -- Attack dodged (Perfect Dodge) / Remove the count so perfect dodge doesn't count.
    elseif (message_id == 32) then
        Update_Data('inc', dec_bundle, 'melee', 'count')

    -- Critical Hits
    elseif (message_id == 67) then 
        Update_Data('inc', inc_bundle, 'melee', 'hits')
        Update_Data('inc', inc_bundle, 'melee', 'crits')
        Update_Data('inc', damage_bundle, 'melee', 'crit damage')
        Running_Accuracy(player_name, true)

    -- Throwing Critical Hit
    elseif (message_id == 353) then
        Update_Data('inc', inc_bundle, 'ranged', 'hits')
        Update_Data('inc', inc_bundle, 'ranged', 'crits')
        Update_Data('inc', damage_bundle, 'ranged', 'crit damage')
        Running_Accuracy(player_name, true)

    -- Throwing Miss
    elseif (message_id == 354) then
        Update_Data('inc', inc_bundle, 'ranged', 'misses')
        Running_Accuracy(player_name, false)

    -- Throwing Square Hit
    elseif (message_id == 576) then
        Update_Data('inc', inc_bundle, 'ranged', 'hits')
        Running_Accuracy(player_name, true)

    -- Throwing Truestrike
    elseif (message_id == 577) then
        Update_Data('inc', inc_bundle, 'ranged', 'hits')
        Running_Accuracy(player_name, true)

    else 
        Add_Message_To_Battle_Log(player_name, 'Att. nuance '..message_id) end

    -----------------------------------------------------------------------

    local spikes = result.spike_effect_effect 
    --Add_Message_To_Chat('W', 'PARSE | Melee_Damage^handling')
    --Add_Message_To_Chat(nil, 'Unhandled spike effect '..tostring(spikes))

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
function Handle_Ranged(result, player_name, target_name)
    local damage = result.param
    local message_id = result.message

    local damage_bundle = {
        value = damage,
        player_name = player_name,
        target_name = target_name,
    }

    local inc_bundle = {
        value = 1,
        player_name = player_name,
        target_name = target_name,
    }

    Update_Data('inc', damage_bundle, 'total',  'total')
    Update_Data('inc', damage_bundle, 'total_no_sc', 'total')
    Update_Data('inc', inc_bundle, 'ranged', 'count')

    -- Miss /////////////////////////////////////////////////////////
    if (message_id == 354) then 
    	Update_Data('inc', inc_bundle, 'ranged', 'misses')
    	return

    -- Shadows //////////////////////////////////////////////////////
    elseif (message_id == 31) then
        Update_Data('inc', inc_bundle, 'ranged', 'hits')
        Update_Data('inc', inc_bundle, 'ranged', 'shadows')
        return

    -- Regular Hit //////////////////////////////////////////////////
    elseif (message_id == 352) then
        Update_Data('inc', inc_bundle, 'ranged', 'hits')
        Update_Data('inc', damage_bundle, 'ranged', 'total')
        Running_Accuracy(player_name, true)

    -- Square Hit ///////////////////////////////////////////////////
    elseif (message_id == 576) then
        Update_Data('inc', inc_bundle, 'ranged', 'hits')
        Update_Data('inc', damage_bundle, 'ranged', 'total')
        Running_Accuracy(player_name, true)

    -- Truestrike ///////////////////////////////////////////////////
    elseif (message_id == 577) then
        Update_Data('inc', inc_bundle, 'ranged', 'hits')
        Update_Data('inc', damage_bundle, 'ranged', 'total')
        Running_Accuracy(player_name, true)

    -- Crit /////////////////////////////////////////////////////////
    elseif (message_id == 353) then
        Update_Data('inc', inc_bundle, 'ranged', 'hits')
        Update_Data('inc', inc_bundle, 'ranged', 'crits')
        Update_Data('inc', damage_bundle, 'ranged', 'crit damage')
        Update_Data('inc', damage_bundle, 'ranged', 'total')
        Running_Accuracy(player_name, true)

    else
        Add_Message_To_Battle_Log(player_name, 'Ranged nuance '..message_id) end

    if (damage == 0) then
        Add_Message_To_Chat('W', 'Handle_Ranged^handling', 'Ranged damage was 0.')
    end

    if (damage < Get_Data(player_name, 'ranged', 'min')) then Update_Data('set', damage_bundle, 'ranged', 'min') end
    if (damage > Get_Data(player_name, 'ranged', 'max')) then Update_Data('set', damage_bundle, 'ranged', 'max') end

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
function Weaponskill_Damage(result, player_name, target_name, ws_name)
    local damage = result.param
    Single_Damage(player_name, target_name, 'ws', damage, ws_name)
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
        return
    end

    local spell_name = spell.en
    local damage = result.param
    local spell_mapped

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
function Handle_Ability(act, result, player_name, target_name)
    local ability_id = act.param
    local ability = Res.job_abilities[ability_id]
    local ability_name = Get_Ability_Name(act)
    local damage = result.param

    if (Damage_Ability_List[ability_id]) then

        if (damage > 0) then
            Single_Damage(player_name, target_name, 'ability', damage, ability_name)
            Add_Message_To_Battle_Log(player_name, ability_name, damage, nil, nil, 'ability', ability)
        end

    end

    return damage
end