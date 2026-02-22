vim.api.nvim_set_var('mapleader', ',')
vim.api.nvim_set_var('maplocalleader', '_')

vim.api.nvim_set_keymap('i', 'jj', '<Esc>', {})
-- buffer move
vim.api.nvim_set_keymap('n','<leader>h','<cmd>bprev<CR>',{})
vim.api.nvim_set_keymap('n','<leader>l','<cmd>bnext<CR>',{})
vim.api.nvim_set_keymap('n','<leader>x','<cmd>bdelete<CR>',{})
-- terminal mode
vim.api.nvim_set_keymap('t', '<Esc>', [[<C-\><C-n>]], {noremap = true})
