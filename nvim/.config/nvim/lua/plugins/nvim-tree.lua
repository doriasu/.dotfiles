return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  keys = {
    {mode = "n", "<leader>b", "<cmd>NvimTreeFindFileToggle<CR>", desc = "NvimTreeをトグルする"},
    {
      mode = "n",
      "<leader>m",
      function()
        if vim.bo.filetype == "NvimTree" then
          vim.cmd("wincmd p")
          return
        end
        require("nvim-tree.api").tree.focus()
      end,
      desc = "NvimTreeフォーカス/エディタに戻る",
    },
  },
  config = function()
    local api = require("nvim-tree.api")

    local function resolve_startup_dir()
      local argv = vim.fn.argv()
      local uv = vim.uv or vim.loop

      for _, arg in ipairs(argv) do
        local path = vim.fn.fnamemodify(arg, ":p")
        local stat = uv.fs_stat(path)
        if stat and stat.type == "directory" then
          return path, true
        end
      end

      return vim.fn.getcwd(), false
    end

    local function on_attach(bufnr)
      api.config.mappings.default_on_attach(bufnr)
      pcall(vim.keymap.del, "n", "u", {buffer = bufnr})
    end

    local function remember_tree_width()
      local last_width = nil
      local Event = api.events.Event

      api.events.subscribe(Event.TreeOpen, function()
        if last_width == nil then
          return
        end

        api.tree.resize({ absolute = last_width })
      end)

      api.events.subscribe(Event.TreeClose, function()
        local winid = api.tree.winid()
        if winid == nil or not vim.api.nvim_win_is_valid(winid) then
          return
        end

        last_width = vim.api.nvim_win_get_width(winid)
      end)
    end

    local startup_dir, has_directory_arg = resolve_startup_dir()
    if has_directory_arg then
      vim.cmd.cd(vim.fn.fnameescape(startup_dir))
    end

    require("nvim-tree").setup {
      prefer_startup_root = true,
      hijack_directories = {
        enable = false,
        auto_open = false,
      },
      on_attach = on_attach,
      actions = {
        change_dir = {
          restrict_above_cwd = true,
        },
      },
      git = {
        enable = true,
        ignore = true,
      }
    }

    remember_tree_width()
  end,
}
