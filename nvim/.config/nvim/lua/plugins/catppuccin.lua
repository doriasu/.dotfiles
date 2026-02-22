return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000, -- カラースキームは最初にロードする
  config = function()
    require("catppuccin").setup({
      flavour = "frappe", -- latte, frappe, macchiato, mocha
      transparent_background = true,
      term_colors = true,
      custom_highlights = function()
        return {
          -- 共通フロート
          NormalFloat = { bg = "NONE" },
          FloatBorder = { bg = "NONE" },
          FloatTitle = { bg = "NONE" },

          -- which-key
          WhichKeyNormal = { bg = "NONE" },
          WhichKeyBorder = { bg = "NONE" },

          -- telescope
          TelescopeNormal = { bg = "NONE" },
          TelescopeBorder = { bg = "NONE" },
          TelescopePromptNormal = { bg = "NONE" },
          TelescopePromptBorder = { bg = "NONE" },
          TelescopeResultsNormal = { bg = "NONE" },
          TelescopeResultsBorder = { bg = "NONE" },
          TelescopePreviewNormal = { bg = "NONE" },
          TelescopePreviewBorder = { bg = "NONE" },

          -- split separator (toggleterm vertical/horizontal を含む)
          WinSeparator = { fg = "#ffffff", bg = "NONE", bold = true },
          VertSplit = { fg = "#ffffff", bg = "NONE", bold = true },
        }
      end,
      integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        treesitter = true,
        telescope = {
          enabled = true,
        },
        which_key = true,
      },
    })

    -- カラースキームを適用
    vim.cmd.colorscheme "catppuccin"
  end,
}
