<#
.SYNOPSIS
    win-render-md: render Markdown files in the Windows terminal (PowerShell), including LaTeX math.

.DESCRIPTION
    Two render modes:

    1. Terminal (default)  - LaTeX ($...$, $$...$$, \(...\), \[...\]) is converted to
       Unicode math (alpha, sum, integral, fractions, super/subscripts ...), then the
       Markdown is displayed in the console with Show-Markdown (PowerShell 6+/7).
       On Windows PowerShell 5.1 (no Show-Markdown) it falls back to browser mode.

    2. Browser (-Browser)  - Full-fidelity render: marked.js + KaTeX, so every LaTeX
       formula renders properly. Opens in your default browser. Needs internet (CDN).

.EXAMPLE
    .\win-render-md.ps1                  # renders .\README.md in the terminal
    .\win-render-md.ps1 docs\GUIDE.md    # render another file
    .\win-render-md.ps1 -Browser         # full LaTeX via KaTeX in the browser
    .\win-render-md.ps1 -Browser -OutFile readme.html   # also keep the HTML

.NOTES
    If scripts are blocked:  Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
    Handy alias (add to $PROFILE):  Set-Alias readme C:\path\to\win-render-md.ps1
    This file is pure ASCII on purpose, so it works in Windows PowerShell 5.1 too.
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Path = 'README.md',

    [switch]$Browser,

    [string]$OutFile
)

$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}

if (-not (Test-Path -LiteralPath $Path)) {
    Write-Error "File not found: $Path"
    return
}
$full = (Resolve-Path -LiteralPath $Path).ProviderPath
$raw  = Get-Content -LiteralPath $full -Raw -Encoding UTF8

# ---------------------------------------------------------------------------
# LaTeX -> Unicode (terminal mode)
# ---------------------------------------------------------------------------
function U([string]$hex) { [string][char][Convert]::ToInt32($hex, 16) }

$symHex = @{
    alpha='03B1'; beta='03B2'; gamma='03B3'; delta='03B4'; epsilon='03B5'; varepsilon='03B5'
    zeta='03B6'; eta='03B7'; theta='03B8'; iota='03B9'; kappa='03BA'; lambda='03BB'; mu='03BC'
    nu='03BD'; xi='03BE'; pi='03C0'; rho='03C1'; sigma='03C3'; tau='03C4'; upsilon='03C5'
    phi='03C6'; varphi='03C6'; chi='03C7'; psi='03C8'; omega='03C9'
    times='00D7'; cdot='00B7'; pm='00B1'; mp='2213'; div='00F7'
    leq='2264'; le='2264'; geq='2265'; ge='2265'; neq='2260'; ne='2260'
    approx='2248'; equiv='2261'; sim='223C'; propto='221D'; ll='226A'; gg='226B'
    infty='221E'; partial='2202'; nabla='2207'; sum='2211'; prod='220F'
    int='222B'; oint='222E'; in='2208'; notin='2209'; ni='220B'
    subset='2282'; subseteq='2286'; supset='2283'; supseteq='2287'
    cup='222A'; cap='2229'; forall='2200'; exists='2203'; emptyset='2205'
    to='2192'; rightarrow='2192'; leftarrow='2190'; uparrow='2191'; downarrow='2193'
    leftrightarrow='2194'
    implies='21D2'; iff='21D4'; mapsto='21A6'
    ldots='2026'; dots='2026'; cdots='22EF'; ell='2113'; hbar='210F'
    degree='00B0'; angle='2220'; perp='22A5'; parallel='2225'; mid='2223'
    land='2227'; wedge='2227'; lor='2228'; vee='2228'; neg='00AC'
    langle='27E8'; rangle='27E9'; circ='2218'; otimes='2297'; oplus='2295'
    star='22C6'; prime='2032'; Vert='2016'; lVert='2016'; rVert='2016'
    quad='2003'; qquad='2003'
    lfloor='230A'; rfloor='230B'; lceil='2308'; rceil='2309'; nmid='2224'
    leqslant='2264'; geqslant='2265'; cong='2245'; setminus='2216'; varnothing='2205'
    iint='222C'; iiint='222D'; because='2235'; therefore='2234'; aleph='2135'; wp='2118'
    triangle='25B3'; bullet='2219'; ast='2217'; dagger='2020'; checkmark='2713'
    lt='003C'; gt='003E'; nsubseteq='2288'; nleq='2270'; ngeq='2271'; asymp='224D'
    downarrow2='21D3'; longrightarrow='27F6'; longleftarrow='27F5'; hookrightarrow='21AA'
    triangleq='225C'; doteq='2250'; coloneqq='2254'; sqcup='2294'; sqcap='2293'
    bigcup='22C3'; bigcap='22C2'; coprod='2210'; Box='25A1'; square='25A1'
}
# Capitalised names live in a second table: PowerShell hashtable literals are
# case-insensitive, so Gamma/gamma cannot share one literal.
$symHexUpper = @{
    Gamma='0393'; Delta='0394'; Theta='0398'; Lambda='039B'; Xi='039E'; Pi='03A0'
    Sigma='03A3'; Phi='03A6'; Psi='03A8'; Omega='03A9'
    Rightarrow='21D2'; Leftarrow='21D0'; Leftrightarrow='21D4'
    Re='211C'; Im='2111'
}
# Third table: these differ from names in the first table only by case (Vert/vert).
$symHexExtra = @{ vert='007C'; lvert='007C'; rvert='007C' }
# Case-sensitive lookup table so \Gamma and \gamma stay different.
$script:Sym = New-Object System.Collections.Hashtable ([System.StringComparer]::Ordinal)
foreach ($k in $symHex.Keys)      { $script:Sym[$k] = U $symHex[$k] }
foreach ($k in $symHexUpper.Keys) { $script:Sym[$k] = U $symHexUpper[$k] }
foreach ($k in $symHexExtra.Keys) { $script:Sym[$k] = U $symHexExtra[$k] }

