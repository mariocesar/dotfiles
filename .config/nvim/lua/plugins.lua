return {
  'folke/tokyonight.nvim', -- colorscheme
  'tpope/vim-surround',
  'mg979/vim-visual-multi',
  {
    'liuchengxu/vim-clap',
    build = ':Clap install-binary!'
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
