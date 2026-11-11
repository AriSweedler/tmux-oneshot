# tmux-oneshot

A command menu for tmux. You list commands in JSON files; `tmux-oneshot` shows them in an fzf
picker inside a tmux popup and runs the one you pick. An entry can have a direct key, ask for a
value, build its arguments from groups, flags and subcommands, and run in the popup, in a
throwaway pane you can scroll, or in a window of its own.

```zsh
mkdir -p ~/.config/tmux_oneshot
echo '[{"cmd": "killall Dock", "description": "restart the Dock", "key": "ctrl-d"}]' \
  > ~/.config/tmux_oneshot/macos.json
nix run github:AriSweedler/tmux-oneshot -- --list      # killall Dock
```

Bind it to a key in `tmux.conf`:

```
bind-key C-k display-popup -E -w 80% -h 60% -d "#{pane_current_path}" tmux-oneshot
```

Install: `nix profile install github:AriSweedler/tmux-oneshot`. It needs `jq`, `fzf` and `tmux`
on PATH.

| Read | For |
|---|---|
| `tmux-oneshot --help` | the options, and the surfaces a command can run on |
| the comment at the top of `bin/tmux-oneshot` | the entry schema and where entry files are read from |
| `tmux-oneshot --debug` | a check of every source file, the menu and the direct keys |
| `tmux-oneshot --log` | the stderr of the last run (a popup closes before you can read it) |

`test/run` runs the suite against the checkout and ends in one `[OK]` line.

`tmux-oneshot` reads its shell library from
[ari-zshlib](https://github.com/AriSweedler/ari-zshlib); the Nix package pins it. Without Nix,
set `ARI_ZSHLIB` to that repo's `lib` directory.
