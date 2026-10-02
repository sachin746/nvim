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
			automatic_enable = false,
			ensure_installed = {
				"lua_ls",
				"gopls",
				"pyright",
				"ts_ls",
				"html",
				"cssls",
				"jsonls",
				"clangd",
			},
		},
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
		},
	},

	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = { "ibhagwan/fzf-lua", "saghen/blink.cmp" },
		config = function()
			local fzf = require("fzf-lua")

			local function on_attach(_, bufnr)
				local function map(lhs, rhs, desc)
					vim.keymap.set("n", lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
				end

				map("gd", fzf.lsp_definitions, "LSP: definition")
				map("gr", fzf.lsp_references, "LSP: references")
				map("gi", fzf.lsp_implementations, "LSP: implementations")
				map("gt", fzf.lsp_typedefs, "LSP: type definition")

				map("gD", vim.lsp.buf.declaration, "LSP: declaration")
				map("K", vim.lsp.buf.hover, "LSP: hover")

				map("<leader>ca", vim.lsp.buf.code_action, "LSP: code action")
				map("<leader>rn", vim.lsp.buf.rename, "LSP: rename")

				map("<leader>fo", function()
					vim.lsp.buf.format({ async = true })
				end, "Format current buffer")

				map("<leader>xx", fzf.diagnostics_workspace, "Diagnostics: workspace")
				map("<leader>xd", fzf.diagnostics_document, "Diagnostics: document")

				map("[d", vim.diagnostic.goto_prev, "Diagnostic: previous")
				map("]d", vim.diagnostic.goto_next, "Diagnostic: next")
				map("<leader>xq", vim.diagnostic.setloclist, "Diagnostics: loclist")

				map("<leader>ds", fzf.lsp_document_symbols, "LSP: document symbols")
				map("<leader>ws", fzf.lsp_workspace_symbols, "LSP: workspace symbols")

				map("<leader>wa", vim.lsp.buf.add_workspace_folder, "LSP: add workspace folder")
				map("<leader>wr", vim.lsp.buf.remove_workspace_folder, "LSP: remove workspace folder")
				map("<leader>lw", function()
					print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
				end, "LSP: list workspace folders")
			end

			local capabilities = require("blink.cmp").get_lsp_capabilities()
			local root_markers = { ".git", "go.mod", "package.json", "pyproject.toml" }

			local servers = {
				lua_ls = {
					filetypes = { "lua" },
					cmd = { "lua-language-server" },
					settings = {
						Lua = {
							diagnostics = { globals = { "vim" } },
						},
					},
				},
				gopls = {
					filetypes = { "go", "gomod", "gowork", "gotmpl" },
					cmd = { "gopls" },
				},
				pyright = {
					filetypes = { "python" },
					cmd = { "pyright-langserver", "--stdio" },
				},
				ts_ls = {
					filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
					cmd = { "typescript-language-server", "--stdio" },
				},
				html = {
					filetypes = { "html" },
					cmd = { "vscode-html-language-server", "--stdio" },
				},
				cssls = {
					filetypes = { "css", "scss", "less" },
					cmd = { "vscode-css-language-server", "--stdio" },
				},
				jsonls = {
					filetypes = { "json", "jsonc" },
					cmd = { "vscode-json-language-server", "--stdio" },
				},
				clangd = {
					filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
					cmd = { "clangd" },
				},
			}

			for name, config in pairs(servers) do
				vim.api.nvim_create_autocmd("FileType", {
					pattern = config.filetypes,
					callback = function(ev)
						vim.lsp.start({
							name = name,
							cmd = config.cmd,
							settings = config.settings,
							capabilities = capabilities,
							on_attach = on_attach,
							root_dir = vim.fs.root(ev.buf, root_markers),
						})
					end,
				})
			end
		end,
	},
}
