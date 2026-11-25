# Draws the README cover (assets/cover.png, 1600x1000), the icon (assets/icon.png, 256x256, which
# Orca shows as the project's icon) and the GitHub social preview (assets/social-preview.png,
# 1280x640, uploaded by hand in Settings), all dark and from shapes.
# Run from the repository root: powershell -NoProfile -File assets/draw-images.ps1
Add-Type -AssemblyName System.Drawing

$assets = Split-Path -Parent $MyInvocation.MyCommand.Path

function Get-Color([string]$hex, [int]$alpha = 255) {
  $c = [System.Drawing.ColorTranslator]::FromHtml($hex)
  return [System.Drawing.Color]::FromArgb($alpha, $c.R, $c.G, $c.B)
}

$ground = Get-Color '#1E222A'
$frame = Get-Color '#181B22'
$sheet = Get-Color '#2C313C'
$line = Get-Color '#565E6E'

function New-RoundedPath([float]$x, [float]$y, [float]$w, [float]$h, [float]$r) {
  $path = New-Object System.Drawing.Drawing2D.GraphicsPath
  $d = $r * 2
  $path.AddArc($x, $y, $d, $d, 180, 90)
  $path.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
  $path.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
  $path.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
  $path.CloseFigure()
  return $path
}

function Fill-Rounded($g, $color, [float]$x, [float]$y, [float]$w, [float]$h, [float]$r) {
  $brush = New-Object System.Drawing.SolidBrush $color
  $path = New-RoundedPath $x $y $w $h $r
  $g.FillPath($brush, $path)
  $brush.Dispose(); $path.Dispose()
}

function Fill-Gradient($g, $from, $to, [float]$x, [float]$y, [float]$w, [float]$h, [float]$r) {
  $brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush((New-Object System.Drawing.PointF $x, $y), (New-Object System.Drawing.PointF ($x + $w), ($y + $h)), $from, $to)
  $path = New-RoundedPath $x $y $w $h $r
  $g.FillPath($brush, $path)
  $brush.Dispose(); $path.Dispose()
}

function Write-Text($g, [string]$text, [string]$font, [float]$size, $color, [float]$x, [float]$y) {
  $f = New-Object System.Drawing.Font($font, $size)
  $b = New-Object System.Drawing.SolidBrush $color
  $g.DrawString($text, $f, $b, $x, $y)
  $f.Dispose(); $b.Dispose()
}

function Draw-Lines($g, [float]$x, [float]$y, [float]$w, [float[]]$fractions, [float]$gap) {
  foreach ($fraction in $fractions) {
    Fill-Rounded $g $line $x $y ($w * $fraction) 8 4
    $y += $gap
  }
}

function New-Canvas([int]$w, [int]$h) {
  $bitmap = New-Object System.Drawing.Bitmap $w, $h
  $g = [System.Drawing.Graphics]::FromImage($bitmap)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  return @($bitmap, $g)
}

# The icon: the accent's gradient square with the repo's symbol, drawn where the cover puts it
# (120,250, 120 px). $glyph draws the symbol in those coordinates.
function Draw-Icon($g, $cover, [scriptblock]$glyph) {
  Fill-Gradient $g (Get-Color $cover.Accent) (Get-Color $cover.AccentDark) 120 250 120 120 26
  & $glyph $g
}

# The cover, 1600 px wide plus $extra on each side: the ground and the glow fill it all, the
# content stays in the middle 1600x1000.
function Draw-Cover($g, $cover, [int]$extra) {
  $width = 1600 + 2 * $extra
  $g.Clear($ground)
  $glow = New-Object System.Drawing.Drawing2D.LinearGradientBrush((New-Object System.Drawing.Point 0, 0), (New-Object System.Drawing.Point $width, 1000), (Get-Color $cover.Accent 70), (Get-Color $cover.Accent 0))
  $g.FillRectangle($glow, 0, 0, $width, 1000)
  $glow.Dispose()
  $g.TranslateTransform($extra, 0)
  Draw-Icon $g $cover $cover.Glyph
  Write-Text $g $cover.Title 'Segoe UI Semibold' 60 (Get-Color '#ECEFF4') 112 400
  for ($i = 0; $i -lt $cover.Text.Count; $i++) {
    Write-Text $g $cover.Text[$i] 'Segoe UI' 28 (Get-Color '#A0A8B6') 120 (520 + $i * 46)
  }
  Fill-Rounded $g $frame 900 90 580 820 28
  for ($i = 0; $i -lt 3; $i++) { Fill-Rounded $g $line (936 + $i * 40) 122 22 22 11 }
  & $cover.Picture $g
  $g.ResetTransform()
}

