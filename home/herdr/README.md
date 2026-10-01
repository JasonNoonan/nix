# herdr

[herdr](https://herdr.dev) + [hwt](https://hwt.doriankarter.com) + [vellum](https://vellum.doriankarter.com),
set up to mirror the Supacode workflow. Imported by `home/cyan` and `home/leo`.

| Supacode                                      | herdr                                                         |
| --------------------------------------------- | ------------------------------------------------------------- |
| worktrees in `~/.supacode/repos/<repo>/…`     | `~/.herdr/worktrees/<repo>/<branch>` (`config.toml`)          |
| copy ignored/untracked files on create        | `files.copy` in `hwt.yaml` (deps/_build as APFS clones)        |
| setup script: mise trust/install, mix setup   | `post_create` in `hwt.yaml`                                    |
| `supatally` / `supacode-tally-layout`         | `herdr-tally-layout` (also run by hwt `post_create`)           |
| `supacode-tally` project picker               | `herdr-tally`, bound to `prefix+s` like tmux                   |
| delete branch with worktree                   | `post_remove: git branch -d` (merged branches only)            |
| in-app notifications, system off              | `[ui.toast] delivery = "herdr"`                                |
| terminal theme sync                           | `[theme] name = "terminal"`                                    |

## Keys (prefix is `ctrl+b`, `prefix+?` lists everything)

| Key              | Action                                  |
| ---------------- | --------------------------------------- |
| `ctrl+shift+h/l` | previous / next tab                     |
| `ctrl+shift+k/j` | previous / next space (workspace)       |
| `prefix+space`   | vellum command palette                  |
| `prefix+s`       | pick project → workspace + tally layout |
| `prefix+f`       | vellum workspace finder (`ctrl+a` for actions) |
| `prefix+a`       | vellum agent finder                     |
| `prefix+shift+g` | new configured worktree (hwt)           |
| `prefix+alt+d`   | remove current worktree (hwt)           |
| `prefix+alt+g`   | lazygit popup                           |
| `prefix+t`       | scratch terminal popup                  |

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
