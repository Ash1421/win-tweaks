#*----------------------------------------------------
#! Ash's Windows Tweaks Manager (PRO)
#*----------------------------------------------------
#* Raw Run:             irm https://raw.githubusercontent.com/Ash1421/win-tweaks/refs/heads/main/tweaks_fzf.ps1 | iex
#*----------------------------------------------------
#* Raw Download & Run:  irm https://raw.githubusercontent.com/Ash1421/win-tweaks/refs/heads/main/tweaks_fzf.ps1 -OutFile "$env:TEMP\tweaks_fzf.ps1"; powershell -ExecutionPolicy Bypass -File "$env:TEMP\tweaks_fzf.ps1"
#*----------------------------------------------------

$script:version = "V4.2.1"
$script:debug = $false  # Set to $true to enable debug output
$script:backup = "$env:TEMP\registry_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').reg"
$script:isAdmin = ([Security.Principal.WindowsPrincipal]::new(
    [Security.Principal.WindowsIdentity]::GetCurrent()
)).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

$script:runAsAdmin = $script:isAdmin

# Debug helper function
function Write-Debug-Info {
    param([string]$Message)
    if ($script:debug) {
        Write-Host "  [DEBUG] $Message" -ForegroundColor Magenta
    }
}

function Get-PowerShellExe {
    # Prefer pwsh 7+ over Windows PowerShell
    if (Get-Command pwsh -ErrorAction SilentlyContinue) {
        return "pwsh"
    }
    return "powershell"
}

if (-not $script:isAdmin) {
    Write-Host ""
    Write-Host "  [!] Some features require Administrator privileges." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Choose an option:" -ForegroundColor Cyan
    Write-Host "  [1] Admin    - Restart with admin rights (all features)" -ForegroundColor Green
    Write-Host "  [2] User     - Continue as user (UI tweaks only)" -ForegroundColor Cyan
    Write-Host "  [3] Cancel   - Exit" -ForegroundColor Red
    Write-Host ""
    $choice = Read-Host "  Select option (1/2/3)"
    
    switch ($choice) {
        "1" {
            Write-Host ""
            Write-Host "  [*] Restarting with elevated rights..." -ForegroundColor Yellow
            Write-Host ""
            Start-Sleep 1
            $psExe = Get-PowerShellExe
            Start-Process $psExe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
            exit
        }
        "2" {
            Write-Host ""
            Write-Host "  [*] Running with user privileges..." -ForegroundColor Yellow
            Write-Host "  [!] Some features will be unavailable" -ForegroundColor Yellow
            Write-Host ""
            Start-Sleep 1
            $script:runAsAdmin = $false
        }
        "3" {
            exit
        }
        default {
            Write-Host "  [!!] Invalid choice. Exiting." -ForegroundColor Red
            exit
        }
    }
}

# ─────────────────────────────────────────────────────────────
# UTILITIES
# ─────────────────────────────────────────────────────────────

function Show-Progress {
    param(
        [string]$Message,
        [int]$Duration = 1
    )
    
    Write-Host " [+] $Message" -ForegroundColor Cyan -NoNewline
    $steps = 20
    for ($i = 0; $i -lt $steps; $i++) {
        Start-Sleep -Milliseconds ($Duration * 1000 / $steps)
        Write-Host "." -ForegroundColor Green -NoNewline
    }
    Write-Host " [" -ForegroundColor White -NoNewline
    Write-Host "OK" -ForegroundColor Green -NoNewline
    Write-Host "]" -ForegroundColor White
}

function Install-Fzf {
    Write-Host " [+] Attempting to install fzf" -ForegroundColor Cyan
    
    # Try winget
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "   [*] Using winget..." -ForegroundColor Yellow
        winget install --id junegunn.fzf --exact --quiet --accept-package-agreements --accept-source-agreements --disable-interactivity 2>&1 | Out-Null
        if ($?) {
            Write-Host "   [" -ForegroundColor White -NoNewline
            Write-Host "OK" -ForegroundColor Green -NoNewline
            Write-Host "] Installed via winget" -ForegroundColor Green
            return $true
        }
    }
    
    # Try choco
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Host "   [*] Using chocolatey..." -ForegroundColor Yellow
        choco install fzf -y 2>&1 | Out-Null
        if ($?) {
            Write-Host "   [" -ForegroundColor White -NoNewline
            Write-Host "OK" -ForegroundColor Green -NoNewline
            Write-Host "] Installed via chocolatey" -ForegroundColor Green
            return $true
        }
    }
    
    # Try scoop
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Write-Host "   [*] Using scoop..." -ForegroundColor Yellow
        scoop install fzf 2>&1 | Out-Null
        if ($?) {
            Write-Host "   [" -ForegroundColor White -NoNewline
            Write-Host "OK" -ForegroundColor Green -NoNewline
            Write-Host "] Installed via scoop" -ForegroundColor Green
            return $true
        }
    }
    
    Write-Host "   [" -ForegroundColor White -NoNewline
    Write-Host "!!" -ForegroundColor Red -NoNewline
    Write-Host "] Could not install fzf (winget/choco/scoop not available)" -ForegroundColor Red
    return $false
}

