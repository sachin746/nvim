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
	{
		"Exafunction/codeium.vim",
		lazy = false,
		config = function()
			vim.g.codeium_no_map_tab = true
			vim.keymap.set("i", "<C-J>", function()
				return vim.fn["codeium#Accept"]()
			end, { expr = true, silent = true, desc = "Codeium: accept suggestion" })
			vim.keymap.set("i", "<C-;>", function()
				return vim.fn["codeium#CycleCompletions"](1)
			end, { expr = true, silent = true, desc = "Codeium: next suggestion" })
		end,
	},
}
