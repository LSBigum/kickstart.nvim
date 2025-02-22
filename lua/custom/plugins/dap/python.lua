return {

  require('dap-python').setup 'python3',
  function()
    -- local dap = require 'dap'
    -- dap.configurations.python = {
    --   {
    --     name = 'Launch file',
    --     type = 'debugpy',
    --     request = 'launch',
    --     program = function()
    --       return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    --     end,
    --     cwd = '${workspaceFolder}',
    --     stopOnEntry = false,
    --   },
    -- }
  end,
}
