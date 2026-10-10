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

## Not tested in a real window

Some items were set up without testing: `workbench.editor.autoLockGroups` locking,
the exact placement of terminals in groups, and the PDF viewer and Live Preview
in SSH windows. Fix this file when you find a difference.
