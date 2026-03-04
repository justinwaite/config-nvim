-- ============================================================================
-- AUTOCOMPLETE
-- We use blink.cmp for automplete.
-- https://github.com/saghen/blink.cmp
-- ============================================================================

vim.pack.add({
	{
		src = "https://github.com/saghen/blink.cmp",
		version = vim.version.range("1.*"),
	},
})

require("utils").packadd("blink.cmp")

require("blink.cmp").setup({
	keymap = {
		preset = "none",
		["<C-Space>"] = { "show", "hide" },
		["<C-y>"] = { "accept", "fallback" },
		["<C-n>"] = { "select_next", "fallback" },
		["<C-p>"] = { "select_prev", "fallback" },
		["<Tab>"] = { "snippet_forward", "fallback" },
		["<S-Tab>"] = { "snippet_backward", "fallback" },
	},
	appearance = { nerd_font_variant = "mono" },
	completion = {
		menu = {
			auto_show = true,
			draw = {
				columns = {
					{
						"label",
						"label_description",
						gap = 1,
					},
					{ "kind_icon", "kind" },
				},
			},
		},
		documentation = {
			auto_show = true,
			auto_show_delay_ms = 500,
		},
	},
	sources = {
		default = { "lsp", "path", "buffer", "snippets" },
		per_filetype = {
			sql = { "dadbod", "buffer" },
		},
		-- add vim-dadbod-completion to your completion providers
		providers = {
			dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
			lsp = {
				transform_items = function(_, items)
					for _, item in ipairs(items) do
						if item.client_name == "typescript-tools" then
							local source = vim.tbl_get(item, "data", "entryNames", 1, "source")
							if source then
								item.labelDetails = item.labelDetails or {}
								item.labelDetails.description = source
							end
						end

						local desc = vim.tbl_get(item, "labelDetails", "description")
						if not desc then
							item.score_offset = (item.score_offset or 0) + 4
						elseif desc:match("^[%.~]") then
							item.score_offset = (item.score_offset or 0) + 2
						end
					end

					return items
				end,
			},
		},
	},
	snippets = {
		expand = function(snippet)
			require("luasnip").lsp_expand(snippet)
		end,
	},
	fuzzy = {
		implementation = "prefer_rust",
		prebuilt_binaries = { download = true },
	},
	signature = {
		enabled = true,
		window = { show_documentation = true },
	},
})

vim.lsp.config["*"] = {
	capabilities = require("blink.cmp").get_lsp_capabilities(),
}
