-- ===============================
-- 🌙 Neovim Options (with comments)
-- ===============================

local opt = vim.opt -- shorthand for setting options

-- ---------- General ----------
opt.number = true -- show line numbers
opt.relativenumber = true -- show relative line numbers (easier movement)
opt.mouse = "a" -- enable mouse support in all modes
opt.clipboard = "unnamedplus" -- use system clipboard for copy/paste
opt.swapfile = false -- disable swapfile (no .swp files)
opt.backup = false -- don’t create backup files
opt.undofile = true -- enable persistent undo history
opt.autoread = true -- auto-reload file when changed outside Neovim
opt.hidden = true -- allow switching buffers without saving

-- ---------- Searching ----------
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- but make it case-sensitive if uppercase used
opt.hlsearch = true -- highlight search matches
opt.incsearch = true -- show matches as you type

-- ---------- Indentation ----------
opt.expandtab = true -- convert tabs to spaces
opt.shiftwidth = 4 -- spaces per indentation level
opt.tabstop = 4 -- number of spaces per tab
opt.smartindent = true -- smarter auto-indenting
opt.autoindent = true -- copy indent from current line when starting new line

-- ---------- UI ----------
opt.termguicolors = true -- enable 24-bit RGB colors
opt.signcolumn = "yes" -- always show sign column (for git/lsp icons)
opt.cursorline = true -- highlight current line
opt.wrap = false -- disable line wrapping
opt.scrolloff = 8 -- minimum lines to keep above/below cursor
opt.sidescrolloff = 8 -- same but for left/right
opt.cmdheight = 1 -- height of command line area
opt.showmode = false -- don’t show mode (since statusline shows it)
opt.laststatus = 3 -- global statusline across all windows

-- ---------- Splits ----------
opt.splitbelow = true -- new horizontal splits open below
opt.splitright = true -- new vertical splits open to the right

-- ---------- Performance ----------
opt.updatetime = 300 -- faster diagnostics / completion response
opt.timeoutlen = 300 -- faster key sequence timeout

-- ---------- Appearance ----------
opt.colorcolumn = "100" -- show vertical line at column 100
opt.background = "dark" -- set background to dark
opt.title = true -- show file name in terminal title

-- ---------- Files & Encoding ----------
opt.encoding = "utf-8" -- default encoding
opt.fileencoding = "utf-8" -- file encoding
opt.fileformats = { "unix", "dos", "mac" } -- prefer Unix line endings

-- ---------- Others ----------
opt.shortmess:append("c") -- don’t show completion messages
opt.completeopt = { "menuone", "noselect" } -- better completion experience
opt.backspace = { "indent", "eol", "start" } -- backspace over anything

-- ---------- Folding ----------
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldenable = false
vim.opt.foldlevelstart = 99

vim.fn.sign_define("DapBreakpoint", { text = "🟥", texthl = "", linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointCondition", { text = "🟨", texthl = "", linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointRejected", { text = "", texthl = "", linehl = "", numhl = "" })
vim.fn.sign_define("DapStopped", { text = "🟢", texthl = "", linehl = "", numhl = "" })
