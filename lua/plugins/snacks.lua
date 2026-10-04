return {
	"folke/snacks.nvim",
	event = "VeryLazy",
	keys = {
		{ "<leader>gg", function() require("snacks").lazygit() end,          desc = "Lazygit" },
		{ "<leader>gf", function() require("snacks").lazygit.log_file() end, desc = "Git log (file)" },
		{ "<leader>gl", function() require("snacks").lazygit.log() end,      desc = "Git log (repo)" },
		{ "]]", function() require("snacks").words.jump(1,  true) end, desc = "Next word reference" },
		{ "[[", function() require("snacks").words.jump(-1, true) end, desc = "Prev word reference" },
	},
	opts = {
		indent = {},
		words = {},
		scope = {},
		lazygit = {},
	},
}
