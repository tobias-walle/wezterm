local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()

-- Theme
config.color_scheme = require("config.theme").theme_name

-- Key bindings
config.leader = { key = "Space", mods = "CTRL" }
config.keys = {
	-- Create tab
	{ key = "c", mods = "LEADER", action = act({ SpawnTab = "CurrentPaneDomain" }) },

	-- Zoom into split
	{ key = "z", mods = "LEADER", action = act.TogglePaneZoomState },

	-- Close stuff
	{ key = "x", mods = "LEADER", action = act({ CloseCurrentPane = { confirm = true } }) },
	{ key = "x", mods = "LEADER|CTRL", action = act({ CloseCurrentTab = { confirm = true } }) },
	{ key = "q", mods = "LEADER|CTRL", action = act.QuitApplication },

	-- Clear Screen & History
	{ key = "k", mods = "LEADER|CTRL", action = act({ ClearScrollback = "ScrollbackAndViewport" }) },

	-- Move tabs
	{ key = "h", mods = "LEADER|SHIFT", action = act({ MoveTabRelative = -1 }) },
	{ key = "l", mods = "LEADER|SHIFT", action = act({ MoveTabRelative = 1 }) },

	-- Navigate panes
	{ key = "h", mods = "CTRL", action = act.EmitEvent("ActivatePaneDirection-left") },
	{ key = "j", mods = "CTRL", action = act.EmitEvent("ActivatePaneDirection-down") },
	{ key = "k", mods = "CTRL", action = act.EmitEvent("ActivatePaneDirection-up") },
	{ key = "l", mods = "CTRL", action = act.EmitEvent("ActivatePaneDirection-right") },

	-- Resize
	{ key = "j", mods = "LEADER|SHIFT", action = act({ AdjustPaneSize = { "Down", 5 } }) },
	{ key = "k", mods = "LEADER|SHIFT", action = act({ AdjustPaneSize = { "Up", 5 } }) },
	{ key = "l", mods = "LEADER|SHIFT", action = act({ AdjustPaneSize = { "Right", 20 } }) },
	{ key = "h", mods = "LEADER|SHIFT", action = act({ AdjustPaneSize = { "Left", 20 } }) },

	-- Split Panes
	{ key = "v", mods = "LEADER", action = act({ SplitHorizontal = { domain = "CurrentPaneDomain" } }) },
	{ key = "s", mods = "LEADER", action = act({ SplitVertical = { domain = "CurrentPaneDomain" } }) },

	-- Rotate Panes
	{ key = "r", mods = "LEADER", action = act.RotatePanes("Clockwise") },
	{ key = "r", mods = "LEADER|CTRL", action = act.RotatePanes("CounterClockwise") },

	-- Switch tabs
	{ key = "l", mods = "CTRL|SHIFT", action = act({ ActivateTabRelative = 1 }) },
	{ key = "h", mods = "CTRL|SHIFT", action = act({ ActivateTabRelative = -1 }) },

	-- Move tabs
	{ key = "l", mods = "LEADER|SHIFT", action = act.MoveTabRelative(1) },
	{ key = "h", mods = "LEADER|SHIFT", action = act.MoveTabRelative(-1) },

	-- Copy mode
	{ key = "v", mods = "LEADER|CTRL", action = act.ActivateCopyMode },

	-- Scrolling
	{ key = "PageUp", mods = "SHIFT", action = act({ ScrollByPage = -1 }) },
	{ key = "PageDown", mods = "SHIFT", action = act({ ScrollByPage = 1 }) },

	-- Font size adjustments
	{ key = "Backspace", mods = "CTRL", action = act.ResetFontSize },

	-- Clipboard
	{ key = "c", mods = "CMD", action = act({ CopyTo = "Clipboard" }) },
	{ key = "c", mods = "CTRL|SHIFT", action = act({ CopyTo = "Clipboard" }) },
	{ key = "v", mods = "CMD", action = act({ PasteFrom = "Clipboard" }) },
	{ key = "v", mods = "CTRL|SHIFT", action = act({ PasteFrom = "Clipboard" }) },

	-- Switch workspaces / sessions
	{
		key = "Space",
		mods = "LEADER",
		action = wezterm.action_callback(require("config.workspaces").open_workspace_picker),
	},

	-- Debug
	{ key = "d", mods = "LEADER|CTRL", action = act.ShowDebugOverlay },
}

config.mouse_bindings = {
	-- Select output of a command with triple click. Doesn't really work at the moment unfortunately.
	{
		event = { Down = { streak = 3, button = "Left" } },
		action = wezterm.action.SelectTextAtMouseCursor("SemanticZone"),
		mods = "NONE",
	},
}

-- Quit when all windows are closed
config.quit_when_all_windows_are_closed = true

-- History limit
config.scrollback_lines = 10000

-- Fonts
config.font = wezterm.font("JetBrains Mono")
config.font_size = 15.5 -- Uneven font size is necessary because otherwise there is unwanted space at the bottom
config.window_padding = { top = 0, left = 0, right = 0, bottom = 0 }

-- Tab Bar
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = false
config.tab_max_width = 40
config.show_new_tab_button_in_tab_bar = false
wezterm.on("format-tab-title", require("config.tab_bar").format_tab_bar)

-- Status Bar
config.status_update_interval = 10000
wezterm.on("update-status", require("config.tab_bar").update_status)

-- Maximize terminal initially
wezterm.on("gui-attached", require("config.windows").maximize_window)

-- Plugins
require("plugins/navigator").configure(config)

return config
