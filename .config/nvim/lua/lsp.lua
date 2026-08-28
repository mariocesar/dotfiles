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
  'bashls'
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

-- Neovim already binds grn/gra/grr/gri/grt/grx/gO, K on attach, and ]d/[d.
local lsp = require('au')('lsp')

function lsp.LspAttach(args)
  local function map(lhs, rhs, desc)
    vim.keymap.set('n', lhs, rhs, { buffer = args.buf, silent = true, desc = desc })
  end

  map('gd', vim.lsp.buf.definition, 'Go to definition')
  map('gD', vim.lsp.buf.declaration, 'Go to declaration')
  map('<leader>f', function() vim.lsp.buf.format { async = true } end, 'Format buffer')
end
