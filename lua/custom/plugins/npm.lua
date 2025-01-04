return {
  -- Autocomplete for npm package versions in package.json
  {
    'David-Kunz/cmp-npm',
    dependencies = { 'nvim-lua/plenary.nvim' },
    ft = 'json',
    config = function()
      require('cmp-npm').setup {
        only_latest_version = true,
      }
    end,
  },
}
