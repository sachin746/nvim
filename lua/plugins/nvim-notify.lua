return {
	"rcarriga/nvim-notify",
	opts = {
		stages = "fade_in_slide_out",
		timeout = 3000,
		render = "default",
		top_down = false,
		background_colour = "#000000",
		max_width = function()
			return math.floor(vim.o.columns * 0.5)
		end,
		on_open = function(win)
			local config = vim.api.nvim_win_get_config(win)
			config.col = math.floor((vim.o.columns - config.width) / 2)
			vim.api.nvim_win_set_config(win, config)
		end,
	},
}
