-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- lua/config/options.lua (overwrites defaults)
vim.opt.autowrite = false
vim.g.snacks_animate = false

-- Support for copying to clipboard from remote
if vim.env.SSH_TTY then
  local osc52 = require("vim.ui.clipboard.osc52")
  vim.g.clipboard = {
    name = "osc52-copy-only",
    copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
    paste = {
      ["+"] = function()
        return vim.fn.getreg('"', 1, true), vim.fn.getregtype('"')
      end,
      ["*"] = function()
        return vim.fn.getreg('"', 1, true), vim.fn.getregtype('"')
      end,
    },
  }
end

-- Always draw a separator line between windows, including under the last one
vim.opt.laststatus = 3
vim.opt.fillchars:append({ vert = "┃", horiz = "━", horizup = "┻", horizdown = "┳", vertleft = "┫", vertright = "┣", verthoriz = "╋" })
