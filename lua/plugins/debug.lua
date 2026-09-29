local ansi_sgr_hl = {
	[30] = "DapAnsiBlack",
	[31] = "DapAnsiRed",
	[32] = "DapAnsiGreen",
	[33] = "DapAnsiYellow",
	[34] = "DapAnsiBlue",
	[35] = "DapAnsiMagenta",
	[36] = "DapAnsiCyan",
	[37] = "DapAnsiWhite",
	[90] = "DapAnsiBrightBlack",
	[91] = "DapAnsiBrightRed",
	[92] = "DapAnsiBrightGreen",
	[93] = "DapAnsiBrightYellow",
	[94] = "DapAnsiBrightBlue",
	[95] = "DapAnsiBrightMagenta",
	[96] = "DapAnsiBrightCyan",
	[97] = "DapAnsiBrightWhite",
}

local function setup_dap_ansi_highlights()
	local colors = {
		DapAnsiBlack = "#3b4048",
		DapAnsiRed = "#e06c75",
		DapAnsiGreen = "#98c379",
		DapAnsiYellow = "#e5c07b",
		DapAnsiBlue = "#61afef",
		DapAnsiMagenta = "#c678dd",
		DapAnsiCyan = "#56b6c2",
		DapAnsiWhite = "#dcdfe4",
		DapAnsiBrightBlack = "#5c6370",
		DapAnsiBrightRed = "#ef596f",
		DapAnsiBrightGreen = "#a5e075",
		DapAnsiBrightYellow = "#f0c674",
		DapAnsiBrightBlue = "#6cb2eb",
		DapAnsiBrightMagenta = "#d68fe0",
		DapAnsiBrightCyan = "#6fc6d6",
		DapAnsiBrightWhite = "#ffffff",
	}
	for name, hex in pairs(colors) do
		vim.api.nvim_set_hl(0, name, { fg = hex })
	end
end

-- Strips ANSI SGR escape codes (e.g. from a colored Go logger) out of a
-- line, returning the clean text plus {hl_group, start_col, end_col} spans
-- so the original colors can be re-applied as buffer highlights.
local function strip_ansi(line)
	local clean_parts = {}
	local spans = {}
	local col = 0
	local current_hl = nil
	local span_start = 0
	local i = 1
	while true do
		local s, e, codes = line:find("\27%[([0-9;]*)m", i)
		local chunk = s and line:sub(i, s - 1) or line:sub(i)
		if #chunk > 0 then
			clean_parts[#clean_parts + 1] = chunk
			col = col + #chunk
		end
		if not s then
			break
		end
		if current_hl and col > span_start then
			spans[#spans + 1] = { current_hl, span_start, col }
		end
		local new_hl = current_hl
		for code in (codes or ""):gmatch("%d+") do
			local n = tonumber(code)
			if n == 0 then
				new_hl = nil
			elseif ansi_sgr_hl[n] then
				new_hl = ansi_sgr_hl[n]
			end
		end
		current_hl = new_hl
		span_start = col
		i = e + 1
	end
	if current_hl and col > span_start then
		spans[#spans + 1] = { current_hl, span_start, col }
	end
	return table.concat(clean_parts), spans
end

-- Fallback coloring for programs that don't emit real ANSI codes: color the
-- whole line based on a recognized log-level keyword (works with the Go
-- stdlib logger, slog, zerolog/logrus text output, etc.)
local level_patterns = {
	{ "%f[%a]FATAL%f[%A]", "DapAnsiBrightRed" },
	{ "%f[%a]PANIC%f[%A]", "DapAnsiBrightRed" },
	{ "%f[%a]ERRO?R?%f[%A]", "DapAnsiRed" },
	{ "%f[%a]WARN%a*%f[%A]", "DapAnsiYellow" },
	{ "%f[%a]INFO%f[%A]", "DapAnsiGreen" },
	{ "%f[%a]DEBU?G?%f[%A]", "DapAnsiBlue" },
	{ "%f[%a]TRACE%f[%A]", "DapAnsiCyan" },
}

local function detect_level_hl(text)
	local upper = text:upper()
	for _, entry in ipairs(level_patterns) do
		if upper:find(entry[1]) then
			return entry[2]
		end
	end
end

local function dap_repl_bufnr()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.bo[buf].filetype == "dap-repl" then
			return buf
		end
	end
end

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

			setup_dap_ansi_highlights()
			vim.api.nvim_create_autocmd("ColorScheme", {
				callback = setup_dap_ansi_highlights,
			})

			dap.defaults.fallback.on_output = function(_, body)
				if body.category == "telemetry" then
					return
				end
				local repl = require("dap").repl
				for _, raw in ipairs(vim.split(body.output, "\n", { plain = true, trimempty = true })) do
					local text, spans = strip_ansi(raw)
					local lnum = repl.append(text, "$", { newline = true })
					local buf = dap_repl_bufnr()
					if buf then
						if #spans > 0 then
							for _, span in ipairs(spans) do
								vim.api.nvim_buf_add_highlight(buf, -1, span[1], lnum, span[2], span[3])
							end
						else
							local level_hl = detect_level_hl(text)
							if level_hl then
								vim.api.nvim_buf_add_highlight(buf, -1, level_hl, lnum, 0, -1)
							end
						end
					end
				end
			end

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
