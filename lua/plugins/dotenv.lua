return {
	"ellisonleao/dotenv.nvim",
	config = function()
		require("dotenv").setup({
			enable_on_load = true, -- load automatically on startup
			verbose = false,
			file_name = vim.fn.expand("~/env/goProject/.env.qa"), -- absolute path
		})
		-- optional: store env type for lualine
		vim.g.current_env = "qa"
	end,
}
