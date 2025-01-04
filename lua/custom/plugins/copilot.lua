return {
  {
    'github/copilot.vim',
  },
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    dependencies = {
      { 'github/copilot.vim' }, -- or zbirenbaum/copilot.lua
      { 'nvim-lua/plenary.nvim', branch = 'master' }, -- for curl, log and async functions
    },
    -- build = 'make tiktoken', -- Only on MacOS or Linux
    opts = {
      -- See Configuration section for options
      mappings = {
        accept_diff = {
          normal = 'ga',
        },
        show_diff = {
          normal = 'gd',
        },
      },
      debug = true,
    },
    keys = {
      {
        '<leader>gp',
        function()
          local actions = require 'CopilotChat.actions'
          require('CopilotChat.integrations.telescope').pick(actions.prompt_actions())
        end,
        desc = '[P]romt Actions',
        mode = { 'n', 'v' },
      },
      {
        '<leader>gc',
        function()
          require('CopilotChat').open()
        end,
        desc = '[C]hat',
        mode = { 'n', 'v' },
      },
      {
        '<leader>gq',
        function()
          local input = vim.fn.input 'Quick Chat: '
          if input ~= '' then
            require('CopilotChat').ask(input, { selection = require('CopilotChat.select').buffer })
          end
        end,
        desc = '[Q]uick Chat',
        mode = { 'n', 'v' },
      },
    },
    -- See Commands section for default commands if you want to lazy load on them
  },
}
