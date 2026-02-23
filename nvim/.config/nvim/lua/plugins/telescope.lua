return {
  'nvim-telescope/telescope.nvim',
  tag = '0.1.8',
  dependencies = { 'nvim-lua/plenary.nvim' },
  keys = {
    {
      mode = "n",
      "<leader>f",
      function()
        local builtin = require("telescope.builtin")
        local ok = pcall(builtin.git_files, { show_untracked = true })
        if not ok then
          builtin.find_files()
        end
      end,
      desc = "git管理ならgit_files、非管理ならfind_files"
    },
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
