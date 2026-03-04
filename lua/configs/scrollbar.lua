vim.pack.add({
	"https://github.com/dstein64/nvim-scrollview",
})

require("utils").packadd("nvim-scrollview")

require("scrollview").setup({
	excluded_filetypes = {},
})
