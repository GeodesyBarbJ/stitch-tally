# Draws the web app icons (three knit-stitch "V"s on green) into app/icons/.
# Same artwork as android/res/drawable/ic_launcher_fg.xml, on a 108-unit grid.
Add-Type -AssemblyName System.Drawing
$outDir = Join-Path (Split-Path $PSScriptRoot -Parent) "app\icons"
New-Item -ItemType Directory -Force $outDir | Out-Null

function Draw-Icon([int]$size, [string]$name, [double]$zoom) {
    $bmp = New-Object System.Drawing.Bitmap $size, $size
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.Clear([System.Drawing.Color]::FromArgb(0x49, 0x8D, 0x75))
    # zoom > 1 enlarges the artwork for icons without an adaptive safe zone.
    $s = $size / 108.0 * $zoom
    $off = ($size - 108 * $s) / 2
    $pen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(0xF2, 0xD5, 0xB0)), ([float](6 * $s))
    $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    foreach ($dy in 0, 16, 32) {
        foreach ($side in @(@(38, 44), @(70, 64))) {
            # Quadratic (x0,30+dy) Q (qx,46+dy) (54,49+dy) as a cubic Bezier.
            $x0 = $side[0]; $qx = $side[1]
            $p0 = @($x0, (30 + $dy)); $q = @($qx, (46 + $dy)); $p2 = @(54, (49 + $dy))
            $c1 = @(($p0[0] + 2 / 3 * ($q[0] - $p0[0])), ($p0[1] + 2 / 3 * ($q[1] - $p0[1])))
            $c2 = @(($p2[0] + 2 / 3 * ($q[0] - $p2[0])), ($p2[1] + 2 / 3 * ($q[1] - $p2[1])))
            $pt = { param($p) New-Object System.Drawing.PointF ([float]($off + $p[0] * $s)), ([float]($off + ($p[1] - 1.5) * $s)) }
            $g.DrawBezier($pen, (& $pt $p0), (& $pt $c1), (& $pt $c2), (& $pt $p2))
        }
    }
    $bmp.Save((Join-Path $outDir $name), [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose(); $bmp.Dispose()
}

Draw-Icon 180 "apple-touch-icon.png" 1.25
Draw-Icon 192 "icon-192.png" 1.25
Draw-Icon 512 "icon-512.png" 1.25
Draw-Icon 512 "icon-maskable-512.png" 1.0
Get-ChildItem $outDir | ForEach-Object { "$($_.Name) $($_.Length) bytes" }
