vim.opt.termguicolors = true

-- ============================================================================
-- OPTIONS
-- ============================================================================
vim.opt.number = true
vim.opt.cursorline = true
vim.opt.wrap = true
vim.opt.scrolloff = 10
vim.opt.sidescrolloff = 10

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.signcolumn = "yes"
vim.opt.colorcolumn = "80"
vim.opt.showmatch = true
vim.opt.cmdheight = 1
vim.opt.completeopt = "menuone,noinsert,noselect"
vim.opt.showmode = false
vim.opt.pumheight = 10
vim.opt.pumblend = 10 -- popup menu transparency, need to review
vim.opt.winblend = 0 -- floating window transparency
vim.opt.conceallevel = 0 -- do not hide markup
vim.opt.concealcursor = ""
vim.opt.lazyredraw = true
vim.opt.synmaxcol = 300
vim.opt.fillchars = { eob = " " } -- hide "~" on empty lines

local undodir = vim.fn.expand("~/.vim/undodir")
if vim.fn.isdirectory(undodir) == 0 then
	vim.fn.mkdir(undodir, "p")
end

vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.undodir = undodir
vim.opt.updatetime = 300
vim.opt.timeoutlen = 500
vim.opt.ttimeoutlen = 0
vim.opt.autoread = true -- auto-reload changes if outside of neovim
vim.opt.autowrite = false -- don't autosave

vim.opt.hidden = true
vim.opt.errorbells = false
vim.opt.backspace = "indent,eol,start"
vim.opt.autochdir = false
vim.opt.path:append("**") -- include subdirs in search
vim.opt.selection = "inclusive"
vim.opt.mouse = "a"
vim.opt.clipboard:append("unnamedplus") -- use system clipboard
vim.opt.modifiable = true
vim.opt.encoding = "utf-8"

vim.opt.guicursor =
	"n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175" -- cursor blinking and settings

vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"
vim.opt.diffopt:append("linematch:60")
vim.opt.redrawtime = 10000
vim.opt.maxmempattern = 20000

