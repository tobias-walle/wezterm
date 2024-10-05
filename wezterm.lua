local wezterm = require("wezterm")
local act = wezterm.action
local utils = require("utils")

local config = wezterm.config_builder()

-- Theme
require("config.theme").configure_theme(config, "Catppuccin Mocha")

-- Key bindings
config.leader = { key = "Space", mods = "CTRL" }
config.disable_default_key_bindings = true
config.keys = {
	-- Create tab
	{ key = "c", mods = "LEADER", action = act({ SpawnTab = "CurrentPaneDomain" }) },

	-- Zoom into split
	{ key = "z", mods = "LEADER", action = act.TogglePaneZoomState },

	-- Close stuff
	{ key = "x", mods = "LEADER", action = act({ CloseCurrentPane = { confirm = true } }) },
	{ key = "x", mods = "LEADER|CTRL", action = act({ CloseCurrentTab = { confirm = true } }) },
	{
		key = "q",
		mods = "LEADER|CTRL",
		action = act.Multiple({
			require("plugins.sessions").action_save,
			act.QuitApplication,
		}),
	},

	-- Clear Screen & History
	{ key = "k", mods = "LEADER|CTRL", action = act({ ClearScrollback = "ScrollbackAndViewport" }) },

	-- Navigate panes
	{ key = "h", mods = "CTRL", action = act.EmitEvent("ActivatePaneDirection-left") },
	{ key = "j", mods = "CTRL", action = act.EmitEvent("ActivatePaneDirection-down") },
	{ key = "k", mods = "CTRL", action = act.EmitEvent("ActivatePaneDirection-up") },
	{ key = "l", mods = "CTRL", action = act.EmitEvent("ActivatePaneDirection-right") },

	-- Split Panes
	{ key = "v", mods = "LEADER", action = act({ SplitHorizontal = { domain = "CurrentPaneDomain" } }) },
	{ key = "s", mods = "LEADER", action = act({ SplitVertical = { domain = "CurrentPaneDomain" } }) },

	-- Switch tabs
	{ key = "l", mods = "CTRL|SHIFT", action = act({ ActivateTabRelative = 1 }) },
	{ key = "h", mods = "CTRL|SHIFT", action = act({ ActivateTabRelative = -1 }) },

	-- Scrolling
	{ key = "PageUp", mods = "SHIFT", action = act({ ScrollByPage = -1 }) },
	{ key = "PageDown", mods = "SHIFT", action = act({ ScrollByPage = 1 }) },

	-- Font size adjustments
	{ key = "Backspace", mods = "CTRL", action = act.ResetFontSize },

	-- Clipboard
	{ key = "v", mods = "LEADER|CTRL", action = act.ActivateCopyMode },
	{ key = "c", mods = "CMD", action = act({ CopyTo = "Clipboard" }) },
	{ key = "c", mods = "CTRL|SHIFT", action = act({ CopyTo = "Clipboard" }) },
	{ key = "v", mods = "CMD", action = act({ PasteFrom = "Clipboard" }) },
	{ key = "v", mods = "CTRL|SHIFT", action = act({ PasteFrom = "Clipboard" }) },
	{
		key = "Tab",
		mods = "LEADER",
		action = wezterm.action_callback(require("config.clipboard").copy_last_output_to_clipboard),
	},

	-- Scroll to earlier prompts
	{ key = "UpArrow", mods = "CMD", action = act.ScrollToPrompt(-1) },
	{ key = "DownArrow", mods = "CMD", action = act.ScrollToPrompt(1) },

	-- Rename tab
	{
		key = "t",
		mods = "LEADER|CTRL",
		action = act.PromptInputLine({
			description = "Enter new name for tab",
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},

	-- Quick select
	{ key = "s", mods = "CMD", action = act.QuickSelect },
	{ key = "s", mods = "CTRL|SHIFT", action = act.QuickSelect },

	-- Switch workspaces / sessions
	{
		key = "Space",
		mods = "LEADER",
		action = wezterm.action_callback(require("config.workspaces").open_workspace_picker),
	},

	-- Show command palette
	{
		key = "p",
		mods = "LEADER|CTRL",
		action = wezterm.action.ActivateCommandPalette,
	},

	-- Debug
	{ key = "d", mods = "LEADER|CTRL", action = act.ShowDebugOverlay },
}

config.key_tables = {}

-- Resize
utils.add_keys_with_repeat(config, "resize", {
	{ key = "j", mods = "LEADER|SHIFT", action = act({ AdjustPaneSize = { "Down", 2 } }) },
	{ key = "k", mods = "LEADER|SHIFT", action = act({ AdjustPaneSize = { "Up", 2 } }) },
	{ key = "l", mods = "LEADER|SHIFT", action = act({ AdjustPaneSize = { "Right", 10 } }) },
	{ key = "h", mods = "LEADER|SHIFT", action = act({ AdjustPaneSize = { "Left", 10 } }) },
})

-- Move Tabs
utils.add_keys_with_repeat(config, "move tabs", {
	{ key = "n", mods = "LEADER|SHIFT", action = act({ MoveTabRelative = -1 }) },
	{ key = "m", mods = "LEADER|SHIFT", action = act({ MoveTabRelative = 1 }) },
})

-- Rotate panes
utils.add_keys_with_repeat(config, "rotate panes", {
	{ key = "r", mods = "LEADER", action = act.RotatePanes("Clockwise") },
})

-- Scroll
utils.add_keys_with_repeat(config, "scroll", {
	{ key = "u", mods = "LEADER|CTRL", action = act.ScrollByPage(-0.5) },
	{ key = "d", mods = "LEADER|CTRL", action = act.ScrollByPage(0.5) },
})

config.mouse_bindings = {
	-- Select output of a command with triple click. Doesn't really work at the moment unfortunately.
	{
		event = { Down = { streak = 3, button = "Left" } },
		action = wezterm.action.SelectTextAtMouseCursor("SemanticZone"),
		mods = "NONE",
	},

	-- Change the default click behavior so that it only selects
	-- text and doesn't open hyperlinks
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "NONE",
		action = act.CompleteSelection("PrimarySelection"),
	},

	-- and make SHIFT-Click open hyperlinks
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "CTRL",
		action = act.OpenLinkAtMouseCursor,
	},

	-- Disable the 'Down' event of CTRL-Click to avoid weird program behaviors
	{
		event = { Down = { streak = 1, button = "Left" } },
		mods = "CTRL",
		action = act.Nop,
	},
}

