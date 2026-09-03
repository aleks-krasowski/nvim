-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
--
-- Automatically pull current config from github
local cfg = vim.fn.stdpath("config")
local stamp = vim.fn.stdpath("cache") .. "/config-pull-stamp"

local function hours_since_pull()
  local st = vim.uv.fs_stat(stamp)
  return st and (os.time() - st.mtime.sec) / 3600 or math.huge
end

local function auto_pull()
  if hours_since_pull() < 6 then
    return
  end
  local script = table.concat({
    "cd " .. vim.fn.shellescape(cfg),
    '[ -z "$(git status --porcelain)" ] || exit 3', -- dirty tree: leave it alone
    "old=$(git rev-parse HEAD)",
    "git pull -q --ff-only || exit 1",
    '[ "$old" != "$(git rev-parse HEAD)" ] && echo changed',
    "exit 0",
  }, " && ")
  vim.system({ "sh", "-c", script }, { text = true, timeout = 15000 }, function(res)
    vim.schedule(function()
      if res.code == 3 then
        return
      elseif res.code ~= 0 then
        vim.notify("nvim config: pull failed\n" .. (res.stderr or ""), vim.log.levels.WARN)
        return
      end
      vim.fn.writefile({}, stamp)
      if res.stdout:find("changed") then
        require("lazy").restore({ show = false }) -- sync plugins to the new lazy-lock.json
        vim.notify("nvim config updated — restart to apply", vim.log.levels.INFO)
      end
    end)
  end)
end

vim.api.nvim_create_autocmd("VimEnter", { once = true, callback = auto_pull })
