---
name: ari-dotfile--submodule-tmux-oneshot
description: Work on tmux-oneshot, the public repo behind `tmux-oneshot` (a command menu for tmux — JSON entries picked with fzf in a popup and run), its test suite, its package and its standalone flake. The repo is a dotfiles dev repo, a plain clone at ~/dotfiles/.config/tmux-oneshot (linked to ~/.config/tmux-oneshot) whose package.nix the shared Nix flake builds and places at ~/.config/bin/tmux-oneshot. Use when editing bin/tmux-oneshot, its tests, package.nix or the repo's flake, or when ~/.config/bin/tmux-oneshot lacks a change. The menu entries are the dotfiles' files, not this repo's; commits, pushes and the flake.lock bump follow ari-dotfile--submodule.
---

# tmux-oneshot in the dotfiles

tmux-oneshot holds one zsh bin, `bin/tmux-oneshot`, its suite under `test/`,
the `package.nix` that installs it and a standalone `flake.nix`. The dotfiles
build that package with their own shell library and place the bin at
`~/.config/bin/tmux-oneshot`, which the `<Prefix> C-k` popup and Hyper+O run.
The repo is a dotfiles *dev repo*: `/ari-dotfile--submodule` has what every dev
repo shares (`main`, identity, commits, Ari's push and the lock bump it makes,
the generic failures); this skill has what is tmux-oneshot's. The entry schema
is the comment at the top of `bin/tmux-oneshot`: edit that comment in the same
commit as any schema change, and never restate the schema here.

## Rules

- **`~/.config/bin/tmux-oneshot` is a commit, never the working tree.** It is the store build of the checkout's HEAD at the last `dotfiles switch`, pushed or not. **NEVER copy, link or write anything into `~/.config/bin`**; to update it, commit (step 4) and switch (step 5). An uncommitted edit runs only from the checkout (step 2).
- **A menu entry is a dotfiles commit, never one here.** The entries live outside this repo (§ Where the menu comes from); ask Ari "every machine or this one?" when his request does not say.
- **The library default.** Every `source` line in `bin/tmux-oneshot` MUST read `source "${ARI_ZSHLIB:-${HOME}/.config/zsh/plugins}/<file>.zsh"`, character for character: `package.nix`'s `libDefault` rewrites exactly that string to the store's `zshlib` with `--replace-fail`. NEVER write `.config/zsh/plugins` anywhere else in the bin, comments included: the install check fails on any survivor. **Check** does not catch either mistake; the package build in step 3 does.
  ```
  BAD:  source ~/.config/zsh/plugins/fzf_group.zsh                         # Check passes; the build fails
  GOOD: source "${ARI_ZSHLIB:-${HOME}/.config/zsh/plugins}/fzf_group.zsh"
  ```
- **Library files live in the dotfiles.** The bin sources the files in `package.nix`'s install-check loop (`for f in log.zsh …`).
  - Edit them at `~/dotfiles/.config/zsh/plugins/` per `/ari-dotfiles`, NEVER in `~/dotfiles/.config/ari-zshlib` (a mirror: `/ari-dotfile--submodule` § Mirrors). An edit reaches every packaged bin that sources the file: name them to Ari before the commit (`/ari-dotfiles-nix` § Change a file, item 3).
  - A new file, in order: the file, its place on the `install` line of `nix/pkgs/ari-zshlib/default.nix` and on the mirror's `watch` (`/ari-dotfiles-nix` § Ari's packages, Copied sources), one df commit; then the `source` line and the install-check loop entry here, one commit; then switch. The standalone flake sees the file only after Ari's push exports the mirror (§ When it fails).
- **No hooks, no bootstrap step, no denylist.** An empty `core.hooksPath` is correct: leave it empty and NEVER run `dotfiles apply` to set it. Leave the missing denylist out of any report. With no hook, step 4's branch, identity, author and company-content checks are yours.
- **Claude NEVER pushes**: no `git push`, no `dotfiles push` (`/ari-dotfile--submodule` § Pushing).

## Reference

### Layout

`~/dotfiles/.config/tmux-oneshot` and `~/.config/tmux-oneshot` are one directory; commands below use `~/.config/tmux-oneshot`.

