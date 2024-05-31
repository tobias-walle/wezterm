local M = {}

local utils = require("utils")

function M.copy_last_output_to_clipboard(window, pane)
	local zones = pane:get_semantic_zones("Output")
	local last_zone = zones[#zones]
	if last_zone then
		local text = pane:get_text_from_semantic_zone(last_zone)
		window:copy_to_clipboard(utils.trim(text), "PrimarySelection")
		pane:send_text("pbpaste | less\n")
	end
end

return M
