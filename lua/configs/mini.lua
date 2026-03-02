-- ============================================================================
-- MINI
-- mini is a collection of Lua modules that provide various functionalities for
-- Neovim. It includes features like extending a and i text objects, commenting,
-- moving lines, surrounding text, highlighting the current word, indent scope
-- visualization, automatic pairing of brackets and quotes, buffer management,
-- notifications, Git integration, icons, diffing, and a customizable
-- statusline.
-- ============================================================================
vim.pack.add({
	"https://www.github.com/echasnovski/mini.nvim",
})

require("utils").packadd("mini.nvim")

local spec_treesitter = require("mini.ai").gen_spec.treesitter

-- This lets us use the treesitter syntax tree to define custom text objects
-- so we can do stuff like "vaF" to select the outer part of a function, or
-- "dio" to delete the inner part of a conditional or loop.
require("mini.ai").setup({
	custom_textobjects = {
		F = spec_treesitter({ a = "@function.outer", i = "@function.inner" }),
		o = spec_treesitter({
			a = { "@conditional.outer", "@loop.outer" },
			i = { "@conditional.inner", "@loop.inner" },
		}),
	},
})

-- require("mini.comment").setup({})
require("mini.move").setup({
	mappings = {
		left = "<D-h>",
		right = "<D-l>",
		down = "<D-j>",
		up = "<D-k>",

		line_left = "<D-h>",
		line_right = "<D-l>",
		line_down = "<D-j>",
		line_up = "<D-k>",
	},
})
require("mini.surround").setup({
	n_lines = 100,
})
require("mini.cursorword").setup({})
require("mini.indentscope").setup({})
require("mini.bufremove").setup({})

-- required for statusline
require("mini.icons").setup({})
require("mini.diff").setup({})

local statusline = require("mini.statusline")
statusline.setup({})
statusline.section_location = function()
	return "%2l:%-2v"
end