-- -- ============================================================================
-- -- STATUSLINE
-- -- ============================================================================
--
-- -- Git branch function with caching and Nerd Font icon
-- local cached_branch = ""
-- local last_check = 0
-- local function git_branch()
-- 	local now = vim.loop.now()
-- 	if now - last_check > 5000 then -- Check every 5 seconds
-- 		cached_branch = vim.fn.system("git branch --show-current 2>/dev/null | tr -d '\n'")
-- 		last_check = now
-- 	end
-- 	if cached_branch ~= "" then
-- 		return " \u{e725} " .. cached_branch .. " " -- nf-dev-git_branch
-- 	end
-- 	return ""
-- end
--
-- -- File type with Nerd Font icon
-- local function file_type()
-- 	local ft = vim.bo.filetype
-- 	local icons = {
-- 		lua = "\u{e620} ", -- nf-dev-lua
-- 		python = "\u{e73c} ", -- nf-dev-python
-- 		javascript = "\u{e74e} ", -- nf-dev-javascript
-- 		typescript = "\u{e628} ", -- nf-dev-typescript
-- 		javascriptreact = "\u{e7ba} ",
-- 		typescriptreact = "\u{e7ba} ",
-- 		html = "\u{e736} ", -- nf-dev-html5
-- 		css = "\u{e749} ", -- nf-dev-css3
-- 		scss = "\u{e749} ",
-- 		json = "\u{e60b} ", -- nf-dev-json
-- 		markdown = "\u{e73e} ", -- nf-dev-markdown
-- 		vim = "\u{e62b} ", -- nf-dev-vim
-- 		sh = "\u{f489} ", -- nf-oct-terminal
-- 		bash = "\u{f489} ",
-- 		zsh = "\u{f489} ",
-- 		rust = "\u{e7a8} ", -- nf-dev-rust
-- 		go = "\u{e724} ", -- nf-dev-go
-- 		c = "\u{e61e} ", -- nf-dev-c
-- 		cpp = "\u{e61d} ", -- nf-dev-cplusplus
-- 		java = "\u{e738} ", -- nf-dev-java
-- 		php = "\u{e73d} ", -- nf-dev-php
-- 		ruby = "\u{e739} ", -- nf-dev-ruby
-- 		swift = "\u{e755} ", -- nf-dev-swift
-- 		kotlin = "\u{e634} ",
-- 		dart = "\u{e798} ",
-- 		elixir = "\u{e62d} ",
-- 		haskell = "\u{e777} ",
-- 		sql = "\u{e706} ",
-- 		yaml = "\u{f481} ",
-- 		toml = "\u{e615} ",
-- 		xml = "\u{f05c} ",
-- 		dockerfile = "\u{f308} ", -- nf-linux-docker
-- 		gitcommit = "\u{f418} ", -- nf-oct-git_commit
-- 		gitconfig = "\u{f1d3} ", -- nf-fa-git
-- 		vue = "\u{fd42} ", -- nf-md-vuejs
-- 		svelte = "\u{e697} ",
-- 		astro = "\u{e628} ",
-- 	}
--
-- 	if ft == "" then
-- 		return " \u{f15b} " -- nf-fa-file_o
-- 	end
--
-- 	return ((icons[ft] or " \u{f15b} ") .. ft)
-- end
--
-- -- File size with Nerd Font icon
-- local function file_size()
-- 	local size = vim.fn.getfsize(vim.fn.expand("%"))
-- 	if size < 0 then
-- 		return ""
-- 	end
-- 	local size_str
-- 	if size < 1024 then
-- 		size_str = size .. "B"
-- 	elseif size < 1024 * 1024 then
-- 		size_str = string.format("%.1fK", size / 1024)
-- 	else
-- 		size_str = string.format("%.1fM", size / 1024 / 1024)
-- 	end
-- 	return " \u{f016} " .. size_str .. " " -- nf-fa-file_o
-- end
--
-- -- Mode indicators with Nerd Font icons
-- local function mode_icon()
-- 	local mode = vim.fn.mode()
-- 	local modes = {
-- 		n = " \u{f121}  NORMAL",
-- 		i = " \u{f11c}  INSERT",
-- 		v = " \u{f0168} VISUAL",
-- 		V = " \u{f0168} V-LINE",
-- 		["\22"] = " \u{f0168} V-BLOCK",
-- 		c = " \u{f120} COMMAND",
-- 		s = " \u{f0c5} SELECT",
-- 		S = " \u{f0c5} S-LINE",
-- 		["\19"] = " \u{f0c5} S-BLOCK",
-- 		R = " \u{f044} REPLACE",
-- 		r = " \u{f044} REPLACE",
-- 		["!"] = " \u{f489} SHELL",
-- 		t = " \u{f120} TERMINAL",
-- 	}
-- 	return modes[mode] or (" \u{f059} " .. mode)
-- end
--
-- _G.mode_icon = mode_icon
-- _G.git_branch = git_branch
-- _G.file_type = file_type
-- _G.file_size = file_size
--
-- vim.cmd([[
--   highlight StatusLineBold gui=bold cterm=bold
-- ]])
--
-- -- Function to change statusline based on window focus
-- local function setup_dynamic_statusline()
-- 	vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
-- 		callback = function()
-- 			vim.opt_local.statusline = table.concat({
-- 				"  ",
-- 				"%#StatusLineBold#",
-- 				"%{v:lua.mode_icon()}",
-- 				"%#StatusLine#",
-- 				" \u{e0b1} %f %h%m%r", -- nf-pl-left_hard_divider
-- 				"%{v:lua.git_branch()}",
-- 				"\u{e0b1} ", -- nf-pl-left_hard_divider
-- 				"%{v:lua.file_type()}",
-- 				"\u{e0b1} ", -- nf-pl-left_hard_divider
-- 				"%{v:lua.file_size()}",
-- 				"%=", -- Right-align everything after this
-- 				" \u{f017} %l:%c  %P ", -- nf-fa-clock_o for line/col
-- 			})
-- 		end,
-- 	})
-- 	vim.api.nvim_set_hl(0, "StatusLineBold", { bold = true })
--
-- 	vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
-- 		callback = function()
-- 			vim.opt_local.statusline = "  %f %h%m%r \u{e0b1} %{v:lua.file_type()} %=  %l:%c   %P "
-- 		end,
-- 	})
-- end
--
-- setup_dynamic_statusline()

