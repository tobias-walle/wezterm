local M = {}

local wezterm = require("wezterm")
local act = wezterm.action
local sessions = require("plugins.sessions")

--- Open a picker to select a preexisting workspace or a configured one
function M.open_workspace_picker(window, pane)
	local theme = require("config.theme").theme
	-- Dynamically create a list of all possible workspaces/projects
	local workspaces_config = require("workspaces")
	local workspaces = {}
	local workspace_ids = {}

	local add_workspace = function(workspace)
		if not workspace_ids[workspace.id] then
			table.insert(workspaces, workspace)
			workspace_ids[workspace.id] = true
		end
	end

	local format_workspace_label = function(name, category, color)
		return wezterm.format({
			{ Text = name },
			{ Text = " " },
			{ Foreground = { Color = color } },
			{ Text = "(" .. category .. ")" },
		})
	end

	-- Existing workspaces
	add_workspace({ id = "default", label = format_workspace_label("default", "workspace", theme.brights[4]) })
	for _, workspace in ipairs(wezterm.mux.get_workspace_names()) do
		add_workspace({
			id = workspace,
			label = format_workspace_label(workspace, "workspace", theme.brights[4]),
		})
	end

	-- Configured possible workspaces
	local path_by_workspace = {}
	for _, workspace in ipairs(workspaces_config) do
		local home = wezterm.home_dir
		local path_glob = workspace.path:gsub("~", home)
		local paths = wezterm.glob(path_glob)
		local only_one_path = #paths == 1
		for _, path in ipairs(paths) do
			local folder_name = string.match(path, [[([^/]+)$]])
			local id = only_one_path and workspace.name or folder_name
			path_by_workspace[id] = path
			add_workspace({
				id = id,
				label = only_one_path and format_workspace_label(workspace.name, "folder", theme.brights[5])
					or format_workspace_label(folder_name, workspace.name, theme.brights[5]),
			})
		end
	end

	window:perform_action(
		act.InputSelector({
			action = wezterm.action_callback(function(window_2, pane_2, id, label)
				-- First save the current workspaces
				require("plugins.sessions").save()
				-- Switch to new workspace
				if id and label then
					window_2:perform_action(
						act.SwitchToWorkspace({
							name = id,
							spawn = {
								cwd = path_by_workspace[id],
							},
						}),
						pane_2
					)
					for _, mux_window in ipairs(wezterm.mux.all_windows()) do
						if mux_window:get_workspace() == id then
							sessions.restore(mux_window)
						end
					end
				end
			end),
			choices = workspaces,
			fuzzy = true,
			fuzzy_description = "Switch to workspace: ",
		}),
		pane
	)
end

return M
