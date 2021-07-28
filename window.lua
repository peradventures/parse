use_UI           = true
hud_x_pos        = 1275
hud_y_pos        = 315
hud_draggable    = true
hud_font         = 'Consolas'
hud_font_size    = 10
hud_transparency = 225 -- a value of 0 (invisible) to 255 (no transparency at all)
stroke_width     = 2

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
function build_hud_box(x, y, font, font_size, alpha, red, blue, green, drag, stroke)
    local content = {}
    local box_info = {}
    
    if x         == nil then x = 0 end
    if y         == nil then y = 0 end
    if font      == nil then font = hud_font end
    if font_size == nil then font_size = hud_font_size end
    if alpha     == nil then alpha = hud_transparency end
    if red       == nil then red = 0 end
    if blue      == nil then blue = 15 end
    if green     == nil then green = 0 end
    if drag      == nil then drag = hud_draggable end
    if stroke    == nil then stroke = stroke_width end

    box_info.box = {
        pos     = {x = x, y = y},
        text    = {font = font, size = font_size, Fonts = {'sans-serif'},},
        bg      = {alpha = alpha, red = 0, green = 0, blue = 15},
        flags   = {draggable = drag},
        padding = 7
    }
    local window = Texts.new(box_info.box)
    initialize(window)
    return window, content
end

--[[
    DESCRIPTION:    Initialize the text object.
                    I didn't write this code.
    PARAMETERS :
        text        Text object (the window)
]] 
function initialize(text)
    local properties = L{}
    properties:append('${modestates}')
    text:clear()
    text:append(properties:concat('\n'))
end

--[[
    DESCRIPTION:    Takes all of the elements in a table and applies them to a table?
                    I didn't write this code.
    PARAMETERS :
        s           Strings in the table.
]] 
function concat_strings(s)
    local t = { }
    for k,v in ipairs(s) do
        t[#t+1] = tostring(v)
    end
    return table.concat(t,"\n")
end