return {
  {
    "folke/tokyonight.nvim",
    opts = {
      style = "moon",
      -- Slightly dim inactive windows so the focused one stands out
      dim_inactive = true,
      on_highlights = function(hl, c)
        -- Bright, clearly visible borders between splits
        hl.WinSeparator = { fg = c.blue, bold = true }
        hl.VertSplit = { fg = c.blue, bold = true }
        -- Floating windows (LSP hover, Telescope, etc.) get the same border colour
        hl.FloatBorder = { fg = c.blue, bg = c.bg_float }
      end,
    },
  },
}
