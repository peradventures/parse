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
function melee_damage(result, player_name, target_name)
    local animation_id = result.animation
    local damage = result.param
    local throwing = false

    update_data('inc', damage, player_name, target_name, 'total', 'total')
    update_data('inc', damage, player_name, target_name, 'total_no_sc', 'total')

    -- MELEE ------------------------------------------------------------------

    -- Main Hand
    if animation_id == 0 then
        update_data('inc', damage, player_name, target_name, 'melee',         'total')
        update_data('inc', damage, player_name, target_name, 'melee primary', 'total')

    -- Off Hand
    elseif animation_id == 1 then
        update_data('inc', damage, player_name, target_name, 'melee',           'total')
        update_data('inc', damage, player_name, target_name, 'melee secondary', 'total')

    -- Kicks
    elseif animation_id == 2 or animation_id == 3 then 
        update_data('inc', damage, player_name, target_name, 'melee',       'total')
        update_data('inc', damage, player_name, target_name, 'melee kicks', 'total')

    -- RANGED -----------------------------------------------------------------

    -- Throwing
    elseif animation_id == 4 then
        throwing = true
        update_data('inc', damage, player_name, target_name, 'ranged',   'total')
        update_data('inc', damage, player_name, target_name, 'throwing', 'total')

    else windower.add_to_chat(c_chat, 'Parse: Unhandled animation in melee_damage: '..tostring(animation_id)) end

    -- MIN/MAX ----------------------------------------------------------------

    if throwing then
        update_data('inc', 1, player_name, target_name, 'ranged', 'count')
        if damage < get_data(player_name, 'ranged', 'min') then update_data('set', damage, player_name, target_name, 'ranged', 'min') end
        if damage > get_data(player_name, 'ranged', 'max') then update_data('set', damage, player_name, target_name, 'ranged', 'max') end
    else
        update_data('inc', 1, player_name, target_name, 'melee', 'count')
        if damage < get_data(player_name, 'melee', 'min') then update_data('set', damage, player_name, target_name, 'melee', 'min') end
        if damage > get_data(player_name, 'melee', 'max') then update_data('set', damage, player_name, target_name, 'melee', 'max') end
    end

    -- ENSPELL ----------------------------------------------------------------
    
    local enspell_damage = result.add_effect_param 

    if enspell_damage > 0 then 

        -- Element of the enspell is in add_effect_animation
        update_data('inc', enspell_damage, player_name, target_name, 'magic',   'total')
        update_data('inc', enspell_damage, player_name, target_name, 'enspell', 'total')
        update_data('inc', 1, player_name, target_name, 'magic', 'count')
        if enspell_damage < get_data(player_name, 'magic', 'min') then update_data('set', enspell_damage, player_name, target_name, 'magic', 'min') end
        if enspell_damage > get_data(player_name, 'magic', 'max') then update_data('set', enspell_damage, player_name, target_name, 'magic', 'max') end
    end

    -- NUANCE -----------------------------------------------------------------

    local message_id = result.message

    -- Hit
    if message_id == 1 then 
        update_data('inc', 1, player_name, target_name, 'melee', 'hits')
        running_acc(player_name, true)
    
    -- Healing with melee attacks
    elseif message_id == 3 or message_id == 373 then
        update_data('inc', 1,      player_name, target_name, 'melee', 'hits')
        update_data('inc', damage, player_name, target_name, 'melee', 'mob heal')

    -- Misses
    elseif message_id == 15 then 
        update_data('inc', 1, player_name, target_name, 'melee', 'misses')
        running_acc(player_name, false)

    -- DRK vs. Omen Gorger
    elseif message_id == 30 then
        windower.add_to_chat(c_chat, 'Attack nuance 30')

    -- Attack absorbed by shadows
    elseif message_id == 31 then
        update_data('inc', 1, player_name, target_name, 'melee', 'hits')
        update_data('inc', 1, player_name, target_name, 'melee', 'shadows')
    
    -- Attack dodged (Perfect Dodge) / Remove the count so perfect dodge doesn't count.
    elseif message_id == 32 then
        update_data('inc', -1, player_name, target_name, 'melee', 'count')

    -- Critical Hits
    elseif message_id == 67 then 
        update_data('inc', 1,      player_name, target_name, 'melee', 'hits')
        update_data('inc', 1,      player_name, target_name, 'melee', 'crits')
        update_data('inc', damage, player_name, target_name, 'melee', 'crit damage')
        running_acc(player_name, true)

    -- Throwing Critical Hit
    elseif message_id == 353 then
        update_data('inc', 1,      player_name, target_name, 'ranged', 'hits')
        update_data('inc', 1,      player_name, target_name, 'ranged', 'crits')
        update_data('inc', damage, player_name, target_name, 'ranged', 'crit damage')
        running_acc(player_name, true)
        
    -- Throwing Miss
    elseif message_id == 354 then
        update_data('inc', 1, player_name, target_name, 'ranged', 'misses')
        running_acc(player_name, false)

    -- Throwing Square Hit
    elseif message_id == 576 then
        update_data('inc', 1, player_name, target_name, 'ranged', 'hits')
        running_acc(player_name, true)

    -- Throwing Truestrike
    elseif message_id == 577 then
        update_data('inc', 1, player_name, target_name, 'ranged', 'hits')
        running_acc(player_name, true)
  
    else Add_Message_To_Battle_Log(player_name, 'Att. nuance '..message_id) end

    -----------------------------------------------------------------------

    local spikes = result.spike_effect_effect 
    --windower.add_to_chat(c_chat, 'Unhandled spike effect '..tostring(spikes))

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
function handle_ranged(result, player_name, target_name)
    local damage = result.param
    local message_id = result.message
    
    update_data('inc', damage, player_name, target_name, 'total',  'total')
    update_data('inc', damage, player_name, target_name, 'total_no_sc', 'total')
    update_data('inc', 1,      player_name, target_name, 'ranged', 'count')

    -- Miss /////////////////////////////////////////////////////////
    if message_id == 354 then 
    	update_data('inc', 1, player_name, target_name, 'ranged', 'misses')
    	return

    -- Shadows //////////////////////////////////////////////////////
    elseif message_id == 31 then
        update_data('inc', 1, player_name, target_name, 'ranged', 'hits')
        update_data('inc', 1, player_name, target_name, 'ranged', 'shadows')
        return

    -- Regular Hit //////////////////////////////////////////////////
    elseif message_id == 352 then
        update_data('inc', 1,      player_name, target_name, 'ranged', 'hits')
        update_data('inc', damage, player_name, target_name, 'ranged', 'total')

    -- Square Hit ///////////////////////////////////////////////////
    elseif message_id == 576 then
        update_data('inc', 1,      player_name, target_name, 'ranged', 'hits')
        update_data('inc', damage, player_name, target_name, 'ranged', 'total')

    -- Truestrike ///////////////////////////////////////////////////
    elseif message_id == 577 then
        update_data('inc', 1,      player_name, target_name, 'ranged', 'hits')
        update_data('inc', damage, player_name, target_name, 'ranged', 'total')

    -- Crit /////////////////////////////////////////////////////////
    elseif message_id == 353 then
        update_data('inc', 1, player_name, target_name, 'ranged', 'hits')
        update_data('inc', 1, player_name, target_name, 'ranged', 'crits')
        update_data('inc', damage, player_name, target_name, 'ranged', 'crit damage')
        update_data('inc', damage, player_name, target_name, 'ranged', 'total')

    else Add_Message_To_Battle_Log(player_name, 'Ranged nuance '..message_id) end

    if damage == 0 then windower.add_to_chat(c_chat, 'Ranged damage was 0') end
    if damage < get_data(player_name, 'ranged', 'min') then update_data('set', damage, player_name, target_name, 'ranged', 'min') end
    if damage > get_data(player_name, 'ranged', 'max') then update_data('set', damage, player_name, target_name, 'ranged', 'max') end

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
function weaponskill_damage(result, player_name, target_name, ws_name)
    local damage = result.param
    single_damage(player_name, target_name, 'ws', damage, ws_name)
    return damage
