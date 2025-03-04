return {
  {
    'vuki656/package-info.nvim',
    ft = 'json',
    dependencies = { 'MunifTanjim/nui.nvim' },
    opts = {
      autostart = false,
      package_manager = 'pnpm',
      colors = {
        up_to_date = '#3C4048', -- Text color for up to date dependency virtual text
        outdated = '#d19a66', -- Text color for outdated dependency virtual text
        invalid = '#ee4b2b', -- Text color for invalid dependency virtual text
      },
      hide_up_to_date = true,
    },
    config = function(_, opts)
      require('package-info').setup(opts)

      -- Hack to set the colors since the plugin didn't account for lazy loading
      vim.cmd([[highlight PackageInfoUpToDateVersion guifg=]] .. opts.colors.up_to_date)
      vim.cmd([[highlight PackageInfoOutdatedVersion guifg=]] .. opts.colors.outdated)
      vim.cmd([[highlight PackageInfoInvalidVersion guifg=]] .. opts.colors.invalid)

      -- Show dependency versions
      vim.keymap.set({ 'n' }, '<LEADER>ns', require('package-info').show, { silent = true, noremap = true, desc = '[S]how latest dependency verisons' })

      -- Hide dependency versions
      vim.keymap.set({ 'n' }, '<LEADER>nc', require('package-info').hide, { silent = true, noremap = true, desc = '[C]lose (hide) dependency versions' })

      -- Toggle dependency versions
      vim.keymap.set({ 'n' }, '<LEADER>nt', require('package-info').toggle, { silent = true, noremap = true, desc = '[T]oggle dependency versions' })

      -- Update dependency on the line
      vim.keymap.set({ 'n' }, '<LEADER>nu', require('package-info').update, { silent = true, noremap = true, desc = '[U]pdate dependency on the line' })

      -- Delete dependency on the line
      vim.keymap.set(
        { 'n' },
        '<LEADER>nd',
        require('package-info').delete,
        { silent = true, noremap = true, desc = '[D]elete (uninstall) the dependency on the line' }
      )

      -- Install a new dependency
      vim.keymap.set({ 'n' }, '<LEADER>ni', require('package-info').install, { silent = true, noremap = true, desc = '[I]nstall a new dependency' })

      -- Install a different dependency version
      vim.keymap.set(
        { 'n' },
        '<LEADER>np',
        require('package-info').change_version,
        { silent = true, noremap = true, desc = '[P]ick a different version of the dependency' }
      )
    end,
  },
}
