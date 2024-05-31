--------------------------------------------------------------------------------------
-- Copied from https://github.com/danielcopper/wezterm-session-manager and modified --
--------------------------------------------------------------------------------------

local wezterm = require("wezterm")
local act = wezterm.action
local M = {}

local function notify(title, message)
	wezterm.gui.gui_windows()[1]:toast_notification(title, message, nil, 3000)
end

--- @return table
local function retrieve_workspace_data(mux_window)
	local workspace_name = mux_window:get_workspace()
	local workspace_data = {
		name = workspace_name,
		tabs = {},
	}

	-- Iterate over tabs in the current window
	for _, tab in ipairs(mux_window:tabs()) do
		local tab_data = {
			tab_id = tostring(tab:tab_id()),
			tab_title = tab:get_title(),
			panes = {},
		}

		-- Iterate over panes in the current tab
		for _, pane_info in ipairs(tab:panes_with_info()) do
			-- Collect pane details, including layout and process information
			table.insert(tab_data.panes, {
				pane_id = tostring(pane_info.pane:pane_id()),
				index = pane_info.index,
				is_active = pane_info.is_active,
				is_zoomed = pane_info.is_zoomed,
				left = pane_info.left,
				top = pane_info.top,
				width = pane_info.width,
				height = pane_info.height,
				pixel_width = pane_info.pixel_width,
				pixel_height = pane_info.pixel_height,
				cwd = pane_info.pane:get_current_working_dir().path,
				tty = tostring(pane_info.pane:get_foreground_process_name()),
			})
		end

		table.insert(workspace_data.tabs, tab_data)
	end

	print(workspace_data)
	return workspace_data
end

--- Save data to json file
--- @param data table
--- @param file_path string
--- @return boolean
local function save_to_json_file(data, file_path)
	if not data then
		wezterm.log_info("No workspace data to log.")
		return false
	end

	local file, error = io.open(file_path, "w")
	if file then
		file:write(wezterm.json_encode(data))
		file:close()
		return true
	else
		wezterm.log_error(error)
		return false
	end
end

--- Recreates the workspace based on the provided data.
--- @param workspace_data table: The data structure containing the saved workspace state.
local function recreate_workspace(mux_window, workspace_data)
	if not workspace_data or not workspace_data.tabs then
		wezterm.log_info("Invalid or empty workspace data provided.")
		return
	end

	local tabs = mux_window:tabs()

	if #tabs ~= 1 or #tabs[1]:panes() ~= 1 then
		wezterm.log_info(
			"Restoration can only be performed in a window with a single tab and a single pane, to prevent accidental data loss."
		)
		return
	end

	mux_window:set_workspace(workspace_data.name)

	local initial_pane = mux_window:active_pane()

	-- Recreate tabs and panes from the saved state
	for _, tab_data in ipairs(workspace_data.tabs) do
		local cwd = tab_data.panes[1].cwd

		local new_tab = mux_window:spawn_tab({
			cwd = cwd,
		})
		if tab_data.tab_title then
			new_tab:set_title(tab_data.tab_title)
		end
		if not new_tab then
			wezterm.log_info("Failed to create a new tab.")
			break
		end

		-- Activate the new tab before creating panes
		new_tab:activate()

		-- Recreate panes within this tab
		for j, pane_data in ipairs(tab_data.panes) do
			local new_pane
			if j == 1 then
				new_pane = new_tab:active_pane()
			else
				local direction = "Right"
				if pane_data.left == tab_data.panes[j - 1].left then
					direction = "Bottom"
				end

				new_pane = new_tab:active_pane():split({
					direction = direction,
					cwd = pane_data.cwd,
				})
			end

			if not new_pane then
				wezterm.log_info("Failed to create a new pane.")
				break
			end
		end
	end

	-- Close initial_pane pane
	initial_pane:activate()
	mux_window:gui_window():perform_action(act.CloseCurrentPane({ confirm = false }), initial_pane)

	-- Activate first tab
	mux_window:tabs()[1]:activate()

	wezterm.log_info("Workspace recreated with new tabs and panes based on saved state.")
	return true
end

--- Loads data from a JSON file.
-- @param file_path string: The file path from which the JSON data will be loaded.
-- @return table or nil: The loaded data as a Lua table, or nil if loading failed.
local function load_from_json_file(file_path)
	local file = io.open(file_path, "r")
	if not file then
		wezterm.log_info("Failed to open file: " .. file_path)
		return nil
	end

	local file_content = file:read("*a")
	file:close()

	local data = wezterm.json_parse(file_content)
	if not data then
		wezterm.log_info("Failed to parse JSON data from file: " .. file_path)
	end
	return data
end

local already_restored = {}

function M.restore(mux_window)
	local workspace_name = mux_window:get_workspace()
	if already_restored[workspace_name] then
		wezterm.log_info("Workspace " .. workspace_name .. " already restored. Skip...")
		return
	end
	local file_path = wezterm.home_dir .. "/.config/wezterm/sessions/" .. workspace_name .. ".json"

	local workspace_data = load_from_json_file(file_path)
	if not workspace_data then
		wezterm.log_info("Workspace file not found for " .. workspace_name)
		return
	end

	if recreate_workspace(mux_window, workspace_data) then
		wezterm.log_info("Workspace state loaded for workspace: " .. workspace_name)
		already_restored[workspace_name] = true
	else
		notify("WezTerm", "Workspace state loading failed for workspace: " .. workspace_name)
	end
end

local save_disabled = false
function M.disable_save()
	save_disabled = true
end

function M.save()
	if save_disabled then
		return
	end

	for _, mux_window in ipairs(wezterm.mux.all_windows()) do
		local workspace_name = mux_window:get_workspace()
		local data = retrieve_workspace_data(mux_window)

		-- Construct the file path based on the workspace name
		local file_path = wezterm.home_dir .. "/.config/wezterm/sessions/" .. data.name .. ".json"

		-- Save the workspace data to a JSON file and display the appropriate notification
		if not save_to_json_file(data, file_path) then
			notify("WezTerm Session Manager", "Failed to save workspace " .. workspace_name)
			return
		end
	end

	wezterm.log_info("WezTerm Session Manager", "Workspaces saved successfully")
end

M.action_save = wezterm.action_callback(function()
	require("plugins.sessions").save()
end)

return M
