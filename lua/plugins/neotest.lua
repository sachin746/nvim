return {
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"antoinemadec/FixCursorHold.nvim",
			"nvim-treesitter/nvim-treesitter",
			"nvim-neotest/neotest-go",
		},
		keys = {
			{ "<leader>nt", function() require("neotest").run.run() end,                   desc = "Test: run nearest" },
			{ "<leader>nf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Test: run file" },
			{ "<leader>ns", function() require("neotest").summary.toggle() end,            desc = "Test: summary panel" },
			{ "<leader>no", function() require("neotest").output_panel.toggle() end,       desc = "Test: output panel" },
			{ "<leader>nS", function() require("neotest").run.stop() end,                  desc = "Test: stop" },
			{ "]t", function() require("neotest").jump.next({ status = "failed" }) end,    desc = "Next failed test" },
			{ "[t", function() require("neotest").jump.prev({ status = "failed" }) end,    desc = "Prev failed test" },
		},
		config = function()
			require("neotest").setup({
				adapters = {
					require("neotest-go")({
						experimental = { test_table = true },
					}),
				},
			})
		end,
	},
}
