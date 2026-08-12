-- Move selected lines up/down in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Move current line up/down in normal mode
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })

-- Resize splits (Ctrl-w > often stolen by terminal / needs Shift+.)
vim.keymap.set("n", "<A-Left>", "<cmd>vertical resize -5<CR>", { desc = "Shrink width" })
vim.keymap.set("n", "<A-Right>", "<cmd>vertical resize +5<CR>", { desc = "Grow width" })
vim.keymap.set("n", "<A-Up>", "<cmd>resize +5<CR>", { desc = "Grow height" })
vim.keymap.set("n", "<A-Down>", "<cmd>resize -5<CR>", { desc = "Shrink height" })

-- terminal
vim.keymap.set("n", "<leader>tf", "<cmd>ToggleTerm direction=float<CR>", { desc = "Toggle floating terminal" })
vim.keymap.set("n", "<leader>tt", "<cmd>ToggleTerm direction=horizontal<CR>", { desc = "Toggle horizontal terminal" })

-- Tab navigation

-- buffer
vim.keymap.set("n", "<leader>bd", ":bdelete<CR>", { desc = "Close current buffer" })
vim.keymap.set("n", "<S-h>", "<cmd>bp<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>bn<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>W", "<cmd>set wrap!<CR>", { desc = "Toggle wrap" })

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

-- kulala keymaps live in lua/plugins/kulala.lua (no :Kulala user command)
---- c++ configs
local test = require("custom.test")
vim.keymap.set("n", '<leader>"', test.Closetxt, { desc = "Open input/output files" })
vim.keymap.set("n", "<C-'>", test.runCPP, { desc = "Run cpp" })
