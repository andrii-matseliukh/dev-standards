local wezterm = require "wezterm"

local config = wezterm.config_builder()
config.default_prog = { 'pwsh.exe' }

config.font = wezterm.font {
  family = 'RobotoMono Nerd Font Mono',
  --family = 'JetBrains Mono',
  weight = 'Medium',
  harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }, -- disable ligatures
}
config.font_size = 10.0
config.line_height = 1.1

function set_catpuccin_theme()
  local current_theme = 'Dark'
  if wezterm.gui then
    current_theme = wezterm.gui.get_appearance()
  end
  -- Latte / Frappe / Macchiato / Mocha
  if current_theme:find 'Dark' then
    return 'Catppuccin Macchiato'
  else
    return 'Catppuccin Latte'
  end
end
config.color_scheme = set_catpuccin_theme()

config.window_padding = { left = '1.1cell', right = '0.5cell', top = '0.5cell', bottom = '0.5cell' }

-- SteadyBlock, BlinkingBlock, SteadyUnderline, BlinkingUnderline, SteadyBar, and BlinkingBar
config.default_cursor_style = 'BlinkingBar'
config.cursor_thickness = '0.095cell'

--config.enable_tab_bar = false
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.window_background_opacity = 0.80

local action = wezterm.action
config.keys = {
  { key = 'd', mods = 'CTRL', action = action.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'd', mods = 'CTRL|SHIFT', action = action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'w', mods = 'CTRL|SHIFT', action = action.CloseCurrentPane { confirm = false } },
}
-- config.keys = {
--   { key = 'd', mods = 'CMD|SHIFT', action = action.SplitVertical { domain = 'CurrentPaneDomain' } },
--   { key = 'd', mods = 'CMD', action = action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
--   { key = 'k', mods = 'CMD', action = action.ClearScrollback 'ScrollbackAndViewport' },
--   { key = 'w', mods = 'CMD', action = action.CloseCurrentPane { confirm = false } },
--   { key = 'w', mods = 'CMD|SHIFT', action = action.CloseCurrentTab { confirm = false } },
--   { key = 'LeftArrow', mods = 'CMD', action = action.SendKey { key = 'Home' } },
--   { key = 'RightArrow', mods = 'CMD', action = action.SendKey { key = 'End' } },
--   { key = 'p', mods = 'CMD|SHIFT', action = action.ActivateCommandPalette },
-- }

-- (here will be added actual configuration)

return config


