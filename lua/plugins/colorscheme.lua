-- lua/plugins/rose-pine.lua
return {
	"catppuccin/nvim",
	name = "catppuccin",
	priority = 1000,

	config = function()
		vim.cmd("colorscheme catppuccin")
	end,
}
