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
        group_empty_dirs = true,
        follow_current_file = {
          enabled = true,
        },
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = true,
          hide_by_name = {
            '.DS_Store',
            '.git',
          },
        },
      },
      window = {
        mappings = {
          ['Y'] = function(state)
            -- NeoTree is based on [NuiTree](https://github.com/MunifTanjim/nui.nvim/tree/main/lua/nui/tree)
            -- The node is based on [NuiNode](https://github.com/MunifTanjim/nui.nvim/tree/main/lua/nui/tree#nuitreenode)
            local node = state.tree:get_node()
            local filepath = node:get_id()
            local filename = node.name
            local modify = vim.fn.fnamemodify

            local results = {
              modify(filepath, ':.'),
              filepath,
              modify(filepath, ':~'),
              filename,
              modify(filename, ':r'),
              modify(filename, ':e'),
            }

            vim.ui.select({
              '1. Path relative to CWD: ' .. results[1],
              '2. Absolute path: ' .. results[2],
              '3. Path relative to HOME: ' .. results[3],
              '4. Filename: ' .. results[4],
              '5. Filename without extension: ' .. results[5],
              '6. Extension of the filename: ' .. results[6],
            }, { prompt = 'Choose to copy to clipboard:' }, function(choice)
              if choice then
                local i = tonumber(choice:sub(1, 1))
                if i then
                  local result = results[i]
                  vim.fn.setreg('+', result, 'v')
                  vim.notify('Copied: ' .. result)
                else
                  vim.notify 'Invalid selection'
                end
              else
                vim.notify 'Selection cancelled'
              end
            end)
          end,
        },
      },
    }
  end,
}
