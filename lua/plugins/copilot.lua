return {
	{
		"github/copilot.vim",
		event = "InsertEnter",
		cond = function()
			return vim.env.ANTHROPIC_AUTH_TOKEN == nil
		end,
		config = function()
			vim.g.copilot_no_tab_map = true
			vim.keymap.set("i", "<C-J>", 'copilot#Accept("<CR>")', {
				expr = true,
				silent = true,
				replace_keycodes = false,
				desc = "Copilot: accept suggestion",
			})
		end,
	},
}
