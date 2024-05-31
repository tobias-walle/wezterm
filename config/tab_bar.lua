local M = {}

local wezterm = require("wezterm")
local utils = require("utils")

local get_tab_theme = function(theme, tab)
	if tab.is_active then
		return theme.tab_bar.active_tab
	else
		return theme.tab_bar.inactive_tab
	end
end

function M.format_tab_bar(tab, tabs, panes, config, hover, max_width)
	local theme = require("config.theme").theme
	local title = tab.tab_title

	-- if the tab title not explicitly set, set default
	if not title or #title == 0 then
		if tab.active_pane.current_working_dir then
			-- Show last two segments of a path, e.g. if the path is "/Users/test/projects/my-project" => "projects/my-project"
			local current_path = utils.replace_home(tab.active_pane.current_working_dir.path)
			local current_folder = string.match(current_path, [[([^/]*/?[^/]+)$]])
			title = current_folder
		end
	end
	if not title then
		title = tab.active_pane.title
	end

	-- Right align title
	local original_len = title:len()
	title = title:sub(-(max_width - 5))
	if title:len() < original_len then
		title = "…" .. title:sub(1)
	end

	local tab_theme = get_tab_theme(theme, tab)

	return {
		{ Background = { Color = tab_theme.bg_color } },
		{ Foreground = { Color = tab_theme.fg_color } },
		{ Text = " " .. title .. " " },
		{ Background = { Color = tab_theme.bg_color } },
		{ Foreground = { Color = tab_theme.fg_color } },
		{ Text = "" },
		{ Foreground = { Color = tab_theme.bg_color } },
		{ Background = { Color = tab_theme.fg_color } },
		{ Text = "" .. tab.tab_index },
		{ Background = { Color = tab_theme.bg_color } },
		{ Foreground = { Color = tab_theme.fg_color } },
		{ Text = "" },
	}
end

-- Status Bar
function M.update_status(window, pane)
	local theme = require("config.theme").theme
	local colors = require("config.theme").colors
	local format_section = function(icon, text, color)
		if text then
			return {
				{ Foreground = { Color = color } },
				{ Text = "" },
				{ Background = { Color = color } },
				{ Foreground = { Color = theme.tab_bar.background } },
				{ Text = " " .. icon .. "  " .. text .. " " },
				"ResetAttributes",
				{ Foreground = { Color = color } },
				{ Text = "" },
			}
		else
			return {}
		end
	end

	local active_key_table = window:active_key_table()

	local cwd = pane:get_current_working_dir()
	local cwd_path = cwd and utils.replace_home(cwd.path) or "<unknown>"

	local workspace = window:active_workspace()

	window:set_right_status(wezterm.format(utils.flatten({
		format_section("", active_key_table, colors.flamingo),
		format_section("", cwd_path, colors.teal),
		format_section("", workspace, colors.mauve),
	})))
end

return M
