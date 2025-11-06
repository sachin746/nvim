return {
	{
		"hrsh7th/nvim-cmp", -- Core completion engine
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp", -- LSP completions
			"hrsh7th/cmp-buffer", -- Buffer words
			"hrsh7th/cmp-path", -- Filesystem paths
			"hrsh7th/cmp-cmdline", -- Command-line completion
			"saadparwaiz1/cmp_luasnip", -- Snippet source
			"L3MON4D3/LuaSnip", -- Snippet engine
			"onsails/lspkind.nvim", -- VSCode-like pictograms
			"rafamadriz/friendly-snippets", -- Predefined snippets
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			local lspkind = require("lspkind")

			-- Load VSCode-style snippets
			require("luasnip.loaders.from_vscode").lazy_load()

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-Space>"] = cmp.mapping.complete(), -- trigger manually
					["<CR>"] = cmp.mapping.confirm({ select = true }), -- confirm selection
					["<Tab>"] = cmp.mapping.select_next_item(), -- next item
					["<S-Tab>"] = cmp.mapping.select_prev_item(), -- prev item
					["<C-e>"] = cmp.mapping.abort(), -- close menu
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" }, -- LSP suggestions
					{ name = "luasnip" }, -- snippets
					{ name = "buffer" }, -- words from open buffer
					{ name = "path" }, -- filesystem paths
				}),
				formatting = {
					format = lspkind.cmp_format({
						mode = "symbol_text", -- show symbol + text
						maxwidth = 50,
						ellipsis_char = "...",
					}),
				},
				experimental = {
					ghost_text = true, -- faint preview text
				},
			})
		end,
	},
}
