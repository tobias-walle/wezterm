local M = {}

local wezterm = require("wezterm")

---@param config table
---@param theme_name string
function M.configure_theme(config, theme_name)
	M.colors = require("plugins.catppuccin").get_colors(theme_name)

	M.theme = wezterm.color.get_builtin_schemes()[theme_name]
	M.theme.indexed[16] = nil
	M.theme.tab_bar.inactive_tab.bg_color = M.theme.tab_bar.background
	M.theme.tab_bar.inactive_tab.fg_color = M.colors.surface2
	M.theme.tab_bar.active_tab.fg_color = M.colors.mauve
	M.theme.tab_bar.active_tab.bg_color = M.theme.tab_bar.background

	config.color_schemes = { ["Custom"] = M.theme }
	config.color_scheme = "Custom"
end

return M
