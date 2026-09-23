return {
  {
    'folke/tokyonight.nvim', -- colorscheme
    cond = not vim.g.vscode,
  },
  'tpope/vim-surround',
  'tpope/vim-repeat',
  'NoahTheDuke/vim-just', -- newer than the copy bundled in the runtime
  {
    'thgrass/tail.nvim', -- :TailEnable follows appended lines while at the bottom
    cmd = { 'TailEnable', 'TailToggle' },
  },
  {
    'liuchengxu/vim-clap',
    build = ':Clap install-binary!',
    cmd = 'Clap',
    cond = not vim.g.vscode,
    init = function() -- clap reads some of these while loading, before config runs
      vim.g.enable_clap_auto_resize = true
      vim.g.clap_enable_background_shadow = true
      vim.g.clap_enable_icon = 1
      vim.g.clap_search_box_border_style = 'curve'
      vim.g.clap_current_selection_sign = { text = '▌', texthl = 'ClapCurrentSelectionSign', linehl = 'ClapCurrentSelection' }
      vim.g.clap_selected_sign = { text = '●', texthl = 'ClapSelectedSign', linehl = 'ClapSelected' }
      vim.g.clap_fuzzy_match_hl_groups = { { 215, '#ff9e64' } }
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
    config = function()
      require('gitsigns').setup {
        on_attach = function(buf)
          local gs = require('gitsigns')
          -- keep the builtin ]c [c in diff windows
          vim.keymap.set('n', ']c', function()
            if vim.wo.diff then vim.cmd.normal { ']c', bang = true } else gs.nav_hunk('next') end
          end, { buffer = buf, desc = 'Next git hunk' })
          vim.keymap.set('n', '[c', function()
            if vim.wo.diff then vim.cmd.normal { '[c', bang = true } else gs.nav_hunk('prev') end
          end, { buffer = buf, desc = 'Previous git hunk' })
        end,
      }
    end
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
