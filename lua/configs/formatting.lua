-- ============================================================================
-- FORMATTING
-- Using conform to format on save.
-- ============================================================================
vim.pack.add({
	"https://github.com/stevearc/conform.nvim.git",
})

local oxfmt_config_cache = {}

local function has_oxfmt_config(ctx)
	local dir = ctx.dirname
	if oxfmt_config_cache[dir] == nil then
		oxfmt_config_cache[dir] = vim.fs.find({ ".oxfmtrc.json", ".oxfmtrc.jsonc" }, {
			upward = true,
			path = dir,
		})[1] ~= nil
	end
	return oxfmt_config_cache[dir]
end

vim.api.nvim_create_user_command("ConformClearCache", function()
	oxfmt_config_cache = {}
	vim.notify("Cleared oxfmt config cache", vim.log.levels.INFO)
end, { desc = "Clear cached oxfmt config lookups" })

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
		rust = { "rustfmt", lsp_format = "fallback" },
		javascript = { "oxfmt", "prettierd", "oxlint" },
		typescript = { "oxfmt", "prettierd", "oxlint" },
		javascriptreact = { "oxfmt", "prettierd", "oxlint" },
		typescriptreact = { "oxfmt", "prettierd", "oxlint" },
		css = { "oxfmt", "prettierd" },
		html = { "oxfmt", "prettierd" },
		json = { "oxfmt", "prettierd" },
		yaml = { "oxfmt", "prettierd" },
		markdown = { "oxfmt", "prettierd" },
		go = { "goimports", "gofmt" },
		sql = { "sql_formatter" },
	},
	formatters = {
		oxlint = {},
		oxfmt = {
			condition = function(_, ctx)
				return has_oxfmt_config(ctx)
			end,
		},
		prettier = {
			condition = function(_, ctx)
				return not has_oxfmt_config(ctx)
			end,
		},
	},
	-- disabled this so that i can use oxlint to run on save without it erroring
	-- out if i have syntax errors. to view errors, run :ConformInfo
	notify_on_error = false,
})

vim.keymap.set("n", "<leader>f", function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format the buffer" })
