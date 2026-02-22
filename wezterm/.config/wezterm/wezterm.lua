-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()
config.automatically_reload_config = true
-- 背景を透過
config.window_background_opacity = 0.7
-- タイトルバーの削除
config.window_decorations = "RESIZE"
-- タブバーの削除
config.hide_tab_bar_if_only_one_tab = true
-- タブバーを常に非表示にしてtmuxステータスの位置ズレを防ぐ
config.enable_tab_bar = false
-- 余白をなくして下端に張り付かせる
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
return config
