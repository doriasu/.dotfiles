return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  keys = {
    {mode = "n", "<leader>b", "<cmd>NvimTreeToggle<CR>", desc = "NvimTreeをトグルする"},
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
      local api = require("nvim-tree.api")

      api.config.mappings.default_on_attach(bufnr)
      pcall(vim.keymap.del, "n", "u", {buffer = bufnr})
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
  end,
}
