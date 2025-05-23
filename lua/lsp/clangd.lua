-- 1) make sure you have nvim-lspconfig installed:
--    Plug 'neovim/nvim-lspconfig'    (vim-plug)
--    use { 'neovim/nvim-lspconfig' } -- packer

local nvim_lsp = require 'lspconfig'
local util = require 'lspconfig.util'

-- function to compute where compile_commands.json lives:
local function get_compile_commands_dir()
  local cwd = vim.fn.getcwd()

  -- 1) hawk-namespaced packages
  --    /…/catkin_ws/src/hawk/<proj> → /…/catkin_ws/build/<proj>
  local ws, proj = cwd:match '(.+/catkin_ws_20)/src/hawk/([^/]+)'
  if ws and proj then
    return ws .. '/build/' .. proj
  end

  -- 2) top-level packages
  --    /…/catkin_ws/src/<proj> → /…/catkin_ws/build/<proj>
  local ws2, proj2 = cwd:match '(.+/catkin_ws_20)/src/([^/]+)'
  if ws2 and proj2 then
    return ws2 .. '/build/' .. proj2
  end

  -- 3) fallback: assume you generated it next to your sources
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
  '--cross-file-rename',
  '-j=8',
  '--log=verbose',
}

-- custom root_dir:
--  • first look for compile_commands.json / .git
--  • then detect ROS workspace as above
--  • finally fall back to git ancestor or cwd
local function clangd_root_dir(fname)
  -- a) standard cmake/git lookup
  local root = util.root_pattern('compile_commands.json', '.git')(fname)
  if root then
    return root
  end

  -- b) any catkin_ws package (hawk-namespace or not) is its own project
  local cwd = vim.fn.getcwd()
  if cwd:match '(.+/catkin_ws_20)/src/[^/]+' then
    return cwd
  end

  -- c) finally, fall back to Git ancestor or cwd
  local git_dir = vim.fs.find('.git', { path = fname, upward = true })[1]
  if git_dir then
    return vim.fs.dirname(git_dir)
  end

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
  on_attach = function(client, bufnr)
    -- only map when the LSP client is clangd
    if client.name == 'clangd' then
      local opts = { noremap = true, silent = true, buffer = bufnr, desc = 'C++: Switch between source and header file' }
      vim.keymap.set('n', '<leader>u', '<cmd>ClangdSwitchSourceHeader<CR>', opts)
    end
  end,
}
