local M = {}

local wezterm = require("wezterm")
local utils = require("utils")

local RIGHT_ARROW = utf8.char(0xe0b4)
local RIGHT_ARROW_THIN = utf8.char(0xe0b5)
local LEFT_ARROW = utf8.char(0xe0b6)
local LEFT_ARROW_THIN = utf8.char(0xe0b7)

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
	title = title:sub(-(max_width - 2))
	if title:len() < original_len then
		title = "…" .. title:sub(1)
	end

	local tab_theme = get_tab_theme(theme, tab)

	local tab_index = tab.tab_index + 1
	local next_tab = tabs[tab_index + 1]
	local next_tab_theme = false
	if next_tab then
		next_tab_theme = get_tab_theme(theme, next_tab)
	end

	local show_thin_arrow = not tab.is_active and (not next_tab or not next_tab.is_active)
	return {
		{ Background = { Color = tab_theme.bg_color } },
		{ Text = " " .. title },
		{ Background = { Color = next_tab_theme and next_tab_theme.bg_color or theme.tab_bar.background } },
		{ Foreground = { Color = show_thin_arrow and theme.tab_bar.active_tab.bg_color or tab_theme.bg_color } },
		{ Text = show_thin_arrow and RIGHT_ARROW_THIN or RIGHT_ARROW },
	}
end

-- Status Bar
function M.update_status(window, pane)
	local theme = require("config.theme").theme
	local format_section = function(text, bg_color, fg_color)
		if text then
			return {
				{ Foreground = { Color = bg_color } },
				{ Text = LEFT_ARROW },
				{ Background = { Color = bg_color } },
				{ Foreground = { Color = fg_color } },
				{ Text = text },
				{ Text = " " },
			}
		else
			return {}
		end
	end

	local active_key_table = window:active_key_table()

	local cwd = pane:get_current_working_dir()
	local cwd_path = cwd and cwd.path or "<unknown>"

	local workspace = window:active_workspace()

	window:set_right_status(wezterm.format(utils.flatten({
		format_section(active_key_table, theme.tab_bar.inactive_tab.bg_color, theme.tab_bar.inactive_tab.fg_color),
		format_section(cwd_path, theme.ansi[1], theme.tab_bar.inactive_tab.fg_color),
		format_section(workspace, theme.tab_bar.active_tab.bg_color, theme.tab_bar.active_tab.fg_color),
	})))
end

return M
