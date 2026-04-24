#*----------------------------------------------------
#! Ash's Windows Tweaks Manager
#* Run: irm wt.ash1421.com | iex
#*----------------------------------------------------

$script:version = "V3.1.0"
$script:backup = "$env:TEMP\registry_backup.reg"
$script:isAdmin = ([Security.Principal.WindowsPrincipal]::new(
    [Security.Principal.WindowsIdentity]::GetCurrent()
)).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

#*###########################
#! Output Helpers
#*###########################

function Write-Ok { param([string]$m) Write-Host "  [+] $m" -ForegroundColor Green }
function Write-Info { param([string]$m) Write-Host "  [*] $m" -ForegroundColor Cyan }
function Write-Warn { param([string]$m) Write-Host "  [!] $m" -ForegroundColor Yellow }
function Write-Fail { param([string]$m) Write-Host "  [x] $m" -ForegroundColor Red }
function Write-Sep { Write-Host "  $([string][char]0x2500 * 37)" -ForegroundColor DarkGray }

function Pause-Menu {
    Write-Host ""
    Read-Host "  Press Enter to continue" | Out-Null
    Clear-Host
}

function Title {
    Clear-Host
    $tag = if ($script:isAdmin) { "[Admin]" } else { "[User - some tweaks require admin]" }
    $color = if ($script:isAdmin) { "Green" } else { "Yellow" }
    Write-Host "  =====================================" -ForegroundColor Magenta
    Write-Host "   ASH'S WINDOWS TWEAKS  $($script:version)" -ForegroundColor White
    Write-Host "   $tag" -ForegroundColor $color
    Write-Host "  =====================================" -ForegroundColor Magenta
    Write-Host ""
}

# Guard used internally -- menus hide admin options when not elevated.
function Assert-Admin {
    param([string]$name)
    if (-not $script:isAdmin) { return $false }
    return $true
}

#*###########################
#! Registry Helper
#*###########################

function Safe-Set {
    param(
        [string]$path,
        [string]$name,
        $value,
        [string]$type = "DWord"
    )
    try {
        if (-not (Test-Path $path)) { New-Item $path -Force | Out-Null }
        Set-ItemProperty -Path $path -Name $name -Value $value -Type $type -ErrorAction Stop
    }
    catch {
        Write-Fail "Could not set $name -- $_"
    }
}

#*###########################
#! Wallpaper Native API
#*###########################

