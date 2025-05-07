-- local cwd = vim.fn.getcwd()
-- -- vim.notify(vim.inspect {
-- --   '/home/nordbo/nvim_docker.sh',
-- --   'hawk20_compiler',
-- --   cwd,
-- -- })
-- return {
--   -- cmd = { 'clangd', '--background-index' },
--   cmd = {
--     '/home/nordbo/nvim_docker.sh',
--     'hawk20_compiler',
--     -- cwd,
--     -- '--background-index',
--     -- '-j=8',
--     -- '--log=verbose',
--     -- '--query-driver=/usr/bin/**/clang-*,/bin/clang,/bin/clang++,/usr/bin/gcc,/usr/bin/g++',
--     -- '--all-scopes-completion',
--     -- '--completion-style=detailed',
--     -- '--header-insertion-decorators',
--     -- '--header-insertion=iwyu',
--     -- '--pch-storage=memory',
--   },
--   root_markers = { 'compile_commands.json', 'compile_flags.txt' },
--   filetypes = { 'c', 'cpp' },
-- }
-- ~/.config/nvim/lua/lsp/clangd.lua

-- local lspconfig = require 'lspconfig'
-- local util = require 'lspconfig.util'
--
-- lspconfig.clangd.setup {
--   -- cmd can be a function in 0.11+, so it's evaluated when the server actually starts:
--   cmd = function()
--     -- wrap clangd in your script, and pass the cwd at startup time
--     return {
--       '/home/nordbo/nvim_docker.sh',
--       'hawk20_compiler',
--       vim.fn.getcwd(),
--     }
--   end,
--
--   -- detect your project root:
--   root_dir = util.root_pattern('compile_commands.json', 'compile_flags.txt', '.git'),
--
--   -- only for C-family files:
--   filetypes = { 'c', 'cpp', 'objc', 'objcpp' },
--
--   -- any clangd-specific settings can still go here:
--   -- settings = { clangd = { ... } },
-- }

-- ~/.config/nvim/init.lua  (or lua/plugins/lsp.lua)

-- 1) make sure you have nvim-lspconfig installed:
--    Plug 'neovim/nvim-lspconfig'    (vim-plug)
--    use { 'neovim/nvim-lspconfig' } -- packer

local nvim_lsp = require 'lspconfig'
local util = require 'lspconfig.util'

-- function to compute where compile_commands.json lives:
local function get_compile_commands_dir()
  local cwd = vim.fn.getcwd()
  -- if we're inside catkin_ws/src/hawk/<proj> …
  local ws_root, proj = cwd:match '(.+)/catkin_ws_20/src/hawk/([^/]+)'
  if ws_root and proj then
    -- … then use ~/catkin_ws/build/<proj>
    return string.format('%s/catkin_ws_20/build/%s', ws_root, proj)
  end
  -- otherwise assume build is right next to src (or you generated compile_commands.json in-place)
  return cwd
end
local path_mappings = '/home/nordbo/catkin_ws_20=/home/nordbo_docker/catkin_ws'

-- clangd “cmd” wrapper to run it inside Docker
local clangd_cmd = {
  'docker',
  'exec',
  '-i',
  'hawk20_compiler',
  'clangd',
  '--background-index',
  '--clang-tidy',
  '--completion-style=detailed',
  '--compile-commands-dir=' .. get_compile_commands_dir(),
  '--path-mappings=' .. path_mappings,
  '--header-insertion-decorators',
  '--header-insertion=iwyu',
  '-j=8',
  '--log=verbose',
}

-- custom root_dir:
--  • first look for compile_commands.json / .git
--  • then detect ROS workspace as above
--  • finally fall back to git ancestor or cwd
local function clangd_root_dir(fname)
  -- 1) look for a local compile_commands.json or .git via lspconfig.util
  local root = util.root_pattern('compile_commands.json', '.git')(fname)
  if root then
    return root
  end

  -- 2) if we’re in a ROS catkin_ws src/hawk/<proj>, use that as root
  local cwd = vim.fn.getcwd()
  if cwd:match '.+/catkin_ws/src/hawk/[^/]+' then
    return cwd
  end

  -- 3) fallback: find the nearest .git via vim.fs.find
  local git_dir = vim.fs.find('.git', { path = fname, upward = true })[1]
  if git_dir then
    return vim.fs.dirname(git_dir)
  end

  -- last resort: just use cwd
  return cwd
end

-- put it all together:
nvim_lsp.clangd.setup {
  cmd = clangd_cmd,
  filetypes = { 'c', 'cpp', 'objc', 'objcpp' },
  root_dir = clangd_root_dir,
  -- any additional clangd-specific settings go here:
  settings = {
    -- e.g. clangd-extension settings or inlay hints
  },
}
