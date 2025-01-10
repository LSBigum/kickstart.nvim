return {
  'mfussenegger/nvim-dap',
  dependencies = {
    -- Runs preLaunchTask / postDebugTask if present
    { 'stevearc/overseer.nvim', config = true },
    -- Creates a beautiful debugger UI
    'rcarriga/nvim-dap-ui',
    -- Required dependency for nvim-dap-ui
    'nvim-neotest/nvim-nio',
    'theHamsta/nvim-dap-virtual-text',
  },
  keys = {
    {
      '<leader>dB',
      function()
        require('dap').list_breakpoints()
      end,
      desc = 'DAP Breakpoints',
    },
    {
      '<leader>da',
      function()
        local widgets = require 'dap.ui.widgets'
        widgets.centered_float(widgets.scopes, { border = 'rounded' })
      end,
      desc = 'DAP Scopes',
    },
    {
      '<leader>db',
      function()
        require('dap').toggle_breakpoint()
      end,
      desc = 'Debug: Toggle Breakpoint',
    },
    {
      '<F1>',
      function()
        require('dap.ui.widgets').hover(nil, { border = 'rounded' })
      end,
      desc = 'DAP Hover',
    },
    { '<F2>', '<CMD>DapContinue<CR>', desc = 'DAP Continue' },
    { '<F3>', '<CMD>DapStepOver<CR>', desc = 'Step Over' },
    { '<F4>', '<CMD>DapStepInto<CR>', desc = 'Step Into' },
    { '<F5>', '<CMD>DapStepOut<CR>', desc = 'Step Out' },
    {
      '<F6>',
      function()
        require('dap').run_to_cursor()
      end,
      desc = 'Run to Cursor',
    },
    { '<F7>', '<CMD>DapToggleBreakpoint<CR>', desc = 'Toggle Breakpoint' },
    {
      '<F10>',
      function()
        require('dap').run_last()
      end,
      desc = 'Run Last',
    },
    {
      '<F11>',
      function()
        vim.ui.input({ prompt = 'Breakpoint condition: ' }, function(input)
          require('dap').set_breakpoint(input)
        end)
      end,
      desc = 'Conditional Breakpoint',
    },
    { '<F12>', '<CMD>DapTerminate<CR>', desc = 'DAP Terminate' },
    {
      '<A-r>',
      function()
        require('dap').repl.toggle(nil, 'tab split')
      end,
      desc = 'Toggle DAP REPL',
    },
    {
      '<leader>dq',
      function()
        require('dapui').close()
      end,
      desc = 'Close debug interface',
    },
    {
      '<leader>do',
      function()
        require('dapui').open()
      end,
      desc = 'Open debug interface',
    },
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    -- Signs
    for _, group in pairs {
      'DapBreakpoint',
      'DapBreakpointCondition',
      'DapBreakpointRejected',
      'DapLogPoint',
    } do
      vim.fn.sign_define(group, { text = '●', texthl = group })
    end

    -- Setup

    -- Decides when and how to jump when stopping at a breakpoint
    -- The order matters!
    --
    -- (1) If the line with the breakpoint is visible, don't jump at all
    -- (2) If the buffer is opened in a tab, jump to it instead
    -- (3) Else, create a new tab with the buffer
    --
    -- This avoid unnecessary jumps
    dap.defaults.fallback.switchbuf = 'usevisible,usetab,newtab'

    -- Set exception breakpoint
    dap.defaults.fallback.exception_breakpoints = { 'Notice', 'Warning', 'Error', 'Exception' }

    -- Adapters
    -- C, C++, Rust
    require 'custom.plugins.dap.codelldb'
    require('dap.ext.vscode').load_launchjs()

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup {
      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    }

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    -- dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    -- dap.listeners.before.event_exited['dapui_config'] = dapui.close

    require('nvim-dap-virtual-text').setup()
  end,
}
