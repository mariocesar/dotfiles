return {
  {
    'folke/tokyonight.nvim', -- colorscheme
    cond = not vim.g.vscode,
  },
  'tpope/vim-surround',
  'tpope/vim-repeat',
  'NoahTheDuke/vim-just', -- newer than the copy bundled in the runtime
  {
    'liuchengxu/vim-clap',
    build = ':Clap install-binary!',
    cmd = 'Clap',
    cond = not vim.g.vscode,
    config = function()
      vim.g.enable_clap_auto_resize = true
      vim.g.clap_enable_background_shadow = true
      vim.g.clap_provider_dotfiles = {
        source = "fd --type f --hidden --follow --exclude .git . ~/.dotfiles/",
        description = 'Open some dotfile',
        sink = 'e',
        previewer = 'head -n 500 {}'
      }
    end
  },
  {
    'lewis6991/gitsigns.nvim',
    cond = not vim.g.vscode,
    config = function() require('gitsigns').setup() end
  },
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    cond = not vim.g.vscode,
    lazy = false, -- upstream does not support lazy-loading
    build = ':TSUpdate',
    config = function() require('treesitter') end
  },
  {
    'neovim/nvim-lspconfig',
    cond = not vim.g.vscode,
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      { 'mason-org/mason.nvim', build = ':MasonUpdate' },
      'mason-org/mason-lspconfig.nvim'
    },
    config = function() require('lsp') end
  },
  {
    -- Ghostty ships ftdetect/ftplugin/syntax for its own config format next to
    -- $GHOSTTY_RESOURCES_DIR on every platform, so no OS-specific path needed.
    dir = (vim.env.GHOSTTY_RESOURCES_DIR or '') .. '/../nvim/site',
    cond = vim.env.GHOSTTY_RESOURCES_DIR ~= nil,
    name = 'ghostty',
    lazy = false,
  }
}
