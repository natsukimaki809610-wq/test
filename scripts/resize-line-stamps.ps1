<#
.SYNOPSIS
    LINEスタンプ用に画像をリサイズします (既定 370x320)。

.DESCRIPTION
    指定フォルダ内の 1〜40 番の画像を読み込み、縦横比を保ったまま
    370x320 に収まるよう縮小し、余白を透明で埋めて
    ちょうど 370x320 の PNG として出力します。
    元のファイルは変更しません（出力先フォルダに新規作成）。

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\resize-line-stamps.ps1

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\resize-line-stamps.ps1 -SourceDir "C:\Users\user\ChatGPT\99_その他\LINE\看護師40" -From 1 -To 40

.EXAMPLE
    # No.1 からメイン画像 (240x240) を main.png として作る
    powershell -ExecutionPolicy Bypass -File .\resize-line-stamps.ps1 -Width 240 -Height 240 -From 1 -To 1 -OutputName main
#>

[CmdletBinding()]
param(
    # 変換元フォルダ。省略時はこのスクリプトが置かれているフォルダ。
    [string]$SourceDir = $PSScriptRoot,

    # 出力先フォルダ。省略時は変換元フォルダ配下の "resized"。
    [string]$OutputDir,

    [int]$Width  = 370,
    [int]$Height = 320,

    [int]$From = 1,
    [int]$To   = 40,

    # 元画像が指定サイズより小さい場合に拡大しない
    [switch]$NoUpscale,

    # 出力ファイル名。1枚だけ変換するとき用 (例: main / tab)。
    # 省略時は番号をそのままファイル名にします (01.png など)。
    [string]$OutputName
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

if (-not $SourceDir) { $SourceDir = (Get-Location).Path }
if (-not (Test-Path -LiteralPath $SourceDir)) {
    throw "変換元フォルダが見つかりません: $SourceDir"
}
$SourceDir = (Resolve-Path -LiteralPath $SourceDir).Path

if (-not $OutputDir) { $OutputDir = Join-Path $SourceDir 'resized' }
if (-not (Test-Path -LiteralPath $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

Write-Host "変換元 : $SourceDir"
Write-Host "出力先 : $OutputDir"
Write-Host "サイズ : ${Width}x${Height} (縦横比を保持し、余白は透明)"
Write-Host ""

# 番号 N に対応するファイルを探す (1.png / 01.png / 001.png、jpg/jpeg/webp も対象)
function Find-SourceFile {
    param([int]$Number, [string]$Dir)

    $extensions = @('png', 'jpg', 'jpeg', 'webp', 'bmp')
    foreach ($name in @("$Number", ('{0:D2}' -f $Number), ('{0:D3}' -f $Number))) {
        foreach ($ext in $extensions) {
            $candidate = Join-Path $Dir "$name.$ext"
            if (Test-Path -LiteralPath $candidate) { return $candidate }
        }
    }
    return $null
}

$converted = 0
$missing   = @()

for ($i = $From; $i -le $To; $i++) {

    $sourcePath = Find-SourceFile -Number $i -Dir $SourceDir
    if (-not $sourcePath) {
        $missing += $i
        Write-Warning "No.$i の画像が見つかりません（スキップ）"
        continue
    }

    $src      = $null
    $canvas   = $null
    $graphics = $null
    $attrs    = $null

    try {
        $src = [System.Drawing.Image]::FromFile($sourcePath)

        # 縦横比を保ったまま 370x320 の枠に収まる寸法を計算
        $scale = [Math]::Min($Width / $src.Width, $Height / $src.Height)
        if ($NoUpscale -and $scale -gt 1) { $scale = 1 }
        $drawW = [Math]::Max(1, [int][Math]::Round($src.Width  * $scale))
        $drawH = [Math]::Max(1, [int][Math]::Round($src.Height * $scale))
        $offsetX = [int][Math]::Round(($Width  - $drawW) / 2)
        $offsetY = [int][Math]::Round(($Height - $drawH) / 2)

        # 透明キャンバスを用意
        $canvas = New-Object System.Drawing.Bitmap($Width, $Height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        $canvas.SetResolution(72, 72)

        $graphics = [System.Drawing.Graphics]::FromImage($canvas)
        $graphics.Clear([System.Drawing.Color]::Transparent)
        $graphics.CompositingMode    = [System.Drawing.Drawing2D.CompositingMode]::SourceOver
        $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
        $graphics.InterpolationMode  = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.SmoothingMode      = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
        $graphics.PixelOffsetMode    = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

        # 端に余計な線が出ないようにする
        $attrs = New-Object System.Drawing.Imaging.ImageAttributes
        $attrs.SetWrapMode([System.Drawing.Drawing2D.WrapMode]::TileFlipXY)

        $destRect = New-Object System.Drawing.Rectangle($offsetX, $offsetY, $drawW, $drawH)
        $graphics.DrawImage($src, $destRect, 0, 0, $src.Width, $src.Height, [System.Drawing.GraphicsUnit]::Pixel, $attrs)

        if ($OutputName) {
            $leaf = $OutputName
            if (-not $leaf.ToLower().EndsWith('.png')) { $leaf = "$leaf.png" }
        }
        else {
            $leaf = '{0:D2}.png' -f $i
        }
        $outPath = Join-Path $OutputDir $leaf
        $canvas.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)

        $sizeKB = [Math]::Round((Get-Item -LiteralPath $outPath).Length / 1KB, 1)
        $message = "No.{0,-3} {1,5}x{2,-5} -> {3,-12} {4}x{5} (中身 {6}x{7}, {8} KB)" -f $i, $src.Width, $src.Height, $leaf, $Width, $Height, $drawW, $drawH, $sizeKB
        Write-Host $message

        $converted++
    }
    finally {
        if ($attrs)    { $attrs.Dispose() }
        if ($graphics) { $graphics.Dispose() }
        if ($canvas)   { $canvas.Dispose() }
        if ($src)      { $src.Dispose() }
    }
}

Write-Host ""
Write-Host "完了: $converted 枚を変換しました -> $OutputDir"
if ($missing.Count -gt 0) {
    Write-Host ("見つからなかった番号: {0}" -f ($missing -join ', '))
}
