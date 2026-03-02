-- ============================================================================
-- DATABASE
-- using dad-bod
-- ============================================================================

vim.pack.add({
	"https://github.com/tpope/vim-dadbod",
	"https://github.com/kristijanhusak/vim-dadbod-ui",
	"https://github.com/kristijanhusak/vim-dadbod-completion",
})

require("utils").packadd("vim-dadbod")
require("utils").packadd("vim-dadbod-ui")
require("utils").packadd("vim-dadbod-completion")

vim.g.db_ui_use_nerd_fonts = 1
