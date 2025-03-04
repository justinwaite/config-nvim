return {
  {
    'pmizio/typescript-tools.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
    -- opts = {
    --   settings = {
    --     complete_function_calls = false,
    --   },
    -- },
    config = function()
      require('typescript-tools').setup {
        settings = {
          complete_function_calls = false,
          expose_as_code_action = {
            'fix_all',
            'add_missing_imports',
            'remove_unused',
            'remove_unused_imports',
            'organize_imports',
          },
        },
      }

      -- create keymap for TSToolsAddMissingImports
      vim.keymap.set('n', '<leader>ia', '<cmd>TSToolsAddMissingImports<CR>', { desc = 'Add [I]mports [A]utomatically' })
    end,
  },
}
