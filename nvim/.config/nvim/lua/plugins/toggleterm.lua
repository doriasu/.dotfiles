return {
  -- amongst your other plugins
  'akinsho/toggleterm.nvim',
  version = "*",
  config = function()
    require("toggleterm").setup {
      size = 100,
      start_in_insert = true,
      direction = 'float',
      close_on_exit = true
    }

    local Terminal = require("toggleterm.terminal").Terminal
    local floating_term = Terminal:new({
      direction = "float",
      count = 1,
      hidden = true,
    })

    local vertical_term = Terminal:new({
      direction = "vertical",
      count = 2,
      hidden = true,
    })

    local horizontal_term = Terminal:new({
      direction = "horizontal",
      count = 3,
      hidden = true,
    })
    local lazygit_term = Terminal:new({
      direction = "float",
      cmd = "lazygit",
      count = 4,
      hidden = true,
    })

    vim.keymap.set({ "n", "t" }, "<leader>t", function()
      floating_term:toggle()
    end, { desc = "Floating terminal" })

    vim.keymap.set({ "n", "t" }, "<leader>%", function()
      vertical_term:toggle()
    end, { desc = "Vertical terminal" })

    vim.keymap.set({ "n", "t" }, '<leader>"', function()
      horizontal_term:toggle()
    end, { desc = "Horizontal terminal" })

    vim.keymap.set({ "n", "t" }, '<leader>lg', function()
      lazygit_term:toggle()
    end, { desc = "lazygit terminal" })
  end,
}
