return {
	"folke/trouble.nvim",
	cmd = "Trouble",
	opts = {},
	keys = {
		{ "<leader>xt", "<cmd>Trouble diagnostics toggle<cr>", desc = "Trouble: diagnostics" },
		{ "<leader>xT", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Trouble: buffer diagnostics" },
		{ "<leader>xl", "<cmd>Trouble loclist toggle<cr>", desc = "Trouble: location list" },
		{ "<leader>xc", "<cmd>Trouble qflist toggle<cr>", desc = "Trouble: quickfix list" },
	},
}
