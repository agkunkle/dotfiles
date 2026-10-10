# dotfiles

Private config backup. One directory per tool ("package"). GNU Stow links
each package into `$HOME`.

## Packages

| Package  | Links to                                                        |
|----------|-----------------------------------------------------------------|
| `claude` | `~/.claude/` (CLAUDE.md, settings.json, hooks, statusline)      |
| `bash`   | `~/.bashrc`                                                     |
| `git`    | `~/.gitconfig`                                                  |

## Install

    sudo apt install stow
    ./install.sh            # all packages
    ./install.sh claude     # one package

Stow refuses to overwrite an existing real file. Move the old file away first.

## Rules

- Never commit credentials, history, or `settings.local.json`. See `.gitignore`.
- `claude/.claude/settings.json` and the hook script hold absolute paths
  (`/home/user/...`). Edit them when the username differs on another machine.
- To add a tool: make `<tool>/` with the same layout as under `$HOME`.
