-- ============================================================================
-- GITHUB COPILOT
-- Configure Github Copilot language server for neovim.
-- neovim now supports the new textDocument/inlineCompletion method, which
-- means we only need to setup the copilot language server.
-- https://github.com/neovim/neovim/pull/33972
-- https://github.com/neovim/nvim-lspconfig/pull/4029
-- https://github.com/neovim/neovim/issues/32421#issuecomment-3218602052
-- ============================================================================

-- Since we're using nvim-lspconfig, some defaults are configured for us.
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#copilot
vim.lsp.config("copilot", {})

vim.lsp.enable({
	"copilot",
})

-- setting up inline completion for copilot
vim.lsp.inline_completion.enable()
vim.keymap.set("i", "<Tab>", function()
	if not vim.lsp.inline_completion.get() then
		return "<Tab>"
	end
end, {
	expr = true,
	replace_keycodes = true,
	desc = "Accept the current inline completion",
})

vim.keymap.set("n", "<leader>ai", "<cmd>LspCopilotSignIn<cr>", {
	desc = "Sign in to GitHub Copilot",
})

vim.keymap.set("n", "<leader>ao", "<cmd>LspCopilotSignOut<cr>", {
	desc = "Sign out of GitHub Copilot",
})