function Set-WallpaperNative {
    param([string]$path)

    try {
        if (-not ([System.Management.Automation.PSTypeName]"WallpaperHelper").Type) {

            Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;

public class WallpaperHelper {
    [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
    public static extern bool SystemParametersInfo(
        int uAction,
        int uParam,
        string lpvParam,
        int fuWinIni
    );
}
'@
        }

        [WallpaperHelper]::SystemParametersInfo(20, 0, $path, 3) | Out-Null
    }
    catch {
        Write-Fail "Wallpaper API failed: $_"
    }
}

#*###########################
#! Backup / Restore
#*###########################

function Backup-Registry {
    Write-Info "Backing up HKCU to $($script:backup)..."
    try {
        reg export HKCU $script:backup /y 2>&1 | Out-Null
        Write-Ok "Backup saved."
    }
    catch { Write-Fail "Backup failed: $_" }
}

function Restore-Registry {
    if (Test-Path $script:backup) {
        Write-Info "Restoring from $($script:backup)..."
        try { reg import $script:backup 2>&1 | Out-Null; Write-Ok "Registry restored." }
        catch { Write-Fail "Restore failed: $_" }
    }
    else {
        Write-Fail "No backup found at $($script:backup)"
    }
}

function Restart-Explorer {
    Write-Info "Restarting Explorer..."
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 600
    Start-Process explorer
    Write-Ok "Explorer restarted."
}

function Relaunch-AsAdmin {
    if ($script:isAdmin) {
        Write-Warn "Already running as Administrator."
        return
    }
    Write-Info "Relaunching as Administrator..."
    $exe = if (Get-Command pwsh -ErrorAction SilentlyContinue) { "pwsh" } else { "powershell" }
    $ps  = $MyInvocation.ScriptName
    if ($ps) {
        Start-Process $exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$ps`"" -Verb RunAs
    } else {
        # Launched via irm | iex -- re-fetch and run elevated
        Start-Process $exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"irm wt.ash1421.com | iex`"" -Verb RunAs
    }
    exit
}

#*###########################
#! Theme
#*###########################

function Enable-DarkMode {
    Safe-Set "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" AppsUseLightTheme    0
    Safe-Set "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" SystemUsesLightTheme 0
    Write-Ok "Dark mode enabled."
}

function Enable-LightMode {
    Safe-Set "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" AppsUseLightTheme    1
    Safe-Set "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" SystemUsesLightTheme 1
    Write-Ok "Light mode enabled."
}

function Disable-Transparency {
    Safe-Set "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" EnableTransparency 0
    Write-Ok "Transparency effects disabled."
}

function Enable-Transparency {
    Safe-Set "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" EnableTransparency 1
    Write-Ok "Transparency effects enabled."
}

function Disable-AccentOnTaskbar {
    Safe-Set "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" ColorPrevalence 0
    Write-Ok "Accent color removed from taskbar."
}

function Enable-AccentOnTaskbar {
    Safe-Set "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" ColorPrevalence 1
    Write-Ok "Accent color applied to taskbar."
}

#*###########################
#! Taskbar
#*###########################

function Taskbar-Left {
    Safe-Set "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" TaskbarAl 0
    Write-Ok "Taskbar aligned left."
}

function Taskbar-Center {
    Safe-Set "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" TaskbarAl 1
    Write-Ok "Taskbar aligned center."
}

function Disable-TaskbarWidgets {
    Safe-Set "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" TaskbarDa 0
    Write-Ok "Taskbar Widgets button hidden."
}

function Enable-TaskbarWidgets {
    Safe-Set "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" TaskbarDa 1
    Write-Ok "Taskbar Widgets button shown."
}

function Disable-TaskbarSearch {
    Safe-Set "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" SearchboxTaskbarMode 0
    Write-Ok "Taskbar Search hidden."
}

function Enable-TaskbarSearch {
    Safe-Set "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" SearchboxTaskbarMode 1
    Write-Ok "Taskbar Search shown."
}

function Disable-TaskView {
    Safe-Set "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" ShowTaskViewButton 0
    Write-Ok "Task View button hidden."
}

function Enable-TaskView {
    Safe-Set "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" ShowTaskViewButton 1
    Write-Ok "Task View button shown."
}

function Disable-CopilotButton {
    Safe-Set "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" ShowCopilotButton 0
    Write-Ok "Copilot button hidden."
}

function Enable-CopilotButton {
    Safe-Set "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" ShowCopilotButton 1
    Write-Ok "Copilot button shown."
}

function Disable-ChatButton {
    Safe-Set "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" TaskbarMn 0
    Write-Ok "Chat / Teams button hidden."
}

function Enable-ChatButton {
    Safe-Set "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" TaskbarMn 1
    Write-Ok "Chat / Teams button shown."
}

#*###########################
#! Start Menu
#*###########################

function StartMenu-MorePins {
    Safe-Set "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" Start_Layout               1
    Safe-Set "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" Start_AccountNotifications 0
    Write-Ok "Start menu set to More Pins layout."
}

function StartMenu-Default {
    Safe-Set "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" Start_Layout 0
    Write-Ok "Start menu set to default layout."
}

function Disable-StartRecommendations {
    Safe-Set "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" Start_IrisRecommendations 0
    Write-Ok "Start recommendations disabled."
}

#*###########################
#! File Explorer
#*###########################

function Show-FileExtensions {
    Safe-Set "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" HideFileExt 0
    Write-Ok "File extensions shown."
}

function Hide-FileExtensions {
    Safe-Set "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" HideFileExt 1
    Write-Ok "File extensions hidden."
}

function Show-HiddenFiles {
    Safe-Set "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" Hidden 1
    Write-Ok "Hidden files visible."
}

function Hide-HiddenFiles {
    Safe-Set "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" Hidden 2
    Write-Ok "Hidden files hidden."
}

function Show-FullPathTitleBar {
    Safe-Set "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState" FullPath 1
    Write-Ok "Full path shown in title bar."
}

function Hide-FullPathTitleBar {
    Safe-Set "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState" FullPath 0
    Write-Ok "Full path hidden."
}

function Show-SecondsInClock {
    Safe-Set "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" ShowSecondsInSystemClock 1
    Write-Ok "Seconds shown in clock."
}

function Hide-SecondsInClock {
    Safe-Set "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" ShowSecondsInSystemClock 0
    Write-Ok "Seconds hidden from clock."
}

#*###########################
#! Desktop Background
#*###########################

function Set-BackgroundSolidBlack {
    Safe-Set "HKCU:\Control Panel\Colors"                                                          Background    "0 0 0" String
    Safe-Set "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Wallpapers"                BackgroundType 1
    Safe-Set "HKCU:\Control Panel\Desktop"                                                         Wallpaper     ""     String
    Set-WallpaperNative ""
    Write-Ok "Background set to solid black [#000000]."
}

function Set-BackgroundSolidColor {
    param([string]$hex = "1e1e2e")
    $hex = $hex.TrimStart("#")
    if ($hex.Length -ne 6) { Write-Fail "Invalid hex -- enter 6 characters e.g. 1a1a1a"; return }
    $r = [convert]::ToInt32($hex.Substring(0, 2), 16)
    $g = [convert]::ToInt32($hex.Substring(2, 2), 16)
    $b = [convert]::ToInt32($hex.Substring(4, 2), 16)
    Safe-Set "HKCU:\Control Panel\Colors"                                           Background     "$r $g $b" String
    Safe-Set "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Wallpapers" BackgroundType 1
    Safe-Set "HKCU:\Control Panel\Desktop"                                          Wallpaper      ""        String
    Set-WallpaperNative ""
    Write-Ok "Background set to [#$hex] RGB $r $g $b."
}

function Set-BackgroundCustomColor {
    Write-Host ""
    Write-Host "  Enter a hex color code (e.g. 1e1e2e  or  000000):" -ForegroundColor Cyan
    $hex = Read-Host "  Hex"
    Set-BackgroundSolidColor -hex $hex
}

#*###########################
#! Performance
#*###########################

function Disable-Animations {
    Safe-Set "HKCU:\Control Panel\Desktop\WindowMetrics" MinAnimate 0
    Write-Ok "Animations disabled."
}

function Enable-Animations {
    Safe-Set "HKCU:\Control Panel\Desktop\WindowMetrics" MinAnimate 1
    Write-Ok "Animations enabled."
}

function Enable-WindowDraggingContent {
    Safe-Set "HKCU:\Control Panel\Desktop" DragFullWindows 1
    Write-Ok "Window contents shown while dragging."
}

function Disable-WindowDraggingContent {
    Safe-Set "HKCU:\Control Panel\Desktop" DragFullWindows 0
    Write-Ok "Window contents hidden while dragging."
}

function Disable-StartupDelay {
    Safe-Set "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" StartupDelayInMSec 0
    Write-Ok "Explorer startup delay removed."
}

function Faster-Menu {
    Safe-Set "HKCU:\Control Panel\Desktop" MenuShowDelay 20 String
    Write-Ok "Menu delay set to 20ms."
}

function Default-MenuSpeed {
    Safe-Set "HKCU:\Control Panel\Desktop" MenuShowDelay 400 String
    Write-Ok "Menu delay restored to 400ms."
}

function Set-BestPerformanceVisuals {
    Safe-Set "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" VisualFXSetting 2
    Write-Ok "Visual effects set to Best Performance."
}

function Set-BestAppearanceVisuals {
    Safe-Set "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" VisualFXSetting 1
    Write-Ok "Visual effects set to Best Appearance."
}

function Disable-GameDVR {
    Safe-Set "HKCU:\System\GameConfigStore" GameDVR_Enabled 0
    if ($script:isAdmin) {
        Safe-Set "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" AllowGameDVR 0
    }
    Write-Ok "Game DVR disabled."
}

function Enable-GameDVR {
    Safe-Set "HKCU:\System\GameConfigStore" GameDVR_Enabled 1
    Write-Ok "Game DVR enabled."
}

#*###########################
#! Privacy
#*###########################

function Disable-BingSearch {
    Safe-Set "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" BingSearchEnabled 0
    Safe-Set "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" CortanaConsent    0
    Write-Ok "Bing search in Start disabled."
}

function Enable-BingSearch {
    Safe-Set "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" BingSearchEnabled 1
    Write-Ok "Bing search in Start enabled."
}

function Disable-AdvertisingID {
    Safe-Set "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" Enabled 0
    Write-Ok "Advertising ID disabled."
}

function Disable-AppSuggestions {
    $p = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
    Safe-Set $p SystemPaneSuggestionsEnabled    0
    Safe-Set $p SubscribedContent-338388Enabled 0
    Safe-Set $p SubscribedContent-338389Enabled 0
    Safe-Set $p SubscribedContent-353698Enabled 0
    Write-Ok "App suggestions and tips disabled."
}

function Disable-LockScreenAds {
    $p = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
    Safe-Set $p RotatingLockScreenEnabled        0
    Safe-Set $p RotatingLockScreenOverlayEnabled 0
    Write-Ok "Lock screen ads disabled."
}

function Disable-Telemetry {
    if (-not (Assert-Admin "Disable Telemetry")) { return }
    Safe-Set "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" AllowTelemetry           0
    Safe-Set "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" LimitDiagnosticLogCollection 1
    Write-Ok "Telemetry disabled."
}

function Disable-ActivityHistory {
    if (-not (Assert-Admin "Disable Activity History")) { return }
    Safe-Set "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" EnableActivityFeed    0
    Safe-Set "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" PublishUserActivities 0
    Safe-Set "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" UploadUserActivities  0
    Write-Ok "Activity history disabled."
}

function Disable-LocationTracking {
    if (-not (Assert-Admin "Disable Location Tracking")) { return }
    Safe-Set "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" DisableLocation 1
    Write-Ok "Location tracking disabled."
}

function Disable-Cortana {
    if (-not (Assert-Admin "Disable Cortana")) { return }
    Safe-Set "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" AllowCortana 0
    Write-Ok "Cortana disabled."
}

#*###########################
#! Ash's Profile
#*###########################

function Apply-AshsProfile {
    Title
    Write-Host "  Applying Ash's Profile..." -ForegroundColor Magenta
    Write-Host ""

    Backup-Registry
    Write-Host ""

    Write-Info "Theme..."
    Enable-DarkMode
    Disable-Transparency
    Disable-AccentOnTaskbar

    Write-Info "Taskbar..."
    Taskbar-Left
    Disable-TaskbarWidgets
    Disable-TaskbarSearch
    Disable-TaskView
    Disable-CopilotButton
    Disable-ChatButton

    Write-Info "Start Menu..."
    StartMenu-MorePins
    Disable-StartRecommendations

    Write-Info "Background..."
    Set-BackgroundSolidBlack

    Write-Info "File Explorer..."
    Show-FileExtensions
    Show-HiddenFiles
    Show-FullPathTitleBar
    Show-SecondsInClock

    Write-Info "Performance..."
    Disable-Animations
    Enable-WindowDraggingContent
    Disable-StartupDelay
    Faster-Menu
    Set-BestPerformanceVisuals
    Disable-GameDVR

    Write-Info "Privacy..."
    Disable-BingSearch
    Disable-AdvertisingID
    Disable-AppSuggestions
    Disable-LockScreenAds
    if ($script:isAdmin) {
        Disable-Telemetry
        Disable-Cortana
        Disable-ActivityHistory
        Disable-LocationTracking
    }

    Write-Host ""
    Write-Sep
    Write-Host "  Profile applied." -ForegroundColor Green
    Write-Host "  Restart Explorer (option 10) or reboot to apply all changes." -ForegroundColor DarkGray
    Write-Sep
}

#*###########################
#! Menus
#*###########################

function MainMenu {
    while ($true) {
        Title
        Write-Host "  1   Apply Ash's Profile  " -NoNewline; Write-Host "(recommended)" -ForegroundColor Magenta
        Write-Sep
        Write-Host "  2   Theme & Appearance"
        Write-Host "  3   Taskbar & Start Menu"
        Write-Host "  4   File Explorer"
        Write-Host "  5   Desktop Background"
        Write-Host "  6   Performance"
        Write-Host "  7   Privacy & Security"
        Write-Sep
        Write-Host "  8   Backup Registry"
        Write-Host "  9   Restore Registry Backup"
        Write-Host "  10  Restart Explorer"
        if (-not $script:isAdmin) {
            Write-Host "  11  Relaunch as Administrator" -ForegroundColor Yellow
        }
        Write-Sep
        Write-Host "  0   Exit"
        Write-Host ""
        $c = Read-Host "  Select"
        switch ($c) {
            "1" { Apply-AshsProfile; Pause-Menu }
            "2" { Menu-Theme }
            "3" { Menu-Taskbar }
            "4" { Menu-Explorer }
            "5" { Menu-Background }
            "6" { Menu-Performance }
            "7" { Menu-Privacy }
            "8" { Backup-Registry; Pause-Menu }
            "9" { Restore-Registry; Pause-Menu }
            "10" { Restart-Explorer; Pause-Menu }
            "11" { Relaunch-AsAdmin }
            "0" { exit }
        }
    }
}

function Menu-Theme {
    while ($true) {
        Title
        Write-Host "  THEME & APPEARANCE" -ForegroundColor Cyan
        Write-Sep
        Write-Host "  1  Enable Dark Mode"
        Write-Host "  2  Enable Light Mode"
        Write-Host "  3  Disable Transparency Effects"
        Write-Host "  4  Enable Transparency Effects"
        Write-Host "  5  Disable Accent Color on Taskbar"
        Write-Host "  6  Enable Accent Color on Taskbar"
        Write-Sep
        Write-Host "  0  Back"
        Write-Host ""
        $c = Read-Host "  Select"
        switch ($c) {
            "1" { Enable-DarkMode }           "2" { Enable-LightMode }
            "3" { Disable-Transparency }      "4" { Enable-Transparency }
            "5" { Disable-AccentOnTaskbar }   "6" { Enable-AccentOnTaskbar }
            "0" { Clear-Host; return }
        }
        if ($c -ne "0") { Pause-Menu }
    }
}

function Menu-Taskbar {
    while ($true) {
        Title
        Write-Host "  TASKBAR & START MENU" -ForegroundColor Cyan
        Write-Sep
        Write-Host "  [ Alignment ]"
        Write-Host "  1  Left          2  Center"
        Write-Host ""
        Write-Host "  [ Taskbar Buttons ]"
        Write-Host "  3  Hide Widgets            4  Show Widgets"
        Write-Host "  5  Hide Search             6  Show Search"
        Write-Host "  7  Hide Task View          8  Show Task View"
        Write-Host "  9  Hide Copilot           10  Show Copilot"
        Write-Host "  11 Hide Chat/Teams        12  Show Chat/Teams"
        Write-Host ""
        Write-Host "  [ Start Menu ]"
        Write-Host "  13 More Pins layout (fewer recommendations)"
        Write-Host "  14 Default layout"
        Write-Host "  15 Disable recommendations"
        Write-Sep
        Write-Host "  0  Back"
        Write-Host ""
        $c = Read-Host "  Select"
        switch ($c) {
            "1" { Taskbar-Left }               "2" { Taskbar-Center }
            "3" { Disable-TaskbarWidgets }     "4" { Enable-TaskbarWidgets }
            "5" { Disable-TaskbarSearch }      "6" { Enable-TaskbarSearch }
            "7" { Disable-TaskView }           "8" { Enable-TaskView }
            "9" { Disable-CopilotButton }      "10" { Enable-CopilotButton }
            "11" { Disable-ChatButton }         "12" { Enable-ChatButton }
            "13" { StartMenu-MorePins }
            "14" { StartMenu-Default }
            "15" { Disable-StartRecommendations }
            "0" { Clear-Host; return }
        }
        if ($c -ne "0") { Pause-Menu }
    }
}

function Menu-Explorer {
    while ($true) {
        Title
        Write-Host "  FILE EXPLORER" -ForegroundColor Cyan
        Write-Sep
        Write-Host "  1  Show File Extensions       2  Hide File Extensions"
        Write-Host "  3  Show Hidden Files           4  Hide Hidden Files"
        Write-Host "  5  Show Full Path in Title     6  Hide Full Path"
        Write-Host "  7  Show Seconds in Clock       8  Hide Seconds in Clock"
        Write-Sep
        Write-Host "  0  Back"
        Write-Host ""
        $c = Read-Host "  Select"
        switch ($c) {
            "1" { Show-FileExtensions }    "2" { Hide-FileExtensions }
            "3" { Show-HiddenFiles }       "4" { Hide-HiddenFiles }
            "5" { Show-FullPathTitleBar }  "6" { Hide-FullPathTitleBar }
            "7" { Show-SecondsInClock }    "8" { Hide-SecondsInClock }
            "0" { Clear-Host; return }
        }
        if ($c -ne "0") { Pause-Menu }
    }
}

function Menu-Background {
    while ($true) {
        Title
        Write-Host "  DESKTOP BACKGROUND" -ForegroundColor Cyan
        Write-Sep
        Write-Host "  1  Solid Black   [#000000]"
        Write-Host "  2  Dark Grey     [#1a1a1a]"
        Write-Host "  3  Dark Purple   [#1e1e2e]"
        Write-Host "  4  Custom Hex Color..."
        Write-Sep
        Write-Host "  0  Back"
        Write-Host ""
        $c = Read-Host "  Select"
        switch ($c) {
            "1" { Set-BackgroundSolidBlack }
            "2" { Set-BackgroundSolidColor "1a1a1a" }
            "3" { Set-BackgroundSolidColor "1e1e2e" }
            "4" { Set-BackgroundCustomColor }
            "0" { Clear-Host; return }
        }
        if ($c -ne "0") { Pause-Menu }
    }
}

function Menu-Performance {
    while ($true) {
        Title
        Write-Host "  PERFORMANCE" -ForegroundColor Cyan
        Write-Sep
        Write-Host "  1  Disable Animations              2  Enable Animations"
        Write-Host "  3  Show Window Content (Dragging)  4  Hide Window Content (Dragging)"
        Write-Host "  5  Disable Startup Delay"
        Write-Host "  6  Faster Menus (20ms)             7  Default Menu Speed (400ms)"
        Write-Host "  8  Visuals -- Best Performance      9  Visuals -- Best Appearance"
        Write-Host "  10 Disable Game DVR               11  Enable Game DVR"
        Write-Sep
        Write-Host "  0  Back"
        Write-Host ""
        $c = Read-Host "  Select"
        switch ($c) {
            "1" { Disable-Animations }             "2" { Enable-Animations }
            "3" { Enable-WindowDraggingContent }   "4" { Disable-WindowDraggingContent }
            "5" { Disable-StartupDelay }
            "6" { Faster-Menu }                    "7" { Default-MenuSpeed }
            "8" { Set-BestPerformanceVisuals }     "9" { Set-BestAppearanceVisuals }
            "10" { Disable-GameDVR }                "11" { Enable-GameDVR }
            "0" { Clear-Host; return }
        }
        if ($c -ne "0") { Pause-Menu }
    }
}

function Menu-Privacy {
    while ($true) {
        Title
        Write-Host "  PRIVACY & SECURITY" -ForegroundColor Cyan
        Write-Sep
        Write-Host "  1  Disable Bing Search in Start    2  Enable Bing Search in Start"
        Write-Host "  3  Disable Advertising ID"
        Write-Host "  4  Disable App Suggestions & Tips"
        Write-Host "  5  Disable Lock Screen Ads"
        if ($script:isAdmin) {
            Write-Host "  6  Disable Telemetry"
            Write-Host "  7  Disable Activity History"
            Write-Host "  8  Disable Location Tracking"
            Write-Host "  9  Disable Cortana"
        } else {
            Write-Host ""
            Write-Host "  Options 6-9 require admin." -ForegroundColor DarkGray
            Write-Host "  Use option 11 on the main menu to relaunch as Administrator." -ForegroundColor DarkGray
        }
        Write-Sep
        Write-Host "  0  Back"
        Write-Host ""
        $c = Read-Host "  Select"
        switch ($c) {
            "1" { Disable-BingSearch }        "2" { Enable-BingSearch }
            "3" { Disable-AdvertisingID }
            "4" { Disable-AppSuggestions }
            "5" { Disable-LockScreenAds }
            "6" { if ($script:isAdmin) { Disable-Telemetry }        else { Write-Warn "Relaunch as admin to use this." } }
            "7" { if ($script:isAdmin) { Disable-ActivityHistory }  else { Write-Warn "Relaunch as admin to use this." } }
            "8" { if ($script:isAdmin) { Disable-LocationTracking } else { Write-Warn "Relaunch as admin to use this." } }
            "9" { if ($script:isAdmin) { Disable-Cortana }          else { Write-Warn "Relaunch as admin to use this." } }
            "0" { Clear-Host; return }
        }
        if ($c -ne "0") { Pause-Menu }
    }
}

#*###########################
#! Entry
#*###########################

MainMenu