-- ============================================================================
-- KEYMAPS
-- ============================================================================
vim.g.mapleader = " " -- space for leader
vim.g.maplocalleader = " " -- space for localleader

-- better movement in wrapped text
vim.keymap.set("n", "j", function()
	return vim.v.count == 0 and "gj" or "j"
end, { expr = true, silent = true, desc = "Down (wrap-aware)" })
vim.keymap.set("n", "k", function()
	return vim.v.count == 0 and "gk" or "k"
end, { expr = true, silent = true, desc = "Up (wrap-aware)" })

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

vim.keymap.set("x", "<leader>p", '"_dP', { desc = "Paste without yanking" })
vim.keymap.set({ "n", "v" }, "<leader>x", '"_d', { desc = "Delete without yanking" })

vim.keymap.set("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bp", ":bprevious<CR>", { desc = "Previous buffer" })

vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

vim.keymap.set("n", "<C-S-Up>", ":resize +2<CR>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-S-Down>", ":resize -2<CR>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-S-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-S-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

vim.keymap.set("n", "<leader>pa", function() -- show file path
	local path = vim.fn.expand("%:p")
	vim.fn.setreg("+", path)
	print("file:", path)
end, { desc = "Copy full file path" })

vim.keymap.set("n", "<leader>td", function()
	vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Toggle diagnostics" })

-- ============================================================================
-- AUTOCMDS
-- ============================================================================

local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })

-- highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup,
	callback = function()
		vim.hl.on_yank()
	end,
})

-- return to last cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
	group = augroup,
	desc = "Restore last cursor position",
	callback = function()
		if vim.o.diff then -- except in diff mode
			return
		end

		local last_pos = vim.api.nvim_buf_get_mark(0, '"') -- {line, col}
		local last_line = vim.api.nvim_buf_line_count(0)

		local row = last_pos[1]
		if row < 1 or row > last_line then
			return
		end

		pcall(vim.api.nvim_win_set_cursor, 0, last_pos)
	end,
})

-- wrap, linebreak and spellcheck on markdown and text files
vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = { "markdown", "text", "gitcommit" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true
		vim.opt_local.spell = true
	end,
})

-- ============================================================================
-- PLUGINS (vim.pack)
-- ============================================================================

vim.pack.add({
	"https://www.github.com/lewis6991/gitsigns.nvim",
	"https://www.github.com/echasnovski/mini.nvim",
	"https://www.github.com/ibhagwan/fzf-lua",
	{
		src = "https://github.com/nvim-treesitter/nvim-treesitter",
		branch = "main",
		build = ":TSUpdate",
	},
	-- Language Server Protocols
	"https://www.github.com/neovim/nvim-lspconfig",
	"https://github.com/mason-org/mason.nvim",
	{
		src = "https://github.com/saghen/blink.cmp",
		version = vim.version.range("1.*"),
	},
	"https://github.com/L3MON4D3/LuaSnip",
	"https://github.com/stevearc/conform.nvim.git",
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/pmizio/typescript-tools.nvim",
	"https://github.com/neanias/everforest-nvim",
})

local function packadd(name)
	vim.cmd("packadd " .. name)
end

packadd("nvim-treesitter")
packadd("gitsigns.nvim")
packadd("mini.nvim")
packadd("fzf-lua")
-- packadd("nvim-tree.lua")
-- LSP
packadd("nvim-lspconfig")
packadd("mason.nvim")
-- packadd("efmls-configs-nvim")
packadd("blink.cmp")
packadd("LuaSnip")

-- ============================================================================
-- PLUGIN CONFIGS
-- ============================================================================

-- mason for installing stuff
require("mason").setup({})

