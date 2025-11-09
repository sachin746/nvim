return {
	"rcarriga/nvim-notify",
	config = function()
		local notify = require("notify")

		notify.setup({
			stages = "fade_in_slide_out", -- nice smooth animation
			timeout = 3000, -- 3 seconds per notification
			render = "default",
			top_down = false, -- show newest at bottom
			max_width = math.floor(vim.o.columns * 0.5), -- half screen width

			on_open = function(win)
				-- center notification horizontally
				local config = vim.api.nvim_win_get_config(win)
				config.col = math.floor((vim.o.columns - config.width) / 2)
				vim.api.nvim_win_set_config(win, config)
			end,
		})

		-- Override default vim.notify to use nvim-notify
		vim.notify = notify
	end,
}
