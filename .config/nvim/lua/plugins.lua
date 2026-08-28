return {
  {
    'folke/tokyonight.nvim', -- colorscheme
    cond = not vim.g.vscode,
  },
  'tpope/vim-surround',
  'tpope/vim-repeat',
  {
    'mg979/vim-visual-multi',
    cond = not vim.g.vscode,
  },
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
    'github/copilot.vim',
    cond = not vim.g.vscode,
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
  }
}
