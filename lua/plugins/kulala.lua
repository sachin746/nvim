return {
	"mistweaverco/kulala.nvim",
	ft = { "http" },
	dependencies = { "nvim-lua/plenary.nvim" },
	opts = {

		global_keymaps_prefix = "<leader>R",
		kulala_keymaps_prefix = "",
		global_keymaps = {
			["Send request"] = { -- sets global mapping
				"<leader>kk",
				function()
					require("kulala").run()
				end,
				mode = { "n", "v" }, -- optional mode, default is n
				desc = "Send request", -- optional description, otherwise inferred from the key
			},
			["Get Curl"] = {
				"<leader>kc",
				function()
					require("kulala").copy()
				end,
				mode = { "n", "v" },
				ft = "http", -- sets mapping for *.http files only
			},
			["Paste Curl"] = {

				"<leader>kp",
				function()
					require("kulala").from_curl()
				end,
				mode = { "n", "v" },
				ft = "http", -- sets mapping for *.http files only
			},
			["Replay the last request"] = {
				"<leader>kl",
				function()
					require("kulala").replay()
				end,
				ft = { "http", "rest" }, -- sets mapping for specified file types
			},
			["Find request"] = false, -- set to false to disable
		},
	},
}