function Test-Fzf {
    $fzfExists = Get-Command fzf -ErrorAction SilentlyContinue
    if ($null -ne $fzfExists) {
        return $true
    }
    
    Write-Host ""
    Write-Host "  [*] fzf not found. Installing..." -ForegroundColor Yellow
    if (Install-Fzf) {
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        Start-Sleep 1
        return (Get-Command fzf -ErrorAction SilentlyContinue) -ne $null
    }
    
    return $false
}

function Show-Header {
    Clear-Host
    Write-Host ""
    Write-Host "  +======================================+" -ForegroundColor Cyan
    Write-Host "  |  WINDOWS TWEAKS MANAGER PRO v4.0.0   |" -ForegroundColor Cyan
    Write-Host "  +======================================+" -ForegroundColor Cyan
    if (-not $script:runAsAdmin) {
        Write-Host "  [USER MODE] Standard features available" -ForegroundColor Yellow
    } else {
        Write-Host "  [ADMIN MODE] All features available" -ForegroundColor Green
    }
    Write-Host ""
}

function Wait-Enter {
    Read-Host "  Press Enter to continue" | Out-Null
}

function Backup-Registry {
    if (-not $script:runAsAdmin) {
        Write-Host "  [!!] This feature requires Administrator privileges" -ForegroundColor Red
        return
    }
    Show-Progress "Creating registry backup" 2
    try {
        reg export HKCU "$script:backup" /y 2>&1 | Out-Null
        Write-Host "  Backup: $script:backup" -ForegroundColor Green
    } catch {
        Write-Host "  [" -ForegroundColor White -NoNewline
        Write-Host "!!" -ForegroundColor Red -NoNewline
        Write-Host "] Failed to create backup" -ForegroundColor Red
    }
}

function Restart-Explorer {
    Show-Progress "Restarting Explorer" 1
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 500
    Start-Process explorer
}

# ─────────────────────────────────────────────────────────────
# UI TWEAKS (User Privileges OK)
# ─────────────────────────────────────────────────────────────

function Enable-DarkMode {
    Show-Progress "Enabling Dark Mode" 1
    Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" AppsUseLightTheme 0
    Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" SystemUsesLightTheme 0
}

function Enable-LightMode {
    Show-Progress "Enabling Light Mode" 1
    Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" AppsUseLightTheme 1
    Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" SystemUsesLightTheme 1
}

function Show-FileExtensions {
    Show-Progress "Showing file extensions" 1
    Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" HideFileExt 0
}

function Hide-FileExtensions {
    Show-Progress "Hiding file extensions" 1
    Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" HideFileExt 1
}

function Show-HiddenFiles {
    Show-Progress "Showing hidden files" 1
    Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" Hidden 1
}

function Hide-HiddenFiles {
    Show-Progress "Hiding hidden files" 1
    Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" Hidden 2
}

function Taskbar-Left {
    Show-Progress "Moving taskbar to left" 1
    Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" TaskbarAl 0
}

function Taskbar-Center {
    Show-Progress "Centering taskbar" 1
    Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" TaskbarAl 1
}

# ─────────────────────────────────────────────────────────────
# PERFORMANCE TWEAKS (Admin Required)
# ─────────────────────────────────────────────────────────────

function Disable-Animations {
    if (-not $script:runAsAdmin) {
        Write-Host "  [!!] This feature requires Administrator privileges" -ForegroundColor Red
        return
    }
    Show-Progress "Disabling animations" 1
    Set-ItemProperty "HKCU:\Control Panel\Desktop\WindowMetrics" MinAnimate 0
}

function Enable-Animations {
    if (-not $script:runAsAdmin) {
        Write-Host "  [!!] This feature requires Administrator privileges" -ForegroundColor Red
        return
    }
    Show-Progress "Enabling animations" 1
    Set-ItemProperty "HKCU:\Control Panel\Desktop\WindowMetrics" MinAnimate 1
}

function Disable-WindowDraggingContent {
    if (-not $script:runAsAdmin) {
        Write-Host "  [!!] This feature requires Administrator privileges" -ForegroundColor Red
        return
    }
    Show-Progress "Disabling window dragging" 1
    Set-ItemProperty "HKCU:\Control Panel\Desktop" DragFullWindows 0
}

