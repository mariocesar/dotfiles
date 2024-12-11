local execute = vim.api.nvim_command

local fn = vim.fn
local opt = vim.opt
local global = vim.g

local create_autocmd = vim.api.nvim_create_autocmd
local create_augroup = vim.api.nvim_create_augroup

require("config.lazy")
require("lazy").setup("plugins")

global.mapleader = ','
global.maplocalleader = '\\'

global.have_nerd_fonts = true

-- Fixes slow startup time
global.loaded_python_provider = 0
global.loaded_python3_provider = 0

opt.number = true
opt.signcolumn = 'yes'
opt.updatetime = 300
opt.timeoutlen = 300

opt.mouse = 'a'

opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false
opt.inccommand = 'split'

opt.autoindent = true
opt.smartindent = true
opt.breakindent = true
opt.cursorline = true
opt.autowrite = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = true
opt.splitbelow = true
opt.splitright = true
opt.scrolloff = 10

opt.list = true
opt.listchars = {
  tab = '▸ ',
  trail = '·',
  extends = '>',
  precedes = '<',
  nbsp = '␣'
}

-- Schedule after UIEnter to avoid increase startup time
vim.schedule(function()
  -- Sync clipboard with system clipboard
  opt.clipboard = 'unnamedplus'
end)

opt.wildignore = {
  '*/node_modules/**',
  '*/*_cache/*',
  '*/.git/**',
  '*.o',
  '*~',
  '*.pyc',
  '*/tmp/**',
  '*.so',
  '*.swp',
  '*.zip',
  '*.tar.gz',
  '*.min.*',
  '*.png',
  '*.jpg',
  '*.jpeg',
  '*.svg',
  '*.gif',
  '*/__pycache__/',
  '*/.idea/**',
  '*/.cache/**',
  '*/var/**',
  '*/venv/**',
  '*/.venv/**',
  '*DS_Store*'
}

vim.cmd [[colorscheme tokyonight-night]]

-- Filetype

vim.filetype.add {
  extension = {
    jinja = 'jinja',
    jinja2 = 'jinja',
    j2 = 'jinja'
  }
}

-- Commands
local cmd = vim.api.nvim_create_user_command

cmd("Cwd", "cd %:p:h", {
  desc = 'set cwd to directory of current file'
})
cmd("Run", '!"%:p"', {
  desc = 'Execute current file'
})
cmd("Config", "edit $MYVIMRC", {
  desc = 'open config file with :Config'
})
cmd("Reload", "source $MYVIMRC", {
  desc = 'reload config file with :Reload'
})

-- open (new) terminal at the bottom of the current tab
cmd("Terminal", function(tbl)
  require("term"):open{
    cmd = #tbl.args > 0 and tbl.args or nil
  }
end, {
  nargs = "?"
})

local map, opts = vim.keymap.set, {
  noremap = true,
  silent = true
}

-- Normal mode
map('n', 'Q', '<nop', {
  desc = "Disabling exmode enter",
  unpack(opts)
})
map('n', '<leader>q', '<cmd>quit<cr>', {
  desc = "Quit",
  unpack(opts)
})
map('n', '<leader>c', '<cmd>tabnew<cr>', {
  desc = "New tab",
  unpack(opts)
})
map('n', '<leader>n', '<cmd>tabnext<cr>', {
  desc = "Switch to next tab",
  unpack(opts)
})
map('n', '<leader>%', '<cmd>vsplit<cr>', {
  desc = "Split vertical",
  unpack(opts)
})
map('n', '<leader>"', '<cmd>split<cr>', {
  desc = "Split horizontal",
  unpack(opts)
})
map('n', '<leader>s', '<cmd>write<cr>', {
  desc = 'Save buffer on normal mode',
  unpack(opts)
})
map('n', '<silent> <esc><esc>', '<cmd><C-u>nohlsearch<cr><C-l>', {
  desc = 'Cleanup search highlight and redraw',
  unpack(opts)
})
map('n', '<leader>p', '<cmd>Clap files<cr>', {
  desc = 'Navigate files in the current working directory',
  unpack(opts)
})

-- Insert mode
map('i', '<silent> <esc><esc>', '<C-o>:nohlsearch<cr>', {
  desc = 'Cleanup search highlight and redraw',
  unpack(opts)
})

-- Visual mode
map('v', '<', '<gv', {
  desc = 'Mantain the selected blocks when indenting',
  unpack(opts)
})
map('v', '>', '>gv', {
  desc = 'Mantain the selected blocks when indenting',
  unpack(opts)
})

-- Terminal mode
map('t', '<esc><esc>', '<C-\\><C-n>', {
  desc = 'Exit terminal mode'
})

vim.g.clap_provider_dotfiles = {
  source = {
    '~/.config/nvim/init.lua',
    '~/.config/nvim/lua/plugins.lua',
    '~/.zshrc',
    '~/.zshrc.tango'
  },
  sink = 'e',
  description = 'Open some dotfile'
}

map('n', '<leader>d', '<cmd>Clap dotfiles<cr>', {
  unpack(opts)
})

-- Paste on Normal, Insert and Command-Line mode

map('v', '<C-c>', function()
  vim.api.nvim_command('normal! gvy')
  vim.notify('Copied to clipboard')
end, {
  desc = 'Copy to clipboard',
  unpack(opts)
})

map('n', '<D-v>', 'a<C-r>+<Esc>', {
  desc = 'Paste',
  unpack(opts)
})
map('i', '<D-v>', '<C-r>+', {
  desc = 'Paste',
  unpack(opts)
})
map('c', '<D-v>', '<C-r>+', {
  desc = 'Paste',
  unpack(opts)
})

-- Auto commands

local au = require("au")

-- JSON show conceal chars

local json = au("json")
local conceal = json({
  'BufEnter'
}, {
  pattern = '*.json'
})

function conceal.handler() opt.conceallevel = 0 end

-- briefly highlight a selection on yank

local yank = au("user_yank")

function yank.TextYankPost() vim.highlight.on_yank() end

-- Markdown preferences

local markdown = au("markdown")
local wrap = markdown({
  "FileType"
}, {
  pattern = "markdown"
})

function wrap.handler()
  vim.opt_local.wrap = true
  vim.opt_local.linebreak = true
end

if global.neovide then
  global.neovide_scale_factor = 0.8
  global.neovide_hide_mouse_when_typing = true
  global.neovide_remember_window_size = true
  global.neovide_fullscreen = false
  global.neovide_confirm_quit = true
  global.neovide_scroll_animation_length = 0.1
  global.neovide_cursor_animation_length = 0.05
  global.neovide_cursor_trail_size = 0.25
  global.neovide_refresh_rate = 60
end

-- Delay the loading of syntax highlighting for large files
vim.api.nvim_create_autocmd('BufReadPre', {
  pattern = '*',
  callback = function()
    if vim.fn.getfsize(vim.fn.expand('%')) > 100 * 1024 then
      vim.cmd('syntax off')
    end
  end
})

-- TODO: load init.lua from a working directory. Similar to .envrc load setup
--
