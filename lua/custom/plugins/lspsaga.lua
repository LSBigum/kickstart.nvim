return {
  'nvimdev/lspsaga.nvim',
  dependencies = {
    'nvim-treesitter/nvim-treesitter', -- optional
    'nvim-tree/nvim-web-devicons', -- optional
  },
  event = 'LspAttach',
  keys = {
    { 'K', '<cmd>Lspsaga hover_doc<CR>', desc = 'Lspsaga: Hover Doc' },
  },
  opts = {},
}
