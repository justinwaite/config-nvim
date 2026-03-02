-- ============================================================================
-- FUZZY FINDING
-- uses fzf-lua for fuzzy finding, which is a Lua adapter for the fzf
-- command-line fuzzy finder. fzf must be installed and in the path.
-- ============================================================================

vim.pack.add({
	"https://www.github.com/ibhagwan/fzf-lua",
})

require("utils").packadd("fzf-lua")

require("fzf-lua").setup({
	keymap = {
		fzf = {
			["ctrl-y"] = "accept",
		},
	},
})

require("fzf-lua").register_ui_select()

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
	require("fzf-lua").oldfiles({ file_ignore_patterns = { "node_modules" } })
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
vim.keymap.set("n", "<leader>sn", function()
	require("fzf-lua").files({ cwd = vim.fn.stdpath("config") })
end, { desc = "Search Neovim Config Files" })

-- LSP keybindings with fzf-lua as the finder
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

	vim.keymap.set("n", "gs", function()
		vim.cmd("vsplit")
		vim.lsp.buf.definition()
	end, opts)

	vim.keymap.set("n", "<leader>ca", function()
		require("fzf-lua").lsp_code_actions({
			previewer = false,
		})
	end, opts)

	vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

	vim.keymap.set("n", "<leader>E", function()
		vim.diagnostic.open_float({ scope = "line" })
	end, opts)

	vim.keymap.set("n", "<leader>e", function()
		vim.diagnostic.open_float({ scope = "cursor" })
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
end

vim.api.nvim_create_autocmd("LspAttach", { group = require("utils").augroup, callback = lsp_on_attach })
