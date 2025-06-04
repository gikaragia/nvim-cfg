return {
  'navarasu/onedark.nvim',
  priority = 1000,
  config = function()
    require('onedark').setup {
      style = 'darker',
      code_style = {
        comments = 'none',
      },
    }

    require('onedark').load()
  end,
}
