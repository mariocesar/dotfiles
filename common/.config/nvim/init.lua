local opt = vim.opt
local global = vim.g

global.mapleader = ","
global.maplocalleader = "\\"

global.loaded_python3_provider = 0
global.loaded_ruby_provider = 0
global.loaded_perl_provider = 0
global.loaded_node_provider = 0
global.loaded_nvim_dir_plugin = 1

global.netrw_mousemaps = 0
global.netrw_banner = 0
global.netrw_liststyle = 3 -- tree
global.netrw_list_hide = [[^\.git/$,^\.venv/$,^\..*_cache/$]]

require("config.lazy")

-- Options

opt.mouse = "a"
opt.cursorline = true
opt.scrolloff = 10
opt.splitbelow = true
opt.splitright = true

opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "split"
opt.grepprg = "rg --vimgrep"

opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = true
opt.smartindent = true
opt.breakindent = true
opt.autowrite = true

opt.modelines = 10
opt.swapfile = false
opt.writebackup = false
opt.undofile = true

opt.updatetime = 250
opt.timeoutlen = 300

opt.wildignore = {
  "*/.git/**",
  "*/.idea/**",
  "*/.cache/**",
  "*/*_cache/*",
  "*/__pycache__/",
  "*/node_modules/**",
  "*/venv/**",
  "*/.venv/**",
  "*/tmp/**",
  "*/var/**",
  "*.o",
  "*.so",
  "*.pyc",
  "*.swp",
  "*~",
  "*.zip",
  "*.tar.gz",
  "*.min.*",
  "*.png",
  "*.jpg",
  "*.jpeg",
  "*.gif",
  "*.svg",
  "*DS_Store*",
}

if not global.vscode then
  opt.number = true
  opt.signcolumn = "yes"
  opt.list = true
  opt.listchars = { tab = "▸ ", trail = "·", extends = ">", precedes = "<", nbsp = "␣" }

  -- The default bar already shows problem counts and the ruler; add the branch and LSP progress
  local statusline = vim.api.nvim_get_option_info2("statusline", {}).default
  opt.statusline = (statusline:gsub("%%=", "%%( %%{get(b:, 'gitsigns_head', '')}%%)%%=%%( %%{v:lua.vim.lsp.status()}%%)", 1))

  -- Window title in the form: "file - project"
  opt.title = true
  opt.titlestring = "%{expand('%:t') != '' ? expand('%:t') .. ' - ' : ''}%{fnamemodify(getcwd(), ':t')}"

  require("tokyonight").setup({
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
  })
  vim.cmd.colorscheme("tokyonight-night")
end

-- Clipboard

-- No display over ssh, and nvim's own OSC 52 fallback is skipped once 'clipboard' is set
if vim.env.SSH_TTY then
  local osc52 = require("vim.ui.clipboard.osc52")
  -- Paste from nvim's own register: OSC 52 reads make Ghostty prompt on every `p`
  local function paste()
    return { vim.fn.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") }
  end
  global.clipboard = {
    name = "OSC 52",
    copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
    paste = { ["+"] = paste, ["*"] = paste },
  }
end

-- Resolving the clipboard provider runs external tools; keep it off the startup path
vim.schedule(function()
  opt.clipboard = "unnamedplus"
end)

-- Filetype

vim.filetype.add({ extension = { jinja = "jinja", jinja2 = "jinja", j2 = "jinja" } })

-- Commands

local cmd = vim.api.nvim_create_user_command

cmd("Cwd", "cd %:p:h", { desc = "Set cwd to the directory of the current file" })
cmd("Run", '!"%:p"', { desc = "Execute the current file" })
cmd("Config", "edit $MYVIMRC", { desc = "Edit init.lua" })
cmd("Reload", "source $MYVIMRC", { desc = "Source init.lua" })
cmd("Cheat", "tabnew " .. vim.fn.stdpath("config") .. "/cheatsheet.md", { desc = "Open the keybinding cheat sheet" })
cmd("Grep", "silent grep! <args>", { nargs = "+", desc = "Grep into quickfix without jumping to the first match" })
cmd("Changed", function()
  require("gitsigns").setqflist("all")
end, { desc = "Quickfix list of every changed hunk in the repo" })
cmd("WriterMode", function()
  vim.opt_local.wrap = true
  vim.opt_local.linebreak = true
  vim.opt_local.showbreak = "»"
  vim.opt_local.textwidth = 80
  vim.opt_local.colorcolumn = "81"
  vim.opt_local.tabstop = 2
  vim.opt_local.shiftwidth = 2
  vim.notify("Applied Writer Mode")
end, { desc = "Set useful writing options for the current buffer" })

-- Keymaps

-- vim.keymap.set with silent as the default
local function map(mode, lhs, rhs, o)
  vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("keep", o or {}, { silent = true }))
end

