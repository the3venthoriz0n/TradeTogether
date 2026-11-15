param(
    [string]$ProjectRoot,
    [string]$Version = "0.12.0-strpm"
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($ProjectRoot)) {
    $ProjectRoot = Split-Path -Parent $PSScriptRoot
}

$ProjectRoot = $ProjectRoot.Trim().Trim('"')
while ($ProjectRoot.EndsWith('\') -or $ProjectRoot.EndsWith('/')) {
    $ProjectRoot = $ProjectRoot.Substring(0, $ProjectRoot.Length - 1)
}
$ProjectRoot = [System.IO.Path]::GetFullPath($ProjectRoot)

$packageDir = Join-Path $ProjectRoot "package"
$dataDir = Join-Path $packageDir "Data"
$pluginDir = Join-Path $dataDir "SKSE\Plugins"
$dllPath = Join-Path $pluginDir "TradeTogether.dll"
$iniPath = Join-Path $pluginDir "TradeTogether.ini"
$mcmPluginPath = Join-Path $dataDir "TradeTogetherMCM.esp"
$mcmNativeScript = Join-Path $dataDir "Scripts\TradeTogetherNative.pex"
$mcmMenuScript = Join-Path $dataDir "Scripts\TradeTogetherMCM.pex"
$distDir = Join-Path $ProjectRoot "dist"

# Keep the internal build marker (for example 0.12.0-strpm) for DLL
# verification, but expose a clean public archive name.
$publicVersion = $Version -replace '-strpm$', ''
$archivePath = Join-Path $distDir ("TradeTogether-{0}.zip" -f $publicVersion)
$verifyScript = Join-Path $PSScriptRoot "verify_release_dll.ps1"

if (-not (Test-Path -LiteralPath $dllPath -PathType Leaf)) {
    throw "DLL introuvable: $dllPath. Compile d'abord avec build_release.bat."
}
if (-not (Test-Path -LiteralPath $iniPath -PathType Leaf)) {
    throw "INI introuvable: $iniPath"
}

& $verifyScript -DllPath $dllPath -ExpectedVersion $Version

if (-not (Test-Path -LiteralPath $mcmPluginPath -PathType Leaf)) {
    Write-Warning "TradeTogetherMCM.esp is missing; archive will not contain the MCM registration quest."
}
if (-not (Test-Path -LiteralPath $mcmNativeScript -PathType Leaf) -or
    -not (Test-Path -LiteralPath $mcmMenuScript -PathType Leaf)) {
    Write-Warning "Compiled MCM Papyrus scripts are missing. Run build_mcm.bat before a public MCM release."
}

# The same working tree is also used by the historical UDP branches. Git does
# not remove untracked package directories when switching branches, so old
# FOMOD folders must never enter a current STRPM archive.
$legacyEntries = @("00 Core", "10 LAN", "20 Remote Host", "30 Remote Client", "fomod")
$foundLegacyEntries = @()
foreach ($entry in $legacyEntries) {
    $entryPath = Join-Path $packageDir $entry
    if (Test-Path -LiteralPath $entryPath) {
        $foundLegacyEntries += $entry
    }
}
if ($foundLegacyEntries.Count -gt 0) {
    Write-Host ("[TradeTogether] Ignoring legacy UDP/FOMOD package residue: " + ($foundLegacyEntries -join ", ")) -ForegroundColor Yellow
}

# Never replace an earlier build: if the target already exists, add a _yyyyMMdd-HHmmss suffix before the extension.
function Get-UniquePath([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) { return $Path }
    $dir  = Split-Path -Parent $Path
    $base = [System.IO.Path]::GetFileNameWithoutExtension($Path)
    $ext  = [System.IO.Path]::GetExtension($Path)
    return (Join-Path $dir ("{0}_{1}{2}" -f $base, (Get-Date -Format "yyyyMMdd-HHmmss"), $ext))
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
$archivePath = Get-UniquePath $archivePath

Compress-Archive `
    -Path $dataDir `
    -DestinationPath $archivePath `
    -CompressionLevel Optimal `
    -Force

if (-not (Test-Path -LiteralPath $archivePath -PathType Leaf)) {
    throw "Archive creation failed: $archivePath"
}

Write-Host "[TradeTogether] Archive creee:" -ForegroundColor Green
Write-Host "  $archivePath"
