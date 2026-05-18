Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Drawing

$Root = Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")
$OutDir = Join-Path $Root "assets\art\generated\pixel_batch_01"
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

function Color([int] $R, [int] $G, [int] $B, [int] $A = 255) {
    return [System.Drawing.Color]::FromArgb($A, $R, $G, $B)
}

function New-Sheet([int] $Width, [int] $Height) {
    $bitmap = [System.Drawing.Bitmap]::new($Width, $Height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.Clear([System.Drawing.Color]::Transparent)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::None
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
    return @{ Bitmap = $bitmap; Graphics = $graphics }
}

function Save-Sheet([hashtable] $Sheet, [string] $Path) {
    if ($null -eq $Sheet.Bitmap -or $null -eq $Sheet.Graphics) {
        throw "Invalid sheet object for $Path."
    }
    $Sheet.Graphics.Dispose()
    $Sheet.Bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    $Sheet.Bitmap.Dispose()
    if (-not (Test-Path -LiteralPath $Path)) {
        throw "Failed to write pixel-art sheet: $Path"
    }
}

function Fill-Rect([System.Drawing.Graphics] $G, [int] $X, [int] $Y, [int] $W, [int] $H, [System.Drawing.Color] $C) {
    $brush = [System.Drawing.SolidBrush]::new($C)
    $G.FillRectangle($brush, $X, $Y, $W, $H)
    $brush.Dispose()
}

function Fill-Ellipse([System.Drawing.Graphics] $G, [int] $X, [int] $Y, [int] $W, [int] $H, [System.Drawing.Color] $C) {
    $brush = [System.Drawing.SolidBrush]::new($C)
    $G.FillEllipse($brush, $X, $Y, $W, $H)
    $brush.Dispose()
}

function Draw-Line([System.Drawing.Graphics] $G, [int] $X1, [int] $Y1, [int] $X2, [int] $Y2, [System.Drawing.Color] $C, [int] $W = 1) {
    $pen = [System.Drawing.Pen]::new($C, $W)
    $G.DrawLine($pen, $X1, $Y1, $X2, $Y2)
    $pen.Dispose()
}

function Draw-Frame-Grid([System.Drawing.Graphics] $G, [int] $FrameW, [int] $FrameH, [int] $Cols, [int] $Rows) {
    $grid = Color 255 255 255 32
    for ($col = 1; $col -lt $Cols; $col++) {
        Fill-Rect $G ($col * $FrameW) 0 1 ($FrameH * $Rows) $grid
    }
    for ($row = 1; $row -lt $Rows; $row++) {
        Fill-Rect $G 0 ($row * $FrameH) ($FrameW * $Cols) 1 $grid
    }
}

function Draw-Player([System.Drawing.Graphics] $G, [int] $Ox, [int] $Oy, [int] $Pose, [string] $Tool) {
    $shadow = Color 50 38 30 54
    $skin = Color 216 154 103
    $hair = Color 66 43 32
    $shirt = Color 103 151 131
    $apron = Color 242 222 178
    $trousers = Color 70 49 45
    $shoe = Color 43 31 31
    $tray = Color 167 118 73
    $cream = Color 255 238 205

    Fill-Ellipse $G ($Ox + 7) ($Oy + 38) 18 5 $shadow
    Fill-Rect $G ($Ox + 12) ($Oy + 26) 4 12 $trousers
    Fill-Rect $G ($Ox + 17) ($Oy + 26) 4 12 $trousers
    Fill-Rect $G ($Ox + 11) ($Oy + 38) 5 3 $shoe
    Fill-Rect $G ($Ox + 17) ($Oy + 38) 5 3 $shoe
    Fill-Rect $G ($Ox + 9) ($Oy + 16) 14 13 $shirt
    Fill-Rect $G ($Ox + 11) ($Oy + 18) 10 14 $apron
    Fill-Rect $G ($Ox + 13) ($Oy + 20) 6 2 (Color 214 189 145)
    Fill-Ellipse $G ($Ox + 9) ($Oy + 6) 14 13 $skin
    Fill-Rect $G ($Ox + 9) ($Oy + 5) 14 5 $hair
    Fill-Rect $G ($Ox + 12) ($Oy + 4) 8 3 $hair

    if ($Pose % 2 -eq 0) {
        Fill-Rect $G ($Ox + 6) ($Oy + 20) 4 9 $skin
        Fill-Rect $G ($Ox + 22) ($Oy + 20) 4 9 $skin
    } else {
        Fill-Rect $G ($Ox + 5) ($Oy + 18) 4 8 $skin
        Fill-Rect $G ($Ox + 23) ($Oy + 22) 4 8 $skin
    }

    if ($Tool -eq "bowl") {
        Fill-Ellipse $G ($Ox + 7) ($Oy + 28) 18 8 (Color 130 160 150)
        Fill-Rect $G ($Ox + 11) ($Oy + 28) 10 3 $cream
        Draw-Line $G ($Ox + 14) ($Oy + 27) ($Ox + 22) ($Oy + 21) (Color 117 78 48) 2
    } elseif ($Tool -eq "tray") {
        Fill-Rect $G ($Ox + 5) ($Oy + 27) 22 7 $tray
        Fill-Rect $G ($Ox + 8) ($Oy + 25) 5 4 (Color 230 172 80)
        Fill-Rect $G ($Ox + 16) ($Oy + 25) 6 4 (Color 205 106 78)
    } elseif ($Tool -eq "box") {
        Fill-Rect $G ($Ox + 6) ($Oy + 25) 20 11 (Color 184 128 72)
        Fill-Rect $G ($Ox + 8) ($Oy + 27) 16 2 (Color 220 171 96)
    }
}

function Draw-Oven([System.Drawing.Graphics] $G, [int] $Ox, [int] $Oy, [int] $Frame) {
    $body = Color 197 92 73
    $edge = Color 101 67 58
    $cream = Color 240 218 174
    $metal = Color 139 126 112
    $glow = Color (255) (150 + ($Frame * 14 % 80)) 42
    Fill-Ellipse $G ($Ox + 11) ($Oy + 52) 42 7 (Color 55 40 30 54)
    Fill-Rect $G ($Ox + 12) ($Oy + 16) 40 34 $edge
    Fill-Rect $G ($Ox + 15) ($Oy + 12) 34 37 $body
    Fill-Rect $G ($Ox + 18) ($Oy + 18) 28 19 $cream
    Fill-Rect $G ($Ox + 21) ($Oy + 21) 22 13 $glow
    Fill-Rect $G ($Ox + 20) ($Oy + 38) 24 3 $metal
    Fill-Rect $G ($Ox + 41) ($Oy + 14) 4 4 (Color 245 205 91)
    Fill-Rect $G ($Ox + 17) ($Oy + 11) 30 3 (Color 232 125 95)
    if ($Frame -gt 1) {
        Draw-Line $G ($Ox + 25) ($Oy + 8) ($Ox + 24) ($Oy + 3) (Color 255 181 73 120) 2
        Draw-Line $G ($Ox + 36) ($Oy + 8) ($Ox + 38) ($Oy + 2) (Color 255 181 73 100) 2
    }
}

function Draw-PrepCounter([System.Drawing.Graphics] $G, [int] $Ox, [int] $Oy, [int] $Frame) {
    Fill-Ellipse $G ($Ox + 9) ($Oy + 52) 46 6 (Color 54 37 27 50)
    Fill-Rect $G ($Ox + 8) ($Oy + 24) 48 22 (Color 126 82 54)
    Fill-Rect $G ($Ox + 10) ($Oy + 18) 44 14 (Color 218 203 177)
    Fill-Rect $G ($Ox + 12) ($Oy + 21) 13 8 (Color 235 226 198)
    Fill-Ellipse $G ($Ox + 31) ($Oy + 20) 14 8 (Color 127 158 151)
    Draw-Line $G ($Ox + 19) ($Oy + 18) ($Ox + 36 + $Frame) ($Oy + 13) (Color 114 73 43) 2
    Fill-Rect $G ($Ox + 45) ($Oy + 23) 6 4 (Color 241 218 159)
    if ($Frame % 2 -eq 0) {
        Fill-Rect $G ($Ox + 14) ($Oy + 16) 12 2 (Color 255 248 218 180)
    }
}

function Draw-DisplayCase([System.Drawing.Graphics] $G, [int] $Ox, [int] $Oy, [int] $Stock) {
    Fill-Ellipse $G ($Ox + 7) ($Oy + 51) 50 7 (Color 54 37 27 50)
    Fill-Rect $G ($Ox + 8) ($Oy + 24) 48 24 (Color 112 75 51)
    Fill-Rect $G ($Ox + 11) ($Oy + 18) 42 20 (Color 152 210 219 135)
    Fill-Rect $G ($Ox + 13) ($Oy + 36) 38 3 (Color 232 201 144)
    for ($i = 0; $i -lt $Stock; $i++) {
        $x = $Ox + 15 + (($i % 5) * 7)
        $y = $Oy + 26 - ([Math]::Floor($i / 5) * 7)
        Fill-Rect $G $x $y 5 4 (Color 228 149 81)
        Fill-Rect $G ($x + 1) ($y - 1) 3 1 (Color 251 219 145)
    }
}

function Draw-DirtyTable([System.Drawing.Graphics] $G, [int] $Ox, [int] $Oy, [int] $Frame) {
    Fill-Ellipse $G ($Ox + 12) ($Oy + 51) 40 7 (Color 54 37 27 50)
    Fill-Ellipse $G ($Ox + 16) ($Oy + 18) 32 25 (Color 135 87 55)
    Fill-Ellipse $G ($Ox + 19) ($Oy + 20) 26 19 (Color 175 118 70)
    if ($Frame -lt 4) {
        Fill-Rect $G ($Ox + 25) ($Oy + 25) 6 3 (Color 94 64 44)
        Fill-Rect $G ($Ox + 33) ($Oy + 29) 7 3 (Color 236 212 162)
    }
    $wipeX = $Ox + 15 + ($Frame * 5)
    Fill-Rect $G $wipeX ($Oy + 22) 8 4 (Color 101 164 151)
    Draw-Line $G ($wipeX + 2) ($Oy + 19) ($wipeX + 13) ($Oy + 14) (Color 82 52 36) 2
}

function Draw-Crate([System.Drawing.Graphics] $G, [int] $Ox, [int] $Oy, [int] $FillLevel) {
    Fill-Ellipse $G ($Ox + 13) ($Oy + 50) 38 7 (Color 54 37 27 50)
    Fill-Rect $G ($Ox + 14) ($Oy + 25) 36 22 (Color 139 88 48)
    Fill-Rect $G ($Ox + 16) ($Oy + 27) 32 4 (Color 190 128 66)
    Draw-Line $G ($Ox + 15) ($Oy + 35) ($Ox + 48) ($Oy + 35) (Color 94 58 36) 2
    for ($i = 0; $i -lt $FillLevel; $i++) {
        $x = $Ox + 18 + (($i % 4) * 7)
        $y = $Oy + 21 - ([Math]::Floor($i / 4) * 5)
        Fill-Rect $G $x $y 6 7 (Color 222 196 129)
        Fill-Rect $G ($x + 1) ($y + 1) 4 2 (Color 245 232 181)
    }
}

function Draw-FoodIcon([System.Drawing.Graphics] $G, [int] $Ox, [int] $Oy, [int] $Index) {
    Fill-Ellipse $G ($Ox + 7) ($Oy + 26) 18 4 (Color 54 37 27 45)
    switch ($Index) {
        0 { Fill-Ellipse $G ($Ox + 9) ($Oy + 13) 14 12 (Color 226 154 91); Fill-Rect $G ($Ox + 12) ($Oy + 10) 8 4 (Color 255 239 210) }
        1 { Fill-Ellipse $G ($Ox + 7) ($Oy + 12) 18 11 (Color 211 143 70); Fill-Rect $G ($Ox + 10) ($Oy + 16) 12 4 (Color 247 214 134) }
        2 { Fill-Rect $G ($Ox + 8) ($Oy + 12) 16 12 (Color 242 192 78); Fill-Rect $G ($Ox + 10) ($Oy + 14) 12 4 (Color 207 82 72) }
        3 { Fill-Ellipse $G ($Ox + 8) ($Oy + 12) 16 12 (Color 251 226 137); Fill-Rect $G ($Ox + 12) ($Oy + 15) 8 3 (Color 245 247 226) }
        4 { Fill-Rect $G ($Ox + 11) ($Oy + 9) 10 16 (Color 147 105 68); Fill-Rect $G ($Ox + 12) ($Oy + 10) 8 4 (Color 243 226 182) }
        5 { Fill-Ellipse $G ($Ox + 8) ($Oy + 11) 16 14 (Color 172 96 63); Fill-Rect $G ($Ox + 12) ($Oy + 15) 3 3 (Color 91 53 42); Fill-Rect $G ($Ox + 18) ($Oy + 18) 3 3 (Color 91 53 42) }
        6 { Fill-Rect $G ($Ox + 8) ($Oy + 14) 17 9 (Color 114 170 108); Fill-Rect $G ($Ox + 11) ($Oy + 11) 12 4 (Color 235 229 157) }
        7 { Fill-Rect $G ($Ox + 10) ($Oy + 11) 12 13 (Color 178 88 73); Fill-Rect $G ($Ox + 12) ($Oy + 8) 8 4 (Color 230 216 164) }
    }
}

$manifest = [ordered]@{
    batch = "pixel_batch_01"
    style = "transparent cozy top-down pixel art, fixed-frame Godot sprite sheets"
    assets = @()
}

$sheet = New-Sheet 192 96
for ($row = 0; $row -lt 2; $row++) {
    for ($col = 0; $col -lt 6; $col++) {
        $tool = @("none", "bowl", "bowl", "tray", "box", "none")[$col]
        if ($row -eq 1) { $tool = @("tray", "tray", "box", "box", "none", "none")[$col] }
        Draw-Player $sheet.Graphics ($col * 32) ($row * 48) $col $tool
    }
}
Draw-Frame-Grid $sheet.Graphics 32 48 6 2
$path = Join-Path $OutDir "player_prep_carry_6x2.png"
Save-Sheet $sheet $path
$manifest.assets += [ordered]@{ file = "player_prep_carry_6x2.png"; frame_size = "32x48"; grid = "6x2"; animations = @("prep row 0", "carry row 1") }

$sheet = New-Sheet 384 64
for ($col = 0; $col -lt 6; $col++) { Draw-Oven $sheet.Graphics ($col * 64) 0 $col }
Draw-Frame-Grid $sheet.Graphics 64 64 6 1
$path = Join-Path $OutDir "oven_basic_bake_cycle_6x1.png"
Save-Sheet $sheet $path
$manifest.assets += [ordered]@{ file = "oven_basic_bake_cycle_6x1.png"; frame_size = "64x64"; grid = "6x1"; animations = @("bake_heat_loop") }

$sheet = New-Sheet 384 64
for ($col = 0; $col -lt 6; $col++) { Draw-PrepCounter $sheet.Graphics ($col * 64) 0 $col }
Draw-Frame-Grid $sheet.Graphics 64 64 6 1
$path = Join-Path $OutDir "prep_counter_work_cycle_6x1.png"
Save-Sheet $sheet $path
$manifest.assets += [ordered]@{ file = "prep_counter_work_cycle_6x1.png"; frame_size = "64x64"; grid = "6x1"; animations = @("prep_work_loop") }

$sheet = New-Sheet 256 64
for ($col = 0; $col -lt 4; $col++) { Draw-DisplayCase $sheet.Graphics ($col * 64) 0 ($col * 4) }
Draw-Frame-Grid $sheet.Graphics 64 64 4 1
$path = Join-Path $OutDir "display_case_stock_states_4x1.png"
Save-Sheet $sheet $path
$manifest.assets += [ordered]@{ file = "display_case_stock_states_4x1.png"; frame_size = "64x64"; grid = "4x1"; animations = @("empty", "low", "medium", "full") }

$sheet = New-Sheet 384 64
for ($col = 0; $col -lt 6; $col++) { Draw-DirtyTable $sheet.Graphics ($col * 64) 0 $col }
Draw-Frame-Grid $sheet.Graphics 64 64 6 1
$path = Join-Path $OutDir "dirty_table_clean_loop_6x1.png"
Save-Sheet $sheet $path
$manifest.assets += [ordered]@{ file = "dirty_table_clean_loop_6x1.png"; frame_size = "64x64"; grid = "6x1"; animations = @("wipe_clean_loop") }

$sheet = New-Sheet 256 64
for ($col = 0; $col -lt 4; $col++) { Draw-Crate $sheet.Graphics ($col * 64) 0 ($col * 3) }
Draw-Frame-Grid $sheet.Graphics 64 64 4 1
$path = Join-Path $OutDir "ingredient_crate_stock_states_4x1.png"
Save-Sheet $sheet $path
$manifest.assets += [ordered]@{ file = "ingredient_crate_stock_states_4x1.png"; frame_size = "64x64"; grid = "4x1"; animations = @("empty", "low", "medium", "full") }

$sheet = New-Sheet 256 64
for ($row = 0; $row -lt 2; $row++) {
    for ($col = 0; $col -lt 8; $col++) {
        Draw-FoodIcon $sheet.Graphics ($col * 32) ($row * 32) (($row * 8 + $col) % 8)
    }
}
Draw-Frame-Grid $sheet.Graphics 32 32 8 2
$path = Join-Path $OutDir "starter_food_icons_8x2.png"
Save-Sheet $sheet $path
$manifest.assets += [ordered]@{ file = "starter_food_icons_8x2.png"; frame_size = "32x32"; grid = "8x2"; animations = @("food item icons and duplicate highlight row") }

$manifestPath = Join-Path $OutDir "pixel_batch_01_manifest.json"
$manifest | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $manifestPath -Encoding UTF8

Write-Host "Generated pixel-art batch:"
Get-ChildItem -LiteralPath $OutDir -Filter "*.png" | Sort-Object Name | ForEach-Object {
    Write-Host (" - " + $_.FullName)
}
