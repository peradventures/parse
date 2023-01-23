Toggle_Horse = Window:New({
    name       = "Toggle Horse",
    message    = '[H]',
    x_pos      = 600,
    y_pos      = 95,
    padding    = 1,
    bg_alpha   = 225,
    bg_red     = 0,
    bg_green   = 0,
    bg_blue    = 15,
    bg_visible = true,
})

Toggle_Horse.Show()
Toggle_Horse.Add_Line('[H]')
Toggle_Horse.Update()

Toggle_Focus = Window:New({
    name       = "Toggle Focus",
    message    = '[F]',
    x_pos      = 635,
    y_pos      = 95,
    padding    = 1,
    bg_alpha   = 225,
    bg_red     = 0,
    bg_green   = 0,
    bg_blue    = 15,
    bg_visible = true,
})

Toggle_Focus.Show()
Toggle_Focus.Add_Line('[F]')
Toggle_Focus.Update()