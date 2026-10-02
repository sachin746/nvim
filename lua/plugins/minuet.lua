return {
	"milanglacier/minuet-ai.nvim",
	event = "InsertEnter",
	config = function()
		local auth_token = vim.env.ANTHROPIC_AUTH_TOKEN
		local base_url = vim.env.ANTHROPIC_BASE_URL
		local enabled = auth_token ~= nil and base_url ~= nil

		local opts = {
			provider = "claude",
			provider_options = {
				claude = {
					model = "claude-sonnet-4-6",
					max_tokens = 512,
					api_key = "ANTHROPIC_AUTH_TOKEN",
					end_point = enabled and (base_url:gsub("/$", "") .. "/v1/messages") or nil,
				},
			},
			virtualtext = {
				auto_trigger_ft = enabled and { "*" } or {},
				keymap = {
					accept = "<A-a>",
					accept_line = "<A-l>",
					accept_n_lines = "<A-z>",
					prev = "<A-[>",
					next = "<A-]>",
					dismiss = "<A-e>",
				},
			},
		}

		require("minuet").setup(opts)
	end,
}
