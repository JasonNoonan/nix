# herdr

[herdr](https://herdr.dev) + [hwt](https://hwt.doriankarter.com) + [vellum](https://vellum.doriankarter.com),
set up to mirror the Supacode workflow. Imported by `home/cyan` and `home/leo`.

| Supacode                                      | herdr                                                         |
| --------------------------------------------- | ------------------------------------------------------------- |
| worktrees in `~/.supacode/repos/<repo>/…`     | `~/.herdr/worktrees/<repo>/<branch>` (`config.toml`)          |
| copy ignored/untracked files on create        | `files.copy` in `hwt.yaml` (deps/_build as APFS clones)        |
| setup script: mise trust/install, mix setup   | `post_create` in `hwt.yaml`                                    |
| `supatally` / `supacode-tally-layout`         | `herdr-tally-layout` (also run by hwt `post_create`)           |
| `supacode-tally` project picker               | `hally`, bound to `prefix+shift+o`                             |
| delete branch with worktree                   | `post_remove: git branch -d` (merged branches only)            |
| in-app notifications, system off              | `[ui.toast] delivery = "herdr"`                                |
| terminal theme sync                           | `[theme] name = "terminal"`                                    |

## Keys (prefix is `ctrl+space`, `prefix+?` lists everything)

Direct, no prefix (`ctrl+alt` is free in Ghostty and leaves nvim's `ctrl+h/j/k/l` alone):

| Key                     | Action                          |
| ----------------------- | ------------------------------- |
| `ctrl+alt+h/j/k/l`      | focus pane                      |
| `ctrl+alt+shift+h/j/k/l`| resize pane                     |
| `ctrl+alt+o`            | last pane (also `prefix+;`)     |
| `ctrl+alt+z`            | zoom pane                       |
| `ctrl+alt+[` / `]`      | previous / next tab             |
| `ctrl+alt+1..9`         | jump to tab                     |
| `ctrl+alt+u` / `d`      | previous / next workspace       |

Prefix, vim `ctrl+w`-style (Herdr defaults otherwise, e.g. `c` new tab, `n/p` tabs,
`shift+h/j/k/l` swap panes, `r` resize mode, `[` copy mode, `g` goto):

| Key                  | Action                                         |
| -------------------- | ---------------------------------------------- |
| `prefix+v`           | split side by side (`:vsplit`)                 |
| `prefix+s` / `-`     | split stacked (`:split`)                       |
| `prefix+q` / `x`     | close pane                                     |
| `prefix+d`           | detach                                         |
| `prefix+,`           | settings                                       |
| `prefix+space`       | vellum command palette                         |
| `prefix+shift+o`     | pick project → workspace + tally layout        |
| `prefix+f`           | vellum workspace finder (`ctrl+a` for actions) |
| `prefix+a`           | vellum agent finder                            |
| `prefix+shift+g`     | new configured worktree (hwt)                  |
| `prefix+alt+d`       | remove current worktree (hwt)                  |
| `prefix+alt+g`       | lazygit popup                                  |
| `prefix+t`           | scratch terminal popup                         |

## One-time setup per machine

After `handshake`:

```sh
mise install                       # herdr, hwt, vlm from mise/conf.d/herdr.toml
herdr integration install claude   # Claude hooks for session restore (edits ~/.claude/settings.json)
hwt plugin install                 # "New configured worktree" / "Remove current worktree" actions
vlm palettes sync                  # official herdr-workspaces / herdr-agents / files palettes
```

Upgrade later with `mise upgrade herdr github:dkarter/hwt github:dkarter/vellum`,
then `hwt plugin update`.
