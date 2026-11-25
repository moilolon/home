# Draws the README cover (1600x1000, dark) into assets/cover.png, from shapes.
# Run from the repository root: powershell -NoProfile -File assets/draw-cover.ps1
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

# The common cover: dark ground with the accent's glow, the icon, the name and three lines on
# the left; the window on the right, where each repo draws its own picture.
function New-Cover([string]$accent, [string]$accentDark, [string]$title, [string[]]$text) {
  $bitmap = New-Object System.Drawing.Bitmap 1600, 1000
  $g = [System.Drawing.Graphics]::FromImage($bitmap)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
  $g.Clear($ground)
  $glow = New-Object System.Drawing.Drawing2D.LinearGradientBrush((New-Object System.Drawing.Point 0, 0), (New-Object System.Drawing.Point 1600, 1000), (Get-Color $accent 70), (Get-Color $accent 0))
  $g.FillRectangle($glow, 0, 0, 1600, 1000)
  $glow.Dispose()
  Fill-Gradient $g (Get-Color $accent) (Get-Color $accentDark) 120 250 120 120 26
  Write-Text $g $title 'Segoe UI Semibold' 60 (Get-Color '#ECEFF4') 112 400
  for ($i = 0; $i -lt $text.Count; $i++) {
    Write-Text $g $text[$i] 'Segoe UI' 28 (Get-Color '#A0A8B6') 120 (520 + $i * 46)
  }
  Fill-Rounded $g $frame 900 90 580 820 28
  for ($i = 0; $i -lt 3; $i++) { Fill-Rounded $g $line (936 + $i * 40) 122 22 22 11 }
  return @($bitmap, $g)
}

function Save-Cover($canvas) {
  $canvas[1].Dispose()
  $canvas[0].Save((Join-Path $assets 'cover.png'), [System.Drawing.Imaging.ImageFormat]::Png)
  $canvas[0].Dispose()
  Write-Output 'cover.png written'
}

$canvas = New-Cover '#8B7BFF' '#4B3FB0' 'moilolon.com' @('My home page: one place', 'that links to everything I make,', 'and the switcher every site shares.')
$g = $canvas[1]

# The icon: a house.
$white = Get-Color '#ECEFF4'
$brush = New-Object System.Drawing.SolidBrush $white
$roof = [System.Drawing.PointF[]]@((New-Object System.Drawing.PointF 180, 276), (New-Object System.Drawing.PointF 216, 308), (New-Object System.Drawing.PointF 144, 308))
$g.FillPolygon($brush, $roof)
$g.FillRectangle($brush, 154, 306, 52, 40)
$brush.Dispose()
Fill-Rounded $g (Get-Color '#4B3FB0') 172 322 16 24 3

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

Save-Cover $canvas
