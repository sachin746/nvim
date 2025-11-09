local colors = {
	bg = "#202328",
	fg = "#bbc2cf",
	yellow = "#ECBE7B",
	cyan = "#008080",
	darkblue = "#081633",
	green = "#98be65",
	orange = "#FF8800",
	violet = "#a9a1e1",
	magenta = "#c678dd",
	blue = "#51afef",
	red = "#ec5f67",
}
local env = {
	function()
		return vim.g.current_env
	end,
	color = { fg = colors.blue, gui = "bold" }, -- Sets highlighting of component
	padding = { left = 1, right = 1 }, -- We don't need space before this
}
return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	event = "VeryLazy",
	opts = {
		theme = "gruvbox",
		sections = {
			lualine_c = { "filename", env },
		},
	},
}
