return {
  'neoclide/coc.nvim',
  branch = 'release',
  lazy = false,  -- cocは常にロードする必要があるのだ
  config = function()
    local coc_ts = require("coc.typescript")
    coc_ts.setup_deno_buffer_overrides()

    -- Tabキーで次の候補へ移動
    vim.keymap.set("i", "<Tab>", [[coc#pum#visible() ? coc#pum#next(1) : "\<Tab>"]], { expr = true, silent = true })

    -- Shift-Tabキーで前の候補へ移動
    vim.keymap.set("i", "<S-Tab>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<S-Tab>"]], { expr = true, silent = true })

    -- Enterキーで補完を確定（nvim-autopairsとの統合）
    _G.coc_confirm_completion = function()
      if vim.fn['coc#pum#visible']() ~= 0 then
        return vim.fn['coc#pum#confirm']()
      else
        -- nvim-autopairsの機能を手動で呼び出す
        local npairs_ok, npairs = pcall(require, 'nvim-autopairs')
        if npairs_ok then
          return npairs.autopairs_cr()
        else
          return vim.api.nvim_replace_termcodes('<CR>', true, true, true)
        end
      end
    end

    vim.keymap.set("i", "<CR>", "v:lua.coc_confirm_completion()", { expr = true, noremap = true, replace_keycodes = false })

    -- 定義位置なら参照、そうでなければ定義へジャンプする
    _G.coc_jump_def_or_refs = function()
      -- coc.nvim がまだ起動していない/初期化中なら何もしない（RPCエラー回避）
      if vim.fn.exists("*coc#rpc#ready") == 1 and vim.fn["coc#rpc#ready"]() == 0 then
        return
      end

      -- 定義のLocationを取得して「今が定義位置か」を判定
      local ok_defs, defs = pcall(vim.fn.CocAction, "definitions")
      local def_list = {}
      if ok_defs and defs then
        if vim.islist(defs) then
          def_list = defs
        else
          def_list = { defs }
        end
      end

      local cur_pos = vim.api.nvim_win_get_cursor(0)
      local cur_line = cur_pos[1] - 1
      local cur_path = vim.api.nvim_buf_get_name(0)

      -- coc が返す uri/path を現在バッファのパスと比較できる形に正規化
      local function uri_to_path(uri)
        if not uri or uri == "" then
          return nil
        end
        if uri:match("^file://") then
          return vim.uri_to_fname(uri)
        end
        return uri
      end

      -- LSP の range に行が含まれているか判定
      -- Coc が返す character は UTF-16 の可能性があるので、列は比較せず行のみ見る
      local function line_in_range(range, line)
        if not range or not range.start or not range["end"] then
          return false
        end
        local s = range.start
        local e = range["end"]
        if line < s.line or line > e.line then
          return false
        end
        return true
      end

      -- documentSymbols からカーソル位置のシンボルを取る（最小レンジを優先）
      local function get_symbol_at_cursor()
        local ok_syms, syms = pcall(vim.fn.CocAction, "documentSymbols")
        if not ok_syms or not syms then
          return nil
        end

        local flat = {}
        local function flatten(items)
          for _, sym in ipairs(items or {}) do
            table.insert(flat, sym)
            if sym.children then
              flatten(sym.children)
            end
          end
        end
        flatten(syms)

        local best_sym = nil
        local best_span = nil
        for _, sym in ipairs(flat) do
          local r = sym.range or sym.selectionRange
          if r and line_in_range(r, cur_line) then
            local span = (r["end"].line or 0) - (r.start.line or 0)
            if not best_span or span < best_span then
              best_span = span
              best_sym = sym
            end
          end
        end

        return best_sym
      end

      local cur_symbol = get_symbol_at_cursor()

      local on_definition = false
      for _, loc in ipairs(def_list) do
        local uri = loc.uri or loc.targetUri
        local range = loc.range or loc.targetRange or loc.targetSelectionRange
        local def_path = uri_to_path(uri)
        if def_path == cur_path and range then
          if cur_symbol and cur_symbol.range then
            if line_in_range(cur_symbol.range, range.start.line) then
              on_definition = true
              break
            end
          elseif line_in_range(range, cur_line) then
            on_definition = true
            break
          end
        end
      end

      -- 定義位置なら参照へ、そうでなければ定義へ
      if #def_list > 0 then
        if on_definition then
          pcall(vim.fn.CocAction, "jumpReferences")
        else
          pcall(vim.fn.CocAction, "jumpDefinition")
        end
      else
        pcall(vim.fn.CocAction, "jumpReferences")
      end
    end

    -- InsertLeaveイベント（Normalモードに戻ったとき）にフォーマットを実行
    vim.api.nvim_create_autocmd("InsertLeave", {
      pattern = "*",
      callback = function()
        local bufnr = vim.api.nvim_get_current_buf()
        -- 変更がないなら何もしない（無駄なフォーマットを避ける）
        if not vim.bo.modified then
          return
        end
        -- help/terminal/prompt等の特殊バッファでは何もしない
        if vim.bo.buftype ~= "" then
          return
        end
        -- coc.nvim がまだ起動していない/初期化中なら何もしない（RPCエラー回避）
        if vim.fn.exists("*coc#rpc#ready") == 1 and vim.fn["coc#rpc#ready"]() == 0 then
          return
        end

        local function run_format_if_available()
          -- DenoではPrettierを使わず、formatは走らせない
          if coc_ts.is_deno_project(bufnr) then
            return
          end
          local ok_has_provider, has_provider = pcall(vim.fn.CocAction, "hasProvider", "format")
          if ok_has_provider and not (has_provider ~= 0 and has_provider ~= false) then
            return
          end
          pcall(vim.fn.CocAction, "format")
        end

        coc_ts.apply_ts_js_source_fixes(bufnr)
        vim.defer_fn(function()
          if not vim.api.nvim_buf_is_valid(bufnr) then
            return
          end
          if vim.bo[bufnr].buftype ~= "" then
            return
          end
          if vim.fn.exists("*coc#rpc#ready") == 1 and vim.fn["coc#rpc#ready"]() == 0 then
            return
          end
          run_format_if_available()
        end, 250)
      end,
    })
  end,
  keys  = {
    {mode = "n", "<leader>i", "<cmd>lua coc_jump_def_or_refs()<CR>", desc="定義/参照ジャンプ"},
    {mode = "n", "K", "<cmd>call CocActionAsync('doHover')<CR>", desc="ホバー情報表示"}
  }
}
