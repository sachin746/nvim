return {
	"stevearc/oil.nvim",
	---@module 'oil'
	---@type oil.SetupOpts
	opts = {
		view_options = { show_hidden = true },
		float = { padding = 2 },
		keymaps = {
			-- free up <C-h>/<C-l> so split navigation still works inside oil
			["<C-h>"] = false,
			["<C-l>"] = false,
		},
	},
	dependencies = { { "nvim-mini/mini.icons", opts = {} } },
	lazy = false,
	keys = {
		{ "-", "<cmd>Oil<CR>", desc = "Open parent directory" },
	},
}
