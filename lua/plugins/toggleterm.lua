return {
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		cmd = { "ToggleTerm", "ToggleTermToggleAll", "TermExec" },
		keys = { "<leader>cl" },
		opts = {
			--[[ things you want to change go here]]
		},
		config = function(_, opts)
			require("toggleterm").setup(opts)

			local Terminal = require("toggleterm.terminal").Terminal
			local claude = Terminal:new({
				cmd = "claude",
				direction = "float",
				hidden = true,
				float_opts = {
					border = "rounded",
				},
			})

			vim.keymap.set("n", "<leader>cl", function()
				claude:toggle()
			end, { desc = "Claude Code" })
		end,
	},
}
