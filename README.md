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

### 💾 Download to Temp & Run

Saves a local copy to `%TEMP%\tweaks.ps1` before running — useful if you want to relaunch as admin without re-downloading, or just keep a copy.

```powershell
irm wt.ash1421.com -OutFile "$env:TEMP\tweaks.ps1"; powershell -ExecutionPolicy Bypass -File "$env:TEMP\tweaks.ps1"
```

### ⚙️ Raw Download to Temp & Run

Using raw links, Saves a local copy to `%TEMP%\tweaks.ps1` before running — useful if you want to relaunch as admin without re-downloading, or just keep a copy.

```powershell
irm https://raw.githubusercontent.com/Ash1421/win-tweaks/refs/heads/main/tweaks.ps1 -OutFile "$env:TEMP\tweaks.ps1"; powershell -ExecutionPolicy Bypass -File "$env:TEMP\tweaks.ps1"
```

### 📁 Download & Run Locally

1. Download or clone the repo
2. Double-click `run.bat`

`run.bat` will attempt to request administrator privileges automatically via UAC. If elevation is unavailable (e.g. in a workspace), it falls back to running as the current user — tweaks that require admin will be skipped with a clear warning, everything else applies fine.

**Or run manually in PowerShell / pwsh:**

```powershell
powershell -ExecutionPolicy Bypass -File tweaks.ps1
```

---

> **Note:** The script works without admin. Tweaks that need `HKLM` access (Telemetry, Cortana, Activity History, Location Tracking, Windows Security icon) are clearly marked `[Admin]` in the menu and will be skipped gracefully if not elevated, rather than erroring out. Use option **13** on the main menu to relaunch as Administrator at any time.

## 🖥️ How It Works

On launch the script detects whether you are running as Administrator and displays this in the header. You navigate numbered menus to apply tweaks individually, or hit **1** to apply Ash's full profile in one shot.

A registry backup is saved to `%TEMP%\registry_backup.reg` automatically before the profile runs. You can also back up and restore manually from the main menu at any time.

After applying tweaks, use option **11 Restart Explorer** or reboot for all changes to take effect.

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