# Blackboard bold letters (\mathbb{R} etc.) and accents (\dot{x}, \hat{x}, \vec{v} ...)
$script:BB = @{}
foreach ($pair in @('R=211D','N=2115','Z=2124','Q=211A','C=2102','P=2119','H=210D')) {
    $kv = $pair.Split('=')
    $script:BB[$kv[0]] = U $kv[1]
}
$script:Accent = @{}
foreach ($pair in @('dot=0307','ddot=0308','hat=0302','widehat=0302','bar=0304','vec=20D7','tilde=0303','widetilde=0303')) {
    $kv = $pair.Split('=')
    $script:Accent[$kv[0]] = U $kv[1]
}
$script:FuncNames = @('sin','cos','tan','cot','sec','csc','log','ln','exp','lim','max','min','det','arg','sup','inf','gcd','deg','dim','ker')

function New-CharMap([string]$chars, [string[]]$hexes) {
    $m = @{}
    for ($i = 0; $i -lt $chars.Length; $i++) { $m[[string]$chars[$i]] = U $hexes[$i] }
    $m
}
$script:SupMap = New-CharMap '0123456789+-=()ni' @(
    '2070','00B9','00B2','00B3','2074','2075','2076','2077','2078','2079',
    '207A','207B','207C','207D','207E','207F','2071')
$script:SubMap = New-CharMap '0123456789+-=()aeoxhklmnpstijruv' @(
    '2080','2081','2082','2083','2084','2085','2086','2087','2088','2089',
    '208A','208B','208C','208D','208E',
    '2090','2091','2092','2093','2095','2096','2097','2098','2099','209A','209B','209C',
    '1D62','2C7C','1D63','1D64','1D65')

function Invoke-Regex([string]$text, [string]$pattern, [scriptblock]$fn) {
    [regex]::Replace($text, $pattern, [System.Text.RegularExpressions.MatchEvaluator]$fn)
}

function Convert-Script([string]$text, [string]$marker, [hashtable]$map) {
    $pattern = '\' + $marker + '(?:\{([^{}]*)\}|([A-Za-z0-9+\-]))'
    if ($marker -eq '_') { $pattern = '_(?:\{([^{}]*)\}|([A-Za-z0-9+\-]))' }
    $fn = {
        param($m)
        $body = if ($m.Groups[1].Success) { $m.Groups[1].Value } else { $m.Groups[2].Value }
        $out = New-Object System.Text.StringBuilder
        foreach ($c in $body.ToCharArray()) {
            $key = [string]$c
            if ($map.ContainsKey($key)) { [void]$out.Append($map[$key]) }
            elseif ($body.Length -eq 1) { return ($marker + $body) }
            else { return ($marker + '(' + $body + ')') }
        }
        $out.ToString()
    }.GetNewClosure()
    Invoke-Regex $text $pattern $fn
}

