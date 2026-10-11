# VS Code fresh-box setup

Follow these steps in order on a new machine with default VS Code.
For daily use after setup, see `WORKFLOW.md`.

## 1. Install VS Code

Install VS Code on the machine where you sit (the "local" side). On Windows, this is the
Windows install. WSL and SSH windows are remote windows of this one install.

## 2. Copy the settings files

Close VS Code first. Copy `settings.json` and `keybindings.json` from this folder into
the VS Code user folder. Replace the files that are there.

| Local OS | User folder                                   |
|----------|-----------------------------------------------|
| Windows  | `%APPDATA%\Code\User`                         |
| Linux    | `~/.config/Code/User`                         |
| macOS    | `~/Library/Application Support/Code/User`     |

From WSL, for a Windows install:

    U=/mnt/c/Users/<name>/AppData/Roaming/Code/User
    cp ~/workspace/dotfiles/vscode/settings.json ~/workspace/dotfiles/vscode/keybindings.json "$U/"

Remote windows (WSL, SSH) read these local files. Do not copy them to the remote side.

## 3. Install extensions

Open the Extensions view (`Ctrl+Shift+X`) and install each one.
Or use the commands in `WORKFLOW.md`, section "Install commands".

Local side (Windows):

| Extension ID                      | Use                          |
|-----------------------------------|------------------------------|
| `ms-vscode-remote.remote-wsl`     | WSL windows                  |
| `ms-vscode-remote.remote-ssh`     | SSH windows                  |
| `ms-vscode-remote.remote-ssh-edit`| SSH config editing           |
| `ms-vscode.remote-explorer`       | Remote host list             |
| `vscodevim.vim`                   | Vim keys                     |
| `tomoki1207.pdf`                  | PDF viewer                   |
| `ms-vscode.live-server`           | HTML Live Preview            |

Each WSL or SSH host (use the "Install in ..." button on first use):

| Extension ID                      | Use                          |
|-----------------------------------|------------------------------|
| `tomoki1207.pdf`                  | PDF viewer                   |
| `ms-vscode.live-server`           | HTML Live Preview            |
| `damianedwards.file-change-follower` | Optional. WSL only.       |

Claude Code (`anthropic.claude-code`): optional. Claude runs in the terminal, so the
extension is only for IDE features (`/ide`). It is disabled on the current box.

## 4. Disable two built-in extensions

This step is manual. The CLI cannot do it.

1. Open the Extensions view.
2. Type `@builtin` in the search box.
3. Open **HTML Language Features**. Click **Disable**.
4. Open **JSON Language Features**. Click **Disable**.

Do this in each window type you use (local, each WSL, each SSH host). Check with
`Developer: Show Running Extensions` that no language server is listed.

## 5. Edit host-specific settings

Open `settings.json` (`Ctrl+,`, then the file icon at the top right). Check these keys.
They came from the first box.

| Key                                   | Action                                            |
|---------------------------------------|---------------------------------------------------|
| `remote.SSH.remotePlatform`           | Not in the repo copy. Add it if you use SSH hosts |
| `optimusMonitor.graphWindowSeconds`   | Delete. It belongs to an extension not installed  |
| `markdown-preview-enhanced.*`         | Delete. That extension is not installed           |
| `claudeCode.*`                        | Keep only if you install the Claude Code extension|
| `workbench.colorTheme`                | Not set. Choose one with `Ctrl+K Ctrl+T`          |

Keep the rest of the file as it is.

## 6. Check it works

1. Run `code <project_dir>` from a shell. A window opens with no Activity Bar and no Status Bar.
2. Press `Alt+Shift+G`. Three empty groups appear (left top, left bottom, right).
3. Press `Alt+Right`. Press `Ctrl+Shift+``. A terminal opens on the right.
4. Click a file in Explorer. It opens in the top-left group, not as a new split.
5. Open a `.md` file and a `.pdf` file. They show as a preview.

If a step fails, see `WORKFLOW.md`, section "Problems".

## 7. Keep the copy current

After you change a setting on a box, copy the live file back into this folder, then commit:

    cp "$U/settings.json" "$U/keybindings.json" ~/workspace/dotfiles/vscode/
