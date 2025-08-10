-- [[ Basic Keymaps ]]
--
--  See `:help vim.keymap.set()`

local function jump_to_diagnostic(diagnostic)
  if diagnostic == nil then
    return
  end

  local jump_opts = {
    diagnostic = diagnostic,
  }

  vim.diagnostic.jump(jump_opts)
end

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>qo', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

vim.keymap.set('n', '<leader>qn', function()
  jump_to_diagnostic(vim.diagnostic.get_next {})
end, { desc = 'Jump to [N]ext diagnostic' })

vim.keymap.set('n', '<leader>qp', function()
  jump_to_diagnostic(vim.diagnostic.get_prev {})
end, { desc = 'Jump to [P]revious diagnostic' })

vim.keymap.set('n', '<leader>qf', function()
  vim.diagnostic.open_float()
  vim.diagnostic.open_float()
end, { desc = 'Open diagnostic [F]loat window' })

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

local function close_buffer()
  local current_buffer = vim.api.nvim_get_current_buf()
  vim.cmd 'bnext'
  vim.api.nvim_buf_delete(current_buffer, {})
end

-- Cycle through buffers
vim.keymap.set('n', '<leader>bn', '<cmd>:bnext<CR>', { desc = '[N]ext' })
vim.keymap.set('n', '<leader>bp', '<cmd>:bprevious<CR>', { desc = '[P]revious' })
vim.keymap.set('n', '<leader>bd', close_buffer, { desc = '[D]elete' })

-- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
-- vim.keymap.set("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
-- vim.keymap.set("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
-- vim.keymap.set("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
-- vim.keymap.set("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })

vim.keymap.set('n', '<CR>', 'o<Esc>', { desc = 'New line on Return' })
vim.keymap.set('n', '<S-CR>', 'O<Esc>', { desc = 'New line up on Shift Return' })

-- Close every floating window
local function close_floating_windows()
  for _, win in pairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative == 'win' then
      vim.api.nvim_win_close(win, false)
    end
  end
end

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

vim.keymap.set('n', '<Esc>', function()
  vim.cmd 'nohlsearch'
  close_floating_windows()
end, { desc = 'Close floating window, clear search highlights' })

-- Focus the hover window on K
vim.keymap.set('n', 'K', function()
  vim.lsp.buf.hover()
  vim.lsp.buf.hover()
end, { desc = 'Hover documentation' })

-- Rust open documentation in browser
local function rust_open_docs()
  vim.lsp.buf_request(vim.api.nvim_get_current_buf(), 'experimental/externalDocs', vim.lsp.util.make_position_params(), function(err, url)
    if err then
      error(tostring(err))
    else
      vim.fn['netrw#BrowseX'](url, 0)
    end
  end)
end

vim.keymap.set('n', 'grx', rust_open_docs, { desc = 'Open documentation for the symbol under the cursor' })
