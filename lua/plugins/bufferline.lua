return {
	"akinsho/bufferline.nvim",
	version = "*",
	dependencies = "nvim-tree/nvim-web-devicons",
	opts = {
		options = {
			diagnostics = "nvim_lsp",
			diagnostics_indicator = function(_, _, diag)
				local icons = { error = " ", warning = " " }
				return (diag.error and icons.error .. diag.error or "")
					.. (diag.warning and icons.warning .. diag.warning or "")
			end,
			offsets = {
				{ filetype = "oil", text = "Files", highlight = "Directory", separator = true },
			},
		},
	},
}
