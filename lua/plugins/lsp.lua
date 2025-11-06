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
		},
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			local function on_attach(_, bufnr)
				local builtin = require("telescope.builtin")
				local opts = { buffer = bufnr, silent = true }

				-- Navigation
				vim.keymap.set("n", "gd", builtin.lsp_definitions, opts)
				vim.keymap.set("n", "gr", builtin.lsp_references, opts)
				vim.keymap.set("n", "gi", builtin.lsp_implementations, opts)
				vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
				vim.keymap.set("n", "gt", builtin.lsp_type_definitions, opts)
				vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

				-- Actions
				vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
				vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
				vim.keymap.set("n", "<leader>f", function()
					vim.lsp.buf.format({ async = true })
				end, opts)

				-- Diagnostics it means error or warning in code
				vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
				vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
				vim.keymap.set("n", "<leader>xd", vim.diagnostic.open_float, opts)
				vim.keymap.set("n", "<leader>xq", vim.diagnostic.setloclist, opts)
				vim.keymap.set("n", "<leader>xx", builtin.diagnostics, opts)

				-- Symbols -> function, variables, struct, enums etc
				vim.keymap.set("n", "<leader>ds", builtin.lsp_document_symbols, opts)
				vim.keymap.set("n", "<leader>ws", builtin.lsp_dynamic_workspace_symbols, opts)

				-- Workspace folders
				vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
				vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
				vim.keymap.set("n", "<leader>lw", function()
					print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
				end, opts)
			end
			-- for autocompetions
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			-- ✅ Define and start LSP servers
			local servers = {
				lua_ls = {
					cmd = { "lua-language-server" },
					settings = {
						Lua = {
							diagnostics = { globals = { "vim" } },
						},
					},
					on_attach = on_attach,
					capabilities = capabilities,
				},
				gopls = { cmd = { "gopls" }, on_attach = on_attach, capabilities = capabilities },
				pyright = {
					cmd = { "pyright-langserver", "--stdio" },
					on_attach = on_attach,
					capabilities = capabilities,
				},
				ts_ls = {
					cmd = { "typescript-language-server", "--stdio" },
					on_attach = on_attach,
					capabilities = capabilities,
				},
				html = {
					cmd = { "vscode-html-language-server", "--stdio" },
					on_attach = on_attach,
					capabilities = capabilities,
				},
				cssls = {
					cmd = { "vscode-css-language-server", "--stdio" },
					on_attach = on_attach,
					capabilities = capabilities,
				},
				jsonls = {
					cmd = { "vscode-json-language-server", "--stdio" },
					on_attach = on_attach,
					capabilities = capabilities,
				},
			}

			for name, config in pairs(servers) do
				config.name = name
				config.root_dir = vim.fs.root(0, { ".git", "go.mod", "package.json", "pyproject.toml" })
				vim.lsp.start(config)
			end
		end,
	},
}
