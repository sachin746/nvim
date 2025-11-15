return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		for _, parser in ipairs({
			"lua",
			"python",
			"go",
			"http",
			"cpp",
			"javascript",
			"html",
			"css",
			"json",
			"bash",
		}) do
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { parser },
				callback = function()
					vim.treesitter.start()
					vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
					vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end,
			})
		end

		require("nvim-treesitter").setup({})
	end,
}
