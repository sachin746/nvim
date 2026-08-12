return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		-- http is owned by kulala.nvim (kulala_http parser) — do not install/start stock http
		local parsers = {
			"lua",
			"python",
			"go",
			"cpp",
			"javascript",
			"html",
			"css",
			"json",
			"bash",
		}

		require("nvim-treesitter").setup({})
		require("nvim-treesitter").install(parsers)

		vim.api.nvim_create_autocmd("FileType", {
			pattern = parsers,
			callback = function()
				vim.treesitter.start()
				vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
				vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end,
		})
	end,
}
