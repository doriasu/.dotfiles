return {
  "tpope/vim-rails",
  -- Rails コマンドを現在バッファでも確実に初期化させるため、
  -- キー押下時ロードではなく Ruby 系ファイルで先に読み込むのだ。
  ft = { "ruby", "eruby" },
  config = function()
    vim.g.rails_projections = {
      ["lib/*.rb"] = {
        alternate = "spec/lib/{}_spec.rb",
        test = "spec/lib/{}_spec.rb",
      },
      ["spec/lib/*_spec.rb"] = {
        alternate = "lib/{}.rb",
      },
    }

    -- Rails バッファが有効化されたときだけ <leader>sa を定義するのだ。
    -- ここで定義すると :AE の buffer-local command と寿命が揃うのだ。
    vim.api.nvim_create_autocmd("User", {
      pattern = "Rails",
      callback = function(args)
        vim.keymap.set("n", "<leader>sa", "<cmd>AE<CR>", {
          buffer = args.buf,
          silent = true,
          desc = "Move rails alternative file",
        })
      end,
    })
  end,
}
