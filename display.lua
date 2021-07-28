horse_box, horse_content = build_hud_box(500, 50, nil, 9, 50)
blog_box,  blog_content  = build_hud_box(1200,  800, nil, 9, 50)
Texts.stroke_width(horse_box, 3)

Column_Widths = {
    ['name']   = 15,
    ['dmg']    = 11,
    ['small']  = 8,
    ['single'] = 4
}

Column_Widths_Compact = {
    ['name']   = 10,
    ['dmg']    = 8,
    ['small']  = 8,
    ['single'] = 4
}

Mob_Filter = nil
top_rank_default = 6
top_rank = top_rank_default

Compact_Mode         = true
Show_Crit            = false
Show_Total_Acc       = false
Include_SC_Damage    = false
show_percent         = false
combine_damage_types = true
show_healing         = false

-- Horse
show_horse    = true
percent       = true
show_alliance = false
melee_heal    = true

require('focus_window')
require('horse_race_window')

-- ******************************************************************************************************
-- *
-- *                                               Functional
-- *
-- ******************************************************************************************************

--[[
    DESCRIPTION:    Updates the parser on the screen.
]] 
function Update_Parser()
    horse_race()
    horse_box:update(horse_content)
    if show_horse then horse_box:show() else horse_box:hide() end              
end



--[[
    DESCRIPTION:    Makes certain windows visible/invisible
    PARAMETERS :    
        window      Name of the Window to turn on or off
]] 
function Toggle_Window_Display(window)
    if window == 'blog' then 
        Show_Blog  = not Show_Blog  
        Update_Blog()
        windower.add_to_chat(c_chat, 'Showing blog: ' ..tostring(Show_Blog))
    
    elseif window == 'horse' then 
        show_horse = not show_horse
        Update_Parser() 
        windower.add_to_chat(c_chat, 'Showing horse: '..tostring(show_horse))
    
    else windower.add_to_chat(c_chat, tostring(window)..' is an unknown window and cannot be toggled.') end
end