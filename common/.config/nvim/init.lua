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
opt.grepprg = 'rg --vimgrep'

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
  require('tokyonight').setup {
    -- vim-clap only derives its own colors for groups that don't exist yet
    on_highlights = function(hl, c)
      hl.ClapInput = { bg = c.bg_highlight }
      hl.ClapSearchText = { fg = c.fg, bg = c.bg_highlight, bold = true }
      hl.ClapSpinner = { fg = c.blue, bg = c.bg_highlight, bold = true }
      hl.ClapIndicator = { fg = c.comment, bg = c.bg_highlight }
      hl.ClapDisplay = { fg = c.fg_dark, bg = c.bg_dark }
      hl.ClapPreview = { bg = c.bg_dark }
      hl.ClapCurrentSelection = { fg = c.fg, bg = c.bg_highlight, bold = true }
      hl.ClapCurrentSelectionSign = { fg = c.blue, bg = c.bg_highlight }
      hl.ClapSelected = { fg = c.magenta, bold = true }
      hl.ClapSelectedSign = { fg = c.magenta }
    end,
  }
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
cmd("Grep", "silent grep! <args>", {
  nargs = '+',
  desc = 'grep into quickfix without jumping to the first match'
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
map('n', '<C-j>', '<C-d>zz', {
  desc = 'Scroll down and center',
})
map('n', '<C-k>', '<C-u>zz', {
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
map('n', '<leader>g', '<cmd>Clap grep<cr>', {
  desc = 'Live grep in the project'
})
map('n', '<leader>G', '<cmd>Clap grep ++query=<cword><cr>', {
  desc = 'Live grep the word under cursor'
})
map('n', '<leader>b', '<cmd>Clap blines<cr>', {
  desc = 'Search lines in the current buffer'
})
-- `:` not <cmd>: leaving visual mode first sets the '< '> marks @visual reads
map('v', '<leader>g', ':<C-u>Clap grep ++query=@visual<cr>', {
  desc = 'Live grep the selection'
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

-- open the quickfix list after :grep

local grep = au("user_grep")
local results = grep({
  'QuickFixCmdPost'
}, {
  pattern = 'grep'
})

function results.handler() vim.cmd.cwindow() end

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
  -- Matched to Ghostty by screenshot: padding is in physical px, so 24 is its 12pt at 2x.
  global.neovide_padding_top = 24
  global.neovide_padding_bottom = 24
  global.neovide_padding_left = 24
  global.neovide_padding_right = 24
  opt.linespace = 1
  global.neovide_text_contrast = 0.9 -- stands in for font-thicken
  global.neovide_opacity = 1.0
  global.neovide_normal_opacity = 0.95

  -- Ghostty's zoom and paste chords; Neovide has neither.
  global.neovide_scale_factor = 1.0
  local function zoom(by)
    global.neovide_scale_factor = by and global.neovide_scale_factor * by or 1.0
  end
  map('n', '<C-=>', function() zoom(1.1) end, { desc = 'Zoom in' })
  map('n', '<C-->', function() zoom(1 / 1.1) end, { desc = 'Zoom out' })
  map('n', '<C-0>', function() zoom() end, { desc = 'Reset zoom' })
  map({ 'n', 'i', 'c', 't' }, '<C-S-v>', function()
    vim.api.nvim_paste(vim.fn.getreg('+'), true, -1)
  end, { desc = 'Paste' })

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
