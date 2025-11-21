local M = {}

function M.open()
	local input = vim.fn.expand("~/Desktop/DSA/cpp/input.txt")
	local output = vim.fn.expand("~/Desktop/DSA/cpp/output.txt")

	local bufflist = vim.api.nvim_list_bufs()
	for _, buf in ipairs(bufflist) do
		local bufname = vim.api.nvim_buf_get_name(buf)
		if bufname == input or bufname == output then
			vim.api.nvim_buf_delete(buf, { force = true })
		end
	end

	vim.cmd("vsplit " .. input)
	vim.cmd("split " .. output)
	M.focusCppLastPosition()
end

function M.Closetxt()
	local input = vim.fn.expand("~/Desktop/DSA/cpp/input.txt")
	local output = vim.fn.expand("~/Desktop/DSA/cpp/output.txt")

	local bufflist = vim.api.nvim_list_bufs()
	for _, buf in ipairs(bufflist) do
		local bufname = vim.api.nvim_buf_get_name(buf)
		if bufname == input or bufname == output then
			vim.api.nvim_buf_delete(buf, { force = true })
		end
	end
end

function M.runCPP()
	local input = vim.fn.expand("~/Desktop/DSA/cpp/input.txt")
	local output = vim.fn.expand("~/Desktop/DSA/cpp/output.txt")
	local filename = vim.fn.expand("%:p")
	local compiled = vim.fn.expand("%:p:r") .. ".out"

	-- Compile the C++ file
	local compile_cmd = "g++ -std=c++17 -O2 -Wall -Wextra -o " .. compiled .. " " .. filename .. " 2> " .. output
	local compile_result = os.execute(compile_cmd)

	if compile_result ~= 0 then
		vim.notify("Compilation failed!.", vim.log.levels.ERROR)
		M.open()
		return
	end

	-- Run the compiled program with input redirection and capture output
	local run_cmd = compiled .. " < " .. input .. " > " .. output
	local run_result = os.execute(run_cmd)

	vim.notify("Execution completed.", vim.log.levels.INFO)
	if run_result ~= 0 then
		print("Execution failed!")
		M.open()
		return
	end

	M.open()
	print("Run successful!")
end

function M.focusCppLastPosition()
	-- Get all open buffers
	local bufs = vim.api.nvim_list_bufs()

	for _, buf in ipairs(bufs) do
		local name = vim.api.nvim_buf_get_name(buf)

		-- Check if buffer is a C++ file
		if name:match("%.cpp$") then
			local win = vim.fn.bufwinid(buf)

			if win == -1 then
				print("C++ buffer found but not visible in a window")
				return
			end

			-- Get last position mark (")
			local pos = vim.api.nvim_buf_get_mark(buf, '"')
			local line, col = pos[1], pos[2]

			-- If mark is empty, go to top of file
			if line == 0 then
				line = 1
				col = 0
			end

			-- Move cursor
			vim.api.nvim_set_current_win(win)
			vim.api.nvim_win_set_cursor(win, { line, col })

			return
		end
	end

	print("No C++ buffer found")
end

return M