-- treesitter for syntax parsing
local setup_treesitter = function()
	local treesitter = require("nvim-treesitter")
	treesitter.setup({})
	local ensure_installed = {
		"vim",
		"vimdoc",
		"rust",
		"go",
		"html",
		"css",
		"javascript",
		"json",
		"lua",
		"markdown",
		"typescript",
		"tsx",
		"jsx",
		"svelte",
		"bash",
	}

	local config = require("nvim-treesitter.config")

	local already_installed = config.get_installed()
	local parsers_to_install = {}

	for _, parser in ipairs(ensure_installed) do
		if not vim.tbl_contains(already_installed, parser) then
			table.insert(parsers_to_install, parser)
		end
	end

	if #parsers_to_install > 0 then
		treesitter.install(parsers_to_install)
	end

	local group = vim.api.nvim_create_augroup("TreeSitterConfig", { clear = true })
	vim.api.nvim_create_autocmd("FileType", {
		group = group,
		callback = function(args)
			if vim.list_contains(treesitter.get_installed(), vim.treesitter.language.get_lang(args.match)) then
				vim.treesitter.start(args.buf)
			end
		end,
	})
end

setup_treesitter()

-- Fuzzy finding with fzf-lua
require("fzf-lua").setup({
	keymap = {
		fzf = {
			["ctrl-y"] = "accept",
		},
	},
})

vim.keymap.set("n", "<leader>sf", function()
	require("fzf-lua").files()
end, { desc = "Search files" })
vim.keymap.set("n", "<leader>sg", function()
	require("fzf-lua").live_grep()
end, { desc = "Search via Live Grep" })
vim.keymap.set("n", "<leader><leader>", function()
	require("fzf-lua").buffers()
end, { desc = "Search Buffers" })
vim.keymap.set("n", "<leader>s.", function()
	require("fzf-lua").oldfiles()
end, { desc = "Search Recent Files" })
vim.keymap.set("n", "<leader>sh", function()
	require("fzf-lua").help_tags()
end, { desc = "Search Help Tags" })
vim.keymap.set("n", "<leader>sx", function()
	require("fzf-lua").diagnostics_document()
end, { desc = "Search Diagnostics Document" })
vim.keymap.set("n", "<leader>sX", function()
	require("fzf-lua").diagnostics_workspace()
end, { desc = "Search Diagnostics Workspace" })

-- git signs
require("gitsigns").setup({
	signs = {
		add = { text = "\u{2590}" }, -- ▏
		change = { text = "\u{2590}" }, -- ▐
		delete = { text = "\u{2590}" }, -- ◦
		topdelete = { text = "\u{25e6}" }, -- ◦
		changedelete = { text = "\u{25cf}" }, -- ●
		untracked = { text = "\u{25cb}" }, -- ○
	},
	signcolumn = true,
	current_line_blame = false,
})

vim.keymap.set("n", "]h", function()
	require("gitsigns").next_hunk()
end, { desc = "Next git hunk" })
vim.keymap.set("n", "[h", function()
	require("gitsigns").prev_hunk()
end, { desc = "Previous git hunk" })
vim.keymap.set("n", "<leader>hs", function()
	require("gitsigns").stage_hunk()
end, { desc = "Stage hunk" })
vim.keymap.set("n", "<leader>hr", function()
	require("gitsigns").reset_hunk()
end, { desc = "Reset hunk" })
vim.keymap.set("n", "<leader>hp", function()
	require("gitsigns").preview_hunk()
end, { desc = "Preview hunk" })
vim.keymap.set("n", "<leader>hb", function()
	require("gitsigns").blame_line({ full = true })
end, { desc = "Blame line" })
vim.keymap.set("n", "<leader>hB", function()
	require("gitsigns").toggle_current_line_blame()
end, { desc = "Toggle inline blame" })
vim.keymap.set("n", "<leader>hd", function()
	require("gitsigns").diffthis()
end, { desc = "Diff this" })

-- mini
require("mini.ai").setup({})
-- require("mini.comment").setup({})
require("mini.move").setup({
	mappings = {
		left = "<D-h>",
		right = "<D-l>",
		down = "<D-j>",
		up = "<D-k>",

		line_left = "<D-h>",
		line_right = "<D-l>",
		line_down = "<D-j>",
		line_up = "<D-k>",
	},
})
require("mini.surround").setup({
	n_lines = 100,
})
require("mini.cursorword").setup({})
require("mini.indentscope").setup({})
require("mini.pairs").setup({})
-- require("mini.trailspace").setup({})
require("mini.bufremove").setup({})
-- require("mini.notify").setup({})
-- require("mini.git").setup({})