function Save-Images($cover) {
  $canvas = New-Canvas 1600 1000
  Draw-Cover $canvas[1] $cover 0
  $canvas[1].Dispose()
  $canvas[0].Save((Join-Path $assets 'cover.png'), [System.Drawing.Imaging.ImageFormat]::Png)
  $canvas[0].Dispose()

  # GitHub's preview is 2:1: the cover widened to 2000x1000, then scaled to 1280x640.
  $wide = New-Canvas 2000 1000
  Draw-Cover $wide[1] $cover 200
  $wide[1].Dispose()
  $social = New-Canvas 1280 640
  $social[1].DrawImage($wide[0], 0, 0, 1280, 640)
  $social[1].Dispose(); $wide[0].Dispose()
  $social[0].Save((Join-Path $assets 'social-preview.png'), [System.Drawing.Imaging.ImageFormat]::Png)
  $social[0].Dispose()

  # The icon, the cover's 120 px square drawn at 240 px on a transparent 256x256.
  $icon = New-Canvas 256 256
  $icon[1].Clear([System.Drawing.Color]::Transparent)
  $icon[1].Transform = New-Object System.Drawing.Drawing2D.Matrix(2, 0, 0, 2, -232, -492)
  Draw-Icon $icon[1] $cover $cover.Glyph
  $icon[1].Dispose()
  $icon[0].Save((Join-Path $assets 'icon.png'), [System.Drawing.Imaging.ImageFormat]::Png)
  $icon[0].Dispose()

  Write-Output 'cover.png, icon.png and social-preview.png written'
}

$cover = @{
  Accent = '#8B7BFF'
  AccentDark = '#4B3FB0'
  Title = 'moilolon.com'
  Text = @('My home page: one place', 'that links to everything I make,', 'and the switcher every site shares.')
}

$cover.Glyph = {
  param($g)
  # The icon: a house.
  $white = Get-Color '#ECEFF4'
  $brush = New-Object System.Drawing.SolidBrush $white
  $roof = [System.Drawing.PointF[]]@((New-Object System.Drawing.PointF 180, 276), (New-Object System.Drawing.PointF 216, 308), (New-Object System.Drawing.PointF 144, 308))
  $g.FillPolygon($brush, $roof)
  $g.FillRectangle($brush, 154, 306, 52, 40)
  $brush.Dispose()
  Fill-Rounded $g (Get-Color '#4B3FB0') 172 322 16 24 3
}

$cover.Picture = {
  param($g)
  # The page: the switcher on top, then a card per site.
  Fill-Rounded $g $sheet 930 176 520 700 18
  Fill-Rounded $g (Get-Color '#8B7BFF') 960 206 150 26 13
  Fill-Rounded $g $line 1370 206 50 26 13
  Fill-Gradient $g (Get-Color '#065F46') (Get-Color '#10B981') 960 262 460 290 16
  $font = New-Object System.Drawing.Font('Consolas', 34)
  $size = $g.MeasureString('<moilolon />', $font)
  $brush = New-Object System.Drawing.SolidBrush (Get-Color '#ECEFF4')
  $g.DrawString('<moilolon />', $font, $brush, (1190 - $size.Width / 2), (407 - $size.Height / 2))
  $font.Dispose(); $brush.Dispose()
  Fill-Gradient $g (Get-Color '#1F6FEB') (Get-Color '#0B3D91') 960 576 220 270 16
  $bars = @(0.35, 0.6, 0.45, 0.8, 0.65)
  for ($i = 0; $i -lt $bars.Count; $i++) {
    $h = 150 * $bars[$i]
    Fill-Rounded $g (Get-Color '#9CC3FF') (990 + $i * 34) (800 - $h) 20 $h 5
  }
  Fill-Rounded $g (Get-Color '#2F3542') 1200 576 220 270 16
  Draw-Lines $g 1224 610 172 @(0.9, 0.7, 0.8, 0.5) 30
}

Save-Images $cover
