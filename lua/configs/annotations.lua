vim.pack.add({
	"https://github.com/danymat/neogen",
})

require("utils").packadd("neogen")

require("neogen").setup({
	enabled = true,
	snippet_engine = "luasnip",
	insert_after_comment = true,
	languages = {
		typescripts = {
			template = {
				annotation_convention = "jsdoc",
			},
		},
	},
})

local opts = { noremap = true, silent = true }
vim.api.nvim_set_keymap("n", "<Leader>jd", ":lua require('neogen').generate({ type = 'func' })<CR>", opts)