function Convert-MathToText([string]$tex) {
    $s = $tex.Trim()

    $s = [regex]::Replace($s, '\\(left|right)(?![A-Za-z])', '')
    $s = $s.Replace('\{', [string][char]1).Replace('\}', [string][char]2)

    # \frac{a}{b} (innermost first)
    for ($i = 0; $i -lt 10; $i++) {
        $n = Invoke-Regex $s '\\[dt]?frac\s*\{([^{}]*)\}\s*\{([^{}]*)\}' {
            param($m)
            $a = $m.Groups[1].Value; $b = $m.Groups[2].Value
            if ($a -match '^[\w.]+$') { $x = $a } else { $x = "($a)" }
            if ($b -match '^[\w.]+$') { $y = $b } else { $y = "($b)" }
            "$x/$y"
        }
        if ($n -eq $s) { break }
        $s = $n
    }

    # \sqrt{x}
    $root = U '221A'
    $s = Invoke-Regex $s '\\sqrt\s*\{([^{}]*)\}' {
        param($m)
        $b = $m.Groups[1].Value
        if ($b -match '^[\w.]+$') { "$root$b" } else { "$root($b)" }
    }.GetNewClosure()

    # \sqrt x (no braces), \binom{n}{k}, \pmod{m}, \bmod, size commands
    $rt = U '221A'
    $s = [regex]::Replace($s, '\\sqrt\s*([A-Za-z0-9])', ($rt + '$1'))
    $s = [regex]::Replace($s, '\\binom\s*\{([^{}]*)\}\s*\{([^{}]*)\}', 'C($1,$2)')
    $s = [regex]::Replace($s, '\\pmod\s*\{([^{}]*)\}', ' (mod $1)')
    $s = [regex]::Replace($s, '\\pmod\s*([A-Za-z0-9]+)', ' (mod $1)')
    $s = [regex]::Replace($s, '\\(?:bmod|mod)(?![A-Za-z])', ' mod ')
    $s = [regex]::Replace($s, '\\(?:big|Big|bigg|Bigg)[lr]?(?![A-Za-z])', '')

    # \mathbb{R} -> blackboard bold letter
    $s = Invoke-Regex $s '\\mathbb\s*\{([A-Za-z])\}' {
        param($m)
        $k = $m.Groups[1].Value
        if ($script:BB.ContainsKey($k)) { $script:BB[$k] } else { $k }
    }

    # \dot{x} \ddot{x} \hat{x} \bar{x} \vec{v} \tilde{x} -> letter + combining mark
    $s = Invoke-Regex $s '\\(dot|ddot|hat|widehat|bar|vec|tilde|widetilde)\s*\{([^{}]*)\}' {
        param($m)
        $m.Groups[2].Value + $script:Accent[$m.Groups[1].Value]
    }

    # \text{..}, \mathbf{..} ... -> content
    for ($i = 0; $i -lt 5; $i++) {
        $n = [regex]::Replace($s, '\\(?:text|textbf|textit|mathrm|mathbf|mathit|mathcal|mathbb|mathsf|boldsymbol|operatorname|mbox|overline)\s*\{([^{}]*)\}', '$1')
        if ($n -eq $s) { break }
        $s = $n
    }

    # spacing commands
    $s = $s.Replace('\!', '')
    $s = [regex]::Replace($s, '\\[,;: ]', ' ')
    $s = $s.Replace('\\', ' ')

    # named symbols
    $s = Invoke-Regex $s '\\([A-Za-z]+)(?![A-Za-z])' {
        param($m)
        $name = $m.Groups[1].Value
        if ($script:Sym.ContainsKey($name)) { $script:Sym[$name] }
        elseif ($script:FuncNames -contains $name) { $name }
        else { $m.Value }
    }

    # super / subscripts
    $s = Convert-Script $s '^' $script:SupMap
    $s = Convert-Script $s '_' $script:SubMap

    # leftover braces
    $s = $s.Replace('{', '').Replace('}', '')
    $s = $s.Replace([string][char]1, '{').Replace([string][char]2, '}')
    $s = [regex]::Replace($s, '[ \t]{2,}', ' ')
    $s.Trim()
}

