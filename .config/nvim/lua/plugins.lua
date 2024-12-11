vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  use 'folke/tokyonight.nvim'
  use {'liuchengxu/vim-clap',  run=':Clap install-binary!' }
  use 'tpope/vim-surround'

  use 'github/copilot.vim'
  if vim.fn.exists('g:vscode') == 1 then
    vim.cmd('autocmd VimEnter * Copilot disable')
  end

  use {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup()
    end
  }

  use 'mg979/vim-visual-multi'
end)
