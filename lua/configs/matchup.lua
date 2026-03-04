-- prevent loading matchit since we use matchup
vim.loaded_matchit = 1

vim.pack.add({
	"https://github.com/andymass/vim-matchup",
})

require("utils").packadd("vim-matchup")

require("match-up").setup({
	matchup_matchparen_offscreen = {
		method = "popup",
	},
})
