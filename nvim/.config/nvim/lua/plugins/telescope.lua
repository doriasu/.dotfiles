return {
  'nvim-telescope/telescope.nvim',
  tag = '0.1.8',
  dependencies = { 'nvim-lua/plenary.nvim' },
  keys = {
    { mode = "n", "<leader>f", "<cmd>Telescope git_files<CR>", desc = "gitで管理されているfileをfindする" },
    { mode = "n", "<leader>g", "<cmd>Telescope live_grep<CR>", desc = "文字列検索" }
  },
  config = function()
    require('telescope').setup({
      defaults = {
        file_ignore_patterns = {
          "node_modules/.*"
        }
      },
      pickers = {
        git_files = {
          show_untracked = true
        }
      }
    })
  end
}
