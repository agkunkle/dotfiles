# VS Code project layout checklist

Use this when you open a project. One VS Code window holds one project.
Settings and keys come from `settings.json` and `keybindings.json` in this folder.

## Layout

    +----------+----------+
    | NW       |          |
    | viewer   |  E       |
    +----------+  tall    |
    | SW       |  Claude  |
    | shell    |          |
    +----------+----------+

- NW: files only. Explorer clicks open a preview tab here. Never put a terminal here.
- E and SW: terminals. VS Code locks a group when a terminal opens in it.

## Steps

1. Run `code <project_dir>`.
2. Press `Alt+Shift+G`. This creates the three empty groups.
3. Press `Alt+Right` to focus E. Press `Ctrl+Shift+``. Run `claude`.
4. Press `Alt+Left`, then `Alt+Down` to focus SW. Press `Ctrl+Shift+``. Use it for misc commands.
5. Click files in Explorer. They open in NW.

## Keys

| Key               | Action                                          |
|-------------------|-------------------------------------------------|
| `Alt+Shift+G`     | Rebuild the three-group grid                    |
| `Alt+Arrows`      | Move focus between groups                       |
| `Ctrl+Shift+``    | New terminal (opens in the active editor group) |
| `Ctrl+J`          | Show or hide the bottom/right panel             |
| `Ctrl+Shift+/`    | Maximize the panel                              |

## File types

| Type     | Behavior                                                       |
|----------|----------------------------------------------------------------|
| `.md`    | Opens in the built-in preview (`workbench.editorAssociations`) |
| `.pdf`   | Opens in the PDF viewer (`tomoki1207.pdf`)                     |
| Image    | Built-in image viewer                                          |
| `.html`  | Opens as source. Use the Live Preview button (`ms-vscode.live-server`) |
| Raw `.md`| Use "Reopen Editor With..." and choose the text editor         |

## Per-project color theme

By default the theme is a user setting (`workbench.colorTheme`). It applies to every
project. To give one project its own theme, set it in that project's
`.vscode/settings.json`:

    { "workbench.colorTheme": "<exact theme name from Ctrl+K Ctrl+T>" }

- The file lives in the project folder. For a WSL or SSH project, it is on the remote side.
  It is not part of this dotfiles repo.
- After the setting exists in the project file, the theme picker should write new choices
  there. This is not tested. Check it once in a real window.
- To keep the file out of the project's git history, add `.vscode/` to the project's
  `.git/info/exclude`. Commit it instead if you want to share the theme.
- `workbench.colorCustomizations` works the same way, for example an accent color per
  project. The Peacock extension (`johnpapa.vscode-peacock`) automates this. It is not installed.
- No theme is set in the user settings now. New projects use the VS Code default.

## Hidden bars

`settings.json` hides the Activity Bar (`workbench.activityBar.location: "hidden"`) and
the Status Bar (`workbench.statusBar.visible: false`). Keys are Windows defaults, from
memory. Remove those two settings to bring the bars back for good.

Activity Bar (left icon strip):

| You lost                  | How to get it                          |
|---------------------------|----------------------------------------|
| Explorer                  | `Ctrl+Shift+E`                         |
| Search                    | `Ctrl+Shift+F`                         |
| Source Control            | Off. `git.enabled` is `false` (see Lean setup) |
| Run and Debug             | `Ctrl+Shift+D`                         |
| Extensions                | `Ctrl+Shift+X`                         |
| Settings gear             | `Ctrl+,`                               |
| Anything else             | Command Palette: `Ctrl+Shift+P` or `F1` |
| Show or hide the side bar | `Ctrl+B`                               |

Status Bar (bottom strip):

| You lost                      | How to get it                                                   |
|-------------------------------|-----------------------------------------------------------------|
| Host and connection           | The window title shows it, such as `workspace [WSL: Ubuntu-22.04]`. For the remote menu, open the Command Palette and type `Remote`. |
| Git branch and sync           | Git is off in VS Code. Run `git branch --show-current` in a terminal. |
| Error and warning counts      | `Ctrl+Shift+M` (Problems view)                                  |
| Line and column               | `Ctrl+G` (Go to Line) shows the current line                    |
| Language, encoding, EOL       | Command Palette: `Change Language Mode`, `Change File Encoding`, `Change End of Line Sequence` |
| Notification bell             | Command Palette: `Notifications: Toggle Notifications Center`   |
| Vim mode text                 | Hidden if `vscodevim` shows it only in the Status Bar           |
| Extension status items        | Look in the extension's own view or Command Palette             |

To see both bars for one session, run `View: Toggle Status Bar Visibility` and
`View: Toggle Activity Bar Visibility` from the Command Palette.

Other UI settings in `settings.json`: no command center, no layout controls, no minimap,
no breadcrumbs, compact tab height, `workbench.editor.showTabs: "single"`.
`window.title` stays `${rootName}`. It already includes the remote name.

## Problems

- **Clicking a file splits NW.** NW is locked. Click its lock icon, or run
  `View: Unlock Editor Group`. This happens when a terminal opens while NW is active.
- **A group closed or the grid looks wrong.** Press `Alt+Shift+G` again.
  `workbench.editor.closeEmptyGroups` is `false`, so empty groups should stay.
- **Terminals vanished after a reload.** Editor-area terminals can lose their sessions
  on window reload. A running Claude session ends. There is no tmux in this setup.
- **Alt+Arrows do nothing in the shell.** VS Code handles these keys first
  (`commandsToSkipShell`). Word jumps in the shell use `Ctrl+Left` and `Ctrl+Right`.

## Extensions to install on each host

Install these in the Windows window and in each WSL or SSH window:
`tomoki1207.pdf`, `ms-vscode.live-server`. VS Code offers an "Install in ..." button
on first use in a remote window.

## Install commands

Run these from a WSL shell. Replace `<name>` with your Windows user name.
Use `--list-extensions` instead of `--install-extension` to check what is installed.
These commands were tested on WSL (Ubuntu) with the Windows VS Code user install.

WSL side (the VS Code Server):

    S=$(ls -d ~/.vscode-server/bin/*/bin/code-server | head -1)
    "$S" --install-extension tomoki1207.pdf --install-extension ms-vscode.live-server

Windows side:

    U=<name>
    D="/mnt/c/Users/$U/AppData/Local/Programs/Microsoft VS Code"
    J=$(wslpath -w "$(ls -d "$D"/*/resources/app/out/cli.js | head -1)")
    cd /mnt/c/Users/$U
    ELECTRON_RUN_AS_NODE=1 WSLENV=ELECTRON_RUN_AS_NODE "$D/Code.exe" "$J" \
      --install-extension tomoki1207.pdf --install-extension ms-vscode.live-server

Why not plain `code`:

- In a WSL shell outside a VS Code terminal, `code` points at a stale session socket
  and fails with `ENOENT ... vscode-ipc-....sock`. `code-server` does not need a session.
- `code.cmd` fails in WSL. Bash runs it as a script (`@echo: not found`), and `cmd.exe /c`
  fails on the space in `Microsoft VS Code`. The commands above copy what `code.cmd` does.
- Pass a Windows path (`wslpath -w`) to `Code.exe`. A WSL path gives `MODULE_NOT_FOUND`.
- A VS Code update changes the hash folder under the install directory. The `*` glob
  handles that.

SSH hosts: not tested. In an SSH window, a terminal `code --install-extension <id>`
should work. Or use the "Install in SSH: <host>" button.

Not installed: `markdown-preview-enhanced`. `settings.json` has options for it, but
the built-in Markdown preview is what `*.md` uses now.

## Lean setup

Goal: several VS Code windows on one box, used only as a Claude host and a file
navigator/viewer. No code indexing, no language servers, no git.

Before this change, two WSL windows ran a 681 MB file watcher, two HTML language
servers (217 and 184 MB), and JSON and Markdown servers (about 60 to 80 MB each).
After disabling the HTML and JSON features, no language-server processes were running
and the WSL VS Code server used about 750 MB. Some of the drop may come from closing
windows, so measure again with the same windows open.

What was turned off:

| Area                  | Change                                                                  |
|-----------------------|-------------------------------------------------------------------------|
| Telemetry, experiments| `telemetry.telemetryLevel: "off"`, `workbench.enableExperiments: false` |
| Updates               | `extensions.autoUpdate` is `"off"` (VS Code rewrote it from `false`) and `extensions.autoCheckUpdates` is `false`. Update extensions by hand. |
| Git                   | `git.enabled: false`, `git.autofetch: false`, `git.autoRepositoryDetection: false` |
| Task detection        | `npm`, `grunt`, `gulp`, `jake`, and `task` `.autoDetect: "off"`          |
| JSON and TypeScript   | `json.schemaDownload.enable: false`, TypeScript and JavaScript validation off, no type acquisition |
| File watcher          | `files.watcherExclude` for `.venv`, `venv`, `__pycache__`, `build`, `dist`, `target` |
| Editor intelligence   | No suggestions, parameter hints, code lens, lightbulb, occurrence or semantic highlighting |

Uninstalled (Windows): Python, Pylance, Python Environments, cpptools, Prettier, docx
reader, Codex audio, ChatGPT. Uninstalled (WSL): ChatGPT, Markdown PDF, CMake Highlight.
To uninstall, use the install commands above with `--uninstall-extension <id>`.

Still installed: Claude Code, Remote SSH (with SSH Edit and Remote Explorer), Remote WSL,
Live Preview, PDF viewer, Vim (Windows only), File Change Follower (WSL only).

Disabled built-in extensions: HTML Language Features, JSON Language Features. Done in the
UI (Extensions view, search `@builtin`). The CLI cannot do it: `code-server --disable-extension`
does nothing useful, and `code --disable-extension` lasts for one session. The persistent list
is in `%APPDATA%\Code\User\globalStorage\state.vscdb`, key `extensionsIdentifiers/disabled`.
Do not edit that file while VS Code runs.

The other built-ins (CSS, PHP, TypeScript, Emmet, npm, debug, GitHub, authentication,
Merge Conflict, Simple Browser, Terminal Suggest, Notebook, References View, Git) are left on.
They start only when a matching file or action appears. If you open `.ts` or `.js` files,
disable TypeScript Language Features too.

Note: the Claude Code extension is installed but disabled in the Windows profile
(`anthropic.claude-code` is in the disabled list). Claude runs in the terminal, so the
IDE features (`/ide`) are not active. Enable it in the Extensions view if you want them.

To undo: remove the settings above, enable the built-ins in the Extensions view, and
reinstall extensions with the install commands.

To measure: run `Developer: Show Running Extensions` and `Developer: Open Process Explorer`.
On WSL, `ps -eo rss,args | grep .vscode-server` lists server processes.

## Not tested in a real window

Some items were set up without testing: `workbench.editor.autoLockGroups` locking,
the exact placement of terminals in groups, and the PDF viewer and Live Preview
in SSH windows. Fix this file when you find a difference.
