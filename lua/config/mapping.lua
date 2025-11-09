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

-- buffer line
vim.keymap.set("n", "<leader>bd", ":bdelete<CR>", { desc = "Close current buffer" })
vim.keymap.set("n", "<S-h>", "<cmd>bp<CR>", { desc = "Next tab" })
vim.keymap.set("n", "<S-l>", "<cmd>bn<CR>", { desc = "Prev tab" })

-- env set
local env_base = vim.fn.expand("~/env/goProject")
vim.keymap.set("n", "<leader>eq", function()
	vim.cmd("Dotenv " .. env_base .. "/.env.qa")
	vim.g.current_env = "qa"
	print("Loaded .env.qa ⚙️")
end, { desc = "Load QA Environment" })

vim.keymap.set("n", "<leader>ep", function()
	vim.cmd("Dotenv " .. env_base .. "/.env.prod")
	vim.g.current_env = "prod"
	print("Loaded .env.prod 🚀")
end, { desc = "Load Prod Environment" })
