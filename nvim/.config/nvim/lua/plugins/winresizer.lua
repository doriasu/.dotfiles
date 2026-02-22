return {
  "simeji/winresizer",
  version = "*",
  vim.keymap.set("n", "<leader>[", "<cmd>WinResizerStartResize<CR>", { silent = true, desc = "WinResizer" }),
}
