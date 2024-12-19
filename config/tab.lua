local M = {}

local wezterm = require("wezterm")

function M.create_tab_next_to_current(window, pane)
	local mux_win = window:mux_window()
	for _, item in ipairs(mux_win:tabs_with_info()) do
		if item.is_active then
			local tab = mux_win:spawn_tab({})
			tab:activate()
			window:perform_action(wezterm.action.MoveTab(item.index + 1), pane)
			return
		end
	end
end

return M
