local wezterm = require 'wezterm'

local config = {}

print("testing the storm")

config.font_size = 12.0
config.font = wezterm.font("Cascadia Code")
config.color_scheme = "Dracula"
config.enable_tab_bar = false
config.window_background_opacity = 1
config.window_background_image = "C:\\Users\\mshepherd\\pics\\stone2.jpg"

config.default_prog = { "pwsh", "-NoLogo", "-NoExit", "-Command", "$PROFILE" }

-- config.leader = { key="a", mods="CTRL", timeout_milliseconds=1000 }
config.keys = {
    -- {
    --     key='-',
    --     action = wezterm.action{SplitHorizontal={domain="CurrentPaneDomain"}},
    -- }
    {
        key = 'q',
        mods = 'CTRL',
        action = wezterm.action.CloseCurrentPane { confirm = true },
    },

    {
        key = 'M',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.ActivateTabRelative(-1),
    },

    {
        key = 'D',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.ActivateTabRelative(1),
    },

    {
        key = 'h',
        mods = 'CTRL',
        action = wezterm.action.ActivatePaneDirection("Left"),
    },

    {
        key = 'l',
        mods = 'CTRL',
        action = wezterm.action.ActivatePaneDirection("Right"),
    },

    {
        key = 'j',
        mods = 'CTRL',
        action = wezterm.action.ActivatePaneDirection("Down"),
    },

    {
        key = 'k',
        mods = 'CTRL',
        action = wezterm.action.ActivatePaneDirection("Up"),
    },

}


return config
