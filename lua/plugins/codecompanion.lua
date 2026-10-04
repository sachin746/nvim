return {
	"olimorris/codecompanion.nvim",
	cmd = { "CodeCompanionChat", "CodeCompanion", "CodeCompanionActions" },
	dependencies = {
		-- needed to install additional parsers
		{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
		{ "nvim-lua/plenary.nvim" },
		-- Test with blink.cmp (delete if not required)
		{
			"saghen/blink.cmp",
			lazy = false,
			version = "*",
			opts = {
				keymap = {
					preset = "enter",
					["<S-Tab>"] = { "select_prev", "fallback" },
					["<Tab>"] = { "select_next", "fallback" },
				},
				cmdline = { sources = { "cmdline" } },
				sources = {
					default = { "lsp", "path", "buffer" },
					per_filetype = {
						codecompanion = { "codecompanion" },
						sql = { "dadbod", "lsp", "path", "buffer" },
						mysql = { "dadbod", "lsp", "path", "buffer" },
						plsql = { "dadbod", "lsp", "path", "buffer" },
					},
					providers = {
						dadbod = {
							name = "Dadbod",
							module = "vim_dadbod_completion.blink",
						},
					},
				},
			},
		},
		-- Test with nvim-cmp
		-- { "hrsh7th/nvim-cmp" },
	},
	config = function(_, opts)
		local adapters = require("codecompanion.adapters")
		local use_proxy = vim.env.ANTHROPIC_AUTH_TOKEN ~= nil and vim.env.ANTHROPIC_BASE_URL ~= nil

		if use_proxy then
			local base_url = vim.env.ANTHROPIC_BASE_URL:gsub("/$", "")
			opts.adapters = {
				http = {
					anthropic_proxy = function()
						return adapters.extend("anthropic", {
							env = { api_key = "ANTHROPIC_AUTH_TOKEN" },
							url = base_url .. "/v1/messages",
							schema = {
								model = {
									default = "claude-sonnet-4-6",
									choices = {
										"claude-sonnet-4-6",
										"claude-haiku-4-5",
										"claude-sonnet-4-6",
									},
								},
							},
						})
					end,
				},
			}
			opts.strategies = {
				chat = { adapter = "anthropic_proxy" },
				inline = { adapter = "anthropic_proxy" },
			}
		else
			-- personal: use copilot
			opts.strategies = {
				chat = { adapter = "copilot" },
				inline = { adapter = "copilot" },
			}
		end

		require("codecompanion").setup(opts)
	end,
	opts = {
		opts = {
			log_level = "ERROR",
		},
	},
}
