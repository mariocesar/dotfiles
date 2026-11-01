-- lspconfig names; mason-lspconfig translates them to Mason package names.
local servers = {
  'lua_ls',
  'pyright',
  'ruff',
  'ts_ls',
  'eslint',
  'terraformls',
  'html',
  'cssls',
  'jsonls',
  'yamlls',
  'bashls',
  'vala_ls'
}

require('mason').setup()

require('mason-lspconfig').setup {
  ensure_installed = servers,
  automatic_enable = false -- enabled explicitly below
}

-- Both servers organize imports and both hover; let ruff do the former only.
vim.lsp.config('pyright', {
  settings = {
    pyright = { disableOrganizeImports = true }
  }
})

vim.lsp.config('ruff', {
  on_attach = function(client)
    client.server_capabilities.hoverProvider = false
  end
})

vim.lsp.enable(servers)

-- Long messages truncate at the window edge, so expand them under the cursor line.
vim.diagnostic.config {
  virtual_text = { current_line = false },
  virtual_lines = { current_line = true },
  severity_sort = true
}

-- Hide inline diagnostics while working; signs stay, the saved config comes back as-is.
local saved_diagnostics
vim.keymap.set('n', '<leader>x', function()
  if saved_diagnostics then
    vim.diagnostic.config(saved_diagnostics)
    saved_diagnostics = nil
  else
    saved_diagnostics = vim.diagnostic.config()
    vim.diagnostic.config { virtual_text = false, virtual_lines = false, underline = false }
  end
end, { desc = 'Toggle inline diagnostics' })

-- Neovim already binds grn/gra/grr/gri/grt/grx/gO, K on attach, and ]d/[d.
local lsp = require('au')('lsp')

function lsp.LspAttach(args)
  local function map(lhs, rhs, desc)
    vim.keymap.set('n', lhs, rhs, { buffer = args.buf, silent = true, desc = desc })
  end

  map('gd', vim.lsp.buf.definition, 'Go to definition')
  map('gD', vim.lsp.buf.declaration, 'Go to declaration')
  map('<leader>f', function()
    -- ruff's formatter leaves import order to its organize-imports action, which needs a resolve for the edit
    for _, ruff in ipairs(vim.lsp.get_clients { bufnr = args.buf, name = 'ruff' }) do
      local params = vim.lsp.util.make_range_params(0, ruff.offset_encoding)
      params.context = { only = { 'source.organizeImports' }, diagnostics = {} }
      local actions = ruff:request_sync('textDocument/codeAction', params, 2000, args.buf)
      for _, action in ipairs(actions and actions.result or {}) do
        local resolved = ruff:request_sync('codeAction/resolve', action, 2000, args.buf)
        if resolved and resolved.result and resolved.result.edit then
          vim.lsp.util.apply_workspace_edit(resolved.result.edit, ruff.offset_encoding)
        end
      end
    end

    local formatters = vim.lsp.get_clients { bufnr = args.buf, method = 'textDocument/formatting' }
    vim.lsp.buf.format { timeout_ms = 2000 }
    if #formatters > 0 then
      vim.notify('Formatted with ' .. table.concat(vim.tbl_map(function(c) return c.name end, formatters), ', '))
    end
  end, 'Sort imports and format buffer')

  -- Menu as you type, server items first; enable() also applies auto-imports on accept
  local client = vim.lsp.get_client_by_id(args.data.client_id)
  if client and client:supports_method('textDocument/completion') then
    vim.lsp.completion.enable(true, client.id, args.buf)
    vim.bo[args.buf].autocomplete = true
    vim.bo[args.buf].complete = 'o,.,w,b,u,t'
    -- Without noselect the first item is inserted as you type, and backspace brings it back
    vim.bo[args.buf].completeopt = 'menu,menuone,noselect,popup,fuzzy'
  end
end
