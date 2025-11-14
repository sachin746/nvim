return {
	"rest-nvim/rest.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	ft = { "http" },
	config = function()
		require("rest-nvim").setup()
	end,
	vim.keymap.set("n", "<leader>hh", "<cmd>RestNvim<cr>", { desc = "Send HTTP request" }),
}
