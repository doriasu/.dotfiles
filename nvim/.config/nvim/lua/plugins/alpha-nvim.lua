return {
  "goolord/alpha-nvim",
  lazy = false,
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local alpha = require("alpha")
    local startify = require("alpha.themes.startify")
    local uv = vim.uv or vim.loop

    -- available: devicons, mini, default is mini
    startify.file_icons.provider = "devicons"
    alpha.setup(startify.config)

    local function startup_mode()
      local argc = vim.fn.argc()
      if argc == 0 then
        return "no_args"
      end

      -- nvim . / nvim <dir> のときは Alpha を表示する
      for _, arg in ipairs(vim.fn.argv()) do
        local path = vim.fn.fnamemodify(arg, ":p")
        local stat = uv.fs_stat(path)
        if not (stat and stat.type == "directory") then
          return "has_files"
        end
      end

      return "dirs_only"
    end

    local function open_alpha_cleanly()
      local cur = vim.api.nvim_get_current_buf()
      local name = vim.api.nvim_buf_get_name(cur)
      local stat = name ~= "" and uv.fs_stat(name) or nil

      -- ディレクトリバッファを1タブ目に残さない
      if stat and stat.type == "directory" then
        vim.cmd("enew")
        pcall(vim.api.nvim_buf_delete, cur, { force = true })
      end

      if vim.bo.filetype ~= "alpha" then
        vim.cmd("Alpha")
      end
    end

    vim.api.nvim_create_autocmd("VimEnter", {
      once = true,
      callback = function()
        local mode = startup_mode()
        if mode == "has_files" then
          return
        end

        if mode == "dirs_only" then
          open_alpha_cleanly()
          return
        end

        vim.defer_fn(open_alpha_cleanly, 30)
      end,
    })

    local cleanup_group = vim.api.nvim_create_augroup("alpha_cleanup_nameless", { clear = true })
    vim.api.nvim_create_autocmd("BufEnter", {
      group = cleanup_group,
      callback = function()
        if vim.bo.filetype == "alpha" then
          return
        end

        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if buf ~= vim.api.nvim_get_current_buf() and vim.api.nvim_buf_is_loaded(buf) then
            local name = vim.api.nvim_buf_get_name(buf)
            local bt = vim.bo[buf].buftype
            local modified = vim.bo[buf].modified
            local line_count = vim.api.nvim_buf_line_count(buf)
            local first_line = line_count > 0 and vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] or ""

            -- Alpha 起動時に残る空の [No Name] バッファだけを対象にする:
            -- 未命名・通常バッファ・未変更・1行のみ・内容が空文字のときに削除する。
            if name == "" and bt == "" and not modified and line_count == 1 and first_line == "" then
              if vim.fn.bufwinnr(buf) == -1 then
                pcall(vim.api.nvim_buf_delete, buf, { force = true })
              end
            end
          end
        end
      end,
    })
  end
}
