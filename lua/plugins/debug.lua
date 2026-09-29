return {
	{
		"mfussenegger/nvim-dap",
		lazy = true,
		dependencies = {
			"leoluz/nvim-dap-go",
			"theHamsta/nvim-dap-virtual-text",
			"nvim-neotest/nvim-nio",
			"mason-org/mason.nvim",
			"igorlfs/nvim-dap-view",
		},

		keys = {
			{
				"<F1>",
				function()
					require("dap").continue()
				end,
				desc = "Start/Continue debugging",
			},
			{
				"<F2>",
				function()
					require("dap").step_over()
				end,
				desc = "Step over",
			},
			{
				"<F3>",
				function()
					require("dap").step_into()
				end,
				desc = "Step into",
			},
			{
				"<F4>",
				function()
					require("dap").step_out()
				end,
				desc = "Step out",
			},
			{
				"<F5>",
				function()
					require("dap").toggle_breakpoint()
				end,
				desc = "Toggle breakpoint",
			},

			-- Eval (dap-view)
			{
				"<F6>",
				function()
					require("dap-view").eval()
				end,
				desc = "Evaluate expression",
				mode = { "n", "v" },
			},

			{
				"<F7>",
				function()
					require("dap").repl.open({ wrap = true })
				end,
				desc = "Open REPL",
			},
			{
				"<F8>",
				function()
					require("dap").restart()
				end,
				desc = "Restart debug session",
			},

			-- Optional manual toggle for dap-view
			{
				"<leader>dv",
				function()
					require("dap-view").open()
				end,
				desc = "Open dap-view",
			},
			{
				"<leader>dV",
				function()
					require("dap-view").close()
				end,
				desc = "Close dap-view",
			},
		},

		config = function()
			local dap = require("dap")
			local dapview = require("dap-view")

			dapview.setup()
			require("dap-go").setup()

			local function get_args()
				return coroutine.create(function(dap_run_co)
					vim.ui.input({ prompt = "Args (blank for none): " }, function(input)
						coroutine.resume(dap_run_co, vim.split(input or "", " ", { trimempty = true }))
					end)
				end)
			end

			-- simplify: skip dap-go's config picker, just run the current package
			dap.configurations.go = {
				{
					type = "go",
					name = "Debug",
					request = "launch",
					program = "${fileDirname}",
					outputMode = "remote",
					args = get_args,
				},
			}

			require("nvim-dap-virtual-text").setup({
				display_callback = function(variable)
					local name = string.lower(variable.name)
					local value = string.lower(variable.value)

					if name:match("secret") or name:match("api") or value:match("secret") or value:match("api") then
						return "*****"
					end

					if #variable.value > 15 then
						return " " .. string.sub(variable.value, 1, 15) .. "... "
					end

					return " " .. variable.value
				end,
			})

			-- Auto open dap-view on start; leave it open on exit so fast-exiting
			-- programs (no breakpoint hit) don't flicker open/closed.
			dap.listeners.after.event_initialized["dap-view"] = function()
				dapview.open()
			end

			-- Elixir debugger (unchanged)
			local elixir_ls_debugger = vim.fn.exepath("elixir-ls-debugger")
			if elixir_ls_debugger ~= "" then
				dap.adapters.mix_task = { type = "executable", command = elixir_ls_debugger }
				dap.configurations.elixir = {
					{
						type = "mix_task",
						name = "phoenix server",
						task = "phx.server",
						request = "launch",
						projectDir = "${workspaceFolder}",
						exitAfterTaskReturns = false,
						debugAutoInterpretAllModules = false,
					},
				}
			end
		end,
	},
}
