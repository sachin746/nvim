return {
	"lewis6991/gitsigns.nvim",
	event = "VeryLazy",
	opts = {
		current_line_blame = true,
		current_line_blame_opts = {
			delay = 300,
			virt_text_pos = "eol",
			numhl = true,
			sign_priority = 15,
		},

		on_attach = function(bufnr)
			local gitsigns = require("gitsigns")

			local function map(mode, l, r, opts)
				opts = opts or {}
				opts.buffer = bufnr
				vim.keymap.set(mode, l, r, opts)
			end

			-- Navigation
			map("n", "]c", function()
				if vim.wo.diff then
					vim.cmd.normal({ "]c", bang = true })
				else
					gitsigns.nav_hunk("next")
				end
			end)

			map("n", "[c", function()
				if vim.wo.diff then
					vim.cmd.normal({ "[c", bang = true })
				else
					gitsigns.nav_hunk("prev")
				end
			end)

			map("n", "<leader>hb", function()
				gitsigns.blame({ full = true })
			end)

			map("n", "<leader>hd", gitsigns.diffthis)
		end,
	},
}
