-- lua/plugins/jupyter.lua
return {
  {
    "benlubas/molten-nvim",
    lazy = false,
    build = ":UpdateRemotePlugins",
    init = function()
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_auto_open_output = false
    end,
    keys = {
      { "<leader>ji", ":MoltenInit<cr>", desc = "Init kernel" },
      { "<leader>jl", ":MoltenEvaluateLine<cr>", desc = "Eval line" },
      { "<leader>jr", ":MoltenReevaluateCell<cr>", desc = "Re-eval cell" },
      { "<leader>jv", ":<C-u>MoltenEvaluateVisual<cr>gv", mode = "v", desc = "Eval selection" },
      { "<leader>jo", ":MoltenShowOutput<cr>", desc = "Show output" },
    },
  },
  { "3rd/image.nvim", opts = { backend = "kitty" } },
  {
    "GCBallesteros/jupytext.nvim",
    opts = {
      style = "percent",
      output_extension = "py",
      jupytext = vim.fn.expand("~/.venvs/nvim/bin/jupytext"),
    },
  },
}
