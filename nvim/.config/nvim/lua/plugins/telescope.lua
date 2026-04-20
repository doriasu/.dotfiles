local function list_project_files()
  local files

  vim.fn.system({ "git", "rev-parse", "--is-inside-work-tree" })
  if vim.v.shell_error == 0 then
    files = vim.fn.systemlist({
      "git",
      "ls-files",
      "--cached",
      "--others",
      "--exclude-standard",
    })
  else
    files = vim.fn.systemlist({ "rg", "--files" })
  end

  return vim.tbl_filter(function(path)
    return path ~= "" and not path:match("(^|/)node_modules/")
  end, files)
end

local function filter_files_by_glob(files, prompt)
  if prompt == "" then
    return files
  end

  local regex = vim.regex(vim.fn.glob2regpat(prompt))

  local matches = vim.tbl_filter(function(path)
    return regex:match_str(path) ~= nil
  end, files)

  table.sort(matches)

  return matches
end

local function glob_files()
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local make_entry = require("telescope.make_entry")
  local previewers = require("telescope.config").values
  local sorters = require("telescope.sorters")
  local files = list_project_files()

  pickers.new({}, {
    prompt_title = "Glob Files",
    finder = finders.new_dynamic({
      entry_maker = make_entry.gen_from_file({}),
      fn = function(prompt)
        return filter_files_by_glob(files, prompt)
      end,
    }),
    previewer = previewers.file_previewer({}),
    sorter = sorters.empty(),
  }):find()
end

return {
  'nvim-telescope/telescope.nvim',
  tag = '0.1.8',
  dependencies = { 'nvim-lua/plenary.nvim' },
  keys = {
    {
      mode = "n",
      "<leader>ff",
      function()
        local builtin = require("telescope.builtin")
        local ok = pcall(builtin.git_files, { show_untracked = true })
        if not ok then
          builtin.find_files()
        end
      end,
      desc = "git管理ならgit_files、非管理ならfind_files"
    },
    { mode = "n", "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "文字列検索(ripgrep regex)" },
    { mode = "n", "<leader>fG", "<cmd>Telescope live_grep<CR>", desc = "正規表現で内容検索" },
    { mode = "n", "<leader>fr", glob_files, desc = "globでファイル検索" },
    { mode = "n", "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "バッファー検索" },
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
