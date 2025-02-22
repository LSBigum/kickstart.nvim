return {
  'NMAC427/guess-indent.nvim', -- Detect tabstop and shiftwidth automatically
  lazy = false,
  config = function()
    require('guess-indent').setup {
      auto_cmd = false,
      filetype_exclude = {
        'diff',
        'gitcommit',
        'gitrebase',
      },
    }
  end,
}
