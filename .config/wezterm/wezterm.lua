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

config.skip_close_confirmation_for_processes_named = {

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
  {
    key = 'Home',
    mods = 'NONE',
    action = wezterm.action.SendString '\x01', -- Ctrl-A
  },
  {
    key = 'End',
    mods = 'NONE',
    action = wezterm.action.SendString '\x05', -- Ctrl-E
  },
  {
    key = 'LeftArrow',
    mods = 'CMD',
    action = wezterm.action.SendString '\x01', -- Ctrl-A
  },
  {
    key = 'RightArrow',
    mods = 'CMD',
    action = wezterm.action.SendString '\x05', -- Ctrl-E
  },
  {
    key = 'w',
    mods = 'CMD',
    action = wezterm.action.CloseCurrentTab { confirm = true },
  },
}

return config
