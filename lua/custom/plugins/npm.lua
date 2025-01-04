return {
  {
    'sajjathossain/nvim-npm',
    config = true,
    dependencies = {
      'nvim-telescope/telescope.nvim',
      'akinsho/toggleterm.nvim',
      'rcarriga/nvim-notify',
    },
    -- mappings = {
    --   '<leader>np',
    --   '<cmd>lua require("nvim-npm").install()<CR>',
    -- }
    --
    keys = {
      {
        '<leader>ns',
        function()
          require('nvim-npm').showScripts()
        end,
        mode = 'n',
        desc = '[S]how npm scripts',
      },
    },
  },
}
