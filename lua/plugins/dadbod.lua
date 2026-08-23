return {
	"kristijanhusak/vim-dadbod-ui",
	dependencies = {
		{ "tpope/vim-dadbod", lazy = true },
		{
			"kristijanhusak/vim-dadbod-completion",
			ft = { "sql", "mysql", "plsql" },
			lazy = true,
		},
	},
	cmd = {
		"DBUI",
		"DBUIToggle",
		"DBUIAddConnection",
		"DBUIFindBuffer",
	},
	keys = {
		{ "<leader>Du", "<cmd>DBUIToggle<CR>", desc = "DB: toggle UI" },
		{ "<leader>Da", "<cmd>DBUIAddConnection<CR>", desc = "DB: add connection" },
		{ "<leader>Df", "<cmd>DBUIFindBuffer<CR>", desc = "DB: find buffer" },
		{ "<leader>Dr", "<cmd>DBUIRenameBuffer<CR>", desc = "DB: rename buffer" },
		{ "<leader>Di", "<cmd>DBUILastQueryInfo<CR>", desc = "DB: last query info" },
	},
	init = function()
		vim.g.db_ui_use_nerd_fonts = 1
		vim.g.db_ui_win_position = "left"
		vim.g.db_ui_show_database_icon = 1
		-- execute query on :w in sql buffers opened from DBUI
		vim.g.db_ui_execute_on_save = 1
	end,
	config = function()
		-- SQL omnifunc completion via nvim-cmp when editing queries
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "sql", "mysql", "plsql" },
			callback = function(args)
				local ok, cmp = pcall(require, "cmp")
				if ok then
					cmp.setup.buffer({
						sources = cmp.config.sources({
							{ name = "vim-dadbod-completion" },
							{ name = "buffer" },
						}),
					})
				end

				-- dadbod caches :params in b:dbui_bind_params; clear so it asks every run
				vim.api.nvim_create_autocmd("BufWritePre", {
					buffer = args.buf,
					callback = function()
						vim.b.dbui_bind_params = nil
					end,
				})
				-- after dadbod's ftplugin maps <Leader>S
				vim.schedule(function()
					if not vim.api.nvim_buf_is_valid(args.buf) then
						return
					end
					vim.keymap.set({ "n", "v" }, "<Leader>S", function()
						vim.b.dbui_bind_params = nil
						return "<Plug>(DBUI_ExecuteQuery)"
					end, {
						buffer = args.buf,
						expr = true,
						remap = true,
						silent = true,
						desc = "DB: execute (ask params every time)",
					})
				end)
			end,
		})
	end,
}
