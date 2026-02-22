return {
  'windwp/nvim-autopairs',
  event = "InsertEnter",
  -- cocと衝突するのでcocでenterを制御している
  opts = {
    check_ts = true,
    map_cr = false,  -- Enterキーのマッピングを無効化
    map_bs = true,   -- Backspaceは有効化
    map_c_h = false,
    map_c_w = false,
  }
}
