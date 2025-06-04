return {
  'akinsho/toggleterm.nvim',
  version = '4.*',
  config = function()
    vim.keymap.set('n', '<leader>tT', '<cmd>TermNew<CR>', { desc = 'Create Terminal' })
    require('toggleterm').setup {
      open_mapping = '<leader>tt',
    }
  end,
}
