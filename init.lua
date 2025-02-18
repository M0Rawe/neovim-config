-- Tab settings
vim.cmd("set expandtab")
vim.cmd("set tabstop=4")
vim.cmd("set softtabstop=4")
vim.cmd("set shiftwidth=4")

-- Visual settings
vim.cmd("set rnu")
vim.cmd("set mouse=")

-- Search settings
vim.cmd("set ignorecase")
vim.cmd("set smartcase")

-- Clipboard settings
vim.opt.clipboard = "unnamedplus"

-- Import lazy nvim config
require("config.lazy")

-- Telescope setup
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<C-l>", builtin.live_grep, {})
vim.keymap.set("n", "<C-p>", builtin.find_files, {})
require("telescope").setup({
	extensions = {
		["ui-select"] = {
			require("telescope.themes").get_dropdown({}),
		},
	},
})
require("telescope").load_extension("ui-select")

-- Set catppuccin
require("catppuccin").setup()
vim.cmd.colorscheme("catppuccin")

-- Treesitter config
local config = require("nvim-treesitter.configs")
config.setup({
	-- ensure_installed = { "c", "python", "lua" },
	auto_install = true,
	highlight = { enable = true },
	indent = { enable = true },
})

-- Lualine config
require("lualine").setup({
	options = { theme = "OceanicNext" },
})

-- Mason install for lsp
require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = { "clangd", "lua_ls" },
})
require("lspconfig").lua_ls.setup({})
require'lspconfig'.clangd.setup{
    cmd = {"clangd", "--compile-commands-dir=/Users/Morawe/Flipper/Momentum-Firmware/build/f7-firmware-C"},
    filetypes = {"c", "cpp", "objc", "objcpp"},
    root_dir = require'lspconfig'.util.root_pattern("compile_commands.json", ".git"),
    init_options = {
        clangdFileStatus = true,
        -- Manually add include paths if not using compile_commands.json
        clangd = {
            compilationDatabaseDirectory = "/Users/morawe/Flipper/Momentum-Firmware",
            extraArgs = {
                "-I/Users/morawe/Flipper/Momentum-Firmware/furi/include",  -- Adjusted include path
            },
        },
    }
}
vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, {})

-- None-ls
local null_ls = require("null-ls")
null_ls.setup({
	sources = {
		null_ls.builtins.formatting.stylua,
		null_ls.builtins.diagnostics.cppcheck,
		null_ls.builtins.formatting.clang_format,
	},
})
vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})

-- gitsigns
require("gitsigns").setup()
vim.keymap.set("n", "<leader>gs", ":Gitsigns preview_hunk<Cr>", {})
vim.keymap.set("n", "<leader>gb", ":Gitsigns toggle_current_line_blame<Cr>", {})

-- run :Lazy update at first daily nvim
local update_file = vim.fn.stdpath("data") .. "/lazy_last_update"

local function needs_update()
	if vim.fn.filereadable(update_file) == 0 then
		vim.fn.writefile({ "0" }, update_file)
	end

	local last_update = tonumber(vim.fn.readfile(update_file)[1] or "0")
	local today = tonumber(os.date("%Y%m%d"))

	if last_update < today then
		vim.fn.writefile({ tostring(today) }, update_file)
		return true
	end
	return false
end

-- Run `:Lazy update` only if needed
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		if needs_update() then
			vim.schedule(function()
				-- Ensure Lazy.nvim is loaded before running update
				require("lazy").update()
			end)
		end
	end,
})
