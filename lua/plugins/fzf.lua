return {
	{
		"ibhagwan/fzf-lua",
		dependencies = { "nvim-tree/nvim-web-devicons" }, -- optional
		lazy = false,
		priority = 1000,

		-- Replace all Telescope keymaps with fzf-lua equivalents
		keys = {
			{ "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Find files" },
			{ "<leader>fg", "<cmd>FzfLua live_grep<cr>", desc = "Live grep" },
			{ "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Find buffers" },
			{ "<leader>fh", "<cmd>FzfLua help_tags<cr>", desc = "Help tags" },
		},

		config = function()
			require("fzf-lua").setup({
				winopts = {
					height = 0.85,
					width = 0.80,
					row = 0.30,
				},
				files = {
					-- Use fd for faster file search (recommended)
					cmd = "fd --type f --hidden --exclude .git",
				},
				preview = {
					default = "bat",
				},
				fzf_opts = {
					["--prompt"] = "❯ ",
					["--layout"] = "reverse",
				},
			})
		end,
	},
}
