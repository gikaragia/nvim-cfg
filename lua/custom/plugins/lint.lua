local severities = {
  note = vim.diagnostic.severity.INFO,
  warning = vim.diagnostic.severity.WARN,
  help = vim.diagnostic.severity.HINT,
}

local function parse(diagnostics, file_name, item)
  local project_root

  for _, span in ipairs(item.message.spans) do
    if file_name:sub(-#span.file_name) == span.file_name then
      local message = item.message.message
      if span.suggested_replacement ~= vim.NIL then
        message = message .. '\nSuggested replacement:\n\n' .. tostring(span.suggested_replacement)
      end

      local rendered = item.message.message
      if item.message.rendered ~= vim.NIL then
        rendered = item.message.rendered
      end

      table.insert(diagnostics, {
        lnum = span.line_start - 1,
        end_lnum = span.line_end - 1,
        col = span.column_start - 1,
        end_col = span.column_end - 1,
        severity = severities[item.message.level],
        source = 'clippy',
        message = message,
        user_data = {
          rendered = rendered,
        },
      })
    end
  end
end

return {

  { -- Linting
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lint = require 'lint'
      lint.linters_by_ft = {
        markdown = { 'markdownlint' },
        go = { 'golangcilint' },
        lua = { 'luac' },
        rust = { 'clippy' },
      }

      -- To allow other plugins to add linters to require('lint').linters_by_ft,
      -- instead set linters_by_ft like this:
      -- lint.linters_by_ft = lint.linters_by_ft or {}
      -- lint.linters_by_ft['markdown'] = { 'markdownlint' }
      --
      -- However, note that this will enable a set of default linters,
      -- which will cause errors unless these tools are available:
      -- {
      --   clojure = { "clj-kondo" },
      --   dockerfile = { "hadolint" },
      --   inko = { "inko" },
      --   janet = { "janet" },
      --   json = { "jsonlint" },
      --   markdown = { "vale" },
      --   rst = { "vale" },
      --   ruby = { "ruby" },
      --   terraform = { "tflint" },
      --   text = { "vale" }
      -- }
      --
      -- You can disable the default linters by setting their filetypes to nil:
      -- lint.linters_by_ft['clojure'] = nil
      -- lint.linters_by_ft['dockerfile'] = nil
      -- lint.linters_by_ft['inko'] = nil
      -- lint.linters_by_ft['janet'] = nil
      -- lint.linters_by_ft['json'] = nil
      -- lint.linters_by_ft['markdown'] = nil
      -- lint.linters_by_ft['rst'] = nil
      -- lint.linters_by_ft['ruby'] = nil
      -- lint.linters_by_ft['terraform'] = nil
      -- lint.linters_by_ft['text'] = nil

      -- Customize clippy to not show children and add extra lints
      local clippy = lint.linters.clippy

      clippy.ignore_exitcode = true
      clippy.args = { 'clippy', '--message-format=json', '--all-features', '--', '-Wclippy::pedantic', '-Wclippy::nursery' }
      clippy.parser = function(output, bufnr)
        local diagnostics = {}
        local items = #output > 0 and vim.split(output, '\n') or {}
        local file_name = vim.api.nvim_buf_get_name(bufnr)
        file_name = vim.fn.fnamemodify(file_name, ':p')

        for _, i in ipairs(items) do
          local item = i ~= '' and vim.json.decode(i) or {}
          -- cargo also outputs build artifacts messages in addition to diagnostics
          if item and item.reason == 'compiler-message' then
            parse(diagnostics, file_name, item)
          end
        end
        return diagnostics
      end

      -- Create autocommand which carries out the actual linting
      -- on the specified events.
      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function()
          -- Only run the linter in buffers that you can modify in order to
          -- avoid superfluous noise, notably within the handy LSP pop-ups that
          -- describe the hovered symbol using Markdown.
          if vim.bo.modifiable then
            -- For projects that include go projects in a subdirectory, cwd needs to be specified
            if vim.bo.filetype == 'go' then
              local filename = vim.api.nvim_buf_get_name(0)
              local cwd = vim.fs.root(filename, 'go.work') or vim.fs.root(filename, 'go.mod')
              lint.try_lint('golangcilint', { cwd = cwd })
            elseif vim.bo.filetype == 'rust' then
              local cwd = vim.fn.getcwd()

              if vim.fn.filereadable(cwd .. '/Cargo.toml') == 0 and vim.fn.isdirectory(cwd .. '/crates') == 1 then
                lint.try_lint('clippy', { cwd = cwd .. '/crates' })
              else
                lint.try_lint()
              end
            else
              lint.try_lint()
            end
          end
        end,
      })
    end,
  },
}
