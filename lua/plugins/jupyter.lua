-- lua/plugins/jupyter.lua

-- Host venv: needs pynvim, jupyter_client, cairosvg, pnglatex, plotly, jupytext.
local NVIM_VENV = vim.fn.expand("~/.venvs/nvim")

if not vim.g.python3_host_prog then
  local py = NVIM_VENV .. "/bin/python"
  if vim.fn.executable(py) == 1 then
    vim.g.python3_host_prog = py
  else
    vim.notify("jupyter.lua: " .. py .. " not found; python3_host_prog left unset", vim.log.levels.WARN)
    vim.notify(
      "Please create a venv with 'pynvim, jupyter_client, cairosvg, pnglatex, plotly, jupytext' installed",
      vim.log.levels.WARN
    )
  end
end

---------------------------------------------------------------------------
-- `# %%` cell helpers (hydrogen / jupytext percent format)
---------------------------------------------------------------------------
local function is_marker(l)
  return l:match("^# %%%%") ~= nil
end

-- All marker line numbers (1-based) in the current buffer.
local function markers()
  local out = {}
  for i, l in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
    if is_marker(l) then
      out[#out + 1] = i
    end
  end
  return out
end

-- Body ranges {s, e} of every cell, in order (text before the first marker is skipped).
local function cells()
  local ms = markers()
  local last = vim.api.nvim_buf_line_count(0)
  local out = {}
  for i, m in ipairs(ms) do
    local e = (ms[i + 1] or last + 1) - 1
    if m + 1 <= e then
      out[#out + 1] = { m + 1, e }
    end
  end
  return out
end

-- Body range (excluding the marker line) of the cell containing `line`.
local function cell_bounds(line)
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local s, e = line, line + 1
  while s > 1 and not is_marker(lines[s]) do
    s = s - 1
  end
  if is_marker(lines[s]) then
    s = s + 1
  end
  while e <= #lines and not is_marker(lines[e]) do
    e = e + 1
  end
  return s, e - 1
end

local function eval_range(s, e)
  if s <= e then
    vim.fn.MoltenEvaluateRange(s, e)
  end
end

local function run_cell()
  eval_range(cell_bounds(vim.api.nvim_win_get_cursor(0)[1]))
end

-- Evaluate every cell for which pred(cell, cursor_line) is true, one Molten cell each.
local function run_cells(pred)
  local cur = vim.api.nvim_win_get_cursor(0)[1]
  for _, c in ipairs(cells()) do
    if pred(c, cur) then
      eval_range(c[1], c[2])
    end
  end
end

local function run_all()
  run_cells(function()
    return true
  end)
end

local function run_above()
  run_cells(function(c, cur)
    return c[2] < cur - 1
  end)
end

local function run_below()
  run_cells(function(c, cur)
    return c[2] >= cur
  end)
end

local function next_cell()
  local cur = vim.api.nvim_win_get_cursor(0)[1]
  for _, m in ipairs(markers()) do
    if m > cur then
      vim.api.nvim_win_set_cursor(0, { math.min(m + 1, vim.api.nvim_buf_line_count(0)), 0 })
      return
    end
  end
end

local function prev_cell()
  local cur = vim.api.nvim_win_get_cursor(0)[1]
  local ms = markers()
  -- marker of the current cell
  local own
  for _, m in ipairs(ms) do
    if m < cur then
      own = m
    end
  end
  -- if we're already at the top of a cell, jump to the previous one
  if own and own == cur - 1 then
    local prev
    for _, m in ipairs(ms) do
      if m < own then
        prev = m
      end
    end
    own = prev
  end
  if own then
    vim.api.nvim_win_set_cursor(0, { own + 1, 0 })
  end
end

local function run_cell_and_next()
  run_cell()
  next_cell()
end

-- Insert a new cell. kind = "code" | "markdown", where = "below" | "above".
local function insert_cell(kind, where)
  local cur = vim.api.nvim_win_get_cursor(0)[1]
  local s, e = cell_bounds(cur)
  local header = kind == "markdown" and "# %% [markdown]" or "# %%"
  local body = kind == "markdown" and "# " or ""
  local at = where == "above" and (s - 1) or e -- 0-based insert position
  if at < 0 then
    at = 0
  end
  vim.api.nvim_buf_set_lines(0, at, at, false, { header, body, "" })
  vim.api.nvim_win_set_cursor(0, { at + 2, #body })
  vim.cmd("startinsert!")
end

---------------------------------------------------------------------------
return {
  -- Molten: allows running Jupyter notebooks from within Neovim,
  -- with support for inline output and cell navigation.
  {
    "benlubas/molten-nvim",
    lazy = false,
    build = ":UpdateRemotePlugins",
    init = function()
      vim.g.molten_image_provider = "snacks.nvim"
      -- outputs as virtual lines under the cell; float only on demand
      vim.g.molten_virt_text_output = true
      vim.g.molten_virt_lines_off_by_1 = false
      vim.g.molten_virt_text_max_lines = 20
      vim.g.molten_auto_open_output = false
      vim.g.molten_output_win_max_height = 20
    end,
    keys = {
      -- kernel
      { "<leader>ji", ":lcd %:h | MoltenInit<cr>", desc = "Init kernel (cwd = notebook dir)" },
      { "<leader>jx", ":MoltenInterrupt<cr>", desc = "Interrupt kernel" },
      { "<leader>jR", ":MoltenRestart!<cr>", desc = "Restart kernel" },
      -- evaluate
      { "<leader>jj", run_cell, desc = "Eval cell" },
      { "<leader>jn", run_cell_and_next, desc = "Eval cell and go to next" },
      { "<leader>ja", run_all, desc = "Eval all cells" },
      { "<leader>jk", run_above, desc = "Eval all cells above" },
      { "<leader>jJ", run_below, desc = "Eval this cell and all below" },
      { "<leader>jl", ":MoltenEvaluateLine<cr>", desc = "Eval line" },
      { "<leader>jr", ":MoltenReevaluateCell<cr>", desc = "Re-eval cell" },
      { "<leader>jv", ":<C-u>MoltenEvaluateVisual<cr>gv", mode = "v", desc = "Eval selection" },
      -- navigate
      { "]j", next_cell, ft = "python", desc = "Next cell" },
      { "[j", prev_cell, ft = "python", desc = "Previous cell" },
      -- edit
      {
        "<leader>jb",
        function()
          insert_cell("code", "below")
        end,
        desc = "New code cell below",
      },
      {
        "<leader>jB",
        function()
          insert_cell("code", "above")
        end,
        desc = "New code cell above",
      },
      {
        "<leader>jm",
        function()
          insert_cell("markdown", "below")
        end,
        desc = "New markdown cell below",
      },
      {
        "<leader>jM",
        function()
          insert_cell("markdown", "above")
        end,
        desc = "New markdown cell above",
      },
      -- output
      { "<leader>jo", ":MoltenShowOutput<cr>", desc = "Show output" },
      { "<leader>je", ":noautocmd MoltenEnterOutput<cr>", desc = "Enter output (copy/scroll)" },
      { "<leader>jd", ":MoltenDelete<cr>", desc = "Delete cell output" },
    },
  },
  -- Rendering of jupyter notebooks as markdown files, with support for hydrogen-style `# %%` cells.
  {
    "GCBallesteros/jupytext.nvim",
    init = function()
      -- Monkey-patch for deprecated function in health check
      -- upstream health.lua uses the nvim-0.12-removed report_* API and ignores the configured binary
      package.preload["jupytext.health"] = function()
        return {
          check = function()
            vim.health.start("jupytext.nvim")
            local bin = require("jupytext").config.jupytext or "jupytext"
            vim.fn.system({ bin, "--version" })
            if vim.v.shell_error == 0 then
              vim.health.ok("jupytext found: " .. bin)
            else
              vim.health.error("jupytext not runnable: " .. bin, "pip install jupytext into the host venv")
            end
          end,
        }
      end
    end,
    opts = {
      style = "hydrogen",
      output_extension = "auto",
      jupytext = NVIM_VENV .. "/bin/jupytext",
    },
  },
}
