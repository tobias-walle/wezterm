local M = {}

local wezterm = require("wezterm")
local act = wezterm.actions

---Replace the home folder in a path with "~"
---@param path string
function M.replace_home(path)
	local home = wezterm.home_dir
	return path:gsub(home, "~")
end

---Add a number of elements to a table at once
---@generic T
---@param list T[]
---@param list_to_add T[]
---@return nil
function M.insert_all(list, list_to_add)
	for _, key in ipairs(list_to_add) do
		table.insert(list, key)
	end
end

---Flatten a list of arrays
---@generic T
---@param list_of_lists (T[])[]
---@return T[]
function M.flatten(list_of_lists)
	local flat_list = {}
	for _, list in ipairs(list_of_lists) do
		for _, item in ipairs(list) do
			table.insert(flat_list, item)
		end
	end
	return flat_list
end

return M
