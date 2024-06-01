local M = {}

local utils = require("utils")

function M.copy_last_output_to_clipboard(window, pane)
	local zones = pane:get_semantic_zones("Output")
	-- Find the last zone with output and copy that
	for i = #zones, 1, -1 do
		local zone = zones[i]
		if zone then
			local text = utils.trim(pane:get_text_from_semantic_zone(zone))
			if text and text ~= "" then
				window:copy_to_clipboard(utils.trim(text), "PrimarySelection")
				utils.notify("Copy Successful", "Copied: " .. text:sub(0, 10) .. "…")
				return
			end
		end
	end
	utils.notify("Copy failed", "Couldn't find suitable output")
end

return M