function Convert-DocumentLatex([string]$text) {
    # 1. protect code (fenced + inline)
    $store = New-Object System.Collections.Generic.List[string]
    $c1 = [char]1
    $text = Invoke-Regex $text '(?s)(```.*?```|~~~.*?~~~)|(`[^`\r\n]+`)' {
        param($m)
        $store.Add($m.Value)
        "$c1`CODE$($store.Count - 1)$c1"
    }.GetNewClosure()

    # 2. display math -> fenced block so it stands out in Show-Markdown
    $display = {
        param($m)
        $inner = if ($m.Groups[1].Success) { $m.Groups[1].Value } else { $m.Groups[2].Value }
        # Blockquote instead of a code fence: no grey code-block background.
        $lines = (Convert-MathToText $inner) -split "\r?\n" | Where-Object { $_.Trim() -ne '' }
        $quoted = ($lines | ForEach-Object { '>     ' + $_.Trim() }) -join "`n"
        "`n`n" + $quoted + "`n`n"
    }
    $text = Invoke-Regex $text '\$\$([\s\S]+?)\$\$|\\\[([\s\S]+?)\\\]' $display

    # 3. inline math
    $text = Invoke-Regex $text '\\\((.+?)\\\)' { param($m) Convert-MathToText $m.Groups[1].Value }
    $text = Invoke-Regex $text '(?<![\\$\w])\$(?!\s)([^$\r\n]+?)(?<!\s)\$(?![\w$])' {
        param($m) Convert-MathToText $m.Groups[1].Value
    }

    # 4. restore code
    Invoke-Regex $text '\x01CODE(\d+)\x01' { param($m) $store[[int]$m.Groups[1].Value] }.GetNewClosure()
}