| Piece | Path |
|---|---|
| Checkout (public) | upstream `github.com/AriSweedler/tmux-oneshot`; ignored by `~/dotfiles/.gitignore`; `[repo ".config/tmux-oneshot"]`, `input = tmux-oneshot` in `~/dotfiles/.config/dotfiles/dev-repos` |
| Bin | `bin/tmux-oneshot` (zsh; its top comment is the entry schema and the source tiers) |
| Tests | `test/run` (the repo check), `test/tmux_oneshot.test.zsh` (the suite) |
| Package | `package.nix`: takes `zshlib`, installs the bin, pins the library default (§ Rules), runs an install check |
| Standalone flake | `flake.nix`, `flake.lock`: `packages.default` from `package.nix` with `github:AriSweedler/ari-zshlib`, locked |
| Docs | `README.md` (install, a tmux binding, where to read more) |
| This skill | `skills/ari-dotfile--submodule-tmux-oneshot/`, linked into `~/.claude/skills` by `nix/claude-skills.nix` at the switch after its commit |

### Where the menu comes from

The bin's top comment has the tiers and their merge order. Who writes each:

| Tier | Edit | Live after |
|---|---|---|
| shared (every machine) | `~/dotfiles/.config/tmux_oneshot/<file>.json`, a `git df` commit (`/ari-dotfiles`) | a switch: `nix/tmux-oneshot.nix` merges it into `~/.config/tmux_oneshot/entries.json`; duplicate direct keys fail the switch |
| this machine | the local flake's `programs.tmuxOneshot.entries` or `.files` (`/ari-dotfiles-nix`), or `~/.local/share/tmux_oneshot/*.json` (`/ari-dotfiles`, ldf) | a switch; the JSON file at once |
| generated | `~/dotfiles/.config/zsh/plugins/oneshot_group.zsh` and its callers, never the JSON in `$XDG_STATE_HOME/tmux_oneshot/generated/` | the next shell |

| Ari says | Where |
|---|---|
| "make `caffeinate` autodismiss" | its entry in `~/dotfiles/.config/tmux_oneshot/macos.json`: a df commit |
| "a shadowed leaf loses its group header" | `bin/tmux-oneshot` and a suite case: a commit here |
| "entries need a `confirm` field" | the bin, its top comment and a suite case: a schema change here |

### The build

