return {
  { -- You can easily change to a different colorscheme.
    -- Change the name of the colorscheme plugin below, and then
    -- change the command in the config to whatever the name of that colorscheme is.
    --
    -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
    'neanias/everforest-nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    version = false,
    lazy = false,
    config = function()
      -- Load the colorscheme here.
      -- Like many other themes, this one has different styles, and you could load
      -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
      -- vim.cmd.colorscheme 'rose-pine'
      require('everforest').setup {
        background = 'hard',
        float_style = 'bright',
        ui_contrast = 'high',
        colours_override = function(palette)
          if vim.g.everforestBackground == 'dim' then
            palette.bg0 = palette.bg_dim
          end
        end,
      }

      -- You can configure highlights by doing something like:
      -- vim.cmd.hi 'Comment gui=none'
    end,
  },
  {
    'kepano/flexoki-neovim',
    name = 'flexoki',
  },
  {
    'f-person/auto-dark-mode.nvim',
    opts = {
      update_interval = 1000,
      set_dark_mode = function()
        vim.g.everforestBackground = 'dim'
        vim.api.nvim_set_option_value('background', 'dark', {})
        vim.cmd 'colorscheme everforest'
      end,
      set_light_mode = function()
        vim.g.everforestBackground = 'normal'
        vim.api.nvim_set_option_value('background', 'dark', {})
        vim.cmd 'colorscheme everforest'
      end,
      fallback = 'everforest',
    },
  },
}
