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

      local function normalize_origin_to_https(origin)
        if not origin or origin == "" then
          return nil
        end

        local url = origin:gsub("%s+$", "")

        if url:match("^https?://") then
          return (url:gsub("%.git$", ""))
        end

        local host, path = url:match("^git@([^:]+):(.+)$")
        if host and path then
          return ("https://%s/%s"):format(host, path:gsub("%.git$", ""))
        end

        local user, host2, path2 = url:match("^ssh://([^@]+)@([^/]+)/(.+)$")
        if user and host2 and path2 then
          host2 = host2:gsub(":%d+$", "")
          return ("https://%s/%s"):format(host2, path2:gsub("%.git$", ""))
        end

        return nil
      end

      local function open_url(url)
        if vim.ui and vim.ui.open then
          local ok = pcall(vim.ui.open, url)
          if ok then
            return true
          end
        end

        local cmd
        if vim.fn.has("mac") == 1 then
          cmd = { "open", url }
        elseif vim.fn.has("win32") == 1 then
          cmd = { "cmd", "/c", "start", "", url }
        else
          cmd = { "xdg-open", url }
        end

        local job = vim.fn.jobstart(cmd, { detach = true })
        return job > 0
      end

      local function open_line_commit_on_origin()
        local sha = line_commit_sha()
        if not sha then
          vim.notify("この行のコミットSHAを取得できなかったのだ", vim.log.levels.WARN)
          return
        end

        local status = vim.b[bufnr].gitsigns_status_dict or {}
        local root = status.root
        if not root then
          vim.notify("gitリポジトリのルートを取得できなかったのだ", vim.log.levels.WARN)
          return
        end

        local remote = vim.fn.systemlist({ "git", "-C", root, "remote", "get-url", "origin" })[1]
        if vim.v.shell_error ~= 0 or not remote then
          vim.notify("originのURLを取得できなかったのだ", vim.log.levels.WARN)
          return
        end

        local base_url = normalize_origin_to_https(remote)
        if not base_url then
          vim.notify("origin URLの形式に対応できなかったのだ: " .. remote, vim.log.levels.WARN)
          return
        end

        local commit_url = base_url .. "/commit/" .. sha
        if not open_url(commit_url) then
          vim.notify("ブラウザを開けなかったのだ: " .. commit_url, vim.log.levels.WARN)
        end
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
        vim.cmd("windo setlocal nofoldenable")
      end

      vim.keymap.set("n", "<leader>nv", function()
        show_line_revision(false)
      end, { buffer = bufnr, desc = "diff file at line commit" })

      vim.keymap.set("n", "<leader>nV", function()
        show_line_revision(true)
      end, { buffer = bufnr, desc = "diff file before line commit" })

      vim.keymap.set("n", "<leader>no", function()
        open_line_commit_on_origin()
      end, { buffer = bufnr, desc = "open line commit on origin" })
    end,
  },
}
