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

local function get_tab_title(tab)
	local title = tab.tab_title or ""

	-- if the tab title not explicitly set, set default
	if title == "" then
		if tab.active_pane.current_working_dir then
			local current_path = utils.replace_home(tab.active_pane.current_working_dir.path)
			-- Show last segment of a path, e.g. if the path is "/Users/test/projects/my-project" => "my-project"
			local current_folder = string.match(current_path, [[([^/]+)$]])
			title = current_folder
		else
			title = tab.active_pane.title
		end
	end

	if tab.active_pane.is_zoomed then
		title = title .. " 🔍"
	end

	return title
end

function M.format_tab_bar(tab, tabs, panes, config, hover)
	local theme = require("config.theme").theme
	local title = get_tab_title(tab)

	-- Right align title
	local original_len = title:len()
	title = title:sub(-(config.tab_max_width - 6))
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
				{ Text = " " .. icon .. " " .. text .. " " },
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

-- Window title
function M.format_window_title(tab, pane, tabs, panes, config)
	local zoomed = ""
	if tab.active_pane.is_zoomed then
		zoomed = "[Z] "
	end

	local index = ""
	if #tabs > 1 then
		index = string.format(" %d/%d", tab.tab_index + 1, #tabs)
	end

	return zoomed .. get_tab_title(tab) .. " [" .. wezterm.mux.get_active_workspace() .. index .. "]"
end

return M
