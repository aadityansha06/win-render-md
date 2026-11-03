# win-render-md

Render Markdown in Windows through the terminal, including LaTeX for maths.

`win-render-md` is a single PowerShell script. It shows `.md` files right inside your terminal, with colored headings, lists, tables and code blocks. Maths written in LaTeX (`$...$` and `$$...$$`) is converted to readable symbols. For the exact LaTeX look, an optional browser mode renders it with KaTeX.

```powershell
pwsh .\win-render-md.ps1 notes.md
```

---

## Install (3 steps)

### 1. Get PowerShell 7

Open PowerShell and run:

```powershell
winget install Microsoft.PowerShell
```

Close the window and open a new one. (Already installed? Type `pwsh` to check.)

### 2. Download the script

Download `win-render-md.ps1` and put it in any folder, for example `C:\Tools`.

### 3. Allow it to run (one time)

Open PowerShell in that folder and run:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
Unblock-File .\win-render-md.ps1
```

If it asks for confirmation, type `Y` and press Enter.

> **Tip:** to open PowerShell in a folder, click the address bar in File Explorer, type `powershell`, and press Enter.

---

## Use it

View a file in the terminal:

```powershell
pwsh .\win-render-md.ps1 README.md
```

View it in your browser with full LaTeX (needs internet):

```powershell
pwsh .\win-render-md.ps1 README.md -Browser
```

Save the browser version as an HTML file too:

```powershell
pwsh .\win-render-md.ps1 README.md -Browser -OutFile readme.html
```

With no file name, it opens `README.md` in the current folder.

---

## Optional: use a short command

Run `notepad $PROFILE`, add this line (use your own path), then restart PowerShell:

```powershell
Set-Alias wrm C:\Tools\win-render-md.ps1
```

After that you can type:

```powershell
wrm README.md
wrm README.md -Browser
```

---

## What maths works in the terminal

| You write | You see |
|-----------|---------|
| `$\alpha + \beta$` | α + β |
| `$x^2$` | x² |
| `$\frac{a}{b}$` | a/b |
| `$\sqrt{2}$` | √2 |
| `$\sum_{i=1}^{n} i$` | ∑ᵢ₌₁ⁿ i |
| `$\int_a^b f\,dx$` | ∫ₐ^b f dx |
| `$\frac{\partial f}{\partial x}$` | (∂f)/(∂x) |
| `$a \equiv b \pmod m$` | a ≡ b (mod m) |
| `$\mathbb{R}$` | ℝ |

Supported delimiters: `$...$`, `$$...$$`, `\(...\)` and `\[...\]`.

Text inside code blocks and `` `inline code` `` is never changed, and prices like `$5 and $10` are left alone.

**Limits:** the terminal can only approximate maths. Matrices, `align` blocks and very complex formulas look simplified. Use `-Browser` for those.

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| "running scripts is disabled on this system" | Run `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` |
| Opens in the browser instead of the terminal | You are using old Windows PowerShell 5.1. Install PowerShell 7 (step 1) and start the script with `pwsh` |
| `winget` is not recognized | Install "PowerShell" from the Microsoft Store instead |
| Strange boxes instead of symbols | Use a terminal font with good Unicode support, such as Cascadia Code (default in Windows Terminal) |
| Code blocks are grey | Run `Get-Command Set-MarkdownOption \| Select -Expand Parameters \| % Keys` and report an issue with the output |
| Browser mode shows a blank page | Check your internet connection (it loads KaTeX from a CDN) |

---

## Requirements

- Windows 10 or 11
- PowerShell 7 for terminal mode (Windows PowerShell 5.1 can only use `-Browser`)
- Internet only for `-Browser` mode

## License

Free to use and share. Add your preferred license file (for example MIT) if you publish this.
