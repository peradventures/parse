Window = {}
Images = require('images')
Texts  = require('texts')

------------------------------------------------------------------------------------------------------
-- Screen items are basically windows on the screen that show words.
-- They should be populated by some update function that runs off of the prerender event.
--
-- BASIC WINDOW CREATION:
-- Window_Name = Window:New({
--      name     = 'ability left',
--      message  = 'ability left',
--      x_pos    = 1150,
--      y_pos    = 400,
-- })
--
-- ADD STUFF TO WINDOW
-- Window_Name.Add_Line("stuff")
--
-- UPDATE WINDOW / APPLY THE STUFF YOU'VE ADDED
-- Window_Name.Update()
-- Note: You do this after you've added all the stuff.
------------------------------------------------------------------------------------------------------
function Window:New(object)

    local self = {}
    object = object or {}

    -- Text Object Defaults
    local name         = object.name         or 'Name'
    local message      = object.message      or 'Message'
    local x_pos        = object.x_pos        or 800
    local y_pos        = object.y_pos        or 300
    local bg_red       = object.bg_red       or 255
    local bg_green     = object.bg_green     or 0
    local bg_blue      = object.bg_blue      or 0
    local bg_alpha     = object.bg_alpha     or 255
    local bg_visible   = object.bg_visible   or false
    local stroke_red   = object.stroke_red   or 28
    local stroke_green = object.stroke_green or 28
    local stroke_blue  = object.stroke_blue  or 28
    local font         = object.font         or 'Consolas'
    local font_size    = object.font_size    or 10
    local padding      = object.padding      or 0
    local bold         = object.bold         or true
    local draggable    = object.draggable    or true

    -- For objects that need to disappear after some amount of time
    local creation_time = os.time()
    local transparency  = 0
    local view_time     = object.view_time or 5
    local hide_rate     = object.hide_rate or 0.03

    -- For objects that need to pulsate
    local pulse_step = 0
    local pulse_mod  = 17

    -- Other misc settings
    local is_visible = true
    local hide_on_logout = object.hide_on_logout or true
    local show_default_message = object.show_default_message or false

    -- List of settings can be found in the texts.lua default_settings table
    local settings = {
        pos     = {x = x_pos, y = y_pos},
        bg      = {red = bg_red, green = bg_green, blue = bg_blue, alpha = bg_alpha},
        text    = {font = font, size = font_size},
        padding = padding,
        flags   = {bold = bold, draggable = draggable},
    }

    -- Initialize the text object
    local content = {}
    content.token = message

    local window = Texts.new('${token}', settings)
    Texts.stroke_width(window, 2)
    Texts.stroke_color(window, stroke_red, stroke_green, stroke_blue)
    Texts.bg_visible(window, bg_visible)
    if (show_default_message) then window:update(content) end
    Texts.show(window)

    ------------------------------------------------------------------------------------------------------
    -- Returns the window's name.
    ------------------------------------------------------------------------------------------------------
    function self.Name()
        return name
    end

    ------------------------------------------------------------------------------------------------------
    -- Shows the window.
    ------------------------------------------------------------------------------------------------------
    function self.Show()
        if (not is_visible) then
            Texts.show(window)
            is_visible = true
        end
    end

    ------------------------------------------------------------------------------------------------------
    -- Hides the window.
    ------------------------------------------------------------------------------------------------------
    function self.Hide()
        if (is_visible) then
            Texts.hide(window)
            is_visible = false
        end
    end

    ------------------------------------------------------------------------------------------------------
    -- Toggles window visibility.
    ------------------------------------------------------------------------------------------------------
    -- function self.Toggle_Window()
    --     if (is_visible) then self.Hide()
    --     else self.Show() end
    -- end

    ------------------------------------------------------------------------------------------------------
    -- Handles hiding when logged out.
    -- The prerender will generally call a function that updates the window via Update.
    -- This function gets called in Update so it can be thought of as running during prerender.
    ------------------------------------------------------------------------------------------------------
    function self.Window_Visibility(visibility)
        if (visibility == nil) then
            visibility = true
        end

        local game_info = windower.ffxi.get_info()
        if (not game_info) or (not game_info.logged_in) then
            if (hide_on_logout) then
                self.Hide()
            else
                self.Show()
            end
        else
            if (visibility) then
                self.Show()
            else
                self.Hide()
            end
        end
    end

    ------------------------------------------------------------------------------------------------------
    -- Sets the window's position on the screen.
    ------------------------------------------------------------------------------------------------------
    function self.Set_Box_Position(new_x, new_y)
        if (new_x) then x_pos = new_x end
        if (new_y) then y_pos = new_y end
        Texts.pos(window, x_pos, y_pos)
    end

    ------------------------------------------------------------------------------------------------------
    -- Returns the window's position to the caller.
    ------------------------------------------------------------------------------------------------------
    function self.Get_Position()
        return {x = x_pos, y = y_pos}
    end

    ------------------------------------------------------------------------------------------------------
    -- Clears the content of the window.
    ------------------------------------------------------------------------------------------------------
    function self.Clear()
        self.Update()
    end

    ------------------------------------------------------------------------------------------------------
    -- Adds a new line to the window content.
    ------------------------------------------------------------------------------------------------------
    function self.Add_Line(new_data)
        table.insert(content, new_data)
    end

    ------------------------------------------------------------------------------------------------------
    -- Updates the window's text with the contents of the 'content' variable.
    ------------------------------------------------------------------------------------------------------
    function self.Update(visibility)
        self.Window_Visibility(visibility)

        local final = {}
        for _, text_line in ipairs(content) do
            final[#final+1] = tostring(text_line)
        end
        final.token = table.concat(final, "\n")
        window:update(final)

        content = {}
    end

    ------------------------------------------------------------------------------------------------------
    -- Turns the background on or off.
    ------------------------------------------------------------------------------------------------------
    function self.BG_Visibility(visible)
        Texts.bg_visible(window, visible)
    end

    ------------------------------------------------------------------------------------------------------
    -- Sets the background color.
    ------------------------------------------------------------------------------------------------------
    function self.BG_Color(red, green, blue)
        Texts.bg_color(window, red, green, blue)
    end

    ------------------------------------------------------------------------------------------------------
    -- Pulses the window's background color.
    -- If you think of a pulsation as a flip book then...
    -- pulse_step is which page you are currently on.
    -- pulse_mod is how many pages are in the book.
    -- The visibility of the background is determined by what step in the pulsation you are on.
    ------------------------------------------------------------------------------------------------------
    function self.Pulse()
        pulse_step = (pulse_step + 1) % pulse_mod

        local denominator
        if (pulse_step == 0) then
            denominator = 1
        else
            denominator = pulse_step
        end

        local new_alpha = 255 / denominator
        Texts.bg_alpha(window, new_alpha)
    end

    ------------------------------------------------------------------------------------------------------
    -- Updates the creation time to keep the window from fading too early. An example of this would be
    -- refreshing the time when cycling in a selection list or when another dangerous move is used for
    -- an alert window.
    ------------------------------------------------------------------------------------------------------
    function self.Update_Creation_Time()
        creation_time = os.time()
        transparency = 0
        Texts.visible(window, true)
        Texts.transparency(window, transparency)
        Texts.bg_transparency(window, transparency)
    end

    ------------------------------------------------------------------------------------------------------
    -- Gradually fades the window's transparency to zero based on the creation time.
    -- After the window is a certain time (in seconds) old--the view_time--then it will start to fade.
    ------------------------------------------------------------------------------------------------------
    function self.Fade()
        if (not creation_time) then
            windower.add_to_chat(C_Chat, 'Window '..name..' cannot be faded.')
            return
        end

        if ((os.time() - creation_time) < view_time) then return end

        transparency = transparency + hide_rate
        if (transparency > 1) then
            transparency = 1
            Texts.visible(window, false)
        end

        Texts.transparency(window, transparency)
        Texts.bg_transparency(window, transparency)
    end

    ------------------------------------------------------------------------------------------------------
    -- Returns the text object.
    ------------------------------------------------------------------------------------------------------
    function self.Text_Object()
        return window
    end

    return self

 end

------------------------------------------------------------------------------------------------------
-- Handles interactions with the text objects.
------------------------------------------------------------------------------------------------------
 windower.register_event('mouse', function(type, x, y, delta, blocked)
    if (blocked) then
        -- Mouse left release
        if (type == 2) then
            if (Texts.hover(Toggle_Horse.Text_Object(), x, y)) then
                Settings.HorseRace.Show = not Settings.HorseRace.Show
            elseif (Texts.hover(Toggle_Focus.Text_Object(), x, y)) then
                Settings.Focus.Show = not Settings.Focus.Show
                Refresh_Focus_Window()
            end
        end
    end
end)