local wezterm = require 'wezterm'

local config = {}

config.font_size = 12.0
config.font = wezterm.font("Cascadia Code")
config.color_scheme = "Dracula"
config.enable_tab_bar = false
config.audible_bell = "Disabled"
config.window_background_opacity = 1
config.window_background_image = "C:\\Users\\marcu\\p\\dotfiles\\img\\dragon-ball3.jpg"

config.default_prog = { "pwsh" }

-- Let ALT keys pass through to the OS (for GlazeWM keybinds)
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false

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
