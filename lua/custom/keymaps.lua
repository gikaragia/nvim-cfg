-- [[ Basic Keymaps ]]
--
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

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

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

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
