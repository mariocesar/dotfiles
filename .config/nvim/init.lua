local execute = vim.api.nvim_command
local fn = vim.fn
local opt = vim.opt
local global = vim.g
local keymap = vim.keymap.set
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

-- Keymaps

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
keymap('n', '<leader>.', '<cmd>lcd %:p:h<cr>', {
    desc = 'Set the current directory to the parent dir of the current file.'
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

opt.relativenumber = true

local group_yaml = create_augroup('yaml', {
    clear = true
})

create_autocmd('BufLeave,FocusLost,InsertEnter', {
    pattern = '*',
    group = group_yaml,
    callback = function()
        opt.relativenumber = false
    end
})

create_autocmd('BufEnter,FocusGained,InsertLeave', {
    pattern = '*',
    group = group_yaml,
    callback = function()
        opt.relativenumber = true
    end
})

local group_json = create_augroup('json', {
    clear = true
})

create_autocmd('BufEnter', {
    pattern = '*.json',
    group = group_json,
    callback = function()
        opt.conceallevel = 0
    end
})

create_autocmd('FileType', {
    pattern = 'markdown',
    callback = function()
        opt.comments = ':* ,:>'
    end
})

create_autocmd({'DirChanged'}, {
    pattern = {'global'},
    callback = function()
        -- TODO: Search and execute .nvim.lua if found.
    end
})
