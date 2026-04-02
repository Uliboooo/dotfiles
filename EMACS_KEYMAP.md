# Emacs Keymap (Current)

Source: `.config/emacs/init.el`

## Leader key

- Leader: `SPC` (General + Evil states)

## Leader mappings (`SPC ...`)

| Key | Command | Description |
|---|---|---|
| `SPC f` | `consult-fd` | Find files (files only) |
| `SPC /` | `consult-ripgrep` | Grep search |
| `SPC b` | `consult-buffer` | Switch buffer |
| `SPC m` | `consult-mark` | Jump to mark |
| `SPC u` | `undo-tree-visualize` | Undo history |
| `SPC d` | `consult-flymake` | Diagnostics list |
| `SPC s` | `consult-eglot-symbols` | LSP symbols |
| `SPC a` | `eglot-code-actions` | Code actions |
| `SPC r` | `eglot-rename` | Rename symbol |
| `SPC n` | `evil-ex-nohighlight` | Clear search highlight |
| `SPC g` | `magit-status` | Git status |
| `SPC l` | `magit-log-current` | Git log (current) |
| `SPC p` | `diff-hl-show-hunk` | Preview git hunk |
| `SPC x b` | `my/dap-breakpoint-toggle` | Toggle breakpoint (DAP) |
| `SPC x r` | `my/dap-ui-repl` | Open DAP REPL |
| `SPC c` | `evilnc-comment-or-uncomment-lines` | Toggle comment |
| `SPC D` | `my/copy-diagnostic-at-point` | Copy diagnostic message |

## Global / Evil mappings

| Key | Command | Description |
|---|---|---|
| `U` (normal) | `evil-redo` | Redo |
| `>` / `<` (visual) | custom lambda | Indent/outdent and keep selection |
| `g d` (normal) | `xref-find-definitions` | Go to definition |
| `g r` (normal) | `xref-find-references` | Find references |
| `K` (normal) | `eldoc-doc-buffer` | Hover/docs |
| `C-p` (normal) | `diff-hl-show-hunk` | Preview current hunk |
| `]q` / `[q` (normal) | `next-error` / `previous-error` | Quickfix-style nav |
| `]d` / `[d` (normal) | `flymake-goto-next-error` / `flymake-goto-prev-error` | Diagnostic nav |
| `]c` / `[c` (normal) | `diff-hl-next-hunk` / `diff-hl-previous-hunk` | Hunk nav |
| `za` / `zo` / `zc` / `zR` / `zM` | `origami-*` | Fold controls |

## Function keys (DAP wrappers)

| Key | Command |
|---|---|
| `F5` | `my/dap-continue` |
| `F10` | `my/dap-next` |
| `F11` | `my/dap-step-in` |
| `F12` | `my/dap-step-out` |

## Non-Leader bindings from packages

| Key | Command |
|---|---|
| `C-\` | `vterm-toggle` |
| `C-_` | `vterm-toggle-cd` |
| `C-.` | `embark-act` |
| `M-.` | `embark-dwim` |
| `C-h B` | `embark-bindings` |
| `C-x b` | `consult-buffer` |
| `M-g g` | `consult-goto-line` |
| `M-g i` | `consult-imenu` |
| `M-s f` | `consult-fd` |
| `M-s r` | `consult-ripgrep` |
| `M-s l` | `consult-line` |
| `M-i` / `M-n` / `M-p` | `symbol-overlay-put` / `symbol-overlay-jump-next` / `symbol-overlay-jump-prev` |
| `TAB` / `S-TAB` / `RET` (Corfu popup) | next / previous / insert |

## Minibuffer

| Key | Command |
|---|---|
| `Esc` | `keyboard-escape-quit` |

