Add-Type -AssemblyName System.Drawing

# 1. Generate 512x512 App Icon
$icon = New-Object System.Drawing.Bitmap 512, 512
$g = [System.Drawing.Graphics]::FromImage($icon)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias

# Background Gradient
$rect = New-Object System.Drawing.Rectangle 0, 0, 512, 512
$c1 = [System.Drawing.Color]::FromArgb(255, 15, 23, 42)    # #0f172a
$c2 = [System.Drawing.Color]::FromArgb(255, 30, 27, 75)    # #1e1b4b
$brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush $rect, $c1, $c2, 45.0
$g.FillRectangle($brush, $rect)

# Concentric Rings (Peripheral vision theme)
$penRing1 = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(70, 56, 189, 248), 6) # Cyan
$penRing2 = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(100, 99, 102, 241), 4) # Indigo
$penRing3 = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(150, 14, 165, 233), 8) # Sky blue
$g.DrawEllipse($penRing1, 36, 36, 440, 440)
$g.DrawEllipse($penRing2, 80, 80, 352, 352)
$g.DrawEllipse($penRing3, 124, 124, 264, 264)

# 3x3 Schulte Grid in Center
$gridSize = 3
$cellSize = 44
$spacing = 8
$startX = (512 - ($gridSize * $cellSize + ($gridSize - 1) * $spacing)) / 2
$startY = (512 - ($gridSize * $cellSize + ($gridSize - 1) * $spacing)) / 2

$cellColors = @(
    [System.Drawing.Color]::FromArgb(240, 239, 68, 68),    # Red
    [System.Drawing.Color]::FromArgb(240, 59, 130, 246),   # Blue
    [System.Drawing.Color]::FromArgb(240, 16, 185, 129),   # Emerald
    [System.Drawing.Color]::FromArgb(240, 245, 158, 11),   # Amber
    [System.Drawing.Color]::FromArgb(255, 255, 255, 255),  # Center White Target
    [System.Drawing.Color]::FromArgb(240, 139, 92, 246),   # Purple
    [System.Drawing.Color]::FromArgb(240, 20, 184, 166),   # Teal
    [System.Drawing.Color]::FromArgb(240, 236, 72, 153),   # Pink
    [System.Drawing.Color]::FromArgb(240, 99, 102, 241)    # Indigo
)

$font = New-Object System.Drawing.Font("Arial", 16, [System.Drawing.FontStyle]::Bold)
$textBrushWhite = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
$textBrushDark = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 15, 23, 42))

$index = 0
for ($row = 0; $row -lt $gridSize; $row++) {
    for ($col = 0; $col -lt $gridSize; $col++) {
        $x = $startX + $col * ($cellSize + $spacing)
        $y = $startY + $row * ($cellSize + $spacing)
        $cellRect = New-Object System.Drawing.Rectangle $x, $y, $cellSize, $cellSize
        $cellBrush = New-Object System.Drawing.SolidBrush($cellColors[$index])
        $g.FillRectangle($cellBrush, $cellRect)

        # Draw number
        $numStr = ($index + 1).ToString()
        $tBrush = if ($index -eq 4) { $textBrushDark } else { $textBrushWhite }
        $sf = New-Object System.Drawing.StringFormat
        $sf.Alignment = [System.Drawing.StringAlignment]::Center
        $sf.LineAlignment = [System.Drawing.StringAlignment]::Center
        $rectF = New-Object System.Drawing.RectangleF ([float]$x), ([float]$y), ([float]$cellSize), ([float]$cellSize)
        $g.DrawString($numStr, $font, $tBrush, $rectF, $sf)

        $index++
    }
}

$icon.Save("store/icon_512x512.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$icon.Dispose()
Write-Output "Generated store/icon_512x512.png"

# 2. Generate 1024x500 Feature Graphic
$banner = New-Object System.Drawing.Bitmap 1024, 500
$g2 = [System.Drawing.Graphics]::FromImage($banner)
$g2.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g2.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias

# Background Gradient
$bRect = New-Object System.Drawing.Rectangle 0, 0, 1024, 500
$bc1 = [System.Drawing.Color]::FromArgb(255, 10, 15, 29)
$bc2 = [System.Drawing.Color]::FromArgb(255, 24, 32, 60)
$bBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush $bRect, $bc1, $bc2, 20.0
$g2.FillRectangle($bBrush, $bRect)

# Decorative Rings on the Right
$penDecor1 = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(60, 56, 189, 248), 4)
$penDecor2 = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(80, 129, 140, 248), 6)
$penDecor3 = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(100, 14, 165, 233), 8)
$g2.DrawEllipse($penDecor1, 620, 30, 440, 440)
$g2.DrawEllipse($penDecor2, 670, 80, 340, 340)
$g2.DrawEllipse($penDecor3, 720, 130, 240, 240)

# 3D Grid Accent inside the circle
$accentBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(200, 2, 132, 199))
$g2.FillRectangle($accentBrush, 805, 215, 70, 70)
$fontTarget = New-Object System.Drawing.Font("Arial", 28, [System.Drawing.FontStyle]::Bold)
$sf2 = New-Object System.Drawing.StringFormat
$sf2.Alignment = [System.Drawing.StringAlignment]::Center
$sf2.LineAlignment = [System.Drawing.StringAlignment]::Center
$targetRectF = New-Object System.Drawing.RectangleF 805.0, 215.0, 70.0, 70.0
$g2.DrawString("1", $fontTarget, $textBrushWhite, $targetRectF, $sf2)

# Typography on Left
$titleFont = New-Object System.Drawing.Font("Arial", 42, [System.Drawing.FontStyle]::Bold)
$subFont = New-Object System.Drawing.Font("Arial", 18, [System.Drawing.FontStyle]::Regular)
$badgeFont = New-Object System.Drawing.Font("Arial", 13, [System.Drawing.FontStyle]::Bold)

$cyanBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 56, 189, 248))
$whiteBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
$mutedBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 148, 163, 184))

$g2.DrawString("SCHULTE FOCUS", $titleFont, $whiteBrush, 60, 120)
$g2.DrawString("Focus & Peripheral Vision Training", $subFont, $cyanBrush, 64, 190)

# Feature Badges
$badgeY = 260
$badges = @("✓ Classic Grid (3x3 to 7x7)", "✓ 3D Circular Rings", "✓ 20 Adaptive Challenge Levels", "✓ Detailed Tap Reaction Analytics")
foreach ($b in $badges) {
    $g2.DrawString($b, $subFont, $mutedBrush, 64, $badgeY)
    $badgeY += 40
}

$banner.Save("store/feature_graphic_1024x500.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g2.Dispose()
$banner.Dispose()
Write-Output "Generated store/feature_graphic_1024x500.png"