-- required for statusline
require("mini.icons").setup({})
require("mini.diff").setup({})

local statusline = require("mini.statusline")
statusline.setup({})
statusline.section_location = function()
	return "%2l:%-2v"
end

-- ============================================================================
-- LSP, Linting, Formatting & Completion
-- ============================================================================

local diagnostic_signs = {
	Error = " ",
	Warn = " ",
	Hint = "",
	Info = "",
}

vim.diagnostic.config({
	virtual_text = { prefix = "●", spacing = 4 },
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = diagnostic_signs.Error,
			[vim.diagnostic.severity.WARN] = diagnostic_signs.Warn,
			[vim.diagnostic.severity.INFO] = diagnostic_signs.Info,
			[vim.diagnostic.severity.HINT] = diagnostic_signs.Hint,
		},
	},
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = {
		border = "rounded",
		source = "always",
		header = "",
		prefix = "",
		focusable = false,
		style = "minimal",
	},
})

do
	local orig = vim.lsp.util.open_floating_preview
	function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
		opts = opts or {}
		opts.border = opts.border or "rounded"
		return orig(contents, syntax, opts, ...)
	end
end

local function lsp_on_attach(ev)
	local client = vim.lsp.get_client_by_id(ev.data.client_id)
	if not client then
		return
	end

	local bufnr = ev.buf
	local opts = { noremap = true, silent = true, buffer = bufnr }

	vim.keymap.set("n", "gd", function()
		require("fzf-lua").lsp_definitions({ jump1 = true })
	end, opts)

	vim.keymap.set("n", "gr", function()
		require("fzf-lua").lsp_references({ jump1 = true, includeDelcaration = false })
	end, opts)

	vim.keymap.set("n", "<leader>gD", vim.lsp.buf.definition, opts)

	vim.keymap.set("n", "<leader>gS", function()
		vim.cmd("vsplit")
		vim.lsp.buf.definition()
	end, opts)

	vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
	vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

	vim.keymap.set("n", "<leader>D", function()
		vim.diagnostic.open_float({ scope = "line" })
	end, opts)
	vim.keymap.set("n", "<leader>d", function()
		vim.diagnostic.open_float({ scope = "cursor" })
	end, opts)
	vim.keymap.set("n", "<leader>nd", function()
		vim.diagnostic.jump({ count = 1 })
	end, opts)

	vim.keymap.set("n", "<leader>pd", function()
		vim.diagnostic.jump({ count = -1 })
	end, opts)

	vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

	vim.keymap.set("n", "<leader>fd", function()
		require("fzf-lua").lsp_definitions({ jump_to_single_result = true })
	end, opts)
	vim.keymap.set("n", "<leader>fr", function()
		require("fzf-lua").lsp_references()
	end, opts)
	vim.keymap.set("n", "<leader>ft", function()
		require("fzf-lua").lsp_typedefs()
	end, opts)
	vim.keymap.set("n", "<leader>fs", function()
		require("fzf-lua").lsp_document_symbols()
	end, opts)
	vim.keymap.set("n", "<leader>fw", function()
		require("fzf-lua").lsp_workspace_symbols()
	end, opts)
	vim.keymap.set("n", "<leader>fi", function()
		require("fzf-lua").lsp_implementations()
	end, opts)

	if client:supports_method("textDocument/codeAction", bufnr) then
		vim.keymap.set("n", "<leader>oi", function()
			vim.lsp.buf.code_action({
				context = { only = { "source.organizeImports" }, diagnostics = {} },
				apply = true,
				bufnr = bufnr,
			})
			vim.defer_fn(function()
				vim.lsp.buf.format({ bufnr = bufnr })
			end, 50)
		end, opts)
	end
end

vim.api.nvim_create_autocmd("LspAttach", { group = augroup, callback = lsp_on_attach })

vim.keymap.set("n", "<leader>q", function()
	vim.diagnostic.setloclist({ open = true })
end, { desc = "Open diagnostic list" })
vim.keymap.set("n", "<leader>dl", vim.diagnostic.open_float, { desc = "Show line diagnostics" })

