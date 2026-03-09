vim.pack.add({
	"https://github.com/folke/ts-comments.nvim",
})

require("utils").packadd("ts-comments.nvim")

require("ts-comments").setup({})