function Enable-WindowDraggingContent {
    if (-not $script:runAsAdmin) {
        Write-Host "  [!!] This feature requires Administrator privileges" -ForegroundColor Red
        return
    }
    Show-Progress "Enabling window dragging" 1
    Set-ItemProperty "HKCU:\Control Panel\Desktop" DragFullWindows 1
}

function Disable-StartupDelay {
    if (-not $script:runAsAdmin) {
        Write-Host "  [!!] This feature requires Administrator privileges" -ForegroundColor Red
        return
    }
    Show-Progress "Removing startup delay" 1
    New-Item "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" StartupDelayInMSec 0
}

function Faster-Menu {
    if (-not $script:runAsAdmin) {
        Write-Host "  [!!] This feature requires Administrator privileges" -ForegroundColor Red
        return
    }
    Show-Progress "Speeding up menus" 1
    Set-ItemProperty "HKCU:\Control Panel\Desktop" MenuShowDelay 20
}

function Default-MenuSpeed {
    if (-not $script:runAsAdmin) {
        Write-Host "  [!!] This feature requires Administrator privileges" -ForegroundColor Red
        return
    }
    Show-Progress "Restoring menu speed" 1
    Set-ItemProperty "HKCU:\Control Panel\Desktop" MenuShowDelay 400
}

# ─────────────────────────────────────────────────────────────
# PRIVACY TWEAKS (Admin Required)
# ─────────────────────────────────────────────────────────────

function Disable-Telemetry {
    if (-not $script:runAsAdmin) {
        Write-Host "  [!!] This feature requires Administrator privileges" -ForegroundColor Red
        return
    }
    Show-Progress "Disabling telemetry" 1
    New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" AllowTelemetry 0
}

function Disable-AdvertisingID {
    if (-not $script:runAsAdmin) {
        Write-Host "  [!!] This feature requires Administrator privileges" -ForegroundColor Red
        return
    }
    Show-Progress "Disabling advertising ID" 1
    Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" Enabled 0
}

# ─────────────────────────────────────────────────────────────
# FZF MENU SYSTEM
# ─────────────────────────────────────────────────────────────

function Get-FzfChoice {
    param([array]$Items)
    
    Write-Debug-Info "Get-FzfChoice called with $($Items.Count) items"
    Write-Debug-Info "Items: $($Items | Out-String)"
    
    $items_text = $Items -join "`n"
    
    Write-Debug-Info "Items text length: $($items_text.Length)"
    Write-Debug-Info "Items text: `n$items_text"
    
    $result = $items_text | fzf `
        --reverse `
        --height 50% `
        --border rounded `
        --border-label " Select " `
        --prompt '> ' `
        --pointer '> ' `
        --marker '* '
    
    Write-Debug-Info "fzf result: '$result'"
    Write-Debug-Info "fzf exit code: $LASTEXITCODE"
    
    return $result
}

function Menu-UITweaks {
    Show-Header
    Write-Host "  " -NoNewline
    Write-Host "UI Tweaks" -ForegroundColor Yellow
    Write-Host ""
    
    $options = @(
        "[1] Enable Dark Mode",
        "[2] Enable Light Mode",
        "[3] Show File Extensions",
        "[4] Hide File Extensions",
        "[5] Show Hidden Files",
        "[6] Hide Hidden Files",
        "[7] Taskbar Left",
        "[8] Taskbar Center",
        "[0] Back to Main Menu"
    )
    
    Write-Debug-Info "Menu-UITweaks: Options count = $($options.Count)"
    
    if (Test-Fzf) {
        Write-Debug-Info "Using fzf for selection"
        $choice = Get-FzfChoice -Items $options
        Write-Debug-Info "fzf choice: '$choice'"
    } else {
        Write-Debug-Info "Using manual selection (fzf not available)"
        $options | ForEach-Object { Write-Host "  $_" }
        $choice = Read-Host "`n  Select"
        $choice = $options[([int]$choice)]
        Write-Debug-Info "Manual choice: '$choice'"
    }
    
    Write-Debug-Info "Switch on choice: '$choice'"
    
    switch -Wildcard ($choice) {
        "*Dark*" { Enable-DarkMode }
        "*Light*" { Enable-LightMode }
        "*Show File*" { Show-FileExtensions }
        "*Hide File*" { Hide-FileExtensions }
        "*Show Hidden*" { Show-HiddenFiles }
        "*Hide Hidden*" { Hide-HiddenFiles }
        "*Left*" { Taskbar-Left }
        "*Center*" { Taskbar-Center }
        "*Back*" { return }
        default { Write-Debug-Info "No match found for choice" }
    }
    
    if ($choice -notmatch "Back") {
        Write-Host ""
        Wait-Enter
        Menu-UITweaks
    }
}

