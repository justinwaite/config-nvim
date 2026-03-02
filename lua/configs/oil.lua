-- ============================================================================
-- Oil (file explorer)
-- ============================================================================
vim.pack.add({
	"https://github.com/stevearc/oil.nvim.git",
})

require("oil").setup({
	watch_for_changes = true,
	view_options = {
		show_hidden = true,
		is_always_hidden = function(name)
			local hidden_files = { ".DS_Store", "thumbs.db", ".git", ".idea" }
			if vim.tbl_contains(hidden_files, name) then
				return true
			end

			return false
		end,
	},
	keymaps = {
		["<C-v>"] = { "actions.select", opts = { vertical = true } },
		["q"] = { "actions.close", mode = "n", opts = { vertical = true } },
		["<Cs-u>"] = { "actions.preview_scroll_up" },
		["<Cs-D>"] = { "actions.preview_scroll_down" },
	},
})
vim.keymap.set("n", "-", "<cmd>Oil --float<CR>")
