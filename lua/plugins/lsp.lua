return {
	{
		"mason-org/mason.nvim",
		opts = {
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		},
	},
	{
		"mason-org/mason-lspconfig.nvim",
		opts = {
			ensure_installed = {
				"lua_ls",
				"gopls",
				"pyright",
				"ts_ls",
				"html",
				"cssls",
				"jsonls",
			},
		},
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
			"neovim/nvim-lspconfig",
		},
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			local lspconfig = require("lsp")
			-- Common keymaps for LSP
			vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to Definition" })
			vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "Go to References" })
			vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover Info" })
			vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename Symbol" })
			vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })

			-- Lua
			lspconfig.lua_ls.setup({
				settings = {
					Lua = {
						diagnostics = { globals = { "vim" } },
					},
				},
			})

			-- Go
			lspconfig.gopls.setup({})

			-- Python
			lspconfig.pyright.setup({})

			-- JavaScript / TypeScript
			lspconfig.ts_ls.setup({})

			-- HTML / CSS / JSON
			lspconfig.html.setup({})
			lspconfig.cssls.setup({})
			lspconfig.jsonls.setup({})
		end,
	},
}
