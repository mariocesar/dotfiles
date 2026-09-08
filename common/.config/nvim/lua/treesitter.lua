--[[
  Treesitter: nvim-treesitter installs the parsers and queries, Neovim does the
  highlighting. Nothing is enabled automatically, hence the FileType hook below.
--]]

local parsers = {
  'bash',
  'css',
  'dockerfile',
  'hcl',
  'html',
  'htmldjango',
  'javascript', -- also parses JSX
  'jinja',
  'jinja_inline',
  'json',
  'lua',
  'markdown',
  'markdown_inline', -- fenced code blocks inside markdown
  'python',
  'sql',
  'terraform',
  'toml',
  'tsx',
  'typescript',
  'yaml'
}

require('nvim-treesitter').install(parsers)

-- Start on any buffer whose language has a parser; pcall skips the rest.
local ts = require('au')('treesitter')

function ts.FileType(args)
  pcall(vim.treesitter.start, args.buf)
end
