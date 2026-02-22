-- vim.api.nvim_set_option('tgc', true)
vim.api.nvim_set_option('scrolloff', 4)
-- 検索
vim.api.nvim_set_option('ignorecase', true)
vim.api.nvim_set_option('smartcase', true)
-- 置換
vim.api.nvim_set_option('inccommand', 'split')
-- clipboard
vim.opt.clipboard:append 'unnamedplus'

-- window api
vim.api.nvim_win_set_option(0, 'number', true)
vim.api.nvim_win_set_option(0, 'cursorline', true)
vim.opt.splitright = true
-- コードの外側を何行許容するか
vim.api.nvim_win_set_option(0, 'signcolumn', 'yes:3')
-- 画面幅に合わせて折り返す
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
-- 80(rubocop標準)にワンライン引く
vim.api.nvim_win_set_option(0, 'colorcolumn', '80')
-- bufに入るごとにtab設定を自動実行(起動時しかうまくいかない問題の回避)
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter' }, {
  pattern = '*',
  -- groupを追加する
  group = vim.api.nvim_create_augroup('buffer_set_options', {}),
  callback = function()
    vim.api.nvim_buf_set_option(0, 'tabstop', 2)
    vim.api.nvim_buf_set_option(0, 'shiftwidth', 0)
    vim.api.nvim_buf_set_option(0, 'expandtab', true)
  end,
})