# ---------------------------------------------------------------------------
# Browser mode (marked + KaTeX)
# ---------------------------------------------------------------------------
function Show-InBrowser([string]$markdown, [string]$sourcePath, [string]$saveAs) {
    $dir  = Split-Path -Parent $sourcePath
    $base = ([System.Uri]::new($dir.TrimEnd('\') + '\')).AbsoluteUri
    $json = (ConvertTo-Json -InputObject $markdown -Compress).Replace('</', '<\/')
    $title = [System.IO.Path]::GetFileName($sourcePath)

    $template = @'
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<base href="__BASE__">
<title>__TITLE__</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16.11/dist/katex.min.css">
<style>
  :root { --bg:#ffffff; --fg:#1f2328; --muted:#59636e; --line:#d1d9e0; --code:#f6f8fa; --link:#0969da; }
  @media (prefers-color-scheme: dark) {
    :root { --bg:#0d1117; --fg:#e6edf3; --muted:#9198a1; --line:#3d444d; --code:#151b23; --link:#4493f8; }
  }
  body { background:var(--bg); color:var(--fg); margin:0;
         font:16px/1.6 "Segoe UI", system-ui, -apple-system, sans-serif; }
  main { max-width:860px; margin:0 auto; padding:32px 24px 64px; }
  h1,h2 { border-bottom:1px solid var(--line); padding-bottom:.3em; }
  h1,h2,h3,h4 { margin:1.6em 0 .6em; line-height:1.25; }
  a { color:var(--link); }
  code { background:var(--code); padding:.15em .4em; border-radius:6px;
         font:.88em "Cascadia Code", Consolas, monospace; }
  pre { background:var(--code); padding:14px 16px; border-radius:8px; overflow:auto; }
  pre code { padding:0; background:none; }
  blockquote { margin:0; padding:0 1em; color:var(--muted); border-left:.25em solid var(--line); }
  table { border-collapse:collapse; display:block; overflow:auto; }
  th,td { border:1px solid var(--line); padding:6px 13px; }
  img { max-width:100%; }
  hr { border:0; border-top:1px solid var(--line); }
  .katex-display { overflow-x:auto; overflow-y:hidden; }
</style>
</head>
<body>
<main id="out">Rendering...</main>
<script src="https://cdn.jsdelivr.net/npm/marked@12/marked.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/katex@0.16.11/dist/katex.min.js"></script>
<script>
const md = __MD__;
const store = [];
const re = /(```[\s\S]*?```|~~~[\s\S]*?~~~|`[^`\n]+`)|\$\$([\s\S]+?)\$\$|\\\[([\s\S]+?)\\\]|\\\((.+?)\\\)|(?<![\\$\w])\$(?!\s)([^$\n]+?)(?<!\s)\$(?![\w$])/g;
const text = md.replace(re, (m, code, d1, d2, i1, i2) => {
  if (code) return m;
  const display = d1 !== undefined || d2 !== undefined;
  store.push({ tex: d1 ?? d2 ?? i1 ?? i2, display });
  return (display ? '\n\n' : '') + 'MATHPH' + (store.length - 1) + 'X' + (display ? '\n\n' : '');
});
let html = marked.parse(text, { gfm: true });
html = html.replace(/MATHPH(\d+)X/g, (m, n) => {
  const s = store[+n];
  return katex.renderToString(s.tex, { displayMode: s.display, throwOnError: false });
});
document.getElementById('out').innerHTML = html;
</script>
</body>
</html>
'@

    $html = $template.Replace('__BASE__', $base).Replace('__TITLE__', $title).Replace('__MD__', $json)

    if ($saveAs) { $target = $saveAs }
    else { $target = Join-Path $env:TEMP ("readme-render-" + [guid]::NewGuid().ToString('N').Substring(0, 8) + '.html') }
    [System.IO.File]::WriteAllText($target, $html, (New-Object System.Text.UTF8Encoding($false)))
    Write-Host "Opening $target" -ForegroundColor DarkGray
    Start-Process $target
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
if ($Browser) {
    Show-InBrowser $raw $full $OutFile
    return
}

if (-not (Get-Command Show-Markdown -ErrorAction SilentlyContinue)) {
    # Old Windows PowerShell 5.1: hand over to PowerShell 7 if it is installed.
    $pwsh = Get-Command pwsh -ErrorAction SilentlyContinue
    if ($pwsh) {
        & $pwsh.Source -NoProfile -File $PSCommandPath $full
        return
    }
    Write-Warning 'Terminal view needs PowerShell 7. Install it with:  winget install Microsoft.PowerShell   (falling back to browser mode for now)'
    Show-InBrowser $raw $full $OutFile
    return
}

$converted = Convert-DocumentLatex $raw
$tmp = Join-Path $env:TEMP ("readme-render-" + [guid]::NewGuid().ToString('N').Substring(0, 8) + '.md')
[System.IO.File]::WriteAllText($tmp, $converted, (New-Object System.Text.UTF8Encoding($false)))
try {
    # Colours for the terminal view. Change the RGB numbers to taste:
    #   48;2;R;G;B = background colour, 38;2;R;G;B = text colour.
    # (Show-Markdown's default code colour is the grey block.)
    $esc = [string][char]27
    $styles = [ordered]@{
        Code                 = $esc + '[48;2;30;34;42;38;2;152;195;121m'
        Header1Color         = $esc + '[1;38;2;97;175;239m'
        Header2Color         = $esc + '[1;38;2;86;182;194m'
        Header3Color         = $esc + '[1;38;2;229;192;123m'
        Header4Color         = $esc + '[1;38;2;229;192;123m'
        LinkForegroundColor  = $esc + '[4;38;2;198;120;221m'
        BoldForegroundColor  = $esc + '[1;38;2;255;255;255m'
        ItalicsForegroundColor = $esc + '[3;38;2;224;108;117m'
    }
    # One option at a time, so a single unsupported option cannot cancel the rest.
    foreach ($name in $styles.Keys) {
        try {
            $one = @{ $name = $styles[$name] }
            Set-MarkdownOption @one | Out-Null
        } catch {
            Write-Verbose "Set-MarkdownOption -$name failed: $($_.Exception.Message)"
        }
    }
    Show-Markdown -Path $tmp
}
finally {
    Remove-Item -LiteralPath $tmp -ErrorAction SilentlyContinue
}
