-- ============================================================================
-- AUTO TAGS
-- Enable auto closing of tags, with language aware support
-- ============================================================================
vim.pack.add({
	"https://github.com/windwp/nvim-ts-autotag",
})

require("utils").packadd("nvim-ts-autotag")

require("nvim-ts-autotag").setup({
	opts = {
		enable_close = true, -- Auto close tags
		enable_rename = true, -- Auto rename pairs of tags
		enable_close_on_slash = true, -- Auto close on trailing </
	},
})
