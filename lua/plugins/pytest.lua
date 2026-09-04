-- Fix: neotest doesn't pick up the local .venv automatically
return {
  {
    "nvim-neotest/neotest",
    opts = {
      adapters = {
        ["neotest-python"] = {
          runner = "pytest",
          python = function(root)
            local venv = vim.env.VIRTUAL_ENV or (root .. "/.venv")
            return venv .. "/bin/python"
          end,
        },
      },
    },
  },
}
