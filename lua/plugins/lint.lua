return {
	"mfussenegger/nvim-lint",
	event = { "BufWritePost", "InsertLeave" },
	config = function()
		local lint = require("lint")

		lint.linters_by_ft = {
			go = { "golangcilint" },
		}

		-- golangci-lint v2: --out-format → --output.formats; --show-stats removed
		lint.linters.golangcilint = vim.tbl_deep_extend("force", lint.linters.golangcilint, {
			args = {
				"run",
				"--output.formats=json",
				function()
					return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":h")
				end,
			},
		})

		vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
			callback = function()
				lint.try_lint()
			end,
		})
	end,
}