end

--[[
    DESCRIPTION:    Handle skillchain damage
    PARAMETERS :    
        result      Data for each action taken on a target
        actor_name  Primary node
        sc_name		Name of the weaponskill
]] 
function skillchain_damage(result, player_name, target_name, sc_name)
    local damage = result.add_effect_param
    single_damage(player_name, target_name, 'sc', damage, sc_name)
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
        act 		Action data
        result      Data for each action taken on a target
        actor       Primary node
        sc_name		Name of the weaponskill
]] 
function Handle_Spell(act, result, player_name, target_name)
    local spell_id = act.param
    local spell = Res.spells[spell_id]

    if not spell and show_error then
        windower.add_to_chat(c_chat, player_name..' handle_spell: Couldn\'t find spell '..tostring(spell_id)..' in spells.')
        return
    end

    local spell_name = spell.en
    local damage = result.param

    if damage_spells[spell_id] then
        single_damage(player_name, target_name, 'magic', damage, spell_name)
    end

    -- Need to handle overcure if possible too
    if healing_spells[spell_id] then
    	single_damage(player_name, target_name, 'healing', damage, spell_name)
    end
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
function handle_ability(act, result, player_name, target_name)
    local ability_id = act.param
    local ability_name = get_ability_name(act)
    --windower.add_to_chat(c_chat, 'handle_ability: '..tostring(ability_name))   
    local damage = result.param

    if damage_abilities[ability_id] then

        if damage > 0 then
            update_data('inc', damage, player_name, target_name, 'total', 'total')
            update_data('inc', damage, player_name, target_name, 'total_no_sc', 'total')
            update_data('inc', 1, player_name, target_name, 'ability', 'hits')
            single_damage(player_name, target_name, 'ability', damage, ability_name)
            Add_Message_To_Battle_Log(player_name, ability_name, damage, nil, nil)
        end

    end
end