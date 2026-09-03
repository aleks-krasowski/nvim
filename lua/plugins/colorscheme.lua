return {
  -- add embark
  {
    "embark-theme/vim",
    name = "embark", -- appear as embard instead of vim
    lazy = false,
    priority = 1000, -- high prio such that errors use theme
  },

  -- Configure LazyVim to load embark
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "embark",
    },
  },
}