-- General options
config.quit_when_all_windows_are_closed = false
config.scrollback_lines = 50000
config.initial_rows = 45
config.initial_cols = 170
-- config.enable_kitty_keyboard = true
-- config.enable_csi_u_key_encoding = false
-- config.send_composed_key_when_left_alt_is_pressed = true
-- config.send_composed_key_when_right_alt_is_pressed = true

-- Fonts
config.font = wezterm.font_with_fallback({
	{ family = "JetBrains Mono", weight = "Regular" },
	{ family = "Symbols Nerd Font Mono", scale = 0.85 },
	{ family = "Noto Color Emoji" },
})
config.use_cap_height_to_scale_fallback_fonts = true
config.font_size = 13.3 -- Uneven font size is necessary because otherwise there is unwanted space at the bottom

-- Window options
config.window_padding = { top = 0, left = 0, right = 0, bottom = 0 }
wezterm.on("format-window-title", require("config.tab_bar").format_window_title)

-- Tab Bar
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = false
config.tab_max_width = 40
config.show_new_tab_button_in_tab_bar = false
wezterm.on("format-tab-title", require("config.tab_bar").format_tab_bar)

-- Image Support
config.enable_kitty_graphics = true

-- Status Bar
config.status_update_interval = 10000
wezterm.on("update-status", require("config.tab_bar").update_status)

-- Restore sessions
wezterm.on("gui-startup", function(cmd)
	if not cmd then
		local _, _, window = wezterm.mux.spawn_window({})
		require("plugins.sessions").restore(window)
	else
		require("plugins.sessions").disable_save()
		wezterm.mux.spawn_window(cmd)
	end
end)

-- Save sessions every minute
local function save_sessions_in_interval()
	wezterm.time.call_after(60, function()
		require("plugins.sessions").save()
		save_sessions_in_interval()
	end)
end
save_sessions_in_interval()

-- Plugins
require("plugins/navigator").configure(config)

wezterm.on("window-focus-changed", function(window, pane)
	wezterm.log_info("the focus state of ", window:window_id(), " changed to ", window:is_focused())
end)

return config
