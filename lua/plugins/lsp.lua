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
			-- Load fzf-lua
			local fzf = require("fzf-lua")

			local function on_attach(_, bufnr)
				local opts = { buffer = bufnr, silent = true }

				-- LSP Navigation (replaces Telescope)
				vim.keymap.set("n", "gd", fzf.lsp_definitions, opts)
				vim.keymap.set("n", "gr", fzf.lsp_references, opts)
				vim.keymap.set("n", "gi", fzf.lsp_implementations, opts)
				vim.keymap.set("n", "gt", fzf.lsp_typedefs, opts)

				-- Declaration + Hover
				vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
				vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

				-- Code actions & rename
				vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
				vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

				-- Formatting
				vim.keymap.set("n", "<leader>fo", function()
					vim.lsp.buf.format({ async = true })
				end, { buffer = bufnr, silent = true, desc = "Format current buffer" })

				-- Diagnostics (Telescope → fzf-lua)
				vim.keymap.set("n", "<leader>xx", fzf.diagnostics_workspace, opts)
				vim.keymap.set("n", "<leader>xd", fzf.diagnostics_document, opts)

				-- Navigate diagnostics
				vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
				vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
				vim.keymap.set("n", "<leader>xq", vim.diagnostic.setloclist, opts)

				-- Symbols (Telescope → fzf-lua)
				vim.keymap.set("n", "<leader>ds", fzf.lsp_document_symbols, opts)
				vim.keymap.set("n", "<leader>ws", fzf.lsp_workspace_symbols, opts)

				-- Workspace folders (same as before)
				vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
				vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
				vim.keymap.set("n", "<leader>lw", function()
					print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
				end, opts)
			end

			-- capabilities for autocompletion
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			-- All LSP servers config
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

			-- start all servers
			for name, config in pairs(servers) do
				config.name = name
				config.root_dir = vim.fs.root(0, { ".git", "go.mod", "package.json", "pyproject.toml" })
				vim.lsp.start(config)
			end
		end,
	},
}
