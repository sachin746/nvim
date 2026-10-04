return {
	"sindrets/diffview.nvim",
	cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
	keys = {
		{ "<leader>do", "<cmd>DiffviewOpen<CR>", desc = "Open Diffview" },
		{ "<leader>dc", "<cmd>DiffviewClose<CR>", desc = "Close Diffview" },
		{ "<leader>dh", "<cmd>DiffviewFileHistory<CR>",   desc = "Git history (repo)" },
		{ "<leader>df", "<cmd>DiffviewFileHistory %<CR>", desc = "Git history (file)" },
	},
}
