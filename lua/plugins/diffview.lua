return {
	"sindrets/diffview.nvim",
	opts = {
		keys = {
			vim.keymap.set("n", "<leader>do", ":DiffviewOpen<CR>", { desc = "Open Diffview" }),
			vim.keymap.set("n", "<leader>dc", ":DiffviewClose<CR>", { desc = "Close Diffview" }),
			vim.keymap.set("n", "<leader>dh", ":DiffviewFileHistory<CR>", { desc = "View file history" }),
		},
	},
}
