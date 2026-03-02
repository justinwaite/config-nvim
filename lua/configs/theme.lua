-- ============================================================================
-- THEME
-- ============================================================================
vim.pack.add({
	"https://github.com/neanias/everforest-nvim",
})

require("everforest").setup({
	background = "hard",
	float_style = "bright",
	ui_contrast = "high",
	colours_override = function(palette)
		palette.bg0 = palette.bg_dim
	end,
	on_highlights = function(hl, palette)
		hl.ComplHint = { fg = palette.grey2, nocombine = true } -- lighter
	end,
})
vim.cmd("colorscheme everforest")
