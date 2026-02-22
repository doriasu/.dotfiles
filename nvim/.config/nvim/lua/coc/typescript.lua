local M = {}

local DENO_ROOT_MARKERS = { "deno.json", "deno.jsonc", "deno.lock", "import_map.json" }
local TS_JS_FILETYPES = {
  javascript = true,
  javascriptreact = true,
  typescript = true,
  typescriptreact = true,
}
local SOURCE_FIX_KINDS = {
  { "source.fixAll.eslint" },
  { "source.fixAll.ts", "source.fixAll.typescript" },
}

local function has_deno_marker(start_path)
  local root = vim.fs.find(DENO_ROOT_MARKERS, { upward = true, path = start_path })[1]
  return root ~= nil
end

local function deno_search_paths(bufnr)
  local paths = {}
  local file_path = vim.api.nvim_buf_get_name(bufnr)
  if file_path ~= "" then
    table.insert(paths, vim.fs.dirname(file_path))
  end

  local cwd = vim.fn.getcwd()
  if cwd ~= "" then
    table.insert(paths, cwd)
  end

  return paths
end

function M.is_deno_project(bufnr)
  for _, path in ipairs(deno_search_paths(bufnr)) do
    if has_deno_marker(path) then
      return true
    end
  end

  return false
end

function M.apply_deno_buffer_overrides(bufnr)
  vim.b[bufnr].coc_disable_autoformat = M.is_deno_project(bufnr) and 1 or 0
end

function M.setup_deno_buffer_overrides()
  local function apply_overrides(args)
    M.apply_deno_buffer_overrides(args.buf)
  end

  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
    pattern = "*",
    callback = apply_overrides,
  })
end

function M.is_ts_js_filetype(filetype)
  return TS_JS_FILETYPES[filetype] == true
end

local function select_preferred_action(actions)
  for _, action in ipairs(actions) do
    if action.isPreferred then
      return action
    end
  end

  return actions[1]
end

local function apply_preferred_source_action(kinds)
  local ok_actions, actions = pcall(vim.fn.CocAction, "codeActions", "", kinds)
  if not ok_actions or not vim.islist(actions) or #actions == 0 then
    return false
  end

  local selected = select_preferred_action(actions)
  local ok_apply = pcall(vim.fn.CocAction, "doCodeAction", selected)
  return ok_apply
end

function M.apply_ts_js_source_fixes(bufnr)
  if not M.is_ts_js_filetype(vim.bo[bufnr].filetype) then
    return
  end

  for _, kinds in ipairs(SOURCE_FIX_KINDS) do
    apply_preferred_source_action(kinds)
  end
end

return M
