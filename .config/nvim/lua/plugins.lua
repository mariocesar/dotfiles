return {
  {
    'folke/tokyonight.nvim', -- colorscheme
    cond = not vim.g.vscode,
  },
  'tpope/vim-surround',
  'tpope/vim-repeat',
  {
    'm4xshen/hardtime.nvim',
    lazy = false,
    cond = not vim.g.vscode,
    dependencies = { 'MunifTanjim/nui.nvim' },
    opts = {},
  },
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
    config = function()
      if vim.fn.exists('g:vscode') == 1 then
        vim.api.nvim_create_autocmd('VimEnter', {
          callback = function() vim.cmd('Copilot disable') end
        })
      end
    end
  },
  {
    'lewis6991/gitsigns.nvim',
    cond = not vim.g.vscode,
    config = function() require('gitsigns').setup() end
  }
}
