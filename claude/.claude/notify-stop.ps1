Add-Type @'
using System;
using System.Runtime.InteropServices;
public class Fg {
  [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
  [DllImport("user32.dll")] public static extern int GetWindowThreadProcessId(IntPtr hWnd, out int pid);
}
'@

$hwnd = [Fg]::GetForegroundWindow()
$procId = 0
[Fg]::GetWindowThreadProcessId($hwnd, [ref]$procId) | Out-Null
$proc = (Get-Process -Id $procId -ErrorAction SilentlyContinue).ProcessName

# Skip notification if VS Code or Windows Terminal already has focus.
if ($proc -eq 'Code' -or $proc -eq 'WindowsTerminal') { exit 0 }

[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType=WindowsRuntime] | Out-Null
[Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType=WindowsRuntime] | Out-Null
$xml = New-Object Windows.Data.Xml.Dom.XmlDocument
$xml.LoadXml('<toast><visual><binding template="ToastText01"><text>Turn complete</text></binding></visual><audio silent="true" /></toast>')
[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier('ClaudeCode.Notifier').Show([Windows.UI.Notifications.ToastNotification]::new($xml))
