<div align="center">

# 🪟 Ash's Windows Tweaks Manager

**A PowerShell registry manager for quickly applying Windows UI, performance, and privacy tweaks.**

</div>

---

## ✨ Socials & Stars

[![Discord Server Invite](https://img.shields.io/badge/Discord-Server%20Invite-7289DA?style=for-the-badge&logo=discord&logoColor=white&color=blueviolet&labelColor=1c1917)](https://rb.ash1421.com/discord)
[![GitHub Stars](https://img.shields.io/github/stars/Ash1421/win-tweaks?style=for-the-badge&color=gold&labelColor=1c1917&logo=github&logoColor=white)](https://github.com/Ash1421/win-tweaks/stargazers)

## 💜 Donations & Funding

#### Donations and or support are appreciated very much!
#### If you would like to show love to the creator of this project, please consider donating on Ko-fi.

[![Ko-fi](https://img.shields.io/badge/Ko--fi-Donate-FF69B4?style=for-the-badge&logo=kofi&logoColor=white&labelColor=1c1917)](https://kofi.ash1421.com)

## ❤️ Made With Love Using

[![PowerShell](https://img.shields.io/badge/PowerShell-5391FE?style=for-the-badge&logo=powershell&logoColor=white&labelColor=1c1917)](https://learn.microsoft.com/en-us/powershell/)
[![Windows](https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white&labelColor=1c1917)](https://www.microsoft.com/en-us/windows)
[![Shields.io](https://img.shields.io/badge/Shields.io-darkgreen.svg?style=for-the-badge&logo=shields.io&logoColor=white&labelColor=1c1917)](https://shields.io/)

## 📜 Licensed Under

[![License: GPL v3.0](https://img.shields.io/badge/License-GPL%20v3.0-6829B1.svg?style=for-the-badge&labelColor=1c1917&logo=gnu&logoColor=white)](./LICENSE)

---

## 🚀 Installation & Usage

### ⚡ One-liner (PowerShell / pwsh)

```powershell
irm wt.ash1421.com | iex
```

### ⚡ One-liner (Command Prompt)

```cmd
powershell -c "irm wt.ash1421.com | iex"
```

### 📁 Download & Run locally

1. Download or clone the repo
2. Double-click `run.bat`

`run.bat` will attempt to request administrator privileges automatically via UAC. If elevation is unavailable (e.g. in a workspace), it falls back to running as the current user — tweaks that require admin will be skipped with a clear warning, everything else applies fine.

**Or run manually in PowerShell / pwsh:**

```powershell
powershell -ExecutionPolicy Bypass -File tweaks.ps1
```

> **Note:** The script works without admin. Tweaks that need `HKLM` access (Telemetry, Cortana, Activity History, Location Tracking) are clearly marked `[Admin]` in the menu and will be skipped gracefully if not elevated, rather than erroring out.

---

## 🖥️ How It Works

On launch the script detects whether you are running as Administrator and displays this in the header. You navigate numbered menus to apply tweaks individually, or hit **1** to apply Ash's full profile in one shot.

A registry backup is saved to `%TEMP%\registry_backup.reg` automatically before the profile runs. You can also back up and restore manually from the main menu at any time.

After applying tweaks, use option **10 Restart Explorer** or reboot for all changes to take effect.

---

## 👤 Ash's Profile — What It Applies

Option **1** from the main menu applies all of the below automatically:

| Area | What changes |
| --- | --- |
| **Theme** | Dark mode, transparency disabled, accent color removed from taskbar |
| **Taskbar** | Aligned left, Widgets hidden, Search hidden, Task View hidden, Copilot hidden, Chat/Teams hidden |
| **Start Menu** | More Pins layout, recommendations disabled |
| **Background** | Solid black (`#000000`) |
| **File Explorer** | File extensions shown, hidden files shown, full path in title bar, seconds in clock |
| **Performance** | Animations disabled, window content shown while dragging, startup delay removed, menu delay 20ms, visual effects set to Best Performance, Game DVR disabled |
| **Privacy** | Bing Search in Start disabled, Advertising ID disabled, app suggestions disabled, lock screen ads disabled |
| **Privacy (Admin)** | Telemetry disabled, Cortana disabled, Activity History disabled, Location Tracking disabled |

> Tweaks in the **Privacy (Admin)** row are silently skipped when not running as Administrator, and a summary is shown at the end.

---

## 📋 Available Tweaks

<details>
<summary>Theme & Appearance</summary>

- Dark / Light mode
- Transparency effects on / off
- Accent color on taskbar on / off

</details>

<details>
<summary>Taskbar & Start Menu</summary>

- Taskbar align left / center
- Hide / show: Widgets, Search, Task View, Copilot, Chat/Teams
- Start menu: More Pins layout, default layout, disable recommendations

</details>

<details>
<summary>File Explorer</summary>

- Show / hide file extensions
- Show / hide hidden files
- Show / hide full path in title bar
- Show / hide seconds in clock

</details>

<details>
<summary>Desktop Background</summary>

- Solid black `#000000`
- Dark grey `#1a1a1a`
- Dark purple `#1e1e2e`
- Any custom hex color

</details>

<details>
<summary>Performance</summary>

- Animations on / off
- Window content while dragging on / off
- Startup delay disabled
- Menu speed: 20ms / 400ms
- Visual effects: Best Performance / Best Appearance
- Game DVR on / off

</details>

<details>
<summary>Privacy & Security</summary>

- Bing search in Start on / off
- Advertising ID disabled
- App suggestions and tips disabled
- Lock screen ads disabled
- Telemetry disabled `[Admin]`
- Activity history disabled `[Admin]`
- Location tracking disabled `[Admin]`
- Cortana disabled `[Admin]`

</details>

---

## 📜 License

This project is licensed under the [GPL v3.0](./LICENSE) (GNU General Public License V3.0).

---

<div align="center">

## 💵 Support Me and or My Projects

<table width="100%" style="border-collapse: collapse; border: 1px solid #ddd;">
  <tr>
    <td align="center" style="border: 1px solid #ddd; padding: 15px; vertical-align: top;">
      <h3>💜 Donations and support are appreciated very much!</h3>
      <p><strong>Minimum donation:</strong> $5 (NZD)</p>
      <p><strong>Payment methods:</strong> Credit/Debit Card, PayPal, Apple Pay, Google Pay</p>
      <p><strong>Supported Cards:</strong> Visa, Mastercard, Amex / American Express</p>
      <p>Membership options are <strong>available</strong> for recurring support.</p>
      <p><strong>You can donate via:</strong></p>
      <a href="https://kofi.ash1421.com">
        <img src="https://img.shields.io/badge/Ko--fi-Donate-FF69B4?style=for-the-badge&logo=kofi&logoColor=white&labelColor=1c1917" alt="Ko-fi">
      </a>
    </td>
    <td align="center" style="border: 1px solid #ddd; padding: 15px; vertical-align: top;">
      <h3 style="color:#553BBB;">💜 Supported Payment Methods:</h3>
      <div>
        <a href="https://www.visa.co.nz/">
          <img src="https://img.shields.io/badge/Visa%20Credit%2FDebit_Card-9C51E3?style=for-the-badge&logo=visa&logoColor=white&labelColor=1c1917" alt="Visa">
        </a>
        <a href="https://www.mastercard.co.nz/">
          <img src="https://img.shields.io/badge/Mastercard%20Credit%2FDebit_Card-8F40E0?style=for-the-badge&logo=mastercard&logoColor=white&labelColor=1c1917" alt="Mastercard">
        </a>
        <a href="https://www.americanexpress.com/newzealand/">
          <img src="https://img.shields.io/badge/Amex%2FAmerican%20Express-8433DD?style=for-the-badge&logo=american-express&logoColor=white&labelColor=1c1917" alt="Amex">
        </a>
        <a href="https://www.paypal.com/nz/">
          <img src="https://img.shields.io/badge/PayPal-Supported-7930DA?style=for-the-badge&logo=paypal&logoColor=white&labelColor=1c1917" alt="PayPal">
        </a>
        <a href="https://www.apple.com/nz/apple-pay/">
          <img src="https://img.shields.io/badge/Apple_Pay-Supported-6F28D7?style=for-the-badge&logo=apple&logoColor=white&labelColor=1c1917" alt="Apple Pay">
        </a>
        <a href="https://pay.google.com/intl/en_nz/about/">
          <img src="https://img.shields.io/badge/Google_Pay-Supported-6320D3?style=for-the-badge&logo=google-pay&logoColor=white&labelColor=1c1917" alt="Google Pay">
        </a>
      </div>
    </td>
  </tr>
</table>

---

**Made with 💜 by [@Ash1421](https://github.com/Ash1421)**

⭐ **Star this repo if you like it!** ⭐

</div>
