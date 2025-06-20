-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Organize Go imports automatically
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*.go',
  callback = function()
    local client = vim.lsp.get_clients({ buf = vim.api.nvim_win_get_buf(0) })[1]
    local encoding = client.offset_encoding or 'utf-16'
    local params = vim.lsp.util.make_range_params(0, encoding)

    params.context = { only = { 'source.organizeImports' } }
    -- buf_request_sync defaults to a 1000ms timeout. Depending on your
    -- machine and codebase, you may want longer. Add an additional
    -- argument after params if you find that you have to write the file
    -- twice for changes to be saved.
    -- E.g., vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
    local result = vim.lsp.buf_request_sync(0, 'textDocument/codeAction', params)
    for cid, res in pairs(result or {}) do
      for _, r in pairs(res.result or {}) do
        if r.edit then
          local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or 'utf-16'
          vim.lsp.util.apply_workspace_edit(r.edit, enc)
        end
      end
    end
  end,
})

-- Enable auto save in rust
local autosave_timer = vim.uv.new_timer()
local autosave = vim.api.nvim_create_augroup('autosave', {})
vim.api.nvim_create_autocmd({ 'InsertLeave', 'TextChanged' }, {
  pattern = '*.rs',
  group = autosave,
  callback = function()
    if autosave_timer == nil then
      return
    end

    local timeout = function()
      vim.schedule(function()
        vim.cmd 'silent w'
      end)
      autosave_timer.stop(autosave_timer)
    end

    if autosave_timer.is_active(autosave_timer) then
      autosave_timer.again(autosave_timer)
    else
      autosave_timer.start(autosave_timer, 1000, 1000, timeout)
    end
  end,
})
