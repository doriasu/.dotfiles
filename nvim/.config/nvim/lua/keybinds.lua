vim.api.nvim_set_var('mapleader', ',')
vim.api.nvim_set_var('maplocalleader', '_')

local function copy_current_file_path()
  local file_path = vim.fn.expand('%:p')

  if file_path == '' then
    vim.notify('現在のバッファにはファイルパスがないのだ', vim.log.levels.WARN)
    return
  end

  local relative_path = vim.fn.fnamemodify(file_path, ':.')

  vim.fn.setreg('+', relative_path)
  vim.notify('相対パスをクリップボードにコピーしたのだ: ' .. relative_path)
end

vim.api.nvim_set_keymap('i', 'jj', '<Esc>', {})
-- buffer move
vim.api.nvim_set_keymap('n','<leader>h','<cmd>bprev<CR>',{})
vim.api.nvim_set_keymap('n','<leader>l','<cmd>bnext<CR>',{})
vim.api.nvim_set_keymap('n','<leader>x','<cmd>BDelete this<CR>',{})
vim.keymap.set('n', '<leader>cp', copy_current_file_path, { desc = 'Copy current file path' })
-- terminal mode
vim.api.nvim_set_keymap('t', '<C-w>', [[<C-\><C-n>]], {noremap = true})
