return {
  "vim-test/vim-test",
  keys = {
    { "<leader>sn", "<cmd>TestNearest<CR>", desc = "Test nearest" },
    { "<leader>sf", "<cmd>TestFile<CR>", desc = "Test file" },
    { "<leader>sl", "<cmd>TestLast<CR>", desc = "Test last" },
    { "<leader>sv", "<cmd>TestVisit<CR>", desc = "Test visit" },
  },
  config = function()
    vim.g["test#strategy"] = "neovim"
    vim.g["test#neovim#term_position"] = "botright 15"
    vim.g["test#ruby#rspec#executable"] = "docker compose exec -T app bundle exec rspec"
  end,
}
