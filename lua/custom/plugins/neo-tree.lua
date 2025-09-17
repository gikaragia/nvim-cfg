-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim
return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  lazy = false,
  keys = {
    { '<leader><Tab>', ':Neotree toggle filesystem left<CR>', desc = 'NeoTree reveal', silent = true },
    { '<leader><S-Tab>', ':Neotree show reveal_force_cwd<CR>', desc = 'NeoTree cwd reveal', silent = true },
    { '<leader><leader>', ':Neotree toggle buffers float<CR>', desc = 'Toggle buffers', silent = true },
    { '<leader>gt', ':Neotree toggle git_status float<CR>', desc = 'Toggle buffers', silent = true },
  },
  config = function()
    -- Search by grep under directory
    local function search_by_grep()
      local manager = require 'neo-tree.sources.manager'
      local state = manager.get_state 'filesystem'
      local node = state.tree:get_node()
      local path = node:get_id()
      require('telescope.builtin').live_grep { search_dirs = { path } }
    end

    vim.keymap.set('n', '<leader>sG', search_by_grep, { desc = '[S]earch by [G]rep under directory' })

    vim.keymap.set('n', '<M-Up>', ':resize +5<CR>', { noremap = true, silent = true })
    vim.keymap.set('n', '<M-Down>', ':resize -5<CR>', { noremap = true, silent = true })
    vim.keymap.set('n', '<M-Right>', ':vertical resize +5<CR>', { noremap = true, silent = true })
    vim.keymap.set('n', '<M-Left>', ':vertical resize -5<CR>', { noremap = true, silent = true })

    require('neo-tree').setup {
      filesystem = {
        follow_current_file = {
          enabled = true,
        },
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_by_name = {
            '.DS_Store',
            '.git',
          },
        },
      },
    }
  end,
}
