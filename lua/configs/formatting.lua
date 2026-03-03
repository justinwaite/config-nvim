-- ============================================================================
-- FORMATTING
-- Using conform to format on save.
-- ============================================================================
vim.pack.add({
	"https://github.com/stevearc/conform.nvim.git",
})

local oxfmt_config_cache = {}

-- oxfmt formatting is handled by the lsp, which is faster than integrating with
-- conform, since conform has to pay startup time every time it runs.
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
	log_level = vim.log.levels.DEBUG,
	format_on_save = function(bufnr)
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
			-- lsp_format = "fallback" allows conform to use oxfmt via the lsp
			lsp_format = "fallback",
			dry_run = dry_run,
		}

		return options
	end,
	formatters_by_ft = {
		lua = { "stylua" },
		rust = { "rustfmt" },
		javascript = { "prettierd", "prettier", stop_after_first = true },
		typescript = { "prettierd", "prettier", stop_after_first = true },
		javascriptreact = { "prettierd", "prettier", stop_after_first = true },
		typescriptreact = { "prettierd", "prettier", stop_after_first = true },
		css = { "prettierd", "prettier", stop_after_first = true },
		html = { "prettierd", "prettier", stop_after_first = true },
		json = { "prettierd", "prettier", stop_after_first = true },
		yaml = { "prettierd", "prettier", stop_after_first = true },
		markdown = { "prettierd", "prettier", stop_after_first = true },
		go = { "goimports", "gofmt" },
		sql = { "sql_formatter" },
	},
	formatters = {
		prettierd = {
			condition = function(_, ctx)
				return not has_oxfmt_config(ctx)
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

-- I like to have a keybinding to format on demand as well
vim.keymap.set("n", "<leader>f", function()
	-- lsp_format = "fallback" allows conform to use oxfmt via the lsp
	require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format the buffer" })
