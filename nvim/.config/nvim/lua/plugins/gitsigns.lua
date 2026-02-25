return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    signcolumn = true,
    numhl = false,
    linehl = true,
    current_line_blame = true,
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = "eol",
      delay = 300,
      ignore_whitespace = false,
    },
    current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
    on_attach = function(bufnr)
      local function parse_gitsigns_bufname(name)
        local _, tail = name:match("^gitsigns://(.+)//(.+)$")
        if not tail then
          return nil
        end

        local revision = tail:match("^(:?[^:]+):")
        local relpath = tail:match("^:?[^:]+:(.*)")
        if relpath == "" then
          relpath = nil
        end

        return {
          revision = revision,
          relpath = relpath,
        }
      end

      local function get_blame_target()
        local name = vim.api.nvim_buf_get_name(bufnr)
        local status = vim.b[bufnr].gitsigns_status_dict or {}
        local root = status.root
        local parsed = parse_gitsigns_bufname(name)

        if parsed then
          if not parsed.relpath then
            return nil
          end

          return {
            root = root,
            file = parsed.relpath,
            revision = parsed.revision,
          }
        end

        local file = name
        if root and file:sub(1, #root + 1) == root .. "/" then
          file = file:sub(#root + 2)
        end

        return {
          root = root,
          file = file,
          revision = nil,
        }
      end

      local function same_revision(a, b)
        if not a or not b then
          return false
        end
        if a == b then
          return true
        end
        if not a:match("^%x+$") or not b:match("^%x+$") then
          return false
        end
        return a:sub(1, #b) == b or b:sub(1, #a) == a
      end

      local function line_commit_sha()
        local target = get_blame_target()
        if not target then
          return nil, nil
        end

        local lnum = vim.api.nvim_win_get_cursor(0)[1]
        local cmd = {
          "git",
        }

        if target.root then
          vim.list_extend(cmd, { "-C", target.root })
        end

        vim.list_extend(cmd, {
          "blame",
          "--porcelain",
          "-L",
          ("%d,%d"):format(lnum, lnum),
        })

        if target.revision and not target.revision:match("^:[0-3]$") then
          table.insert(cmd, target.revision)
        end

        vim.list_extend(cmd, { "--", target.file })

        local out = vim.fn.systemlist(cmd)

        if vim.v.shell_error ~= 0 then
          return nil, nil
        end

        local first = out[1] or ""
        local sha = first:match("^(%x+)")
        if not sha or sha == string.rep("0", 40) then
          return nil, nil
        end
        return sha, target.revision
      end

      local function show_line_revision(parent)
        local sha, current_revision = line_commit_sha()
        if not sha then
          vim.notify("この行のコミットSHAを取得できなかったのだ", vim.log.levels.WARN)
          return
        end

        if parent or same_revision(sha, current_revision) then
          sha = sha .. "^"
        end

        if vim.wo.diff then
          vim.cmd("silent! diffoff!")
        end
        vim.cmd("Gitsigns diffthis " .. sha)
      end

      vim.keymap.set("n", "<leader>nv", function()
        show_line_revision(false)
      end, { buffer = bufnr, desc = "diff file at line commit" })

      vim.keymap.set("n", "<leader>nV", function()
        show_line_revision(true)
      end, { buffer = bufnr, desc = "diff file before line commit" })
    end,
  },
}
