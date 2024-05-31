local utils = {}

local wezterm = require("wezterm")
local act = wezterm.action

---Replace the home folder in a path with "~"
---@param path string
function utils.replace_home(path)
	local home = wezterm.home_dir
	return path:gsub(home, "~")
end

---Add a number of elements to a table at once
---@generic T
---@param list T[]
---@param list_to_add T[]
---@return nil
function utils.insert_all(list, list_to_add)
	for _, key in ipairs(list_to_add) do
		table.insert(list, key)
	end
end

---Merge two tables to a new one
---@param table table
---@param other_table table
---@return table
function utils.merge(table, other_table)
	local new_table = {}
	for key, value in pairs(table) do
		new_table[key] = value
	end
	for key, value in pairs(other_table) do
		new_table[key] = value
	end
	return new_table
end

---Flatten a list of arrays
---@generic T
---@param list_of_lists (T[])[]
---@return T[]
function utils.flatten(list_of_lists)
	local flat_list = {}
	for _, list in ipairs(list_of_lists) do
		for _, item in ipairs(list) do
			table.insert(flat_list, item)
		end
	end
	return flat_list
end

---After given keys are triggered, a keytable is activated which allows repeating the keys without leader.
---Mimics the -r option in tmux.
---Make sure that the given keys "mod" starts with "LEADER|".
---@param config table
---@param keytable_name string
---@param keys table[]
function utils.add_keys_with_repeat(config, keytable_name, keys)
	config.key_tables[keytable_name] = {}
	for _, key in ipairs(keys) do
		table.insert(
			config.key_tables[keytable_name],
			utils.merge(key, {
				-- Remove leader key requirement from mapping
				mods = key.mods:gsub("|?LEADER|?", ""),
			})
		)
		table.insert(
			config.keys,
			utils.merge(key, {
				-- Activate key table if action is triggered
				action = act.Multiple({
					key.action,
					act.ActivateKeyTable({
						name = keytable_name,
						one_shot = false,
						timeout_milliseconds = 3000,
						until_unknown = true,
					}),
				}),
			})
		)
	end
end

---Remove trailing and leading whitespace from string
---@param str string
---@return string
function utils.trim(str)
	local result = string.gsub(str, "^%s*(.-)%s*$", "%1")
	return result
end

return utils
