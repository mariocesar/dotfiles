return {
  'folke/tokyonight.nvim', -- colorscheme
  'tpope/vim-surround',
  'tpope/vim-repeat',
  'mg979/vim-visual-multi',
  {
    'liuchengxu/vim-clap',
    build = ':Clap install-binary!',
    cmd = 'Clap',
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
    config = function() require('gitsigns').setup() end
  }
}
