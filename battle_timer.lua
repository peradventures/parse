Timers = {}

-- Populate a claim list by mob name to account for duplicate mob names.
-- Loop through that list to check claim IDs. But then how do we identify the mobs?

--[[
    DESCRIPTION:
    PARAMETERS :
]]
function Check_Mobs()
	local mob_list = windower.ffxi.get_mob_array()
	local claim, claimed_by

    for _, mob in pairs(mob_list) do

		claim = mob.claim_id
		claimed_by = windower.ffxi.get_mob_by_id(claim)

		if (claimed_by) then

			-- If the claimer is in our alliance...
			if (Find_Party_Member_By_Name(claimed_by.name, 'name')) then

				if (mob.hpp == 0) then
					Remove_Mob_From_Claim_List(mob)
				else
					Add_Mob_To_Claim_List(mob)
				end

			end

		end

    end
end

--[[
    DESCRIPTION:
    PARAMETERS :
]]
function Add_Mob_To_Claim_List(mob_data)

	if (not Has_Timer_Started(mob_data.name)) then
		Start_Timer(mob_data.name)
	end

end

--[[
    DESCRIPTION:
    PARAMETERS :
]]
function Remove_Mob_From_Claim_List(mob_data)

	if (Has_Timer_Started(mob_data.name)) then
		Stop_Timer(mob_data.name)
	end

end

--[[
    DESCRIPTION:
    PARAMETERS :
]]
function Initialize_Mob_Timer(mob)
	Timers[mob.id] = {}
	Timers[mob.id] = mob.name
	Timers[mob.id]['total_time'] = 0
	Timers[mob.id]['start_time'] = os.time()
end

--[[
    DESCRIPTION:
    PARAMETERS :
]]
function Start_Timer(mob_name)

	if (not Timers[mob_name]) then
		Initialize_Mob_Timer(mob_name)
		return
	end

	Timers[mob_name]['start_time'] = os.time()
end

--[[
    DESCRIPTION:
    PARAMETERS :
]]
function Stop_Timer(mob_name)

	if (not Timers[mob_name]) then
		Initialize_Mob_Timer(mob_name)
	end

	local total_time = Timers[mob_name]['total_time']
	local time_difference = os.time() - Timers[mob_name]['start_time']

	 Timers[mob_name]['total_time'] = total_time + time_difference
	 Timers[mob_name]['start_time'] = nil
end

--[[
    DESCRIPTION:
    PARAMETERS :
]]
function Has_Timer_Started(mob_name)

	-- If this is the first time seeing the mob then initialize it
	if (not Timers[mob_name]) then
		Initialize_Mob_Timer(mob_name)
		return true
	end

	-- If this mob is already cached then check to see if the timer is running
	if (not Timers[mob_name]['start_time']) then
		return false
	else
		return true
	end

end

--[[
    DESCRIPTION:    Elapsed time since the start of the timer.
    PARAMETERS :
    	node 		Alert type
    	raw			TRUE: Raw amount of seconds; FALSE: Formatted time.
    RETURNS    :
					Elapsed time (formatted)
]] 
function Get_Elapsed_Time(node, raw)
	local diff
	local now = os.time()

	if (Has_Timer_Started(node)) then diff = now - Timers[node]
	else diff = 0 end

	if (not raw) then return format_time(diff) else return diff end
end