map("n", "<leader>s", "<cmd>write<cr>", { desc = "Save buffer" })
map("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit" })
map("n", "<leader>%", "<cmd>vsplit<cr>", { desc = "Split vertical" })
map("n", '<leader>"', "<cmd>split<cr>", { desc = "Split horizontal" })
map("n", "<leader>c", "<cmd>tabnew<cr>", { desc = "New tab" })
map("n", "<leader>n", "<cmd>tabnext<cr>", { desc = "Switch to next tab" })
map("n", "<leader>f", vim.lsp.buf.format, { desc = "Format the current buffer" })
map("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Quickly select, search and replace" })
map("n", "<C-j>", "<C-d>zz", { desc = "Scroll down and center" })
map("n", "<C-k>", "<C-u>zz", { desc = "Scroll up and center" })
map("n", "<esc><esc>", "<cmd>nohlsearch<cr><C-l>", { desc = "Cleanup search highlight and redraw" })
map("n", "J", "mzJ`z", { desc = "Join lines without moving the cursor" })
map("n", "n", "nzzzv", { desc = "Jumps to the next match and center" })
map("n", "N", "Nzzzv", { desc = "Jumps to the previous match and center" })
map("n", "<C-]>", "<cmd>cnext<CR>zz", { desc = "Focus on the next quickfix item" })
map("n", "<C-[>", "<cmd>cprev<CR>zz", { desc = "Focus on the previous quickfix item" })

map("n", "<leader>l", function()
  if vim.fn.getqflist({ winid = 0 }).winid ~= 0 then
    vim.cmd.cclose()
  else
    vim.cmd.copen()
  end
end, { desc = "Toggle the quickfix list" })

-- Lexplore's own size is a percentage; a tree reads better at a fixed width
local function explorer()
  vim.cmd.Lexplore()
  if vim.api.nvim_get_current_buf() == vim.t.netrw_lexbufnr then
    vim.cmd("vertical resize 30")
  end
end

map("n", "<leader>e", explorer, { desc = "Toggle the file tree sidebar" })

-- :terminal takes the rest of the line as its command, so `| startinsert` can't chain
map("n", "<leader>t", function()
  vim.cmd("below terminal")
  vim.cmd.startinsert()
end, { desc = "Open a terminal below" })

map("n", "<leader>p", "<cmd>Clap files<cr>", { desc = "Navigate files in the current working directory" })
map("n", "<leader>d", "<cmd>Clap dotfiles<cr>", { desc = "Open some dotfile" })
map("n", "<leader>b", "<cmd>Clap blines<cr>", { desc = "Search lines in the current buffer" })
map("n", "<leader>g", "<cmd>Clap grep<cr>", { desc = "Live grep in the project" })
map("n", "<leader>G", "<cmd>Clap grep ++query=<cword><cr>", { desc = "Live grep the word under cursor" })
-- `:` not <cmd>: leaving visual mode first sets the '< '> marks @visual reads
map("v", "<leader>g", ":<C-u>Clap grep ++query=@visual<cr>", { desc = "Live grep the selection" })

map("v", "<", "<gv", { desc = "Keep the selection when indenting" })
map("v", ">", ">gv", { desc = "Keep the selection when indenting" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selected line up" })
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selected line down" })

map("t", "<esc><esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

map("v", "<C-c>", function()
  vim.api.nvim_command("normal! gvy")
  vim.notify("Copied to clipboard")
end, { desc = "Copy to clipboard" })
map("n", "<D-v>", "a<C-r>+<Esc>", { desc = "Paste" })
map("i", "<D-v>", "<C-r>+", { desc = "Paste" })
map("c", "<D-v>", "<C-r>+", { desc = "Paste" })

-- Autocommands

local au = require("au")

-- briefly highlight a selection on yank
local yank = au("user_yank")

function yank.TextYankPost()
  vim.hl.on_yank()
end

-- open the quickfix list after :grep
local grep = au("user_grep")
local results = grep("QuickFixCmdPost", { pattern = "grep" })

function results.handler()
  vim.cmd.cwindow()
end

-- progress messages only reach the statusline on a redraw
local progress = au("user_lsp_progress")

function progress.LspProgress()
  vim.cmd.redrawstatus()
end

-- skip syntax highlighting for large files
local bigfile = au("user_bigfile")

function bigfile.BufReadPost(args)
  if vim.fn.getfsize(args.file) > 100 * 1024 then
    vim.bo[args.buf].syntax = "off"
  end
end

-- Neovide

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

  map("n", "<C-=>", function()
    zoom(1.1)
  end, { desc = "Zoom in" })

  map("n", "<C-->", function()
    zoom(1 / 1.1)
  end, { desc = "Zoom out" })

  map("n", "<C-0>", function()
    zoom()
  end, { desc = "Reset zoom" })

  map({ "n", "i", "c", "t" }, "<C-S-v>", function()
    vim.api.nvim_paste(vim.fn.getreg("+"), true, -1)
  end, { desc = "Paste" })

  -- Instead of :q, close the buffer keep the window open.
  map("n", "<leader>q", "<cmd>bdelete<cr>", { desc = "Close buffer" })

  -- Show the explorer by default
  if vim.fn.argc() == 0 then
    local project = au("user_project")
    function project.VimEnter()
      explorer()
      vim.cmd.wincmd("p")
    end
  end

  global.neovide_hide_mouse_when_typing = true
  global.neovide_remember_window_size = true
  global.neovide_fullscreen = false
  global.neovide_confirm_quit = true
  global.neovide_scroll_animation_length = 0.1
  global.neovide_cursor_animation_length = 0.05
  global.neovide_cursor_trail_size = 0.25
  global.neovide_cursor_animate_in_insert_mode = false -- typed text lands before the gliding cursor does
  global.neovide_refresh_rate = 60
end

-- TODO: load init.lua from a working directory. Similar to .envrc load setup
