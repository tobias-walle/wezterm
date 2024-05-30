local M = {}

local wezterm = require("wezterm")
local mux = wezterm.mux

function M.maximize_window(domain)
	-- maximize all displayed windows on startup
	local workspace = mux.get_active_workspace()
	for _, window in ipairs(mux.all_windows()) do
		if window:get_workspace() == workspace then
			window:gui_window():maximize()
		end
	end
end

return M
