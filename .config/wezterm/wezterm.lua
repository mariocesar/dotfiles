local wezterm = require 'wezterm'
local config = {}

config.font = wezterm.font 'FiraMono Nerd Font Mono'
config.font_size = 12
config.color_scheme = 'Tokyo Night'
config.window_decorations = 'RESIZE'
config.initial_cols = 100
config.initial_rows = 40

config.colors = {
  background = '#202124'
}

config.leader = {
  key = 'a',
  mods = 'CTRL',
  timeout_milliseconds = 1000
}

config.keys = {
  {
    key = '%',
    mods = 'LEADER',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  {
    key = '"',
    mods = 'LEADER',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },
}

return config
