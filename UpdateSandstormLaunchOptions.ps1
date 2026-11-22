<#PSScriptInfo
.NAME UpdateSandstormLaunchOptions
.VERSION 2.1.0
.AUTHOR Joanna Wick
.TAGS Sandstorm, Mods
.PROJECTURI https://github.com/JoannaWick/Sandstorm_Player_Boot
#>

function ConvertFrom-Vdf {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]]$InputObject
    )

    begin {
        $root = [ordered]@{}
        $stack = [System.Collections.Generic.Stack[object]]::new()
        $stack.Push($root)
        $pendingKey = $null
    }

    process {
        foreach ($line in ($InputObject -split "`r?`n")) {
            $trimmed = $line.Trim()

            if ([string]::IsNullOrWhiteSpace($trimmed) -or $trimmed.StartsWith('//')) {
                continue
            }

            if ($trimmed -eq '{') {
                $newSection = [ordered]@{}
                $current = $stack.Peek()

                if ($null -ne $pendingKey) {
                    if ($current.Contains($pendingKey)) {
                        $current[$pendingKey] = @($current[$pendingKey]) + $newSection
                    } else {
                        $current[$pendingKey] = $newSection
                    }
                    $pendingKey = $null
                }
                $stack.Push($newSection)
            }
            elseif ($trimmed -eq '}') {
                if ($stack.Count -gt 1) {
                    [void]$stack.Pop()
                }
            }
            elseif ($trimmed -match '^"((?:\\.|[^"\\])*)"\s+"((?:\\.|[^"\\])*)"$') {
                $key = $matches[1] -replace '\\"', '"' -replace '\\\\', '\'
                $val = $matches[2] -replace '\\"', '"' -replace '\\\\', '\'
                $current = $stack.Peek()

                if ($current.Contains($key)) {
                    $current[$key] = @($current[$key]) + $val
                } else {
                    $current[$key] = $val
                }
            }
            elseif ($trimmed -match '^"((?:\\.|[^"\\])*)"$') {
                $pendingKey = $matches[1] -replace '\\"', '"' -replace '\\\\', '\'
            }
        }
    }

    end {
        return $root
    }
}

function ConvertTo-Vdf {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.Collections.IDictionary]$InputObject,
        [int]$IndentLevel = 0
    )

    $sb = [System.Text.StringBuilder]::new()
    $indent = "`t" * $IndentLevel

    foreach ($key in $InputObject.Keys) {
        $escapedKey = ($key -replace '\\', '\\') -replace '"', '\"'
        $value = $InputObject[$key]

        $items = if ($value -is [array]) { $value } else { ,$value }

        foreach ($item in $items) {
            if ($item -is [System.Collections.IDictionary]) {
                [void]$sb.AppendLine("$indent`"$escapedKey`"")
                [void]$sb.AppendLine("$indent{")
                [void]$sb.Append((ConvertTo-Vdf -InputObject $item -IndentLevel ($IndentLevel + 1)))
                [void]$sb.AppendLine("$indent}")
            }
            else {
                $escapedVal = ("$item" -replace '\\', '\\') -replace '"', '\"'
                [void]$sb.AppendLine("$indent`"$escapedKey`"`t`t`"$escapedVal`"")
            }
        }
    }

    return $sb.ToString()
}

# --- Execution ---

# Resolve the script's directory (falls back to working directory if run interactively)
$currentDir = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
$batPath = Join-Path -Path $currentDir -ChildPath "Start_Player_Mod_Update.bat"
$prefix = "`"$batPath`" %COMMAND%"

# Detect Steam executable and track whether it is currently running
$steamProc = Get-Process -Name "steam" -ErrorAction SilentlyContinue | Select-Object -First 1
$wasSteamRunning = $null -ne $steamProc

$steamExe = if ($steamProc -and $steamProc.Path) {
    $steamProc.Path
} else {
    $regExe = (Get-ItemProperty -Path "HKCU:\Software\Valve\Steam" -Name "SteamExe" -ErrorAction SilentlyContinue).SteamExe
    if ($regExe) { $regExe -replace '/', '\' }
}

if (-not $steamExe -or -not (Test-Path $steamExe)) {
    $steamExe = "C:\Program Files (x86)\Steam\steam.exe"
}
$steamDir = Split-Path -Path $steamExe -Parent

# Locate localconfig.vdf
$vdfFile = Get-ChildItem -Path "$steamDir\userdata\*\config\localconfig.vdf" -ErrorAction SilentlyContinue | Select-Object -First 1

if (-not $vdfFile) {
    Write-Error "Could not find localconfig.vdf under $steamDir\userdata"
    exit 1
}

# Stop Steam only if it was running
if ($wasSteamRunning) {
    Write-Host "Stopping Steam...`n"
    Stop-Process -Name "steam" -Force -ErrorAction SilentlyContinue
    Wait-Process -Name "steam" -Timeout 15 -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 3
}

try {
    # Create a backup before modifying
    Copy-Item -Path $vdfFile.FullName -Destination "$($vdfFile.FullName).bak" -Force

    # Parse the VDF file
    $vdf = Get-Content -Path $vdfFile.FullName -Raw -Encoding UTF8 | ConvertFrom-Vdf

    # Safely traverse or create UserLocalConfigStore -> Software -> Valve -> Steam -> apps
    $currentNode = $vdf
    foreach ($segment in @("UserLocalConfigStore", "Software", "Valve", "Steam", "apps")) {
        if (-not $currentNode.Contains($segment)) {
            $currentNode[$segment] = [ordered]@{}
        }
        $currentNode = $currentNode[$segment]
    }

    $appId = "581320"

    if (-not $currentNode.Contains($appId)) {
        $currentNode[$appId] = [ordered]@{}
    }

    $oldLaunchOptions = if ($currentNode[$appId].Contains("LaunchOptions")) {
        $currentNode[$appId]["LaunchOptions"].Trim()
    } else {
        ""
    }

    if ([string]::IsNullOrWhiteSpace($oldLaunchOptions)) {
        $currentNode[$appId]["LaunchOptions"] = $prefix
        $modified = $true
    }
    elseif ($oldLaunchOptions -notlike "$prefix*") {
        $currentNode[$appId]["LaunchOptions"] = "$prefix $oldLaunchOptions"
        $modified = $true
    }
    else {
        Write-Host "LaunchOptions already starts with the specified prefix. No file changes needed.`n"
        $modified = $false
    }

    # Serialize and save back as UTF-8 without BOM
    if ($modified) {
        $updatedContent = ConvertTo-Vdf -InputObject $vdf
        $utf8NoBom = [System.Text.UTF8Encoding]::new($false)
        [System.IO.File]::WriteAllText($vdfFile.FullName, $updatedContent, $utf8NoBom)
        Write-Host "Updated LaunchOptions to: $($currentNode[$appId]['LaunchOptions'])`n"
    }
}
finally {
    # Restart Steam only if it was running prior to the script
    if ($wasSteamRunning -and (Test-Path $steamExe)) {
        Write-Host "Restarting Steam...`n"
        Start-Process -FilePath $steamExe -ArgumentList "-silent"
    }
}

Write-Host "Update Complete.  Script will now run when Steam Launches Sandstorm.`n"
pause