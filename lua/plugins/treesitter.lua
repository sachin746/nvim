
return {
	"nvim-treesitter/nvim-treesitter",
	branch = 'master', 
	lazy = false, 
	build = ":TSUpdate",
	config = function() 
		require("nvim.treesitter.configs").setup({
			-- languages to install (others can be added later)
        		ensure_installed = {
          			"lua",
				"bash",
				"go",
				"json",
				"yml",
				"python",
			},
			-- automatically install missing parsers
        		auto_install = true,

        		-- enable syntax highlighting
        		highlight = {
          			enable = true,
          			additional_vim_regex_highlighting = false,
       		 	},

        		-- enable indentation
        		indent = { enable = true }
		})	
	end,
}

