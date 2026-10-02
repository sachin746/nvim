return {
	"xeluxee/competitest.nvim",
	dependencies = { "MunifTanjim/nui.nvim" },
	keys = {
		{ "<c-'>", "<cmd>CompetiTest run<CR>", desc = "run cpp" },
		{ "<c-;>", "<cmd>CompetiTest receive problem<CR>", desc = "receive problem" },
	},
	config = function()
		require("competitest").setup({
			compile_command = {
				cpp = {
					exec = "g++",
					args = {
						"-std=c++17",
						"-O2",
						"-Wall",
						"$(FNAME)",
						"-o",
						"$(FNOEXT)",
						"-I" .. vim.fn.expand("~/Desktop/DSA/cpp"),
					},
				},
			},

			run_command = {
				cpp = {
					exec = "./$(FNOEXT)",
				},
			},
			testcases_directory = vim.fn.expand("testcases/"),
			template_file = vim.fn.expand("~/Desktop/DSA/cpp/template.cpp"),

			runner_ui = {
				interface = "split", -- split | popup | float
				split = {
					position = "bottom",
					size = 10,
				},
			},
		})
	end,
}
