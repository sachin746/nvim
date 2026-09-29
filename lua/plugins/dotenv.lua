return {
	"ellisonleao/dotenv.nvim",
	config = function()
		vim.g.current_env = vim.g.current_env or "qa"

		local function service_env_file()
			local root = vim.fs.root(0, { ".git", "go.mod" }) or vim.fn.getcwd()
			local service = vim.fn.fnamemodify(root, ":t")
			return vim.fn.expand("~/env/" .. service .. "/.env." .. vim.g.current_env)
		end

		local function load_service_env()
			local file = service_env_file()
			if vim.fn.filereadable(file) == 1 then
				require("dotenv").command({ fargs = { file } })
			end
		end

		require("dotenv").setup({
			enable_on_load = false, -- we drive loading ourselves, per service
			verbose = false,
		})

		local group = vim.api.nvim_create_augroup("DotenvPerService", { clear = true })
		vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
			group = group,
			callback = load_service_env,
		})

		local function switch_env(env)
			vim.g.current_env = env
			local file = service_env_file()
			if vim.fn.filereadable(file) == 0 then
				vim.notify("No " .. env .. " env file for this service: " .. file, vim.log.levels.WARN)
				return
			end
			load_service_env()
			vim.notify("Switched to " .. env .. " env (" .. file .. ")")
		end

		vim.keymap.set("n", "<leader>eq", function()
			switch_env("qa")
		end, { desc = "Env: switch to qa" })
		vim.keymap.set("n", "<leader>ep", function()
			switch_env("prod")
		end, { desc = "Env: switch to prod" })
	end,
}