function Menu-PerformanceTweaks {
    Show-Header
    Write-Host "  " -NoNewline
    Write-Host "Performance Tweaks" -ForegroundColor Yellow
    Write-Host ""
    
    $options = @(
        "[1] Disable Animations",
        "[2] Enable Animations",
        "[3] Disable Window Dragging Content",
        "[4] Enable Window Dragging Content",
        "[5] Disable Startup Delay",
        "[6] Faster Menus",
        "[7] Default Menu Speed",
        "[0] Back to Main Menu"
    )
    
    Write-Debug-Info "Menu-PerformanceTweaks: Options count = $($options.Count)"
    
    if (Test-Fzf) {
        Write-Debug-Info "Using fzf for selection"
        $choice = Get-FzfChoice -Items $options
        Write-Debug-Info "fzf choice: '$choice'"
    } else {
        Write-Debug-Info "Using manual selection"
        $options | ForEach-Object { Write-Host "  $_" }
        $choice = Read-Host "`n  Select"
        $choice = $options[([int]$choice)]
        Write-Debug-Info "Manual choice: '$choice'"
    }
    
    Write-Debug-Info "Switch on choice: '$choice'"
    
    switch -Wildcard ($choice) {
        "*Disable Anim*" { Disable-Animations }
        "*Enable Anim*" { Enable-Animations }
        "*Disable Window*" { Disable-WindowDraggingContent }
        "*Enable Window*" { Enable-WindowDraggingContent }
        "*Disable Startup*" { Disable-StartupDelay }
        "*Faster*" { Faster-Menu }
        "*Default*" { Default-MenuSpeed }
        "*Back*" { return }
        default { Write-Debug-Info "No match found for choice" }
    }
    
    if ($choice -notmatch "Back") {
        Write-Host ""
        Wait-Enter
        Menu-PerformanceTweaks
    }
}

function Menu-PrivacyTweaks {
    Show-Header
    Write-Host "  " -NoNewline
    Write-Host "Privacy Tweaks" -ForegroundColor Yellow
    Write-Host ""
    
    $options = @(
        "[1] Disable Telemetry",
        "[2] Disable Advertising ID",
        "[0] Back to Main Menu"
    )
    
    Write-Debug-Info "Menu-PrivacyTweaks: Options count = $($options.Count)"
    
    if (Test-Fzf) {
        Write-Debug-Info "Using fzf for selection"
        $choice = Get-FzfChoice -Items $options
        Write-Debug-Info "fzf choice: '$choice'"
    } else {
        Write-Debug-Info "Using manual selection"
        $options | ForEach-Object { Write-Host "  $_" }
        $choice = Read-Host "`n  Select"
        $choice = $options[([int]$choice)]
        Write-Debug-Info "Manual choice: '$choice'"
    }
    
    Write-Debug-Info "Switch on choice: '$choice'"
    
    switch -Wildcard ($choice) {
        "*Telemetry*" { Disable-Telemetry }
        "*Advertising*" { Disable-AdvertisingID }
        "*Back*" { return }
        default { Write-Debug-Info "No match found for choice" }
    }
    
    if ($choice -notmatch "Back") {
        Write-Host ""
        Wait-Enter
        Menu-PrivacyTweaks
    }
}

function Menu-Main {
    while ($true) {
        Show-Header
        
        $options = @(
            "[1] UI Tweaks",
            "[2] Performance Tweaks",
            "[3] Privacy Tweaks",
            "[4] Backup Registry",
            "[5] Restart Explorer",
            "[0] Exit"
        )
        
        Write-Debug-Info "Menu-Main: Options count = $($options.Count)"
        
        if (Test-Fzf) {
            Write-Debug-Info "Using fzf for selection"
            $choice = Get-FzfChoice -Items $options
            Write-Debug-Info "fzf choice: '$choice'"
        } else {
            Write-Debug-Info "Using manual selection"
            $options | ForEach-Object { Write-Host "  $_" }
            $choice = Read-Host "`n  Select"
            $choice = $options[([int]$choice)]
            Write-Debug-Info "Manual choice: '$choice'"
        }
        
        Write-Debug-Info "Switch on choice: '$choice'"
        
        switch -Wildcard ($choice) {
            "*UI*" { Menu-UITweaks }
            "*Performance*" { Menu-PerformanceTweaks }
            "*Privacy*" { Menu-PrivacyTweaks }
            "*Backup*" { Show-Header; Backup-Registry; Write-Host ""; Wait-Enter }
            "*Restart*" { Show-Header; Restart-Explorer; Write-Host ""; Start-Sleep 2 }
            "*Exit*" { Show-Header; Write-Host "  Bye!" -ForegroundColor Cyan; exit }
            default { Write-Debug-Info "No match found for choice" }
        }
    }
}

# ─────────────────────────────────────────────────────────────
# ENTRY POINT
# ─────────────────────────────────────────────────────────────

Test-Fzf | Out-Null
Menu-Main