require("blink.cmp").setup({
	keymap = {
		preset = "none",
		["<C-Space>"] = { "show", "hide" },
		["<C-y>"] = { "accept", "fallback" },
		["<C-n>"] = { "select_next", "fallback" },
		["<C-p>"] = { "select_prev", "fallback" },
		["<Tab>"] = { "snippet_forward", "fallback" },
		["<S-Tab>"] = { "snippet_backward", "fallback" },
	},
	appearance = { nerd_font_variant = "mono" },
	completion = { menu = { auto_show = true } },
	sources = { default = { "lsp", "path", "buffer", "snippets" } },
	snippets = {
		expand = function(snippet)
			require("luasnip").lsp_expand(snippet)
		end,
	},
	fuzzy = {
		implementation = "prefer_rust",
		prebuilt_binaries = { download = true },
	},
	signature = {
		enabled = true,
		window = { show_documentation = true },
	},
})

vim.lsp.config["*"] = {
	capabilities = require("blink.cmp").get_lsp_capabilities(),
}

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			diagnostics = { globals = { "vim" } },
			telemetry = { enable = false },
		},
	},
})

-- vim.lsp.config("pyright", {})
vim.lsp.config("bashls", {})
-- vim.lsp.config("ts_ls", {})
vim.lsp.config("gopls", {})
vim.lsp.config("copilot", {})
-- vim.lsp.config("clangd", {})

require("conform").setup({
	format_on_save = function(bufnr)
		local lsp_format_opt

		-- Disable formatting on save entirely for certain filetypes
		-- I disable for sql since there are many dialects and times where you
		-- just don't want it.
		local disable_format_on_save_filetypes = { sql = true }
		local dry_run = false
		if disable_format_on_save_filetypes[vim.bo[bufnr].filetype] then
			dry_run = true
		end

		local options = {
			timeout_ms = 500,
			lsp_format = lsp_format_opt,
			dry_run = dry_run,
		}

		return options
	end,
	formatters_by_ft = {
		lua = { "stylua" },
		-- Conform will run multiple formatters sequentially
		-- python = { "isort", "black" },
		-- You can customize some of the format options for the filetype (:help conform.format)
		rust = { "rustfmt", lsp_format = "fallback" },
		-- Conform will run the first available formatter
		javascript = { "oxfmt", "oxlint" },
		typescript = { "oxfmt", "oxlint" },
		javascriptreact = { "oxfmt", "oxlint" },
		typescriptreact = { "oxfmt", "oxlint" },
		css = { "oxfmt" },
		html = { "oxfmt" },
		json = { "oxfmt" },
		yaml = { "oxfmt" },
		markdown = { "oxfmt" },
		go = { "goimports", "gofmt" },
		sql = { "sql_formatter" },
	},
	formatters = {
		oxlint = {},
		oxfmt = {
			require_cwd = true,
		},
	},
	notify_on_error = false,
})

vim.keymap.set("n", "<leader>f", function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Show line diagnostics" })

vim.lsp.enable({
	"lua_ls",
	-- "pyright",
	"bashls",
	-- "ts_ls",
	"gopls",
	-- "clangd",
	-- "efm",
	"oxlint",
	"copilot",
})

-- to support copilot
vim.lsp.inline_completion.enable()
vim.keymap.set("i", "<C-CR>", function()
	if not vim.lsp.inline_completion.get() then
		return "<C-CR>"
	end
end, {
	expr = true,
	replace_keycodes = true,
	desc = "Get the current inline completion",
})

require("typescript-tools").setup({
	settings = {
		complete_function_calls = false,
		expose_as_code_action = {
			"fix_all",
			"add_missing_imports",
			"remove_unused",
			"remove_unused_imports",
			"organize_imports",
		},
	},
})

-- Theme setup
require("everforest").setup({
	background = "hard",
	float_style = "bright",
	ui_contrast = "high",
	colours_override = function(palette)
		palette.bg0 = palette.bg_dim
	end,
	on_highlights = function(hl, palette)
		hl.ComplHint = { fg = palette.grey2, nocombine = true } -- lighter
	end,
})
vim.cmd("colorscheme everforest")
