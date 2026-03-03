-- ============================================================================
-- LSP
-- ============================================================================
vim.pack.add({
	"https://www.github.com/neovim/nvim-lspconfig",
})

require("utils").packadd("nvim-lspconfig")

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

vim.keymap.set("n", "<leader>q", function()
	vim.diagnostic.setloclist({ open = true })
end, { desc = "Open diagnostic list" })

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			diagnostics = { globals = { "vim" } },
			telemetry = { enable = false },
		},
	},
})

vim.lsp.config("bashls", {})
vim.lsp.config("gopls", {})
vim.lsp.config("oxfmt", {})
vim.lsp.config("vtsls", {
	on_attach = function(client)
		-- disable tsserver's formatting capabilities since we use oxfmt and prettier for that
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
	end,
})
vim.lsp.config("jsonls", {
	init_options = {
		-- disable in favor of oxfmt and prettier
		provideFormatter = false,
	},
})
vim.lsp.config("tailwindcss", {})
-- oxlint fix on save
local oxlint_on_attach = vim.lsp.config.oxlint.on_attach
vim.lsp.config("oxlint", {
	on_attach = function(client, bufnr)
		if oxlint_on_attach then
			oxlint_on_attach(client, bufnr)
		end

		vim.api.nvim_create_autocmd("BufWritePre", {
			buffer = bufnr,
			command = "LspOxlintFixAll",
		})
	end,
})

vim.lsp.enable({
	"lua_ls",
	"bashls",
	"gopls",
	"oxlint",
	"oxfmt",
	"eslint",
	"jsonls",
	"tailwindcss",
	"vtsls",
})
