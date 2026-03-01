-- ============================================================================
-- Oil (file explorer)
-- ============================================================================

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
		["<Esc>"] = { "actions.close", mode = "n" },
		["<C-v>"] = { "actions.select", opts = { vertical = true } },
		["<Cs-u>"] = { "actions.preview_scroll_up" },
		["<Cs-D>"] = { "actions.preview_scroll_down" },
	},
})
vim.keymap.set("n", "-", "<cmd>Oil --float<CR>")
