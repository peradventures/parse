Hud_X_Pos        = 1275
Hud_Y_Pos        = 315
Hud_Draggable    = true
Hud_Font         = 'Consolas'
Hud_Font_Size    = 10
Hud_Transparency = 225 -- a value of 0 (invisible) to 255 (no transparency at all)
Stroke_Width     = 2

--[[
    DESCRIPTION:    Creates a text object.
    PARAMETERS :
        x           X coordinate for the top left corner of the box (left to right)
        y           Y coordinate for the top left corner of the box (top to bottom)
        font        Font for the text box
        font_size   Font size
        alpha       Transparency of the background
        red         Background RGB
        blue        Background RGB
        green       Background RGB
        drag        Can you move the box with the mouse?
    RETURNS    :
        window      The actual box object
        content     Content to put inside of the box
]] 
function Create_Window(x_pos, y_pos, font_size, font, bg_alpha, bg_red, bg_blue, bg_green, drag, stroke)
    local content = {}

    if (x_pos     == nil) then x_pos = 0 end
    if (y_pos     == nil) then y_pos = 0 end
    if (font      == nil) then font = Hud_Font end
    if (font_size == nil) then font_size = Hud_Font_Size end
    if (bg_alpha  == nil) then bg_alpha = Hud_Transparency end
    if (bg_red    == nil) then bg_red = 0 end
    if (bg_blue   == nil) then bg_blue = 15 end
    if (bg_green  == nil) then bg_green = 0 end
    if (drag      == nil) then drag = Hud_Draggable end
    if (stroke    == nil) then stroke = Stroke_Width end

    local settings = {
        pos     = {x = x_pos, y = y_pos},
        text    = {font = font, size = font_size, Fonts = {'sans-serif'},},
        bg      = {alpha = bg_alpha, red = 0, green = 0, blue = 15},
        flags   = {draggable = drag},
        padding = 7
    }

    local window = Texts.new('${token}', settings)

    return window, content
end

--[[
    DESCRIPTION:    Takes all of the elements in a table and applies them to a table?
                    I didn't write this code.
    PARAMETERS :
        s           Strings in the table.
]] 
function Concat_Strings(s)
    local t = { }
    for k,v in ipairs(s) do
        t[#t+1] = tostring(v)
    end
    return table.concat(t,"\n")
end