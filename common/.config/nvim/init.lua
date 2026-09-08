local opt = vim.opt
local global = vim.g

global.mapleader = ','
global.maplocalleader = '\\'

require("config.lazy")

global.have_nerd_fonts = true

-- Fixes slow startup time
global.loaded_python3_provider = 0

if not global.vscode then
  opt.number = true
  opt.signcolumn = 'yes'

  opt.list = true
  opt.listchars = {
    tab = '▸ ',
    trail = '·',
    extends = '>',
    precedes = '<',
    nbsp = '␣'
  }
end

opt.updatetime = 300
opt.timeoutlen = 300

opt.mouse = 'a'

opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
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

vim.o.modeline = true
vim.o.modelines = 10

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

if not global.vscode then
  vim.cmd [[colorscheme tokyonight-night]]
end

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
cmd("Cheat", "tabnew " .. vim.fn.stdpath("config") .. "/cheatsheet.md", {
  desc = 'open the keybinding cheat sheet'
})

-- open (new) terminal at the bottom of the current tab
cmd("Terminal", function(tbl)
  require("term"):open{
    cmd = #tbl.args > 0 and tbl.args or nil
  }
end, {
  nargs = "?"
})

-- Make vim.keymap.set defaults every mapping to silent.
local function map(mode, lhs, rhs, o)
  vim.keymap.set(mode, lhs, rhs, vim.tbl_extend('keep', o or {}, {
    silent = true
  }))
end

-- Normal mode
map('n', 'Q', '<nop>', {
  desc = "Disabling exmode enter"
})
map('n', '<leader>q', '<cmd>quit<cr>', {
  desc = "Quit"
})
map('n', '<leader>c', '<cmd>tabnew<cr>', {
  desc = "New tab"
})
map('n', '<leader>n', '<cmd>tabnext<cr>', {
  desc = "Switch to next tab"
})
map('n', '<leader>%', '<cmd>vsplit<cr>', {
  desc = "Split vertical"
})
map('n', '<leader>"', '<cmd>split<cr>', {
  desc = "Split horizontal"
})
map('n', '<leader>s', '<cmd>write<cr>', {
  desc = 'Save buffer on normal mode'
})
map('n', '<esc><esc>', '<cmd>nohlsearch<cr><C-l>', {
  desc = 'Cleanup search highlight and redraw'
})
map('n', '<leader>p', '<cmd>Clap files<cr>', {
  desc = 'Navigate files in the current working directory'
})

map('n', '<C-d>', '<C-d>zz', {
  desc = 'Scroll down and center',
})

map('n', '<C-u>', '<C-u>zz', {
  desc = 'Scroll up and center',
})

-- Visual mode
map('v', '<', '<gv', {
  desc = 'Mantain the selected blocks when indenting'
})
map('v', '>', '>gv', {
  desc = 'Mantain the selected blocks when indenting'
})

-- Terminal mode
map('t', '<esc><esc>', '<C-\\><C-n>', {
  desc = 'Exit terminal mode'
})

map('n', '<leader>d', '<cmd>Clap dotfiles<cr>', {
  desc = 'Open some dotfile'
})

-- Paste on Normal, Insert and Command-Line mode

map('v', '<C-c>', function()
  vim.api.nvim_command('normal! gvy')
  vim.notify('Copied to clipboard')
end, {
  desc = 'Copy to clipboard'
})

map('n', '<D-v>', 'a<C-r>+<Esc>', {
  desc = 'Paste'
})
map('i', '<D-v>', '<C-r>+', {
  desc = 'Paste'
})
map('c', '<D-v>', '<C-r>+', {
  desc = 'Paste'
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

function conceal.handler() vim.opt_local.conceallevel = 0 end

-- briefly highlight a selection on yank

local yank = au("user_yank")

function yank.TextYankPost() vim.hl.on_yank() end

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

-- Skip syntax highlighting for large files. 
vim.api.nvim_create_autocmd('BufReadPost', {
  pattern = '*',
  callback = function(args)
    if vim.fn.getfsize(args.file) > 100 * 1024 then
      vim.bo[args.buf].syntax = 'off'
    end
  end
})

-- TODO: load init.lua from a working directory. Similar to .envrc load setup
--