- `~/dotfiles/.config/dotfiles/nix/pkgs/default.nix` builds `"${devInputs.tmux-oneshot}/package.nix"` with `zshlib = self.ari_zshlib`; `ari-bins.nix` places the bin at `~/.config/bin/tmux-oneshot` (`/ari-dotfiles-nix` § Ari's packages).
- `dotfiles switch` builds the checkout's HEAD and locks the `tmux-oneshot` input at it in `~/.local/share/dotfiles/nix/flake.lock`; when that lock moves, and why a locked rev there does not prove the build landed: `/ari-dotfile--submodule` § How the build and the lock follow the checkout.
- A host without Nix gets no `tmux-oneshot` from the dotfiles.

### Check

`zsh ~/.config/tmux-oneshot/test/run` runs the suite against the checkout's `bin/tmux-oneshot`. Green is exit 0 and these last two lines; anything else is red:

```
[INFO] … tmux_oneshot: all <n> passed
[OK] tmux-oneshot: the suite passed
```

Red ends `tmux_oneshot: <p> passed, <f> failed` and `[FAIL] tmux-oneshot: the suite failed`; the first `FAIL: <name>` line names the failing assertion. A source error before any assertion is the environment, not the code: `command -v jq` must succeed, and with no `~/.config/zsh/plugins` re-run with `ARI_ZSHLIB=~/dotfiles/.config/ari-zshlib/lib`.

- **The placed copy:** `TMUX_ONESHOT_BIN=~/.config/bin/tmux-oneshot zsh ~/.config/tmux-oneshot/test/run`.
- **The package:** `nix build --no-link path:$HOME/dotfiles/.config/tmux-oneshot` builds the working tree (untracked files included) with the locked mirror and runs the install check.

## Workflow

### Change tmux-oneshot

1. **Edit** under `bin/`, `test/`, `package.nix` or `flake.nix`. If you add, remove or change the meaning of an entry field, you MUST update the bin's top comment in the same commit, and grep the files `--files` lists for entries the change alters: name them to Ari, and change them only as separate dotfiles commits.
2. **Try it** from the working tree, against a scratch state directory, so the live `index.json` cache and the popup's `log.txt` stay untouched:
   ```zsh
   s=$(mktemp -d /tmp/tmux-oneshot-try.XXXXXX); print -r -- '[{"cmd": "echo hello", "menu": {"name": "hi"}}]' > "$s/db.json"
   XDG_STATE_HOME="$s" TMUX_ONESHOT_DB="$s/db.json" zsh ~/.config/tmux-oneshot/bin/tmux-oneshot --dry-run hi    # … cmd=echo hello
   ```
   Put the field under test in the scratch entry. Against Ari's real entries, drop `TMUX_ONESHOT_DB` and add `TMUX_ONESHOT_DIRS=~/.local/state/tmux_oneshot/generated` (the generated tier) to `XDG_STATE_HOME="$s"` (`--list`, `--debug`). **NEVER run `tmux display-popup`, `tmux send-keys` or the bare picker yourself**: hand Ari `tmux display-popup -E -w 80% -h 60% 'XDG_STATE_HOME=<s> zsh ~/.config/tmux-oneshot/bin/tmux-oneshot'` as an interactive run link per `/ari-driving-tmux` (pass `--interactive`: fzf is not auto-detected). `C-k` runs the last switched commit, not the edit.
3. **Check** (§ Check), and the package build too when the edit touched `package.nix`, `flake.nix` or a `source` line. Red → fix and re-run; two fixes that do not clear it → stop and show Ari the first failing assertion, what you changed, and the choices: keep debugging, `git -C ~/.config/tmux-oneshot restore <files>`, or leave the edits uncommitted for him.
4. **Commit**, per `/ari-dotfile--submodule` § Working in one, in this order:
   1. `git -C ~/.config/tmux-oneshot branch --show-current` prints `main`, and `git -C ~/.config/tmux-oneshot config --local user.email` prints `ari@sweedler.com`.
   2. `git -C ~/.config/tmux-oneshot add <every file you edited in step 1>`, never `-A` or `.`: the switch builds HEAD, so an unstaged file is not in the build.
   3. `git -C ~/.config/tmux-oneshot diff --cached --quiet` exits 0 → nothing to commit; skip to step 7.
   4. **MUST read `git -C ~/.config/tmux-oneshot diff --cached` and the message for company hostnames, ids, ticket numbers or colleagues**; remove any and re-stage.
   5. Commit as `type(scope): subject`. Types: `feat`, `fix`, `test`, `build`, `docs`, `refactor`. Scope, by the commit's purpose: `tmux-oneshot` (the bin), `test`, `nix` (package.nix, flake.nix, flake.lock), `readme` or `skills`. E.g. `fix(tmux-oneshot): keep the group header when a leaf is shadowed`, `build(nix): pin ari-zshlib with fzf_groups.zsh`. The repo's first commits predate this form; do not copy them.
   6. `git -C ~/.config/tmux-oneshot log -1 --format='%an <%ae> %cn <%ce>'` prints `Ari Sweedler <ari@sweedler.com>` twice, and `git -C ~/.config/tmux-oneshot status --porcelain -- bin test package.nix` prints nothing. Else stop and show Ari; never amend unasked.
5. **Switch** per `/ari-dotfiles-nix` § Switch when the commit touched `bin/`, `package.nix` or `skills/`; a commit of only `README.md`, `test/`, `flake.nix` or `flake.lock` needs none. First record `prev=$(jq -er '.nodes["tmux-oneshot"].locked.rev' ~/.local/share/dotfiles/nix/flake.lock)`.
6. **Placed check**, after a switch for `bin/` or `package.nix`: § Check, the placed copy. Red → the live menu is broken: stop and tell Ari the failing assertion and `git -C ~/.config/tmux-oneshot log --oneline <prev>..HEAD`, with the choices: fix forward (steps 1–5), `git -C ~/.config/tmux-oneshot revert --no-edit <prev>..HEAD` and switch (a revert commit his push publishes), or leave it live and debug.
7. **Report** in one line: the commit `<sha> <subject>` or "nothing to commit", Check, the switch (done, or not needed and why) and the placed check. Only when `git -C ~/.config/tmux-oneshot status -sb` shows `ahead`, add "Run `dotfiles push` when ready." per `/ari-dotfile--submodule` § Pushing. **Do not push.**

### Set up a machine

```zsh
dotfiles apply dotfiles_repo                       # clones the checkout; ~/dotfiles/.config/tmux-oneshot/.git must exist after
git -C ~/.config/tmux-oneshot config user.name "Ari Sweedler"
git -C ~/.config/tmux-oneshot config user.email ari@sweedler.com
dotfiles switch                                    # per /ari-dotfiles-nix § Switch; then § Check, the placed copy
```

The two `config` lines are yours on each machine (`/ari-dotfile--submodule` § Layout contract, the packaged repo). Switch again whenever a pull moves the checkout.

## When it fails

Generic rows (detached HEAD, push log lines, lock-bump refusals, drift from the shared lock): `/ari-dotfile--submodule` § When it fails.

| symptom | cause | do |
|---|---|---|
| healthcheck `fail dotfiles_repo submodule_undocumented ~/.claude/skills lacks ari-dotfile--submodule-tmux-oneshot …` | this skill uncommitted, or committed after the last switch | committed → switch: `nix/claude-skills.nix` makes the link. Uncommitted → `/ari-skill-update ari-dotfile--submodule-tmux-oneshot` commits it, and its record step needs the link first: run the healthcheck's `link` fix line, which the next switch replaces (delete any `.before-nix` backup it leaves in `~/.claude/skills`) |
| `~/.config/bin/tmux-oneshot` lacks a change | uncommitted, committed after the last switch, a failed switch, or a stale cache | `jq -er '.nodes["tmux-oneshot"].locked.rev' ~/.local/share/dotfiles/nix/flake.lock` against `git -C ~/.config/tmux-oneshot rev-parse HEAD`: differ → commit or switch. Equal → the lock moved but the switch may not have landed (`--build` alone, a failed build, a cancelled sudo): read the last switch's error, fix it, switch. Equal after a good switch → `~/.config/bin/tmux-oneshot --debug` rebuilds the cache. HEAD behind the locked rev → the checkout was reset: show Ari `git -C ~/.config/tmux-oneshot log --oneline HEAD..<locked rev>` and ask before moving `main` |
| an entry is missing or wrong in the menu | the entry files, not the bin | § Where the menu comes from: edit, commit and switch; `~/.config/bin/tmux-oneshot --files` and `--debug` show what loaded |
| `substituteStream() in derivation tmux-oneshot-0: ERROR: pattern … doesn't match anything` | the library default changed without `libDefault` | update `libDefault` in `package.nix` (§ Rules, The library default) |
| the build fails in `installCheckPhase`: `ari-zshlib lacks <file>` or `the bin still names a live library path` | a library file not in the package, or `.config/zsh/plugins` written outside a `source` line | § Rules, Library files live in the dotfiles; or The library default |
| the standalone build's bin cannot source a library file | `flake.lock` pins a mirror older than the file | only once `git -C ~/dotfiles/.config/ari-zshlib ls-tree --name-only origin/main lib/<file>` prints the file (else tell Ari it waits on his push): `/ari-dotfile--submodule` § Mirrors, Consumers, then commit `flake.lock` as `build(nix): …`. Fails twice → leave `flake.lock` alone and tell Ari |
| the checkout's bin or `test/run` fails sourcing `log.zsh` or another library file | no `~/.config/zsh/plugins` on this machine | `ARI_ZSHLIB=~/dotfiles/.config/ari-zshlib/lib` before the command (read-only use of the mirror) |
| a popup run failed and closed before its error showed | stderr went to the popup's run log | `~/.config/bin/tmux-oneshot --log`, before any try without a scratch `XDG_STATE_HOME`; rotated copies are `~/.local/state/tmux_oneshot/log.txt.bak.1`…`4` |
