param
(
    [string]$IPAddress
)

$AppId      = 581320

# game process name (no .exe)
$ProcName   = "InsurgencyClient-Win64-Shipping"   

# key that opens the console
$ConsoleKey = '`'                                  

# How many Milliseconds to delay bewtween long entry for menu and joining server
# Increase this value if console doesn't open or decrease the value if your computer is fast enough
$mainMenuDelay = 2500 # 2.5 seconds

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Import native Windows API to genuinely force focus and handle windows
if (-not ([Ref].Assembly.GetType('Win32.NativeMethods'))) {
    $NativeMethods = @'
    using System;
    using System.Runtime.InteropServices;
    public class NativeMethods {
        [DllImport("user32.dll")]
        public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
        [DllImport("user32.dll")]
        public static extern bool SetForegroundWindow(IntPtr hWnd);
    }
'@
    Add-Type -TypeDefinition $NativeMethods
}

Write-Host "Joining Server @ IP: $IPAddress" -ForegroundColor Green

# WAIT FOR PROCESS TO EXIST
$proc = Get-Process $ProcName -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $proc) {
    Write-Host "Waiting for game process to start..." -ForegroundColor Yellow
    $waited = 0
    while (-not $proc -and $waited -lt 120) {
        Start-Sleep -Seconds 2
        $waited += 2
        $proc = Get-Process $ProcName -ErrorAction SilentlyContinue | Select-Object -First 1
    }
}

# STREAM LOG UNTIL READY
if ($proc) {
    $logPath = "$env:LOCALAPPDATA\Insurgency\Saved\Logs\Insurgency.log"
    $targetString = "LogINSGameInstance: State transition: 'WelcomeScreen' -> 'MainMenu'"
    
    if (Test-Path $logPath) {
        Write-Host "Streaming log until main menu loads..." -ForegroundColor Yellow
        try {
            Get-Content -Path $logPath -Wait -Tail 0 | ForEach-Object {
                if ($_ -like "*$targetString*") {
                    throw "MatchFound" 
                }
            }
        } 
        catch [System.Management.Automation.RuntimeException] {
            if ($_.Exception.Message -ne "MatchFound") { throw $_ }
        }
    } else {
        # Fallback safety if the log file hasn't been generated yet
        Write-Host "Log file not found yet. Applying safety delay..." -ForegroundColor Yellow
        Start-Sleep -Seconds 15
    }
}

# Refresh process object to grab the UI Window Handle
$proc = Get-Process $ProcName -ErrorAction SilentlyContinue | Select-Object -First 1

if ($proc -and $proc.MainWindowHandle -ne [IntPtr]::Zero) { 
    Write-Host "Bringing game window to foreground..." -ForegroundColor Cyan
    # Fixed: Removed the 'Win32.' prefix to match the defined type structure
    [NativeMethods]::ShowWindow($proc.MainWindowHandle, 9) # 9 = Restore/Show
    [NativeMethods]::SetForegroundWindow($proc.MainWindowHandle)
} else { 
    $shell = New-Object -ComObject WScript.Shell
    [void]$shell.AppActivate("Insurgency") 
}

Start-Sleep -Milliseconds $mainMenuDelay  

# CLIPBOARD BUFFERING & INJECTION
$oldClip = Get-Clipboard -Raw -ErrorAction SilentlyContinue
Set-Clipboard -Value "open $IPAddress"
Start-Sleep -Milliseconds 200 # Crucial: Gives the Windows OS time to save the string to clipboard memory

# Open Console -> Paste -> Submit
[System.Windows.Forms.SendKeys]::SendWait($ConsoleKey)
Start-Sleep -Milliseconds 800  
[System.Windows.Forms.SendKeys]::SendWait("^v")
Start-Sleep -Milliseconds 500  
[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")

# RESTORE CLIPBOARD
Start-Sleep -Milliseconds 300
if ($null -ne $oldClip -and $oldClip -ne "") { 
    Set-Clipboard -Value $oldClip 
}


