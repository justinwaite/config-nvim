-- ============================================================================
-- FORMATTING
-- Using conform to format on save.
-- ============================================================================
vim.pack.add({
	"https://github.com/stevearc/conform.nvim.git",
})

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
	-- disabled this so that i can use oxlint to run on save without it erroring
	-- out if i have syntax errors. to view errors, run :ConformInfo
	notify_on_error = false,
})

vim.keymap.set("n", "<leader>f", function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format the buffer" })
