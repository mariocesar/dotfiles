local execute = vim.api.nvim_command
local fn = vim.fn
local opt = vim.opt
local global = vim.g
local create_autocmd = vim.api.nvim_create_autocmd
local create_augroup = vim.api.nvim_create_augroup

opt.number = true
opt.mouse = 'a'
opt.hlsearch = false
opt.autoindent = true
opt.smartindent = true
opt.breakindent = true
opt.cursorline = false
opt.autowrite = true

opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = true

opt.splitbelow = true
opt.splitright = true

global.mapleader = ','

opt.wildignore = {'*/node_modules/**', '*/*_cache/*', '*/.git/**', '*.o', '*~', '*.pyc', '*/tmp/**', '*.so', '*.swp',
                  '*.zip', '*.tar.gz', '*.min.*', '*.png', '*.jpg', '*.jpeg', '*.svg', '*.gif', '*/__pycache__/',
                  '*/.idea/**', '*/.cache/**', '*/var/**', '*/venv/**', '*/.venv/**', '*DS_Store*'}

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

-- Keymaps
local keymap = vim.keymap.set

keymap('n', 'Q', '<nop', {
    desc = "Disabling exmode enter"
})
keymap('n', '<leader>q', '<cmd>quit<cr>', {
    desc = "Quit"
})
keymap('n', '<leader>c', '<cmd>tabnew<cr>', {
    desc = "New tab"
})
keymap('n', '<leader>n', '<cmd>tabnext<cr>', {
    desc = "Switch to next tab"
})
keymap('n', '<leader>%', '<cmd>vsplit<cr>', {
    desc = "Split vertical"
})
keymap('n', '<leader>"', '<cmd>split<cr>', {
    desc = "Split horizontal"
})
keymap('n', '<leader>s', '<cmd>write<cr>', {
    desc = 'Save buffer on normal mode'
})
keymap('n', '<silent> <esc><esc>', '<cmd><C-u>nohlsearch<cr><C-l>', {
    desc = 'Cleanup search highlight and redraw'
})
keymap('i', '<silent> <esc><esc>', '<C-o>:nohlsearch<cr>', {
    desc = 'Cleanup search highlight and redraw'
})
keymap('v', '<', '<gv', {
    desc = 'Mantain the selected blocks when indenting'
})
keymap('v', '>', '>gv', {
    desc = 'Mantain the selected blocks when indenting'
})

-- Paste on Normal, Insert and Command-Line mode
keymap('n', '<D-v>', 'a<C-r>+<Esc>', {
    desc = 'Paste'
})
keymap('i', '<D-v>', '<C-r>+', {
    desc = 'Paste'
})
keymap('c', '<D-v>', '<C-r>+', {
    desc = 'Paste'
})

local au = require("au")

-- Toggle between relative and absolute line numbers depending on mode

local number = au("user_number")
local relative = number {"BufEnter", "FocusGained", "InsertLeave", "TermLeave", "WinEnter"}
local absolute = number {"BufLeave", "FocusLost", "InsertEnter", "TermEnter", "WinLeave"}

function relative.handler()
    if vim.opt_local.number:get() and vim.fn.mode() ~= "i" then
        vim.opt_local.relativenumber = true
    end
end

function absolute.handler()
    if vim.opt_local.number:get() then
        vim.opt_local.relativenumber = false
    end
end

-- JSON show conceal chars

local json = au("json")
local conceal = json({'BufEnter'}, {
    pattern = '*.json'
})

function conceal.handler()
    opt.conceallevel = 0
end
