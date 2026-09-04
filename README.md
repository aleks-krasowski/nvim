# Neovim config

[LazyVim](https://www.lazyvim.org) with a few additions:

- **Jupyter workflow** via [molten-nvim](https://github.com/benlubas/molten-nvim) + [jupytext.nvim](https://github.com/GCBallesteros/jupytext.nvim) (`lua/plugins/jupyter.lua`)
- **Auto-pull** of this config from GitHub on startup, at most every 6 h, only if the tree is clean (`lua/config/autocmds.lua`)
- **OSC52 clipboard** when running over SSH (`lua/config/options.lua`)
- Extras enabled (`lazyvim.json`): copilot, yanky, dap, mini-diff, mini-hipatterns, test, and language support for python, tex, markdown, json, yaml, toml, git

## Setup

```sh
git clone <this repo> ~/.config/nvim
python -m venv ~/.venvs/nvim
~/.venvs/nvim/bin/pip install pynvim jupyter_client ipykernel jupytext cairosvg pnglatex plotly
nvim   # plugins install on first start; then run :UpdateRemotePlugins and :checkhealth
```

Set `$NVIM_VENV` to use a different host venv (e.g. on a cluster).

## Cheat-sheet

Leader is `<Space>`. Press `<Space>` and wait to see all bindings (which-key).

### Moving around (faster than `hjkl`)

| Key                            | Action                                                      |
| ------------------------------ | ----------------------------------------------------------- |
| `<C-d>` / `<C-u>`              | Scroll half a page down / up (cursor moves with it)         |
| `<C-f>` / `<C-b>`              | Scroll a full page down / up                                |
| `zz` / `zt` / `zb`             | Put current line in the center / top / bottom of the window |
| `gg` / `G`                     | Top / bottom of file                                        |
| `42G` or `:42`                 | Go to line 42                                               |
| `w` / `b` / `e`                | Next word / previous word / end of word                     |
| `0` / `^` / `$`                | Line start / first non-blank / line end                     |
| `f{c}` / `t{c}` then `;` / `,` | Jump to / before char in line, repeat forward / back        |
| `s{2 chars}`                   | Flash: jump anywhere on screen by typing 2 chars + label    |
| `S`                            | Flash treesitter: select enclosing syntax node              |
| `{` / `}`                      | Previous / next paragraph (blank line)                      |
| `%`                            | Matching bracket                                            |
| `*` / `#`                      | Search word under cursor forward / backward                 |
| `/text` then `n` / `N`         | Search, next / previous match                               |
| `<C-o>` / `<C-i>`              | Jump back / forward in jump list                            |
| `''` or ` ` ``                 | Back to position before last jump                           |
| `]]` / `[[`                    | Next / previous reference to the word under cursor          |
| `]f` / `[f`                    | Next / previous function (treesitter)                       |
| `]c` / `[c`                    | Next / previous class (treesitter)                          |

### Files & search

| Key                         | Action                     |
| --------------------------- | -------------------------- |
| `<leader><space>`           | Find files (root)          |
| `<leader>ff` / `<leader>fF` | Find files (root / cwd)    |
| `<leader>fr`                | Recent files               |
| `<leader>fb`                | Buffers                    |
| `<leader>e` / `<leader>E`   | File explorer (root / cwd) |
| `<leader>/` or `<leader>sg` | Grep in project            |
| `<leader>sw`                | Grep word under cursor     |
| `<leader>ss`                | Symbols in file (LSP)      |
| `<leader>sk`                | Search keymaps             |
| `<leader>sh`                | Search help                |
| `<leader>,`                 | Switch buffer              |
| `<leader>fn`                | New file                   |

### Buffers, windows, tabs

| Key                                     | Action                 |
| --------------------------------------- | ---------------------- |
| `H` / `L` or `[b` / `]b`                | Previous / next buffer |
| `<leader>bd`                            | Delete buffer          |
| `<leader>bo`                            | Delete other buffers   |
| `<C-h/j/k/l>`                           | Move between windows   |
| `<C-Up/Down/Left/Right>`                | Resize window          |
| `<leader>-` / `<leader>\|`              | Split below / right    |
| `<leader>wd`                            | Close window           |
| `<leader><tab><tab>` / `<leader><tab>d` | New / close tab        |

### Editing

| Key                   | Action                 |
| --------------------- | ---------------------- |
| `<A-j>` / `<A-k>`     | Move line(s) down / up |
| `gcc` / `gc` (visual) | Toggle comment         |
| `<leader>cf`          | Format buffer          |
| `<C-s>`               | Save                   |
| `<leader>p`           | Yank history (yanky)   |
| `<Esc>`               | Clear search highlight |

### Toggles (`<leader>u`)

| Key                         | Action                                 |
| --------------------------- | -------------------------------------- |
| `<leader>ud`                | Toggle diagnostics                     |
| `<leader>uf` / `<leader>uF` | Toggle autoformat (global / buffer)    |
| `<leader>us`                | Toggle spelling                        |
| `<leader>uw`                | Toggle word wrap                       |
| `<leader>ul` / `<leader>uL` | Toggle line numbers / relative numbers |
| `<leader>uh`                | Toggle inlay hints                     |
| `<leader>uc`                | Toggle conceal                         |
| `<leader>uT`                | Toggle treesitter highlight            |
| `<leader>ub`                | Toggle background light / dark         |
| `<leader>ug`                | Toggle indent guides                   |
| `<leader>uD`                | Toggle dim (focus current scope)       |
| `<leader>ua`                | Toggle animations                      |
| `<leader>un`                | Dismiss notifications                  |

### Code (LSP)

| Key                | Action                                         |
| ------------------ | ---------------------------------------------- |
| `gd` / `gr` / `gI` | Go to definition / references / implementation |
| `gy`               | Go to type definition                          |
| `K`                | Hover docs                                     |
| `<leader>ca`       | Code action                                    |
| `<leader>cr`       | Rename symbol                                  |
| `<leader>cd`       | Line diagnostics                               |
| `]d` / `[d`        | Next / previous diagnostic                     |
| `]e` / `[e`        | Next / previous error                          |
| `<leader>xx`       | Diagnostics list (trouble)                     |
| `<leader>cs`       | Symbols outline                                |
| `<leader>cm`       | Mason (install LSP/formatters)                 |

### Git

| Key                           | Action               |
| ----------------------------- | -------------------- |
| `<leader>gg`                  | Lazygit              |
| `<leader>gb`                  | Git blame line       |
| `<leader>gB`                  | Open in browser      |
| `]h` / `[h`                   | Next / previous hunk |
| `<leader>ghs` / `<leader>ghr` | Stage / reset hunk   |
| `<leader>ghp`                 | Preview hunk         |
| `<leader>gl`                  | Git log              |

### Terminal, debugging, tests

| Key                         | Action                     |
| --------------------------- | -------------------------- |
| `<C-/>` or `<leader>ft`     | Toggle terminal            |
| `<leader>db`                | Toggle breakpoint          |
| `<leader>dc`                | Start / continue debugging |
| `<leader>do` / `<leader>di` | Step over / into           |
| `<leader>du`                | Toggle DAP UI              |
| `<leader>tr`                | Run nearest test           |
| `<leader>tt`                | Run file tests             |
| `<leader>ts`                | Test summary               |

### Jupyter (custom, `<leader>j`)

Works on `.ipynb` files (converted on the fly by jupytext) and any `.py` file using `# %%` cell markers.

| Key                         | Action                                    |
| --------------------------- | ----------------------------------------- |
| `<leader>ji`                | Init kernel (cwd set to the notebook dir) |
| `<leader>jx`                | Interrupt kernel                          |
| `<leader>jR`                | Restart kernel                            |
| `<leader>jj`                | Eval current cell                         |
| `<leader>jn`                | Eval cell and go to next                  |
| `<leader>ja`                | Eval all cells                            |
| `<leader>jk`                | Eval all cells above                      |
| `<leader>jJ`                | Eval this cell and all below              |
| `<leader>jl`                | Eval current line                         |
| `<leader>jr`                | Re-eval cell                              |
| `<leader>jv` (visual)       | Eval selection                            |
| `]j` / `[j`                 | Next / previous cell                      |
| `<leader>jb` / `<leader>jB` | New code cell below / above               |
| `<leader>jm` / `<leader>jM` | New markdown cell below / above           |
| `<leader>jo`                | Show output                               |
| `<leader>je`                | Enter output window (scroll / copy)       |
| `<leader>jd`                | Delete cell output                        |

### Plugins & config

| Key / Command  | Action                          |
| -------------- | ------------------------------- |
| `<leader>l`    | Lazy (plugin manager)           |
| `:Lazy sync`   | Update plugins to lock file     |
| `<leader>uC`   | Pick colorscheme                |
| `:checkhealth` | Diagnose setup                  |
| `:LazyExtras`  | Enable / disable LazyVim extras |
