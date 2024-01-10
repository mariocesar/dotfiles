vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  use 'folke/tokyonight.nvim'
  use {'liuchengxu/vim-clap',  run=':Clap install-binary!' }
end)
