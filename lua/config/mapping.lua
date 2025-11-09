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
