local M = {}

local wezterm = require("wezterm")

M.theme_name = "Catppuccin Mocha"
M.theme = wezterm.color.get_builtin_schemes()[M.theme_name]

return M
