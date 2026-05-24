--[[
==================================
             Config
==================================
--]]

config = {
    appearance = {
        color_active   = "#5e81ac",
        color_chord    = "#b48ead",
        color_inactive = "#3b4252",

        gaps = 5,
        border_width = 2,
        master_ratio = 0.5,

        scratchpad_width  = 0.8,
        scratchpad_height = 0.7,
    },

    startup = {
        "firefox",
    },

    scratchpads = {
        {
            name = "alacritty",
            cmd  = "alacritty -class scratchpad",
            class = "scratchpad"
        }
    }
}

MOD   = {"Mod"}
ALT   = {"Alt"}
SHIFT = {"Shift"}

for _, cmd in ipairs(config.startup) do
    wm.exec(cmd)
end

bind("Return", MOD, function()
    wm.exec("kitty")
end)

bind("r", MOD, function()
    wm.reload()
end)

bind("space", MOD, function()
    wm.activate_chord()
end)


--[[
==================================
             Focus
==================================
--]]

bind("h", MOD, function() wm.focus(Direction.LEFT)  end)
bind("l", MOD, function() wm.focus(Direction.RIGHT) end)
bind("k", MOD, function() wm.focus(Direction.UP)    end)
bind("j", MOD, function() wm.focus(Direction.DOWN)  end)


--[[
==================================
         Window Movement
==================================
--]]
bind("h", { "Mod", "Shift" }, function()
    wm.move_window(Direction.LEFT)
end)

bind("l", { "Mod", "Shift" }, function()
    wm.move_window(Direction.RIGHT)
end)

bind("k", { "Mod", "Shift" }, function()
    wm.move_window(Direction.UP)
end)

bind("j", { "Mod", "Shift" }, function()
    wm.move_window(Direction.DOWN)
end)

--[[
==================================
  Workspace Navigation
==================================
--]]

for i = 1, 9 do
    bind(tostring(i), MOD, function()
        wm.focus_workspace(i - 1)
    end)

    bind(tostring(i), { "Mod", "Shift" }, function()
        wm.move_window_workspace(i - 1)
    end)
end

--[[
==================================
             MISC
==================================
--]]

bind("q", MOD, function()
    wm.close()
end)


chord("space", MOD, {
    q = function()
        wm.quit();
    end
})
