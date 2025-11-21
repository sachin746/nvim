-- Move selected lines up/down in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Move current line up/down in normal mode
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==")
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==")

-- terminal
vim.keymap.set("n", "<leader>tf", "<cmd>ToggleTerm direction=float<CR>")
vim.keymap.set("n", "<leader>tt", "<cmd>ToggleTerm direction=horizontal<CR>")

-- Tab navigation

-- buffer
vim.keymap.set("n", "<leader>bd", ":bdelete<CR>", { desc = "Close current buffer" })
vim.keymap.set("n", "<S-h>", "<cmd>bp<CR>", { desc = "Next tab" })
vim.keymap.set("n", "<S-l>", "<cmd>bn<CR>", { desc = "Prev tab" })
vim.keymap.set("n", "<leader>W", "<cmd>set wrap!<CR>", { desc = "toggle wrap" })

-- env set
local env_base = vim.fn.expand("~/env/goProject")
vim.keymap.set("n", "<leader>eq", function()
	vim.cmd("Dotenv " .. env_base .. "/.env.qa")
	vim.g.current_env = "qa"
	vim.notify("Loaded .env.qa ⚙️")
end, { desc = "Load QA Environment" })

vim.keymap.set("n", "<leader>ep", function()
	vim.cmd("Dotenv " .. env_base .. "/.env.prod")
	vim.g.current_env = "prod"
	vim.notify("Loaded .env.prod 🚀")
end, { desc = "Load Prod Environment" })

-- kulala http client
vim.keymap.set("n", "<leader>kk", "<cmd>Kulala run<cr>", { desc = "Send HTTP request" })
vim.keymap.set("n", "<leader>kl", "<cmd>Kulala last<cr>", { desc = "Repeat last request" })
vim.keymap.set("n", "<leader>kf", "<cmd>Kulala fmt<cr>", { desc = "Format HTTP buffer" })
vim.keymap.set("n", "<leader>kc", "<cmd>Kulala curl<cr>", { desc = "Convert to curl command" })

---- c++ configs
local test = require("custom.test")
vim.keymap.set("n", '<leader>"', test.Closetxt, { desc = "Open input/output files" })
vim.keymap.set("n", "<C-'>", test.runCPP, { desc = "Running cpp" })
